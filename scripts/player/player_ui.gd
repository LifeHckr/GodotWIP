extends CanvasLayer

@onready var card_controller : Control = self.get_node("Card_Display_Control");
@onready var card_anims : AnimationPlayer = card_controller.get_node("anims");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
