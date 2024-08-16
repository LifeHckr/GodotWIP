class_name EnemyChar extends CharacterBody2D

@onready var sprite = self.get_node("sprite");
@onready var anims = sprite.get_node("anims");
@onready var hitbox = self.get_node("hitbox");

const SPEED = 100.0
const JUMP_VELOCITY = -400.0
var hp = 36;
var poise = 4;
const base_poise = 4;

enum STATES {IDLE, WALKING, ATTACKING, KNOCKBACK, PATROLLING, CHASING};
var current_state = STATES.IDLE
var current_target;

var direction = -1;

var gravity = 980
var friction = 12;


func _ready():
	
	pass

func _physics_process(_delta):
	velocity.y += gravity * _delta;
	velocity.x = move_toward(velocity.x, 0, friction);
	match current_state:
		STATES.KNOCKBACK:
			if !sprite.is_playing():
				if current_target != null:
					transition_state(STATES.CHASING, null);
				else:
					transition_state(STATES.IDLE, null);
		STATES.IDLE:
				velocity.x = move_toward(velocity.x, 0, friction * 2);
				if abs(position.distance_to(Global.player[0].position)) < 200:
					current_target = Global.player[0];
				if current_target != null:
					transition_state(STATES.CHASING, null);
		STATES.CHASING:
			velocity.x = sign(current_target.position.x - position.x) * SPEED;
			checkTurn();
			if abs(position.x - current_target.position.x) < 1:
				velocity.x = 0;
			if not (abs(position.distance_to(current_target.position)) < 230):
				current_target = null;
				transition_state(STATES.IDLE, null);
			elif abs(position.distance_to(current_target.position)) < 100:
				transition_state(STATES.ATTACKING, null);
		STATES.ATTACKING:
			if !anims.is_playing():
				transition_state(STATES.IDLE, null);
	move_and_slide();
		
	


func transition_state(next_state, data):
	match next_state:
		STATES.KNOCKBACK:
			hitbox.monitoring = false;
			velocity = data;
			sprite.play("knockback");
		STATES.IDLE:
			velocity.x = 0;
			sprite.play("idle");
		STATES.CHASING:
			sprite.play("walking");
		STATES.ATTACKING:
			velocity.x = 0;
			anims.play("attack_2");
	current_state = next_state;

func hit(damage, knockback):
	anims.play("particles_delay");
	hp -= damage;
	if hp <= 0:
		self.queue_free();
	poise -= damage;
	if poise <= 0:
		transition_state(STATES.KNOCKBACK, knockback)
		poise = base_poise;
		
func checkTurn():
	if velocity.x != 0 && sign(velocity.x) != direction:
		scale.x *= -1;
		direction *= -1;
		
func animVeloc(veloX, veloY):
	velocity.x += direction * veloX;
	velocity.y = veloY;

func nudge(nudgerPos):
	#print_debug(nudgerPos.x - self.position.x);
	velocity = Vector2(sign(nudgerPos.x - self.position.x) * -60, 0);
	if sign(nudgerPos.x - self.position.x) == 0:
		velocity = Vector2(30, 0);
		
func _on_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	print_debug(_body);
	pass # Replace with function body.
