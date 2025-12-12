#!/usr/bin/env bash
# Converte views do Super Admin para usar i18n em vez de textos hardcoded
# As traduções são gerenciadas pelo arquivo config/locales/super_admin.pt-BR.yml

set -euo pipefail

echo "Convertendo views do Super Admin para i18n..."

# ============================================================
# settings/show.html.erb - Página principal de configurações
# ============================================================
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
if [ -f "$SETTINGS_SHOW" ]; then
  # Título (content_for)
  sed -i "s|Settings$|<%= t('super_admin.settings.title') %>|g" "$SETTINGS_SHOW"

  # Subtítulo
  sed -i "s|Update your instance settings, access billing portal|<%= t('super_admin.settings.update_settings') %>|g" "$SETTINGS_SHOW"

  # Installation Identifier
  sed -i "s|>Installation Identifier<|><%= t('super_admin.settings.installation_identifier') %><|g" "$SETTINGS_SHOW"

  # Current plan
  sed -i "s|>Current plan<|><%= t('super_admin.settings.current_plan') %><|g" "$SETTINGS_SHOW"

  # Refresh
  sed -i "s|>Refresh<|><%= t('super_admin.settings.update') %><|g" "$SETTINGS_SHOW"

  # Manage
  sed -i "s|>Manage<|><%= t('super_admin.settings.manage') %><|g" "$SETTINGS_SHOW"

  # Agent limit warning - usa interpolação
  sed -i "s|You have <%= User.count %> agents. Please add more licenses to add more users.|<%= t('super_admin.settings.agent_limit_warning', count: User.count) %>|g" "$SETTINGS_SHOW"

  # Need help?
  sed -i "s|>Need help\?<|><%= t('super_admin.settings.need_help') %><|g" "$SETTINGS_SHOW"

  # Having trouble
  sed -i "s|>Do you face any issues\? We are here to help.<|><%= t('super_admin.settings.having_trouble') %><|g" "$SETTINGS_SHOW"

  # Community Support
  sed -i "s|>Community Support<|><%= t('super_admin.settings.community_support') %><|g" "$SETTINGS_SHOW"

  # Chat Support
  sed -i "s|>Chat Support<|><%= t('super_admin.settings.chat_support') %><|g" "$SETTINGS_SHOW"

  # Features
  sed -i "s|>Features<|><%= t('super_admin.settings.features') %><|g" "$SETTINGS_SHOW"

  echo "  - settings/show.html.erb convertido para i18n"
fi

# ============================================================
# Botões de upgrade
# ============================================================
UPGRADE_COMMUNITY="app/views/super_admin/settings/_upgrade_button_community.html.erb"
if [ -f "$UPGRADE_COMMUNITY" ]; then
  sed -i "s|>Switch to Enterprise edition<|><%= t('super_admin.settings.switch_to_enterprise') %><|g" "$UPGRADE_COMMUNITY"
  echo "  - _upgrade_button_community.html.erb convertido"
fi

UPGRADE_ENTERPRISE="app/views/super_admin/settings/_upgrade_button_enterprise.html.erb"
if [ -f "$UPGRADE_ENTERPRISE" ]; then
  sed -i "s|>Upgrade now<|><%= t('super_admin.settings.upgrade_now') %><|g" "$UPGRADE_ENTERPRISE"
  echo "  - _upgrade_button_enterprise.html.erb convertido"
fi

# ============================================================
# Menu de configurações
# ============================================================
SETTINGS_MENU="app/views/super_admin/application/_settings_menu.html.erb"
if [ -f "$SETTINGS_MENU" ]; then
  sed -i "s|>Settings<|><%= t('super_admin.navigation.settings') %><|g" "$SETTINGS_MENU"
  echo "  - _settings_menu.html.erb convertido"
fi

# ============================================================
# app_configs/show.html.erb
# ============================================================
APP_CONFIG="app/views/super_admin/app_configs/show.html.erb"
if [ -f "$APP_CONFIG" ]; then
  sed -i "s|Configure Settings|<%= t('super_admin.app_configs.title') %>|g" "$APP_CONFIG"
  sed -i "s|>Submit<|><%= t('super_admin.common.submit') %><|g" "$APP_CONFIG"
  echo "  - app_configs/show.html.erb convertido"
fi

# ============================================================
# accounts/_reset_cache.html.erb
# ============================================================
RESET_CACHE="app/views/super_admin/accounts/_reset_cache.html.erb"
if [ -f "$RESET_CACHE" ]; then
  sed -i "s|Reset Frontend Cache|<%= t('super_admin.accounts.reset_frontend_cache') %>|g" "$RESET_CACHE"
  sed -i "s|This will clear the IndexedDB cache keys from redis|<%= t('super_admin.accounts.reset_cache_warning') %>|g" "$RESET_CACHE"
  sed -i "s|Next reload would fetch the data from backend|<%= t('super_admin.accounts.reset_cache_warning') %>|g" "$RESET_CACHE"
  echo "  - accounts/_reset_cache.html.erb convertido"
fi

# ============================================================
# accounts/_seed_data.html.erb
# ============================================================
SEED_DATA="app/views/super_admin/accounts/_seed_data.html.erb"
if [ -f "$SEED_DATA" ]; then
  sed -i "s|Generate Seed Data|<%= t('super_admin.accounts.generate_seed_data') %>|g" "$SEED_DATA"
  sed -i "s|Click the button to generate seed data into this account for demos|<%= t('super_admin.accounts.seed_data_description') %>|g" "$SEED_DATA"
  sed -i "s|Note: This will clear all the existing data in this account|<%= t('super_admin.accounts.seed_data_warning') %>|g" "$SEED_DATA"
  echo "  - accounts/_seed_data.html.erb convertido"
fi

# ============================================================
# users/_impersonate.erb
# ============================================================
IMPERSONATE="app/views/super_admin/users/_impersonate.erb"
if [ -f "$IMPERSONATE" ]; then
  sed -i "s|Impersonate user|<%= t('super_admin.users.impersonate_user') %>|g" "$IMPERSONATE"
  sed -i "s|Caution:|<%= t('super_admin.common.caution') %>:|g" "$IMPERSONATE"
  sed -i "s|Any actions executed after impersonate will appear as actions performed by the impersonated user|<%= t('super_admin.users.impersonate_warning') %>|g" "$IMPERSONATE"
  echo "  - users/_impersonate.erb convertido"
fi

# ============================================================
# instance_statuses/show.html.erb
# ============================================================
INSTANCE_STATUS="app/views/super_admin/instance_statuses/show.html.erb"
if [ -f "$INSTANCE_STATUS" ]; then
  sed -i "s|Instance Status|<%= t('super_admin.instance_status.title') %>|g" "$INSTANCE_STATUS"
  sed -i "s|>Metric<|><%= t('super_admin.instance_status.metric') %><|g" "$INSTANCE_STATUS"
  sed -i "s|>Value<|><%= t('super_admin.instance_status.value') %><|g" "$INSTANCE_STATUS"
  echo "  - instance_statuses/show.html.erb convertido"
fi

# ============================================================
# dashboard/index.html.erb
# ============================================================
DASHBOARD="app/views/super_admin/dashboard/index.html.erb"
if [ -f "$DASHBOARD" ]; then
  sed -i "s|Admin Dashboard|<%= t('super_admin.dashboard.title') %>|g" "$DASHBOARD"
  echo "  - dashboard/index.html.erb convertido"
fi

# ============================================================
# devise/sessions/new.html.erb (login)
# ============================================================
LOGIN="app/views/super_admin/devise/sessions/new.html.erb"
if [ -f "$LOGIN" ]; then
  # Converte textos já em PT-BR para usar i18n
  sed -i "s|Boas-vindas, admin|<%= t('super_admin.login.welcome') %>|g" "$LOGIN"
  sed -i 's|>E-mail$|><%= t('\''super_admin.login.email'\'') %>|g' "$LOGIN"
  sed -i 's|>Senha$|><%= t('\''super_admin.login.password'\'') %>|g' "$LOGIN"
  sed -i "s|>Entrar<|><%= t('super_admin.login.sign_in') %><|g" "$LOGIN"
  sed -i 's|placeholder: "Digite seu e-mail corporativo"|placeholder: t('\''super_admin.login.email_placeholder'\'')|g' "$LOGIN"
  sed -i 's|placeholder: "Digite sua senha"|placeholder: t('\''super_admin.login.password_placeholder'\'')|g' "$LOGIN"
  echo "  - devise/sessions/new.html.erb convertido"
fi

echo ""
echo "Conversão para i18n concluída!"
echo "Traduções são lidas de: config/locales/super_admin.pt-BR.yml"
