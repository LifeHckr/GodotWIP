class_name Card_Slot extends Inv_Slot

var amounts : Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
#i am kinda forcing this idea of inheritance here work

func _init(i : int) -> void:
	super(i, 0);
	
func _increase_amount(base_val : int, quantity : int = 1) -> void:
	super(quantity);
	amounts[base_val] += quantity;
	if amounts[base_val] > 99:
		amounts[base_val] = 99;

func decrease_amount(val : int, quantity : int = 1) -> bool:
	if quantity > amounts[val]:
		return false;
	amounts[val] -= quantity;
	return true;
	
func get_amount(val : int) -> int:
	return amounts[val];
