# Integração Evolution API + V4 Connect

Guia completo para integrar o Evolution API ao V4 Connect (Chatwoot), permitindo atendimento via WhatsApp.

## Índice

- [Visão Geral](#visão-geral)
- [Pré-requisitos](#pré-requisitos)
- [Arquitetura](#arquitetura)
- [Configuração Passo a Passo](#configuração-passo-a-passo)
- [Parâmetros de Configuração](#parâmetros-de-configuração)
- [Testando a Integração](#testando-a-integração)
- [Múltiplas Instâncias](#múltiplas-instâncias)
- [Troubleshooting](#troubleshooting)
- [Referências](#referências)

---

## Visão Geral

O **Evolution API** é uma API open-source para WhatsApp que possui integração nativa com o Chatwoot. Esta integração permite:

- Receber mensagens do WhatsApp diretamente no V4 Connect
- Responder clientes pelo painel de atendimento
- Sincronizar contatos e histórico de mensagens
- Gerenciar múltiplos números de WhatsApp
- Assinatura automática do atendente nas mensagens

### Tipos de Conexão Suportados

| Tipo | Descrição | Custo |
|------|-----------|-------|
| **Baileys** | Baseado no WhatsApp Web (biblioteca Baileys) | Gratuito |
| **Cloud API** | API oficial da Meta (WhatsApp Business) | Pago por mensagem |

---

## Pré-requisitos

### No servidor Evolution API

- [ ] Evolution API v2.x instalado e rodando
- [ ] Instância WhatsApp criada e conectada (QR Code escaneado)
- [ ] API Key do Evolution configurada
- [ ] URL do Evolution acessível (ex: `https://evolution.seudominio.com`)

### No V4 Connect

- [ ] V4 Connect instalado e rodando
- [ ] **Usuário Administrador** criado (NÃO usar Super Admin)
- [ ] Token de acesso do administrador (Access Token)
- [ ] Account ID da conta onde será criado o inbox
- [ ] Nginx configurado com `underscores_in_headers on;`
- [ ] Variável `FRONTEND_URL` configurada no worker

---

## Arquitetura

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│                 │     │                 │     │                 │
│    WhatsApp     │◄───►│  Evolution API  │◄───►│   V4 Connect    │
│                 │     │                 │     │   (Chatwoot)    │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                              │
                              ▼
                        ┌───────────┐
                        │  Webhooks │
                        │ (eventos) │
                        └───────────┘
```

### Fluxo de Mensagens

**Mensagem Recebida (Cliente → Atendente):**
1. Cliente envia mensagem no WhatsApp
2. Evolution API recebe via Baileys/Cloud API
3. Evolution envia webhook para V4 Connect
4. Mensagem aparece na conversa do atendente

**Mensagem Enviada (Atendente → Cliente):**
1. Atendente responde no V4 Connect
2. V4 Connect envia para webhook do Evolution
3. Evolution processa e envia para WhatsApp
4. Cliente recebe a mensagem

---

## Configuração Passo a Passo

### Passo 1: Obter Credenciais do V4 Connect

#### 1.1 Obter o Account ID

1. Acesse o **Super Admin** do V4 Connect
2. Vá em **Contas** no menu lateral
3. Localize a conta desejada
4. Anote o **ID** da conta (número na primeira coluna)

```
Exemplo: Account ID = 1
```

#### 1.2 Obter o Token de Acesso

1. Faça login no V4 Connect com uma conta **Administrador**
2. Clique no ícone do perfil (canto inferior esquerdo)
3. Vá em **Configurações do Perfil**
4. Na seção **Token de Acesso**, clique em **Copiar**

```
Exemplo: Token = aBcDeFgHiJkLmNoPqRsTuVwXyZ123456
```

> **Importante:** Use o token de um usuário Administrador, não de um Agente comum.

### Passo 2: Verificar Instância no Evolution

Confirme que sua instância está conectada:

```bash
curl -X GET "https://evolution.seudominio.com/instance/connectionState/NOME_DA_INSTANCIA" \
  -H "apikey: SUA_API_KEY_EVOLUTION"
```

Resposta esperada:
```json
{
  "instance": "NOME_DA_INSTANCIA",
  "state": "open"
}
```

### Passo 3: Configurar Integração Chatwoot

Execute o seguinte comando para ativar a integração:

```bash
curl -X POST "https://evolution.seudominio.com/chatwoot/set/NOME_DA_INSTANCIA" \
  -H "apikey: SUA_API_KEY_EVOLUTION" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "accountId": "1",
    "token": "SEU_TOKEN_V4_CONNECT",
    "url": "https://v4connect.seudominio.com",
    "signMsg": true,
    "signDelimiter": "\n",
    "reopenConversation": true,
    "conversationPending": true,
    "autoCreate": true,
    "nameInbox": "WhatsApp Comercial",
    "importContacts": true,
    "importMessages": true,
    "daysLimitImportMessages": 3,
    "mergeBrazilContacts": true,
    "organization": "V4 Connect Bot",
    "logo": "https://v4connect.seudominio.com/brand-assets/logo_thumbnail.svg"
  }'
```

### Passo 4: Verificar Configuração

Confirme que a integração foi configurada:

```bash
curl -X GET "https://evolution.seudominio.com/chatwoot/find/NOME_DA_INSTANCIA" \
  -H "apikey: SUA_API_KEY_EVOLUTION"
```

Resposta esperada:
```json
{
  "enabled": true,
  "accountId": "1",
  "url": "https://v4connect.seudominio.com",
  "nameInbox": "WhatsApp Comercial",
  "signMsg": true,
  ...
}
```

### Passo 5: Verificar Inbox no V4 Connect

1. Acesse o V4 Connect
2. Vá em **Configurações → Caixas de Entrada**
3. Você verá um novo inbox chamado "WhatsApp Comercial" (ou o nome configurado)
4. O tipo será **API**

---

## Parâmetros de Configuração

### Parâmetros Obrigatórios

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `enabled` | boolean | Ativa (`true`) ou desativa (`false`) a integração |
| `accountId` | string | ID da conta no V4 Connect |
| `token` | string | Token de acesso do administrador |
| `url` | string | URL base do V4 Connect (**sem barra no final**) |

### Parâmetros de Comportamento

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `signMsg` | boolean | `false` | Adiciona assinatura do atendente nas mensagens |
| `signDelimiter` | string | `\n` | Separador entre assinatura e mensagem |
| `reopenConversation` | boolean | `false` | Reabre a mesma conversa ou cria nova |
| `conversationPending` | boolean | `false` | Inicia conversas como "Pendente" |
| `autoCreate` | boolean | `true` | Cria inbox automaticamente no Chatwoot |

### Parâmetros de Sincronização

| Parâmetro | Tipo | Padrão | Descrição |
|-----------|------|--------|-----------|
| `importContacts` | boolean | `false` | Importa contatos do WhatsApp |
| `importMessages` | boolean | `false` | Importa histórico de mensagens |
| `daysLimitImportMessages` | number | `3` | Dias de histórico para importar |
| `mergeBrazilContacts` | boolean | `false` | Unifica contatos BR com/sem 9º dígito |

### Parâmetros de Identificação

| Parâmetro | Tipo | Descrição |
|-----------|------|-----------|
| `nameInbox` | string | Nome do inbox no V4 Connect |
| `organization` | string | Nome do bot/contato no WhatsApp |
| `logo` | string | URL da imagem de perfil do bot |

---

## Testando a Integração

### Teste 1: Receber Mensagem

1. Envie uma mensagem de um celular qualquer para o número do WhatsApp conectado
2. No V4 Connect, vá em **Conversas**
3. A mensagem deve aparecer no inbox configurado

### Teste 2: Enviar Mensagem

1. No V4 Connect, abra uma conversa existente
2. Digite uma resposta e envie
3. Verifique se a mensagem chegou no WhatsApp do cliente

### Teste 3: Verificar Assinatura

Se `signMsg: true`, as mensagens enviadas devem ter o formato:

```
*Nome do Atendente*
Texto da mensagem aqui
```

---

## Múltiplas Instâncias

Você pode conectar vários números de WhatsApp ao mesmo V4 Connect.

### Opção A: Mesmo Account (Recomendado)

Todos os números aparecem como inboxes diferentes na mesma conta:

```bash
# Instância 1 - Vendas
curl -X POST "https://evolution.seudominio.com/chatwoot/set/whatsapp-vendas" \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "accountId": "1",
    "token": "TOKEN_ADMIN",
    "url": "https://v4connect.seudominio.com",
    "nameInbox": "WhatsApp Vendas",
    "autoCreate": true
  }'

# Instância 2 - Suporte
curl -X POST "https://evolution.seudominio.com/chatwoot/set/whatsapp-suporte" \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "enabled": true,
    "accountId": "1",
    "token": "TOKEN_ADMIN",
    "url": "https://v4connect.seudominio.com",
    "nameInbox": "WhatsApp Suporte",
    "autoCreate": true
  }'
```

### Opção B: Accounts Separados

Cada número em uma conta diferente (isolamento total):

```bash
# Empresa A (Account ID: 1)
curl -X POST "https://evolution.seudominio.com/chatwoot/set/empresa-a" \
  -d '{"accountId": "1", "nameInbox": "WhatsApp", ...}'

# Empresa B (Account ID: 2)
curl -X POST "https://evolution.seudominio.com/chatwoot/set/empresa-b" \
  -d '{"accountId": "2", "nameInbox": "WhatsApp", ...}'
```

---

## Troubleshooting

### Problema: Inbox não foi criado automaticamente

**Causa:** `autoCreate` está `false` ou houve erro de autenticação.

**Solução:**
1. Verifique se o token tem permissões de administrador
2. Verifique se a URL não tem barra no final
3. Crie o inbox manualmente:
   - V4 Connect → Configurações → Caixas de Entrada → Adicionar
   - Tipo: **API**
   - Nome: mesmo valor de `nameInbox`
   - Webhook URL: `https://evolution.seudominio.com/chatwoot/webhook/NOME_INSTANCIA`

### Problema: Mensagens não chegam no V4 Connect

**Verificações:**
```bash
# 1. Verificar se instância está conectada
curl -X GET "https://evolution.seudominio.com/instance/connectionState/NOME_INSTANCIA" \
  -H "apikey: SUA_API_KEY"

# 2. Verificar configuração do Chatwoot
curl -X GET "https://evolution.seudominio.com/chatwoot/find/NOME_INSTANCIA" \
  -H "apikey: SUA_API_KEY"

# 3. Verificar logs do Evolution
docker logs evolution-api --tail 100
```

**Soluções comuns:**
- Reconectar a instância (escanear QR Code novamente)
- Verificar se a URL do V4 Connect está acessível externamente
- Verificar certificado SSL válido

### Problema: Mensagens duplicadas

**Causa:** Webhook configurado duas vezes ou `reopenConversation: false`.

**Solução:**
```bash
# Reconfigurar com reopenConversation: true
curl -X POST "https://evolution.seudominio.com/chatwoot/set/NOME_INSTANCIA" \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"reopenConversation": true}'
```

### Problema: Contatos brasileiros duplicados

**Causa:** Números com e sem o 9º dígito criando contatos diferentes.

**Solução:**
```bash
# Ativar merge de contatos BR
curl -X POST "https://evolution.seudominio.com/chatwoot/set/NOME_INSTANCIA" \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"mergeBrazilContacts": true}'
```

### Problema: Erro 401 Unauthorized

**Causa:** Token inválido, expirado ou de Super Admin.

**Solução:**

1. **NÃO use token de Super Admin** - Tokens de Super Admin não funcionam na API
2. Crie um **usuário Administrador normal** para a integração:
   - Acesse **Configurações → Agentes → Adicionar Agente**
   - Email: `integracao@seudominio.com`
   - Função: **Administrador**
   - Use o token deste usuário na integração

3. **Verifique configuração do Nginx** - Headers com underscore são bloqueados por padrão:
   ```nginx
   # Adicione no bloco server do Nginx
   underscores_in_headers on;
   ```

4. Reconfigure a integração com o novo token

### Problema: Erro 404 Account not found

**Causa:** Account ID incorreto.

**Solução:**
1. Verifique o ID correto no Super Admin → Contas
2. Reconfigure com o ID correto

### Problema: Webhooks falham no Worker (mensagens não chegam)

**Causa:** Variável `FRONTEND_URL` não configurada no serviço worker.

**Sintomas:**
- Inbox foi criado corretamente
- Instância está conectada
- Mas mensagens do WhatsApp não aparecem no V4 Connect

**Solução:**

Adicione a variável `FRONTEND_URL` ao serviço **chatwoot-worker** no `docker-compose.yml`:

```yaml
chatwoot-worker:
  environment:
    - FRONTEND_URL=https://chat.seudominio.com  # Adicione esta linha
```

Reinicie o worker:
```bash
docker compose restart chatwoot-worker
```

### Problema: Headers bloqueados pelo Nginx

**Causa:** Nginx bloqueia headers com underscore (`_`) por padrão, como `api_access_token`.

**Sintomas:**
- API retorna 401 mesmo com token válido
- Integração não consegue autenticar

**Solução:**

Adicione ao bloco `server` do Nginx:
```nginx
server {
    underscores_in_headers on;  # Permite headers com underscore

    # ... resto da configuração
}
```

Reinicie o Nginx:
```bash
nginx -t && nginx -s reload
```

---

## Scripts Úteis

### Script de Configuração Rápida

Crie um arquivo `setup-evolution.sh`:

```bash
#!/bin/bash

# Configurações
EVOLUTION_URL="https://evolution.seudominio.com"
EVOLUTION_API_KEY="sua-api-key"
INSTANCE_NAME="whatsapp-principal"

V4_CONNECT_URL="https://v4connect.seudominio.com"
V4_CONNECT_TOKEN="seu-token-admin"
V4_CONNECT_ACCOUNT_ID="1"
INBOX_NAME="WhatsApp"

# Configurar integração
curl -X POST "${EVOLUTION_URL}/chatwoot/set/${INSTANCE_NAME}" \
  -H "apikey: ${EVOLUTION_API_KEY}" \
  -H "Content-Type: application/json" \
  -d "{
    \"enabled\": true,
    \"accountId\": \"${V4_CONNECT_ACCOUNT_ID}\",
    \"token\": \"${V4_CONNECT_TOKEN}\",
    \"url\": \"${V4_CONNECT_URL}\",
    \"signMsg\": true,
    \"reopenConversation\": true,
    \"conversationPending\": true,
    \"autoCreate\": true,
    \"nameInbox\": \"${INBOX_NAME}\",
    \"importContacts\": true,
    \"mergeBrazilContacts\": true
  }"

echo "Integração configurada!"
```

### Script de Verificação

```bash
#!/bin/bash

EVOLUTION_URL="https://evolution.seudominio.com"
EVOLUTION_API_KEY="sua-api-key"
INSTANCE_NAME="whatsapp-principal"

echo "=== Status da Instância ==="
curl -s -X GET "${EVOLUTION_URL}/instance/connectionState/${INSTANCE_NAME}" \
  -H "apikey: ${EVOLUTION_API_KEY}" | jq .

echo ""
echo "=== Configuração Chatwoot ==="
curl -s -X GET "${EVOLUTION_URL}/chatwoot/find/${INSTANCE_NAME}" \
  -H "apikey: ${EVOLUTION_API_KEY}" | jq .
```

---

## Variáveis de Ambiente (Opcional)

Se preferir, adicione ao `.env` do V4 Connect para documentação:

```bash
# Evolution API Integration (documentação)
# EVOLUTION_API_URL=https://evolution.seudominio.com
# EVOLUTION_API_KEY=sua-api-key
# EVOLUTION_INSTANCE_NAME=whatsapp-principal
```

> **Nota:** Estas variáveis são apenas para documentação. A integração é configurada no lado do Evolution API.

---

## Referências

- [Evolution API - Documentação Oficial](https://doc.evolution-api.com/v2/en/integrations/chatwoot)
- [Evolution API - GitHub](https://github.com/EvolutionAPI/evolution-api)
- [Evolution API - Webhooks](https://doc.evolution-api.com/v2/en/configuration/webhooks)
- [Chatwoot - API Channel Inbox](https://www.chatwoot.com/hc/user-guide/articles/1677839703-how-to-create-an-api-channel-inbox)
- [Evolution + Chatwoot Docker](https://github.com/willph/evolutionApi_chatwoot_docker)

---

## Changelog

| Data | Versão | Descrição |
|------|--------|-----------|
| 2025-12-14 | 1.1.0 | Adicionado troubleshooting: Nginx headers, FRONTEND_URL no worker, token de Super Admin |
| 2025-12-14 | 1.0.0 | Documentação inicial |

---

**Dúvidas?** Abra uma issue no repositório ou consulte a documentação oficial do Evolution API.
