#!/usr/bin/env ruby
# frozen_string_literal: true

# V4 Connect - Setup Premium Features
# Este script configura o plano premium e habilita features enterprise
# Executar com: bundle exec rails runner scripts/setup_premium_features.rb

puts "=== V4 Connect - Configurando Features Premium ==="

# 1. Configurar plano premium e branding
puts "\n[1/4] Configurando plano premium e branding..."

premium_configs = {
  'INSTALLATION_PRICING_PLAN' => 'premium',
  'INSTALLATION_PRICING_PLAN_QUANTITY' => 999,
  'DEPLOYMENT_ENV' => 'self-hosted',
  'INSTALLATION_NAME' => 'V4 Connect',
  'BRAND_NAME' => 'V4 Connect',
  'BRAND_URL' => 'https://v4company.com',
  'WIDGET_BRAND_URL' => 'https://v4company.com'
}

premium_configs.each do |name, value|
  config = InstallationConfig.find_or_initialize_by(name: name)
  config.value = value
  config.save!
  puts "  #{name}: #{value}"
end

# 2. Carregar configurações padrão se não existirem
puts "\n[2/4] Carregando configurações padrão..."
ConfigLoader.new.process
puts "  ConfigLoader executado"

# 3. Habilitar features premium nos defaults
puts "\n[3/4] Habilitando features premium nos defaults..."

config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')

if config
  features = config.value

  # Features premium para habilitar por padrão
  premium_features = %w[
    disable_branding
    audit_logs
    sla
    custom_roles
    captain_integration
    saml
    companies
    assignment_v2
    crm_integration
    linear_integration
    notion_integration
    whatsapp_campaign
  ]

  enabled_count = 0
  features.each do |f|
    if premium_features.include?(f['name']) && !f['enabled']
      f['enabled'] = true
      enabled_count += 1
      puts "  + #{f['name']}"
    end
  end

  config.update!(value: features)
  puts "  #{enabled_count} features habilitadas nos defaults"
else
  puts "  AVISO: ACCOUNT_LEVEL_FEATURE_DEFAULTS não encontrado"
end

# 4. Habilitar features em contas existentes
puts "\n[4/4] Habilitando features em contas existentes..."

all_features = %w[
  inbound_emails channel_email channel_facebook channel_instagram
  help_center agent_bots macros agent_management team_management
  inbox_management labels custom_attributes automations canned_responses
  integrations voice_recorder channel_website campaigns reports crm
  auto_resolve_conversations chatwoot_v4
  disable_branding audit_logs sla custom_roles captain_integration
  saml companies assignment_v2 crm_integration linear_integration
  notion_integration whatsapp_campaign
]

account_count = 0
Account.find_each do |account|
  account.enable_features(*all_features)
  account.save!
  account_count += 1
  puts "  Account ##{account.id}: #{account.name}"
end

puts "  #{account_count} contas atualizadas"

# Resumo
puts "\n=== Configuração Concluída ==="
puts "Plano: premium (999 agentes)"
puts "Features premium habilitadas: #{all_features.count}"
puts "Contas atualizadas: #{account_count}"
