class_name PlayerUsing extends PlayerState

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.velocity.y += player.gravity * _delta;
	player.velocity.x = move_toward(player.velocity.x, 0, 15);
	player.move_and_slide();
	
	if !player.anims.is_playing():
		player.owned_deck._use_card();
		player.transition_state(player.STATES.IDLE);
	elif Input.is_action_just_pressed("special") && player.aerial_action:
		player.aerial_action = false;
		player.transition_state(player.STATES.ROLLING);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.sprite.pause();
	player.anims.play("reload");
	player.owned_deck.locked = true;

func _end() -> void:
	player.anims.stop();
	player.owned_deck.locked = false;
