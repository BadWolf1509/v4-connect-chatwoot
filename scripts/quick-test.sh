#!/bin/bash
#
# V4 Connect - Quick Test Script
# Testa alterações rapidamente sem rebuild completo
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "  V4 Connect - Quick Test"
echo "============================================"
echo ""

# Validar patch
echo "→ Validando patch file..."
if [ -f "${PROJECT_DIR}/patches/v4-connect.patch" ]; then
    echo "✓ Patch file encontrado"
else
    echo "✗ Patch file não encontrado!"
    exit 1
fi

# Validar branding assets
echo "→ Validando branding assets..."
REQUIRED_FILES=(
    "logo.svg"
    "logo_dark.svg"
    "logo_dark.png"
    "logo_thumbnail.svg"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${PROJECT_DIR}/branding/${file}" ]; then
        echo "  ✓ ${file}"
    else
        echo "  ✗ ${file} não encontrado!"
        exit 1
    fi
done

# Validar build script
echo "→ Validando build script..."
if bash -n "${PROJECT_DIR}/build_v4_connect_image.sh"; then
    echo "✓ Build script válido (sintaxe OK)"
else
    echo "✗ Erro de sintaxe no build script!"
    exit 1
fi

# Validar workflow
echo "→ Validando GitHub workflow..."
if [ -f "${PROJECT_DIR}/.github/workflows/build.yml" ]; then
    echo "✓ Workflow file encontrado"
else
    echo "✗ Workflow file não encontrado!"
    exit 1
fi

echo ""
echo "============================================"
echo "  Todos os testes passaram!"
echo "============================================"
echo ""
echo "Próximos passos:"
echo "  1. git add -A && git commit -m 'sua mensagem'"
echo "  2. git push origin develop  # para testar build"
echo "  3. git checkout main && git merge develop  # para deploy"
echo "  4. git push origin main"
echo ""
