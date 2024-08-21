class_name EnemyChar extends CharacterBody2D

@onready var sprite : AnimatedSprite2D = self.get_node("sprite");
@onready var anims : AnimationPlayer = sprite.get_node("anims");
@onready var body : CollisionShape2D = self.get_node("body");
@onready var hitbox : Area2D = self.get_node("hitbox");
@onready var hp_bar : ColorRect = self.get_node("./hp_back_back/hp_back/%hp_bar");
@onready var ground_check : RayCast2D = self.get_node("ground_checker");

@onready var PARTICLES = preload("res://scenes/hit_particles.tscn");
@onready var Phys = preload("res://testArt/using/particles/purple/tile190.png");
@onready var Fire = preload("res://testArt/using/particles/red/tile030.png");


var hp_bar_length : float;


const SPEED : float = 100.0
const JUMP_VELOCITY : float = -400.0
var attack : int = 5;
const base_hp : float = 7;
var hp : float;
var poise : int;
const base_poise : int = 4;

enum STATES {IDLE, WALKING, ATTACKING, KNOCKBACK, PATROLLING, CHASING, DEATH};
var current_state : STATES = STATES.IDLE
var current_target : Node2D;

var vision_range : float = 250.0;
var direction : float = -1.0;

var gravity : float = 980;
var friction : int = 12;


func _ready() -> void:
	poise = base_poise;
	hp = base_hp;
	hp_bar_length = hp_bar.size.x;

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta) -> void:
	if !is_on_floor():
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
				if checkInRange(Global.player[0], 1.0):
					current_target = Global.player[0];
				if current_target != null:
					transition_state(STATES.CHASING, null);

		STATES.CHASING:
			velocity.x = sign(current_target.position.x - position.x) * SPEED;
			checkTurn();
			if !ground_check.is_colliding() || abs(position.x - current_target.position.x) < 1:
				velocity.x = 0;
				sprite.play("idle");
			else:
				sprite.play("walking");
			if not checkInRange(current_target, 1.5):
				current_target = null;
				transition_state(STATES.IDLE, null);
			elif abs(position.distance_to(current_target.position)) < 100:
				transition_state(STATES.ATTACKING, null);
				
		STATES.ATTACKING:
			sprite.pause();
			if !anims.is_playing():
				transition_state(STATES.IDLE, null);
				
		STATES.DEATH:
			if !anims.is_playing():
				Global.player[0].changePortrait("win_blink");
				self.queue_free();
				
	move_and_slide();

func transition_state(next_state : STATES, data) -> bool:
	if current_state == next_state:
		return false;
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
			faceTarget();
			velocity.x = 0;
			anims.play("attack_2");
			
		STATES.DEATH:
			velocity = Vector2(0, 0);
			gravity = 0;
			anims.play("death");
			body.set_deferred("disabled", true);
			self.get_node("hp_back_back").queue_free();
			
			
	current_state = next_state;
	return true;

func hit(damage : int, knockback : Vector2, element : String) -> void:
	var particles : CPUParticles2D = PARTICLES.instantiate();
	add_child(particles);
	particles.texture = self.get(element);
	particles.emitting = true;
	anims.play("interrupt");
	
	hp -= damage;
	updateHP();
	if hp <= 0:
		hp = 0;
		transition_state(STATES.DEATH, null);
		return;
	poise -= damage;
	if poise <= 0:
		transition_state(STATES.KNOCKBACK, knockback)
		poise = base_poise;

func updateHP() -> void:
	hp_bar.size.x = hp_bar_length * (hp / base_hp); 

#bias visual range in the direction the enemy is facing
func checkInRange(target : Node2D, multi : float) -> bool:
	var test : bool = abs(target.position.y - position.y) < 80 * multi && target.position.x - position.x <= vision_range * multi * (1.0/4.0 * direction + (3.0/4.0))   && target.position.x - position.x >= vision_range * multi * (1.0/4.0 * direction + (-3.0/4.0));
	return test;

func checkTurn() -> void:
	if velocity.x != 0 && sign(velocity.x) != direction:
		scale.x *= -1;
		direction *= -1;

func faceTarget() -> void:
	if sign(current_target.position.x - self.position.x) != direction:
		scale.x *= -1;
		direction *= -1;
		
func animVeloc(veloX : float, veloY : float) -> void:
	velocity.x += direction * veloX;
	velocity.y = veloY;

func nudge(nudgerPos : Vector2) -> void:
	velocity = Vector2(sign(nudgerPos.x - self.position.x) * -70, 0);
	if sign(nudgerPos.x - self.position.x) == 0:
		velocity = Vector2(60, 0);
	move_and_slide();

func _on_hitbox_body_entered(obj: Node2D) -> void:
	if obj.has_method("hit"):
		var dmg : int = ceil(attack);
		obj.hit(dmg, Vector2(sign(obj.position.x - self.position.x) * 200 , -180));

		
#func _on_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	#print_debug(_body);
	#pass # Replace with function body.
