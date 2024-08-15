extends CharacterBody2D

#region New Code Region
var startSpeed = 400.0; #300
var drag = 1500;
var runThreshold = 500;
var runMulti = 3;
var acceleration = 0; #was 80
var maxVelocity = 1000;
var gravity = 1900;
var jumpSpeed = -605;
var jumpAccel = -1975;
var sillyTime = 0.135; #secs
@onready var sprite = self.get_node("sprite");
@onready var anims = sprite.get_node("anims");
@onready var camera = self.get_node("camera");
@onready var body = self.get_node("body");

#endregion

#region New Code Region
#states
var air = "grounded"; #grounded, inair, nojump
var facing = -1; # -1: left, # 1: right
var running = 1;
var moving = true;
var animating = 1; # 1 == false, 0 == true i know i know
var knockback =  false;

var sillyTimeTimer;
var turnTimer;
var coyoteTime;
#endregion

func _ready():
	pass

func _process(_delta):
	if (running > 1):
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(300 * facing * (abs(velocity.x)/(maxVelocity + 100)), 0), .8);
	else:
		var tween = get_tree().create_tween();
		tween.tween_property(camera, "offset", Vector2(0, 0), .8);
	pass

func _physics_process(_delta):
	#Prejack physics
	#print_debug(velocity.x)
	velocity.y += gravity * _delta * animating;
	if (is_on_floor()):
		if (air != "grounded"):
			air = "grounded";
			#anims.play("drop");

	elif (coyoteTime == null): 			
		coyoteTime = Timer.new();
		coyoteTime.wait_time = .135;
		coyoteTime.one_shot = true;
		coyoteTime.connect("timeout", _on_coyoteTimeout);
		add_child(coyoteTime);
		coyoteTime.start();
	#Run Checks
	if (abs(velocity.x) >= runThreshold && not knockback):
		running = 3;
		#sprite.texture = Global.spriteRun;
	elif (abs(velocity.x) < runThreshold):
		running = 1;
		#sprite.set_texture(Global.spriteWalk);
	
	#input
	get_input(_delta);
	if (Input.is_action_pressed("jump") && air != "nojump"):
		if (air == "grounded"):
			#anims.play("jump");
			self.sprite.play("jump");
			velocity.y = jumpSpeed;
			air = "inair";
		velocity.y += jumpAccel * _delta;
		#Silly time timer
		if (sillyTimeTimer == null):
			sillyTimeTimer = Timer.new();
			sillyTimeTimer.wait_time = .135;
			sillyTimeTimer.one_shot = true;
			sillyTimeTimer.connect("timeout", _on_SillyTimerTimeout);
			add_child(sillyTimeTimer);
			sillyTimeTimer.start();
		
	
	#End jack physics
	velocity.x = clamp(velocity.x, -1 * maxVelocity, maxVelocity);
	velocity.y = clamp(velocity.y, -1 * maxVelocity, maxVelocity);
	move_and_slide();
	


#End of physics process

#get input
func get_input(delta):
	var x_direction = Input.get_axis("move_left", "move_right");
	if (x_direction != 0):
		doRizMove(x_direction, delta);
		if is_on_floor():
			self.sprite.play("running");
	else: #no left or right is same as both here

		if (air == "grounded"):
			velocity.x = (abs(velocity.x) - (drag * delta * 1.5)) * facing;
		else:
			velocity.x = (abs(velocity.x) - (drag * delta * 1.25)) * facing;
		if (abs(velocity.x) <= drag * delta * 1.5):
			zeroVel();
			

#Do 'rizontal movement
func doRizMove(dir, delta):
	if (dir != facing):
		#Change dir
		facing = dir;
		doTurn();
		self.scale.x *= -1;
	elif (abs(velocity.x) <= startSpeed):
		velocity.x = startSpeed * dir;
		facing = dir;
		
	velocity.x += acceleration * facing * delta * running; #acceleration
	#setup for knockback stuff
	if (facing == 0 && sign(velocity.x) == sign(dir)):
		velocity.x += acceleration * dir * delta * running; #acceleration
		facing = dir;
		
	pass
	
#Might end up wanting more in here
func zeroVel():
	velocity.x = 0;
	running = 1;
	if is_on_floor():
		self.sprite.play("idle");

#Do stylish change direction
func doTurn():
	if (running > 1 && animating == 1):
		animating = 0;
		#timer
		if (turnTimer == null):
			turnTimer = Timer.new();
			turnTimer.wait_time = .1;
			turnTimer.one_shot = true;
			turnTimer.connect("timeout", _on_turnTimer);
			add_child(turnTimer);
			turnTimer.start();
	else:
		velocity.x = .85 * facing * abs(velocity.x);
	pass







#Timers
func _on_turnTimer():
	velocity.x = .95 * facing * abs(velocity.x);
	animating = 1;
	velocity.y += 69
	turnTimer.queue_free();
	turnTimer = null;
	pass

func _on_SillyTimerTimeout():
	if (air != "grounded"):
		air = "nojump";
	sillyTimeTimer.queue_free();
	sillyTimeTimer = null;
	
func _on_coyoteTimeout():
	air = "nojump"
	coyoteTime.queue_free();
	coyoteTime = null;
	pass
	

func _on_test_pickup_collected(obj):
	obj.queue_free()
	pass # Replace with function body.
