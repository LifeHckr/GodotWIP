class_name Pickup extends Area2D

#signal collected(obj)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	pass


func _on_body_entered(body : Node2D) -> void:
	print(body.name)
	#if body.name.match("***main_char***"):
		#collected.emit(self)
	if body.is_in_group("players"):
		body.on_pickup(self);
	pass # Replace with function body.
