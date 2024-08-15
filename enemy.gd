class_name Enemy extends RigidBody2D

@onready var sprite = self.get_node("sprite");
@onready var anims = self.get_node("anims");
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var hp = 36;
enum STATES {IDLE, WALKING, ATTACKING, KNOCKBACK}
var current_state = STATES.IDLE

var gravity = 980


func _ready():
	
	pass

func _physics_process(_delta):
	#velocity.y += gravity * delta
	if current_state == STATES.KNOCKBACK:
		if !sprite.is_playing():
			transition_state(STATES.IDLE, null);
		pass
	#velocity.x = move_toward(velocity.x, 0, 10);#experiment


func hit(damage, knockback):
	anims.play("particles_delay");
	hp -= damage;
	if hp <= 0:
		self.queue_free();
	transition_state(STATES.KNOCKBACK, knockback)
	
func nudge(nudgerPos):
	#print_debug(nudgerPos.x - self.position.x);
	apply_central_impulse(Vector2(sign(nudgerPos.x - self.position.x) * -60, 0));
	if sign(nudgerPos.x - self.position.x) == 0:
		apply_central_impulse(Vector2(40, 0));
	
func transition_state(next_state, data):
	if next_state == STATES.KNOCKBACK:
		apply_central_impulse(data);
		sprite.play("knockback");
	if next_state == STATES.IDLE:
		#velocity.x = 0;
		sprite.play("idle");
	current_state = next_state;



func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print_debug(body);
	pass # Replace with function body.
