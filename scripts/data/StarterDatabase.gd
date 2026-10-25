class_name StarterDatabase
extends Node
## Catálogo compartilhado de espécies. As entradas são usadas na seleção,
## na criação de torres e no spawn de inimigos.

static var generations: Array[Dictionary] = [
	{"region":"Kanto (Geração 1)","starters":[
		{"name":"Bulbasaur","type":"Planta/Veneno","sprite_origin":Vector2(0,32),"hp":45,"attack":49,"defense":49,"special_attack":65,"special_defense":65,"speed":45,"moves":["Investida","Chicote de Vinha","Pó do Sono",""]},
		{"name":"Charmander","type":"Fogo","sprite_origin":Vector2(256,32),"hp":39,"attack":52,"defense":43,"special_attack":60,"special_defense":50,"speed":65,"moves":["Arranhão","Brasa","Cortina de Fumaça",""]},
		{"name":"Squirtle","type":"Água","sprite_origin":Vector2(448,32),"hp":44,"attack":48,"defense":65,"special_attack":50,"special_defense":64,"speed":43,"moves":["Investida","Jato d'Água","Retirada",""]}
	]},
	{"region":"Johto (Geração 2)","starters":[
		{"name":"Chikorita","type":"Planta","sprite_origin":Vector2(576,1152),"hp":45,"attack":49,"defense":65,"special_attack":49,"special_defense":65,"speed":45,"moves":["Investida","Folha Navalha","Refletir",""]},
		{"name":"Cyndaquil","type":"Fogo","sprite_origin":Vector2(832,1152),"hp":39,"attack":52,"defense":43,"special_attack":60,"special_defense":50,"speed":65,"moves":["Investida","Brasa","Roda de Fogo",""]},
		{"name":"Totodile","type":"Água","sprite_origin":Vector2(0,1280),"hp":50,"attack":65,"defense":64,"special_attack":44,"special_defense":48,"speed":43,"moves":["Arranhão","Pistola d'Água","Mordida",""]}
	]},
	{"region":"Hoenn (Geração 3)","starters":[
		{"name":"Treecko","type":"Planta","sprite_origin":Vector2(192,2400),"hp":40,"attack":45,"defense":35,"special_attack":65,"special_defense":55,"speed":70,"moves":["Pancada","Absorver","Ataque Rápido",""]},
		{"name":"Torchic","type":"Fogo","sprite_origin":Vector2(384,2400),"hp":45,"attack":60,"defense":40,"special_attack":70,"special_defense":50,"speed":45,"moves":["Arranhão","Brasas","Bicada",""]},
		{"name":"Mudkip","type":"Água","sprite_origin":Vector2(576,2400),"hp":50,"attack":70,"defense":50,"special_attack":50,"special_defense":50,"speed":40,"moves":["Investida","Jato d'Água","Tiro de Lama",""]}
	]},
	{"region":"Sinnoh (Geração 4)","starters":[
		{"name":"Turtwig","type":"Planta","sprite_origin":Vector2(64,3744),"hp":55,"attack":68,"defense":64,"special_attack":45,"special_defense":55,"speed":31,"moves":["Investida","Folha Navalha","Mordida",""]},
		{"name":"Chimchar","type":"Fogo","sprite_origin":Vector2(256,3744),"hp":44,"attack":58,"defense":44,"special_attack":58,"special_defense":44,"speed":61,"moves":["Arranhão","Brasa","Roda de Fogo",""]},
		{"name":"Piplup","type":"Água","sprite_origin":Vector2(448,3744),"hp":53,"attack":51,"defense":53,"special_attack":61,"special_defense":56,"speed":40,"moves":["Pancada","Bolha","Bicada",""]}
	]}
]

# Espécies usadas nas ondas existentes mas que não fazem parte dos quatro
# grupos de iniciais acima. Os dados-base também ficam centralizados aqui.
static var additional_species: Array[Dictionary] = [
	{"name":"Snivy","type":"Planta","sprite_origin":Vector2(0,4800),"hp":45,"attack":45,"defense":55,"special_attack":45,"special_defense":55,"speed":63,"moves":["Investida","Chicote de Vinha","",""]},
	{"name":"Tepig","type":"Fogo","sprite_origin":Vector2(192,4800),"hp":65,"attack":63,"defense":45,"special_attack":45,"special_defense":45,"speed":45,"moves":["Investida","Brasa","",""]},
	{"name":"Oshawott","type":"Água","sprite_origin":Vector2(384,4800),"hp":55,"attack":55,"defense":45,"special_attack":63,"special_defense":45,"speed":45,"moves":["Investida","Jato d'Água","",""]}
]

static func get_species(species_name: String) -> Dictionary:
	var wanted := species_name.strip_edges().to_lower()
	for generation in generations:
		for entry in generation.get("starters", []):
			if str(entry.get("name", "")).to_lower() == wanted:
				return entry.duplicate(true)
	for entry in additional_species:
		if str(entry.get("name", "")).to_lower() == wanted:
			return entry.duplicate(true)
	return {}

static func all_species() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for generation in generations:
		for entry in generation.get("starters", []):
			result.append(entry.duplicate(true))
	for entry in additional_species:
		result.append(entry.duplicate(true))
	return result

static func create_pokemon_data(species_name: String, level: int = 5, overrides: Dictionary = {}) -> PokemonData:
	var entry := get_species(species_name)
	for key in overrides:
		entry[key] = overrides[key]
	var pokemon := PokemonData.new()
	pokemon.id = absi(str(entry.get("name", species_name)).to_lower().hash()) % 100000
	pokemon.species_name = str(entry.get("display_name", entry.get("name", species_name)))
	pokemon.level = maxi(1, level)
	pokemon.sprite_origin = entry.get("sprite_origin", Vector2.ZERO)
	pokemon.frame_size = Vector2(32, 32)
	pokemon.hp = float(entry.get("hp", 45.0))
	pokemon.current_hp = pokemon.hp
	pokemon.attack = float(entry.get("attack", 49.0))
	pokemon.defense = float(entry.get("defense", 49.0))
	pokemon.special_attack = float(entry.get("special_attack", 49.0))
	pokemon.special_defense = float(entry.get("special_defense", 49.0))
	pokemon.speed = float(entry.get("speed", 45.0))
	pokemon.primary_type = _type_from_name(str(entry.get("type", "Normal")).split("/")[0])
	pokemon.secondary_type = _type_from_name(str(entry.get("type", "Normal")).split("/")[1]) if str(entry.get("type", "")).contains("/") else PokemonData.Type.NONE
	pokemon.available_moves.clear()
	for move in entry.get("moves", ["Investida", "", "", ""]):
		pokemon.available_moves.append(str(move))
	while pokemon.available_moves.size() < 4:
		pokemon.available_moves.append("")
	return pokemon

static func _type_from_name(type_name: String) -> PokemonData.Type:
	match type_name.strip_edges():
		"Planta":
			return PokemonData.Type.GRASS
		"Fogo":
			return PokemonData.Type.FIRE
		"Água":
			return PokemonData.Type.WATER
		"Veneno":
			return PokemonData.Type.POISON
		"Voador":
			return PokemonData.Type.FLYING
		"Elétrico":
			return PokemonData.Type.ELECTRIC
		"Gelo":
			return PokemonData.Type.ICE
		"Lutador":
			return PokemonData.Type.FIGHTING
		"Terrestre":
			return PokemonData.Type.GROUND
		"Inseto":
			return PokemonData.Type.BUG
		"Pedra":
			return PokemonData.Type.ROCK
		"Fantasma":
			return PokemonData.Type.GHOST
		"Dragão":
			return PokemonData.Type.DRAGON
		"Psíquico":
			return PokemonData.Type.PSYCHIC
		_:
			return PokemonData.Type.NORMAL
