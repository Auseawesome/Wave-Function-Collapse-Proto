class_name GeneratedTileMap extends TileMap

@export var map_width: int = 16
@export var map_height: int = 16

var Random = load("res://Random Utilities.gd").new()
var tileset_source : TileSetSource = get_tileset().get_source(0)
var tile_list: PackedVector2Array
var core_material_count
var starting_weights
var possible_tiles: Array
var tileset_dimensions: Vector2

func _ready():
	tile_list = get_valid_tiles()
	core_material_count = get_core_material_count()
	# Set starting weights to consider not just core material but also corners so corner and edge tiles aren't unfairly weighted against
	starting_weights = get_starting_weights()
	tileset_dimensions = get_tileset_dimensions()
	possible_tiles = get_possible_tiles()
	randomize()
	generate_world()


func _process(delta):
	pass

func create_multi_array(dimensions: Array) -> Array:
	assert(dimensions != null and dimensions.size() > 0)
	for d in dimensions:
		assert(typeof(d) == TYPE_INT and d > 0)
	return _create_multi_array(dimensions, 0)
	
func _create_multi_array(dimensions: Array, dimension: int) -> Array:
	var a := []
	a.resize(dimensions[dimension])
	if dimension + 1 < dimensions.size():
		for i in range(a.size()):
			a[i] = _create_multi_array(dimensions, dimension + 1)
	return a

func set_tile(coords,atlas_coords):
	set_cell(0,coords,0,atlas_coords)

func get_tile_data_at(position: Vector2, dataType: String):
	var tile_data : TileData = tileset_source.get_tile_data(position, 0)
	return tile_data.get_custom_data(dataType)

func get_tiles_with_data(dataType: String, dataValue: String):
	var tiles: Array
	for tile in tileset_source.get_tiles_count():
		if tileset_source.get_tile_data(tileset_source.get_tile_id(tile), 0).get_custom_data(dataType) == dataValue:
			tiles = tiles + [tileset_source.get_tile_id(tile)]
	return tiles

func get_valid_tiles():
	var valid_tiles: Array
	for tile in tileset_source.get_tiles_count():
		if tileset_source.get_tile_data(tileset_source.get_tile_id(tile), 0).get_custom_data("Core Material") != "":
			valid_tiles = valid_tiles + [tileset_source.get_tile_id(tile)]
	return valid_tiles

func get_core_material_count():
	var local_core_material_count: Dictionary
	for tile in tile_list:
		var material_type = tileset_source.get_tile_data(tile, 0).get_custom_data("Core Material")
		if local_core_material_count.has(material_type):
			local_core_material_count[material_type] += 1
		else:
			local_core_material_count[material_type] = 1
	return local_core_material_count
	
func get_starting_weights():
	var tile_weights: Array
	for tile in tile_list:
		var material_type = tileset_source.get_tile_data(tile, 0).get_custom_data("Core Material")
		tile_weights = tile_weights + [1.0 / float(core_material_count[material_type])]
	return tile_weights

func get_tileset_dimensions():
	return tileset_source.get_tile_id(tileset_source.get_tiles_count()-1)+Vector2i(1,1)

func get_possible_tiles():
	var local_possible_tiles: Array
	local_possible_tiles = create_multi_array([map_width, map_height, int(tileset_dimensions.x), int(tileset_dimensions.y)])
	for i_map_width in map_width:
		for i_map_height in map_height:
			for tile_x in tileset_dimensions.x:
				for tile_y in tileset_dimensions.y:
					if Vector2(tile_x,tile_y) in tile_list:
						local_possible_tiles[i_map_width][i_map_height][tile_x][tile_y] = starting_weights[tile_list.find(Vector2(tile_x,tile_y))]
					else:
						local_possible_tiles[i_map_width][i_map_height][tile_x][tile_y] = 0.0
	return local_possible_tiles

func generate_world():
	# Generate Random Tile
	var random_coords = Vector2(randi() % map_width,randi() % map_height)
	var random_tile = Random.random_choice(tile_list,starting_weights)
	set_tile(random_coords, random_tile)
	# Figure out how to get the map function on Array to multiply everything in an array by 0
	possible_tiles[random_coords.x][random_coords.y]
