extends Node2D

var metrocity = randf_range(0.20,3)

var hcells = 16
var vcells = 11

var cellScene = preload("res://cell.tscn")

var Map : Array = []

#add vehicles/people to this 

func type_to_color(tile_type):
	match tile_type:
		"FUSE": return Color(1.0, 0.6, 0.0)
		"THREAT": return Color.BLUE
		"BOMB": return Color(0.8, 0.8, 0.0)
		"IMPACT": return Color(0.5, 0.0, 1.0)
		"IGNITE": return Color(1.0, 0.1, 0.1)
		"STINK": return Color.GREEN
		_: return Color.WHITE

func highlight_cells(affected: Array) -> void:
	for cell_info in affected:
		if cell_info != null:
			var pos: Vector2i = cell_info["pos"]
			var color: Color = type_to_color(cell_info["type"])
			if pos.x >= 0 and pos.x < hcells and pos.y >= 0 and pos.y < vcells:
				Map[pos.x][pos.y].modulate = color


func clear_highlight(affected: Array) -> void:
	for cell_info in affected:
		if cell_info != null:
			var pos: Vector2i = cell_info["pos"]
			if pos.x >= 0 and pos.x < hcells and pos.y >= 0 and pos.y < vcells:
				Map[pos.x][pos.y].modulate = Color.WHITE


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < hcells and cell.y >= 0 and cell.y < vcells



func _ready() -> void:
	# Build a unique column for each h index
	for h in range(hcells):
		var column := []  # NEW array each time
		for v in range(vcells):
			var child = spawnEmptyCell(h, v)
			add_child(child)
			column.append(child)
		Map.append(column)  # store column into Map
	
	roads()
	roundabouts()
	intersections()
	roadcorners()
	buildings()
	alleyClear()
	
	advertCarve()
	
	specialCheck() #creates specials - these appear in large open spaces and replace them as gardens and statues
	
	derelictCheck() #creates derelicts, sprinkles a few in place of regular buildings. average reduces as difficulty increases.
	
	addBeach() #converts the bottom beach H strip
	

func spawnEmptyCell(h,v):
	var emptyCell = cellScene.instantiate()
	emptyCell.h = h
	emptyCell.v = v
	emptyCell.position.x = h*64
	emptyCell.position.y = v*64
	return emptyCell

#prevent more than 2 parallel neighbor roads at a time
func roads():
	var total = randi_range(2, 10) # total number of roads to place
	for i in range(total):
		if randf() < 0.5: 
			# horizontal road
			var v_index = randi_range(0, vcells - 1)

			# prevent parallel horizontal roads
			if (v_index > 0 and Map[0][v_index - 1].type.ends_with("road")) \
			or (v_index < vcells - 1 and Map[0][v_index + 1].type.ends_with("road")):
				continue

			for h in range(hcells):
				if Map[h][v_index].type.ends_with("road") and randf() < 0.5:
					break # stop at intersection
				Map[h][v_index].set_cell_type("h_road")
				
		else:
			# vertical road
			var h_index = randi_range(0, hcells - 1)

			# prevent parallel vertical roads
			if (h_index > 0 and Map[h_index - 1][0].type.ends_with("road")) \
			or (h_index < hcells - 1 and Map[h_index + 1][0].type.ends_with("road")):
				continue

			for v in range(vcells):
				if Map[h_index][v].type.ends_with("road") and randf() < 0.5:
					break
				Map[h_index][v].set_cell_type("v_road")




func roundabouts():
	for h in range(1, hcells - 2):
		for v in range(1, vcells - 2):
			# look for true 4-way intersections
			if Map[h][v].type.ends_with("road") \
			and Map[h-1][v].type.ends_with("road") \
			and Map[h+1][v].type.ends_with("road") \
			and Map[h][v-1].type.ends_with("road") \
			and Map[h][v+1].type.ends_with("road") \
			and not Map[h-1][v-1].type.ends_with("road") \
			and not Map[h-1][v+1].type.ends_with("road") \
			and not Map[h+1][v-1].type.ends_with("road") \
			and not Map[h+1][v+1].type.ends_with("road") \
			and not Map[h-1][v-2].type.ends_with("road") \
			and not Map[h-1][v+2].type.ends_with("road") \
			and not Map[h+1][v-2].type.ends_with("road") \
			and not Map[h+1][v+2].type.ends_with("road") \
			and not Map[h-2][v-2].type.ends_with("road") \
			and not Map[h-2][v+2].type.ends_with("road") \
			and not Map[h+2][v-2].type.ends_with("road") \
			and not Map[h+2][v+2].type.ends_with("road"):
				
				if randf() < 0.5:  # rare (10% of intersections)
					# Replace center with a special type
					var intersection_special_centers = ["trees", "derelict", "advert", "building", "garden", "statue",  "statue", "advert", "advert", "statue",]
					Map[h][v].set_cell_type(intersection_special_centers[randi() % intersection_special_centers.size()])
					if Map[h][v].type == "building": Map[h][v].height = randi_range(2,4)
					
					# Convert cardinal neighbors to 3-way road types
					Map[h-1][v].set_cell_type("w_road")
					Map[h+1][v].set_cell_type("e_road")
					Map[h][v-1].set_cell_type("n_road")
					Map[h][v+1].set_cell_type("s_road")
					
					# Convert diagonal corners to turning roads
					Map[h-1][v-1].set_cell_type("nw_road")
					Map[h+1][v-1].set_cell_type("ne_road")
					Map[h-1][v+1].set_cell_type("sw_road")
					Map[h+1][v+1].set_cell_type("se_road")

func intersections():
	for h in range(hcells):
		for v in range(vcells):
			if Map[h][v].type.ends_with("road"):
				var n = h > 0 and Map[h-1][v].type.ends_with("road")
				var s = h < hcells - 1 and Map[h+1][v].type.ends_with("road")
				var w = v > 0 and Map[h][v-1].type.ends_with("road")
				var e = v < vcells - 1 and Map[h][v+1].type.ends_with("road")
				
				var count = int(n) + int(s) + int(w) + int(e)
				
				if count == 4:
					Map[h][v].set_cell_type("fourway_road")
				elif count == 3:
					if not n:
						Map[h][v].set_cell_type("e_road")
					elif not s:
						Map[h][v].set_cell_type("w_road")
					elif not w:
						Map[h][v].set_cell_type("s_road")
					elif not e:
						Map[h][v].set_cell_type("n_road")

func roadcorners():
	for h in range(hcells):
		for v in range(vcells):
			if Map[h][v].type.ends_with("road"):
				# Check neighbors safely
				var n = h > 0 and Map[h-1][v].type.ends_with("road")
				var s = h < hcells - 1 and Map[h+1][v].type.ends_with("road")
				var w = v > 0 and Map[h][v-1].type.ends_with("road")
				var e = v < vcells - 1 and Map[h][v+1].type.ends_with("road")
				
				var count = int(n) + int(s) + int(w) + int(e)
				
				# Corner = exactly 2 neighbors that are NOT opposite
				if count == 2:
					if n and e:
						Map[h][v].set_cell_type("ne_road")
					elif e and s:
						Map[h][v].set_cell_type("nw_road")
					elif s and w:
						Map[h][v].set_cell_type("sw_road")
					elif w and n:
						Map[h][v].set_cell_type("se_road")


func buildings():
	var to_alley: Array = []

	for column in Map:
		for cell in column:
			if cell.type == "unassigned":
				cell.set_cell_type("building")
			
			if cell.type == "building":
				# Base height chance: higher metrocity = lower chance
				var chance = clamp(0.10 * (metrocity*metrocity), 0.0, 1.0)
				cell.set_cell_height(1)
				if randf() < chance:
					cell.set_cell_height(randi_range(1, 4))
		
				# Detect 3+ long building walls (major alley carving)
				var h = cell.h
				var v = cell.v
				var alley := false

				# UP
				if v >= 3 and Map[h][v-1].type == "building" and Map[h][v-2].type == "building" and Map[h][v-3].type == "building":
					alley = true
				# DOWN
				elif v <= vcells-4 and Map[h][v+1].type == "building" and Map[h][v+2].type == "building" and Map[h][v+3].type == "building":
					alley = true
				# LEFT
				elif h >= 3 and Map[h-1][v].type == "building" and Map[h-2][v].type == "building" and Map[h-3][v].type == "building":
					alley = true
				# RIGHT
				elif h <= hcells-4 and Map[h+1][v].type == "building" and Map[h+2][v].type == "building" and Map[h+3][v].type == "building":
					alley = true
				
				# Don't carve every wall, only ~60% of them
				if alley and randf() < 0.40:
					to_alley.append(cell)

	# Apply batched conversions after scanning all cells
	for cell in to_alley:
		cell.set_cell_type("alley")
		cell.set_cell_height(0)



func alleyClear():
	for column in Map:
		for cell in column:
			if cell.type != "building":
				continue  # only modify buildings

			var h = cell.h
			var v = cell.v
			var alley_neighbors := 0

			# count adjacent alleys
			if v > 0 and Map[h][v-1].type == "alley":
				alley_neighbors += 1
			if v < vcells-1 and Map[h][v+1].type == "alley":
				alley_neighbors += 1
			if h > 0 and Map[h-1][v].type == "alley":
				alley_neighbors += 1
			if h < hcells-1 and Map[h+1][v].type == "alley":
				alley_neighbors += 1

			# if surrounded by many alleys then almost certain
			# if touching only one alley then  small chance to connect
			if alley_neighbors >= 3 or (alley_neighbors > 0 and randf() < 0.1):
				cell.set_cell_type("alley")
				cell.set_cell_height(0)


func advertCarve():
	if metrocity < 2.0:
		return  # nothing happens unless the city is dense
	
	var advert_cells = []

	#randomly place adverts
	for h in range(hcells):
		for v in range(vcells):
			if Map[h][v].type == "building":
				# Chance to seed increases slightly with metrocity
				var chance = (metrocity - 1.9) * 0.7  # 0 at 2.0, ~0.15 at 3.0
				if randf() < chance:
					Map[h][v].set_cell_type("advert")
					advert_cells.append(Vector2i(h, v))

	#Carve neighbors outward
	for pos in advert_cells:
		for offset in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
			var nh = pos.x + offset.x
			var nv = pos.y + offset.y
			if nh >= 0 and nh < hcells and nv >= 0 and nv < vcells:
				if Map[nh][nv].type == "building":
					var neighbor_chance = (metrocity/(metrocity*1.2)) * 0.3  # 0 at 2.0, ~0.25 at 3.0
					if randf() < neighbor_chance:
						Map[nh][nv].set_cell_type("advert")

func _is_alley(h:int, v:int) -> bool:
	if h < 0 or h >= hcells or v < 0 or v >= vcells:
		return false
	var t = Map[h][v].type
	return typeof(t) == TYPE_STRING and t.ends_with("alley")


func specialCheck():
	var to_special := []

	# iterate interior cells (skip edges to avoid OOB)
	for h in range(1, hcells - 1):
		for v in range(1, vcells - 1):
			# center must be an alley
			if not _is_alley(h, v):
				continue

			# require all 8 neighbors to be alley
			if _is_alley(h-1, v) and _is_alley(h+1, v) \
			and _is_alley(h, v-1) and _is_alley(h, v+1) \
			and _is_alley(h-1, v-1) and _is_alley(h-1, v+1) \
			and _is_alley(h+1, v-1) and _is_alley(h+1, v+1):
				to_special.append(Map[h][v])

	# apply after scanning to avoid mid-scan mutation effects
	for cell in to_special:
		cell.specialize(metrocity)

func derelictCheck():
	for column in Map:
		for cell in column:
			if cell.type == "building" and randf() < 0.13 / metrocity:
				cell.set_cell_type("derelict")
				cell.load_texture()

func addBeach():
	for h in range(hcells):
		Map[h][vcells-1].set_cell_type("beach")
		Map[h][vcells-1].set_cell_height(0)
