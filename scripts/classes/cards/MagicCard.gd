class_name MagicCard extends PlayerAttackCard



func _init(v : int):
	super(v);
	id = 2;
	sprite = preload("res://testArt/using/cardMagic.png");
	
func _get_dupl(x : int) -> MagicCard:
	return MagicCard.new(x);
