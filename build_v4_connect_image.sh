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
git apply "${BUILD_ROOT}/patches/v4-connect.patch"

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

# Copiando arquivo de locale completo para super_admin
echo "Copiando arquivo de locale PT-BR completo para super_admin..."
cp "${BUILD_ROOT}/locales/super_admin.pt-BR.yml" config/locales/super_admin.pt-BR.yml

# Dashboard principal (index.html.erb)
DASHBOARD_FILE="app/views/super_admin/dashboard/index.html.erb"
if [ -f "$DASHBOARD_FILE" ]; then
  sed -i "s|Admin Dashboard|Painel Administrativo|g" "$DASHBOARD_FILE"
  sed -i "s|>Accounts<|>Contas<|g" "$DASHBOARD_FILE"
  sed -i "s|>Users<|>Usuários<|g" "$DASHBOARD_FILE"
  sed -i "s|>Inboxes<|>Caixas de Entrada<|g" "$DASHBOARD_FILE"
  sed -i "s|>Conversations<|>Conversas<|g" "$DASHBOARD_FILE"
  sed -i "s|>Total<|>Total<|g" "$DASHBOARD_FILE"
  sed -i "s|>Active<|>Ativos<|g" "$DASHBOARD_FILE"
fi

# Instance Status page
INSTANCE_STATUS="app/views/super_admin/instance_status/show.html.erb"
if [ -f "$INSTANCE_STATUS" ]; then
  sed -i "s|Instance Status|Status da Instância|g" "$INSTANCE_STATUS"
  sed -i "s|>Metric<|>Métrica<|g" "$INSTANCE_STATUS"
  sed -i "s|>Value<|>Valor<|g" "$INSTANCE_STATUS"
  sed -i "s|Chatwoot Version|Versão do V4 Connect|g" "$INSTANCE_STATUS"
  sed -i "s|Postgres Version|Versão do PostgreSQL|g" "$INSTANCE_STATUS"
  sed -i "s|Redis Version|Versão do Redis|g" "$INSTANCE_STATUS"
  sed -i "s|Sidekiq Status|Status do Sidekiq|g" "$INSTANCE_STATUS"
  sed -i "s|>Running<|>Rodando<|g" "$INSTANCE_STATUS"
  sed -i "s|>Stopped<|>Parado<|g" "$INSTANCE_STATUS"
fi

# Formulário de contas
ACCOUNT_FORM="app/views/super_admin/accounts/_form.html.erb"
if [ -f "$ACCOUNT_FORM" ]; then
  sed -i "s|>Name<|>Nome<|g" "$ACCOUNT_FORM"
  sed -i "s|>Status<|>Status<|g" "$ACCOUNT_FORM"
  sed -i "s|>Locale<|>Idioma<|g" "$ACCOUNT_FORM"
  sed -i "s|>Domain<|>Domínio<|g" "$ACCOUNT_FORM"
  sed -i "s|>Support Email<|>E-mail de Suporte<|g" "$ACCOUNT_FORM"
  sed -i "s|>Feature Flags<|>Funcionalidades<|g" "$ACCOUNT_FORM"
  sed -i "s|>Limits<|>Limites<|g" "$ACCOUNT_FORM"
  sed -i "s|>Auto Resolve Duration<|>Duração Auto-resolver<|g" "$ACCOUNT_FORM"
fi

echo "Adicionando validação de erros no controller de contas..."
ACCOUNTS_CONTROLLER="app/controllers/super_admin/accounts_controller.rb"
if [ -f "$ACCOUNTS_CONTROLLER" ]; then
  # Adiciona rescue para ActiveRecord::NotNullViolation após o método create
  # Procura por "def create" e adiciona tratamento de erro no final do método
  sed -i '/def create/,/^  end$/ {
    /^  end$/i\
  rescue ActiveRecord::NotNullViolation => e\
    flash.now[:error] = if e.message.include?("name")\
                          "Nome da conta é obrigatório"\
                        else\
                          "Por favor, preencha todos os campos obrigatórios"\
                        end\
    render :new, locals: { page: Administrate::Page::Form.new(dashboard, requested_resource) }
  }' "$ACCOUNTS_CONTROLLER"
fi

echo "Adicionando validação HTML5 no formulário de contas..."
# Adiciona script JavaScript para validação client-side
ACCOUNT_NEW_VIEW="app/views/super_admin/accounts/new.html.erb"
if [ -f "$ACCOUNT_NEW_VIEW" ]; then
  # Adiciona validação JavaScript no final do arquivo se ainda não existir
  if ! grep -q "account-form-validation" "$ACCOUNT_NEW_VIEW"; then
    cat >> "$ACCOUNT_NEW_VIEW" << 'EOJS'
<script>
// account-form-validation
document.addEventListener('DOMContentLoaded', function() {
  const accountForm = document.querySelector('form');
  if (accountForm) {
    // Adiciona required ao campo name (account_name)
    const nameInput = accountForm.querySelector('input[name="account[name]"]');
    if (nameInput) {
      nameInput.setAttribute('required', 'required');
      nameInput.setAttribute('placeholder', 'Nome da conta é obrigatório');
    }
  }
});
</script>
EOJS
  fi
fi

# Formulário de usuários
USER_FORM="app/views/super_admin/users/_form.html.erb"
if [ -f "$USER_FORM" ]; then
  sed -i "s|>Name<|>Nome<|g" "$USER_FORM"
  sed -i "s|>Display Name<|>Nome de Exibição<|g" "$USER_FORM"
  sed -i "s|>Email<|>E-mail<|g" "$USER_FORM"
  sed -i "s|>Password<|>Senha<|g" "$USER_FORM"
  sed -i "s|>Password Confirmation<|>Confirmação de Senha<|g" "$USER_FORM"
  sed -i "s|>Type<|>Tipo<|g" "$USER_FORM"
  sed -i "s|>Custom Attributes<|>Atributos Personalizados<|g" "$USER_FORM"
fi

# Botões e ações comuns (layout application.html.erb)
APP_LAYOUT="app/views/layouts/super_admin/application.html.erb"
if [ -f "$APP_LAYOUT" ]; then
  sed -i "s|>Edit<|>Editar<|g" "$APP_LAYOUT"
  sed -i "s|>Delete<|>Excluir<|g" "$APP_LAYOUT"
  sed -i "s|>Save<|>Salvar<|g" "$APP_LAYOUT"
  sed -i "s|>Cancel<|>Cancelar<|g" "$APP_LAYOUT"
  sed -i "s|>Back<|>Voltar<|g" "$APP_LAYOUT"
fi

# Tradução do Vue Dashboard Component
DASHBOARD_VUE="app/javascript/dashboard/components/widgets/chart/index.vue"
if [ -f "$DASHBOARD_VUE" ]; then
  sed -i "s/'Accounts'/'Contas'/g" "$DASHBOARD_VUE"
  sed -i "s/'Users'/'Usuários'/g" "$DASHBOARD_VUE"
  sed -i "s/'Inboxes'/'Caixas de Entrada'/g" "$DASHBOARD_VUE"
  sed -i "s/'Conversations'/'Conversas'/g" "$DASHBOARD_VUE"
fi

# Tradução do Playground Robin AI
PLAYGROUND_VUE="app/javascript/super_admin/playground/index.vue"
if [ -f "$PLAYGROUND_VUE" ]; then
  sed -i "s|Robin AI playground|Playground Robin AI|g" "$PLAYGROUND_VUE"
  sed -i "s|Chat with the source|Converse com a fonte|g" "$PLAYGROUND_VUE"
  sed -i "s|evaluate its efficiency|avalie sua eficiência|g" "$PLAYGROUND_VUE"
  sed -i "s|Type a message|Digite uma mensagem|g" "$PLAYGROUND_VUE"
  sed -i "s|Error: Could not get response|Erro: Não foi possível obter resposta|g" "$PLAYGROUND_VUE"
  sed -i "s|Please check the console for more details|Por favor, verifique o console para mais detalhes|g" "$PLAYGROUND_VUE"
fi

# Tradução dos filtros do Administrate
find app/views/super_admin -name "*.erb" -exec sed -i 's|All records|Todos os registros|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|Clear filter|Limpar filtro|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|Search|Pesquisar|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|Showing|Exibindo|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's| of | de |g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|results|resultados|g' {} \; 2>/dev/null || true

# Tradução das ações do Administrate
find app/views/super_admin -name "*.erb" -exec sed -i 's|>New |>Novo |g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>Show<|>Ver<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>Edit<|>Editar<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>Destroy<|>Excluir<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>Delete<|>Excluir<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|Are you sure?|Tem certeza?|g' {} \; 2>/dev/null || true

# Tradução de campos comuns
find app/views/super_admin -name "*.erb" -exec sed -i 's|Created At|Criado em|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|Updated At|Atualizado em|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>Actions<|>Ações<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>True<|>Sim<|g' {} \; 2>/dev/null || true
find app/views/super_admin -name "*.erb" -exec sed -i 's|>False<|>Não<|g' {} \; 2>/dev/null || true

echo "Corrigindo Dockerfile (git SHA workaround)..."
# Move git SHA capture before asset cleanup to avoid /bin/sh issues
sed -i 's|rm -rf spec node_modules tmp/cache;|git rev-parse HEAD > /app/.git_sha \&\& rm -rf spec node_modules tmp/cache;|' docker/Dockerfile
# Remove the separate git rev-parse step that fails
sed -i '/^RUN git rev-parse HEAD > \/app\/.git_sha$/d' docker/Dockerfile

echo "Copiando brand-assets (logos/favicons)..."
mkdir -p "${WORKDIR}/public/brand-assets"
cp -r "${BUILD_ROOT}/branding/." "${WORKDIR}/public/brand-assets/"

echo "Aplicando traduções PT-BR do frontend (Assignment Policy, Sidebar)..."
node "${BUILD_ROOT}/scripts/apply_frontend_translations.js" \
  "app/javascript/dashboard/i18n/locale/pt_BR/settings.json" \
  "${BUILD_ROOT}/locales/assignment_policy.pt-BR.json"

echo "Traduzindo Super Admin Dashboard Vue..."
SUPERADMIN_DASHBOARD="app/javascript/superadmin_pages/views/dashboard/Index.vue"
if [ -f "$SUPERADMIN_DASHBOARD" ]; then
  sed -i "s|'Admin Dashboard'|'Painel Administrativo'|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|{{ 'Admin Dashboard' }}|{{ 'Painel Administrativo' }}|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|{{ 'Accounts' }}|{{ 'Contas' }}|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|{{ 'Users' }}|{{ 'Usuarios' }}|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|{{ 'Inboxes' }}|{{ 'Caixas de entrada' }}|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|{{ 'Conversations' }}|{{ 'Conversas' }}|g" "$SUPERADMIN_DASHBOARD"
  sed -i "s|label: 'Conversations'|label: 'Conversas'|g" "$SUPERADMIN_DASHBOARD"
fi

echo "Configurando fallback para INSTALLATION_NAME em todos os layouts..."

# Função para adicionar fallback em um arquivo
add_installation_name_fallback() {
  local file="$1"
  if [ -f "$file" ]; then
    # Adiciona linha Ruby logo após <html> para garantir fallback
    sed -i '/<html>/a\<% @global_config['\''INSTALLATION_NAME'\''] = @global_config['\''INSTALLATION_NAME'\''].presence || ENV['\''INSTALLATION_NAME'\''].presence || '\''V4 Connect'\'' unless @global_config['\''INSTALLATION_NAME'\''].present? %>' "$file"
    echo "  - Fallback aplicado: $file"
  fi
}

# 1. vueapp.html.erb - Layout principal do dashboard
VUEAPP_LAYOUT="app/views/layouts/vueapp.html.erb"
add_installation_name_fallback "$VUEAPP_LAYOUT"

# Atualizar favicons para usar brand-assets no vueapp
if [ -f "$VUEAPP_LAYOUT" ]; then
  sed -i 's|href="/favicon-|href="/brand-assets/favicon-|g' "$VUEAPP_LAYOUT"
  sed -i 's|href="/apple-icon-|href="/brand-assets/apple-touch-icon.png" /><!-- |g' "$VUEAPP_LAYOUT"
  sed -i 's|href="/android-icon-|href="/brand-assets/android-chrome-|g' "$VUEAPP_LAYOUT"
fi

# 2. survey/responses/show.html.erb - Página de survey
add_installation_name_fallback "app/views/survey/responses/show.html.erb"

# 3. widgets/show.html.erb - Widget embarcado
add_installation_name_fallback "app/views/widgets/show.html.erb"

# 4. Portal footer - já usa @global_config diretamente, então tratamos diferente
PORTAL_FOOTER="app/views/public/api/v1/portals/_footer.html.erb"
if [ -f "$PORTAL_FOOTER" ]; then
  # Substituir @global_config['INSTALLATION_NAME'] por fallback inline
  # Usando # como delimitador para evitar conflito com || do Ruby
  sed -i "s#@global_config\['INSTALLATION_NAME'\]#(@global_config['INSTALLATION_NAME'].presence || 'V4 Connect')#g" "$PORTAL_FOOTER"
  echo "  - Fallback aplicado: $PORTAL_FOOTER"
fi

echo "Configurando locale padrão PT-BR..."
APP_CONFIG="config/application.rb"
if [ -f "$APP_CONFIG" ]; then
  # Adicionar configuração de locale se não existir
  if ! grep -q "config.i18n.default_locale" "$APP_CONFIG"; then
    sed -i "/config.generators.stylesheets = false/a\\\\n    # Locale padrão\\n    config.i18n.default_locale = (ENV['DEFAULT_LOCALE'] || 'pt_BR').to_sym" "$APP_CONFIG"
  fi
fi

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
- Atribuição de Agentes em PT-BR
- Sidebar Settings em PT-BR
- Brand assets customizados
============================================================
EOF
