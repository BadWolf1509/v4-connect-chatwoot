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
├── custom/
│   ├── locales/           # Traduções PT-BR
│   ├── stylesheets/       # CSS customizado
│   └── views/             # Templates modificados
├── patches/               # Diffs de código
├── docker/                # Configurações Docker
├── build_v4_connect_image.sh  # Script de build principal
└── .env.example
```

## Build da Imagem

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

### Deploy com Docker Swarm

```bash
# Atualizar serviços
docker service update --image v4-connect/chatwoot:v4.8.0-branded chatwoot_chatwoot-web
docker service update --image v4-connect/chatwoot:v4.8.0-branded chatwoot_chatwoot-worker
```

## Configuração

### Variáveis de Ambiente

Configure `INSTALLATION_NAME` no banco de dados para personalizar o nome exibido:

```sql
UPDATE installation_configs
SET serialized_value = '"V4 Connect"'
WHERE name = 'INSTALLATION_NAME';
```

## Baseado no Chatwoot

- Versão base: v4.8.0
- Repositório original: https://github.com/chatwoot/chatwoot
