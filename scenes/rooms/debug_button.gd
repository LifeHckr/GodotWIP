extends Button

@onready var thing = preload("res://scenes/enemyREDO.tscn");


func _on_pressed() -> void:
	Global.player[0].owned_deck._reset_cards();
	var enem = thing.instantiate()
	get_parent().add_child(enem);
	enem.position.x = 232;
	enem.position.y = 0;
	
