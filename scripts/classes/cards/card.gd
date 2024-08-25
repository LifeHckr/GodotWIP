class_name Card extends Resource
var value : int;
var base_value : int; #between 0 - 9
var sprite = preload("res://testArt/using/cardEmpty.png");
var exhaust : bool = false;
var combo_exhaust : bool = false;
var can_combo : bool = true;
signal used;

func _init(v : int):
	base_value = v;
	value = base_value;
	pass
	
#Returns true if card is used (removed from active use, until reload)
func _use() -> bool:
	used.emit(self);
	return true;

func _on_reload():
	pass

#Resets a card after battle sloppyish
func _reset():
	value = base_value;
	pass;

func _get_dupl(x : int) -> Card:
	return Card.new(x);
