class_name PlayerJumping extends PlayerState

var AERIAL;
var CAN_ATTACK;
var INTANGIBLE;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.checkTurn();
	if !player.is_on_floor():
		player.velocity.y += player.gravity * _delta;
	player.velocity.x = player.SPEED * player.x_direction;
	player.move_and_slide();
	
	if !player.owned_deck.locked && Input.is_action_just_pressed("addCombo"):
		player.doComboAction();
	elif Input.is_action_just_pressed("attack") && player.aerial_action:
		player.aerial_action = false;
		player.useCard();
	elif Input.is_action_just_pressed("special") && player.aerial_action:
		player.aerial_action = false;
		player.transition_state(player.STATES.ROLLING);
	elif player.velocity.y >= 0:
		player.transition_state(player.STATES.FALLING);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.coyoteFrames = 0;
	player.nudging = false;
	player.ray.enabled = false;
	player.aerial_action = true;
	player.sprite.play("jump");
	player.velocity.y = player.JUMP_VELOCITY;

func _end() -> void:
	player.ray.enabled = true;
