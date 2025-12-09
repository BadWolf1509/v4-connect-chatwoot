#!/bin/bash
#
# V4 Connect - Deploy Script
# Faz pull da imagem do GHCR e atualiza os serviços Docker Swarm
#

set -e

# Configurações
REGISTRY="ghcr.io"
IMAGE_NAME="badwolf1509/v4-connect-chatwoot"
DEFAULT_TAG="latest"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  V4 Connect - Deploy Script${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}→ $1${NC}"
}

show_help() {
    echo "Uso: $0 [opções]"
    echo ""
    echo "Opções:"
    echo "  -t, --tag TAG     Tag da imagem a ser deployada (default: latest)"
    echo "  -l, --local       Usar imagem local ao invés de pull do GHCR"
    echo "  -r, --rollback    Rollback para a imagem anterior"
    echo "  -s, --status      Mostrar status dos serviços"
    echo "  -h, --help        Mostrar esta ajuda"
    echo ""
    echo "Exemplos:"
    echo "  $0                    # Deploy da tag 'latest'"
    echo "  $0 -t v4.8.0          # Deploy da tag 'v4.8.0'"
    echo "  $0 -l                 # Deploy usando imagem local"
    echo "  $0 -s                 # Mostrar status"
}

show_status() {
    print_header
    print_info "Status dos serviços Chatwoot:"
    echo ""
    docker service ls --filter "name=chatwoot" --format "table {{.Name}}\t{{.Replicas}}\t{{.Image}}"
    echo ""
    print_info "Containers em execução:"
    docker ps --filter "name=chatwoot" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

pull_image() {
    local tag=$1
    local full_image="${REGISTRY}/${IMAGE_NAME}:${tag}"

    print_info "Fazendo pull da imagem: ${full_image}"

    if docker pull "${full_image}"; then
        print_success "Pull concluído com sucesso"

        # Tag local para facilitar uso
        docker tag "${full_image}" "v4-connect/chatwoot:${tag}"
        print_success "Tag local criada: v4-connect/chatwoot:${tag}"
    else
        print_error "Falha no pull da imagem"
        exit 1
    fi
}

deploy_services() {
    local image=$1

    print_info "Atualizando serviços com imagem: ${image}"
    echo ""

    # Update web service
    print_info "Atualizando chatwoot_chatwoot-web..."
    if docker service update --image "${image}" chatwoot_chatwoot-web; then
        print_success "chatwoot_chatwoot-web atualizado"
    else
        print_error "Falha ao atualizar chatwoot_chatwoot-web"
        exit 1
    fi

    # Update worker service
    print_info "Atualizando chatwoot_chatwoot-worker..."
    if docker service update --image "${image}" chatwoot_chatwoot-worker; then
        print_success "chatwoot_chatwoot-worker atualizado"
    else
        print_error "Falha ao atualizar chatwoot_chatwoot-worker"
        exit 1
    fi

    echo ""
    print_success "Deploy concluído!"
}

rollback_services() {
    print_info "Executando rollback dos serviços..."
    echo ""

    docker service rollback chatwoot_chatwoot-web
    docker service rollback chatwoot_chatwoot-worker

    print_success "Rollback concluído!"
}

# Parse argumentos
TAG="${DEFAULT_TAG}"
USE_LOCAL=false
DO_ROLLBACK=false
SHOW_STATUS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--tag)
            TAG="$2"
            shift 2
            ;;
        -l|--local)
            USE_LOCAL=true
            shift
            ;;
        -r|--rollback)
            DO_ROLLBACK=true
            shift
            ;;
        -s|--status)
            SHOW_STATUS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            print_error "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Executar ação
print_header

if [ "$SHOW_STATUS" = true ]; then
    show_status
    exit 0
fi

if [ "$DO_ROLLBACK" = true ]; then
    rollback_services
    show_status
    exit 0
fi

if [ "$USE_LOCAL" = true ]; then
    IMAGE="v4-connect/chatwoot:v4.8.0-branded"
    print_info "Usando imagem local: ${IMAGE}"
else
    pull_image "${TAG}"
    IMAGE="v4-connect/chatwoot:${TAG}"
fi

deploy_services "${IMAGE}"
echo ""
show_status
