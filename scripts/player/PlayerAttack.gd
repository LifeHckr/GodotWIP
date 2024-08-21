class_name PlayerAttack extends Area2D

var element : String = "";
var attack : int = 9;
var dmg_multi : float = 9.0;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(_body: Node2D) -> void:
	queue_free();
	pass # Replace with function body.
