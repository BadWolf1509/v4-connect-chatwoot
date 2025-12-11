const fs = require('fs');
const path = require('path');

// Caminho para o arquivo de settings PT-BR
const settingsPath = path.join(__dirname, '../../chatwoot-dev/app/javascript/dashboard/i18n/locale/pt_BR/settings.json');

// Ler o arquivo atual
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

// Traduções da seção ASSIGNMENT_POLICY
const translations = {
  "INDEX": {
    "HEADER": {
      "TITLE": "Atribuição de Agentes",
      "DESCRIPTION": "Defina políticas para gerenciar efetivamente a carga de trabalho e rotear conversas com base nas necessidades das caixas de entrada e agentes. Saiba mais aqui"
    },
    "ASSIGNMENT_POLICY": {
      "TITLE": "Política de Atribuição",
      "DESCRIPTION": "Gerencie como as conversas são atribuídas nas caixas de entrada.",
      "FEATURES": [
        "Atribuir conversas igualmente ou por capacidade disponível",
        "Adicionar regras de distribuição justa para evitar sobrecarga de agentes",
        "Adicionar caixas de entrada a uma política - uma política por caixa"
      ]
    },
    "AGENT_CAPACITY_POLICY": {
      "TITLE": "Política de Capacidade do Agente",
      "DESCRIPTION": "Gerencie a carga de trabalho dos agentes.",
      "FEATURES": [
        "Definir máximo de conversas por caixa de entrada",
        "Criar exceções baseadas em etiquetas e tempo",
        "Adicionar agentes a uma política - uma política por agente"
      ]
    }
  },
  "AGENT_ASSIGNMENT_POLICY": {
    "INDEX": {
      "HEADER": {
        "TITLE": "Política de Atribuição",
        "CREATE_POLICY": "Nova política"
      },
      "CARD": {
        "ORDER": "Ordem",
        "PRIORITY": "Prioridade",
        "ACTIVE": "Ativo",
        "INACTIVE": "Inativo",
        "POPOVER": "Caixas adicionadas",
        "EDIT": "Editar"
      },
      "NO_RECORDS_FOUND": "Nenhuma política de atribuição encontrada"
    },
    "CREATE": {
      "HEADER": {
        "TITLE": "Criar política de atribuição"
      },
      "CREATE_BUTTON": "Criar política",
      "API": {
        "SUCCESS_MESSAGE": "Política de atribuição criada com sucesso",
        "ERROR_MESSAGE": "Falha ao criar política de atribuição"
      }
    },
    "EDIT": {
      "HEADER": {
        "TITLE": "Editar política de atribuição"
      },
      "EDIT_BUTTON": "Atualizar política",
      "CONFIRM_ADD_INBOX_DIALOG": {
        "TITLE": "Adicionar caixa de entrada",
        "DESCRIPTION": "A caixa {inboxName} já está vinculada a outra política. Tem certeza que deseja vinculá-la a esta política? Ela será desvinculada da outra política.",
        "CONFIRM_BUTTON_LABEL": "Continuar",
        "CANCEL_BUTTON_LABEL": "Cancelar"
      },
      "API": {
        "SUCCESS_MESSAGE": "Política de atribuição atualizada com sucesso",
        "ERROR_MESSAGE": "Falha ao atualizar política de atribuição"
      },
      "INBOX_API": {
        "ADD": {
          "SUCCESS_MESSAGE": "Caixa adicionada à política com sucesso",
          "ERROR_MESSAGE": "Falha ao adicionar caixa à política"
        },
        "REMOVE": {
          "SUCCESS_MESSAGE": "Caixa removida da política com sucesso",
          "ERROR_MESSAGE": "Falha ao remover caixa da política"
        }
      }
    },
    "FORM": {
      "NAME": {
        "LABEL": "Nome da política:",
        "PLACEHOLDER": "Digite o nome da política"
      },
      "DESCRIPTION": {
        "LABEL": "Descrição:",
        "PLACEHOLDER": "Digite a descrição"
      },
      "STATUS": {
        "LABEL": "Status:",
        "PLACEHOLDER": "Selecione o status",
        "ACTIVE": "Política ativa",
        "INACTIVE": "Política inativa"
      },
      "ASSIGNMENT_ORDER": {
        "LABEL": "Ordem de atribuição",
        "ROUND_ROBIN": {
          "LABEL": "Rodízio",
          "DESCRIPTION": "Atribuir conversas igualmente entre os agentes."
        },
        "BALANCED": {
          "LABEL": "Balanceado",
          "DESCRIPTION": "Atribuir conversas com base na capacidade disponível."
        }
      },
      "ASSIGNMENT_PRIORITY": {
        "LABEL": "Prioridade de atribuição",
        "EARLIEST_CREATED": {
          "LABEL": "Criada primeiro",
          "DESCRIPTION": "A conversa criada primeiro é atribuída primeiro."
        },
        "LONGEST_WAITING": {
          "LABEL": "Maior tempo de espera",
          "DESCRIPTION": "A conversa esperando há mais tempo é atribuída primeiro."
        }
      },
      "FAIR_DISTRIBUTION": {
        "LABEL": "Política de distribuição justa",
        "DESCRIPTION": "Defina o número máximo de conversas que podem ser atribuídas por agente em uma janela de tempo para evitar sobrecarga. Este campo obrigatório tem padrão de 100 conversas por hora.",
        "INPUT_MAX": "Atribuir máximo",
        "DURATION": "Conversas por agente a cada"
      },
      "INBOXES": {
        "LABEL": "Caixas adicionadas",
        "DESCRIPTION": "Adicione caixas de entrada para as quais esta política será aplicável.",
        "ADD_BUTTON": "Adicionar caixa",
        "DROPDOWN": {
          "SEARCH_PLACEHOLDER": "Pesquisar e selecionar caixas para adicionar",
          "ADD_BUTTON": "Adicionar"
        },
        "EMPTY_STATE": "Nenhuma caixa adicionada a esta política, adicione uma caixa para começar",
        "API": {
          "SUCCESS_MESSAGE": "Caixa adicionada à política com sucesso",
          "ERROR_MESSAGE": "Falha ao adicionar caixa à política"
        }
      }
    },
    "DELETE_POLICY": {
      "SUCCESS_MESSAGE": "Política de atribuição excluída com sucesso",
      "ERROR_MESSAGE": "Falha ao excluir política de atribuição"
    }
  },
  "AGENT_CAPACITY_POLICY": {
    "INDEX": {
      "HEADER": {
        "TITLE": "Capacidade do Agente",
        "CREATE_POLICY": "Nova política"
      },
      "CARD": {
        "POPOVER": "Agentes adicionados",
        "EDIT": "Editar"
      },
      "NO_RECORDS_FOUND": "Nenhuma política de capacidade encontrada"
    },
    "CREATE": {
      "HEADER": {
        "TITLE": "Criar política de capacidade"
      },
      "CREATE_BUTTON": "Criar política",
      "API": {
        "SUCCESS_MESSAGE": "Política de capacidade criada com sucesso",
        "ERROR_MESSAGE": "Falha ao criar política de capacidade"
      }
    },
    "EDIT": {
      "HEADER": {
        "TITLE": "Editar política de capacidade"
      },
      "EDIT_BUTTON": "Atualizar política",
      "CONFIRM_ADD_AGENT_DIALOG": {
        "TITLE": "Adicionar agente",
        "DESCRIPTION": "{agentName} já está vinculado a outra política. Tem certeza que deseja vinculá-lo a esta política? Ele será desvinculado da outra política.",
        "CONFIRM_BUTTON_LABEL": "Continuar",
        "CANCEL_BUTTON_LABEL": "Cancelar"
      },
      "API": {
        "SUCCESS_MESSAGE": "Política de capacidade atualizada com sucesso",
        "ERROR_MESSAGE": "Falha ao atualizar política de capacidade"
      },
      "AGENT_API": {
        "ADD": {
          "SUCCESS_MESSAGE": "Agente adicionado à política com sucesso",
          "ERROR_MESSAGE": "Falha ao adicionar agente à política"
        },
        "REMOVE": {
          "SUCCESS_MESSAGE": "Agente removido da política com sucesso",
          "ERROR_MESSAGE": "Falha ao remover agente da política"
        }
      }
    },
    "FORM": {
      "NAME": {
        "LABEL": "Nome da política:",
        "PLACEHOLDER": "Digite o nome da política"
      },
      "DESCRIPTION": {
        "LABEL": "Descrição:",
        "PLACEHOLDER": "Digite a descrição"
      },
      "INBOX_CAPACITY_LIMIT": {
        "LABEL": "Limites de capacidade por caixa",
        "ADD_BUTTON": "Adicionar caixa",
        "FIELD": {
          "SELECT_INBOX": "Selecionar caixa",
          "MAX_CONVERSATIONS": "Máx. conversas",
          "SET_LIMIT": "Definir limite"
        },
        "EMPTY_STATE": "Nenhum limite de caixa definido"
      },
      "EXCLUSION_RULES": {
        "LABEL": "Regras de exclusão",
        "DESCRIPTION": "Conversas que satisfaçam as seguintes condições não contarão para a capacidade do agente",
        "TAGS": {
          "LABEL": "Excluir conversas marcadas com etiquetas específicas",
          "ADD_TAG": "adicionar etiqueta",
          "DROPDOWN": {
            "SEARCH_PLACEHOLDER": "Pesquisar e selecionar etiquetas para adicionar"
          },
          "EMPTY_STATE": "Nenhuma etiqueta adicionada a esta política."
        },
        "DURATION": {
          "LABEL": "Excluir conversas mais antigas que uma duração específica",
          "PLACEHOLDER": "Definir tempo"
        }
      },
      "USERS": {
        "LABEL": "Agentes atribuídos",
        "DESCRIPTION": "Adicione agentes para os quais esta política será aplicável.",
        "ADD_BUTTON": "Adicionar agente",
        "DROPDOWN": {
          "SEARCH_PLACEHOLDER": "Pesquisar e selecionar agentes para adicionar",
          "ADD_BUTTON": "Adicionar"
        },
        "EMPTY_STATE": "Nenhum agente adicionado",
        "API": {
          "SUCCESS_MESSAGE": "Agente adicionado à política com sucesso",
          "ERROR_MESSAGE": "Falha ao adicionar agente à política"
        }
      }
    },
    "DELETE_POLICY": {
      "SUCCESS_MESSAGE": "Política de capacidade excluída com sucesso",
      "ERROR_MESSAGE": "Falha ao excluir política de capacidade"
    }
  }
};

// Aplicar traduções
settings.ASSIGNMENT_POLICY = translations;

// Salvar arquivo
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
console.log('✅ Traduções PT-BR aplicadas com sucesso em:', settingsPath);
