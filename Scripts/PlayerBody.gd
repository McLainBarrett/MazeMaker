class_name PlayerBody
extends CharacterBody3D

@export var SPEED = 5.0
@onready var myInput = $InputSynchronizer
var isGhost = true
@export var playerID := 1 :
	set(id):# Set by the authority, synchronized on spawn.
		playerID = id
		# Give authority over the player input to the appropriate peer.
		$InputSynchronizer.set_multiplayer_authority(id)


func _ready():
	if playerID == multiplayer.get_unique_id():
		$Camera.current = true
		isGhost = false
	
	set_meta("PlayerColor", Color.from_hsv(randf(), 1, 1))


var protected = true
func spawnProtection():
	if (not protected):
		return
	
	#Check if player is blocking spawn
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = $Collider.shape
	query.transform = transform
	query.collision_mask = 2
	var valid = len(get_world_3d().direct_space_state.collide_shape(query)) <= 0
	
	#enable player collision
	if (valid):
		self.collision_layer = 2
		self.collision_mask = 15
		protected = false


func setColor():
	var pC := get_meta("PlayerColor") as Color
	#var mat := $CSGCylinder3D.material as StandardMaterial3D
	var mat := StandardMaterial3D.new()
	mat.albedo_color = pC
	$CSGCylinder3D.material = mat
	
	if (isGhost):
		$OmniLight3D.light_color = pC
	else:
		$OmniLight3D.light_color = Color.WHITE


func _physics_process(_delta):
	spawnProtection()
	setColor()
	var WASD = myInput.HorizontalInput
	var direction = (transform.basis * Vector3(WASD.x, 0, WASD.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var upDown = myInput.VerticalInput
	direction = (transform.basis * Vector3(0, upDown, 0)).normalized()
	if direction:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	abilities(_delta)
	
	#Camera Controls 
	rotation += Vector3(0,myInput.Mouse.x,0)
	$Camera.rotation += Vector3(myInput.Mouse.y, 0, 0)


func vecRound(vec, num):
	var factor = pow(10, num)
	vec *= factor
	return Vector3(round(vec.x), round(vec.y), round(vec.z))/factor


#var gsCooldown = 0.0
func abilities(_delta):
#	gsCooldown -= delta
#	if (myInput.Fkey and gsCooldown <= 0):
#		gsCooldown = 2
#		var stick = load("res://Assets/Glowstick.tscn").instantiate()
#		get_parent().add_child(stick)
#		stick.position = position + Vector3.FORWARD * Quaternion.from_euler(-rotation)
	pass
