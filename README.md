# ZbdCombatLock

Mod client-side para Project Zomboid Build 42 que transforma a ação de mira em
uma alternância persistente. Um toque em **Ctrl esquerdo** ativa a postura de
combate; outro toque a desativa.

## Estado do projeto

A versão `0.2.1` foi validada manualmente no Project Zomboid `42.21.0`.

O mod está disponível na
[Oficina Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3811449205).

Comportamento confirmado:

- Ctrl esquerdo alterna entre combate ativo e controles normais;
- a postura de mira permanece ativa depois de soltar Ctrl;
- WASD mantém o movimento nativo enquanto o personagem acompanha o cursor;
- o botão esquerdo executa o ataque nativo;
- o botão direito mantém os menus contextuais do jogo;
- o indicador `ZCL: COMBATE ATIVO` reflete o estado real da mira;
- não há alteração de dano, alcance, stamina, animações ou regras de combate.

## Requisito de controle

A ação **Mira** do jogo precisa estar atribuída ao **Ctrl esquerdo**:

1. Abra **Opções → Atribuição de Teclas**.
2. Role até **Combate**.
3. Confirme que **Mira** usa `Ctrl esquerdo` como tecla principal.

O mod acompanha a atribuição real da ação Mira. Se essa ação estiver vinculada
a outro botão, pressionar Ctrl não ativará o combate nativo.

## Como funciona

O Build 42.21 já possui a opção interna `toggleToAim`. O mod a habilita em
memória durante o carregamento do Lua, antes da criação do jogador, e deixa o
próprio jogo processar mira, direção, ataque e prioridade de entrada.

O mod não grava essa preferência em `options.ini`. O indicador é exibido apenas
quando `IsoPlayer:isForceAim()` confirma que o modo nativo está ativo.

## Interação com interfaces

O modo ativo é intencionalmente exclusivo para combate:

- o botão esquerdo fica dedicado ao ataque e não seleciona controles de menus;
- o botão direito ainda pode abrir menus contextuais;
- para usar inventário, crafting ou outros controles com o botão esquerdo,
  toque em Ctrl para desativar o combate.

A versão atual não suspende automaticamente o combate ao abrir interfaces.

## Instalação

### Oficina Steam

Assine o
[Zbd Combat Lock na Oficina Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=3811449205),
aguarde o download e ative o mod no menu **Mods** e no save desejado.

### Instalação manual

Copie a pasta do mod para:

```text
%USERPROFILE%\Zomboid\mods\ZbdCombatLock
```

A pasta instalada deve conter `mod.info` na raiz e o diretório `42/`. Depois,
ative **Zbd Combat Lock** no menu Mods e também no save, caso o jogo solicite.
Reinicie completamente o jogo após substituir arquivos Lua.

## Teste rápido

1. Entre em uma partida local com o mod ativo.
2. Equipe uma arma, inclusive uma arma improvisada como um lápis.
3. Toque e solte Ctrl esquerdo.
4. Confirme o indicador `ZCL: COMBATE ATIVO`.
5. Mova-se com WASD e altere a direção pelo cursor.
6. Ataque com o botão esquerdo.
7. Toque novamente em Ctrl e confirme o retorno aos controles normais.

Não é necessário iniciar um servidor para esse teste. A validação multiplayer
fica separada da prova técnica client-side.

## Diagnóstico

Se aparecer a janela de erros do jogo ou o modo não responder, feche o jogo e
procure por linhas com `[ZbdCombatLock]` em:

```text
%USERPROFILE%\Zomboid\console.txt
```

## Estrutura

```text
mod/
├── mod.info
└── 42/
    ├── mod.info
    └── media/lua/client/
        ├── ZCL_Main.lua
        └── ZCL_State.lua
```

O `mod.info` da raiz permite a descoberta do mod. A implementação específica do
Build 42 fica dentro de `42/`.

## Documentação

- [Design técnico](docs/DESIGN.md)
- [Plano de testes](docs/TEST_PLAN.md)
- [Publicação na Oficina Steam](docs/STEAM_WORKSHOP.md)
- [Histórico de versões](CHANGELOG.md)

## Licença

Distribuído sob a licença MIT. Consulte [LICENSE](LICENSE).
