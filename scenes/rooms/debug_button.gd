extends Button

@onready var thing = preload("res://scenes/enemyREDO.tscn");

func _ready() -> void:
	pass
	
func _on_pressed() -> void:
	#Global.player[0].owned_deck._reset_cards();
	#var enem = thing.instantiate()
	#get_parent().add_child(enem);
	#enem.position.x = 232;
	#enem.position.y = 0;
	#var thing2 : DialogueObject;
	#var thing4 = DialogueObject.new("HELLOW YOU PICKED OBPTION3", 0, [], []);
	#var thing5 = DialogueObject.new("Again?", 0, ["Yes", "No"]);
	#var thing7 = DialogueObject.new("I WANT TO TEST AND SEE IF THIS WORKS.", 0, ["funcCall", "Again", "Options3"], [null, thing5, thing4], [func thing(): print_debug("hello")]);
	#thing5.next_dialogue.push_front(thing7);
	#var thing3 = DialogueObject.new("this is the 2nd text");
	var thing8 = DialogueObject.new("real")
	var thing9 = DialogueObject.new("", 0, ["Yes", "Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes" ], [thing8, thing8,thing8,thing8,thing8,thing8,thing8,thing8,thing8,thing8,thing8,thing8,thing8])
	var thing7 = DialogueObject.new("Is contra fun?", 0, [], [thing9])
	#thing4.set_next(thing3);
	var thing99 = await DialogueManager.doDialogue(thing7);
	print_debug("this is the result: " + str(thing99));
