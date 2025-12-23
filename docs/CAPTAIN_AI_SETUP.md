# Captain (Copiloto de IA) - V4 Connect

Guia completo para configurar e utilizar o Captain, o sistema de IA integrado ao V4 Connect para atendimento inteligente.

## Índice

- [Visão Geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Pré-requisitos](#pré-requisitos)
- [Configuração Passo a Passo](#configuração-passo-a-passo)
- [Alimentando o Captain](#alimentando-o-captain)
- [Usando o Captain Assistant](#usando-o-captain-assistant)
- [Usando o Captain Copilot](#usando-o-captain-copilot)
- [Captain FAQs](#captain-faqs)
- [Captain Memories](#captain-memories)
- [Modelos Suportados](#modelos-suportados)
- [Configurações Avançadas](#configurações-avançadas)
- [Troubleshooting](#troubleshooting)
- [Custos e Limites](#custos-e-limites)
- [Referências](#referências)

---

## Visão Geral

O **Captain** é um agente de IA integrado nativamente ao Chatwoot v4.8.0, projetado para:

- Responder clientes automaticamente (Assistant)
- Auxiliar agentes com sugestões e rascunhos (Copilot)
- Gerar FAQs automaticamente a partir de conversas
- Memorizar informações importantes de clientes

### Status no V4 Connect

| Item | Status |
|------|--------|
| Feature Flag | `captain_integration` |
| Habilitado por padrão | ✅ Sim |
| Requer configuração | ✅ Sim (API Key OpenAI) |

---

## Funcionalidades

### 1. Captain Assistant (Bot para Clientes)

O Assistant é um chatbot que conversa diretamente com seus clientes.

**Capacidades:**
- Responde perguntas frequentes automaticamente
- Aprende com Help Center, PDFs e conversas passadas
- Transfere para agente humano quando necessário
- Funciona 24/7 sem intervenção humana

**Exemplo de interação:**
```
Cliente: Qual o prazo de entrega para São Paulo?
Captain: O prazo de entrega para São Paulo capital é de 3 a 5 dias úteis.
         Para outras regiões do estado, pode variar de 5 a 7 dias úteis.
         Posso ajudar com mais alguma informação?
```

### 2. Captain Copilot (Assistente para Agentes)

O Copilot trabalha nos bastidores, ajudando sua equipe de atendimento.

**Capacidades:**
- Rascunha respostas baseadas no contexto
- Traduz mensagens para outros idiomas
- Resume conversas longas
- Lê notas privadas do time
- Acessa atributos customizados da conversa
- Busca informações em integrações (Notion, Linear, CRM)

**Exemplo de uso:**
```
[Agente abre conversa com 50 mensagens]

Copilot sugere:
"Resumo: Cliente João relatou problema com cobrança duplicada
há 2 dias. Ticket #1234 aberto no financeiro. Aguardando estorno."

[Agente clica em "Rascunhar resposta"]

Copilot sugere:
"Olá João! Temos uma boa notícia: o estorno da cobrança
duplicada foi processado e deve aparecer na sua fatura
em até 48 horas. Precisa de mais alguma ajuda?"
```

### 3. Captain FAQs (Gerador Automático)

Identifica perguntas frequentes que ainda não estão documentadas.

**Capacidades:**
- Analisa conversas resolvidas
- Sugere novos artigos de FAQ
- Permite aprovação em lote
- Inclui citações das fontes

**Fluxo:**
```
1. Equipe resolve 50 conversas sobre "política de troca"
2. Captain detecta o padrão
3. Sugere: "Criar FAQ: Qual a política de troca?"
4. Admin aprova → Artigo criado automaticamente
```

### 4. Captain Memories (Memória de Clientes)

Armazena informações importantes sobre cada cliente.

**Capacidades:**
- Registra preferências mencionadas
- Guarda histórico de problemas
- Personaliza atendimentos futuros
- Integra com CRM

**Exemplo:**
```
[Em conversa anterior]
Cliente: "Prefiro ser contatado por email, não gosto de ligações"

[Captain registra na memória]

[Em conversa futura]
Copilot alerta: "Memória: Cliente prefere contato por email,
                evitar ligações telefônicas."
```

---

## Pré-requisitos

### Obrigatórios

- [ ] **OpenAI API Key** - Conta em [platform.openai.com](https://platform.openai.com)
- [ ] **PostgreSQL com pgvector** - Extensão para embeddings
- [ ] **V4 Connect v4.8.0+** - Versão com suporte ao Captain

### Recomendados

- [ ] Help Center configurado com artigos
- [ ] Histórico de conversas resolvidas
- [ ] Documentação em PDF (manuais, políticas)

---

## Configuração Passo a Passo

### Passo 1: Obter API Key da OpenAI

1. Acesse [platform.openai.com](https://platform.openai.com)
2. Faça login ou crie uma conta
3. Vá em **API Keys** → **Create new secret key**
4. Copie a chave (formato: `sk-proj-...`)
5. Adicione créditos em **Billing** (mínimo $5 recomendado)

> **Importante:** A chave só é exibida uma vez. Guarde em local seguro.

### Passo 2: Configurar PostgreSQL com pgvector

O Captain usa embeddings vetoriais para busca semântica. É necessário o pgvector.

**Opção A: Alterar imagem no docker-compose.yml**

```yaml
services:
  postgres:
    image: pgvector/pgvector:pg16  # Em vez de postgres:16
    # ... resto da configuração
```

**Opção B: Instalar extensão manualmente**

```bash
# Acessar o container
docker exec -it chatwoot_postgres psql -U postgres -d chatwoot_production

# Criar extensão
CREATE EXTENSION IF NOT EXISTS vector;

# Verificar
\dx
```

**Opção C: Usar imagem Chatwoot**

```yaml
services:
  postgres:
    image: chatwoot/pgvector:pg12
```

### Passo 3: Reiniciar e Migrar Banco

```bash
# Reiniciar PostgreSQL
docker compose restart postgres

# Executar migrações (se necessário)
docker compose exec rails bundle exec rails db:migrate
```

### Passo 4: Configurar no Super Admin

1. Acesse o **Super Admin** do V4 Connect
2. Vá em **Settings** (Configurações) no menu lateral
3. Clique em **Captain**

4. Preencha os campos:

| Campo | Valor | Obrigatório |
|-------|-------|-------------|
| **OpenAI API Key** | `sk-proj-...` | ✅ Sim |
| **OpenAI Model** | `gpt-4o-mini` | ✅ Sim |
| **OpenAI Endpoint** | (deixe vazio para OpenAI padrão) | ❌ Não |
| **Firecrawl API Key** | (para web crawling avançado) | ❌ Não |

5. Clique em **Save** / **Salvar**

### Passo 5: Habilitar por Conta

1. No **Super Admin**, vá em **Contas**
2. Clique na conta desejada (ex: "V4 Lima Soares & Co")
3. Na seção **Premium Features**, verifique se `captain_integration` está ativo
4. Se não estiver, ative e salve

### Passo 6: Verificar Ativação

1. Faça login na conta como Administrador
2. No menu lateral, deve aparecer a opção **Captain** ou **Capitão**
3. Se aparecer, a configuração está completa

---

## Alimentando o Captain

O Captain precisa de conhecimento para responder corretamente.

### Fontes de Conhecimento

| Fonte | Como Adicionar | Prioridade |
|-------|----------------|------------|
| **Help Center** | Criar artigos em Central de Ajuda | Alta |
| **PDFs** | Upload em Captain → Documentos | Alta |
| **Websites** | Adicionar URLs para crawling | Média |
| **Conversas** | Automático (conversas resolvidas) | Baixa |

### Adicionando Artigos no Help Center

1. Vá em **Central de Ajuda** no menu lateral
2. Crie **Categorias** (ex: "Pagamentos", "Entregas")
3. Adicione **Artigos** em cada categoria
4. Marque como **Publicado**

**Dica:** Artigos bem estruturados melhoram as respostas do Captain.

### Adicionando PDFs

1. Vá em **Captain** → **Documentos**
2. Clique em **Upload**
3. Selecione PDFs (manuais, políticas, catálogos)
4. Aguarde processamento

### Adicionando Websites

1. Vá em **Captain** → **Fontes**
2. Adicione URLs do seu site/documentação
3. Captain irá fazer crawling automático

---

## Usando o Captain Assistant

### Ativar em uma Caixa de Entrada

1. Vá em **Configurações** → **Caixas de Entrada**
2. Selecione a inbox desejada (ex: WhatsApp, Website)
3. Vá na aba **Configuração do Bot**
4. Ative **Captain Assistant**
5. Selecione o assistente configurado
6. Defina comportamento:
   - **Sempre responder** - Captain responde todas as mensagens
   - **Fora do horário** - Apenas quando agentes offline
   - **Sob demanda** - Apenas quando solicitado

### Configurar Persona do Assistant

1. Vá em **Captain** → **Assistentes**
2. Clique em **Criar Assistente** ou edite existente
3. Configure:

| Campo | Exemplo |
|-------|---------|
| **Nome** | "Luna - Assistente Virtual" |
| **Descrição** | "Assistente de atendimento V4" |
| **Instruções** | "Seja cordial, use português formal..." |
| **Tom** | Profissional / Casual / Amigável |

### Testar no Playground

1. Vá em **Captain** → **Playground**
2. Digite perguntas de teste
3. Verifique as respostas
4. Ajuste instruções se necessário

---

## Usando o Captain Copilot

### Ativar Copilot para Agentes

O Copilot fica disponível automaticamente para agentes após configuração.

### Funcionalidades do Copilot

**1. Rascunhar Resposta**
- Abra uma conversa
- Clique no ícone de **varinha mágica** ou **Copilot**
- Selecione "Rascunhar resposta"
- Copilot analisa contexto e sugere resposta
- Edite se necessário e envie

**2. Resumir Conversa**
- Em conversas longas, clique em "Resumir"
- Copilot gera resumo dos pontos principais
- Útil para agentes assumindo conversas de outros

**3. Traduzir Mensagem**
- Selecione uma mensagem
- Clique em "Traduzir"
- Escolha o idioma de destino
- Copilot traduz mantendo contexto

**4. Buscar Informações**
- Digite `/search` seguido da pergunta
- Copilot busca em Help Center, Notion, etc.
- Retorna informações relevantes

### Atalhos do Copilot

| Atalho | Ação |
|--------|------|
| `/draft` | Rascunhar resposta |
| `/summarize` | Resumir conversa |
| `/translate` | Traduzir última mensagem |
| `/search [termo]` | Buscar informações |

---

## Captain FAQs

### Como Funciona

1. Captain analisa conversas **resolvidas**
2. Identifica perguntas frequentes sem artigo correspondente
3. Gera sugestão de FAQ com resposta
4. Admin revisa e aprova

### Gerenciar Sugestões

1. Vá em **Captain** → **FAQs**
2. Veja lista de sugestões pendentes
3. Para cada sugestão:
   - **Aprovar** - Cria artigo no Help Center
   - **Editar** - Ajusta antes de aprovar
   - **Rejeitar** - Descarta sugestão

### Aprovação em Lote

1. Selecione múltiplas sugestões
2. Clique em **Aprovar Selecionados**
3. Artigos são criados automaticamente

---

## Captain Memories

### Como Funciona

Captain automaticamente registra informações importantes mencionadas em conversas:

- Preferências de contato
- Problemas recorrentes
- Dados pessoais relevantes
- Histórico de compras/interações

### Visualizar Memórias

1. Abra o perfil de um **Contato**
2. Veja seção **Memórias** ou **Captain Notes**
3. Informações registradas aparecem aqui

### Adicionar Memória Manual

1. No perfil do contato
2. Clique em **Adicionar Memória**
3. Digite informação relevante
4. Salve

---

## Modelos Suportados

### OpenAI (Nativo)

| Modelo | Velocidade | Qualidade | Custo |
|--------|------------|-----------|-------|
| `gpt-4o-mini` | Rápido | Boa | Baixo |
| `gpt-4o` | Médio | Excelente | Médio |
| `gpt-4-turbo` | Médio | Excelente | Alto |
| `gpt-4` | Lento | Excelente | Alto |

**Recomendação:** Comece com `gpt-4o-mini` para testes, escale para `gpt-4o` em produção.

### Endpoints Compatíveis

Captain suporta qualquer API compatível com OpenAI:

**Azure OpenAI**
```
Endpoint: https://seu-recurso.openai.azure.com
API Key: sua-chave-azure
```

**Ollama (Local)**
```
Endpoint: http://localhost:11434/v1
API Key: ollama (ou qualquer valor)
Modelo: llama3.1, mistral, etc.
```

**LiteLLM (Proxy)**
```
Endpoint: http://localhost:4000
API Key: sua-chave-litellm
```

> **Dica:** Use LiteLLM para acessar Claude (Anthropic) ou outros modelos não-OpenAI.

---

## Configurações Avançadas

### Variáveis de Ambiente

```bash
# Obrigatório (ou configure via Super Admin)
CAPTAIN_OPEN_AI_API_KEY=sk-proj-...

# Opcional - Endpoint customizado
CAPTAIN_OPENAI_ENDPOINT=https://custom-endpoint.com/v1

# Opcional - Modelo padrão
CAPTAIN_OPENAI_MODEL=gpt-4o-mini

# Opcional - Web Crawling
CAPTAIN_FIRECRAWL_API_KEY=fc-...
```

### Instruções Customizadas

No assistente, adicione instruções específicas:

```
Você é Luna, assistente virtual da V4 Company.

Regras:
- Sempre responda em português brasileiro
- Use tom profissional mas acolhedor
- Nunca invente informações - diga "não sei" se não souber
- Para assuntos financeiros, transfira para humano
- Limite respostas a 3 parágrafos

Contexto:
- Somos uma assessoria de marketing digital
- Horário de atendimento: 9h às 18h (dias úteis)
- Contato comercial: vendas@v4company.com
```

### Limitar Escopo

Configure o que o Captain pode/não pode fazer:

```
NÃO faça:
- Não forneça dados de outros clientes
- Não prometa prazos específicos
- Não discuta preços sem confirmação
- Não acesse sistemas externos

SEMPRE faça:
- Confirme entendimento antes de responder
- Ofereça transferência para humano
- Registre informações importantes
- Agradeça ao final da conversa
```

---

## Troubleshooting

### Problema: Captain não aparece no menu

**Causa:** Feature não habilitada para a conta.

**Solução:**
1. Super Admin → Contas → Selecionar conta
2. Premium Features → Ativar `captain_integration`
3. Recarregar página

### Problema: Erro "pgvector extension not found"

**Causa:** PostgreSQL sem extensão pgvector.

**Solução:**
```bash
# Opção 1: Usar imagem com pgvector
# docker-compose.yml
postgres:
  image: pgvector/pgvector:pg16

# Opção 2: Instalar manualmente
docker exec -it postgres psql -U postgres -d chatwoot_production
CREATE EXTENSION vector;
```

### Problema: Respostas muito genéricas

**Causa:** Falta de conhecimento específico.

**Solução:**
1. Adicione mais artigos ao Help Center
2. Faça upload de PDFs relevantes
3. Configure instruções mais detalhadas
4. Aguarde Captain aprender com conversas

### Problema: Captain não responde

**Causa:** API Key inválida ou sem créditos.

**Solução:**
1. Verifique API Key no Super Admin
2. Confirme créditos em platform.openai.com
3. Teste a chave manualmente:
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer sk-proj-..."
```

### Problema: Erro 429 (Rate Limit)

**Causa:** Muitas requisições para OpenAI.

**Solução:**
1. Aguarde alguns minutos
2. Considere upgrade do plano OpenAI
3. Use modelo mais leve (`gpt-4o-mini`)
4. Implemente cache de respostas

### Problema: Respostas em inglês

**Causa:** Instruções não especificam idioma.

**Solução:**
Adicione nas instruções do assistente:
```
IMPORTANTE: Sempre responda em português brasileiro (pt-BR).
Nunca use inglês, mesmo que a pergunta seja em inglês.
```

---

## Custos e Limites

### Preços OpenAI (Dezembro 2025)

| Modelo | Input (1M tokens) | Output (1M tokens) |
|--------|-------------------|-------------------|
| gpt-4o-mini | $0.15 | $0.60 |
| gpt-4o | $2.50 | $10.00 |
| gpt-4-turbo | $10.00 | $30.00 |

### Estimativa de Custos

| Volume | Modelo | Custo Estimado/Mês |
|--------|--------|-------------------|
| 1.000 conversas | gpt-4o-mini | ~$5-10 |
| 5.000 conversas | gpt-4o-mini | ~$25-50 |
| 1.000 conversas | gpt-4o | ~$50-100 |

> **Dica:** Monitore uso em platform.openai.com → Usage

### Limites Self-Hosted

Em instalações self-hosted, não há limites impostos pelo Chatwoot. Os limites são apenas da API OpenAI:
- **RPM** (Requests per minute): Varia por tier
- **TPM** (Tokens per minute): Varia por tier

---

## Referências

### Documentação Oficial

- [Introducing Captain - Chatwoot Blog](https://www.chatwoot.com/blog/introducing-captain/)
- [Captain User Guide](https://www.chatwoot.com/hc/user-guide/en/categories/captain)
- [How to enable Captain on self-hosted](https://www.chatwoot.com/hc/user-guide/articles/1755284287-how-to-enable-captain-on-self_hosted-installations)
- [How to use Captain Copilot](https://www.chatwoot.com/hc/user-guide/articles/1738110272-how-to-use-captain-copilot)

### APIs e Ferramentas

- [OpenAI Platform](https://platform.openai.com)
- [pgvector - PostgreSQL Extension](https://github.com/pgvector/pgvector)
- [LiteLLM - LLM Proxy](https://github.com/BerriAI/litellm)
- [Firecrawl - Web Crawling](https://firecrawl.dev)

---

## Changelog

| Data | Versão | Descrição |
|------|--------|-----------|
| 2025-12-14 | 1.0.0 | Documentação inicial |

---

**Dúvidas?** Abra uma issue no repositório ou consulte a documentação oficial do Chatwoot Captain.
