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

static var resource_paths: Dictionary = {
	"bulbasaur": "res://resources/pokemon/Bulbasaur.tres",
	"charmander": "res://resources/pokemon/Charmander.tres",
	"squirtle": "res://resources/pokemon/Squirtle.tres",
	"chikorita": "res://resources/pokemon/Chikorita.tres",
	"cyndaquil": "res://resources/pokemon/Cyndaquil.tres",
	"totodile": "res://resources/pokemon/Totodile.tres",
	"treecko": "res://resources/pokemon/Treecko.tres",
	"torchic": "res://resources/pokemon/Torchic.tres",
	"mudkip": "res://resources/pokemon/Mudkip.tres",
	"turtwig": "res://resources/pokemon/Turtwig.tres",
	"chimchar": "res://resources/pokemon/Chimchar.tres",
	"piplup": "res://resources/pokemon/Piplup.tres",
	"snivy": "res://resources/pokemon/Snivy.tres",
	"tepig": "res://resources/pokemon/Tepig.tres",
	"oshawott": "res://resources/pokemon/Oshawott.tres",
	"pidgey": "res://resources/pokemon/Pidgey.tres",
	"rattata": "res://resources/pokemon/Rattata.tres",
	"pikachu": "res://resources/pokemon/Pikachu.tres",
	"sandshrew": "res://resources/pokemon/Sandshrew.tres",
	"nidoranf": "res://resources/pokemon/NidoranF.tres",
	"nidoranm": "res://resources/pokemon/NidoranM.tres",
	"clefairy": "res://resources/pokemon/Clefairy.tres",
	"vulpix": "res://resources/pokemon/Vulpix.tres",
	"jigglypuff": "res://resources/pokemon/Jigglypuff.tres",
	"zubat": "res://resources/pokemon/Zubat.tres",
	"oddish": "res://resources/pokemon/Oddish.tres",
	"meowth": "res://resources/pokemon/Meowth.tres",
	"psyduck": "res://resources/pokemon/Psyduck.tres",
	"growlithe": "res://resources/pokemon/Growlithe.tres",
	"poliwag": "res://resources/pokemon/Poliwag.tres",
	"abra": "res://resources/pokemon/Abra.tres",
	"machop": "res://resources/pokemon/Machop.tres",
	"geodude": "res://resources/pokemon/Geodude.tres",
	"gastly": "res://resources/pokemon/Gastly.tres",
	"eevee": "res://resources/pokemon/Eevee.tres"
}

static func _load_species_resource(species_name: String) -> PokemonData:
	var path: String = str(resource_paths.get(species_name.strip_edges().to_lower(), ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as PokemonData

static func _type_name(type_value: int) -> String:
	match type_value:
		PokemonData.Type.GRASS: return "Planta"
		PokemonData.Type.FIRE: return "Fogo"
		PokemonData.Type.WATER: return "Água"
		PokemonData.Type.POISON: return "Veneno"
		PokemonData.Type.FLYING: return "Voador"
		PokemonData.Type.ELECTRIC: return "Elétrico"
		PokemonData.Type.ICE: return "Gelo"
		PokemonData.Type.FIGHTING: return "Lutador"
		PokemonData.Type.GROUND: return "Terrestre"
		PokemonData.Type.BUG: return "Inseto"
		PokemonData.Type.ROCK: return "Pedra"
		PokemonData.Type.GHOST: return "Fantasma"
		PokemonData.Type.DRAGON: return "Dragão"
		PokemonData.Type.PSYCHIC: return "Psíquico"
		PokemonData.Type.NORMAL: return "Normal"
		_: return "Normal"

static func _resource_to_dictionary(resource: PokemonData) -> Dictionary:
	var type_name := _type_name(int(resource.primary_type))
	if resource.secondary_type != PokemonData.Type.NONE:
		type_name += "/" + _type_name(int(resource.secondary_type))
	return {
		"name": resource.species_name, "type": type_name,
		"sprite_origin": resource.sprite_origin, "hp": resource.hp,
		"attack": resource.attack, "defense": resource.defense,
		"special_attack": resource.special_attack, "special_defense": resource.special_defense,
		"speed": resource.speed, "moves": resource.available_moves.duplicate(),
		"id": resource.id
	}

static func get_species(species_name: String) -> Dictionary:
	var resource := _load_species_resource(species_name)
	if resource != null:
		return _resource_to_dictionary(resource)
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
			var species := get_species(str(entry.get("name", "")))
			if not species.is_empty(): result.append(species)
	for entry in additional_species:
		var species := get_species(str(entry.get("name", "")))
		if not species.is_empty() and not _contains_species(result, str(species.get("name", ""))): result.append(species)
	for species_name in resource_paths.keys():
		var species := get_species(str(species_name))
		if not species.is_empty() and not _contains_species(result, str(species.get("name", ""))): result.append(species)
	return result

static func _contains_species(species_list: Array[Dictionary], species_name: String) -> bool:
	for entry in species_list:
		if str(entry.get("name", "")).to_lower() == species_name.to_lower(): return true
	return false

static func create_pokemon_data(species_name: String, level: int = 5, overrides: Dictionary = {}) -> PokemonData:
	var resource := _load_species_resource(species_name)
	if resource != null:
		var pokemon := resource.duplicate(true) as PokemonData
		pokemon.level = maxi(1, level)
		for key in overrides.keys():
			var property_name := "species_name" if str(key) == "display_name" else str(key)
			if property_name in ["id", "species_name", "level", "primary_type", "secondary_type", "sprite_origin", "frame_size", "hp", "current_hp", "attack", "defense", "special_attack", "special_defense", "speed", "attack_range", "attack_speed", "ability", "held_item", "available_moves", "active_move_index", "status_condition", "sprite", "shiny_sprite"]:
				pokemon.set(property_name, overrides[key])
		if overrides.has("hp") and not overrides.has("current_hp"):
			pokemon.current_hp = pokemon.hp
		return pokemon
	var entry := get_species(species_name)
	for key in overrides:
		entry[key] = overrides[key]
	var fallback := PokemonData.new()
	fallback.id = absi(str(entry.get("name", species_name)).to_lower().hash()) % 100000
	fallback.species_name = str(entry.get("display_name", entry.get("name", species_name)))
	fallback.level = maxi(1, level)
	fallback.sprite_origin = entry.get("sprite_origin", Vector2.ZERO)
	fallback.frame_size = Vector2(32, 32)
	fallback.hp = float(entry.get("hp", 45.0))
	fallback.current_hp = fallback.hp
	fallback.attack = float(entry.get("attack", 49.0))
	fallback.defense = float(entry.get("defense", 49.0))
	fallback.special_attack = float(entry.get("special_attack", 49.0))
	fallback.special_defense = float(entry.get("special_defense", 49.0))
	fallback.speed = float(entry.get("speed", 45.0))
	fallback.primary_type = _type_from_name(str(entry.get("type", "Normal")).split("/")[0])
	fallback.secondary_type = _type_from_name(str(entry.get("type", "Normal")).split("/")[1]) if str(entry.get("type", "")).contains("/") else PokemonData.Type.NONE
	fallback.available_moves.clear()
	for move in entry.get("moves", ["Investida", "", "", ""]):
		fallback.available_moves.append(str(move))
	while fallback.available_moves.size() < 4:
		fallback.available_moves.append("")
	return fallback

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
