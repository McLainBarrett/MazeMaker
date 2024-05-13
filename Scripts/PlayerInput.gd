extends MultiplayerSynchronizer

@export var HorizontalInput := Vector2.ZERO
@export var VerticalInput := 0.0
@export var Mouse := Vector2.ZERO

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _process(_delta):
	if Input.is_action_just_pressed("Escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED) else Input.MOUSE_MODE_CAPTURED
	HorizontalInput = Input.get_vector("Left", "Right", "Forward", "Backward")
	VerticalInput = Input.get_axis("Down", "Up")

	if (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		var sensitivity = 5.0/1000
		Mouse = -Vector2(mouseIn.x, mouseIn.y) * sensitivity
	else:
		Mouse = Vector2.ZERO
	mouseIn = Vector2.ZERO

var mouseIn = Vector2.ZERO
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouseIn = event.relative
