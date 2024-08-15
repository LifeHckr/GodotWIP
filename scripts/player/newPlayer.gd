class_name Player extends CharacterBody2D


const SPEED = 300.0
const ROLL_SPEED = 400.0
const JUMP_VELOCITY = -500.0
var attack = 3;
var knockback = 180;

const gravity = 980
@onready var sprite = self.get_node("sprite");
@onready var anims = sprite.get_node("anims");
@onready var camera = self.get_node("camera");
@onready var body = self.get_node("body");
@onready var hitbox = self.get_node("hitbox");
@onready var particles = self.get_node("particles");
@onready var ray = self.get_node("Ray");
enum STATES {IDLE, RUNNING, JUMPING, FALLING, ROLLING, ATTACKING, AERIAL, KNOCKBACK, NUDGE};
var initial_state = STATES.IDLE;
var current_state = initial_state;
#no direction var, do it based on scale???
#left is dir -1, right dir 1
#nvm it breaks shit
var direction = -1;
var x_direction = 0;
var combo_anim = 0;
var combo_until_finisher = 2; # has to be >0
var input_buffer = null;
var aerial_action = true;
var nudging = false;
var nudgeObj;


func _ready():
	
	pass;
	
func _process(_delta):
	
	#Camera offsets
	if current_state == STATES.RUNNING:
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(direction * 150, 0), 1);
	else:
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(0, 0), 1);
	pass

func _physics_process(_delta):
	#universal pre update
	
#region Debug
	print_debug(current_state);
	if Input.is_action_just_pressed("debug1"):
		self.set_collision_layer_value(5, true);
		self.set_collision_mask_value(5, true);
	if Input.is_action_just_pressed("debug2"):
		self.set_collision_layer_value(5, false);
		self.set_collision_mask_value(5, false);
#endregion
	x_direction = Input.get_axis("move_left", "move_right");

	if ray.is_colliding():
		nudgeObj = ray.get_collider();
		if nudgeObj != null && nudgeObj.has_method("nudge"):
			nudging = true;
			nudgeObj.nudge(self.position);
			
	#NUDGE -- GET OUT OF COLLs
	if current_state == STATES.NUDGE:
		velocity.y += gravity * _delta;
		move_and_slide();
		if Input.is_action_just_pressed("attack"):
			transition_state(STATES.AERIAL);
			aerial_action = false;
			nudging = false;
		elif Input.is_action_just_pressed("special"):
			aerial_action = false;
			transition_state(STATES.ROLLING);
			nudging = false;
		elif velocity.y == 0 && is_on_floor():
			nudging = false;
			transition_state(STATES.FALLING);
	#IDLE
	elif current_state == STATES.IDLE:
		velocity.y += gravity * _delta;
		move_and_slide();
		if Input.is_action_pressed("jump"):
			transition_state(STATES.JUMPING);
		elif Input.is_action_just_pressed("attack"):
			transition_state(STATES.ATTACKING);
		elif Input.is_action_just_pressed("special"):
			transition_state(STATES.ROLLING);
		elif nudging || (velocity.y >= 0 && !is_on_floor()):
			transition_state(STATES.FALLING);
		elif x_direction != 0:
			transition_state(STATES.RUNNING);
		pass
		
	#RUNNING
	elif current_state == STATES.RUNNING:
		if x_direction != 0 && x_direction != direction:
			self.scale.x *= -1;
			direction = x_direction;
		velocity.y += gravity * _delta;
		velocity.x = SPEED * x_direction;
		if Input.is_action_pressed("jump"):
			transition_state(STATES.JUMPING);
		elif Input.is_action_just_pressed("attack"):
			transition_state(STATES.ATTACKING);
		elif Input.is_action_just_pressed("special"):
			transition_state(STATES.ROLLING);
		elif x_direction == 0:
			transition_state(STATES.IDLE);
		elif velocity.y >= 0 && !is_on_floor():
			transition_state(STATES.FALLING);
		move_and_slide();

		pass
		
	#JUMPING
	elif current_state == STATES.JUMPING:
		nudging = false;
		if x_direction != 0 && x_direction != direction:
			self.scale.x *= -1;
			direction = x_direction;
		velocity.y += gravity * _delta;
		velocity.x = SPEED * x_direction;
		move_and_slide();
		if Input.is_action_just_pressed("attack") && aerial_action:
			aerial_action = false;
			transition_state(STATES.AERIAL);
		elif Input.is_action_just_pressed("special") && aerial_action:
			aerial_action = false;
			#velocity.y *= .5;
			transition_state(STATES.ROLLING);
		elif is_on_floor():
			transition_state(STATES.IDLE);
		elif velocity.y >= 0 && !is_on_floor():
			transition_state(STATES.FALLING);
		pass
		
	#FALLING
	elif current_state == STATES.FALLING:
		if x_direction != 0 && x_direction != direction:
			self.scale.x *= -1;
			direction = x_direction;
		velocity.y += gravity * _delta;
		velocity.x = SPEED * x_direction;
		move_and_slide();
		if Input.is_action_just_pressed("attack") && aerial_action:
			aerial_action = false;
			transition_state(STATES.AERIAL);
		elif Input.is_action_just_pressed("special") && aerial_action:
			aerial_action = false;
			transition_state(STATES.ROLLING);
		#elif is_on_floor() && x_direction != 0:
			#transition_state(STATES.RUNNING);
		elif nudging:
			transition_state(STATES.NUDGE);
		elif is_on_floor() && velocity.y == 0:
			transition_state(STATES.IDLE);
		pass
		
	#ROLLING
	elif current_state == STATES.ROLLING:
		nudging = false;
		velocity.y += gravity * _delta;
		velocity.x = move_toward(velocity.x, direction * ROLL_SPEED, 50);
		move_and_slide();
		if is_on_floor() && Input.is_action_pressed("jump"):
			transition_state(STATES.JUMPING);
		if (sprite.get_animation() == "rolling"):
			if !sprite.is_playing():
				velocity.x = 0;
				if velocity.y >= 0 && !is_on_floor():
					transition_state(STATES.FALLING);
				elif x_direction != 0:
					transition_state(STATES.RUNNING);
				else:
					transition_state(STATES.IDLE);
				
		pass
		
	#ATTACKING -- Will eventually split
	elif current_state == STATES.ATTACKING:
		velocity.x = move_toward(velocity.x, 0, 12);
		velocity.y += gravity * _delta;
		move_and_slide();
		
		if input_buffer == null: # could make this state machine too, so states have inherent priority
			if Input.is_action_just_pressed("attack") && combo_anim <= combo_until_finisher:
				input_buffer = "attack";
			if Input.is_action_pressed("jump"):
				input_buffer = "jump";
			if Input.is_action_pressed("special"):
				input_buffer = "special";
		#print_debug(input_buffer);
		if nudging:
			transition_state(STATES.NUDGE);
		if !sprite.is_playing(): # look into doing based on progress, could skip recovery frames
			hitbox.monitoring = false;
			if x_direction != 0 && x_direction != direction:
				self.scale.x *= -1;
				direction = x_direction;
			if !is_on_floor():
				transition_state(STATES.FALLING)
			elif input_buffer == "attack" && combo_anim <= combo_until_finisher:
				if combo_anim == combo_until_finisher:
					velocity.x += direction * 200;
					combo_anim += 1;
					knockback = 380;
					sprite.play("ground_attack_3");
					hitbox.monitoring = true;
				elif combo_anim % 2 == 1:
					velocity.x += direction * 230;
					combo_anim += 1;
					knockback = 210;
					sprite.play("ground_attack_2");
					hitbox.monitoring = true;
				elif combo_anim % 2 == 0:
					velocity.x += direction * 150;
					combo_anim += 1;
					knockback = 210;
					sprite.play("ground_attack_1");
					hitbox.monitoring = true;
				input_buffer = null;
			elif input_buffer == "jump":
				transition_state(STATES.JUMPING);
			elif input_buffer == "special":
				transition_state(STATES.ROLLING);
			elif x_direction != 0:
				transition_state(STATES.RUNNING);
			else:
				transition_state(STATES.IDLE);
		pass
		
	#AERIAL -- attacking in teh air
	elif current_state == STATES.AERIAL:
		velocity.x = move_toward(velocity.x, 0, 7);
		velocity.y += gravity * .8 * _delta;
		move_and_slide();
		
		if Input.is_action_just_pressed("attack"):
			input_buffer = "attack";
		if Input.is_action_pressed("special"):
			input_buffer = "special";
		
		if is_on_floor() && !nudging:
			transition_state(STATES.IDLE);
		if !sprite.is_playing():
			hitbox.monitoring = false;
			if x_direction != 0 && x_direction != direction:
				self.scale.x *= -1;
				direction = x_direction;
			if input_buffer == "attack" && combo_anim <= combo_until_finisher:
				if combo_anim == combo_until_finisher:
					velocity.y = -225;
					velocity.x += direction * 220;
					knockback = 280;
					combo_anim += 1;
					sprite.play("aerial_3");
					hitbox.monitoring = true;
				elif combo_anim % 2 == 1:
					velocity.y = -350;
					velocity.x += direction * 160;
					combo_anim += 1;
					knockback = 180;
					sprite.play("aerial_2");
					hitbox.monitoring = true;
				elif combo_anim % 2 == 0:
					velocity.y = -250;
					velocity.x += direction*240;
					combo_anim += 1;
					knockback = 180;
					sprite.play("aerial_1");
					hitbox.monitoring = true;
				input_buffer = null;
			elif input_buffer == "special":
				transition_state(STATES.ROLLING);
			else:
				nudging = false;
				transition_state(STATES.FALLING);
		pass	
	
	pass
	
func transition_state(next_state):
	if current_state == next_state:
		return 0;
	hitbox.monitoring = false;
	self.set_collision_layer_value(5, true);
	self.set_collision_mask_value(5, true);
	input_buffer = null;
	combo_anim = 1;
	if next_state == STATES.NUDGE:
		nudge(nudgeObj);
	if next_state == STATES.JUMPING:
		sprite.play("jump");
		velocity.y = JUMP_VELOCITY;
	elif next_state == STATES.RUNNING:
		aerial_action = true;
		sprite.play("running");
	elif next_state == STATES.FALLING:
		sprite.play("falling");
	elif next_state == STATES.IDLE:
		aerial_action = true;
		sprite.play("idle");
		velocity.x = 0;
	elif next_state == STATES.ROLLING:
		if velocity.y < -300:
			velocity.y = -300;
		sprite.play("rolling");
		velocity.x = SPEED * direction;
		self.set_collision_layer_value(5, false);
		self.set_collision_mask_value(5, false);
	elif next_state == STATES.ATTACKING:
		knockback = 180;
		hitbox.monitoring = true;
		velocity.y *= .5;
		velocity.x = velocity.x/2 + 150 * direction;
		sprite.play("ground_attack_1");
	elif next_state == STATES.AERIAL:
		knockback = 180;
		hitbox.monitoring = true;
		velocity.y = -250;
		velocity.x *= .5;
		velocity.x += direction*200;
		sprite.play("aerial_1");
	current_state = next_state;
	pass


func _on_hitbox_body_entered(_obj):
	#anims.play("particles_delay");
	if _obj.has_method("hit"):
		_obj.hit(attack, Vector2(sign(_obj.position.x - self.position.x) * knockback , -150));
		pass
	pass # Replace with function body.
	
func on_pickup(obj):
	#print_debug(obj.name);
	obj.queue_free();
	pass

func nudge(nudger):
	velocity.x = sign(nudger.position.x - self.position.x) * -100;
	velocity.y -= 2;
	x_direction = 0;
	move_and_slide();
	
#func _on_test_pickup_collected(obj):
	#obj.queue_free();
	#pass # Replace with function body.
