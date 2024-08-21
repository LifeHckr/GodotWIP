class_name PlayerUsing extends PlayerState

var PARTICLES = preload("res://scenes/effect_particles.tscn");

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	if !player.is_on_floor():
		player.velocity.y += player.gravity * _delta;
	player.velocity.x = move_toward(player.velocity.x, 0, 15);
	player.move_and_slide();
	
	if !player.anims.is_playing():
		var particles : CPUParticles2D = PARTICLES.instantiate();
		player.add_child(particles);
		particles.emitting = true;
			
		player.owned_deck._use_card();
		if player.current_card.value <= 0:
			player.transition_state(player.STATES.IDLE);
		else:
			player.anims.play("reload_cont");
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
	player.current_card = null;
	player.owned_deck.locked = false;
