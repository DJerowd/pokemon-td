# Recursos visuais opcionais da interface

O código da HUD procura estes arquivos locais e mantém uma interface funcional com ícones textuais se eles não estiverem presentes:

- `pokemon_items.png` — [folha de itens Pokémon (The Spriters Resource)](https://www.spriters-resource.com/media/assets/45/48051.png?updated=1755472948)
- `pokemon_bags.png` — [sprites de bolsas (The Spriters Resource)](https://www.spriters-resource.com/media/assets/45/48047.png?updated=1755472948)
- `pokeballs_bw.png` — [Poké Balls de Pokémon Black/White (The Spriters Resource)](https://www.spriters-resource.com/media/assets/36/39327.png?updated=1755472779)

Salve os três PNGs dentro desta pasta, usando exatamente os nomes acima. Depois, abra o projeto no Godot e aguarde a importação.

## Fonte de Pokémon

A imagem [Fonts](https://www.spriters-resource.com/media/assets/25/27044.png?updated=1755472588) é uma folha de referência com exemplos de caracteres/estilos, não um arquivo de fonte TTF/OTF nem um atlas bitmap com descritor de glifos pronto para o Godot. Ela não pode ser atribuída diretamente a `Theme.default_font`. Para usá-la de verdade, é necessário obter a fonte extraída correspondente ou converter os glifos em uma fonte bitmap compatível (com mapeamento de caracteres e métricas). Até isso ser feito, a interface usa a fonte padrão do Godot com paleta e contornos inspirados no estilo DS.

## Ajuste dos recortes

Os recortes em `scenes/main/HUD.gd` são valores iniciais aproximados. Confira os ícones no editor e ajuste as constantes `ITEM_ICON_INDEX`, `BALL_COLUMN` e os tamanhos das regiões se o ícone selecionado não corresponder ao nome.
