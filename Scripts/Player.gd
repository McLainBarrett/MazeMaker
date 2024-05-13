extends CharacterBody3D

@export var SPEED = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(_delta):
	if Input.is_action_just_pressed("Escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) else Input.MOUSE_MODE_CAPTURED

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var upDown = Input.get_axis("Down", "Up")
	direction = (transform.basis * Vector3(0, upDown, 0)).normalized()
	if direction:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	abilities(_delta)
	#print(vecRound(position, 2))
	
	#Camera Controls
	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var sensitivity = 5.0/1000
		rotation += Vector3(0,-mouse.x,0) * sensitivity
		get_child(0).rotation += Vector3(-mouse.y, 0, 0) * sensitivity
	mouse = Vector2.ZERO

func vecRound(vec, num):
	var factor = pow(10, num)
	vec *= factor
	return Vector3(round(vec.x), round(vec.y), round(vec.z))/factor

var gsCooldown = 0.0
func abilities(delta):
	if (Input.is_action_just_pressed("Use")):
		#Rotate player to look at end of maze
		var mS = $"..".mazeSize
		mS = position - Vector3(mS.x-1, mS.z-1, mS.y-1) * 2
		rotation = Vector3(0, PI/2-atan2(mS.z, mS.x), 0)
		get_child(0).rotation = Vector3(-atan2(mS.y, sqrt(pow(mS.x, 2)+pow(mS.z, 2))), 0, 0)
	
	gsCooldown -= delta
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and gsCooldown <= 0):
		gsCooldown = 2
		var stick = load("res://Assets/Glowstick.tscn").instantiate()
		get_parent().add_child(stick)
		stick.position = position + Vector3.FORWARD * Quaternion.from_euler(-rotation)


var mouse = Vector2.ZERO
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse = event.relative
