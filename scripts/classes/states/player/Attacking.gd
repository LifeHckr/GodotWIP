class_name PlayerAttacking extends PlayerState

var GROUNDED;
var ATTACKING;
var CAN_ATTACK;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, 12);
	if !player.is_on_floor():
		player.velocity.y += player.gravity * _delta;
	player.move_and_slide();

	if Input.is_action_just_pressed("attack") && player.combo_anim <= player.combo_length:
		player.input_buffer = "attack";
	if Input.is_action_pressed("jump"):
		player.input_buffer = "jump";
	if Input.is_action_pressed("special"):
		player.input_buffer = "special";
	
	if !player.anims.is_playing(): # look into doing based on progress, could skip recovery frames
		player.checkTurn();
		if !player.is_on_floor():
			player.transition_state(player.STATES.FALLING);
		elif (player.doing_combo || player.input_buffer == "attack") && player.combo_anim <= player.combo_length:
			player.useCard();
			player.input_buffer = "";
		elif player.input_buffer == "jump":
			player.transition_state(player.STATES.JUMPING);
		elif player.input_buffer == "special":
			player.transition_state(player.STATES.ROLLING);
		elif player.x_direction != 0:
			player.transition_state(player.STATES.RUNNING);
		else:
			player.transition_state(player.STATES.IDLE);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.sprite.pause();
	player.aerial_action = true;
	player.velocity.y *= .5;
	player.velocity.x = player.velocity.x/2;
	if player.current_card is MagicCard:
		player.doAttack(player.magic_combos);
	else:
		player.doAttack(player.att_combos);

func _end() -> void:
	player.endCombo();
	player.anims.stop();
	player.input_buffer = "";
	player.combo_anim = 1;
	player.hitbox.monitoring = false;
