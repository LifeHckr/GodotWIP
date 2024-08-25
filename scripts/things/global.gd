extends Node
@onready var player : Array[Node] = get_tree().get_nodes_in_group("players");


#Might not be the best place for this stuff
#Item IDS := fun
#for now "cards" have id's 0-99
	#Attack Cards
@onready var cards_changelater : Array = [null, PlayerAttackCard.new(0), MagicCard.new(0)];
#items will have 100+


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
func delayed_call(object : Node, function_name : String, delay : float) -> void:
	if !object.has_method(function_name):
		return;

	var timer : Timer = Timer.new();
	timer.timeout.connect(Callable(object, function_name));
	timer.one_shot = true;
	timer.autostart = true;
	get_tree().root.add_child.call_deferred(timer);
	timer.start.call_deferred(delay);
	
