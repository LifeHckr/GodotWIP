class_name PlayerNudge extends PlayerState

var AERIAL;
var CAN_ATTACK;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.velocity.y += player.gravity * _delta;
	player.move_and_slide();
	
	if !player.owned_deck.locked && Input.is_action_just_pressed("addCombo"):
		player.doComboAction();
	elif Input.is_action_just_pressed("attack"):
		player.useCard();
		player.aerial_action = false;
	elif Input.is_action_just_pressed("special"):
		player.aerial_action = false;
		player.transition_state(player.STATES.ROLLING);
	elif player.velocity.y >= 0 && player.is_on_floor():
		player.transition_state(player.STATES.FALLING);
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.nudge(player.nudgeObj);

func _end() -> void:
	player.nudging = false;
