extends Node2D

onready var map = $TileMap
onready var map2 = $TileMap2
onready var map3 = $TileMap3
onready var icon = $KinematicBody2D
onready var timer = $Timer
onready var canvas = $CanvasModulate
onready var light = $KinematicBody2D/Light2D
onready var camera = $KinematicBody2D/Sprite/Camera2D
onready var label = $CanvasLayer/Label
onready var timeLabel = $CanvasLayer/Label2
onready var pause_menu = $CanvasLayer/Control
onready var over_menu = $CanvasLayer/GameOver
onready var elapsed_time_label= $CanvasLayer/GameOver/VBoxContainer/Time
onready var collected_gems_label= $CanvasLayer/GameOver/VBoxContainer/Gems
onready var timer2 = $Timer2
onready var minecart = $Path2D/PathFollow2D/Sprite/Area2D/CollisionShape2D
onready var backgroundSong = $GameplaySong
onready var coinSound = $KinematicBody2D/CoinSound
onready var stepSound = $KinematicBody2D/StepSound
onready var itemSound = $KinematicBody2D/ItemSound
onready var chestSound = $KinematicBody2D/ChestSound
onready var pickaxeSound = $KinematicBody2D/PickaxeSound
onready var deathSound = $KinematicBody2D/DeathSound
onready var endingSound = $EndingSound
onready var checkPoint = Vector2.ZERO
onready var lastDirInput = "down"
var pause = false
onready var game = $Node2D

onready var last_position = Vector2.ZERO
var pickaxeItem = Vector2(0,15)
var keyItem = Vector2(3,18)
var northCaveEntrance = Vector2(25,6)
var southCaveEntrance = Vector2(24,16)
var southCaveExit = Vector2(96,2)
var northCaveExit = Vector2(85,8)
var stoneBlock = [Vector2(18,5), Vector2(18,4)]
var chest = Vector2(4,23)
var grass  = 34
var coin = 38
var finish = 41
var chestOpened = 35
var move_delay = 0.2
var can_move = true
var pickaxe = false
var key = false
var gems = 0
var time = 0

func _ready():
	backgroundSong.play()
	icon.position = map.map_to_world(last_position)
	timer.wait_time = move_delay
	timer.start()
	light.set_enabled(false)
	pause_menu.hide()
	timer2.start()
	over_menu.hide()

func _process(delta):
	timeLabel.text = str(time) + "sec"
	var dirVector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		lastDirInput = "right"
		$KinematicBody2D/AnimationPlayer.play("walk_right")
		dirVector = Vector2(1, 0)
	elif Input.is_action_pressed("ui_left"):
		lastDirInput = "left"
		$KinematicBody2D/AnimationPlayer.play("walk_left")
		dirVector = Vector2(-1, 0)
	elif Input.is_action_pressed("ui_up"):
		lastDirInput = "up"
		$KinematicBody2D/AnimationPlayer.play("walk_up")
		dirVector = Vector2(0, -1)
	elif Input.is_action_pressed("ui_down"):
		lastDirInput = "down"
		$KinematicBody2D/AnimationPlayer.play("walk_down")
		dirVector = Vector2(0, 1)
	
	if dirVector == Vector2.ZERO and can_move:
		$KinematicBody2D/AnimationPlayer.play("idle_"+lastDirInput)
	
	if dirVector != Vector2.ZERO and can_move:
		stepSound.play()
		move_icon(dirVector)
		can_move = false

func _input(event):
	if Input.is_action_pressed("ui_cancel"):
		pauseMenu()

func pauseMenu():
	pause=!pause
	if !pause:
		pause_menu.hide()
		get_tree().paused = false
	else:
		pause_menu.show()
		get_tree().paused = true

func _on_Timer_timeout():
	can_move = true

func move_icon(direction):
	camera.smoothing_enabled = true
	var next_position = last_position + direction

	icon.global_position = map.map_to_world(last_position)
	var collision = icon.move_and_collide(map.map_to_world(direction))
	if not collision:
		last_position = next_position
		if next_position == pickaxeItem and pickaxe==false:
			pickItem(pickaxeItem)

		if next_position == northCaveEntrance:
			checkPoint = Vector2(85,9)
			caveTeleport(checkPoint, "in")

		if next_position == southCaveExit:
			checkPoint = Vector2(24,16)
			caveTeleport(checkPoint, "out")
			
		if next_position == southCaveEntrance:
			checkPoint = Vector2(96,3)
			caveTeleport(checkPoint, "in")
			
		if next_position == northCaveExit:
			checkPoint = Vector2(25,6)
			caveTeleport(checkPoint, "out")
			
		if next_position == keyItem and key==false:
			pickItem(keyItem)

		if map3.get_cell(next_position[0] + 2, next_position[1] + 2) == coin:
			pickAndUpdateCoin(next_position)

		if map2.get_cell(next_position[0] + 2,next_position[1] + 2) == finish and gems >= 9:
			gameOver()

	else:
		if next_position in stoneBlock and pickaxe==true :
			pickaxeSound.play()
			map2.set_cell(next_position[0] + 2, next_position[1] + 2, grass)
		if next_position == chest and key==true:
			chestSound.play()
			map2.set_cell(next_position[0] + 2, next_position[1] + 2, chestOpened)
			key = false
			gems += 4
			label.text = str(gems) + "x"
			$Label3.text = str(gems) + "/9"

	timer.start()  # Restart the timer regardless

func _on_Timer2_timeout():
	time = time + 1

func _on_Area2D_body_entered(body):
	if(body==icon):
		deathSound.play()
		icon.global_position = map.map_to_world(checkPoint)
		last_position = checkPoint

func pickItem(item):
	map2.set_cell(item[0] + 2, item[1] + 2, grass)
	itemSound.play()
	if(item == pickaxeItem):
		pickaxe = true
	elif(item == keyItem):
		key = true
		
func pickAndUpdateCoin(next_position):
	map3.set_cell(next_position[0] + 2, next_position[1] + 2, -1)
	coinSound.play()
	gems += 1
	label.text = str(gems) + "x"
	$Label3.text = str(gems) + "/9"

func caveTeleport(checkPoint, direction):
	camera.smoothing_enabled = false
	icon.global_position = map.map_to_world(checkPoint)
	last_position = checkPoint
	if(direction == "in"):
		light.set_enabled(true)
		canvas.set_color(Color("GRAY"))
	else:
		light.set_enabled(false)
		canvas.set_color(Color(1,1,1))
		
func gameOver():
	over_menu.show()
	endingSound.play()
	elapsed_time_label.set_text(str(time) + " s")
	collected_gems_label.set_text(str(gems) + "/9")
	get_tree().paused = true
