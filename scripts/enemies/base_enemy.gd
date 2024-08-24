class_name Enemy extends CharacterBody2D


@onready var sprite : AnimatedSprite2D = self.get_node("sprite");
@onready var anims : AnimationPlayer = sprite.get_node("anims");
@onready var body : CollisionShape2D = self.get_node("body");
@onready var hitbox : Area2D = self.get_node("hitbox");
@onready var hp_bar : ColorRect = self.get_node("./hp_back_back/hp_back/%hp_bar");
@onready var ground_check : RayCast2D = self.get_node("ground_checker");

var hp_bar_length : float;


var SPEED : float;
var JUMP_VELOCITY : float;
var attack : int;
var base_hp : float;
var hp : float;
var poise : int;
var base_poise : int;

var gravity : float;
var friction : int;

func _updateHP(damage: int) -> void:
	hp -= damage;
	hp_bar.size.x = hp_bar_length * (hp / base_hp); 

func _hit(_damage : int, _knockback : Vector2, _element : String) -> void:
	pass

func _death() -> void:
	pass;
