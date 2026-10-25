# Catálogo legado; a classe global StarterDatabase é definida em scripts/data/StarterDatabase.gd.
extends Node

# Estatísticas base oficiais de cada inicial. sprite_origin = Vector2(-1, -1)
# significa que ainda não existe um recorte verificado para essa espécie na
# spritesheet local; a interface deixa a prévia vazia em vez de mostrar outro Pokémon.
static var generations: Array[Dictionary] = [
	{"region":"Kanto (Geração 1)","starters":[
		{"name":"Bulbasaur","type":"Planta/Veneno","sprite_origin":Vector2(0,32),"hp":45,"attack":49,"defense":49,"special_attack":65,"special_defense":65,"speed":45,"moves":["Investida","Chicote de Vinha","Pó do Sono",""]},
		{"name":"Charmander","type":"Fogo","sprite_origin":Vector2(256,32),"hp":39,"attack":52,"defense":43,"special_attack":60,"special_defense":50,"speed":65,"moves":["Arranhão","Brasa","Cortina de Fumaça",""]},
		{"name":"Squirtle","type":"Água","sprite_origin":Vector2(448,32),"hp":44,"attack":48,"defense":65,"special_attack":50,"special_defense":64,"speed":43,"moves":["Investida","Jato d'Água","Retirada",""]}
	]},
	{"region":"Johto (Geração 2)","starters":[
		{"name":"Chikorita","type":"Planta","sprite_origin":Vector2(0,128),"hp":45,"attack":49,"defense":65,"special_attack":49,"special_defense":65,"speed":45,"moves":["Investida","Folha Navalha","Refletir",""]},
		{"name":"Cyndaquil","type":"Fogo","sprite_origin":Vector2(192,128),"hp":39,"attack":52,"defense":43,"special_attack":60,"special_defense":50,"speed":65,"moves":["Investida","Brasa","Roda de Fogo",""]},
		{"name":"Totodile","type":"Água","sprite_origin":Vector2(384,128),"hp":50,"attack":65,"defense":64,"special_attack":44,"special_defense":48,"speed":43,"moves":["Arranhão","Pistola d'Água","Mordida",""]}
	]},
	{"region":"Hoenn (Geração 3)","starters":[
		{"name":"Treecko","type":"Planta","sprite_origin":Vector2(192,2432),"hp":40,"attack":45,"defense":35,"special_attack":65,"special_defense":55,"speed":70,"moves":["Pancada","Absorver","Ataque Rápido",""]},
		{"name":"Torchic","type":"Fogo","sprite_origin":Vector2(384,2432),"hp":45,"attack":60,"defense":40,"special_attack":70,"special_defense":50,"speed":45,"moves":["Arranhão","Brasas","Bicada",""]},
		{"name":"Mudkip","type":"Água","sprite_origin":Vector2(576,2432),"hp":50,"attack":70,"defense":50,"special_attack":50,"special_defense":50,"speed":40,"moves":["Investida","Jato d'Água","Tiro de Lama",""]}
	]},
	{"region":"Sinnoh (Geração 4)","starters":[
		{"name":"Turtwig","type":"Planta","sprite_origin":Vector2(0,3488),"hp":55,"attack":68,"defense":64,"special_attack":45,"special_defense":55,"speed":31,"moves":["Investida","Folha Navalha","Mordida",""]},
		{"name":"Chimchar","type":"Fogo","sprite_origin":Vector2(192,3488),"hp":44,"attack":58,"defense":44,"special_attack":58,"special_defense":44,"speed":61,"moves":["Arranhão","Brasa","Roda de Fogo",""]},
		{"name":"Piplup","type":"Água","sprite_origin":Vector2(384,3488),"hp":53,"attack":51,"defense":53,"special_attack":61,"special_defense":56,"speed":40,"moves":["Pancada","Bolha","Bicada",""]}
	]},
	{"region":"Unova (Geração 5)","starters":[
		{"name":"Snivy","type":"Planta","sprite_origin":Vector2(0,4800),"hp":45,"attack":45,"defense":55,"special_attack":45,"special_defense":55,"speed":63,"moves":["Investida","Chicote de Vinha","Folha Navalha",""]},
		{"name":"Tepig","type":"Fogo","sprite_origin":Vector2(192,4800),"hp":65,"attack":63,"defense":45,"special_attack":45,"special_defense":45,"speed":45,"moves":["Investida","Brasa","Cabeçada",""]},
		{"name":"Oshawott","type":"Água","sprite_origin":Vector2(384,4800),"hp":55,"attack":55,"defense":45,"special_attack":63,"special_defense":45,"speed":45,"moves":["Investida","Jato d'Água","Concha Navalha",""]}
	]},
	{"region":"Kalos (Geração 6)","starters":[
		{"name":"Chespin","type":"Planta","sprite_origin":Vector2(-1,-1),"hp":56,"attack":61,"defense":65,"special_attack":48,"special_defense":45,"speed":38,"moves":["Investida","Chicote de Vinha","Proteção",""]},
		{"name":"Fennekin","type":"Fogo","sprite_origin":Vector2(-1,-1),"hp":40,"attack":45,"defense":40,"special_attack":62,"special_defense":60,"speed":60,"moves":["Arranhão","Brasa","Confusão",""]},
		{"name":"Froakie","type":"Água","sprite_origin":Vector2(-1,-1),"hp":41,"attack":56,"defense":40,"special_attack":62,"special_defense":44,"speed":71,"moves":["Pancada","Bolhas","Ataque Rápido",""]}
	]},
	{"region":"Alola (Geração 7)","starters":[
		{"name":"Rowlet","type":"Planta/Voador","sprite_origin":Vector2(-1,-1),"hp":68,"attack":55,"defense":55,"special_attack":50,"special_defense":50,"speed":42,"moves":["Investida","Folha Navalha","Ataque de Asa",""]},
		{"name":"Litten","type":"Fogo","sprite_origin":Vector2(-1,-1),"hp":45,"attack":65,"defense":40,"special_attack":60,"special_defense":40,"speed":70,"moves":["Arranhão","Brasa","Mordida",""]},
		{"name":"Popplio","type":"Água","sprite_origin":Vector2(-1,-1),"hp":50,"attack":54,"defense":54,"special_attack":66,"special_defense":56,"speed":40,"moves":["Pancada","Jato d'Água","Canto",""]}
	]},
	{"region":"Galar (Geração 8)","starters":[
		{"name":"Grookey","type":"Planta","sprite_origin":Vector2(-1,-1),"hp":50,"attack":65,"defense":50,"special_attack":40,"special_defense":40,"speed":65,"moves":["Investida","Chicote de Vinha","Golpe de Tambor",""]},
		{"name":"Scorbunny","type":"Fogo","sprite_origin":Vector2(-1,-1),"hp":50,"attack":71,"defense":40,"special_attack":40,"special_defense":40,"speed":69,"moves":["Investida","Brasa","Ataque Rápido",""]},
		{"name":"Sobble","type":"Água","sprite_origin":Vector2(-1,-1),"hp":50,"attack":40,"defense":40,"special_attack":70,"special_defense":40,"speed":70,"moves":["Pancada","Jato d'Água","Tiro Certeiro",""]}
	]},
	{"region":"Paldea (Geração 9)","starters":[
		{"name":"Sprigatito","type":"Planta","sprite_origin":Vector2(-1,-1),"hp":40,"attack":61,"defense":54,"special_attack":45,"special_defense":45,"speed":65,"moves":["Arranhão","Folha Navalha","Ataque Rápido",""]},
		{"name":"Fuecoco","type":"Fogo","sprite_origin":Vector2(-1,-1),"hp":67,"attack":45,"defense":59,"special_attack":63,"special_defense":40,"speed":36,"moves":["Investida","Brasa","Mordida",""]},
		{"name":"Quaxly","type":"Água","sprite_origin":Vector2(-1,-1),"hp":55,"attack":65,"defense":45,"special_attack":50,"special_defense":45,"speed":50,"moves":["Pancada","Jato d'Água","Bicada",""]}
	]}
]
