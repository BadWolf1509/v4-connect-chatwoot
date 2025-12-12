#!/usr/bin/env node
/**
 * Aplica traduções PT-BR no frontend do Chatwoot
 * - Sidebar: AGENT_ASSIGNMENT, SLA, CUSTOM_ROLES
 * - Assignment Policy: Seção completa
 */

const fs = require('fs');
const path = require('path');

// Caminhos
const settingsPath = process.argv[2] || 'app/javascript/dashboard/i18n/locale/pt_BR/settings.json';
const translationsPath = process.argv[3] || path.join(__dirname, '../locales/assignment_policy.pt-BR.json');

// Carregar arquivos
console.log('Carregando settings.json...');
const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));

console.log('Carregando traduções do Assignment Policy...');
const assignmentPolicy = JSON.parse(fs.readFileSync(translationsPath, 'utf8'));

// Adicionar traduções do sidebar
settings.SETTINGS = settings.SETTINGS || {};
settings.SETTINGS.AGENT_ASSIGNMENT = 'Atribuição de Agentes';
settings.SETTINGS.SLA = 'SLA';
settings.SETTINGS.CUSTOM_ROLES = 'Funções Personalizadas';
settings.SETTINGS.AUDIT_LOGS = 'Auditoria';
settings.SETTINGS.BETA = 'Beta';

// Adicionar traduções do Assignment Policy
settings.ASSIGNMENT_POLICY = assignmentPolicy.ASSIGNMENT_POLICY || assignmentPolicy;

// Salvar
fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
console.log('Traduções PT-BR aplicadas com sucesso!');
console.log('  - Sidebar: AGENT_ASSIGNMENT, SLA, CUSTOM_ROLES, AUDIT_LOGS, BETA');
console.log('  - Assignment Policy: Seção completa');
