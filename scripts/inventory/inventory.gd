class_name Inventory extends Resource

#An inventory with built in management to sort items added based on item ID
var slots : Array[Inv_Slot] = [];
var card_slots : Array[Card_Slot] = [];
var unique_items : int = 0;
var max_size : int; #-1 unlimited size, should be -1 || >0 Max size only effects item slots

func _init(_max_size : int = -1) -> void:
	max_size = _max_size;

#max_size >0 or -1
#I feel like this can be refined
#returns whether the item was added or not
func _add_item(item : int, quantity : int = 1) -> bool:
	var new_slot : Inv_Slot;
	new_slot = Inv_Slot.new(item, quantity);
	
	if _is_empty():
		slots.push_front(new_slot);
		unique_items += 1;
		return true;
	
	#is not empty, see if it exists
	for x in range(0, unique_items):
		var temp_id = slots[x]._get_itemID();
		
		#got past new item id, hasn't been added
		if temp_id > item:
			
			if max_size != -1 && unique_items >= max_size:
				return false;
				
			slots.insert(x -1, new_slot);
			unique_items += 1
			return true;
		#found item
		elif temp_id == item:
			slots[x]._increase_amount(quantity);
			return true;
	
	#not found, therefore is now largest id
	if max_size != -1 && unique_items >= max_size:
		return false;
	slots.push_back(new_slot);
	unique_items += 1;
	
	return true;
	
func _add_card(item : int, val : int, quantity : int = 1) -> bool:
	if val < 0 || val > 9:
		return false;
	var new_slot : Card_Slot;
	new_slot = Card_Slot.new(item);
	new_slot._increase_amount(val, quantity);
	
	if card_slots.is_empty():
		card_slots.push_front(new_slot);
		return true;
	
	#is not empty, see if it exists
	for x in range(0, card_slots.size()):
		var temp_id = card_slots[x]._get_itemID();
		#got past new item id, hasn't been added
		if temp_id > item:				
			slots.insert(x -1, new_slot);
			return true;
		#found item
		elif temp_id == item:
			card_slots[x]._increase_amount(val, quantity);
			return true;
	
	#not found, therefore is now largest id
	card_slots.push_back(new_slot);	
	return true;

func _rem_card(item : int, val : int) -> bool:
	if val < 0 || val > 9 || card_slots.is_empty():
		return false;
	for x in range(0, card_slots.size()):
		var temp_id = card_slots[x]._get_itemID();
		if temp_id > item:				
			return false;
		elif temp_id == item:
			return card_slots[x].decrease_amount(val);
	return false;

func _correct_slots(val : int = -1) -> Array:
	if val == -1:
		return slots;
	else:
		return card_slots;

func _get_card_slot(index : int) -> Card_Slot:
	return card_slots[index];

func _is_empty() -> bool:
	return slots.is_empty();

func _get_cards() -> Array[Card_Slot]:
	return card_slots;

func _get_items() -> Array[Inv_Slot]:
	return slots;
