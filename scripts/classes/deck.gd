class_name Deck extends Node

var empty = preload("res://testArt/cardEmpty.png");


var cards : Array[Card] = [];
var battle_cards : Array[Card]; #will optimize at some point
var size : int;
var cards_remaining: int = 0;
var max_size : int;
var cursor : int = 0;
var reload_val : int;
#var deck_owner : Node2D;
var draw_to : CanvasLayer;

#TODO: add_next, add_prev
#	memory management?


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_val = 1;
	max_size = 4;
	pass # Replace with function body.

func _init_deck(owner_cards : Array[Card]):
	cards.clear();
	battle_cards.clear();
	size = 0;
	cards_remaining = 0;
	cursor = 0;
	reload_val = 1;
	
	for x in owner_cards:
		if cards_remaining >= max_size:
			break;
		_add_back(x);
		cards_remaining += 1;
	battle_cards = cards.duplicate(false); #note to self: idk how i feel about this
	var rCard = ReloadCard.new(reload_val);
	rCard.used.connect(_reload);
	_add_front(rCard);
	cards_remaining += 1;
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _add_front(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.push_front(card);
	return true;
	
func _add_back(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.push_back(card);
	return true;

func _rotate_forward():
	if cursor == 0:
		cursor = cards_remaining - 1;
	else:
		cursor -= 1;
	
	#Really messy
	var card_controller = draw_to.get_node("Card_Display_Control");
	if card_controller != null:
		card_controller.get_node("anims").play("rotate_right");
			
	await card_controller.get_node("anims").animation_finished;
	card_controller.get_node("anims").play("float_current");
	_drawDeck();

	

func _rotate_back():
	if cursor == cards_remaining - 1:
		cursor = 0;
	else:
		cursor += 1;
		
	#Really messy
	var card_controller = draw_to.get_node("Card_Display_Control");
	if card_controller != null:
		card_controller.get_node("anims").play("rotate_left");
			
	await card_controller.get_node("anims").animation_finished;
	_drawDeck();
	card_controller.get_node("anims").play("float_current");
	
func _get_current_card() -> Card:
	return cards[cursor];

#gets 'n' next or 'p' prev card from current cursor position
func _position_from_cursor(change : int = 1, dir : String = "n") -> int:
	if dir == "n":
		return posmod((cursor + change), cards_remaining);
	elif dir == "p":
		return posmod((cursor - change), cards_remaining);
	else:
		return -1;

#Cursor should exist, uses card at cursor
func _use_card():
	#Get card to use and remove from array
	var use_this = cards.pop_at(cursor);
	#if the card is used up
	if use_this is ReloadCard: #agh is breaks from signal desync
		if !use_this._use():
			cards.insert(cursor, use_this);
		return;
	if use_this._use():
		#move all cards forward into place
		#eventually put animation here
		cards_remaining -= 1;
		#if last card just roll back to pos 0
		if cursor == cards_remaining:
			cursor = 0;
	else:
		#sloppy
		pass
	_drawDeck();

func _reload(_reload_card : Card):
	#get cards from useable cards
	cards.resize(0);
	size = 0;
	if _reload_card != null:
		reload_val += 1;
	cards_remaining = 0;
	for x in battle_cards:
		if cards_remaining >= max_size:
			break;
		if !x.exhaust:
			x._on_reload();
			_add_back(x);
			cards_remaining += 1;
	#add reload card
	var rCard = ReloadCard.new(reload_val);
	rCard.used.connect(_reload);
	_add_front(rCard, true);
	cards_remaining += 1;
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();
	pass

func _drawDeck(offset : int = 0):
	if draw_to != null:
		var card_controller = draw_to.get_node("Card_Display_Control");
		if card_controller != null:
			card_controller.get_node("Current_Card").texture = cards[cursor + offset].sprite;
			card_controller.get_node("Prev_Card").texture = cards[_position_from_cursor(1 + offset, "p")].sprite;
			card_controller.get_node("Card_Forw1").texture = cards[_position_from_cursor(1 + offset, "n")].sprite;
			card_controller.get_node("Card_Forw2").texture = cards[_position_from_cursor(2 + offset, "n")].sprite;
