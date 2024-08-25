extends MarginContainer

var has_loaded : bool = false;
var deck_card_group : ButtonGroup;
var card_inv_group : ButtonGroup;
var val_group : ButtonGroup;

var card_button;

var player_card_inv : Inventory;
var player_deck : Array[Card];

var card_inv_buttons : Array[Node] = [];
var deck_inv_buttons : Array[BaseButton] = [];
var cur_slot : int = 0;
var cur_val : int = 0;

var active : bool = false;
var state : String = "add"; # "rem"
var active_panel : String = ""; #card vals deck

signal finished;

@onready var cards_inv_grid = get_node("%Cards_Grid");
@onready var values_grid = get_node("%Values_Grid");
@onready var deck_grid = get_node("%Deck_Grid");


func loadStuff() -> void:
	card_inv_group = load("res://scenes/ui/card_inv_BGroup.tres");
	card_button = load("res://scenes/ui/card_in_deck.tscn");
	val_group = values_grid.get_child(0).button_group;
	deck_card_group = load("res://scenes/ui/deck_button_group.tres");
	has_loaded = true;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if active && Input.is_action_just_pressed("ui_cancel"):
		if active_panel == "card":
			endCards();
			endActive();
		elif active_panel == "vals":
			endVals();
			startCards();
		elif active_panel == "deck":
			endDeck();
			startVals();


func startActive() -> void:
	if !has_loaded:
		loadStuff();
	active = true;
	state = "add";
	cur_slot = 0;
	cur_val = 0;
	player_card_inv = Global.player[0].inventory;
	player_deck = Global.player[0].cur_deck;
	startCards();

func startCards() -> void:
	draw_card_inv();
	draw_values();
	draw_deck();
	active_panel = "card";
	var pressed : BaseButton = card_inv_group.get_pressed_button();
	if pressed != null:
		pressed.button_pressed = false;
	card_inv_buttons = cards_inv_grid.get_children();
	for button in card_inv_buttons:
		button.focus_mode = 2;
		button.disabled = false;
	card_inv_buttons[cur_slot].grab_focus();

func endCards() -> void:
	for button in cards_inv_grid.get_children():
		button.focus_mode = 0;
		button.disabled = true;

func startVals() -> void:
	active_panel = "vals";
	draw_values();
	var buttons : Array[Node] = values_grid.get_children();
	for x in range(0, 10):
		var amount : int = player_card_inv._get_card_slot(cur_slot).amounts[x];
		buttons[x].focus_mode = 2;
		if amount > 0:
			buttons[x].disabled = false;
	var pressed : BaseButton = val_group.get_pressed_button();
	if pressed != null:
		pressed.button_pressed = false;
	buttons[cur_val].grab_focus();
	
func endVals() -> void:
	var buttons : Array[Node] = values_grid.get_children();
	for button in buttons:
		button.focus_mode = 0;
		button.disabled = true;
		
func startDeck() -> void:
	active_panel = "deck";
	draw_deck();
	deck_inv_buttons = deck_card_group.get_buttons();
	for button in deck_inv_buttons:
		button.focus_mode = Control.FOCUS_ALL;
		button.disabled = false;
	var pressed : BaseButton = deck_card_group.get_pressed_button();
	if pressed != null:
		pressed.button_pressed = false;
	deck_grid.get_child(0).grab_focus();
	
func endDeck() -> void:
	var deck_buttons : Array[Node] = deck_grid.get_children();
	for button in deck_buttons:
		button.focus_mode = 0;
		button.disabled = true;

func endActive():
	active = false;
	cur_slot = 0;
	active_panel = "";
	for button in card_inv_buttons:
		button.focus_mode = 0;
		button.disabled = true;
	finished.emit();



func draw_card_inv() -> void:
	if card_inv_buttons.size() != player_card_inv.card_slots.size():
		for x in card_inv_buttons:
			x.free();
		for x in range(0, player_card_inv.card_slots.size()):
			draw_card_inv_button(x);
	
func draw_card_inv_button( x : int) -> void:
	var button : Button = card_button.instantiate();
	button.toggled.connect(inv_card_toggled.bind(x));
	button.icon = Global.cards_changelater[player_card_inv._get_card_slot(x).item].sprite;
	cards_inv_grid.add_child(button);
	button.button_group = card_inv_group;
	
func draw_card_deck_button( x : int) -> void:
	var button : Button = card_button.instantiate();
	button.toggled.connect(deck_but_toggled.bind(x));
	if x > -1:
		button.icon = player_deck[x].sprite;
	deck_grid.add_child(button);
	button.button_group = deck_card_group;

func draw_values() -> void:
	var buttons : Array[Node] = values_grid.get_children();
	for x in range(0, 10):
		var amount : int = player_card_inv._get_card_slot(cur_slot).amounts[x];
		buttons[x].text = "x%02d" % amount;

func draw_deck() -> void:
	deck_inv_buttons = deck_card_group.get_buttons();
	for button in deck_inv_buttons:
		button.queue_free();
	for x in range(0, player_deck.size()):
		draw_card_deck_button(x);
	if player_deck.size() < Global.player[0].max_deck_size:
		draw_card_deck_button(-1);

#region Signals
func inv_card_toggled(_toggled_on : bool, _slot : int):
	cur_slot = _slot;
	if _toggled_on:
		endCards();
		startVals();
	
func val_but_toggled(_toggled_on : bool, _val : int):
	cur_val = _val;
	if _toggled_on:
		endVals();
		startDeck();
	
func deck_but_toggled(_toggled_on : bool, _val : int):
	if _toggled_on:
		if _val == -1:
			player_deck.push_back(Global.cards_changelater[player_card_inv._get_card_slot(cur_slot).item]._get_dupl(cur_val));
		else:
			var removed_card : Card = player_deck.pop_at(_val);
			player_deck.insert(_val, Global.cards_changelater[player_card_inv._get_card_slot(cur_slot).item]._get_dupl(cur_val));
			player_card_inv._add_card(removed_card.id, removed_card.base_value, 1);
		player_card_inv._get_card_slot(cur_slot).decrease_amount(cur_val);
		var pressed : BaseButton = deck_card_group.get_pressed_button();
		if pressed != null:
			pressed.button_pressed = false;
		if player_card_inv._get_card_slot(cur_slot).get_amount(cur_val) <= 0:
			endDeck();
			draw_deck();
			startVals();
		else:
			draw_values();
			startDeck();
		Global.player[0].owned_deck._init_deck(player_deck, Global.player[0].max_deck_size);
#endregion
