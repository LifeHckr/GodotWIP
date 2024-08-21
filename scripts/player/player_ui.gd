extends CanvasLayer

@onready var card_controller : Control = self.get_node("Card_Display_Control");
@onready var combo_controller : Control = card_controller.get_node("Combo_Control");
@onready var combo_sprites : Array[Sprite2D] = [combo_controller.get_node("Card1"), combo_controller.get_node("Card2"), combo_controller.get_node("Card3")]
@onready var card_anims : AnimationPlayer = card_controller.get_node("anims");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
