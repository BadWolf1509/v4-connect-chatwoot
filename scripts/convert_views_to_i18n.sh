#!/usr/bin/env bash
# Converte views do Super Admin para usar i18n em vez de textos hardcoded
# As traduções são gerenciadas pelo arquivo config/locales/super_admin.pt-BR.yml
#
# Este script é executado durante o build da imagem Docker
# para converter textos hardcoded em chamadas t() do Rails i18n

set -euo pipefail

echo "============================================================"
echo "Convertendo views do Super Admin para i18n..."
echo "============================================================"

# ============================================================
# _navigation.html.erb - Menu lateral
# ============================================================
NAV="app/views/super_admin/application/_navigation.html.erb"
if [ -f "$NAV" ]; then
  sed -i "s|label: 'Dashboard'|label: t('super_admin.navigation.dashboard')|g" "$NAV"
  sed -i "s|label: 'Sidekiq Dashboard'|label: t('super_admin.navigation.sidekiq')|g" "$NAV"
  sed -i "s|label: 'Instance Health'|label: t('super_admin.navigation.instance_health')|g" "$NAV"
  sed -i "s|label: 'Agent Dashboard'|label: t('super_admin.navigation.agent_panel')|g" "$NAV"
  sed -i "s|label: 'Logout'|label: t('super_admin.navigation.logout')|g" "$NAV"
  sed -i "s|alt: 'Chatwoot Admin Dashboard'|alt: t('super_admin.dashboard.admin_dashboard')|g" "$NAV"
  echo "  [OK] application/_navigation.html.erb"
fi

# ============================================================
# _settings_menu.html.erb - Menu Settings no sidebar
# ============================================================
SETTINGS_MENU="app/views/super_admin/application/_settings_menu.html.erb"
if [ -f "$SETTINGS_MENU" ]; then
  sed -i 's|<span class="ml-2 text-sm">Settings</span>|<span class="ml-2 text-sm"><%= t('\''super_admin.navigation.settings'\'') %></span>|g' "$SETTINGS_MENU"
  echo "  [OK] application/_settings_menu.html.erb"
fi

# ============================================================
# _filters.html.erb - Filtros de listagem
# ============================================================
FILTERS="app/views/super_admin/application/_filters.html.erb"
if [ -f "$FILTERS" ]; then
  sed -i 's|>All records<|><%= t('\''administrate.filter.all'\'') %><|g' "$FILTERS"
  sed -i 's|value="">All records|value=""><%= t('\''administrate.filter.all'\'') %>|g' "$FILTERS"
  echo "  [OK] application/_filters.html.erb"
fi

# ============================================================
# users/_impersonate.erb - Simular usuário
# ============================================================
IMPERSONATE="app/views/super_admin/users/_impersonate.erb"
if [ -f "$IMPERSONATE" ]; then
  sed -i "s|Impersonate user|<%= t('super_admin.users.impersonate_user') %>|g" "$IMPERSONATE"
  sed -i "s|Caution:|<%= t('super_admin.common.caution') %>:|g" "$IMPERSONATE"
  sed -i "s|Any actions executed after impersonate will appear as actions performed by the impersonated user|<%= t('super_admin.users.impersonate_warning') %>|g" "$IMPERSONATE"
  echo "  [OK] users/_impersonate.erb"
fi

# ============================================================
# instance_statuses/show.html.erb - Status da instância
# ============================================================
INSTANCE_STATUS="app/views/super_admin/instance_statuses/show.html.erb"
if [ -f "$INSTANCE_STATUS" ]; then
  sed -i "s|Instance Status|<%= t('super_admin.instance_status.title') %>|g" "$INSTANCE_STATUS"
  sed -i "s|>Metric<|><%= t('super_admin.instance_status.metric') %><|g" "$INSTANCE_STATUS"
  sed -i "s|>Value<|><%= t('super_admin.instance_status.value') %><|g" "$INSTANCE_STATUS"
  echo "  [OK] instance_statuses/show.html.erb"
fi

# ============================================================
# dashboard/index.html.erb - Painel principal
# ============================================================
DASHBOARD="app/views/super_admin/dashboard/index.html.erb"
if [ -f "$DASHBOARD" ]; then
  sed -i "s|Admin Dashboard|<%= t('super_admin.dashboard.admin_dashboard') %>|g" "$DASHBOARD"
  echo "  [OK] dashboard/index.html.erb"
fi

# ============================================================
# accounts/_reset_cache.html.erb - Limpar cache
# ============================================================
RESET_CACHE="app/views/super_admin/accounts/_reset_cache.html.erb"
if [ -f "$RESET_CACHE" ]; then
  sed -i "s|'Reset Frontend Cache'|t('super_admin.accounts.reset_frontend_cache')|g" "$RESET_CACHE"
  sed -i "s|This will clear the frontend cached keys.|<%= t('super_admin.accounts.reset_cache_warning') %>|g" "$RESET_CACHE"
  echo "  [OK] accounts/_reset_cache.html.erb"
fi

# ============================================================
# accounts/_seed_data.html.erb - Dados de exemplo
# ============================================================
SEED_DATA="app/views/super_admin/accounts/_seed_data.html.erb"
if [ -f "$SEED_DATA" ]; then
  sed -i "s|Click the button to generate seed data into this account for demos.|<%= t('super_admin.accounts.seed_data_description') %>|g" "$SEED_DATA"
  sed -i "s|'Generate Seed Data'|t('super_admin.accounts.generate_seed_data')|g" "$SEED_DATA"
  echo "  [OK] accounts/_seed_data.html.erb"
fi

# ============================================================
# devise/sessions/new.html.erb - Login
# ============================================================
LOGIN="app/views/super_admin/devise/sessions/new.html.erb"
if [ -f "$LOGIN" ]; then
  # Textos em inglês
  sed -i "s|Howdy, admin|<%= t('super_admin.login.welcome') %>|g" "$LOGIN"
  sed -i "s|Email Address|<%= t('super_admin.login.email') %>|g" "$LOGIN"
  sed -i "s|>Password<|><%= t('super_admin.login.password') %><|g" "$LOGIN"
  sed -i "s|>Login<|><%= t('super_admin.login.sign_in') %><|g" "$LOGIN"
  # Textos PT-BR
  sed -i "s|Boas-vindas, admin|<%= t('super_admin.login.welcome') %>|g" "$LOGIN"
  sed -i 's|>E-mail<|><%= t('\''super_admin.login.email'\'') %><|g' "$LOGIN"
  sed -i 's|>Senha<|><%= t('\''super_admin.login.password'\'') %><|g' "$LOGIN"
  sed -i "s|>Entrar<|><%= t('super_admin.login.sign_in') %><|g" "$LOGIN"
  # Placeholders
  sed -i 's|placeholder: "Digite seu e-mail corporativo"|placeholder: t('\''super_admin.login.email_placeholder'\'')|g' "$LOGIN"
  sed -i 's|placeholder: "Digite sua senha"|placeholder: t('\''super_admin.login.password_placeholder'\'')|g' "$LOGIN"
  echo "  [OK] devise/sessions/new.html.erb"
fi

# ============================================================
# app_configs/show.html.erb - Configurar definições
# ============================================================
APP_CONFIGS="app/views/super_admin/app_configs/show.html.erb"
if [ -f "$APP_CONFIGS" ]; then
  sed -i "s|Configure Settings|<%= t('super_admin.app_configs.title') %>|g" "$APP_CONFIGS"
  sed -i "s|>True<|><%= t('super_admin.app_configs.true_value') %><|g" "$APP_CONFIGS"
  sed -i "s|>False<|><%= t('super_admin.app_configs.false_value') %><|g" "$APP_CONFIGS"
  sed -i "s|>Submit<|><%= t('super_admin.app_configs.submit') %><|g" "$APP_CONFIGS"
  echo "  [OK] app_configs/show.html.erb"
fi

# ============================================================
# application/index.html.erb - Botão "Novo recurso"
# ============================================================
INDEX="app/views/super_admin/application/index.html.erb"
if [ -f "$INDEX" ]; then
  # Usar tradução do ActiveRecord para nome do recurso no botão New
  sed -i 's|name: page.resource_name.titleize.downcase|name: t("activerecord.models.#{page.resource_name}.one", default: page.resource_name.titleize).downcase|g' "$INDEX"
  echo "  [OK] application/index.html.erb"
fi

# ============================================================
# application/show.html.erb - Detalhes genérico
# ============================================================
APP_SHOW="app/views/super_admin/application/show.html.erb"
if [ -f "$APP_SHOW" ]; then
  sed -i "s|>Edit<|><%= t('administrate.actions.edit') %><|g" "$APP_SHOW"
  echo "  [OK] application/show.html.erb"
fi

echo ""
echo "============================================================"
echo "Conversão para i18n concluída!"
echo "Traduções em: config/locales/super_admin.pt-BR.yml"
echo "============================================================"
