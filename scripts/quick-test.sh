#!/bin/bash
#
# V4 Connect - Quick Test Script
# Testa alterações rapidamente sem rebuild completo
#
# Uso:
#   ./quick-test.sh           # executa todos os testes
#   ./quick-test.sh --full    # inclui teste de aplicação do patch (requer git)
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Flags
FULL_TEST=false
ERRORS=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --full)
            FULL_TEST=true
            shift
            ;;
        -h|--help)
            echo "V4 Connect - Quick Test"
            echo ""
            echo "Uso: ./quick-test.sh [opções]"
            echo ""
            echo "Opções:"
            echo "  --full    Inclui teste de aplicação do patch (clona Chatwoot temporário)"
            echo "  -h        Mostra esta ajuda"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  V4 Connect - Quick Test${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# Função para registrar erro sem parar
check_error() {
    if [ $? -ne 0 ]; then
        echo -e "  ${RED}✗ $1${NC}"
        ((ERRORS++))
        return 1
    fi
    return 0
}

# 1. Validar patch files
echo -e "${YELLOW}→ Validando patch files...${NC}"
PATCH_DIR="${PROJECT_DIR}/patches"
if [ -d "$PATCH_DIR" ] && [ "$(ls -A "$PATCH_DIR"/*.patch 2>/dev/null)" ]; then
    for patch in "$PATCH_DIR"/*.patch; do
        patch_name=$(basename "$patch")
        # Verificar se não está vazio
        if [ -s "$patch" ]; then
            # Verificar formato básico do patch
            if head -1 "$patch" | grep -qE "^(diff|---|\+\+\+|@@)"; then
                echo -e "  ${GREEN}✓${NC} ${patch_name} ($(wc -l < "$patch") linhas)"
            else
                echo -e "  ${RED}✗${NC} ${patch_name} - formato inválido"
                ((ERRORS++))
            fi
        else
            echo -e "  ${RED}✗${NC} ${patch_name} - arquivo vazio"
            ((ERRORS++))
        fi
    done
else
    echo -e "  ${RED}✗ Nenhum patch encontrado em patches/${NC}"
    ((ERRORS++))
fi

# 2. Validar branding assets
echo ""
echo -e "${YELLOW}→ Validando branding assets...${NC}"
REQUIRED_ASSETS=(
    "logo.svg"
    "logo_dark.svg"
    "logo_dark.png"
    "logo_thumbnail.svg"
    "favicon-32x32.png"
)

for file in "${REQUIRED_ASSETS[@]}"; do
    if [ -f "${PROJECT_DIR}/branding/${file}" ]; then
        size=$(wc -c < "${PROJECT_DIR}/branding/${file}")
        echo -e "  ${GREEN}✓${NC} ${file} (${size} bytes)"
    else
        echo -e "  ${RED}✗${NC} ${file} não encontrado"
        ((ERRORS++))
    fi
done

# 3. Validar scripts
echo ""
echo -e "${YELLOW}→ Validando scripts...${NC}"
SCRIPTS=(
    "build_v4_connect_image.sh"
    "scripts/quick-test.sh"
    "scripts/deploy.sh"
    "scripts/apply_branding.sh"
)

for script in "${SCRIPTS[@]}"; do
    script_path="${PROJECT_DIR}/${script}"
    if [ -f "$script_path" ]; then
        if bash -n "$script_path" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} ${script} (sintaxe OK)"
        else
            echo -e "  ${RED}✗${NC} ${script} - erro de sintaxe"
            ((ERRORS++))
        fi
    else
        echo -e "  ${YELLOW}⚠${NC} ${script} não encontrado"
    fi
done

# 4. Validar GitHub workflow
echo ""
echo -e "${YELLOW}→ Validando GitHub workflow...${NC}"
WORKFLOW="${PROJECT_DIR}/.github/workflows/build.yml"
if [ -f "$WORKFLOW" ]; then
    # Verificar YAML básico (indentação consistente)
    if python3 -c "import yaml; yaml.safe_load(open('$WORKFLOW'))" 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} build.yml (YAML válido)"
    elif command -v yq &>/dev/null && yq '.' "$WORKFLOW" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} build.yml (YAML válido)"
    else
        # Fallback: verificar apenas se arquivo existe e não está vazio
        if [ -s "$WORKFLOW" ]; then
            echo -e "  ${GREEN}✓${NC} build.yml (arquivo presente)"
        else
            echo -e "  ${RED}✗${NC} build.yml - arquivo vazio"
            ((ERRORS++))
        fi
    fi
else
    echo -e "  ${RED}✗${NC} .github/workflows/build.yml não encontrado"
    ((ERRORS++))
fi

# 5. Validar docker-compose
echo ""
echo -e "${YELLOW}→ Validando Docker files...${NC}"
DOCKER_COMPOSE="${PROJECT_DIR}/docker/docker-compose.yml"
if [ -f "$DOCKER_COMPOSE" ]; then
    if command -v docker-compose &>/dev/null; then
        if docker-compose -f "$DOCKER_COMPOSE" config -q 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} docker/docker-compose.yml (válido)"
        else
            echo -e "  ${YELLOW}⚠${NC} docker/docker-compose.yml (não foi possível validar)"
        fi
    else
        echo -e "  ${GREEN}✓${NC} docker/docker-compose.yml (arquivo presente)"
    fi
else
    echo -e "  ${RED}✗${NC} docker/docker-compose.yml não encontrado"
    ((ERRORS++))
fi

# 6. Validar .env.example
echo ""
echo -e "${YELLOW}→ Validando configuração...${NC}"
if [ -f "${PROJECT_DIR}/.env.example" ]; then
    # Verificar variáveis essenciais
    REQUIRED_VARS=("SECRET_KEY_BASE" "POSTGRES_HOST" "REDIS_URL")
    missing=0
    for var in "${REQUIRED_VARS[@]}"; do
        if ! grep -q "^${var}=" "${PROJECT_DIR}/.env.example"; then
            echo -e "  ${YELLOW}⚠${NC} ${var} não encontrada em .env.example"
            ((missing++))
        fi
    done
    if [ $missing -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} .env.example (variáveis essenciais presentes)"
    fi
else
    echo -e "  ${RED}✗${NC} .env.example não encontrado"
    ((ERRORS++))
fi

# 7. Teste completo (aplicar patch em clone temporário)
if [ "$FULL_TEST" = true ]; then
    echo ""
    echo -e "${YELLOW}→ Teste completo: aplicando patch em clone temporário...${NC}"

    CHATWOOT_VERSION="v4.8.0"
    TEMP_DIR=$(mktemp -d)

    cleanup() {
        rm -rf "$TEMP_DIR"
    }
    trap cleanup EXIT

    echo "  Clonando Chatwoot ${CHATWOOT_VERSION}..."
    if git clone --depth 1 --branch "$CHATWOOT_VERSION" \
        https://github.com/chatwoot/chatwoot.git "$TEMP_DIR/chatwoot" 2>/dev/null; then

        cd "$TEMP_DIR/chatwoot"

        echo "  Aplicando patches..."
        for patch in "$PATCH_DIR"/*.patch; do
            patch_name=$(basename "$patch")
            if git apply --check "$patch" 2>/dev/null; then
                git apply "$patch"
                echo -e "  ${GREEN}✓${NC} ${patch_name} aplicado com sucesso"
            else
                echo -e "  ${RED}✗${NC} ${patch_name} falhou ao aplicar"
                ((ERRORS++))
            fi
        done

        cd "$PROJECT_DIR"
    else
        echo -e "  ${RED}✗${NC} Falha ao clonar Chatwoot"
        ((ERRORS++))
    fi
fi

# Resultado final
echo ""
echo -e "${BLUE}============================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  ✓ Todos os testes passaram!${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Próximos passos:"
    echo "  1. git add -A && git commit -m 'sua mensagem'"
    echo "  2. git push origin develop  # para testar build"
    echo "  3. Abrir PR: develop → main"
    echo "  4. Após merge, a imagem será publicada no GHCR"
    echo ""
    exit 0
else
    echo -e "${RED}  ✗ ${ERRORS} erro(s) encontrado(s)${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    echo "Corrija os erros acima antes de continuar."
    echo ""
    exit 1
fi
