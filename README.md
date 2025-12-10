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
