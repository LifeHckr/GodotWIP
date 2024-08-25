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
enum STATES {IDLE, RUNNING, JUMPING, FALLING, ROLLING, ATTACKING, AERIAL, KNOCKBACK, USING, DIALOGUE};
var states : Array[State] = [PlayerIdle.new(self), PlayerRunning.new(self), PlayerJumping.new(self), PlayerFalling.new(self), PlayerRolling.new(self), PlayerAttacking.new(self), PlayerAerial.new(self), PlayerKnockback.new(self), PlayerUsing.new(self), PlayerDialogue.new(self)];
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
var coyoteFrames : int = 5;

var doing_combo : bool = false;
var comboing : Array[Card];
#COMBAT================================================================================================
var max_deck_size : int = 12;
var cur_deck: Array[Card] = [MagicCard.new(1), MagicCard.new(3), PlayerAttackCard.new(1), PlayerAttackCard.new(2)];
var inventory :Inventory = Inventory.new();
var owned_deck : Deck;
var current_card : Card = null;
var attack : int = 1;
var knockback : int = 100;

@export var hit_dmg_multi: float = 1.0;
@export var hit_knockback_multi: float  = 1.0;
@export var hit_knockback_multi_up: float  = 1.0;

#STATS=================================================================================================
var base_hp : float = 100;
var base_poise : int = 99;
var SPEED : float = 300.0
var ROLL_SPEED : float = 400.0;
var JUMP_VELOCITY : float = -425.0;
var invince_time : float = .6;
var combo_length : int = 3; # has to be >0 # can only combocombo if >2
var hp : float;
var poise : int;

var strong_unlocked : bool = true;
var combo_unlocked : bool = true;

#endregion

func _ready() -> void:
	hp = base_hp;
	poise = base_poise;
	
	owned_deck = preload("res://scenes/deck.tscn").instantiate();
	add_child(owned_deck);
	owned_deck.draw_to = Player_UI;
	owned_deck._init_deck(cur_deck, max_deck_size);
	
	hitbox.body_entered.connect(_on_hitbox_body_entered.bind());
	
	Player_UI.combo_controller.visible = combo_unlocked;
	
	DialogueManager.cur_player = self;
	
	inventory._add_card(1, 9, 99);
	inventory._add_card(2, 0, 0);

func _process(_delta) -> void:
	
	#Camera offsets
	if current_state == STATES.RUNNING && !is_on_wall():
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(direction * 150, -30), 1);
	else:
		var tween : Tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(0, -30), 1);
	
	Player_UI.get_node("./hp_back_back/hp_back/hp_bar").size.x = 36 * (hp / base_hp);


func _physics_process(_delta : float) -> void:
#universal pre update
	if !"INTANGIBLE" in states[current_state]:
		nudgeFix();
	x_direction = Input.get_axis("move_left", "move_right");

	if ray.is_colliding():
		nudgeObj = ray.get_collider();
		if nudgeObj.has_method("nudge"):
			nudgeObj.nudge(self.position);

#region Debug
	#print_debug(current_state);
	if Input.is_action_just_pressed("debug1"):
		Global.save_data();
	if Input.is_action_just_pressed("debug2"):
		Global.load_data();
#endregion

	states[current_state]._physics_update(_delta);
	
	if "AERIAL" in states[current_state]:
		coyoteFrames -= 1;

#END PHYSICS PROCESS ----------------------------------------------------------------	


#region States
#True if the player successfully changed states
func transition_state(next_state) -> bool:
	
	if current_state == next_state:
		return false;

	states[current_state]._end();
	states[next_state]._start();

	current_state = next_state;
	return true;


#region Helpers

func useCard():
	
	var doing_strong : bool = false;
	if doing_combo:
		current_card = comboing.pop_front();
	else:
		current_card = owned_deck._get_current_card();
		if strong_unlocked && combo_length > 1 && Input.is_action_just_pressed("strong"): #feels scuffed
			doing_strong = true;
			combo_anim = combo_length;

	if current_card is ReloadCard:
		transition_state(STATES.USING);
		
	elif current_card is PlayerAttackCard:
		attack = current_card.value;
		
		var next_state : STATES = STATES.ATTACKING;
		var combo_to_use : Array = att_combos;

		if "AERIAL" in states[current_state]:
			next_state = STATES.AERIAL;
			combo_to_use = aer_combos;

		if current_card is MagicCard:
			combo_to_use = magic_combos;
			if "AERIAL" in states[current_state]:
				velocity.y = -250;
				
		if "ATTACKING" in states[current_state]:
			doAttack(combo_to_use);
		else:
			transition_state(next_state);

		if doing_combo:
			owned_deck._use_combo_card();
		else:
			owned_deck._use_card(doing_strong);
		current_card = null;

#Can't directly change velo in anims, and relative position changes are wierd to implement and questionable physics wise
func animVeloc(veloX: int, veloY: int) -> void:
	velocity.x += direction * veloX;
	velocity.y = veloY;

func on_pickup(obj : Node) -> void:
	obj.queue_free();

func nudge(_nudger: Node) -> void:
	pass#velocity.x = sign(_nudger.position.x - self.position.x) * -100;
	#velocity.y -= 2;
	#x_direction = 0;
	#move_and_slide();
	
func nudgeFix() -> void:
	#temp new nudge fix
	ray.enabled = true;
	var is_colliding = ray.is_colliding();
	nudgeObj = ray.get_collider();
	if is_colliding && nudgeObj.has_method("nudge"):
		velocity.y = -1;
	set_collision_layer_value(5, !ray.is_colliding());
	set_collision_mask_value(5, !ray.is_colliding());


func _hit(damage : int, dmg_knockback : Vector2) -> void:
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
	if combo_anim >= combo_length || (doing_combo && combo_anim == 3):
		hit_dmg_multi += .5;
		anims.play(combo_anim_names[2]);
		combo_anim = combo_length + 1; # just to make sure
	elif combo_anim % 2 == 0:
		anims.play(combo_anim_names[1]);
	elif combo_anim % 2 == 1:
		anims.play(combo_anim_names[0]);
	combo_anim += 1;

func doComboAction() -> void:
	if !combo_unlocked || combo_length < 3:
		return;
	if !owned_deck.locked && await owned_deck._add_cur_combo():
		doing_combo = true;
		owned_deck.locked = true;
		comboing = owned_deck._get_combo_cards();
		aerial_action = false;
		useCard();

func endCombo() -> void:
	if doing_combo:
		comboing.clear();
		owned_deck._clear_combo();
		owned_deck.locked = false;
	doing_combo = false;

func doMagicShoot():
	var p : PlayerAttack = proj.instantiate();
	owner.add_child(p);
	
	p.visible = true;
	p.element = "Fire";
	p.attack = attack;
	p.dmg_multi = hit_dmg_multi;
	
	p.position.x = position.x + direction * 30;
	p.position.y = position.y;
	p.speed = 500 * direction;
	
	p.body_entered.connect(_on_hitbox_body_entered.bind(p.element, p.attack, p.dmg_multi));
	
#Probably should do something different to control ui, but
func changePortrait(anim_name : String) -> void:
	if Player_UI != null:
		Player_UI.get_node("faces").play(anim_name);

#endregion

#region Signals

func hittable() -> void:
	invince = false;

func _on_hitbox_body_entered(_obj : Node2D, _element : String = hitbox.get_meta("element"), attack_dmg : int = attack, attack_multi : float = hit_dmg_multi) -> void:
	if _obj.has_method("_hit"):
		var dmg : int = ceil(attack_dmg * attack_multi);
		_obj._hit(dmg, Vector2(sign(_obj.position.x - self.position.x) * 100 * hit_knockback_multi , -150 * hit_knockback_multi_up), _element);
		changePortrait("yah");

#endregion
