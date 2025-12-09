#!/usr/bin/env bash
set -euo pipefail

# Cria uma imagem Chatwoot customizada com paleta V4 e fontes priorizando Proxima Nova/Bebas.
# Requer docker e git.

CHATWOOT_VERSION="${CHATWOOT_VERSION:-v4.8.0}"
IMAGE_TAG="${IMAGE_TAG:-v4-connect/chatwoot:${CHATWOOT_VERSION}-branded}"
BUILD_ROOT="$(dirname "$(readlink -f "$0")")"
WORKDIR="${BUILD_ROOT}/.build/chatwoot"

rm -rf "${BUILD_ROOT}/.build"
mkdir -p "${WORKDIR}"

echo "Clonando Chatwoot (${CHATWOOT_VERSION})..."
git clone --depth 1 --branch "${CHATWOOT_VERSION}" https://github.com/chatwoot/chatwoot.git "${WORKDIR}"

echo "Aplicando patch de templates (super_admin PT-BR)..."
cd "${WORKDIR}"
git apply "${BUILD_ROOT}/v4-connect.patch"

echo "Aplicando tradução do onboarding para PT-BR..."
ONBOARDING_FILE="app/views/installation/onboarding/index.html.erb"
# Title e installation_name
sed -i '/<title>SuperAdmin | Chatwoot<\/title>/c\    <% installation_name = GlobalConfig.get('\''INSTALLATION_NAME'\'')['\''INSTALLATION_NAME'\''] || '\''Chatwoot'\'' %>\n    <title>SuperAdmin | <%= installation_name %></title>' "$ONBOARDING_FILE"
# Logo alt tags
sed -i 's|alt="Chatwoot"|alt="<%= installation_name %>"|g' "$ONBOARDING_FILE"
# Welcome message
sed -i 's|Howdy, Welcome to Chatwoot|Boas-vindas ao <%= installation_name %>|g' "$ONBOARDING_FILE"
# Labels
sed -i 's|<label for="name" class="flex justify-between text-sm font-medium leading-6 text-slate-900 dark:text-white">\s*Name|<label for="name" class="flex justify-between text-sm font-medium leading-6 text-slate-900 dark:text-white">\n                  Nome|g' "$ONBOARDING_FILE"
sed -i 's|Company Name|Nome da Empresa|g' "$ONBOARDING_FILE"
sed -i 's|Work Email|E-mail Corporativo|g' "$ONBOARDING_FILE"
sed -i 's|Password|Senha|g' "$ONBOARDING_FILE"
# Placeholders
sed -i 's|Enter your full name. eg: Bruce Wayne|Digite seu nome completo|g' "$ONBOARDING_FILE"
sed -i 's|Enter your company name. eg: Wayne Enterprises|Digite o nome da sua empresa|g' "$ONBOARDING_FILE"
sed -i 's|Enter your work email address. eg: bruce@wayne.enterprises|Digite seu e-mail corporativo|g' "$ONBOARDING_FILE"
sed -i 's|Enter a password with 6 characters or more.|Digite uma senha com 6 ou mais caracteres|g' "$ONBOARDING_FILE"
# Checkbox label
sed -i 's|Subscribe to release notes, newsletters & product feedback surveys.|Receber novidades, atualizações e pesquisas de feedback.|g' "$ONBOARDING_FILE"
# Button
sed -i 's|Finish Setup|Concluir Configuração|g' "$ONBOARDING_FILE"

echo "Aplicando paleta de cores V4 (vermelho #e50914)..."
COLORS_FILE="theme/colors.js"
# Substituir a paleta woot de azul para vermelho V4
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

echo "Aplicando tipografia V4 (Proxima Nova / Bebas Neue)..."
TAILWIND_FILE="tailwind.config.js"
# Inserir fontes V4 no início do array defaultSansFonts
sed -i "/const defaultSansFonts = \[/a\\  '\"Proxima Nova\"',\n  '\"Bebas Neue\"'," "$TAILWIND_FILE"

echo "Aplicando rebranding: Chatwoot → V4 Connect..."
# IMPORTANTE: NÃO substituir em arquivos ERB/Ruby para evitar quebrar classes Ruby
# como ChatwootHub, ChatwootMarkdownRenderer, etc.
# O nome exibido é controlado via INSTALLATION_NAME no banco de dados.

# Widget e Survey - "Powered by" footer (JSON é seguro)
find app/javascript/widget/i18n/locale -name "*.json" -exec sed -i 's/"Powered by Chatwoot"/"Powered by V4 Connect"/g' {} \;
find app/javascript/survey/i18n/locale -name "*.json" -exec sed -i 's/"Powered by Chatwoot"/"Powered by V4 Connect"/g' {} \;

# Email templates (Liquid) - seguro, não contém código Ruby
find app/views/mailers -name "*.liquid" -exec sed -i 's/Chatwoot/V4 Connect/g' {} \;

# Dashboard locales - JSON é seguro (substitui texto de exibição)
find app/javascript/dashboard/i18n/locale -name "*.json" -exec sed -i 's/Chatwoot/V4 Connect/g' {} \;

# Portal/public locales - JSON é seguro
find app/javascript/portal/i18n/locale -name "*.json" -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true
find app/javascript/shared/i18n -name "*.json" -exec sed -i 's/Chatwoot/V4 Connect/g' {} \; 2>/dev/null || true

# Widget/Survey/SDK locales e mensagens - JSON é seguro
find app/javascript -name "*.json" -exec sed -i 's/"Chatwoot"/"V4 Connect"/g' {} \; 2>/dev/null || true

# NOTA: Arquivos ERB (super_admin, devise, installation) NÃO são modificados
# O branding é feito via INSTALLATION_NAME configurado no banco de dados
# Isso evita quebrar referências Ruby como Chatwoot.config, ChatwootHub, etc.

echo "Aplicando tradução do super_admin para PT-BR..."
# Navegação principal (_navigation.html.erb)
NAV_FILE="app/views/super_admin/application/_navigation.html.erb"
sed -i "s|label: 'Dashboard'|label: 'Painel'|g" "$NAV_FILE"
sed -i "s|label: 'Sidekiq Dashboard'|label: 'Painel Sidekiq'|g" "$NAV_FILE"
sed -i "s|label: 'Instance Health'|label: 'Saúde da Instância'|g" "$NAV_FILE"
sed -i "s|label: 'Agent Dashboard'|label: 'Painel do Agente'|g" "$NAV_FILE"
sed -i "s|label: 'Logout'|label: 'Sair'|g" "$NAV_FILE"
sed -i "s|Super Admin Console|Console Super Admin|g" "$NAV_FILE"

# Menu de configurações (_settings_menu.html.erb)
SETTINGS_MENU="app/views/super_admin/application/_settings_menu.html.erb"
sed -i "s|>Settings<|>Configurações<|g" "$SETTINGS_MENU"

# Página de configurações (settings/show.html.erb)
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
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

# Página de configuração de app (app_configs/show.html.erb)
APP_CONFIG="app/views/super_admin/app_configs/show.html.erb"
sed -i "s|Configure Settings|Configurar Definições|g" "$APP_CONFIG"
sed -i "s|>Submit<|>Enviar<|g" "$APP_CONFIG"

# Reset cache (accounts/_reset_cache.html.erb)
RESET_CACHE="app/views/super_admin/accounts/_reset_cache.html.erb"
sed -i "s|Reset Frontend Cache|Limpar Cache do Frontend|g" "$RESET_CACHE"
sed -i "s|This will clear the IndexedDB cache keys from redis|Isso irá limpar as chaves de cache do IndexedDB no Redis|g" "$RESET_CACHE"
sed -i "s|Next reload would fetch the data from backend|O próximo carregamento buscará os dados do backend|g" "$RESET_CACHE"

# Seed data (accounts/_seed_data.html.erb)
SEED_DATA="app/views/super_admin/accounts/_seed_data.html.erb"
sed -i "s|Generate Seed Data|Gerar Dados de Exemplo|g" "$SEED_DATA"
sed -i "s|Click the button to generate seed data into this account for demos|Clique no botão para gerar dados de exemplo nesta conta para demonstrações|g" "$SEED_DATA"
sed -i "s|Note: This will clear all the existing data in this account|Nota: Isso irá limpar todos os dados existentes nesta conta|g" "$SEED_DATA"

# Impersonate user (users/_impersonate.erb)
IMPERSONATE="app/views/super_admin/users/_impersonate.erb"
if [ -f "$IMPERSONATE" ]; then
  sed -i "s|Impersonate user|Simular usuário|g" "$IMPERSONATE"
  sed -i "s|Caution:|Cuidado:|g" "$IMPERSONATE"
  sed -i "s|Any actions executed after impersonate will appear as actions performed by the impersonated user|Quaisquer ações executadas após simular aparecerão como ações realizadas pelo usuário simulado|g" "$IMPERSONATE"
fi

# Tradução dos nomes de recursos do Administrate
# Criando arquivo de locale para super_admin
cat >> config/locales/pt_BR.yml << 'LOCALE_EOF'

  # Super Admin translations
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

echo "Corrigindo Dockerfile (git SHA workaround)..."
# Move git SHA capture before asset cleanup to avoid /bin/sh issues
sed -i 's|rm -rf spec node_modules tmp/cache;|git rev-parse HEAD > /app/.git_sha \&\& rm -rf spec node_modules tmp/cache;|' docker/Dockerfile
# Remove the separate git rev-parse step that fails
sed -i '/^RUN git rev-parse HEAD > \/app\/.git_sha$/d' docker/Dockerfile

echo "Copiando brand-assets (logos/favicons)..."
mkdir -p "${WORKDIR}/public/brand-assets"
cp -r "${BUILD_ROOT}/../brand-assets/." "${WORKDIR}/public/brand-assets/"

echo "Construindo imagem ${IMAGE_TAG} (sem cache)..."
docker build \
  --no-cache \
  -f docker/Dockerfile \
  -t "${IMAGE_TAG}" \
  .

cat <<'EOF'
============================================================
Imagem pronta com customizacoes V4 Connect:
- Rebranding completo: Chatwoot → V4 Connect
- Paleta de cores vermelha (#e50914)
- Tipografia Proxima Nova / Bebas Neue
- Super Admin Console em PT-BR
- Onboarding em PT-BR
- Login Super Admin em PT-BR
- Brand assets customizados
============================================================
EOF
