extends Camera3D

@export var Speed : float = 10

func debugMove(object):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_key_pressed(KEY_X)):
		object.position += Vector3(0, -Input.get_last_mouse_velocity().y, Input.get_last_mouse_velocity().x)/25000
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_X)):
		object.position += Vector3(Input.get_last_mouse_velocity().x, -Input.get_last_mouse_velocity().y, 0)/25000

func _process(delta):
	debugMove($"../Spider")
	
	var x = Input.get_axis("Left", "Right")
	var y = Input.get_axis("Down", "Up")
	var z = Input.get_axis("Forward", "Backward")
	
	position += basis * Vector3(x,y,z) * delta
	
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		rotation += Vector3(-mouse.y,-mouse.x,0) * 5.0 / 1000
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	mouse = Vector2.ZERO

var mouse = Vector2.ZERO
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		mouse = event.relative
