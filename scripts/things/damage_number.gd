extends Marker2D

@onready var label : Label = get_node("Label");

var amount : int = 0;
var speed : Vector2 = Vector2(0, 0);
var type : String = "";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.set_text(str(amount));
	
	#label.set("theme_override_colors/font_color", Color("red"))
	
	var tween : Tween = self.create_tween();
	tween.tween_property(self, "scale", Vector2(1, 1), .5);
	tween.tween_property(self, "scale", Vector2(0, 0), .25);
	tween.parallel().tween_property(self, "modulate", Color(255, 255, 255, 0), .25);
	tween.tween_callback(self.queue_free);
	tween.play();
	
func _process(_delta: float) -> void:
	position.x += speed.x;
	position.y += speed.y;
