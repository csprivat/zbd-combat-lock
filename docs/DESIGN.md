# Design técnico — 0.3.0

## Objetivo

Remover a necessidade de manter Ctrl pressionado durante o combate com mouse e
teclado, preservando integralmente a simulação nativa do Project Zomboid, e
permitir que o jogador restaure o comportamento de tecla mantida durante a
partida.

## Escopo validado

- alternância da ação Mira pelo Ctrl esquerdo;
- mira persistente direcionada pelo cursor;
- movimento simultâneo por WASD;
- ataque nativo pelo botão esquerdo;
- indicador visual sincronizado com o estado nativo;
- limpeza do estado ao morrer ou desconectar.
- habilitação e desabilitação do ZCL por ação configurável, com F8 como padrão;
- retorno imediato ao comportamento nativo de tecla mantida quando desabilitado.

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

`ZCL_State.lua` altera essa opção somente em memória. O arquivo `options.ini`
não é salvo ou editado pelo mod. `ZCL_Main.lua` não intercepta o Ctrl e não
injeta ataques; ele observa o primeiro jogador local e desenha o indicador.

A ação `Zbd Combat Lock` é registrada pela API pública `Core:addKeyBinding`,
com F8 como valor inicial. Quando a funcionalidade é desabilitada,
`Core:setToggleToAim(false)` devolve a mira mantida ao jogo. Quando habilitada,
`Core:setToggleToAim(true)` restaura a alternância persistente. A ação não
consome o evento de teclado e é ignorada durante pausa ou diálogo modal.

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
| `DISABLED` | `featureEnabled == false` | Ctrl precisa permanecer pressionado |
| `BLOCKED` | Jogador ausente ou morto | Estado de mira limpo |

`enabled` não é uma segunda máquina de estados. Ele espelha o valor nativo para
evitar que o indicador fique diferente do comportamento real do jogo.
`featureEnabled` controla exclusivamente se o ZCL possui `toggleToAim`.

## Ciclo de vida

1. O Lua client-side carrega `ZCL_State.lua`.
2. `ZCL_Main.lua` registra a ação configurável e habilita `toggleToAim` antes da
   criação de `IsoPlayer`.
3. `OnGameStart` inicia cada sessão com o ZCL habilitado.
4. `OnPlayerUpdate` consulta `isForceAim()` para o jogador local zero.
5. `OnPostUIDraw` desenha o indicador somente quando o estado está ativo.
6. `OnKeyPressed` alterna o ZCL sem consumir o evento, desde que a UI não tenha
   prioridade.
7. `OnDisconnect` limpa a mira e restaura a opção anterior em memória.

Chamadas sujeitas a diferenças entre versões menores do Build 42 usam `pcall`.
Erros repetidos são deduplicados antes de serem gravados no `console.txt`.

## Entrada e interfaces

A ação Mira deve estar atribuída ao Ctrl esquerdo. O mod não simula uma tecla
física e não substitui o vínculo configurado pelo usuário.

Enquanto `ACTIVE`, o botão esquerdo permanece sob controle do combate nativo e
não seleciona controles de interface. O usuário desativa o modo com Ctrl antes
de operar inventário, crafting ou menus suspensos. Menus contextuais do botão
direito continuam disponíveis. Esse comportamento foi aceito como intencional.

O controle de habilitar ou desabilitar o ZCL não é executado durante pausa ou
diálogo modal. O mod não bloqueia eventos de teclado ou mouse da interface.

## Multiplayer

O código atual é client-side e não modifica a simulação nem envia comandos de
rede próprios. O teste funcional inicial pode ser feito em uma partida local.
A compatibilidade com a política de mods de um servidor privado deve ser
validada separadamente antes de distribuição.

## Identidade, autoria e licença

O projeto e os pacotes publicados usam o ID estável `ZbdCombatLock`. Uma cópia
manual e a cópia da Oficina não devem ser carregadas juntas, pois possuem a
mesma identidade e uma pode sobrescrever a outra.

Autor: Cristian Privat — privat.tecnologia@gmail.com. Copyright © 2026 Cristian
Privat. Código distribuído sob a licença MIT; os arquivos executáveis Lua e
PowerShell contêm cabeçalhos SPDX e o pacote de distribuição inclui uma cópia
de `LICENSE`.

## Estrutura Build 42

`mod/mod.info` permite que o gerenciador descubra o mod. A implementação e os
metadados específicos ficam em `mod/42/`. Ambos usam o mesmo ID
`ZbdCombatLock` e a versão mínima `42.21.0`.
