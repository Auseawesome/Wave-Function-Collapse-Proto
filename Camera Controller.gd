extends Camera2D

@export var speed: float = 250
@export var zoomSpeed: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_offset(Vector2(175,125))
	set_zoom(Vector2(1,1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		set_offset(get_offset()+Vector2(speed*delta,0))
	if Input.is_action_pressed("ui_left"):
		set_offset(get_offset()+Vector2(-speed*delta,0))
	if Input.is_action_pressed("ui_up"):
		set_offset(get_offset()+Vector2(0,-speed*delta))
	if Input.is_action_pressed("ui_down"):
		set_offset(get_offset()+Vector2(0,speed*delta))
	if Input.is_action_pressed("zoom_in"):
		set_zoom(get_zoom()*(1.1**zoomSpeed))
	if Input.is_action_pressed("zoom_out"):
		set_zoom(get_zoom()/(1.1**zoomSpeed))
