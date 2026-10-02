# Design técnico — 0.2.1

## Objetivo

Remover a necessidade de manter Ctrl pressionado durante o combate com mouse e
teclado, preservando integralmente a simulação nativa do Project Zomboid.

## Escopo validado

- alternância da ação Mira pelo Ctrl esquerdo;
- mira persistente direcionada pelo cursor;
- movimento simultâneo por WASD;
- ataque nativo pelo botão esquerdo;
- indicador visual sincronizado com o estado nativo;
- limpeza do estado ao morrer ou desconectar.

## Fora do escopo atual

- mudanças em dano, alcance, hit chance, stamina ou animações;
- envio de pacotes próprios para o servidor;
- remapeamento de ataque ou empurrão;
- suspensão automática ao abrir interfaces;
- suporte específico a controle Xbox;
- patches Java ou dependências externas.

## Integração nativa

O Build 42.21 fornece a opção `Core.toggleToAim`. Quando habilitada antes da
criação do jogador, o próprio `CharacterInputComponent` transforma a ação Mira
em uma alternância.

`ZCL_State.lua` habilita essa opção somente em memória. O arquivo `options.ini`
não é salvo ou editado pelo mod. `ZCL_Main.lua` não intercepta o Ctrl e não
injeta ataques; ele observa o primeiro jogador local e desenha o indicador.

Essa arquitetura substituiu duas provas anteriores:

- `0.1.0-dev` usava `IsoPlayer:setIsAiming(true)`, mas o jogo recalculava o
  estado a partir da entrada física;
- `0.1.1-dev` tentou acessar diretamente `CharacterInputComponent`, que não é
  indexável pela camada Lua do Build 42.21.

A versão `0.2.1` usa apenas interfaces públicas disponíveis ao Lua.

## Estados

| Estado | Fonte | Comportamento |
|---|---|---|
| `OFF` | `isForceAim() == false` | Controles originais e indicador oculto |
| `ACTIVE` | `isForceAim() == true` | Mira persistente e indicador visível |
| `BLOCKED` | Jogador ausente ou morto | Estado de mira limpo |

`enabled` não é uma segunda máquina de estados. Ele espelha o valor nativo para
evitar que o indicador fique diferente do comportamento real do jogo.

## Ciclo de vida

1. O Lua client-side carrega `ZCL_State.lua`.
2. `ZCL_Main.lua` habilita `toggleToAim` antes da criação de `IsoPlayer`.
3. `OnGameStart` reafirma a opção de forma idempotente.
4. `OnPlayerUpdate` consulta `isForceAim()` para o jogador local zero.
5. `OnPostUIDraw` desenha o indicador somente quando o estado está ativo.
6. `OnDisconnect` limpa `forceAim` e `isAiming` do último jogador conhecido.

Chamadas sujeitas a diferenças entre versões menores do Build 42 usam `pcall`.
Erros repetidos são deduplicados antes de serem gravados no `console.txt`.

## Entrada e interfaces

A ação Mira deve estar atribuída ao Ctrl esquerdo. O mod não simula uma tecla
física e não substitui o vínculo configurado pelo usuário.

Enquanto `ACTIVE`, o botão esquerdo permanece sob controle do combate nativo e
não seleciona controles de interface. O usuário desativa o modo com Ctrl antes
de operar inventário, crafting ou menus suspensos. Menus contextuais do botão
direito continuam disponíveis. Esse comportamento foi aceito como intencional.

## Multiplayer

O código atual é client-side e não modifica a simulação nem envia comandos de
rede próprios. O teste funcional inicial pode ser feito em uma partida local.
A compatibilidade com a política de mods de um servidor privado deve ser
validada separadamente antes de distribuição.

## Estrutura Build 42

`mod/mod.info` permite que o gerenciador descubra o mod. A implementação e os
metadados específicos ficam em `mod/42/`. Ambos usam o mesmo ID
`ZbdCombatLock` e a versão mínima `42.21.0`.
