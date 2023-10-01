extends Node2D


var grid = []
var grid_width = 5
var grid_height = 5

var gridcount = 0
# e = empty
# ra = red agent
# re = red end

var offset = Vector2(100, 100)
var pp : Vector2

#load prefabs
@onready var red_agent = preload("res://Scenes/reg_agent.tscn")
@onready var red_goal = preload("res://Scenes/red_goal.tscn")
@onready var empty = preload("res://Scenes/empty.tscn")
@onready var block_prefab = preload( "res://Scenes/block.tscn")

var ra
var sheep_array = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in grid_width:
		grid.append([])
		for j in grid_height:
			grid[i].append("e") 

	grid[0][0] = "ra"
	grid[2][2] = "ra"
	grid[2][1] = "ra"
	grid[3][4] = "ra"
	grid[3][2] = "ra"
	grid[2][4] = "b"
	grid[3][3] = "b"
	
	#print_grid()
	create_empty_grid()
	create_objects_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func print_grid():
	for i in grid_width:
		for j in grid_height:
			#print("Gridcount : ",gridcount)
			#gridcount = gridcount +1
			print("Grid",i,j," : ",grid[i][j])
			
func create_empty_grid():
	for i in grid_width:
		for j in grid_height:
			var empty_block = empty.instantiate()
			var pos = Vector2(i* 210, j * 210)
			
			pos = pos+ offset
			empty_block.initialize(pos)
			
			add_child(empty_block)

func create_objects_grid():
	for i in grid_width:
		for j in grid_height:
			if grid[i][j] == 'ra':
				ra = red_agent.instantiate()
				ra.pos_in_grid= Vector2(i,j)
				var pos = Vector2(i* 210, j * 210)
				pos = pos+ offset
				ra.position = pos
				#print(i,j)
				add_child(ra)
				sheep_array.append(ra)
			elif grid[i][j] == "b":
				var block= block_prefab.instantiate()
				var pos = Vector2(i* 210, j * 210)
				pos = pos + offset
				block.position = pos
				add_child(block)
	print("Sheep Array: ",sheep_array)


func update_objects_grid():
	for i in grid_width:
		for j in grid_height:
			if grid[i][j] == 'ra':
				
				var pos = Vector2(i* 210, j * 210)
				pos = pos+ offset
				var tween = get_tree().create_tween()
				tween.tween_property(ra, "position", pos, 0.5)
					
					
				
func _input(event):
	
	


	if event.is_action_pressed("ui_right"):
		pp = Vector2.RIGHT
		move_sheeps(pp)
		
		
	if event.is_action_pressed("ui_left"):
		pp = Vector2.LEFT
		move_sheeps(pp)
		
	if event.is_action_pressed("ui_down"):
		pp = Vector2.DOWN
		move_sheeps(pp)
	if event.is_action_pressed("ui_up"):
		pp = Vector2.UP
		move_sheeps(pp)
	#print_grid()
	
	
func find_object_in_grid(name: String) -> Vector2:
	for i in grid_width:
		for j in grid_height:
			if grid[i][j] == name:
				return Vector2(i,j)
	return Vector2(-1,-1)
			
func set_pos_object_in_grid(name : String, targetPos : Vector2):
	var startPos = find_object_in_grid(name)
	grid[startPos.x][startPos.y] = 'e'
	grid[targetPos.x][targetPos.y] = name
	


func move_sheeps(direction : Vector2):
	for i in sheep_array.size():
		var target = sheep_array[i].pos_in_grid + direction
		if is_target_reachable(target):
			move_sheep(i, target)


func move_sheep(i : int,  target :  Vector2):
	var current_sheep = sheep_array[i]
	current_sheep.pos_in_grid = target
	var pos = Vector2(target.x* 210, target.y * 210)
	pos = pos+ offset
	#sheep_array[i].position = pos
	
	var tween = get_tree().create_tween()
	tween.tween_property(current_sheep, "position", pos, 0.1)
	

func is_target_reachable(targetPos: Vector2) -> bool:
	if targetPos.x > grid_width - 1 || targetPos.x  < 0:
		return false
	if targetPos.y > grid_height -1  || targetPos.y < 0:
		return false
	if grid[targetPos.x][targetPos.y]	== 'b':
		return false
	#grid[targetPos.x][targetPos.y] = "ra"
	
	for i in sheep_array.size():
		var current_sheep = sheep_array[i]
		#print("Target Pos: " ,targetPos)
		#print("Sheep Pos: " ,sheep_array[i].pos_in_grid)
		if targetPos == sheep_array[i].pos_in_grid:
			return is_target_reachable(pp  +targetPos)
			print("Blocked")
	return true
