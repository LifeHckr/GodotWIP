class_name Inv_Slot extends Resource

var item : int;
var amount : int;

func _init(thing : int, amou : int) -> void:
	item = thing;
	amount = amou;

func _increase_amount(quantity : int) -> void:
	amount += quantity;

func _decrease_amount(quantity : int = 0) -> bool:
	if quantity > amount:
		return false;
	amount -= quantity;
	return true;

#func _get_item() -> Item:
	#return item;
	
func _get_itemID() -> int:
	return item;
