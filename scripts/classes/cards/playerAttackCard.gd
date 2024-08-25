class_name PlayerAttackCard extends Card

var id : int = 1;

func _init(v : int):
	super(v);
	sprite = preload("res://testArt/using/cardAttack.png");
	
func _reset() -> void:
	super();
	exhaust = false;
	combo_exhaust = false;

func _get_dupl(x : int) -> PlayerAttackCard:
	return PlayerAttackCard.new(x);
