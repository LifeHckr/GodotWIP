class_name Card extends RefCounted
var value : int;
var sprite = preload("res://testArt/cardEmpty.png");
var exhaust = false;
signal used;

func _init(v : int = 0):
	value = v;
	pass
	
#Returns true if card is used (removed from active use, until reload)
func _use() -> bool:
	used.emit(self);
	return true;

func _on_reload():
	pass

#Resets a card after battle sloppyish
func _reset():
	pass;
