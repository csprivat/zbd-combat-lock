# Histórico de versões

Todas as mudanças relevantes do projeto serão registradas neste arquivo.

## 0.3.0 — 2026-10-02

- adiciona uma ação configurável, com F8 como padrão, para habilitar ou
  desabilitar o ZCL durante a partida;
- restaura o comportamento nativo de manter Ctrl esquerdo pressionado quando o
  ZCL está desabilitado;
- limpa a mira persistente durante as transições para evitar postura travada;
- preserva a prioridade de pausa e diálogos modais sobre a nova ação;
- restaura em memória a preferência original de `toggleToAim` ao desconectar;
- mantém combate, stamina, alcance, animações e rede sob controle nativo.

## 0.2.1 — 2026-10-01

- habilita a alternância nativa de mira do Project Zomboid Build 42;
- mantém a postura de combate ativa após soltar o Ctrl esquerdo;
- preserva movimento, ataque, stamina, alcance, animações e rede nativos;
- exibe o indicador `ZCL: COMBATE ATIVO` enquanto a mira forçada está ativa;
- limpa o estado ao morrer ou desconectar;
- adiciona compatibilidade defensiva com APIs variáveis da linha Build 42;
- publica o mod na Oficina Steam sob o ID `3811449205`.
