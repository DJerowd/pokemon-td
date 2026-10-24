class_name StarterDatabase
extends Node

# Dicionário estático contendo as gerações de Pokémon Iniciais de Kanto até Unova
static var generations = [
	{
		"region": "Kanto (Geração 1)",
		"starters": [
			{ "name": "Bulbasaur", "type": "Planta/Veneno", "sprite_origin": Vector2(0, 32), "hp": 45, "attack": 49 },
			{ "name": "Charmander", "type": "Fogo", "sprite_origin": Vector2(256, 32), "hp": 39, "attack": 52 },
			{ "name": "Squirtle", "type": "Água", "sprite_origin": Vector2(448, 32), "hp": 44, "attack": 48 }
		]
	},
	{
		"region": "Johto (Geração 2)",
		"starters": [
			{ "name": "Chikorita", "type": "Planta", "sprite_origin": Vector2(0, 128), "hp": 45, "attack": 49 },
			{ "name": "Cyndaquil", "type": "Fogo", "sprite_origin": Vector2(192, 128), "hp": 39, "attack": 52 },
			{ "name": "Totodile", "type": "Água", "sprite_origin": Vector2(384, 128), "hp": 50, "attack": 65 }
		]
	},
	{
		"region": "Hoenn (Geração 3)",
		"starters": [
			{ "name": "Treecko", "type": "Planta", "sprite_origin": Vector2(192, 2432), "hp": 40, "attack": 45 },
			{ "name": "Torchic", "type": "Fogo", "sprite_origin": Vector2(384, 2432), "hp": 45, "attack": 60 },
			{ "name": "Mudkip", "type": "Água", "sprite_origin": Vector2(576, 2432), "hp": 50, "attack": 70 }
		]
	},
	{
		"region": "Sinnoh (Geração 4)",
		"starters": [
			{ "name": "Turtwig", "type": "Planta", "sprite_origin": Vector2(0, 3500), "hp": 55, "attack": 68 },
			{ "name": "Chimchar", "type": "Fogo", "sprite_origin": Vector2(192, 3500), "hp": 44, "attack": 58 },
			{ "name": "Piplup", "type": "Água", "sprite_origin": Vector2(384, 3500), "hp": 53, "attack": 51 }
		]
	},
	{
		"region": "Unova (Geração 5)",
		"starters": [
			{ "name": "Snivy", "type": "Planta", "sprite_origin": Vector2(0, 4800), "hp": 45, "attack": 45 },
			{ "name": "Tepig", "type": "Fogo", "sprite_origin": Vector2(192, 4800), "hp": 65, "attack": 63 },
			{ "name": "Oshawott", "type": "Água", "sprite_origin": Vector2(384, 4800), "hp": 55, "attack": 55 }
		]
	}
]
