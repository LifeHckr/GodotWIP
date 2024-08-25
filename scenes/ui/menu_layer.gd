extends CanvasLayer

@onready var cards_panel : MarginContainer = get_node("%Cards_Panel");
@onready var menu_opts : Array[Node] = $"%Menu_Opts".get_children();
@onready var menu_opts_group : ButtonGroup = menu_opts[0].button_group;
var active_menu : Control = null;

#temp
signal menu_opened;
signal menu_closed;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	cards_panel.visible = false;
	visible = false;
	
	#temp
	menu_closed.connect(Callable(Global.player[0], "transition_state").bind(0));
	menu_opened.connect(Callable(Global.player[0], "transition_state").bind(9));
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#temp
	if Input.is_action_just_pressed("menu") && !self.visible:
		openMenu();
	elif Input.is_action_just_pressed("ui_cancel") && active_menu == $"%Menu_Opts":
		closeMenu();
	
	if active_menu != null && active_menu.has_method("update"):
		active_menu.update();
	
func openMenu():
	self.visible = true;
	menu_opened.emit();
	beginActive();
	
func closeMenu():
	self.visible = false;
	menu_closed.emit();
	endActive();
	active_menu = null;

func update():
	pass
	
func beginActive():
	var pressed : BaseButton = menu_opts_group.get_pressed_button();
	if pressed != null:
		pressed.button_pressed = false;
	for button in menu_opts:
		if button is Button:
			button.focus_mode = 2;
			button.disabled = false;
	menu_opts[0].grab_focus();
	active_menu = $"%Menu_Opts";
	
func endActive():
	for button in menu_opts:
		if button is Button:
			button.focus_mode = 0;
			button.disabled = true;

func _on_cards_toggled(toggled_on: bool) -> void:
	cards_panel.visible = toggled_on;
	endActive();
	if toggled_on:
		active_menu = cards_panel;
		cards_panel.startActive();
		
func active_finished() -> void:
	beginActive();
	pass

func _on_inventory_toggled(_toggled_on: bool) -> void:
	pass
