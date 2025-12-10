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
├── .github/workflows/         # CI/CD automático
├── branding/                  # Logos e favicons
├── docker/
│   └── docker-compose.yml     # Stack local de desenvolvimento
├── patches/                   # Patches de código
│   ├── 01-super-admin-login-pt-br.patch
│   ├── 02-onboarding-pt-br.patch
│   ├── 03-super-admin-navigation-pt-br.patch
│   ├── 04-locale-pt-br.patch
│   └── 05-colors-v4-red.patch
├── scripts/
│   ├── apply_branding.sh      # Aplicar branding no banco
│   ├── deploy.sh              # Deploy na VPS
│   └── quick-test.sh          # Validação rápida
├── build_v4_connect_image.sh  # Script de build principal
├── .env.example
└── README.md
```

## Workflow de Desenvolvimento

### Fluxo Recomendado

```
┌─────────────────────────────────────────────────────────────────┐
│  1. DESENVOLVIMENTO RÁPIDO (Hot-reload)                         │
│     ├── Clone Chatwoot original (v4.8.0) em pasta separada     │
│     ├── git apply patches/*.patch                               │
│     ├── Rode Rails + Vite dev server                            │
│     └── Itere com hot-reload                                    │
├─────────────────────────────────────────────────────────────────┤
│  2. GERAR PATCHES                                               │
│     ├── Faça alterações no clone do Chatwoot                   │
│     ├── git diff > ../v4-connect-chatwoot/patches/novo.patch   │
│     └── Ou edite os patches existentes                          │
├─────────────────────────────────────────────────────────────────┤
│  3. VALIDAR                                                     │
│     ├── ./scripts/quick-test.sh        # Validação rápida       │
│     └── ./scripts/quick-test.sh --full # Com teste de patch    │
├─────────────────────────────────────────────────────────────────┤
│  4. BUILD & TESTE                                               │
│     ├── ./build_v4_connect_image.sh                             │
│     └── docker-compose -f docker/docker-compose.yml up          │
├─────────────────────────────────────────────────────────────────┤
│  5. COMMIT & PR                                                 │
│     ├── git checkout -b feature/minha-feature                   │
│     ├── git push origin feature/minha-feature                   │
│     └── Criar PR para develop                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Branches

| Branch | Propósito | Build | Push GHCR |
|--------|-----------|-------|-----------|
| `main` | Produção | ✅ | ✅ |
| `develop` | Desenvolvimento | ✅ | ❌ |
| `feature/*` | Features | Via PR | ❌ |

## Scripts

### build_v4_connect_image.sh

Constrói a imagem Docker customizada.

```bash
# Build padrão (v4.8.0)
./build_v4_connect_image.sh

# Versão específica
CHATWOOT_VERSION=v4.9.0 ./build_v4_connect_image.sh

# Sem cache Docker (para build final)
NO_CACHE=true ./build_v4_connect_image.sh
```

### scripts/quick-test.sh

Valida patches, assets e scripts antes do build.

```bash
# Validação rápida
./scripts/quick-test.sh

# Validação completa (aplica patches em clone temporário)
./scripts/quick-test.sh --full
```

### scripts/apply_branding.sh

Aplica configurações de branding no banco de dados.

```bash
# Ver SQL sem executar
./scripts/apply_branding.sh --dry-run

# Aplicar via container Docker
./scripts/apply_branding.sh --container chatwoot_chatwoot-web

# Customizar nome
INSTALLATION_NAME="Minha Empresa" ./scripts/apply_branding.sh --container chatwoot_chatwoot-web
```

### scripts/deploy.sh

Deploy na VPS (Docker Swarm).

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

## Desenvolvimento Local

### Stack de Desenvolvimento (Docker)

```bash
# Subir stack local
docker-compose -f docker/docker-compose.yml up -d

# Aplicar branding
./scripts/apply_branding.sh --container v4-connect-chatwoot-chatwoot-web-1

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f
```

### Desenvolvimento com Hot-Reload (Recomendado)

Para iterar rapidamente sem rebuildar Docker:

```bash
# 1. Clone Chatwoot em pasta separada
git clone --branch v4.8.0 https://github.com/chatwoot/chatwoot.git ../chatwoot-dev
cd ../chatwoot-dev

# 2. Aplique os patches
git apply ../v4-connect-chatwoot/patches/*.patch

# 3. Copie os assets
cp -r ../v4-connect-chatwoot/branding/* public/brand-assets/

# 4. Configure ambiente
cp .env.example .env
# Edite .env com suas configurações

# 5. Instale dependências
bundle install
yarn install

# 6. Rode o servidor de desenvolvimento
foreman start -f Procfile.dev
# Ou separadamente:
# Terminal 1: bundle exec rails s
# Terminal 2: bin/vite dev
```

## Patches

Os patches são aplicados em ordem numérica durante o build:

| Patch | Descrição |
|-------|-----------|
| `01-super-admin-login-pt-br.patch` | Traduz tela de login do Super Admin |
| `02-onboarding-pt-br.patch` | Traduz tela de onboarding |
| `03-super-admin-navigation-pt-br.patch` | Traduz navegação do Super Admin |
| `04-locale-pt-br.patch` | Adiciona locale PT-BR para Administrate |
| `05-colors-v4-red.patch` | Paleta de cores vermelha V4 |

### Criando Novos Patches

```bash
# No clone de desenvolvimento
cd ../chatwoot-dev

# Faça suas alterações...

# Gere o patch
git diff > ../v4-connect-chatwoot/patches/XX-descricao.patch

# Ou para alterações já commitadas
git format-patch -1 HEAD --stdout > ../v4-connect-chatwoot/patches/XX-descricao.patch
```

## Dicas de Eficiência

1. **Evite `--no-cache`** durante desenvolvimento local; reserve para build final
2. **Patches pequenos e idempotentes** facilitam upgrades de versão
3. **Prefira `git apply`** a grandes blocos de `sed`
4. **Limite testes** ao que mexeu (linters/rspec/JS unit)
5. **Build completo** só antes de PR ou gerar imagem

## Deploy em Produção

### Via GHCR (Recomendado)

```bash
# Pull e deploy
./scripts/deploy.sh

# Aplicar branding pós-deploy
./scripts/apply_branding.sh --container chatwoot_chatwoot-web
```

### Manual com Docker Swarm

```bash
# Pull da imagem
docker pull ghcr.io/badwolf1509/v4-connect-chatwoot:latest

# Atualizar serviços
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-web
docker service update --image ghcr.io/badwolf1509/v4-connect-chatwoot:latest chatwoot_chatwoot-worker
```

## Versionamento

```bash
# Criar release
git tag v4.8.0-v4connect-1
git push origin v4.8.0-v4connect-1
```

O GitHub Actions automaticamente:
1. Builda a imagem
2. Push para GHCR com tag de versão
3. Atualiza tag `latest`

## Imagens Docker

| Registry | Imagem |
|----------|--------|
| GHCR | `ghcr.io/badwolf1509/v4-connect-chatwoot:latest` |
| Local | `v4-connect/chatwoot:v4.8.0-branded` |

## Baseado no Chatwoot

- **Versão base**: v4.8.0
- **Repositório original**: https://github.com/chatwoot/chatwoot
