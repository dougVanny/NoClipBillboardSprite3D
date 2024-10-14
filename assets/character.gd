extends Node3D

@export var moveSpeed:float;
@export var rotateSpeed:float;
@export var attackDuration:float;

@export var sprite:Sprite3D;

@export var idleTexture:Texture2D;
@export var attackTexture:Texture2D;

var navigationYRange:float = 0.5;

var movement:Vector2;
var cameraRotation:float;
var attackDurationLeft:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	sprite.texture = idleTexture;

var frameWait:int = 1;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frameWait > 0:
		frameWait -= 1;
		return;
	
	if attackDurationLeft > 0:
		attackDurationLeft -= delta;
		if attackDurationLeft <= 0:
			sprite.texture = idleTexture;
	
	var newPosition = position;
	
	newPosition += basis.x * movement.x * moveSpeed * delta;
	newPosition -= basis.z * movement.y * moveSpeed * delta;
	
	position = NavigationServer3D.map_get_closest_point_to_segment(get_world_3d().navigation_map, newPosition + Vector3.UP * navigationYRange, newPosition - Vector3.UP * navigationYRange);
	
	rotate_y(cameraRotation * rotateSpeed * delta);
	cameraRotation = 0.0;

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_echo():
		var pressed = 1.0 if event.pressed else -1.0;
		
		if event.keycode == KEY_W:
			movement.y += 1.0 * pressed;
		elif event.keycode == KEY_S:
			movement.y -= 1.0 * pressed;
		elif event.keycode == KEY_A:
			movement.x -= 1.0 * pressed;
		elif event.keycode == KEY_D:
			movement.x += 1.0 * pressed;
		elif event.keycode == KEY_SPACE:
			attackDurationLeft = attackDuration;
			sprite.texture = attackTexture;
	elif event is InputEventMouseMotion:
		cameraRotation -= event.relative.x;
