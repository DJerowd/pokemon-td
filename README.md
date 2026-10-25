# Pokémon Tower Defense — projeto de aprendizado

Protótipo de Tower Defense feito com Godot 4.x e GDScript. O jogador escolhe um Pokémon inicial, monta uma equipe e posiciona membros dessa equipe em espaços do mapa para atacar inimigos que percorrem um caminho.

> **Objetivo educacional:** este repositório prioriza código legível, pequenas responsabilidades por script e comentários que expliquem decisões importantes. É um protótipo em evolução, não uma versão final de jogo.

## Como executar

1. Instale uma versão do Godot compatível com a versão do projeto indicada em `project.godot`.
2. Clone o repositório e abra o arquivo `project.godot` no Godot.
3. Aguarde o editor importar os recursos.
4. Execute o projeto com **F6/F5** ou o botão de execução.
5. A cena inicial configurada é `scenes/ui/StarterSelectScene.tscn`.

Se aparecer um erro de recurso, confira o caminho indicado no erro no painel **FileSystem**. Não crie uma textura vazia com o mesmo nome para esconder um arquivo ausente: corrija o caminho ou atribua um recurso válido no Inspector.

## Fluxo principal

1. **Escolha do inicial** — `StarterDatabase.gd` fornece nome, tipo, HP, ataque e origem do sprite; `StarterSelectScene.gd` converte esses dados em um recurso `PokemonData`.
2. **Montagem da equipe** — `TeamSelectScene.gd` mostra o inventário e permite arrastar Pokémon para até seis posições. Um Pokémon não pode ocupar duas posições.
3. **Entrada na partida** — a equipe escolhida é armazenada em `GameManager.active_battle_team`.
4. **Posicionamento** — a barra inferior lista apenas a equipe ativa. Clique em um Pokémon e depois em um espaço vazio para posicioná-lo.
5. **Ondas** — `WaveManager.gd` controla a contagem de inimigos, intervalo de surgimento e término da onda. Ele é a única fonte da contagem de ondas; `GameManager.current_wave` é atualizado para a interface.
6. **Combate** — `PokemonTower.gd` detecta inimigos no alcance e aplica dano no temporizador. `Enemy.gd` gerencia HP, recompensa, captura e chegada ao fim do caminho.
7. **Fim de jogo** — quando as vidas chegam a zero, `GameManager.game_over` bloqueia novas ações de partida.

## Organização do código

| Arquivo | Responsabilidade |
| --- | --- |
| `scripts/managers/GameManager.gd` | Estado compartilhado, dinheiro, vidas, Pokébolas, equipe e inventário |
| `scripts/data/PokemonData.gd` | Recurso de dados de cada Pokémon e cálculo de região do sprite |
| `scripts/StarterDatabase.gd` | Dados estáticos dos iniciais por geração |
| `scenes/ui/StarterSelectScene.gd` | Interface e confirmação do inicial |
| `scenes/ui/TeamSelectScene.gd` | Montagem da equipe e navegação |
| `scripts/ui/DraggablePokemonCard.gd` / `scripts/ui/TeamSlot.gd` | Drag-and-drop da equipe |
| `scenes/main/GameScene.gd` | Liga os nós da partida e os sinais de onda/fim de jogo |
| `scenes/main/WaveManager.gd` | Criação dos inimigos e ciclo de ondas |
| `scenes/entities/Enemy.gd` | Movimento, vida, dano, captura e saída do mapa |
| `scenes/entities/PokemonTower.gd` | Alcance, alvo, cadência de ataque e inspeção |
| `scenes/map/TowerSlot.gd` | Posicionamento e movimentação das torres |
| `scenes/main/HUD.gd` / `scenes/main/ActiveTeamBar.gd` | Exibição de estado e seleção de unidades |

## Conceitos importantes para quem está aprendendo

### Recursos e cenas são coisas diferentes

`PokemonData` é um `Resource`: guarda dados reutilizáveis (nome, nível, ataque, sprite). `PokemonTower.tscn` é uma cena: define os nós visuais e físicos que aparecem no mapa. Separar os dados da representação evita duplicar estatísticas em vários scripts.

### O GameManager é um ponto central — use com disciplina

O autoload `GameManager` persiste entre cenas. Os métodos `add_money()`, `spend_money()`, `take_damage()` e `use_pokeball()` concentram regras para evitar valores negativos e efeitos colaterais inconsistentes. À medida que o jogo crescer, considere dividir inventário, economia e estado da partida em componentes separados.

### Sinais reduzem o acoplamento

`GameManager.stats_changed` avisa a interface quando um valor muda. A HUD não precisa descobrir quem concedeu dinheiro ou removeu uma vida: apenas reage ao sinal. Esse padrão é útil para menus, áudio, conquistas e salvamento.

### Um ciclo de onda deve ter uma única fonte de verdade

`WaveManager` incrementa a onda e acompanha quantos inimigos ainda serão criados. A onda só termina quando não há mais inimigos a criar nem inimigos vivos no grupo `enemies`. Não incremente o contador também no botão, pois isso gera divergência entre interface e lógica.

### Movimento no Path2D

O inimigo é um `PathFollow2D` filho do `Path2D`. A propriedade `progress` representa a distância percorrida no caminho. `loop = false` é importante: se o loop ficar ativo, o inimigo pode retornar ao começo sem disparar a condição de fim.

### Física e alcance

A torre usa `Area2D` para saber quando corpos entram ou saem do alcance. A área física e o círculo desenhado na tela precisam usar o mesmo raio. Se o alcance não funcionar, confira no Inspector as camadas/máscaras de colisão e se o inimigo possui um `CollisionShape2D`.

### Sprites

`PokemonData.sprite` pode receber uma textura no Inspector. Se for uma textura atlas, `sprite_origin` e `frame_size` determinam o recorte. Se o sprite sheet não estiver atribuído, a lógica de combate ainda deve funcionar, mas a aparência pode permanecer no sprite padrão da cena. Confirme sempre que a origem do frame está dentro das dimensões reais da imagem.

## Roteiro de testes manuais

- [ ] O projeto abre sem erros de parser ou recursos ausentes.
- [ ] É possível navegar entre gerações e confirmar/cancelar a escolha inicial.
- [ ] O Pokémon selecionado aparece no inventário com nome, nível, HP, ataque e tipo corretos.
- [ ] Não é possível iniciar a partida sem selecionar ao menos um Pokémon.
- [ ] Arrastar um Pokémon para outro slot remove sua atribuição anterior.
- [ ] A barra de batalha mostra somente a equipe ativa.
- [ ] Selecionar um Pokémon e clicar em um slot vazio cria uma torre; tentar ocupar um slot ocupado não cria duplicatas.
- [ ] Uma torre detecta inimigos dentro do alcance e causa dano no intervalo esperado.
- [ ] Inimigos morrem ao chegar a zero HP e concedem dinheiro apenas uma vez.
- [ ] Inimigos que chegam ao final do caminho removem uma vida apenas uma vez.
- [ ] Capturar consome uma Pokébola; não é possível ficar com saldo negativo.
- [ ] Uma onda só termina depois de todos os spawns e de todos os inimigos saírem do mapa.
- [ ] Ao zerar as vidas, novas ondas e ações de posicionamento ficam bloqueadas.
- [ ] Fechar o inspetor limpa a seleção da torre e remove o destaque de alcance.

## Próximas etapas recomendadas

1. **Validar no editor:** abrir todas as cenas e resolver warnings/erros do Output.
2. **Adicionar testes automatizados:** começar por regras puras, como economia, captura e tamanho da equipe.
3. **Criar dados de inimigos reais:** substituir o recurso genérico de inimigo em `WaveManager` por uma tabela de espécies e níveis.
4. **Completar os golpes:** mover dano, efeitos, tipo e animação para recursos `MoveData`, em vez de tratar o nome do golpe como dano.
5. **Melhorar feedback visual:** animações de ataque, barras de vida, indicadores de captura e mensagem de fim de jogo.
6. **Persistência:** implementar salvamento do inventário e progresso quando as regras estiverem estáveis.

## Limitações conhecidas

- Os inimigos surgem com dados genéricos até existir uma tabela de encontro.
- O protótipo ainda usa recompensa fixa e chance de captura simples.
- Golpes diferentes mudam a seleção exibida, mas ainda não têm efeitos e danos próprios.
- As coordenadas de sprite dependem do sprite sheet usado; valide-as visualmente no editor.
- Esta revisão foi feita por inspeção estática dos arquivos no GitHub. Execute o projeto no Godot para confirmar integração de cenas, colisões e sintaxe na versão instalada.


## Melhorias recentes de sprites, combate e inventário

- `SpriteFrameFactory.gd` recorta frames da spritesheet, remove fundos sólidos detectados nos cantos e preserva o canvas 32×32 para reduzir diferenças de escala.
- Pokémon posicionados continuam animando em repouso; quando há inimigos no alcance, a torre escolhe uma das quatro direções e usa a linha correspondente da spritesheet.
- O inspetor é adicionado ao `CanvasLayer` da interface para permanecer visível acima do mapa.
- A barra da equipe exibe sprite e nível até o Pokémon ser posicionado; a barra reage ao sinal `team_changed`.
- `WaveManager.gd` define rosters pré-programados por onda, com espécies, HP, velocidade, recompensa e política de captura. Alguns inimigos especiais não podem ser capturados.
- A HUD permite alternar entre Poké Bola, Great Ball e Ultra Ball. As bolas possuem bônus de captura diferentes e consomem inventários separados.
- Itens disponíveis durante a batalha: Poção (recupera HP), Antídoto (remove envenenamento) e Despertar (remove sono). Clique em uma torre para selecioná-la como alvo e use os botões da HUD. Inimigos especiais podem causar dano e condições de status a Pokémon posicionados; envenenamento causa dano periódico e sono interrompe os ataques até ser curado.
- Pokémon capturados entram automaticamente na equipe ativa se houver espaço entre os seis membros; caso contrário, ficam no armazenamento.

### Checklist adicional para testar

1. Observe um Pokémon posicionado sem inimigos por perto: a animação idle deve continuar.
2. Inicie uma onda e confira se a torre vira para cima, baixo, esquerda e direita conforme o inimigo se move.
3. Clique na torre e confirme que o painel de inspeção aparece no canto superior esquerdo.
4. Observe os sprites contra o mapa e verifique se o fundo não aparece como um quadrado sólido.
5. Confirme que o sprite some da barra ao posicionar a unidade e retorna se ela for removida.
6. Teste os três tipos de Pokébola; Great Ball e Ultra Ball devem ter chance maior que a Poké Bola.
7. Tente capturar um inimigo especial: a tentativa deve ser recusada sem consumir uma Pokébola.
8. Deixe um inimigo especial atacar uma torre, depois teste Poção e o item de cura de status.
