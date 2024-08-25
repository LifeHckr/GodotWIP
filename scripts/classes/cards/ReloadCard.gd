class_name ReloadCard extends Card

func _init(v : int):
	super(v);
	sprite = preload("res://testArt/using/cardReload.png");
	can_combo = false;

#Returns true if card is used (removed from active use, until reload)
func _use() -> bool:
	value -= 1;
	if value <= 0:
		used.emit(self);
		return true;
	else:
		return false;
	
