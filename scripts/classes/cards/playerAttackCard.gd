class_name PlayerAttackCard extends Card

var base_val : int;

func _init(v : int = 0):
	super(v);
	base_val = v;
	sprite = preload("res://testArt/using/cardAttack.png");
	
func _reset() -> void:
	exhaust = false;
	combo_exhaust = false;
	value = base_val;
