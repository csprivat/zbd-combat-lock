# Plano de teste manual — 0.2.1

## Pré-condições

- Project Zomboid `42.21.0` ou versão compatível da linha Build 42;
- **Zbd Combat Lock** ativo no gerenciador e no save;
- ação **Mira** atribuída ao `Ctrl esquerdo`;
- jogo reiniciado depois de qualquer alteração nos arquivos Lua;
- arma equipada na mão principal.

## Casos principais

| Caso | Ação | Resultado esperado |
|---|---|---|
| Inicialização | Entrar na partida | Sem janela de erro; combate começa desligado |
| Ativar | Tocar e soltar Ctrl esquerdo | Postura de mira persistente e indicador visível |
| Movimento | Usar WASD com combate ativo | Movimento nativo com direção voltada ao cursor |
| Ataque | Clicar o botão esquerdo com arma equipada | Ataque nativo é executado |
| Alternância | Tocar Ctrl esquerdo novamente | Indicador some e controles normais retornam |
| Repetição | Manter Ctrl pressionado | O modo alterna uma única vez por acionamento |
| Morte | Morrer com combate ativo | Estado interno e postura de mira são limpos |
| Reconexão | Sair e entrar novamente | A nova sessão começa sem mira travada |

## Interfaces

| Caso | Ação | Resultado esperado |
|---|---|---|
| Botão esquerdo ativo | Tentar selecionar um controle de menu em combate | Controle não é selecionado; ataque continua prioritário |
| Menu contextual | Usar botão direito sobre contexto válido | Menu contextual pode ser aberto |
| Uso normal da UI | Desativar combate e usar inventário/menu | Botão esquerdo volta a selecionar controles |

## Regressões proibidas

- alteração de dano, alcance, stamina ou animação;
- múltiplas alternâncias ao manter Ctrl pressionado;
- indicador visível sem `isForceAim()` ativo;
- contagem crescente de erros Lua;
- estado de mira preso depois de sair da partida.

## Diagnóstico

Se ocorrer erro, feche o jogo e consulte
`%USERPROFILE%\Zomboid\console.txt`. Registre a versão exata do jogo, a arma
usada, a sequência de entrada e as linhas que contenham `[ZbdCombatLock]`.

## Resultado da baseline

A baseline `0.2.1` foi validada manualmente em 1º de outubro de 2026 no
Build `42.21.0`, usando um lápis como arma corpo a corpo.
