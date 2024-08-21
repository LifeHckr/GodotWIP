class_name PlayerAerial extends PlayerState

var AERIAL;
var ATTACKING;
var CAN_ATTACK;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, 7);
	player.velocity.y += player.gravity * .8 * _delta;
	player.move_and_slide();

	if Input.is_action_just_pressed("attack"):
		player.input_buffer = "attack";
	if Input.is_action_pressed("special"):
		player.input_buffer = "special";

	#Anim cancel when landing
	if player.is_on_floor() && !player.nudging:
		player.transition_state(player.STATES.FALLING);
		
	if !player.anims.is_playing():
		player.checkTurn();
		if (player.doing_combo || player.input_buffer == "attack") && player.combo_anim <= player.combo_length:
			player.useCard();
			player.input_buffer = "";
		elif player.input_buffer == "special":
			player.transition_state(player.STATES.ROLLING);
		else:
			player.transition_state(player.STATES.FALLING);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.sprite.pause();
	player.velocity.x *= .5;
	if player.current_card is MagicCard:
		player.velocity.y = -250; #TODO
		player.doAttack(player.magic_combos);
	else:
		player.doAttack(player.aer_combos);

func _end() -> void:
	player.endCombo();
	player.anims.stop();
	player.input_buffer = "";
	player.combo_anim = 1;
	player.hitbox.monitoring = false;
	player.nudging = false;
