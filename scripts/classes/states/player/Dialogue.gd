class_name PlayerDialogue extends PlayerState

var STATIC;
var INTANGIBLE;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	player.invince = true;
	if !player.is_on_floor():
		player.velocity.y += player.gravity * _delta;
	player.move_and_slide();
	
func _handle_input() -> void:
	pass
	
func _start() -> void:
	player.Player_UI.visible = false;
	player.anims.stop();
	player.nudging = false;
	player.ray.enabled = false;
	player.velocity.x = 0;
	player.sprite.play("idle");

func _end() -> void:
	player.Player_UI.visible = true;
	player.aerial_action = true;
	player.ray.enabled = true;
	player.invince = false;
