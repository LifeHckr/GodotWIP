class_name PlayerRolling extends PlayerState

var INTANGIBLE;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.invince = true;
	if !player.is_on_floor():
		player.velocity.y += player.gravity * _delta;
	player.velocity.x = move_toward(player.velocity.x, player.direction * player.ROLL_SPEED, 40);
	player.move_and_slide();
	
	if player.is_on_floor() && Input.is_action_pressed("jump"):
		player.transition_state(player.STATES.JUMPING);
		
	if (player.sprite.get_animation() == "rolling"):
		if !player.sprite.is_playing():
			player.velocity.x = 0;
			if player.velocity.y >= 0 && !player.is_on_floor():
				player.transition_state(player.STATES.FALLING);
			elif player.x_direction != 0:
				player.transition_state(player.STATES.RUNNING);
			else:
				player.transition_state(player.STATES.IDLE);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.nudging = false;
	player.ray.enabled = false;

	#Reduce upward momentum from rolling immediately after jumping
	if player.velocity.y < -300:
		player.velocity.y = -300;
	player.set_collision_layer_value(5, false);
	player.set_collision_mask_value(5, false);

	player.sprite.play("rolling");
	player.velocity.x = player.SPEED * player.direction;

func _end() -> void:
	player.ray.enabled = true;
	player.set_collision_layer_value(5, true);
	player.set_collision_mask_value(5, true);
	player.invince = false;
