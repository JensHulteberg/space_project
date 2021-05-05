extends TileMap

func _ready():
	$"../astar_map".connect("map_recalculated", self, "_on_map_recalculated")
	_on_map_recalculated()

func place_tiles(tile_list):
	clear()
	for point in tile_list:
		var points_relative = PoolVector2Array([
				point + Vector2.RIGHT,
				point + Vector2(-1, 1),
				point + Vector2.LEFT,
				point + Vector2(1, 1),
				point + Vector2.DOWN,
				point + Vector2(1, -1),
				point + Vector2.UP,
				point + Vector2(-1, -1),
			])
		for point_relative in points_relative:
			if not point_relative in tile_list:
				set_cellv(point_relative, 0)
	update_bitmask_region()

func _on_map_recalculated():
	place_tiles($"../astar_map".obstacles)
