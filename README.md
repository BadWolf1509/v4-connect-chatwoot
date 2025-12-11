# V4 Connect - Chatwoot Customizado

Fork customizado do Chatwoot para a plataforma V4 Connect.

## Customizações

- **Branding**: Logo e cores V4 Connect (vermelho #e50914)
- **Tipografia**: Proxima Nova / Bebas Neue
- **Tradução PT-BR**: Super Admin, Login, Onboarding
- **Rebranding**: Chatwoot → V4 Connect em toda interface

## Estrutura do Repositório

```
v4-connect-chatwoot/
├── .github/workflows/      # CI/CD automático
├── branding/               # Logos e favicons
├── patches/                # Patches de código (traduções, etc)
├── scripts/
│   ├── apply_branding.sh  # Aplicar branding no banco
│   ├── deploy.sh          # Script de deploy na VPS
│   └── quick-test.sh      # Validação rápida
├── docker/                 # Configurações Docker
├── build_v4_connect_image.sh  # Script de build principal
└── .env.example
```

## Workflow de Desenvolvimento

```
┌─────────────────────────────────────────────────────────────┐
│                    WORKFLOW DE DESENVOLVIMENTO               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. Criar feature branch a partir de 'develop'              │
│     └── git checkout develop                                │
│     └── git checkout -b feature/minha-feature               │
│                                                              │
│  2. Fazer alterações e testar localmente                    │
│     └── ./scripts/quick-test.sh                             │
│                                                              │
│  3. Push para origin                                        │
│     └── git push origin feature/minha-feature               │
│                                                              │
│  4. Criar PR para 'develop'                                 │
│     └── GitHub Actions builda (sem push para registry)      │
│     └── Validar se build passou                             │
│                                                              │
│  5. Merge para 'develop' após aprovação                     │
│                                                              │
│  6. Quando pronto para produção: PR develop → main          │
│     └── GitHub Actions builda + push para GHCR              │
│                                                              │
│  7. Na VPS: executar deploy                                 │
│     └── ./scripts/deploy.sh                                 │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Branches

| Branch | Propósito | Build | Push GHCR |
|--------|-----------|-------|-----------|
| `main` | Produção | ✅ | ✅ |
| `develop` | Desenvolvimento | ✅ | ❌ |
| `feature/*` | Features | Via PR | ❌ |

## Build Local

### Pré-requisitos
- Docker instalado
- Git instalado

### Construir a imagem

```bash
# Definir versão (padrão: v4.8.0)
export CHATWOOT_VERSION=v4.8.0
export IMAGE_TAG=v4-connect/chatwoot:v4.8.0-branded

# Executar build
./build_v4_connect_image.sh
```

## Desenvolvimento local (hot reload)

Para desenvolvimento rápido com hot reload, sem precisar rebuild da imagem:

### 1. Preparar o ambiente Chatwoot

```bash
# Clone o Chatwoot oficial (se ainda não tem)
git clone https://github.com/chatwoot/chatwoot.git chatwoot-dev
cd chatwoot-dev
git checkout v4.8.0

# Copie o branding do v4-connect-chatwoot
cp -r ../v4-connect-chatwoot/branding/* public/brand-assets/
```

### 2. Configurar variáveis de ambiente

```bash
# Crie o arquivo .env
cp .env.example .env
```

Edite o `.env` e defina **pelo menos** estas variáveis:

```bash
# Idioma padrão (CRÍTICO para PT-BR funcionar!)
DEFAULT_LOCALE=pt_BR

# Nome da instalação
INSTALLATION_NAME=V4 Connect

# Credenciais do banco
POSTGRES_PASSWORD=chatwoot

# Redis (opcional se não usar senha)
REDIS_PASSWORD=chatwoot

# Rails
SECRET_KEY_BASE=replace_with_lengthy_secure_hex
RAILS_ENV=development
```

### 3. Subir os containers de desenvolvimento

```bash
# Subir PostgreSQL e Redis primeiro
docker compose up -d postgres redis

# Aguardar alguns segundos para o banco inicializar
sleep 5

# Subir Rails, Sidekiq, Vite e Mailhog
docker compose up rails sidekiq vite mailhog
```

### 4. Setup inicial do banco de dados

Em **outro terminal**, na pasta `chatwoot-dev`:

```bash
# Criar banco de dados
docker compose exec rails bundle exec rails db:create

# Carregar schema
docker compose exec rails bundle exec rails db:schema:load

# Popular com dados iniciais
docker compose exec rails bundle exec rails db:seed
```

### 5. Aplicar patches de tradução (opcional)

Os patches de tradução PT-BR são aplicados automaticamente no build da imagem. Para desenvolvimento local, você pode:

**Opção A - Aplicar patches manualmente:**
```bash
# Entrar no container Rails
docker compose exec rails bash

# Dentro do container, aplicar cada patch:
cd /app
git apply /caminho/para/patches/01-super-admin-login-pt-br.patch
git apply /caminho/para/patches/02-onboarding-pt-br.patch
# ... etc
exit
```

**Opção B - Usar a imagem buildada:**
```bash
# Buildar a imagem V4 Connect e usar ela no docker-compose
# (modifique docker-compose.yml para usar a imagem local)
```

### 6. Criar usuário Super Admin

Volte para a pasta `v4-connect-chatwoot` e execute:

```bash
# Usando variáveis de ambiente personalizadas
ADMIN_EMAIL="seu.email@empresa.com" \
ADMIN_NAME="Seu Nome" \
ADMIN_PASSWORD="SuaSenhaSegura123" \
./scripts/apply_super_admin.sh --container chatwoot-dev-rails-1

# Ou usar os valores padrão do script
./scripts/apply_super_admin.sh --container chatwoot-dev-rails-1
```

### 7. Aplicar branding no banco de dados

```bash
# Configurar branding (logos, nome, cores)
./scripts/apply_branding.sh --container chatwoot-dev-rails-1

# Ou customizar o nome da instalação
INSTALLATION_NAME="Minha Empresa" \
./scripts/apply_branding.sh --container chatwoot-dev-rails-1
```

### 8. Acessar a aplicação

- **Rails (Backend + Frontend)**: http://localhost:3000
- **Vite HMR (Hot Module Replacement)**: http://localhost:3036/vite-dev/
- **Mailhog (Emails de teste)**: http://localhost:8025

### 9. Login

Acesse http://localhost:3000 e faça login com as credenciais do super admin criadas no passo 6.

### 10. Desenvolvimento

Agora você pode editar arquivos e ver as mudanças em tempo real:

- **Arquivos Vue/JS**: Recarregamento automático via Vite HMR
- **Arquivos ERB**: Recarregar a página no navegador
- **Arquivos Ruby (controllers, models)**: Reiniciar o container Rails

```bash
# Para reiniciar apenas o Rails após mudanças em Ruby
docker compose restart rails
```

### Estrutura de diretórios esperada

```
seu-workspace/
├── v4-connect-chatwoot/     # Este repositório
│   ├── branding/
│   ├── patches/
│   ├── scripts/
│   └── build_v4_connect_image.sh
│
└── chatwoot-dev/            # Clone do Chatwoot oficial
    ├── app/
    ├── public/
    │   └── brand-assets/    # ← Branding copiado aqui
    ├── docker-compose.yaml
    └── .env                 # ← Configurado no passo 2
```

## Deploy

### Via GHCR (Recomendado)

```bash
# Deploy da última versão
./scripts/deploy.sh

# Deploy de uma tag específica
./scripts/deploy.sh -t v4.8.0

# Ver status dos serviços
./scripts/deploy.sh -s

# Rollback para versão anterior
./scripts/deploy.sh -r
```

### Via Imagem Local

```bash
# Usar imagem buildada localmente
./scripts/deploy.sh -l
```

### Manual com Docker Swarm

```bash
# Pull da imagem do GHCR
docker pull ghcr.io/badwolf1509/v4-connect-chatwoot:latest

# Atualizar serviços
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-web
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-worker
```

## Versionamento

Para criar uma release:

```bash
# Na branch main
git tag v4.8.0-v4connect-1
git push origin v4.8.0-v4connect-1
```

O GitHub Actions irá:
1. Buildar a imagem
2. Fazer push para GHCR com a tag de versão
3. Manter a tag `latest` apontando para main

## Configuração

### Aplicar Branding no Banco

Use o script `apply_branding.sh` para configurar branding após deploy:

```bash
# Ver SQL sem executar
./scripts/apply_branding.sh --dry-run

# Aplicar via container Docker
./scripts/apply_branding.sh --container chatwoot_chatwoot-web

# Customizar nome da instalação
INSTALLATION_NAME="Minha Empresa" ./scripts/apply_branding.sh --container chatwoot_chatwoot-web
```

### Variáveis de Ambiente

Configure `INSTALLATION_NAME` no banco de dados para personalizar o nome exibido:

```sql
UPDATE installation_configs
SET serialized_value = '"V4 Connect"'
WHERE name = 'INSTALLATION_NAME';
```

## Imagens Docker

| Registry | Imagem |
|----------|--------|
| GHCR | `ghcr.io/badwolf1509/v4-connect-chatwoot:latest` |
| Local | `v4-connect/chatwoot:v4.8.0-branded` |

## Baseado no Chatwoot

- Versão base: v4.8.0
- Repositório original: https://github.com/chatwoot/chatwoot
