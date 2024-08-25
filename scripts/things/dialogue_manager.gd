extends Node

var OPTION_BUTTON = preload("res://scenes/ui/dialogue_option.tscn");
var ONLY_OPTION = preload("res://testArt/using/optionBox.png");
var OPTION_TOP = preload("res://testArt/using/optionBoxTop.png");
var OPTION_MID = preload("res://testArt/using/optionBoxMid.png");
var OPTION_BOT = preload("res://testArt/using/optionBoxBot.png");

enum STATES {IDLE, DIALOGUE, DIALOGUEDONE, OPTIONS, SELECTED, FINISHED};
var current_state : STATES = STATES.IDLE;

var empty_call : Callable = func (): pass;

var cur_player : CharacterBody2D;
var dialogue_layer : CanvasLayer;

var current_type_delay : float = .02;
var type_timer : float = 0;

var current_dialogue : DialogueObject;
var chars : int = 0;
var max_chars : int = 0;
#max 8 options before funny business
#option 0 at top then down
var option_num : int = 0;

signal dialogue_finished;
signal option_selected;

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_state == STATES.IDLE:
		return;
	type_timer += delta
	if type_timer >= current_type_delay:
		chars += 1;
		dialogue_layer.dialogue_text.visible_characters = chars;
		type_timer = 0;
	if current_state == STATES.DIALOGUE && dialogue_layer.dialogue_text.visible_characters >= max_chars:
		current_state = STATES.DIALOGUEDONE;

#returns either the option selected [0, ... x] or 0 if doDia fails or there were no options
#Current oversights: If doDia is called while already running it is UB
#Assumes the chain of dialog objects is setup correctly, otherwise theres a chance it could try calling OOB
func doDialogue(dialogue : DialogueObject) -> int:
	if dialogue == null || dialogue.is_empty():
		endDialogue();
		return 0;
	current_state = STATES.DIALOGUE;
	
	current_dialogue = dialogue;
	cur_player.transition_state(cur_player.STATES.DIALOGUE);
	max_chars = current_dialogue.text.length();
	chars = 0;
	dialogue_layer.dialogue_text.text = current_dialogue.text;
	dialogue_layer.dialogue_text.visible_characters = 0;
	dialogue_layer.dialogue_cont.visible = true;	
	
	await self.dialogue_finished;
	#endDialogue();
	var selected = await doOptions();
	if (current_dialogue.flag <= -1):
		endDialogue();
		return selected;
	elif current_dialogue.flag <= 2:
		if current_dialogue.end_call.size() > selected && current_dialogue.end_call[selected] != null:
			current_dialogue.end_call[selected].call();
			
	if current_dialogue.flag == 1:
		endDialogue();
		return selected;
	
	#check if there is actually a dialogue to run
	if current_dialogue.next_dialogue.size() > selected && current_dialogue.next_dialogue[selected] != null:
		return await doDialogue(current_dialogue.next_dialogue[selected]);
	else:
		endDialogue();
		return selected;
	
#Given the current dialogue's options, returns the option selected, or -1 if no options
func doOptions() -> int:
	if current_dialogue.options.is_empty():
		current_state = STATES.FINISHED;
		return 0;
	current_state = STATES.OPTIONS;
	
	var op_num = 0;
	for x in current_dialogue.options:
		draw_button(x, op_num);
		op_num += 1;
	dialogue_layer.cursor.position.y = 230 - 26.8 * (current_dialogue.options.size() - 1); #shut up i found numbers manually
	dialogue_layer.options.visible = true;
	option_num = 0;
	var option_picked : int = await self.option_selected;
	for x in dialogue_layer.options.get_children():
		if x is Button:
			x.queue_free();
	current_state = STATES.SELECTED;
	dialogue_layer.options.visible = false;
	return option_picked;
	
#resets to exit dialogue
func endDialogue() -> void:
	cur_player.transition_state(cur_player.STATES.IDLE);
	dialogue_layer.dialogue_cont.visible = false;
	dialogue_layer.options.visible = false;
	current_state = STATES.IDLE;
	
#input, consumes while displaying
func _unhandled_input(event: InputEvent) -> void:
	if current_state != STATES.IDLE && event.is_action_released("ui_accept"):
		input_confirm(option_num);
	if current_state == STATES.OPTIONS:
		if event.is_action_pressed("move_up"):
			option_num = posmod(option_num -1, current_dialogue.options.size());
			dialogue_layer.cursor.position.y = (230 - 26.8 * (current_dialogue.options.size() - 1)) + 26.8 * (option_num); #shut up i found numbers manually
		if event.is_action_pressed("move_down"):
			option_num = posmod(option_num +1, current_dialogue.options.size());
			dialogue_layer.cursor.position.y = (230 - 26.8 * (current_dialogue.options.size() - 1)) + 26.8 * (option_num); #shut up i found numbers manually
	
#Seperated this for clarity
func input_confirm(data : int = 0):
	if current_state == STATES.DIALOGUE:
		chars = max_chars;
	elif current_state == STATES.DIALOGUEDONE:
		dialogue_finished.emit();
	elif  current_state == STATES.OPTIONS:
		option_selected.emit(data);

#Draw and setup each option button
func draw_button(x : String = "wrong", num : int = 0):
		var option_button : Button = OPTION_BUTTON.instantiate();
		if num == 0 && current_dialogue.options.size() == 1:
			option_button.get_node("option_background").texture = ONLY_OPTION;
		elif num == 0:
			option_button.get_node("option_background").texture = OPTION_TOP;
		elif num == current_dialogue.options.size() - 1:
			option_button.get_node("option_background").texture = OPTION_BOT;
		else:
			option_button.get_node("option_background").texture = OPTION_MID;
		
		option_button.text = x;
		dialogue_layer.options.add_child(option_button);
		#option_button.pressed.connect(input_confirm.bind(num)); for now uis arent clickable
