class_name PlayerStateMachine extends StateMachine

enum STATES {IDLE, RUNNING, JUMPING, FALLING, ROLLING, ATTACKING};

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func transitionState(next_state):
	pass
