class_name GeneratedTileMap extends TileMap

@export var map_width: int = 16
@export var map_height: int = 16

var Random = load("res://Random Utilities.gd").new()
var tileset_source : TileSetSource = get_tileset().get_source(0)
var tile_list: PackedVector2Array
var material_ids: Dictionary
var unique_tiles: Dictionary
var tile_values: Array
var tileset_dimensions: Vector2

func _ready():
	tile_list = get_tile_list()
	material_ids = get_material_ids()
	# If pattern in world gen occurs but tiles are wrong this function is likely the issue
	unique_tiles = get_unique_tiles()
	tile_values = get_tile_values()
	tileset_dimensions = get_tileset_dimensions()
	randomize()
	generate_world()

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

func get_all_tileset_tile_data_of(atlas_position: Vector2, dataType: String):
	var tile_data : TileData = tileset_source.get_tile_data(atlas_position, 0)
	return tile_data.get_custom_data(dataType)

func get_all_tileset_materials_of(atlas_position: Vector2) -> Array:
	return [
		get_all_tileset_tile_data_of(atlas_position, "Core Material"),
		get_all_tileset_tile_data_of(atlas_position, "North East Material"),
		get_all_tileset_tile_data_of(atlas_position, "South East Material"),
		get_all_tileset_tile_data_of(atlas_position, "South West Material"),
		get_all_tileset_tile_data_of(atlas_position, "North West Material")
	]

func get_all_tilemap_tile_data_of(tile_position: Vector2, dataType: String):
	var tile_data: TileData = get_cell_tile_data(0, tile_position)
	if tile_data == null:
		return ""
	return tile_data.get_custom_data(dataType)

func get_all_tilemap_materials_of(tile_position: Vector2) -> Array:
	return [
		get_all_tilemap_tile_data_of(tile_position, "Core Material"),
		get_all_tilemap_tile_data_of(tile_position, "North East Material"),
		get_all_tilemap_tile_data_of(tile_position, "South East Material"),
		get_all_tilemap_tile_data_of(tile_position, "South West Material"),
		get_all_tilemap_tile_data_of(tile_position, "North West Material")
	]

func get_tiles_with_data(dataType: String, dataValue: String):
	var tiles: Array
	for tile in tileset_source.get_tiles_count():
		if tileset_source.get_tile_data(tileset_source.get_tile_id(tile), 0).get_custom_data(dataType) == dataValue:
			tiles = tiles + [tileset_source.get_tile_id(tile)]
	return tiles

func get_tile_list():
	var local_tile_list: Array
	for tile in tileset_source.get_tiles_count():
		if tileset_source.get_tile_data(tileset_source.get_tile_id(tile), 0).get_custom_data("Core Material") != "":
			local_tile_list = local_tile_list + [tileset_source.get_tile_id(tile)]
	return local_tile_list

func get_material_ids() -> Dictionary:
	var local_material_ids: Dictionary
	# Iterates through all tiles
	for tile in tile_list:
		var tile_material = get_all_tileset_tile_data_of(tile, "Core Material")
		# Checks if material is not currently in materials dictionary
		if not local_material_ids.has(tile_material):
			# If material wasn't present adds it to dictionary with unique ID
			local_material_ids[tile_material] = local_material_ids.size()
	return local_material_ids

func get_material_id_of(tile_material: String):
	return material_ids[tile_material]

func get_unique_tiles():
	var local_unique_tiles: Dictionary
	# Iterates through all tiles
	for tile in tile_list:
		# Converts a tile into an array of material ids in the same order as get_all_tileset_materials_of() returns
		var id_array: Array = get_all_tileset_materials_of(tile).map(get_material_id_of)
		var tile_id: int = 0
		# Reverses ID array so each digit in base material_ids.size() corresponds to id of material in same order as get_all_tileset_materials_of() returns
		id_array.reverse()
		# Converts the id_array into a base material_ids.size() number id which corresponds to the materials on the tile
		for i in id_array.size():
			# Loops through id_array and adds each value multiplied by material_ids.size() to the power of it's position to set each digit in base material_ids.size()
			tile_id += id_array[i]*(material_ids.size()**i)
		if local_unique_tiles.has(tile_id):
			# If a tile with the same ID has already been found, simply add the coordinates of the new tile to the array of tiles with that ID
			local_unique_tiles[tile_id] = local_unique_tiles[tile_id] + [tile]
		else:
			# Otherwise if it is a new ID, create an array in the dictionary containing the coordinates of the tile
			local_unique_tiles[tile_id] = [tile]
	return local_unique_tiles

func get_tile_values():
	var local_tile_values: Array
	local_tile_values = create_multi_array([map_width,map_height,5],"") # 5 corresponds to amount of different materials per tile
	return local_tile_values

func get_tileset_dimensions():
	return tileset_source.get_tile_id(tileset_source.get_tiles_count()-1)+Vector2i(1,1)

func get_random_tile():
	var tile_array: Array
	# Converts unique_tiles array into list of tile types
	for tile_type in unique_tiles:
		tile_array = tile_array + [unique_tiles[tile_type]]
	# Gets a random tile type then a random tile from that type
	var random_tile_type: Array = Random.random_choice(tile_array)
	return Random.random_choice(random_tile_type)

func get_possible_materials(coords) -> bool:
	var core_material := ""
	var north_east_material := ""
	var south_east_material := ""
	var south_west_material := ""
	var north_west_material := ""
	var north_materials: Array = get_all_tilemap_materials_of(coords+Vector2(0,-1))
	if not north_materials.has(""):
		# Sets north east material to south east material of tile north of it
		north_east_material = north_materials[2]
		# Sets north west material to south west material of tile north of it
		north_west_material = north_materials[3]
		# If both the south west and east materials of the tile north of it are the same, set core of tile to that material
		if north_materials[2] == north_materials[3]:
			core_material = north_materials[2]
		# If both the south east and core materials of the tile north of it are the same, set core of tile to that material
		elif north_materials[2] == north_materials[0]:
			core_material = north_materials[0]
		# If both the south west and core materials of the tile north of it are the same, set core of tile to that material
		elif north_materials[3] == north_materials[0]:
			core_material = north_materials[0]
		# Return 0 as an invalid tile has been encountered
		else:
			return 0
	var east_materials = get_all_tilemap_materials_of(coords+Vector2(1,0))
	if not east_materials.has(""):
		# If the north west material of the tile to the east is not the same as the current north east tile and the northern tile was valid, return 0 as there are conflicting tiles
		if east_materials[4] != north_east_material and north_east_material != "":
			return 0
		elif east_materials[4] == "":
			north_east_material = east_materials[4]
		# Sets south east material to the south west material of the eastern tile
		south_east_material = east_materials[3]
		# If both the south west and north west materials of the tile east of it are the same but don't match with current core (if north was valid) return 0 as there are conflicting tiles
		if east_materials[3] == east_materials[4]:
			if east_materials[3] != core_material and core_material != "":
				return 0
			# If there was no tile north set core to the same material as south west and north west material of tile to the east
			elif core_material == "":
				core_material = east_materials[3]
		# If both the south west and core materials of the tile east of it are the same but don't match with current core (if north was valid) return 0 as there are conflicting tiles
		elif east_materials[3] == east_materials[0]:
			if east_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = east_materials[0]
		# If both the north west and core materials of the tile east of it are the same but don't match with current core (if north was valid) return 0 as there are conflicting tiles
		elif east_materials[4] == east_materials[0]:
			if east_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = east_materials[0]
		# Return 0 as an invalid tile has been encountered
		else:
			return 0
	var south_materials = get_all_tilemap_materials_of(coords+Vector2(0,1))
	if not south_materials.has(""):
		# If the north east material of the tile to the south is not the same as the current south east tile and the eastern tile was valid, return 0 as there are conflicting tiles
		if south_materials[1] != south_east_material and south_east_material != "":
			return 0
		elif south_east_material == "":
			south_east_material = south_materials[1]
		# Sets south west material to the north west material of the southern tile
		south_west_material = south_materials[4]
		# If both the north west and east materials of the southern tile are the same but don't match with current core (if north or east was valid) return 0 as there are conflicting tiles
		if south_materials[4] == south_materials[1]:
			if south_materials[4] != core_material and core_material != "":
				return 0
			# If there was no tile north or east set core to the same material as north west and east material of tile to the south
			elif core_material == "":
				core_material = south_materials[1]
		# If both the north west and core materials of the southern tile are the same but don't match with current core if core material has been set return 0 as there are conflicting tiles
		elif south_materials[4] == south_materials[0]:
			if south_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = south_materials[0]
		# If both the north weast and core materials of the southern tile are the same but don't match with current core of core material has been set return 0 as there are conflicting tiles
		elif south_materials[1] == south_materials[0]:
			if south_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = south_materials[0]
		# Return 0 as an invalid tile has been encountered
		else:
			return 0
	var west_materials = get_all_tilemap_materials_of(coords+Vector2(-1,0))
	if not west_materials.has(""):
		# If the south east material of the western tile is not the same as the current south west tile and the south west material has been set, return 0 as there are conflicting tiles
		if west_materials[2] != south_west_material and south_west_material != "":
			return 0
		elif south_west_material == "":
			south_west_material = west_materials[2]
		# If the north east material of the western tile is not the same as the current north west tile and the north west material has been set, return 0 as there are conflicting tiles
		if west_materials[1] != north_west_material and north_west_material != "":
			return 0
		elif north_west_material == "":
			north_west_material = west_materials[1]
		# If both the north and south east materials of the western tile are the same but don't match with current core if it has been set return 0 as there are conflicting tiles
		if west_materials[1] == west_materials[2]:
			if west_materials[1] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = west_materials[1]
		# If both the north east and core materials of the west tile are the same but don't match with current core if core material has been set return 0 as there are conflicting tiles
		elif west_materials[1] == west_materials[0]:
			if west_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = west_materials[0]
		# If both the south east and core materials of the western tile are the same but don't match with current core of core material has been set return 0 as there are conflicting tiles
		elif west_materials[2] == west_materials[0]:
			if west_materials[0] != core_material and core_material != "":
				return 0
			elif core_material == "":
				core_material = west_materials[0]
		# Return 0 as an invalid tile has been encountered
		else:
			return 0
	tile_values[coords.x][coords.y] = [core_material, north_east_material, south_east_material, south_west_material, north_west_material]
	return 1

func get_possible_tiles(coords):
	if get_possible_materials(coords):
		pass # Write code to get number of possible tiles
	else:
		pass # Do something here. This triggers if get_possible_materials() fails

func place_tile(coords: Vector2, tile: Vector2):
	tile_values[coords.x][coords.y] = get_all_tileset_materials_of(tile)
	set_tile(coords,tile)
	# Call method to update materials of nearby tiles

func generate_world():
	# Generate Random Tile
	var random_coords = Vector2(randi() % map_width,randi() % map_height)
	var random_tile = get_random_tile()
	place_tile(random_coords,random_tile)
