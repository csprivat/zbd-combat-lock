# Publicação na Oficina Steam

## Item criado

- ID da Oficina Steam: `3811449205`
- Endereço: `https://steamcommunity.com/sharedfiles/filedetails/?id=3811449205`
- Visibilidade atual: pública (`public`)

O ID deve permanecer no `workshop.txt`. Removê-lo faria o publicador tratar o
pacote como um item novo em vez de atualizar a publicação existente.

## Pacote preparado

O pacote de publicação é gerado em:

```text
dist/steam-workshop/ZbdCombatLock/
├── preview.png
├── workshop.txt
└── Contents/mods/ZbdCombatLock/
    ├── mod.info
    ├── poster.png
    └── 42/
```

O `preview.png` possui 256 × 256 pixels e menos de 1 MB, conforme o modelo
instalado pelo Project Zomboid. O `poster.png` possui 512 × 512 pixels e aparece
no gerenciador de mods do jogo.

## Primeira publicação

1. Feche o Project Zomboid.
2. Copie a pasta `dist/steam-workshop/ZbdCombatLock` para
   `%USERPROFILE%\Zomboid\Workshop\ZbdCombatLock`.
3. Inicie o jogo pela Steam e permaneça no menu inicial, fora de qualquer partida.
4. No menu principal em português, abra **Oficina** (logo abaixo de **Mods**) e
   depois **Criar e atualizar itens**.
5. Selecione **Zbd Combat Lock**, confira a imagem, o título, a descrição e as
   tags, e avance para enviar o item.
6. Após o envio, abra a página do item na Oficina Steam e confirme a visibilidade,
   o contrato da Oficina e a classificação exigida pela Steam.

Na primeira publicação, o jogo acrescentou `id=3811449205` ao `workshop.txt`.
Preserve essa linha para que os próximos envios atualizem o mesmo item em vez de
criar outro.

## Verificação antes de tornar público

- assinar o item recém-publicado;
- remover ou desativar a cópia de desenvolvimento para evitar IDs duplicados;
- iniciar o Build 42.21 ou superior;
- confirmar que **Mira** está atribuída ao Ctrl esquerdo;
- executar os casos principais descritos em `docs/TEST_PLAN.md`;
- conferir se não surgiram erros em `%USERPROFILE%\Zomboid\console.txt`.

## Atualizações futuras

Substitua `Contents/mods/ZbdCombatLock` pelos arquivos da nova versão, mantenha
o `id` existente no `workshop.txt` e use novamente **Criar e atualizar itens**.
Informe as alterações no campo de notas da atualização antes do envio.
