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
	if !locked && Input.is_action_just_pressed("remCombo"):
		_rem_cur_combo();

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
	cards.shuffle();
	_add_rCard();
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();
	
func _drawDeck(offset : int = 0) -> void:
	if draw_to == null:
		return;
	var card_controller : Control = draw_to.card_controller;
	if card_controller != null:
		card_controller.get_node("Current_Card").texture = cards[cursor + offset].sprite;
		card_controller.get_node("Prev_Card").texture = cards[_position_from_cursor(-1 + offset)].sprite;
		card_controller.get_node("Card_Forw1").texture = cards[_position_from_cursor(1 + offset)].sprite;
		card_controller.get_node("Card_Forw2").texture = cards[_position_from_cursor(2 + offset)].sprite;
	
func _drawCombo() -> void:
	if draw_to == null:
		return
	for x in range(0, 3):
		if x < cards_in_combo:
			draw_to.combo_sprites[x].texture = combo_cards[x].sprite;
		else:
			draw_to.combo_sprites[x].texture = empty;

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
	var rCard : ReloadCard = ReloadCard.new(reload_val);
	rCard.used.connect(_reload);
	_add_front(rCard, true);

#Adds behind cursor
func _add_at_cursor(card : Card, ignoreLimit : bool = false) -> bool:
	if size >= max_size && !ignoreLimit:
		return false;
	cards.insert(cursor + 1, card);
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

func _get_combo_cards() -> Array[Card]:
	return combo_cards.duplicate();

#endregion

#Cursor should exist, uses card at cursor
func _use_card(shouldExhaust : bool = false) -> void:
	var use_this : Card = cards.pop_at(cursor);
	use_this.exhaust = shouldExhaust;
	
	if use_this is ReloadCard:
		if !use_this._use():
			cards.insert(cursor, use_this);
		return;
		
	if use_this._use():
		cards_remaining -= 1;
		if cursor == cards_remaining:
			cursor = 0;
	_drawDeck();

func _add_cur_combo() -> bool:
	if cards_in_combo >= 3:
		return true; #TODO
	if !_get_current_card().can_combo:
		return false;
	var card_to_move : Card = cards.pop_at(cursor);
	card_to_move.combo_exhaust = true;
	combo_cards.push_back(card_to_move);
	cards_remaining -= 1;
	cards_in_combo += 1;
	if cursor >= cards_remaining-1:
		cursor -= 1;
	if draw_to != null:
		draw_to.card_anims.play("send_current");
		await draw_to.card_anims.animation_finished;
		_drawDeck();
		_drawCombo();
		draw_to.card_anims.play("float_current");
	return false;

func _rem_cur_combo(exhaust : bool = false) -> void:
	if cards_in_combo < 1:
		return;
	var card_to_move : Card = combo_cards.pop_back();
	card_to_move.combo_exhaust = exhaust;
	if !exhaust:
		_add_at_cursor(card_to_move, true);
	cards_in_combo -= 1;
	if draw_to != null:
		draw_to.card_anims.play("recv_current");
		await draw_to.card_anims.animation_finished;
		_drawDeck();
		_drawCombo();
		draw_to.card_anims.play("float_current");
		
func _use_combo_card():
	var _use_this : Card = combo_cards.pop_front();
	_use_this.combo_exhaust = false;
	_use_this._use();
	cards_in_combo -= 1;
	_drawCombo();

func _clear_combo():
	while cards_in_combo > 0:
		_rem_cur_combo(true);
	
func _reload(_reload_card : Card) -> void:
	#get cards from useable cards
	cards.resize(0);
	size = 0;
	cards_remaining = 0;
	
	#if null is passed in consider it a special reload action, which does not increase reload count
	if _reload_card != null:
		reload_val += 1;
	
	for x : Card in battle_cards:
		if cards_remaining >= max_size:
			break;
		if !x.exhaust && !x.combo_exhaust:
			x._on_reload();
			_add_back(x);
	cards.shuffle();
	_add_rCard();
	if cards_remaining > 1:
		cursor = 1;
	size = cards_remaining;
	_drawDeck();

func _reset_cards() -> void:
	reload_val = 1;
	for x in battle_cards:
		x._reset();
	_reload(null);
