extends Button

@onready var thing = preload("res://scenes/enemyREDO.tscn");


func _on_pressed() -> void:
	#Global.player[0].owned_deck._reset_cards();
	#var enem = thing.instantiate()
	#get_parent().add_child(enem);
	#enem.position.x = 232;
	#enem.position.y = 0;
	var thing2 : DialogueObject;
	var thing4 = DialogueObject.new("HELLOW YOU PICKED OBPTION3");
	var thing5 = DialogueObject.new("Again?", ["Yes", "No"], [], [], 0);
	thing2 = DialogueObject.new("I WANT TO TEST AND SEE IF THIS WORKS.", ["Pr Deb", "Again", "Options3"], [null, thing5, thing4], [func thing(): print_debug("hello")], 0);
	thing5.next_dialogue.push_front(thing2);
	var thing3 = await DialogueManager.doDialogue(thing2);
	print_debug("this is the result: " + str(thing3));
