#!/bin/bash
#
# V4 Connect - Apply Branding Script
# Aplica configurações de branding no banco de dados do Chatwoot
#
# Uso:
#   ./apply_branding.sh                    # usa variáveis de ambiente
#   ./apply_branding.sh --container NAME   # executa dentro do container
#   ./apply_branding.sh --dry-run          # mostra SQL sem executar
#

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações padrão (podem ser sobrescritas por variáveis de ambiente)
INSTALLATION_NAME="${INSTALLATION_NAME:-V4 Connect}"
LOGO_URL="${LOGO_URL:-/brand-assets/logo.svg}"
LOGO_DARK_URL="${LOGO_DARK_URL:-/brand-assets/logo_dark.svg}"
LOGO_THUMBNAIL_URL="${LOGO_THUMBNAIL_URL:-/brand-assets/logo_thumbnail.svg}"
FAVICON_URL="${FAVICON_URL:-/brand-assets/favicon-32x32.png}"
DEFAULT_LOCALE="${DEFAULT_LOCALE:-pt_BR}"
WIDGET_BRAND_URL="${WIDGET_BRAND_URL:-https://v4company.com}"

# Variáveis de conexão
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_DATABASE="${POSTGRES_DATABASE:-chatwoot_production}"
POSTGRES_USERNAME="${POSTGRES_USERNAME:-chatwoot}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"

# Flags
DRY_RUN=false
USE_CONTAINER=""
SHOW_HELP=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --container)
            USE_CONTAINER="$2"
            shift 2
            ;;
        -h|--help)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo -e "${RED}Argumento desconhecido: $1${NC}"
            exit 1
            ;;
    esac
done

if [ "$SHOW_HELP" = true ]; then
    cat << 'EOF'
V4 Connect - Apply Branding Script

Aplica configurações de branding no banco de dados do Chatwoot.

USO:
    ./apply_branding.sh [opções]

OPÇÕES:
    --dry-run           Mostra o SQL que seria executado sem executar
    --container NAME    Executa o SQL dentro do container Docker especificado
    -h, --help          Mostra esta ajuda

VARIÁVEIS DE AMBIENTE:
    INSTALLATION_NAME   Nome da instalação (padrão: "V4 Connect")
    LOGO_URL            URL do logo claro (padrão: /brand-assets/logo.svg)
    LOGO_DARK_URL       URL do logo escuro (padrão: /brand-assets/logo_dark.svg)
    LOGO_THUMBNAIL_URL  URL do thumbnail (padrão: /brand-assets/logo_thumbnail.svg)
    FAVICON_URL         URL do favicon (padrão: /brand-assets/favicon-32x32.png)
    DEFAULT_LOCALE      Idioma padrão (padrão: pt_BR)
    WIDGET_BRAND_URL    URL do link "Powered by" (padrão: https://v4company.com)

    POSTGRES_HOST       Host do PostgreSQL (padrão: localhost)
    POSTGRES_PORT       Porta do PostgreSQL (padrão: 5432)
    POSTGRES_DATABASE   Nome do banco (padrão: chatwoot_production)
    POSTGRES_USERNAME   Usuário do banco (padrão: chatwoot)
    POSTGRES_PASSWORD   Senha do banco

EXEMPLOS:
    # Aplicar branding localmente
    export POSTGRES_PASSWORD=minhasenha
    ./apply_branding.sh

    # Ver SQL sem executar
    ./apply_branding.sh --dry-run

    # Executar dentro de um container
    ./apply_branding.sh --container chatwoot_chatwoot-web

    # Customizar nome
    INSTALLATION_NAME="Minha Empresa" ./apply_branding.sh
EOF
    exit 0
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  V4 Connect - Apply Branding${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Gerar SQL
SQL=$(cat << EOSQL
-- V4 Connect Branding Configuration
-- Gerado em: $(date -Iseconds)

-- Configurações de instalação
INSERT INTO installation_configs (name, serialized_value, created_at, updated_at)
VALUES
    ('INSTALLATION_NAME', '"${INSTALLATION_NAME}"', NOW(), NOW()),
    ('LOGO', '"${LOGO_URL}"', NOW(), NOW()),
    ('LOGO_DARK', '"${LOGO_DARK_URL}"', NOW(), NOW()),
    ('LOGO_THUMBNAIL', '"${LOGO_THUMBNAIL_URL}"', NOW(), NOW()),
    ('FAVICON', '"${FAVICON_URL}"', NOW(), NOW()),
    ('DEFAULT_LOCALE', '"${DEFAULT_LOCALE}"', NOW(), NOW()),
    ('WIDGET_BRAND_URL', '"${WIDGET_BRAND_URL}"', NOW(), NOW())
ON CONFLICT (name) DO UPDATE SET
    serialized_value = EXCLUDED.serialized_value,
    updated_at = NOW();

-- Atualizar locale padrão em contas existentes (opcional)
-- UPDATE accounts SET locale = '${DEFAULT_LOCALE}' WHERE locale IS NULL OR locale = 'en';

-- Limpar cache de configurações
DELETE FROM global_config WHERE key LIKE 'installation_%';
EOSQL
)

echo -e "${YELLOW}Configurações a serem aplicadas:${NC}"
echo "  INSTALLATION_NAME: ${INSTALLATION_NAME}"
echo "  LOGO_URL: ${LOGO_URL}"
echo "  LOGO_DARK_URL: ${LOGO_DARK_URL}"
echo "  LOGO_THUMBNAIL_URL: ${LOGO_THUMBNAIL_URL}"
echo "  FAVICON_URL: ${FAVICON_URL}"
echo "  DEFAULT_LOCALE: ${DEFAULT_LOCALE}"
echo "  WIDGET_BRAND_URL: ${WIDGET_BRAND_URL}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}=== DRY RUN - SQL que seria executado ===${NC}"
    echo "$SQL"
    echo -e "${YELLOW}=========================================${NC}"
    exit 0
fi

# Executar SQL
if [ -n "$USE_CONTAINER" ]; then
    echo -e "${BLUE}Executando dentro do container: ${USE_CONTAINER}${NC}"

    # Verificar se container existe
    if ! docker ps --format '{{.Names}}' | grep -q "^${USE_CONTAINER}$"; then
        echo -e "${RED}Container '${USE_CONTAINER}' não encontrado ou não está rodando${NC}"
        echo "Containers disponíveis:"
        docker ps --format '  - {{.Names}}'
        exit 1
    fi

    # Executar via rails runner no container
    docker exec -i "$USE_CONTAINER" rails runner "
        configs = {
            'INSTALLATION_NAME' => '${INSTALLATION_NAME}',
            'LOGO' => '${LOGO_URL}',
            'LOGO_DARK' => '${LOGO_DARK_URL}',
            'LOGO_THUMBNAIL' => '${LOGO_THUMBNAIL_URL}',
            'FAVICON' => '${FAVICON_URL}',
            'DEFAULT_LOCALE' => '${DEFAULT_LOCALE}',
            'WIDGET_BRAND_URL' => '${WIDGET_BRAND_URL}'
        }

        configs.each do |key, value|
            config = InstallationConfig.find_or_initialize_by(name: key)
            config.value = value
            config.save!
            puts \"  ✓ #{key} = #{value}\"
        end

        GlobalConfig.clear_cache
        puts ''
        puts 'Cache limpo com sucesso!'
    "
else
    echo -e "${BLUE}Executando via psql...${NC}"

    if [ -z "$POSTGRES_PASSWORD" ]; then
        echo -e "${RED}POSTGRES_PASSWORD não definida${NC}"
        echo "Use: export POSTGRES_PASSWORD=suasenha"
        exit 1
    fi

    export PGPASSWORD="$POSTGRES_PASSWORD"
    psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USERNAME" -d "$POSTGRES_DATABASE" << EOSQL
$SQL
EOSQL
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Branding aplicado com sucesso!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}Próximos passos:${NC}"
echo "  1. Reinicie os serviços do Chatwoot para aplicar as mudanças"
echo "  2. Limpe o cache do navegador (Ctrl+Shift+R)"
echo ""
