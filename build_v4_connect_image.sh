#!/usr/bin/env bash
set -euo pipefail

#===============================================================================
# V4 Connect - Chatwoot Build Script
#===============================================================================
# Cria uma imagem Docker do Chatwoot customizada com:
# - Branding V4 Connect (logo, cores, nome)
# - Tradução PT-BR (super admin, onboarding, login)
# - Paleta de cores vermelha (#e50914)
# - Tipografia Proxima Nova / Bebas Neue
#
# Uso:
#   ./build_v4_connect_image.sh                    # build padrão
#   CHATWOOT_VERSION=v4.9.0 ./build_v4_connect_image.sh  # versão específica
#   NO_CACHE=true ./build_v4_connect_image.sh      # sem cache Docker
#
# Requer: docker, git
#===============================================================================

# Configurações
CHATWOOT_VERSION="${CHATWOOT_VERSION:-v4.8.0}"
IMAGE_TAG="${IMAGE_TAG:-v4-connect/chatwoot:${CHATWOOT_VERSION}-branded}"
BUILD_ROOT="$(dirname "$(readlink -f "$0")")"
WORKDIR="${BUILD_ROOT}/.build/chatwoot"
NO_CACHE="${NO_CACHE:-false}"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  V4 Connect - Chatwoot Build${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
log_info "Versão base: ${CHATWOOT_VERSION}"
log_info "Tag da imagem: ${IMAGE_TAG}"
echo ""

#-------------------------------------------------------------------------------
# 1. Preparar ambiente
#-------------------------------------------------------------------------------
log_info "Preparando ambiente de build..."
rm -rf "${BUILD_ROOT}/.build"
mkdir -p "${WORKDIR}"

#-------------------------------------------------------------------------------
# 2. Clonar Chatwoot
#-------------------------------------------------------------------------------
log_info "Clonando Chatwoot ${CHATWOOT_VERSION}..."
git clone --depth 1 --branch "${CHATWOOT_VERSION}" \
    https://github.com/chatwoot/chatwoot.git "${WORKDIR}"
cd "${WORKDIR}"
log_success "Clone concluído"

#-------------------------------------------------------------------------------
# 3. Aplicar patches
#-------------------------------------------------------------------------------
log_info "Aplicando patches..."

# Aplicar todos os patches em ordem numérica
PATCH_DIR="${BUILD_ROOT}/patches"
if [ -d "$PATCH_DIR" ]; then
    for patch in $(ls -1 "$PATCH_DIR"/*.patch 2>/dev/null | sort); do
        patch_name=$(basename "$patch")
        if git apply --check "$patch" 2>/dev/null; then
            git apply "$patch"
            log_success "Patch aplicado: ${patch_name}"
        else
            log_warn "Patch ignorado (já aplicado ou incompatível): ${patch_name}"
        fi
    done
fi

#-------------------------------------------------------------------------------
# 4. Aplicar customizações via sed (temporário até migrar para patches)
#-------------------------------------------------------------------------------
log_info "Aplicando customizações adicionais..."

# Paleta de cores V4 (vermelho #e50914)
COLORS_FILE="theme/colors.js"
if [ -f "$COLORS_FILE" ]; then
    sed -i "s/25: blue.blue2,/25: '#fef2f2',/" "$COLORS_FILE"
    sed -i "s/50: blue.blue3,/50: '#fee2e2',/" "$COLORS_FILE"
    sed -i "s/75: blue.blue4,/75: '#fecaca',/" "$COLORS_FILE"
    sed -i "s/100: blue.blue5,/100: '#fca5a5',/" "$COLORS_FILE"
    sed -i "s/200: blue.blue7,/200: '#f87171',/" "$COLORS_FILE"
    sed -i "s/300: blue.blue8,/300: '#ef4444',/" "$COLORS_FILE"
    sed -i "s/400: blueDark.blue11,/400: '#dc2626',/" "$COLORS_FILE"
    sed -i "s/500: blueDark.blue10,/500: '#e50914',/" "$COLORS_FILE"
    sed -i "s/600: blueDark.blue9,/600: '#c10812',/" "$COLORS_FILE"
    sed -i "s/700: blueDark.blue8,/700: '#9a060e',/" "$COLORS_FILE"
    sed -i "s/800: blueDark.blue6,/800: '#73050b',/" "$COLORS_FILE"
    sed -i "s/900: blueDark.blue2,/900: '#4c0307',/" "$COLORS_FILE"
    log_success "Paleta de cores V4 aplicada"
fi

# Tipografia V4 (Proxima Nova / Bebas Neue)
TAILWIND_FILE="tailwind.config.js"
if [ -f "$TAILWIND_FILE" ]; then
    sed -i "/const defaultSansFonts = \[/a\\  '\"Proxima Nova\"',\n  '\"Bebas Neue\"'," "$TAILWIND_FILE"
    log_success "Tipografia V4 aplicada"
fi

#-------------------------------------------------------------------------------
# 5. Rebranding em arquivos JSON (seguro - não quebra código Ruby)
#-------------------------------------------------------------------------------
log_info "Aplicando rebranding em locales..."

# Widget e Survey - "Powered by" footer
find app/javascript/widget/i18n/locale -name "*.json" \
    -exec sed -i 's/"Powered by Chatwoot"/"Powered by V4 Connect"/g' {} \; 2>/dev/null || true
find app/javascript/survey/i18n/locale -name "*.json" \
    -exec sed -i 's/"Powered by Chatwoot"/"Powered by V4 Connect"/g' {} \; 2>/dev/null || true

# Dashboard locales
find app/javascript/dashboard/i18n/locale -name "*.json" \
    -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true

# Portal/shared locales
find app/javascript/portal/i18n/locale -name "*.json" \
    -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true
find app/javascript/shared/i18n -name "*.json" \
    -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true

# Widget/Survey geral
find app/javascript -name "*.json" \
    -exec sed -i 's/"Chatwoot"/"V4 Connect"/g' {} \; 2>/dev/null || true

# Email templates (Liquid - seguro)
find app/views/mailers -name "*.liquid" \
    -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true

log_success "Rebranding aplicado em locales"

#-------------------------------------------------------------------------------
# 6. Tradução do Super Admin para PT-BR
#-------------------------------------------------------------------------------
log_info "Aplicando tradução PT-BR do Super Admin..."

# Navegação principal
NAV_FILE="app/views/super_admin/application/_navigation.html.erb"
if [ -f "$NAV_FILE" ]; then
    sed -i "s|label: 'Dashboard'|label: 'Painel'|g" "$NAV_FILE"
    sed -i "s|label: 'Sidekiq Dashboard'|label: 'Painel Sidekiq'|g" "$NAV_FILE"
    sed -i "s|label: 'Instance Health'|label: 'Saúde da Instância'|g" "$NAV_FILE"
    sed -i "s|label: 'Agent Dashboard'|label: 'Painel do Agente'|g" "$NAV_FILE"
    sed -i "s|label: 'Logout'|label: 'Sair'|g" "$NAV_FILE"
    sed -i "s|Super Admin Console|Console Super Admin|g" "$NAV_FILE"
fi

# Menu de configurações
SETTINGS_MENU="app/views/super_admin/application/_settings_menu.html.erb"
if [ -f "$SETTINGS_MENU" ]; then
    sed -i "s|>Settings<|>Configurações<|g" "$SETTINGS_MENU"
fi

# Página de configurações
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
if [ -f "$SETTINGS_SHOW" ]; then
    sed -i "s|Settings<|Configurações<|g" "$SETTINGS_SHOW"
    sed -i "s|Update your instance settings, access billing portal|Atualize as configurações da instância, acesse o portal de cobrança|g" "$SETTINGS_SHOW"
    sed -i "s|>Alert!<|>Alerta!<|g" "$SETTINGS_SHOW"
    sed -i "s|Unauthorized premium changes detected in Chatwoot. To keep using them, please upgrade your plan.|Alterações premium não autorizadas detectadas. Para continuar usando, atualize seu plano.|g" "$SETTINGS_SHOW"
    sed -i "s|Contact for help :|Contato para ajuda:|g" "$SETTINGS_SHOW"
    sed -i "s|Installation Identifier|Identificador da Instalação|g" "$SETTINGS_SHOW"
    sed -i "s|Current plan|Plano Atual|g" "$SETTINGS_SHOW"
    sed -i "s|>Refresh<|>Atualizar<|g" "$SETTINGS_SHOW"
    sed -i "s|>Manage<|>Gerenciar<|g" "$SETTINGS_SHOW"
    sed -i "s|Please add more licenses to add more users|Por favor, adicione mais licenças para adicionar mais usuários|g" "$SETTINGS_SHOW"
    sed -i "s|Need help?|Precisa de ajuda?|g" "$SETTINGS_SHOW"
    sed -i "s|Do you face any issues? We are here to help.|Está com algum problema? Estamos aqui para ajudar.|g" "$SETTINGS_SHOW"
    sed -i "s|>Community Support<|>Suporte da Comunidade<|g" "$SETTINGS_SHOW"
    sed -i "s|>Chat Support<|>Suporte por Chat<|g" "$SETTINGS_SHOW"
    sed -i "s|>Features<|>Funcionalidades<|g" "$SETTINGS_SHOW"
fi

# App configs
APP_CONFIG="app/views/super_admin/app_configs/show.html.erb"
if [ -f "$APP_CONFIG" ]; then
    sed -i "s|Configure Settings|Configurar Definições|g" "$APP_CONFIG"
    sed -i "s|>Submit<|>Enviar<|g" "$APP_CONFIG"
fi

# Reset cache
RESET_CACHE="app/views/super_admin/accounts/_reset_cache.html.erb"
if [ -f "$RESET_CACHE" ]; then
    sed -i "s|Reset Frontend Cache|Limpar Cache do Frontend|g" "$RESET_CACHE"
    sed -i "s|This will clear the IndexedDB cache keys from redis|Isso irá limpar as chaves de cache do IndexedDB no Redis|g" "$RESET_CACHE"
    sed -i "s|Next reload would fetch the data from backend|O próximo carregamento buscará os dados do backend|g" "$RESET_CACHE"
fi

# Seed data
SEED_DATA="app/views/super_admin/accounts/_seed_data.html.erb"
if [ -f "$SEED_DATA" ]; then
    sed -i "s|Generate Seed Data|Gerar Dados de Exemplo|g" "$SEED_DATA"
    sed -i "s|Click the button to generate seed data into this account for demos|Clique no botão para gerar dados de exemplo nesta conta para demonstrações|g" "$SEED_DATA"
    sed -i "s|Note: This will clear all the existing data in this account|Nota: Isso irá limpar todos os dados existentes nesta conta|g" "$SEED_DATA"
fi

# Onboarding
ONBOARDING_FILE="app/views/installation/onboarding/index.html.erb"
if [ -f "$ONBOARDING_FILE" ]; then
    sed -i '/<title>SuperAdmin | Chatwoot<\/title>/c\    <% installation_name = GlobalConfig.get('\''INSTALLATION_NAME'\'')['\''INSTALLATION_NAME'\''] || '\''Chatwoot'\'' %>\n    <title>SuperAdmin | <%= installation_name %></title>' "$ONBOARDING_FILE"
    sed -i 's|alt="Chatwoot"|alt="<%= installation_name %>"|g' "$ONBOARDING_FILE"
    sed -i 's|Howdy, Welcome to Chatwoot|Boas-vindas ao <%= installation_name %>|g' "$ONBOARDING_FILE"
    sed -i 's|Company Name|Nome da Empresa|g' "$ONBOARDING_FILE"
    sed -i 's|Work Email|E-mail Corporativo|g' "$ONBOARDING_FILE"
    sed -i 's|Password|Senha|g' "$ONBOARDING_FILE"
    sed -i 's|Enter your full name. eg: Bruce Wayne|Digite seu nome completo|g' "$ONBOARDING_FILE"
    sed -i 's|Enter your company name. eg: Wayne Enterprises|Digite o nome da sua empresa|g' "$ONBOARDING_FILE"
    sed -i 's|Enter your work email address. eg: bruce@wayne.enterprises|Digite seu e-mail corporativo|g' "$ONBOARDING_FILE"
    sed -i 's|Enter a password with 6 characters or more.|Digite uma senha com 6 ou mais caracteres|g' "$ONBOARDING_FILE"
    sed -i 's|Subscribe to release notes, newsletters & product feedback surveys.|Receber novidades, atualizações e pesquisas de feedback.|g' "$ONBOARDING_FILE"
    sed -i 's|Finish Setup|Concluir Configuração|g' "$ONBOARDING_FILE"
fi

log_success "Tradução PT-BR aplicada"

#-------------------------------------------------------------------------------
# 7. Adicionar locale PT-BR para Administrate
#-------------------------------------------------------------------------------
log_info "Adicionando locale PT-BR..."

cat >> config/locales/pt_BR.yml << 'LOCALE_EOF'

  # Super Admin translations - V4 Connect
  super_admin:
    resources:
      account:
        one: Conta
        other: Contas
      user:
        one: Usuário
        other: Usuários
      platform_app:
        one: App da Plataforma
        other: Apps da Plataforma
      agent_bot:
        one: Bot Agente
        other: Bots Agentes

  administrate:
    actions:
      show_resource: "Visualizar %{name}"
      destroy: "Excluir"
      confirm: "Tem certeza?"
      edit: "Editar"
      new_resource: "Novo %{name}"
      back: "Voltar"
    search:
      label: "Pesquisar %{resource}"
      clear: "Limpar pesquisa"
    controller:
      create:
        success: "%{resource} foi criado com sucesso."
      update:
        success: "%{resource} foi atualizado com sucesso."
      destroy:
        success: "%{resource} foi excluído com sucesso."
    fields:
      has_many:
        more: "e mais %{count}"
    pagination:
      first: "&laquo; Primeira"
      last: "Última &raquo;"
      previous: "&lsaquo; Anterior"
      next: "Próxima &rsaquo;"
      truncate: "&hellip;"
LOCALE_EOF

log_success "Locale PT-BR adicionado"

#-------------------------------------------------------------------------------
# 8. Corrigir Dockerfile (git SHA workaround)
#-------------------------------------------------------------------------------
log_info "Aplicando correção no Dockerfile..."
sed -i 's|rm -rf spec node_modules tmp/cache;|git rev-parse HEAD > /app/.git_sha \&\& rm -rf spec node_modules tmp/cache;|' docker/Dockerfile
sed -i '/^RUN git rev-parse HEAD > \/app\/.git_sha$/d' docker/Dockerfile
log_success "Dockerfile corrigido"

#-------------------------------------------------------------------------------
# 9. Copiar brand assets
#-------------------------------------------------------------------------------
log_info "Copiando brand assets..."
mkdir -p "${WORKDIR}/public/brand-assets"
cp -r "${BUILD_ROOT}/branding/." "${WORKDIR}/public/brand-assets/"
log_success "Brand assets copiados"

#-------------------------------------------------------------------------------
# 10. Build da imagem Docker
#-------------------------------------------------------------------------------
echo ""
log_info "Construindo imagem Docker..."
log_info "Tag: ${IMAGE_TAG}"

DOCKER_BUILD_ARGS=""
if [ "$NO_CACHE" = "true" ]; then
    DOCKER_BUILD_ARGS="--no-cache"
    log_info "Build sem cache (NO_CACHE=true)"
fi

docker build \
    $DOCKER_BUILD_ARGS \
    -f docker/Dockerfile \
    -t "${IMAGE_TAG}" \
    .

#-------------------------------------------------------------------------------
# Resumo final
#-------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Build concluído com sucesso!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Customizações aplicadas:"
echo "  ✓ Rebranding: Chatwoot → V4 Connect"
echo "  ✓ Paleta de cores vermelha (#e50914)"
echo "  ✓ Tipografia: Proxima Nova / Bebas Neue"
echo "  ✓ Super Admin Console em PT-BR"
echo "  ✓ Onboarding em PT-BR"
echo "  ✓ Login Super Admin em PT-BR"
echo "  ✓ Brand assets customizados"
echo ""
echo "Próximos passos:"
echo "  1. Testar localmente:"
echo "     docker-compose -f docker/docker-compose.yml up"
echo ""
echo "  2. Aplicar branding no banco:"
echo "     ./scripts/apply_branding.sh --container chatwoot_chatwoot-web"
echo ""
echo "  3. Push para registry (se necessário):"
echo "     docker tag ${IMAGE_TAG} ghcr.io/badwolf1509/v4-connect-chatwoot:latest"
echo "     docker push ghcr.io/badwolf1509/v4-connect-chatwoot:latest"
echo ""
