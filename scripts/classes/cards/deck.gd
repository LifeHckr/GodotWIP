class_name Deck extends Node

var empty = preload("res://testArt/using/cardEmpty.png");

var cards : Array[Card] = [];
var battle_cards : Array[Card]; #will optimize at some point
var size : int;
var cards_remaining: int = 0;
var max_size : int;
var cursor : int = 0;
var reload_val : int;
var draw_to : CanvasLayer;
var locked : bool = false;

var combo_cards : Array[Card];
var cards_in_combo : int = 0;


#TODO: add_next, add_prev
#	memory management?


#region Management
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reload_val = 1;
	pass # Replace with function body.
	
func _process(_delta: float) -> void:
	if !locked && Input.is_action_just_pressed("rotate_left"):
		_rotate_back();
	if !locked && Input.is_action_just_pressed("rotate_right"):
		_rotate_forward();

func _init_deck(owner_cards : Array[Card], max_card : int = 5) -> void:
#endregion
	max_size = max_card;
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
	battle_cards = cards.duplicate(false); #note to self: idk how i feel about this
	_add_rCard();
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();
	
func _drawDeck(offset : int = 0) -> void:
	if draw_to != null:
		var card_controller = draw_to.get_node("Card_Display_Control");
		if card_controller != null:
			card_controller.get_node("Current_Card").texture = cards[cursor + offset].sprite;
			card_controller.get_node("Prev_Card").texture = cards[_position_from_cursor(-1 + offset)].sprite;
			card_controller.get_node("Card_Forw1").texture = cards[_position_from_cursor(1 + offset)].sprite;
			card_controller.get_node("Card_Forw2").texture = cards[_position_from_cursor(2 + offset)].sprite;
	
#region Helpers
func _add_front(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.push_front(card);
	cards_remaining += 1;
	return true;
	
func _add_back(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.push_back(card);
	cards_remaining += 1;
	return true;

func _add_rCard() -> void:
	var rCard = ReloadCard.new(reload_val);
	rCard.used.connect(_reload);
	_add_front(rCard, true);

func _add_at_cursor(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.insert(cursor, card);
	cards_remaining += 1;
	return true;

func _rotate_forward() -> void:
	if cursor == 0:
		cursor = cards_remaining - 1;
	else:
		cursor -= 1;
	
	if draw_to != null:
		draw_to.card_anims.play("rotate_right");
	await draw_to.card_anims.animation_finished;
	_drawDeck();
	draw_to.card_anims.play("float_current");

func _rotate_back() -> void:
	if cursor == cards_remaining - 1:
		cursor = 0;
	else:
		cursor += 1;
		
	if draw_to != null:
		draw_to.card_anims.play("rotate_left");
	await draw_to.card_anims.animation_finished;
	_drawDeck();
	draw_to.card_anims.play("float_current");
	
func _get_current_card() -> Card:
	return cards[cursor];

func _get_next_card() -> Card:
	return cards[_position_from_cursor(1)];
	
func _get_prev_card() -> Card:
	return cards[_position_from_cursor(-1)];
	
#gets 'n' next or 'p' prev card from current cursor position
func _position_from_cursor(change : int = 1) -> int:
	return posmod((cursor + change), cards_remaining);
#endregion

#Cursor should exist, uses card at cursor
func _use_card() -> void:
	
	var use_this = cards.pop_at(cursor);

	if use_this is ReloadCard: #agh is breaks from signal desync
		if !use_this._use():
			cards.insert(cursor, use_this);
		return;
	if use_this._use():
		cards_remaining -= 1;
		if cursor == cards_remaining:
			cursor = 0;
	_drawDeck();

func _add_cur_combo() -> void:
	pass

func _reload(_reload_card : Card) -> void:
	#get cards from useable cards
	cards.resize(0);
	size = 0;
	cards_remaining = 0;
	
	#if null is passed in consider it a special reload action, which does not increase reload count
	if _reload_card != null:
		reload_val += 1;
	
	for x in battle_cards:
		if cards_remaining >= max_size:
			break;
		if !x.exhaust && !x.combo_exhaust:
			x._on_reload();
			_add_back(x);
	_add_rCard();
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();
