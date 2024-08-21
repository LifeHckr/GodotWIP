extends Area2D

var speed = 0;
var element : String = "";
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x += delta * speed;


func _on_body_entered(_body: Node2D) -> void:
	queue_free();
	pass # Replace with function body.
