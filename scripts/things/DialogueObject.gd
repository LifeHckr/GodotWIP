class_name DialogueObject extends RefCounted

var text : String;
var options : Array[String];
var next_dialogue : Array[DialogueObject];
var end_call : Array[Callable];
#FLAGS:
#-1 end immediately
#0 normal logic:
	#if options do next [selection] and end [selection]
#2 only do dialogue
#1 only do end call
var flag : int;

func _init(_text : String = "/end", flagIn : int = -1, opts : Array[String] = [], next : Array[DialogueObject] = [], end : Array[Callable] = []) -> void:
	text = _text;
	if text == "/end":
		return;
	options = opts.duplicate();
	next_dialogue = next.duplicate();
	end_call = end.duplicate();
	flag = flagIn;

func is_empty() -> bool:
	return text == "/end";

func set_text(_text : String = "/end"):
	text = _text;
	
func set_next(_option_next : DialogueObject):
	next_dialogue.push_back(_option_next);

#Always adds new option to end of options array, if next or end call are supplied tries to fill the array, if neccessary, to keep them lined up
func add_option(_option_text : String, _option_next : DialogueObject = null, _option_call : Callable = DialogueManager.empty_call):
	options.push_back(_option_text);
	if options.size() > next_dialogue.size():
		for x in range(0, next_dialogue.size()):
			next_dialogue.push_back(null);			
	next_dialogue.push_back(_option_next);
	
	if options.size() > end_call.size():
		for x in range(0, next_dialogue.size()):
			next_dialogue.push_back(null);
	next_dialogue.push_back(_option_next);
