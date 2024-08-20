class_name Enemy extends RigidBody2D

@onready var sprite = self.get_node("sprite");
@onready var anims = self.get_node("anims");
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var hp = 36;
var poise = 1;
enum STATES {IDLE, WALKING, ATTACKING, KNOCKBACK, PATROLLING, CHASING};
var current_state = STATES.IDLE
var current_target;

var gravity = 980


func _ready():
	
	pass

func _physics_process(_delta):
	match current_state:
		STATES.KNOCKBACK:
			if !sprite.is_playing():
				transition_state(STATES.IDLE, null);
		STATES.IDLE:
			if Global.player.position.x == 0:
				current_target = Global.player;


func transition_state(next_state, data):
	match next_state:
		STATES.KNOCKBACK:
			apply_central_impulse(data);
			#sprite.play("knockback");
		STATES.IDLE:
			linear_velocity.x = 0;
			sprite.play("idle")
	current_state = next_state;

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
		apply_central_impulse(Vector2(30, 0));

#func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	#print_debug(body);
	#pass # Replace with function body.
