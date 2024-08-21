class_name PlayerKnockback extends PlayerState

var STATIC;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.invince = true;
	player.velocity.y += player.gravity * _delta;
	player.velocity.x = move_toward(player.velocity.x, 0, 12);
	player.move_and_slide();
	
	if !player.sprite.is_playing():
		if player.is_on_floor():
			player.transition_state(player.STATES.IDLE);
		else: 
			player.transition_state(player.STATES.FALLING);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.nudging = false;
	player.ray.enabled = false;
	player.sprite.play("knockback");

func _end() -> void:
	player.aerial_action = true;
	player.ray.enabled = true;
	player.invince = false;
