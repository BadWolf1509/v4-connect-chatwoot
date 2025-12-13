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

echo "Configurando branding V4 Connect nos defaults..."
CONFIG_FILE="config/installation_config.yml"
# INSTALLATION_NAME - título da aba do navegador
sed -i "s/value: 'Chatwoot'/value: 'V4 Connect'/" "$CONFIG_FILE"
# BRAND_NAME - nome exibido em emails e widget
sed -i "/^- name: BRAND_NAME/,/^- name:/{s/value: 'Chatwoot'/value: 'V4 Connect'/}" "$CONFIG_FILE"
# BRAND_URL - URL do branding
sed -i "s|value: 'https://www.chatwoot.com'|value: 'https://v4company.com'|g" "$CONFIG_FILE"
# WIDGET_BRAND_URL - URL do widget
sed -i "s|value: 'https://www.chatwoot.com/terms-of-service'|value: 'https://v4company.com/terms'|g" "$CONFIG_FILE"
sed -i "s|value: 'https://www.chatwoot.com/privacy-policy'|value: 'https://v4company.com/privacy'|g" "$CONFIG_FILE"
echo "  - INSTALLATION_NAME: V4 Connect"
echo "  - BRAND_NAME: V4 Connect"
echo "  - URLs de branding atualizadas"

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
# Usando padrão regex mais flexível para garantir match
sed -i "s/25: blue\.blue2,/25: '#fef2f2',/" "$COLORS_FILE"
sed -i "s/50: blue\.blue3,/50: '#fee2e2',/" "$COLORS_FILE"
sed -i "s/75: blue\.blue4,/75: '#fecaca',/" "$COLORS_FILE"
sed -i "s/100: blue\.blue5,/100: '#fca5a5',/" "$COLORS_FILE"
sed -i "s/200: blue\.blue7,/200: '#f87171',/" "$COLORS_FILE"
sed -i "s/300: blue\.blue8,/300: '#ef4444',/" "$COLORS_FILE"
sed -i "s/400: blueDark\.blue11,/400: '#dc2626',/" "$COLORS_FILE"
sed -i "s/500: blueDark\.blue10,/500: '#e50914',/" "$COLORS_FILE"
sed -i "s/600: blueDark\.blue9,/600: '#b20710',/" "$COLORS_FILE"
sed -i "s/700: blueDark\.blue8,/700: '#80050b',/" "$COLORS_FILE"
sed -i "s/800: blueDark\.blue6,/800: '#5c0308',/" "$COLORS_FILE"
sed -i "s/900: blueDark\.blue2,/900: '#400306',/" "$COLORS_FILE"

# Alterar a cor brand para vermelho V4
sed -i "s/brand: '#.*'/brand: '#e50914'/" "$COLORS_FILE"

# Verificar se as alterações foram aplicadas
if grep -q "#e50914" "$COLORS_FILE"; then
  echo "  - Cores V4 aplicadas com sucesso"
else
  echo "  - AVISO: Cores podem não ter sido aplicadas corretamente"
fi

# Alterar cor de seleção do sidebar (--text-blue) para vermelho V4
echo "Alterando cor de seleção do sidebar para vermelho V4..."
NEXT_COLORS_FILE="app/javascript/dashboard/assets/scss/_next-colors.scss"
if [ -f "$NEXT_COLORS_FILE" ]; then
  # Modo claro: #e50914 = RGB(229, 9, 20)
  sed -i 's/--text-blue: 8 109 224;/--text-blue: 229 9 20;/' "$NEXT_COLORS_FILE"
  # Modo escuro: versão mais clara #ff6b6b = RGB(255, 107, 107)
  sed -i 's/--text-blue: 126 182 255;/--text-blue: 255 107 107;/' "$NEXT_COLORS_FILE"
  echo "  - Cor de seleção do sidebar alterada para vermelho"
fi

# Alterar cores do Super Admin (Administrate) para vermelho V4
echo "Alterando cores do Super Admin para vermelho V4..."

# 1. Variáveis principais do Administrate (utilities/_variables.scss)
ADMIN_VARS="app/assets/stylesheets/administrate/utilities/_variables.scss"
if [ -f "$ADMIN_VARS" ]; then
  # Cor principal (botões): azul → vermelho V4
  sed -i 's/\$color-woot: #1f93ff;/$color-woot: #e50914;/' "$ADMIN_VARS"
  # Cor primária clara (hover, backgrounds): azul claro → vermelho claro
  sed -i 's/\$color-primary-light: #c7e3ff;/$color-primary-light: #fecaca;/' "$ADMIN_VARS"
  echo "  - Cor dos botões alterada para vermelho V4"
fi

# 2. Variáveis de biblioteca (library/_variables.scss)
ADMIN_LIB_VARS="app/assets/stylesheets/administrate/library/_variables.scss"
if [ -f "$ADMIN_LIB_VARS" ]; then
  # Cor azul (links, action-color): azul → vermelho V4
  sed -i 's/\$blue: #1f93ff;/$blue: #e50914;/' "$ADMIN_LIB_VARS"
  echo "  - Cor dos links alterada para vermelho V4"
fi

# 3. Variáveis CSS do Super Admin index.scss
SUPERADMIN_INDEX="app/javascript/dashboard/assets/scss/super_admin/index.scss"
if [ -f "$SUPERADMIN_INDEX" ]; then
  # Modo claro: --text-blue
  sed -i 's/--text-blue: 8 109 224;/--text-blue: 229 9 20;/' "$SUPERADMIN_INDEX"
  # Modo escuro: --text-blue
  sed -i 's/--text-blue: 126 182 255;/--text-blue: 255 107 107;/' "$SUPERADMIN_INDEX"
  echo "  - Variáveis CSS do Super Admin alteradas"
fi

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
# IMPORTANTE: Alterar o nome no header de "Chatwoot" para "V4 Connect"
sed -i "s|alt: 'Chatwoot Admin Dashboard'|alt: 'V4 Connect Admin'|g" "$NAV_FILE"
sed -i "s|>Chatwoot <%= Chatwoot.config\[:version\] %><|>V4 Connect <%= Chatwoot.config[:version] %><|g" "$NAV_FILE"
# Tradução dos labels
sed -i "s|label: 'Dashboard'|label: 'Painel'|g" "$NAV_FILE"
sed -i "s|label: 'Sidekiq Dashboard'|label: 'Painel Sidekiq'|g" "$NAV_FILE"
sed -i "s|label: 'Instance Health'|label: 'Saúde da Instância'|g" "$NAV_FILE"
sed -i "s|label: 'Agent Dashboard'|label: 'Painel do Agente'|g" "$NAV_FILE"
sed -i "s|label: 'Logout'|label: 'Sair'|g" "$NAV_FILE"
sed -i "s|Super Admin Console|Console Super Admin|g" "$NAV_FILE"

# ============================================================
# TRADUÇÃO VIA i18n - Views do Super Admin
# ============================================================
# As views são convertidas para usar t() e as traduções vêm do arquivo de locale
# Isso é mais limpo e manutenível do que usar sed diretamente nos textos

# Remover alerta de "Unauthorized premium changes" - não aplicável para V4 Connect
# O bloco if/end e div precisa ser removido completamente para evitar tags órfãs
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
# Remove o bloco completo: desde <% if Redis::Alfred... até <% end %> (incluindo </div>)
sed -i '/CHATWOOT_INSTALLATION_CONFIG_RESET_WARNING/,/<% end %>/d' "$SETTINGS_SHOW"
echo "  - Alerta de premium changes removido"

# Converter views para usar i18n (t())
echo "Convertendo views do Super Admin para i18n..."
bash "${BUILD_ROOT}/scripts/convert_views_to_i18n.sh"

# ============================================================
# TRADUÇÃO VIA SED - Arquivos que não usam i18n
# ============================================================
# Estes arquivos têm textos hardcoded que não passam pelo sistema i18n do Rails

# Traduzir FeaturesHelper (plan_details) - Ruby code, não usa i18n
FEATURES_HELPER="app/helpers/super_admin/features_helper.rb"
if [ -f "$FEATURES_HELPER" ]; then
  sed -i "s|You are currently on the|Você está no plano|g" "$FEATURES_HELPER"
  sed -i "s|plan with|com|g" "$FEATURES_HELPER"
  sed -i "s|agents|agentes|g" "$FEATURES_HELPER"
  sed -i "s|edition plan.|edição.|g" "$FEATURES_HELPER"
  echo "  - FeaturesHelper traduzido"
fi

# Traduzir features.yml (nomes e descrições das funcionalidades)
FEATURES_YML="app/helpers/super_admin/features.yml"
if [ -f "$FEATURES_YML" ]; then
  # Premium Features
  sed -i "s|Enable AI-powered conversations with your customers.|Habilite conversas com IA para seus clientes.|g" "$FEATURES_YML"
  sed -i "s|Configuration for controlling SAML Single Sign-On availability|Configuração para controlar a disponibilidade do SAML SSO|g" "$FEATURES_YML"
  sed -i "s|Apply your own branding to this installation.|Aplique sua própria marca nesta instalação.|g" "$FEATURES_YML"
  sed -i "s|Set limits to auto-assigning conversations to your agents.|Defina limites para atribuição automática de conversas aos agentes.|g" "$FEATURES_YML"
  sed -i "s|Track and trace account activities with ease with detailed audit logs.|Rastreie atividades da conta com logs de auditoria detalhados.|g" "$FEATURES_YML"
  sed -i "s|Disable branding on live-chat widget and external emails.|Desabilite a marca no widget de chat e e-mails externos.|g" "$FEATURES_YML"

  # Product Features
  sed -i "s|Allow agents to create help center articles and publish them in a portal.|Permita que agentes criem artigos e publiquem em um portal.|g" "$FEATURES_YML"

  # Communication Channels
  sed -i "s|Improve your customer experience using a live chat on your website.|Melhore a experiência do cliente com chat ao vivo no seu site.|g" "$FEATURES_YML"
  sed -i "s|Manage your email customer interactions from Chatwoot.|Gerencie interações de e-mail com clientes.|g" "$FEATURES_YML"
  sed -i "s|Manage your SMS customer interactions from Chatwoot.|Gerencie interações de SMS com clientes.|g" "$FEATURES_YML"
  sed -i "s|Stay connected with your customers on Facebook & Instagram.|Conecte-se com clientes no Facebook e Instagram.|g" "$FEATURES_YML"
  sed -i "s|Stay connected with your customers on Instagram|Conecte-se com seus clientes no Instagram|g" "$FEATURES_YML"
  sed -i "s|Manage your WhatsApp business interactions from Chatwoot.|Gerencie interações do WhatsApp Business.|g" "$FEATURES_YML"
  sed -i "s|Manage your Telegram customer interactions from Chatwoot.|Gerencie interações do Telegram com clientes.|g" "$FEATURES_YML"
  sed -i "s|Manage your Line customer interactions from Chatwoot.|Gerencie interações do Line com clientes.|g" "$FEATURES_YML"

  # OAuth & Authentication
  sed -i "s|Configuration for setting up Google OAuth Integration|Configuração para integração OAuth do Google|g" "$FEATURES_YML"
  sed -i "s|Configuration for setting up Microsoft Email|Configuração para e-mail da Microsoft|g" "$FEATURES_YML"

  # Third-party Integrations
  sed -i "s|Configuration for setting up Linear Integration|Configuração para integração com Linear|g" "$FEATURES_YML"
  sed -i "s|Configuration for setting up Notion Integration|Configuração para integração com Notion|g" "$FEATURES_YML"
  sed -i "s|Configuration for setting up Slack Integration|Configuração para integração com Slack|g" "$FEATURES_YML"
  sed -i "s|Configuration for setting up WhatsApp Embedded Integration|Configuração para WhatsApp Embedded|g" "$FEATURES_YML"
  sed -i "s|Configuration for setting up Shopify Integration|Configuração para integração com Shopify|g" "$FEATURES_YML"

  # Nomes das features (traduzir apenas alguns que fazem sentido)
  sed -i "s|name: 'Custom Branding'|name: 'Marca Personalizada'|g" "$FEATURES_YML"
  sed -i "s|name: 'Agent Capacity'|name: 'Capacidade do Agente'|g" "$FEATURES_YML"
  sed -i "s|name: 'Audit Logs'|name: 'Logs de Auditoria'|g" "$FEATURES_YML"
  sed -i "s|name: 'Disable Branding'|name: 'Desabilitar Marca'|g" "$FEATURES_YML"
  sed -i "s|name: 'Help Center'|name: 'Central de Ajuda'|g" "$FEATURES_YML"
  sed -i "s|name: 'Live Chat'|name: 'Chat ao Vivo'|g" "$FEATURES_YML"

  echo "  - Features traduzidas para PT-BR"
fi

# NOTA: As views abaixo são tratadas pelo script convert_views_to_i18n.sh:
# - app_configs/show.html.erb
# - accounts/_reset_cache.html.erb
# - accounts/_seed_data.html.erb
# - users/_impersonate.erb
# Elas usam t() para tradução, lendo de config/locales/super_admin.pt-BR.yml

# Copiando arquivo de locale completo para super_admin
echo "Copiando arquivo de locale PT-BR completo para super_admin..."
cp "${BUILD_ROOT}/locales/super_admin.pt-BR.yml" config/locales/super_admin.pt-BR.yml

# NOTA: dashboard/index.html.erb e instance_statuses/show.html.erb
# são tratados pelo script convert_views_to_i18n.sh

# Instance Status - traduzir nomes de métricas no CONTROLLER
INSTANCE_STATUS_CONTROLLER="app/controllers/super_admin/instance_statuses_controller.rb"
if [ -f "$INSTANCE_STATUS_CONTROLLER" ]; then
  sed -i "s|'Chatwoot version'|'Versão do V4 Connect'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Postgres alive'|'PostgreSQL ativo'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis alive'|'Redis ativo'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis version'|'Versão do Redis'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis number of connected clients'|'Clientes Redis conectados'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|\"Redis 'maxclients' setting\"|'Configuração maxclients Redis'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis memory used'|'Memória Redis usada'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis memory peak'|'Pico de memória Redis'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|'Redis total memory available'|'Memória total Redis disponível'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|\"Redis 'maxmemory' setting\"|'Configuração maxmemory Redis'|g" "$INSTANCE_STATUS_CONTROLLER"
  sed -i "s|\"Redis 'maxmemory_policy' setting\"|'Política maxmemory Redis'|g" "$INSTANCE_STATUS_CONTROLLER"
  echo "  - Métricas de Instance Status traduzidas"
fi

# ============================================================
# Settings - Página de configurações (tradução direta via sed)
# ============================================================
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
if [ -f "$SETTINGS_SHOW" ]; then
  # Título da página (substitui "Settings" pelo texto em português)
  sed -i 's|^  Settings$|  Configurações|g' "$SETTINGS_SHOW"

  # Subtítulo
  sed -i 's|Update your instance settings, access billing portal|Atualize as configurações da sua instância|g' "$SETTINGS_SHOW"

  # Alert
  sed -i 's|<strong class="font-bold">Alert!</strong>|<strong class="font-bold">Alerta!</strong>|g' "$SETTINGS_SHOW"
  sed -i 's|Unauthorized premium changes detected in Chatwoot|Alterações premium não autorizadas detectadas|g' "$SETTINGS_SHOW"
  sed -i 's|To keep using them, please upgrade your plan|Para continuar usando, atualize seu plano|g' "$SETTINGS_SHOW"
  sed -i 's|Contact for help :|Contato para ajuda:|g' "$SETTINGS_SHOW"

  # Installation Identifier
  sed -i 's|>Installation Identifier<|>Identificador da Instalação<|g' "$SETTINGS_SHOW"

  # Current plan
  sed -i 's|>Current plan<|>Plano Atual<|g' "$SETTINGS_SHOW"

  # Refresh
  sed -i 's|>Refresh<|>Atualizar<|g' "$SETTINGS_SHOW"

  # Manage
  sed -i 's|>Manage<|>Gerenciar<|g' "$SETTINGS_SHOW"

  # Agent limit warning
  sed -i 's|You have <%= User.count %> agents. Please add more licenses to add more users.|Você tem <%= User.count %> agentes. Adicione mais licenças para habilitar mais usuários.|g' "$SETTINGS_SHOW"

  # Need help section
  sed -i 's|>Need help?<|>Precisa de ajuda?<|g' "$SETTINGS_SHOW"
  sed -i 's|>Do you face any issues? We are here to help.<|>Está enfrentando problemas? Estamos aqui para ajudar.<|g' "$SETTINGS_SHOW"

  # Buttons
  sed -i 's|>Community Support<|>Suporte da Comunidade<|g' "$SETTINGS_SHOW"
  sed -i 's|>Chat Support<|>Suporte por Chat<|g' "$SETTINGS_SHOW"

  # Features section
  sed -i 's|>Features<|>Funcionalidades<|g' "$SETTINGS_SHOW"

  echo "  - settings/show.html.erb traduzido"
fi

# Botões de upgrade
UPGRADE_COMMUNITY="app/views/super_admin/settings/_upgrade_button_community.html.erb"
if [ -f "$UPGRADE_COMMUNITY" ]; then
  sed -i 's|>Switch to Enterprise edition<|>Mudar para Enterprise<|g' "$UPGRADE_COMMUNITY"
  echo "  - _upgrade_button_community.html.erb traduzido"
fi

UPGRADE_ENTERPRISE="app/views/super_admin/settings/_upgrade_button_enterprise.html.erb"
if [ -f "$UPGRADE_ENTERPRISE" ]; then
  sed -i 's|>Upgrade now<|>Atualizar agora<|g' "$UPGRADE_ENTERPRISE"
  echo "  - _upgrade_button_enterprise.html.erb traduzido"
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

# Copiar favicons para /public/ raiz (usado pelo Super Admin que não tem links de favicon)
echo "Copiando favicons para /public/ raiz (Super Admin)..."
cp "${BUILD_ROOT}/branding/favicon.ico" "${WORKDIR}/public/favicon.ico"
cp "${BUILD_ROOT}/branding/favicon-16x16.png" "${WORKDIR}/public/favicon-16x16.png"
cp "${BUILD_ROOT}/branding/favicon-32x32.png" "${WORKDIR}/public/favicon-32x32.png"
cp "${BUILD_ROOT}/branding/favicon-96x96.png" "${WORKDIR}/public/favicon-96x96.png"

# Adicionar links de favicon ao layout do Super Admin
echo "Adicionando favicon ao layout do Super Admin..."
SUPERADMIN_LAYOUT="app/views/layouts/super_admin/application.html.erb"
if [ -f "$SUPERADMIN_LAYOUT" ]; then
  # Adicionar links de favicon após <meta name="viewport">
  sed -i '/<meta name="viewport"/a\  <link rel="icon" type="image/x-icon" href="/favicon.ico">\
  <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32x32.png">\
  <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16x16.png">' "$SUPERADMIN_LAYOUT"
  echo "  - Favicon adicionado ao Super Admin layout"

  # Forçar "V4 Connect" no título do Super Admin (ignora INSTALLATION_NAME do banco)
  # Substitui a linha que define installation_name para sempre usar 'V4 Connect'
  sed -i "s/<% installation_name = @global_config.*%>/<% installation_name = 'V4 Connect' %>/" "$SUPERADMIN_LAYOUT"
  echo "  - Título forçado para 'V4 Connect'"
fi

# Sobrescrever método application_title do Administrate para usar "V4 Connect"
# Este é o método que define o título na aba do navegador do Super Admin
echo "Sobrescrevendo application_title no Super Admin controller..."
SUPERADMIN_CONTROLLER="app/controllers/super_admin/application_controller.rb"
if [ -f "$SUPERADMIN_CONTROLLER" ]; then
  # Adicionar método application_title antes do primeiro "private"
  # O método helper_method :application_title torna disponível nas views
  if ! grep -q "def application_title" "$SUPERADMIN_CONTROLLER"; then
    # Inserir antes da linha "private" usando sed com múltiplas linhas
    sed -i '/^  private$/i\
  # Sobrescreve o título do Administrate para exibir "V4 Connect"\
  def application_title\
    '"'"'V4 Connect'"'"'\
  end\
  helper_method :application_title\
' "$SUPERADMIN_CONTROLLER"
    echo "  - Método application_title adicionado"
  fi
fi

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
  # Corrigir apple-touch-icon: substituir href completo sem adicionar comentários
  sed -i 's|href="/apple-icon-[^"]*"|href="/brand-assets/apple-touch-icon.png"|g' "$VUEAPP_LAYOUT"
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

echo "Habilitando features premium/enterprise..."
FEATURES_FILE="config/features.yml"
if [ -f "$FEATURES_FILE" ]; then
  # SLA - habilitar por padrão
  sed -i '/^- name: sla$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Custom Roles - habilitar por padrão
  sed -i '/^- name: custom_roles$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Audit Logs - habilitar por padrão
  sed -i '/^- name: audit_logs$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Assignment V2 (Agent Assignment) - habilitar e remover flag internal
  sed -i '/^- name: assignment_v2$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"
  sed -i '/^- name: assignment_v2$/,/^- name:/ { /chatwoot_internal: true/d; }' "$FEATURES_FILE"

  # Disable Branding - habilitar por padrão
  sed -i '/^- name: disable_branding$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Captain Integration - habilitar por padrão
  sed -i '/^- name: captain_integration$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # SAML SSO - habilitar por padrão
  sed -i '/^- name: saml$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Companies - habilitar e remover flag internal
  sed -i '/^- name: companies$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"
  sed -i '/^- name: companies$/,/^- name:/ { /chatwoot_internal: true/d; }' "$FEATURES_FILE"

  # CRM Integration - habilitar por padrão
  sed -i '/^- name: crm_integration$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Linear Integration - habilitar por padrão
  sed -i '/^- name: linear_integration$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # Notion Integration - habilitar por padrão
  sed -i '/^- name: notion_integration$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  # WhatsApp Campaign - habilitar por padrão
  sed -i '/^- name: whatsapp_campaign$/,/^- name:/ { s/enabled: false/enabled: true/; }' "$FEATURES_FILE"

  echo "  - SLA habilitado"
  echo "  - Custom Roles habilitado"
  echo "  - Audit Logs habilitado"
  echo "  - Assignment V2 habilitado"
  echo "  - Disable Branding habilitado"
  echo "  - Captain Integration habilitado"
  echo "  - SAML SSO habilitado"
  echo "  - Companies habilitado"
  echo "  - CRM Integration habilitado"
  echo "  - Linear/Notion Integration habilitado"
  echo "  - WhatsApp Campaign habilitado"
fi

echo "Copiando rake task V4 Connect..."
cp "${BUILD_ROOT}/lib/tasks/v4_connect.rake" "lib/tasks/"
echo "  - lib/tasks/v4_connect.rake copiado"
echo "  - Uso após db:setup: bundle exec rake v4_connect:setup"

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
