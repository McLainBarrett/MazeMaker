extends Node3D

@export var strideLength : float = 0.25
@export var isUp : bool = false

var Point : Vector3 = Vector3.ZERO
func Raycast() -> Vector3:
	return $RayCast3D.get_collision_point()

func IKLimb(target : Vector3) -> void:
	target -= global_position
	#target *= Quaternion.from_euler(global_rotation).inverse()
	target += 0.25 * Vector3.UP if isUp else Vector3.ZERO
	#scale?
	
	var A : float = 0.5#Limb 1 Length
	var B : float = 0.5#Limb 2 Length
	var T : float = sqrt(target.x*target.x + target.y*target.y + target.z*target.z)
	
	var d = atan2(target.x, target.z)
	#d = min(max(d, -PI/2), PI/2)
	var c = atan2(target.y, sqrt(target.x*target.x + target.z*target.z))#need to replace sqrtx^2+z^2 if d is clamped
	var a = -acos((B*B + T*T - A*A) / (2*B*T)) - c
	#a = min(max(a, -PI/2), PI/2)
	var b =  acos((A*A + T*T - B*B) / (2*A*T)) - a - c
	#b = min(max(b, 0), PI/2)
	
#	$UpperLeg.rotation = (quaternion * Quaternion.from_euler(Vector3(0, d, 0)) * 
#										Quaternion.from_euler(Vector3(a, 0, 0))).get_euler()
#	$UpperLeg/LowerLeg.rotation = (quaternion * Quaternion.from_euler(Vector3(b, 0, 0))).get_euler()
	
	#instead of setting rotation, lerp to target rotation
	var ULtargRot = quaternion.inverse() * Quaternion.from_euler(Vector3(0, d, 0)) * Quaternion.from_euler(Vector3(a, 0, 0))
	var LLtargRot = Quaternion.from_euler(Vector3(b, 0, 0))

	var legSpeed = 0.25
	$UpperLeg.quaternion = $UpperLeg.quaternion.slerp(ULtargRot, legSpeed)
	$UpperLeg/LowerLeg.quaternion = $UpperLeg/LowerLeg.quaternion.slerp(LLtargRot, legSpeed)
	
	

func debugMove(object):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not Input.is_key_pressed(KEY_X)):
		object.position += Vector3(0, -Input.get_last_mouse_velocity().y, Input.get_last_mouse_velocity().x)/25000
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_key_pressed(KEY_X)):
		object.position += Vector3(Input.get_last_mouse_velocity().x, -Input.get_last_mouse_velocity().y, 0)/25000

func _ready():
	Point = Raycast()
	IKLimb(Point)

func _process(_delta):
#	if (not Input.is_key_pressed(KEY_F)):
#		debugMove($"../../../TestPoint")
#	else:
#		debugMove($"../..")
#	IKLimb($"../../../TestPoint".position)
	
	IKLimb(Point)
	var R = Raycast()
	if ((R-Point).length() > strideLength):
		isUp = not isUp
		Point = R
		IKLimb(Point)
