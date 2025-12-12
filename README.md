# V4 Connect - Chatwoot Customizado

Fork customizado do Chatwoot v4.8.0 para a plataforma V4 Connect, com foco em:
- **Localização completa PT-BR** com suporte a caracteres especiais (acentos, ç)
- **Branding V4 Connect** (vermelho #e50914)
- **White-label** para o mercado brasileiro

## Status do Projeto

| Módulo | Status | Observações |
|--------|--------|-------------|
| Super Admin | ✅ Completo | Tradução via i18n + locale |
| Login/Onboarding | ✅ Completo | Inclui placeholders |
| Dashboard Admin | ✅ Completo | Componentes Vue traduzidos |
| Instance Status | ✅ Completo | Métricas traduzidas no controller |
| Navegação | ✅ Completo | Menus e links |
| Features (nomes) | ✅ Completo | Via sed no build |
| Branding | ✅ Completo | Logo, favicon, cores |

## Arquitetura de Tradução

O V4 Connect usa uma abordagem **híbrida** para tradução:

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUXO DE TRADUÇÃO                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. VIEWS (ERB Templates)                                       │
│     └── convert_views_to_i18n.sh converte textos para t()       │
│     └── Locale super_admin.pt-BR.yml fornece traduções          │
│                                                                 │
│  2. CONTROLLERS (Ruby)                                          │
│     └── sed substitui strings hardcoded no build                │
│     └── Ex: instance_statuses_controller.rb                     │
│                                                                 │
│  3. COMPONENTES VUE (Frontend)                                  │
│     └── Node.js script aplica traduções no JSON de locale       │
│     └── Ex: app/javascript/dashboard/i18n/locale/pt_BR/         │
│                                                                 │
│  4. FEATURES (YAML)                                             │
│     └── sed substitui nomes e descrições                        │
│     └── Ex: enterprise/app/models/enterprise/features.yml       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Arquivos de Tradução

| Arquivo | Propósito |
|---------|-----------|
| `locales/super_admin.pt-BR.yml` | Traduções do módulo Super Admin (com acentos) |
| `scripts/convert_views_to_i18n.sh` | Converte views para usar i18n |
| `scripts/apply_frontend_translations.js` | Traduções do dashboard Vue |
| `build_v4_connect_image.sh` | Aplica todas as customizações no build |

## Customizações Implementadas

### Branding
- Logo V4 Connect (SVG) em `/public/brand-assets/`
- Favicon customizado
- Cores: vermelho primário #e50914
- Nome da instalação: "V4 Connect"

### Traduções PT-BR
- **Super Admin**: Login, Dashboard, Settings, Accounts, Users
- **Navegação**: Menus laterais e superiores
- **Instance Status**: Métricas (Versão, PostgreSQL, Redis, Sidekiq)
- **Features**: Nomes e descrições das funcionalidades
- **Onboarding**: Fluxo de criação de conta

### Tipografia
- Proxima Nova / Bebas Neue (via branding)

## Estrutura do Repositório

```
v4-connect-chatwoot/
├── .github/workflows/       # CI/CD automático (GitHub Actions)
├── branding/                # Logos, favicons, assets visuais
├── locales/
│   └── super_admin.pt-BR.yml  # Traduções com acentos
├── scripts/
│   ├── apply_branding.sh       # Configura branding no banco
│   ├── apply_super_admin.sh    # Cria usuário super admin
│   ├── convert_views_to_i18n.sh # Converte views para i18n
│   ├── apply_frontend_translations.js # Traduções Vue
│   ├── deploy.sh               # Deploy na VPS
│   └── quick-test.sh           # Validação rápida
├── docker/                  # Configurações Docker
├── build_v4_connect_image.sh  # Script de build principal
└── .env.example
```

## Workflow de Desenvolvimento

```
┌─────────────────────────────────────────────────────────────────┐
│                    WORKFLOW DE DESENVOLVIMENTO                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Criar feature branch a partir de 'develop'                  │
│     └── git checkout develop                                    │
│     └── git checkout -b feature/minha-feature                   │
│                                                                 │
│  2. Fazer alterações e testar localmente                        │
│     └── ./scripts/quick-test.sh                                 │
│                                                                 │
│  3. Push para origin                                            │
│     └── git push origin feature/minha-feature                   │
│                                                                 │
│  4. Criar PR para 'develop'                                     │
│     └── GitHub Actions builda (sem push para registry)          │
│     └── Validar se build passou                                 │
│                                                                 │
│  5. Merge para 'develop' após aprovação                         │
│                                                                 │
│  6. Quando pronto para produção: PR develop → main              │
│     └── GitHub Actions builda + push para GHCR                  │
│                                                                 │
│  7. Na VPS: executar deploy                                     │
│     └── ./scripts/deploy.sh                                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Branches

| Branch | Propósito | Build | Push GHCR |
|--------|-----------|-------|-----------|
| `main` | Produção | ✅ | ✅ |
| `develop` | Desenvolvimento | ✅ | ❌ |
| `feature/*` | Features | Via PR | ❌ |

## Build da Imagem

### O que o build faz

1. Clona Chatwoot v4.8.0
2. Copia locale PT-BR para `config/locales/`
3. Executa `convert_views_to_i18n.sh` (converte views)
4. Aplica traduções via sed (controllers, features)
5. Executa `apply_frontend_translations.js` (Vue)
6. Copia branding para `public/brand-assets/`
7. Builda imagem Docker

### Build Local

```bash
# Definir versão (padrão: v4.8.0)
export CHATWOOT_VERSION=v4.8.0
export IMAGE_TAG=v4-connect/chatwoot:v4.8.0-branded

# Executar build
./build_v4_connect_image.sh
```

### Build via GitHub Actions

Qualquer push para `main` dispara build automático no GHCR:
- Imagem: `ghcr.io/badwolf1509/v4-connect-chatwoot:latest`

## Desenvolvimento Local

### Pré-requisitos
- Docker instalado
- Git instalado
- Node.js (para scripts de tradução)

### 1. Preparar ambiente

```bash
# Clone o Chatwoot oficial
git clone https://github.com/chatwoot/chatwoot.git chatwoot-dev
cd chatwoot-dev
git checkout v4.8.0

# Copie o branding
cp -r ../v4-connect-chatwoot/branding/* public/brand-assets/
```

### 2. Configurar .env

```bash
cp .env.example .env
```

Edite o `.env`:

```bash
DEFAULT_LOCALE=pt_BR
INSTALLATION_NAME=V4 Connect
POSTGRES_PASSWORD=chatwoot
SECRET_KEY_BASE=replace_with_lengthy_secure_hex
RAILS_ENV=development
```

### 3. Subir containers

```bash
docker compose up -d postgres redis
sleep 5
docker compose up rails sidekiq vite mailhog
```

### 4. Setup do banco

```bash
docker compose exec rails bundle exec rails db:create
docker compose exec rails bundle exec rails db:schema:load
docker compose exec rails bundle exec rails db:seed
```

### 5. Criar Super Admin

```bash
cd ../v4-connect-chatwoot
./scripts/apply_super_admin.sh --container chatwoot-dev-rails-1
```

### 6. Aplicar branding

```bash
./scripts/apply_branding.sh --container chatwoot-dev-rails-1
```

### 7. Acessar

- **Aplicação**: http://localhost:3000
- **Vite HMR**: http://localhost:3036/vite-dev/
- **Mailhog**: http://localhost:8025

## Deploy em Produção

### Via GHCR (Recomendado)

```bash
# Deploy da última versão
./scripts/deploy.sh

# Deploy de tag específica
./scripts/deploy.sh -t v4.8.0

# Ver status
./scripts/deploy.sh -s

# Rollback
./scripts/deploy.sh -r
```

### Manual com Docker Swarm

```bash
docker pull ghcr.io/badwolf1509/v4-connect-chatwoot:latest
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-web
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-worker
```

## Adicionando Novas Traduções

### Para views (ERB)

1. Adicione a chave em `locales/super_admin.pt-BR.yml`
2. Adicione o sed em `scripts/convert_views_to_i18n.sh`

Exemplo:
```yaml
# locales/super_admin.pt-BR.yml
pt_BR:
  super_admin:
    minha_pagina:
      titulo: "Meu Título"
```

```bash
# scripts/convert_views_to_i18n.sh
sed -i "s|My Title|<%= t('super_admin.minha_pagina.titulo') %>|g" "$ARQUIVO"
```

### Para controllers (Ruby)

Adicione sed direto em `build_v4_connect_image.sh`:

```bash
sed -i "s|'English text'|'Texto em português'|g" "app/controllers/..."
```

### Para Vue (Frontend)

Edite `scripts/apply_frontend_translations.js` ou os arquivos JSON em `app/javascript/dashboard/i18n/locale/pt_BR/`.

## Versionamento

```bash
# Criar release
git tag v4.8.0-v4connect-2
git push origin v4.8.0-v4connect-2
```

## Imagens Docker

| Registry | Imagem |
|----------|--------|
| GHCR | `ghcr.io/badwolf1509/v4-connect-chatwoot:latest` |
| Local | `v4-connect/chatwoot:v4.8.0-branded` |

## Baseado no Chatwoot

- **Versão base**: v4.8.0
- **Repositório original**: https://github.com/chatwoot/chatwoot
- **Licença**: MIT (mesma do Chatwoot)
