class_name Player extends CharacterBody2D


#region Onready parts
@onready var sprite : AnimatedSprite2D = self.get_node("sprite");
@onready var anims : AnimationPlayer = sprite.get_node("anims");
@onready var camera : Camera2D = self.get_node("camera");
@onready var body : CollisionShape2D = self.get_node("body");
@onready var hitbox : Area2D = self.get_node("hitbox");
@onready var ray : RayCast2D = self.get_node("Ray");
@onready var Player_UI : CanvasLayer = self.get_node("Player_UI");
#@onready var states : StateMachine = self.get_node("PlayerStateMachine");
#endregion


#region Declarations
#STATES ==============================================================================================
enum STATES {IDLE, RUNNING, JUMPING, FALLING, ROLLING, ATTACKING, AERIAL, KNOCKBACK, NUDGE, USING};
var states : Array[State] = [PlayerIdle.new(self), PlayerRunning.new(self), PlayerJumping.new(self), PlayerFalling.new(self), PlayerRolling.new(self), PlayerAttacking.new(self), PlayerAerial.new(self), PlayerKnockback.new(self), PlayerNudge.new(self), PlayerUsing.new(self)];
var initial_state : STATES = STATES.IDLE;
var current_state : STATES = initial_state;
const aer_combos : Array[String] = ["new_aerial_1", "new_aerial_2", "new_aerial_3"];
const att_combos : Array[String] = ["new_ground_attack_1", "new_ground_attack_2", "new_ground_attack_3"];
const magic_combos : Array[String] = ["cast", "cast", "cast_finisher"]

#PRELOADS ============================================================================================
var proj = preload("res://scenes/projectile.tscn");

#CONSTS=================================================================================================
const gravity : int = 980

#STATE MANAGEMENT=====================================================================================
var direction : float = -1;
var x_direction : float = 0;
var input_buffer : String = "";
var aerial_action : bool = true;
var nudging : bool = false;
var nudgeObj : Object;
var combo_anim : int = 1;
var invince : bool = false;
var gravity_multi : float = 1;

var coyoteFrames = 5;

#COMBAT================================================================================================
var cur_deck: Array[Card] = [MagicCard.new(1), MagicCard.new(1), MagicCard.new(1), MagicCard.new(1), MagicCard.new(1), PlayerAttackCard.new(2), PlayerAttackCard.new(2), PlayerAttackCard.new(2), PlayerAttackCard.new(2), PlayerAttackCard.new(2), PlayerAttackCard.new(2)];
var owned_deck : Deck;
var current_card : Card = null;
var attack : int = 1;
var knockback : int = 100;

@export var hit_dmg_multi: float = 1.0;
@export var hit_knockback_multi: float  = 1.0;
@export var hit_knockback_multi_up: float  = 1.0;

#STATS=================================================================================================
var base_hp : float = 100;
var base_poise : int = 7;
var SPEED : float = 300.0
var ROLL_SPEED : float = 400.0
var JUMP_VELOCITY : float = -425.0;
var invince_time : float = .6;
var combo_length : int = 3; # has to be >0
var hp : float;
var poise : int;

#endregion

func _ready() -> void:
	hp = base_hp;
	poise = base_poise;
	
	owned_deck = preload("res://scenes/deck.tscn").instantiate();
	add_child(owned_deck);
	owned_deck.draw_to = Player_UI;
	owned_deck._init_deck(cur_deck, 12);
	
	hitbox.body_entered.connect(_on_hitbox_body_entered.bind(hitbox.get_meta("element")));

func _process(_delta) -> void:
	
	#Camera offsets
	if current_state == STATES.RUNNING && !is_on_wall():
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(direction * 150, -30), 1);
	else:
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(0, -30), 1);
	
	Player_UI.get_node("./hp_back_back/hp_back/hp_bar").size.x = 36 * (hp / base_hp);

func _physics_process(_delta : float) -> void:
#universal pre update

	x_direction = Input.get_axis("move_left", "move_right");

	if ray.is_colliding():
		nudgeObj = ray.get_collider();
		if nudgeObj.has_method("nudge"):
			nudging = true;
			nudgeObj.nudge(self.position);

#region Debug
	#print_debug(current_state);
	if Input.is_action_just_pressed("debug1"):
		transition_state(STATES.KNOCKBACK);
	if Input.is_action_just_pressed("debug2"):
		doMagicShoot();
#endregion

	states[current_state]._physics_update(_delta);
	
	if "AERIAL" in states[current_state]:
		coyoteFrames -= 1;
#region Old Update
	#match current_state:		
	##NUDGE -- GET OUT OF COLLs ---------------------
		#STATES.NUDGE:
			#velocity.y += gravity * _delta;
			#move_and_slide();
			#
			#if Input.is_action_just_pressed("attack"):
				#useCard();
				#aerial_action = false;
			#elif Input.is_action_just_pressed("special"):
				#aerial_action = false;
				#transition_state(STATES.ROLLING);
			#elif velocity.y >= 0 && is_on_floor():
				#transition_state(STATES.FALLING);
				#
	##IDLE ----Standing still------------
		#STATES.IDLE:
			#velocity.y += gravity * _delta;
			#move_and_slide();
			#
			#if nudging || (velocity.y >= 0 && !is_on_floor()):
				#transition_state(STATES.FALLING);
			#elif Input.is_action_just_pressed("attack"):
				#useCard();
			#elif Input.is_action_just_pressed("special"):
				#transition_state(STATES.ROLLING);
			#elif Input.is_action_pressed("jump"):
				#transition_state(STATES.JUMPING);
			#elif x_direction != 0:
				#transition_state(STATES.RUNNING);
		#
	##RUNNING -----------Moving On Ground ---------------
		#STATES.RUNNING:
			#checkTurn();
			#velocity.y += gravity * _delta;
			#velocity.x = SPEED * x_direction;
			#move_and_slide();
			#
			#if nudging || (velocity.y >= 0 && !is_on_floor()):
				#transition_state(STATES.FALLING);
			#elif Input.is_action_pressed("jump"):
				#transition_state(STATES.JUMPING);
			#elif Input.is_action_just_pressed("attack"):
				#useCard();
			#elif Input.is_action_just_pressed("special"):
				#transition_state(STATES.ROLLING);
			#elif x_direction == 0:
				#transition_state(STATES.IDLE);
		#
	##JUMPING ------Self Explanatory-------------
		#STATES.JUMPING:
			#checkTurn();
			#velocity.y += gravity * _delta;
			#velocity.x = SPEED * x_direction;
			#move_and_slide();
			#
			#if Input.is_action_just_pressed("attack") && aerial_action:
				#aerial_action = false;
				#useCard();
			#elif Input.is_action_just_pressed("special") && aerial_action:
				#aerial_action = false;
				#transition_state(STATES.ROLLING);
			#elif is_on_floor():
				#transition_state(STATES.FALLING);
			#elif velocity.y >= 0 && !is_on_floor():
				#transition_state(STATES.FALLING);
		#
	##FALLING --------In air, not doing other action ------------------
		#STATES.FALLING:
			#checkTurn();
			#velocity.y += gravity * _delta;
			#velocity.x = SPEED * x_direction;
			#move_and_slide();
			#
			#if Input.is_action_just_pressed("attack") && aerial_action:
				#aerial_action = false;
				#useCard();
			#elif Input.is_action_just_pressed("special") && aerial_action:
				#aerial_action = false;
				#transition_state(STATES.ROLLING);
			#elif nudging:
				#transition_state(STATES.NUDGE);
			#elif is_on_floor() && x_direction != 0:
				#transition_state(STATES.RUNNING);
			#elif is_on_floor() && velocity.y >= 0:
				#transition_state(STATES.IDLE);
						#
	##ROLLING --------------Dodge roll------------------------
		#STATES.ROLLING:
			#invince = true;
			#velocity.y += gravity * _delta;
			#velocity.x = move_toward(velocity.x, direction * ROLL_SPEED, 40);
			#move_and_slide();
			#
			##I wanted jumping to cancel rolls, but it does weird things if you jump while in an enemy
			#if is_on_floor() && Input.is_action_pressed("jump"):
				#transition_state(STATES.JUMPING);
				#
			#if (sprite.get_animation() == "rolling"):
				#if !sprite.is_playing():
					#velocity.x = 0;
					#if velocity.y >= 0 && !is_on_floor():
						#transition_state(STATES.FALLING);
					#elif x_direction != 0:
						#transition_state(STATES.RUNNING);
					#else:
						#transition_state(STATES.IDLE);
		#
	##ATTACKING -------Melee attack on ground----------------
		#STATES.ATTACKING:
			#velocity.x = move_toward(velocity.x, 0, 12);
			#velocity.y += gravity * _delta;
			#move_and_slide();
#
			#if Input.is_action_just_pressed("attack") && combo_anim <= combo_length:
				#input_buffer = "attack";
			#if Input.is_action_pressed("jump"):
				#input_buffer = "jump";
			#if Input.is_action_pressed("special"):
				#input_buffer = "special";
			#
			#if nudging: #idk if this si still necessary for att state
				#transition_state(STATES.FALLING);
				#
			#if !anims.is_playing(): # look into doing based on progress, could skip recovery frames
				#checkTurn();
				#if !is_on_floor():
					#transition_state(STATES.FALLING);
				#elif input_buffer == "attack" && combo_anim <= combo_length:
					#useCard();
					#input_buffer = "";
				#elif input_buffer == "jump":
					#transition_state(STATES.JUMPING);
				#elif input_buffer == "special":
					#transition_state(STATES.ROLLING);
				#elif x_direction != 0:
					#transition_state(STATES.RUNNING);
				#else:
					#transition_state(STATES.IDLE);
		#
	##AERIAL -- Melee in air --------------------------
		#STATES.AERIAL:
			#velocity.x = move_toward(velocity.x, 0, 7);
			#velocity.y += gravity * .8 * _delta;
			#move_and_slide();
			#
			#if Input.is_action_just_pressed("attack"):
				#input_buffer = "attack";
			#if Input.is_action_pressed("special"):
				#input_buffer = "special";
			#
			##Anim cancel when landing
			#if is_on_floor() && !nudging:
				#transition_state(STATES.FALLING);
				#
			#if !anims.is_playing():
				#checkTurn();
				#if input_buffer == "attack" && combo_anim <= combo_length:
					#useCard();
					#input_buffer = "";
				#elif input_buffer == "special":
					#transition_state(STATES.ROLLING);
				#else:
					#transition_state(STATES.FALLING);
	#
	##KNOCKBACK ----------------------------------------------------------------
		#STATES.KNOCKBACK:
			#invince = true;
			#velocity.y += gravity * _delta;
			#velocity.x = move_toward(velocity.x, 0, 12);
			#move_and_slide();
			#
			#if !sprite.is_playing():
				#if is_on_floor():
					#transition_state(STATES.IDLE);
				#else: 
					#transition_state(STATES.FALLING);
	#
	##USING -- animation for doing extra actions like reloading
		#STATES.USING:
#
			#velocity.y += gravity * _delta;
			#velocity.x = move_toward(velocity.x, 0, 15);
			#move_and_slide();
			#
			#if !anims.is_playing():
				#owned_deck._use_card();
				#transition_state(STATES.IDLE);
			#elif Input.is_action_just_pressed("special") && aerial_action:
				#aerial_action = false;
				#transition_state(STATES.ROLLING);
#endregion
#END PHYSICS PROCESS ----------------------------------------------------------------	


#region States
#True if the player successfully changed states
func transition_state(next_state) -> bool:
	
	if current_state == next_state:
		return false;

	#end_state(current_state);
	states[current_state]._end();
	states[next_state]._start();
#region Old Transition
	#match next_state:
		#STATES.NUDGE:
			#nudge(nudgeObj);
#
		#STATES.JUMPING:
			#nudging = false;
			#ray.enabled = false;
			#aerial_action = true;
			#sprite.play("jump");
			#velocity.y = JUMP_VELOCITY;
#
		#STATES.RUNNING:
			#aerial_action = true;
			#sprite.play("running");
#
		#STATES.FALLING:
			#sprite.play("falling");
#
		#STATES.IDLE:
			#aerial_action = true;
			#sprite.play("idle");
			#velocity.x = 0;
#
		#STATES.ROLLING:
			#nudging = false;
			#ray.enabled = false;
#
			##Reduce upward momentum from rolling immediately after jumping
			#if velocity.y < -300:
				#velocity.y = -300;
			#self.set_collision_layer_value(5, false);
			#self.set_collision_mask_value(5, false);
#
			#sprite.play("rolling");
			#velocity.x = SPEED * direction;
#
		#STATES.ATTACKING:
			#sprite.pause();
			#aerial_action = true;
			#velocity.y *= .5;
			#velocity.x = velocity.x/2;
			#if current_card is MagicCard:
				#doAttack(magic_combos);
			#else:
				#doAttack(att_combos);
#
		#STATES.AERIAL:
			#sprite.pause();
			#velocity.x *= .5;
			#if current_card is MagicCard:
				#velocity.y = -250;
				#doAttack(magic_combos);
			#else:
				#doAttack(aer_combos);
#
		#STATES.KNOCKBACK:
			#nudging = false;
			#ray.enabled = false;
			#sprite.play("knockback");
		#
		#STATES.USING:
			#sprite.pause();
			#anims.play("reload");
			#owned_deck.locked = true;
#endregion

	current_state = next_state;
	return true;

func end_state(next_state) -> void:
	match next_state:
		STATES.NUDGE:
			nudging = false;

		STATES.JUMPING:
			ray.enabled = true;

		STATES.FALLING:
			pass

		STATES.ROLLING:
			ray.enabled = true;
			self.set_collision_layer_value(5, true);
			self.set_collision_mask_value(5, true);
			invince = false;

		STATES.ATTACKING:
			anims.stop();
			input_buffer = "";
			combo_anim = 1;
			hitbox.monitoring = false;

		STATES.AERIAL:	
			anims.stop();
			input_buffer = "";
			combo_anim = 1;
			hitbox.monitoring = false;
			nudging = false;

		STATES.KNOCKBACK:
			aerial_action = true;
			ray.enabled = true;
			invince = false;

		STATES.USING:
			anims.stop();
			owned_deck.locked = false;

#endregion

#region Helpers

func useCard():
	
	current_card = owned_deck._get_current_card();
	
	if current_card is PlayerAttackCard:
		attack = current_card.value;
		
		var next_state : STATES;
		var combo_to_use : Array = att_combos;
		if "AERIAL" in states[current_state]:
			next_state = STATES.AERIAL;
			combo_to_use = aer_combos;
		else:
			next_state = STATES.ATTACKING;
				
		if current_card is MagicCard:
			combo_to_use = magic_combos;
				
		if "ATTACKING" in states[current_state]:
			if "AERIAL" in states[current_state]:
				velocity.y = -250;
			doAttack(combo_to_use);
		else:
			transition_state(next_state);

		owned_deck._use_card();
		current_card = null;
		
	elif current_card is ReloadCard:
		transition_state(STATES.USING);
				
#Can't directly change velo in anims, and relative position changes are wierd to implement and questionable physics wise
func animVeloc(veloX: int, veloY: int) -> void:
	velocity.x += direction * veloX;
	velocity.y = veloY;

func on_pickup(obj : Node) -> void:
	obj.queue_free();

func nudge(nudger: Node) -> void:
	velocity.x = sign(nudger.position.x - self.position.x) * -100;
	velocity.y -= 2;
	x_direction = 0;
	move_and_slide();
	
func hit(damage : int, dmg_knockback : Vector2) -> void:
	if !invince:
		hp -= damage;
		changePortrait("hurt");
		poise -= damage;
		invince = true;
		if poise <= 0:
			velocity = dmg_knockback;
			transition_state(STATES.KNOCKBACK);
			poise = base_poise;
		else:
			Global.delayed_call(self, "hittable", invince_time);

func checkTurn() -> void:
	if x_direction != 0 && x_direction != direction:
		self.scale.x *= -1;
		direction = x_direction;
		
func doAttack(combo_anim_names : Array[String]) -> void:
	hit_dmg_multi = 1.0; #might cause the exploit i have in mind
	if combo_anim >= combo_length:
		hit_dmg_multi = 1.5;
		anims.play(combo_anim_names[2]);
	elif combo_anim % 2 == 0:
		anims.play(combo_anim_names[1]);
	elif combo_anim % 2 == 1:
		anims.play(combo_anim_names[0]);
	combo_anim += 1;
	
func doMagicShoot():
	var p = proj.instantiate();
	owner.add_child(p);
	p.visible = true;
	p.element = "Fire";
	p.position.x = position.x + direction * 30;
	p.position.y = position.y;
	p.speed = 500 * direction;
	p.body_entered.connect(_on_hitbox_body_entered.bind(p.element));
	
#Probably should do something different to control ui, but
func changePortrait(anim_name : String) -> void:
	if Player_UI != null:
		Player_UI.get_node("faces").play(anim_name);

#endregion

#region Signals

func hittable() -> void:
	invince = false;

func _on_hitbox_body_entered(_obj : Node2D, _element : String = " ") -> void:
	if _obj.has_method("hit"):
		var dmg = ceil(attack * hit_dmg_multi);
		_obj.hit(dmg, Vector2(sign(_obj.position.x - self.position.x) * 100 * hit_knockback_multi , -150 * hit_knockback_multi_up), _element);
		changePortrait("yah");

#endregion
