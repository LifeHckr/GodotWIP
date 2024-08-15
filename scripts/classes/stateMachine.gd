class_name StateMachine extends Node

#Shit is borked, each child class should have a STATES enum, cant do something general here
@export var current_state: State;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
#
#func _physics_process(_delta):
	#pass
	#
	
func transitionState(next_state):
	pass
