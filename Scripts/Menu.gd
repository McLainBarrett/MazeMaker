extends Control

func _ready():
	pass

func _process(_delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		$BlueScreen.visible = false

#Menu navigation buttons
func joinButtonPressed():
	$Main.visible = false
	$Join.visible = true

func hostButtonPressed():
	$Main.visible = false
	$Host.visible = true

func backButtonPressed():
	$Main.visible = true
	$Join.visible = false
	$Host.visible = false

func quitButtonPressed():
	get_tree().quit()

var amram = 4
func amramButtonPressed():
	amram -= 1
	if (amram == 0):
		$BlueScreen.visible = true
		amram = 4


func joinJoinButtonPressed():
	OVERLORD.hosting = false
	OVERLORD.ipAddress = $Join/MarginContainer/VBoxContainer/HBoxContainer/TextEdit.text
	get_tree().change_scene_to_file("res://Assets/Main.tscn")

func getInt(lineEdit : LineEdit, bounds : Vector2, defaultValue : int) -> int:
	if (lineEdit.text == ""):
		return defaultValue
	return clamp(int(lineEdit.text), bounds.x, bounds.y)

func hostHostButtonPressed():
	#Load game, start server
	OVERLORD.hosting = true
	var sizeBounds := Vector2(2, 200)
	var defaultVal := 3
	OVERLORD.mazeSize = Vector3(
		getInt($Host/MarginContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/SizeSettings/Length/LengthLineEdit, sizeBounds, defaultVal),
		getInt($Host/MarginContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/SizeSettings/Height/HeightLineEdit, Vector2(1, sizeBounds.y), defaultVal),
		getInt($Host/MarginContainer/VBoxContainer/SettingsPanel/MarginContainer/VBoxContainer/SizeSettings/Width/WidthLineEdit, sizeBounds, defaultVal)
	)
#	OVERLORD.spiders = 
	get_tree().change_scene_to_file("res://Assets/Main.tscn")
