class_name GeneratedTileMap extends TileMap

@export var map_width: int = 16
@export var map_height: int = 16

var Random = load("res://Random Utilities.gd").new()
var tileset_source : TileSetSource = get_tileset().get_source(0)
var tile_list: PackedVector2Array
var tile_values: Array
var tileset_dimensions: Vector2

func _ready():
	tile_list = get_valid_tiles()
	tile_values = get_tile_values()
	tileset_dimensions = get_tileset_dimensions()
	randomize()
	generate_world()


func _process(delta):
	pass

func create_multi_array(dimensions: Array,fill_value = null) -> Array:
	var multi_array: Array
	# Reverses dimensions array
	dimensions.reverse()
	# Creates smallest sub array filled with fill_value
	multi_array.resize(dimensions.pop_front())
	multi_array.fill(fill_value)
	# Iterates through dimensions pulling out each value to further nest the list
	for i in dimensions.size():
		var temp_array: Array
		temp_array.resize(dimensions.pop_front())
		temp_array.fill(multi_array.duplicate())
		multi_array = temp_array
	return multi_array

func set_tile(coords,atlas_coords):
	set_cell(0,coords,0,atlas_coords)

func get_tile_data_of(position: Vector2, dataType: String):
	var tile_data : TileData = tileset_source.get_tile_data(position, 0)
	return tile_data.get_custom_data(dataType)

func get_all_materials_of(position: Vector2) -> Array:
	return [
		get_tile_data_of(position, "Core Material"),
		get_tile_data_of(position, "North East Material"),
		get_tile_data_of(position, "South East Material"),
		get_tile_data_of(position, "South West Material"),
		get_tile_data_of(position, "North West Material")
	]

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

func get_tile_values():
	var local_tile_values: Array
	local_tile_values = create_multi_array([map_width,map_height,5],"") # 5 corresponds to amount of different materials per tile
	return local_tile_values

func get_tileset_dimensions():
	return tileset_source.get_tile_id(tileset_source.get_tiles_count()-1)+Vector2i(1,1)

func generate_world():
	# Generate Random Tile
	var random_coords = Vector2(randi() % map_width,randi() % map_height)
	# Fix to generate a tile type rather than tile so weights are equal - Not Urgent, Just biases starting tile
	var random_tile = Random.random_choice(tile_list)
	tile_values[random_coords.x][random_coords.y] = get_all_materials_of(random_tile)
	print(tile_values[random_coords.x][random_coords.y])
