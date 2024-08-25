extends Node
@onready var player : Array[Node] = get_tree().get_nodes_in_group("players");

const SAVE_DIR : String = "user://saves/";
const SAVE_FILE_NAME : String = "save.savefile";
const SECURITY_KEY : String = "089SADFH";
const PATH : String = SAVE_DIR + SAVE_FILE_NAME;
var MARKER : PackedByteArray;
var data;

#Might not be the best place for this stuff
#Item IDS := fun
#for now "cards" have id's 0-99
	#Attack Cards
@onready var cards_changelater : Array[Card] = [null, PlayerAttackCard.new(0), MagicCard.new(0)];
#items will have 100+


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	verify_save_directory(SAVE_DIR);
	
	MARKER.resize(8);
	MARKER.encode_s64(0, -8008);
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
	

func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path);
	
func save_data(path : String = PATH):
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.WRITE, SECURITY_KEY);
	if file == null:
		print(FileAccess.get_open_error());
		return
	print_debug("Saving");
	for card in player[0].cur_deck:
		file.store_8(card.id);
		file.store_8(card.base_value);
	file.store_buffer(MARKER);
	file.close();
	
func load_data(path : String = PATH):
	if !FileAccess.file_exists(path):
		printerr("NO FILE!");
		return;
	var file = FileAccess.open_encrypted_with_pass(path, FileAccess.READ, SECURITY_KEY);
	if file == null:
		print(FileAccess.get_open_error());
		return;
	player[0].cur_deck.clear();
	print_debug("Loading");
	var position : int = file.get_position();
	while file.get_buffer(8).decode_s64(0) != -8008:
		file.seek(position);
		var id = file.get_8();
		var val = file.get_8();
		player[0].cur_deck.push_back(cards_changelater[id]._get_dupl(val));
		position = file.get_position();
	
	file.close();

		
	
