extends Node
@onready var player = get_tree().get_nodes_in_group("players");
@onready var UI_Layers = get_tree().get_nodes_in_group("UI_Layers");
var Player_UI : CanvasLayer = null;
#Texture load
const spriteRun = preload("res://assets/pizza-face.png");
const spriteWalk = preload("res://assets/pizza.png");


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player[0].change_portrait.connect(changePortrait);
	for layer in UI_Layers:
		if layer.name == "Player_UI":
			Player_UI = layer;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Player_UI != null:
		Player_UI.get_node("./hp_back_back/hp_back/hp_bar").size.x = 36 * (player[0].hp / player[0].base_hp);
	pass
	
	
func delayed_call(object : Node, function_name : String, delay : float) -> void:
	if !object.has_method(function_name):
		return;

	var timer = Timer.new();
	timer.timeout.connect(Callable(object, function_name));
	timer.one_shot = true;
	timer.autostart = true;
	get_tree().root.add_child.call_deferred(timer);
	timer.start.call_deferred(delay);
	
#Probably should do something different to control ui, but
func changePortrait(anim_name : String) -> void:
	if Player_UI != null:
		Player_UI.get_node("faces").play(anim_name);
