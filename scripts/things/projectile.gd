class_name Projectile extends PlayerAttack

var speed = 0;
var lifespan = 100;

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	lifespan -= 1;
	if lifespan <= 0:
		queue_free();

func _physics_process(delta: float) -> void:
	position.x += delta * speed;


func _on_body_entered(_body: Node2D) -> void:
	queue_free();
	pass # Replace with function body.
