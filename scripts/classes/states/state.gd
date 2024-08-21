class_name State extends RefCounted
var player : Node2D;

#signal ending;

func _init(owner : Node2D):
	player = owner;

func _ready() -> void:
	pass
	
func _update(_delta) -> void:
	pass

func _physics_update(_delta) -> void:
	pass
	
func _start() -> void:
	pass

func _end() -> void:
	pass
