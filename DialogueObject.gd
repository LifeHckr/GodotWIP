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

func _init(_text : String = "/end", opts : Array[String] = [], next : Array[DialogueObject] = [], end : Array[Callable] = [], flagIn : int = -1) -> void:
	text = _text;
	options = opts.duplicate();
	next_dialogue = next.duplicate();
	end_call = end.duplicate();
	flag = flagIn;
	
func is_empty() -> bool:
	return text == "/end";
