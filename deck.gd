class_name Deck extends Node
var cards : Array[Card] = [];
var size : int;
var cards_remaining: int = 1;
var max_size : int;
var cursor : int = 0;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_size = 5;
	add_front(Card.new(1));
	add_front(Card.new(1));
	add_front(Card.new(1));
	add_front(Card.new(1));
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func add_front(card : Card) -> bool:
	if size >= max_size:
		return false;
	cards.push_front(card);
	return true;
	
func add_back(card : Card) -> bool:
	if size >= max_size:
		return false;
	cards.push_back(card);
	return true;

func rotate_back():
	if cursor == 0:
		cursor = cards_remaining - 1;
	else:
		cursor -= 1;

func rotate_forward():
	if cursor == cards_remaining:
		cursor = 0;
	else:
		cursor += 1;

#Cursor should exist, uses card at cursor
func use_card():
	var use_this = cards.pop_at(cursor);
	if use_this.use():
		for x in range (cursor, cards_remaining - 1):
			cards[x] = cards[x+1];
	
	
	pass
