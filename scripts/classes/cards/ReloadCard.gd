class_name ReloadCard extends Card

func _init(v : int = 0):
	super(v);
	sprite = preload("res://testArt/using/cardReload.png");
	can_combo = false;

#Returns true if card is used (removed from active use, until reload)
func _use() -> bool:
	if value == 1:
		used.emit(self);
		return true;
	else:
		value -= 1;
		return false;
	
