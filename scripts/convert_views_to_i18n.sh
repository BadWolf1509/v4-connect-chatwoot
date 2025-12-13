#!/bin/sh
# Converte views do Super Admin para usar i18n em vez de textos hardcoded
# As traduções são gerenciadas pelo arquivo config/locales/super_admin.pt-BR.yml
#
# Este script é executado durante o build da imagem Docker
# para converter textos hardcoded em chamadas t() do Rails i18n

set -e

echo "============================================================"
echo "Convertendo views do Super Admin para i18n..."
echo "============================================================"

# ============================================================
# Layout - Suporte a Dark Mode
# ============================================================
LAYOUT="app/views/layouts/super_admin/application.html.erb"
if [ -f "$LAYOUT" ]; then
  # Adicionar estilos e script de dark mode inline (antes do </head>)
  # Estilos inline são mais confiáveis pois não dependem de recompilação de assets
  # Paleta V4 Connect Dark Mode (igual ao app principal):
  # - Background: #121213 | Solid-1: #17171a | Solid-2: #1d1e24 | Solid-3: #2c2d36
  # - Border: #343434 | Text: #edeef0 (primary), #b0b4ba (secondary) | Links: #ff949d
  DARK_MODE_BLOCK='<style>
    /* ============================================================ */
    /* DARK MODE - SUPER ADMIN V4 CONNECT                           */
    /* Cores baseadas no app principal (_next-colors.scss)          */
    /* ============================================================ */

    /* === SIDEBAR/NAVIGATION === */
    [role="navigation"] { height: 100vh !important; overflow-y: auto !important; }
    .dark [role="navigation"] {
      background-color: #17171a !important;
      border-color: #343434 !important;
    }
    .dark [role="navigation"] .border-slate-100 { border-color: #343434 !important; }
    .dark [role="navigation"] .border-b { border-color: #343434 !important; }
    .dark [role="navigation"] .text-sm { color: #edeef0 !important; }
    .dark [role="navigation"] .text-xs { color: #b0b4ba !important; }
    .dark [role="navigation"] .text-slate-700 { color: #b0b4ba !important; }
    .dark [role="navigation"] .text-slate-500 { color: #b0b4ba !important; }
    .dark [role="navigation"] .text-slate-600 { color: #b0b4ba !important; }
    .dark [role="navigation"] .text-slate-800 { color: #b0b4ba !important; }
    .dark [role="navigation"] .text-slate-900 { color: #edeef0 !important; }
    .dark [role="navigation"] a { color: #b0b4ba !important; }
    .dark [role="navigation"] a:hover { color: #edeef0 !important; background-color: #2c2d36 !important; }
    .dark [role="navigation"] .hover\\:bg-slate-100:hover { background-color: #2c2d36 !important; }
    .dark [role="navigation"] .hover\\:bg-slate-50:hover { background-color: #2c2d36 !important; }
    .dark [role="navigation"] .bg-slate-25 { background-color: #1d1e24 !important; }
    .dark [role="navigation"] .bg-slate-50 { background-color: #1d1e24 !important; }
    .dark [role="navigation"] svg { color: #b0b4ba !important; }

    /* === MAIN CONTENT AREA === */
    .dark .main-content__header {
      background-color: #17171a !important;
      border-bottom-color: #343434 !important;
    }
    .dark .main-content__page-title { color: #edeef0 !important; }
    .dark .main-content__body { color: #b0b4ba !important; }

    /* === REPORT CARDS (Dashboard) === */
    .dark .report--list { background-color: transparent !important; }
    .dark .report-card {
      background-color: #17171a !important;
      border-color: #343434 !important;
      color: #b0b4ba !important;
    }
    .dark .report-card .metric { color: #edeef0 !important; font-weight: bold; }

    /* === TABLES === */
    .dark table { color: #b0b4ba !important; background-color: transparent !important; }
    .dark table th {
      background-color: #1d1e24 !important;
      color: #edeef0 !important;
      border-color: #343434 !important;
    }
    .dark table td {
      border-color: #26262a !important;
      background-color: transparent !important;
    }
    .dark table tr:hover td { background-color: #1d1e24 !important; }
    .dark table a { color: #ff949d !important; }
    .dark table a:hover { color: #fed2e1 !important; }

    /* === LINKS (apenas área principal) === */
    .dark main a { color: #ff949d !important; }
    .dark main a:hover { color: #fed2e1 !important; }

    /* === BUTTONS === */
    .dark .button {
      background-color: #2c2d36 !important;
      color: #edeef0 !important;
      border-color: #343434 !important;
    }
    .dark .button:hover { background-color: #353942 !important; }
    .dark .button--primary {
      background-color: #e50914 !important;
      border-color: #e50914 !important;
      color: white !important;
    }
    .dark .button--primary:hover { background-color: #b20710 !important; }
    .dark button[type="submit"] {
      background-color: #e50914 !important;
      color: white !important;
    }

    /* === FORMS === */
    .dark input, .dark select, .dark textarea {
      background-color: #1d1e24 !important;
      border-color: #343434 !important;
      color: #edeef0 !important;
    }
    .dark input:focus, .dark select:focus, .dark textarea:focus {
      border-color: #e5455a !important;
      outline: none !important;
    }
    .dark input::placeholder, .dark textarea::placeholder { color: #696e77 !important; }
    .dark label { color: #b0b4ba !important; }
    .dark .field-unit__label { color: #b0b4ba !important; }

    /* === PAGINATION === */
    .dark .pagination a, .dark .pagination span { color: #b0b4ba !important; }
    .dark .pagination a:hover { background-color: #2c2d36 !important; }
    .dark .pagination .current { background-color: #e50914 !important; color: white !important; }

    /* === MISC === */
    .dark .flash { background-color: #2c2d36 !important; color: #edeef0 !important; }
    .dark .attribute-data { color: #b0b4ba !important; }
    .dark .attribute-data--id a { color: #ff949d !important; }
    .dark .feature-cell { background-color: #2c2d36 !important; color: #b0b4ba !important; }
    .dark .search input { background-color: #1d1e24 !important; border-color: #343434 !important; }
    .dark h1, .dark h2, .dark h3, .dark h4 { color: #edeef0 !important; }
    .dark p { color: #b0b4ba !important; }

    /* === THEME TOGGLE BUTTONS === */
    .dark .theme-toggle-btn {
      background-color: transparent !important;
      border: none !important;
    }
    .dark .theme-toggle-btn:hover { background-color: #2c2d36 !important; }
    .dark .theme-toggle-btn.active { background-color: #353942 !important; }

    /* === FEATURE CARDS ICONS === */
    .dark .feature-icon { fill: #b0b4ba !important; color: #b0b4ba !important; }
    .dark .w-10.h-10.border-slate-100.text-slate-800.rounded-full { color: #b0b4ba !important; border-color: #343434 !important; background-color: #1d1e24 !important; }
    .dark .w-10.h-10.border-slate-100.text-slate-800.rounded-full svg { fill: #b0b4ba !important; }
    .dark section.main-content__body svg.feature-icon { fill: #b0b4ba !important; }
    .dark .border-n-weak { border-color: #343434 !important; }
    .dark .text-n-slate-11 { color: #b0b4ba !important; }
    .dark .text-n-slate-12 { color: #edeef0 !important; }
    .dark .outline-n-container { outline-color: #343434 !important; }
    .dark main svg { color: #b0b4ba !important; fill: currentColor !important; stroke: currentColor !important; }
    .dark main svg path { fill: currentColor !important; }
    .dark main svg use { color: #b0b4ba !important; }
    .dark .border.border-slate-100.rounded-full svg { color: #b0b4ba !important; fill: #b0b4ba !important; }
    .dark .text-slate-800 svg { color: #b0b4ba !important; fill: #b0b4ba !important; }
    .dark div[class*="border-slate-100"][class*="rounded-full"] { border-color: #343434 !important; background-color: #1d1e24 !important; }
    .dark div[class*="border-slate-100"][class*="text-slate-800"] { color: #b0b4ba !important; }
    .dark .rounded-full.border-slate-100 { border-color: #343434 !important; background-color: #1d1e24 !important; }
    .dark .rounded-full.text-slate-800 { color: #b0b4ba !important; }
    .dark .border.border-slate-100.rounded-full, .dark .w-10.h-10.border-slate-100 { border-color: #343434 !important; background-color: #1d1e24 !important; color: #b0b4ba !important; }

    /* === TAILWIND OVERRIDES === */
    .dark .bg-white { background-color: #121213 !important; }
    .dark .bg-slate-25 { background-color: #1d1e24 !important; }
    .dark .bg-slate-50 { background-color: #1d1e24 !important; }
    .dark .bg-slate-100 { background-color: #2c2d36 !important; }
    .dark .text-slate-900 { color: #edeef0 !important; }
    .dark .text-slate-800 { color: #edeef0 !important; }
    .dark .text-slate-700 { color: #b0b4ba !important; }
    .dark .text-slate-600 { color: #b0b4ba !important; }
    .dark .text-slate-500 { color: #696e77 !important; }
    .dark .border-slate-100 { border-color: #343434 !important; }
    .dark .border-slate-200 { border-color: #343434 !important; }
    .dark .ring-slate-200 { --tw-ring-color: #343434 !important; }

    /* === CARDS/SECTIONS === */
    .dark section { background-color: transparent !important; }
    .dark .shadow { box-shadow: 0 1px 3px rgba(0,0,0,0.3) !important; }
    .dark .shadow-sm { box-shadow: 0 1px 2px rgba(0,0,0,0.3) !important; }

    /* === SETTINGS SUBMENU (details/summary) === */
    .dark details { background-color: transparent !important; }
    .dark details summary {
      color: #b0b4ba !important;
      background-color: transparent !important;
    }
    .dark details summary:hover { background-color: #2c2d36 !important; }
    .dark details[open] summary { background-color: #1d1e24 !important; }
    .dark details ul { background-color: #1d1e24 !important; }
    .dark details ul li a {
      color: #b0b4ba !important;
      background-color: transparent !important;
    }
    .dark details ul li a:hover {
      color: #edeef0 !important;
      background-color: #2c2d36 !important;
    }
    .dark .text-woot-500 { color: #ff949d !important; }
    .dark details summary .text-woot-500,
    .dark details summary.text-woot-500 { color: #ff949d !important; }
    .dark details ul li a.text-woot-500 { color: #ff949d !important; }
    .dark .bg-slate-25 { background-color: #1d1e24 !important; }

    /* === CHART.JS === */
    .dark canvas { filter: none; }
  </style>
  <script>
    (function() {
      var theme = localStorage.getItem("super-admin-theme");
      var prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
      if (theme === "dark" || (theme === "system" && prefersDark) || (!theme && prefersDark)) {
        document.documentElement.classList.add("dark");
      }
      window.chartJsDarkMode = document.documentElement.classList.contains("dark");
    })();
  </script>'

  # Adicionar script para configurar Chart.js após body (cores do app principal)
  CHARTJS_CONFIG='<script>
    document.addEventListener("DOMContentLoaded", function() {
      if (window.Chart && document.documentElement.classList.contains("dark")) {
        Chart.defaults.color = "#b0b4ba";
        Chart.defaults.borderColor = "#343434";
      }
    });
  </script>'

  # Inserir configuração do Chart.js antes de </body>
  sed -i "s|</body>|${CHARTJS_CONFIG}\n</body>|" "$LAYOUT"

  # Inserir bloco antes de </head>
  sed -i "s|</head>|${DARK_MODE_BLOCK}\n</head>|" "$LAYOUT"

  # Adicionar classes dark mode ao body e main (cores do app principal: #121213)
  sed -i 's|<body class="antialiased w-full h-full">|<body class="antialiased w-full h-full bg-white dark:bg-[#121213]">|g' "$LAYOUT"
  sed -i 's|role="main">|role="main" class="dark:bg-[#121213]">|g' "$LAYOUT"

  echo "  [OK] layouts/super_admin/application.html.erb (dark mode)"
fi

# ============================================================
# _navigation.html.erb - Menu lateral
# ============================================================
NAV="app/views/super_admin/application/_navigation.html.erb"
if [ -f "$NAV" ]; then
  # Ajustar largura do sidebar para 260px (igual ao app principal)
  sed -i "s|w-56 flex-shrink-0|w-[260px] flex-shrink-0|g" "$NAV"
  sed -i "s|w-72 flex-shrink-0|w-[260px] flex-shrink-0|g" "$NAV"
  # Traduções
  sed -i "s|label: 'Dashboard'|label: t('super_admin.navigation.dashboard')|g" "$NAV"
  sed -i "s|label: 'Sidekiq Dashboard'|label: t('super_admin.navigation.sidekiq')|g" "$NAV"
  sed -i "s|label: 'Instance Health'|label: t('super_admin.navigation.instance_health')|g" "$NAV"
  sed -i "s|label: 'Agent Dashboard'|label: t('super_admin.navigation.agent_panel')|g" "$NAV"
  sed -i "s|label: 'Logout'|label: t('super_admin.navigation.logout')|g" "$NAV"
  sed -i "s|alt: 'Chatwoot Admin Dashboard'|alt: t('super_admin.dashboard.admin_dashboard')|g" "$NAV"

  # Adicionar informações do super admin logado e toggle de tema na seção inferior do sidebar
  # Usa awk para identificar a segunda ocorrência do padrão </div>\n  <div>
  awk '
    /<\/div>/ { close_div++ }
    close_div == 2 && /^  <div>$/ {
      print $0
      print "    <div class=\"px-4 py-3 border-t border-slate-100 dark:border-[#343434]\">"
      print "      <div class=\"text-sm font-medium text-slate-900 dark:text-[#edeef0] truncate\"><%= current_super_admin.name %></div>"
      print "      <div class=\"text-xs text-slate-500 dark:text-[#b0b4ba] truncate\"><%= current_super_admin.email %></div>"
      print "      <!-- Theme Toggle -->"
      print "      <div class=\"flex items-center gap-1 mt-3\">"
      print "        <button onclick=\"setTheme('"'"'light'"'"')\" id=\"theme-light\" class=\"theme-toggle-btn p-1.5 rounded\" title=\"<%= t('"'"'super_admin.theme.light'"'"') %>\">"
      print "          <svg class=\"w-4 h-4\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z\"></path></svg>"
      print "        </button>"
      print "        <button onclick=\"setTheme('"'"'dark'"'"')\" id=\"theme-dark\" class=\"theme-toggle-btn p-1.5 rounded\" title=\"<%= t('"'"'super_admin.theme.dark'"'"') %>\">"
      print "          <svg class=\"w-4 h-4\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z\"></path></svg>"
      print "        </button>"
      print "        <button onclick=\"setTheme('"'"'system'"'"')\" id=\"theme-system\" class=\"theme-toggle-btn p-1.5 rounded\" title=\"<%= t('"'"'super_admin.theme.system'"'"') %>\">"
      print "          <svg class=\"w-4 h-4\" fill=\"none\" stroke=\"currentColor\" viewBox=\"0 0 24 24\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" stroke-width=\"2\" d=\"M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z\"></path></svg>"
      print "        </button>"
      print "      </div>"
      print "      <script>"
      print "        function setTheme(theme) {"
      print "          localStorage.setItem('"'"'super-admin-theme'"'"', theme);"
      print "          var prefersDark = window.matchMedia('"'"'(prefers-color-scheme: dark)'"'"').matches;"
      print "          if (theme === '"'"'dark'"'"' || (theme === '"'"'system'"'"' && prefersDark)) {"
      print "            document.documentElement.classList.add('"'"'dark'"'"');"
      print "          } else {"
      print "            document.documentElement.classList.remove('"'"'dark'"'"');"
      print "          }"
      print "          updateThemeButtons(theme);"
      print "        }"
      print "        function updateThemeButtons(theme) {"
      print "          ['"'"'light'"'"', '"'"'dark'"'"', '"'"'system'"'"'].forEach(function(t) {"
      print "            var btn = document.getElementById('"'"'theme-'"'"' + t);"
      print "            if (btn) {"
      print "              if (t === theme) {"
      print "                btn.classList.add('"'"'active'"'"');"
      print "                btn.style.backgroundColor = '"'"'#353942'"'"';"
      print "              } else {"
      print "                btn.classList.remove('"'"'active'"'"');"
      print "                btn.style.backgroundColor = '"'"'transparent'"'"';"
      print "              }"
      print "            }"
      print "          });"
      print "        }"
      print "        document.addEventListener('"'"'DOMContentLoaded'"'"', function() {"
      print "          var theme = localStorage.getItem('"'"'super-admin-theme'"'"') || '"'"'system'"'"';"
      print "          updateThemeButtons(theme);"
      print "        });"
      print "      </script>"
      print "    </div>"
      next
    }
    { print }
  ' "$NAV" > "${NAV}.tmp" && mv "${NAV}.tmp" "$NAV"

  # Adicionar classes dark mode ao sidebar container (cores do app principal)
  # Background solid-1: #17171a | Border: #343434 | Text secondary: #b0b4ba | Links: #ff949d
  sed -i 's|border-slate-100 border-r|border-slate-100 dark:border-[#343434] border-r bg-white dark:bg-[#17171a]|g' "$NAV"
  sed -i 's|text-slate-700 mt-0.5|text-slate-700 dark:text-[#b0b4ba] mt-0.5|g' "$NAV"
  # Título da versão - text primary: #edeef0
  sed -i 's|class="text-sm">|class="text-sm dark:text-[#edeef0]">|g' "$NAV"
  # Links da navegação - Links ruby: #ff949d
  sed -i 's|hover:bg-slate-100|hover:bg-slate-100 dark:hover:bg-[#2c2d36]|g' "$NAV"
  # Borda da seção do logo
  sed -i 's|border-slate-100 border-b py-6|border-slate-100 dark:border-[#343434] border-b py-6|g' "$NAV"

  echo "  [OK] application/_navigation.html.erb (largura: 260px, info admin, theme toggle, dark mode cores app)"
fi

# ============================================================
# _nav_item.html.erb - Itens de navegação individual
# ============================================================
NAV_ITEM="app/views/super_admin/application/_nav_item.html.erb"
if [ -f "$NAV_ITEM" ]; then
  # Adicionar dark mode aos itens de navegação (cores do app principal)
  # Text secondary: #b0b4ba | Hover bg: #2c2d36 | Active: #353942
  sed -i 's|text-slate-600|text-slate-600 dark:text-[#b0b4ba]|g' "$NAV_ITEM"
  sed -i 's|text-slate-700|text-slate-700 dark:text-[#b0b4ba]|g' "$NAV_ITEM"
  sed -i 's|hover:bg-slate-50|hover:bg-slate-50 dark:hover:bg-[#2c2d36]|g' "$NAV_ITEM"
  sed -i 's|hover:text-slate-900|hover:text-slate-900 dark:hover:text-[#edeef0]|g' "$NAV_ITEM"
  echo "  [OK] application/_nav_item.html.erb (dark mode)"
fi

# ============================================================
# _settings_menu.html.erb - Menu Settings no sidebar
# ============================================================
SETTINGS_MENU="app/views/super_admin/application/_settings_menu.html.erb"
if [ -f "$SETTINGS_MENU" ]; then
  sed -i 's|<span class="ml-2 text-sm">Settings</span>|<span class="ml-2 text-sm"><%= t('\''super_admin.navigation.settings'\'') %></span>|g' "$SETTINGS_MENU"
  # Dark mode para settings menu (cores do app principal)
  sed -i 's|text-slate-600|text-slate-600 dark:text-[#b0b4ba]|g' "$SETTINGS_MENU"
  sed -i 's|text-slate-700|text-slate-700 dark:text-[#b0b4ba]|g' "$SETTINGS_MENU"
  sed -i 's|hover:bg-slate-50|hover:bg-slate-50 dark:hover:bg-[#2c2d36]|g' "$SETTINGS_MENU"
  sed -i 's|bg-slate-50|bg-slate-50 dark:bg-[#1d1e24]|g' "$SETTINGS_MENU"
  echo "  [OK] application/_settings_menu.html.erb (dark mode)"
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
  # Dark mode para página de login (cores do app principal)
  sed -i 's|bg-white|bg-white dark:bg-[#17171a]|g' "$LOGIN"
  sed -i 's|text-gray-900|text-gray-900 dark:text-[#edeef0]|g' "$LOGIN"
  sed -i 's|text-gray-700|text-gray-700 dark:text-[#b0b4ba]|g' "$LOGIN"
  sed -i 's|border-gray-300|border-gray-300 dark:border-[#343434]|g' "$LOGIN"
  echo "  [OK] devise/sessions/new.html.erb (dark mode)"
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

# ============================================================
# settings/show.html.erb - Adicionar classe aos ícones SVG
# ============================================================
SETTINGS_SHOW="app/views/super_admin/settings/show.html.erb"
if [ -f "$SETTINGS_SHOW" ]; then
  # Adicionar classe feature-icon aos SVGs dos cards de funcionalidades
  sed -i 's|<svg width="20" height="20"><use xlink:href="#<%= attrs\[:icon\] %>" /></svg>|<svg width="20" height="20" class="feature-icon" style="fill: currentColor"><use xlink:href="#<%= attrs[:icon] %>" /></svg>|g' "$SETTINGS_SHOW"
  echo "  [OK] settings/show.html.erb (feature icons)"
fi

echo ""
echo "============================================================"
echo "Conversão para i18n concluída!"
echo "Traduções em: config/locales/super_admin.pt-BR.yml"
echo "============================================================"
