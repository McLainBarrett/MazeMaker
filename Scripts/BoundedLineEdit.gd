extends LineEdit
 
var typeRestriction : TypeRestriction
var defaultValue

var bounded
var lowerBound
var upperBound

enum TypeRestriction {STRING, INT, IPv4_ADDRESS}

func _ready():
	text_changed.connect(onChange)

func onChange(newText : String):
	match typeRestriction:
		TypeRestriction.INT:
			pass
		TypeRestriction.IPv4_ADDRESS:
			pass
		_:
			pass

func retrieveInt() -> int:
	if (text == ""):
		return defaultValue
	if (bounded):
		return clamp(int(text),lowerBound, upperBound)
	else:
		return int(text)

func retrieveIP() -> String:
	return ""

func retrieveValue():
	match typeRestriction:
		TypeRestriction.INT:
			return retrieveInt()
		TypeRestriction.IPv4_ADDRESS:
			return retrieveIP()
		_:
			return text
