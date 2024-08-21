class_name PlayerRunning extends PlayerState

var GROUNDED;
var CAN_ATTACK;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.checkTurn();
	player.velocity.y += player.gravity * _delta;
	player.velocity.x = player.SPEED * player.x_direction;
	player.move_and_slide();
	
	if player.nudging || (player.velocity.y >= 0 && !player.is_on_floor()):
		player.transition_state(player.STATES.FALLING);
	elif Input.is_action_pressed("jump"):
		player.transition_state(player.STATES.JUMPING);
	elif !player.owned_deck.locked && Input.is_action_just_pressed("addCombo"):
		player.doComboAction();
	elif Input.is_action_just_pressed("attack"):
		player.useCard();
	elif Input.is_action_just_pressed("special"):
		player.transition_state(player.STATES.ROLLING);
	elif player.x_direction == 0:
		player.transition_state(player.STATES.IDLE);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.coyoteFrames = 5;
	player.aerial_action = true;
	player.sprite.play("running");

func _end() -> void:
	pass
