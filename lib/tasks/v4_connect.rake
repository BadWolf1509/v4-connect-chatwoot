# frozen_string_literal: true

namespace :v4_connect do
  desc 'Setup V4 Connect premium features and configurations'
  task setup: :environment do
    puts '=== V4 Connect - Configurando Features Premium ==='

    # 1. Configurar plano premium e branding
    puts "\n[1/4] Configurando plano premium e branding..."
    {
      'INSTALLATION_PRICING_PLAN' => 'premium',
      'INSTALLATION_PRICING_PLAN_QUANTITY' => 999,
      'DEPLOYMENT_ENV' => 'self-hosted',
      'INSTALLATION_NAME' => 'V4 Connect',
      'BRAND_NAME' => 'V4 Connect',
      'BRAND_URL' => 'https://v4company.com',
      'WIDGET_BRAND_URL' => 'https://v4company.com'
    }.each do |name, value|
      config = InstallationConfig.find_or_initialize_by(name: name)
      config.value = value
      config.save!
      puts "  #{name}: #{value}"
    end

    # 2. Carregar configurações padrão
    puts "\n[2/4] Carregando configurações padrão..."
    ConfigLoader.new.process
    puts '  ConfigLoader executado'

    # 3. Habilitar features premium nos defaults
    puts "\n[3/4] Habilitando features premium nos defaults..."
    config = InstallationConfig.find_by(name: 'ACCOUNT_LEVEL_FEATURE_DEFAULTS')

    if config
      premium_features = %w[
        disable_branding audit_logs sla custom_roles captain_integration
        saml companies assignment_v2 crm_integration linear_integration
        notion_integration whatsapp_campaign
      ]

      features = config.value
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

    Account.find_each do |account|
      account.enable_features(*all_features)
      account.save!
      puts "  Account ##{account.id}: #{account.name}"
    end

    puts "\n=== Configuração Concluída ==="
  end
end
