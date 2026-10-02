# Plano de teste manual — 0.3.0

## Pré-condições

- Project Zomboid `42.21.0` ou versão compatível da linha Build 42;
- **Zbd Combat Lock** ativo no gerenciador e no save;
- ação **Mira** atribuída ao `Ctrl esquerdo`;
- ação **Zbd Combat Lock** atribuída a `F8` ou outra tecla conhecida;
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
| Desabilitar ZCL | Pressionar F8 | Aviso `ZCL: DESATIVADO` aparece brevemente |
| Mira nativa | Manter Ctrl com ZCL desabilitado | Mira permanece ativa somente enquanto a tecla estiver pressionada |
| Soltar mira nativa | Soltar Ctrl com ZCL desabilitado | Postura de mira termina imediatamente |
| Reabilitar ZCL | Pressionar F8 novamente | Aviso `ZCL: HABILITADO` e alternância persistente restaurada |
| Transição ativa | Desabilitar ZCL com combate ativo | Mira persistente é limpa antes do modo nativo |
| Morte | Morrer com combate ativo | Estado interno e postura de mira são limpos |
| Reconexão | Sair e entrar novamente | A nova sessão começa sem mira travada |

## Interfaces

| Caso | Ação | Resultado esperado |
|---|---|---|
| Botão esquerdo ativo | Tentar selecionar um controle de menu em combate | Controle não é selecionado; ataque continua prioritário |
| Menu contextual | Usar botão direito sobre contexto válido | Menu contextual pode ser aberto |
| Uso normal da UI | Desativar combate e usar inventário/menu | Botão esquerdo volta a selecionar controles |
| Jogo pausado | Pressionar a tecla do ZCL no menu de pausa | Estado do ZCL não muda |
| Diálogo modal | Pressionar a tecla do ZCL com diálogo aberto | Estado do ZCL não muda |

## Regressões proibidas

- alteração de dano, alcance, stamina ou animação;
- múltiplas alternâncias ao manter Ctrl pressionado;
- indicador visível sem `isForceAim()` ativo;
- contagem crescente de erros Lua;
- estado de mira preso depois de sair da partida.
- reativação automática do ZCL depois que o jogador o desabilitou;
- tecla do ZCL superando uma interface com prioridade de entrada.

## Diagnóstico

Se ocorrer erro, feche o jogo e consulte
`%USERPROFILE%\Zomboid\console.txt`. Registre a versão exata do jogo, a arma
usada, a sequência de entrada e as linhas que contenham `[ZbdCombatLock]`.

## Resultados

A baseline `0.2.1` foi validada manualmente em 1º de outubro de 2026 no
Build `42.21.0`, usando um lápis como arma corpo a corpo.

A versão `0.3.0` ainda precisa executar todos os casos afetados acima dentro do
jogo. A inspeção estática não confirma que `CharacterInputComponent` aplica a
mudança de `toggleToAim` durante uma partida já carregada.
