extends CanvasLayer

@onready var dialogue_text : RichTextLabel = get_node("%Dialogue_Displaye");
@onready var dialogue_cont : MarginContainer = get_node("%Dialogude_Cont");
@onready var options : VBoxContainer = get_node("%Options");
@onready var anims : AnimationPlayer = get_node("anims");
@onready var cursor : Sprite2D = get_node("%cursor");



func _ready() -> void:
	DialogueManager.dialogue_layer = self;
	dialogue_cont.visible = false;
	options.visible = false;
	pass


func _process(_delta: float) -> void:
	pass
