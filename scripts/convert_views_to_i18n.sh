#!/usr/bin/env bash
# Converte views do Super Admin para usar i18n em vez de textos hardcoded
# As traduções são gerenciadas pelo arquivo config/locales/super_admin.pt-BR.yml
#
# NOTA: settings/show.html.erb é traduzido diretamente via sed no build_v4_connect_image.sh
# para evitar problemas com carregamento de locale no Super Admin

set -euo pipefail

echo "Convertendo views do Super Admin para i18n..."

# NOTA: settings/show.html.erb e botões de upgrade são traduzidos
# diretamente via sed no build_v4_connect_image.sh (não usam i18n)

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
