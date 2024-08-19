class_name Card
var _value : int;
var _sprite = preload("res://icon.svg");

func _init(v : int = 0):
	_value = v;
	pass
	
#Returns true if card is used (removed from active use, until reload)
func _use() -> bool:
	return true;
