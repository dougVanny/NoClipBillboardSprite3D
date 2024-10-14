extends Node3D

@export var moveSpeed:float;
@export var rotateSpeed:float;
@export var attackDuration:float;

@export var idleTexture:Texture2D;
@export var attackTexture:Texture2D;

@export_group("Node references")
@export var sprite:Sprite3D;
@export var noClipSprite:NoClipBillboardSprite3D;

@export_group("Hud")
@export var updateHud:bool;
@export var nodeType:Label;
@export var billboardType1:Label;
@export var billboardType2:Label;
@export var billboardType3:Label;

var navigationYRange:float = 0.5;

var movement:Vector2;
var cameraRotation:float;
var attackDurationLeft:float;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	setTexture(idleTexture);
	
	noClipSprite.visible = true;
	sprite.visible = false;
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	noClipSprite.billboardMode = NoClipBillboardSprite3D.BillboardMode.BILLBOARD;
	if updateHud:
		nodeType.text = "NoClipBillboardSprite3D";
		nodeType.label_settings.font_color =Color.GREEN;
		billboardType1.label_settings.font_color = Color.GREEN;
		billboardType2.label_settings.font_color = Color.DIM_GRAY;
		billboardType3.label_settings.font_color = Color.DIM_GRAY;

var frameWait:int = 1;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frameWait > 0:
		frameWait -= 1;
		return;
	
	if attackDurationLeft > 0:
		attackDurationLeft -= delta;
		if attackDurationLeft <= 0:
			setTexture(idleTexture);
	
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
		elif event.pressed:
			if event.keycode == KEY_SPACE and attackDuration > 0.0:
				attackDurationLeft = attackDuration;
				setTexture(attackTexture);
			elif event.keycode == KEY_TAB:
				noClipSprite.visible = !noClipSprite.visible;
				sprite.visible = !noClipSprite.visible;
				
				if updateHud:
					nodeType.text = "Sprite3D" if sprite.visible else "NoClipBillboardSprite3D";
					nodeType.label_settings.font_color = Color.RED if sprite.visible else Color.GREEN;
					
					if billboardType3.label_settings.font_color != Color.DIM_GRAY:
						billboardType3.label_settings.font_color = Color.RED if sprite.visible else Color.GREEN;
			elif event.keycode == KEY_1:
				sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				noClipSprite.billboardMode = NoClipBillboardSprite3D.BillboardMode.BILLBOARD;
				
				if updateHud:
					billboardType1.label_settings.font_color = Color.GREEN;
					billboardType2.label_settings.font_color = Color.DIM_GRAY;
					billboardType3.label_settings.font_color = Color.DIM_GRAY;
			elif event.keycode == KEY_2:
				sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
				noClipSprite.billboardMode = NoClipBillboardSprite3D.BillboardMode.Y_BILLBOARD;
				
				if updateHud:
					billboardType1.label_settings.font_color = Color.DIM_GRAY;
					billboardType2.label_settings.font_color = Color.GREEN;
					billboardType3.label_settings.font_color = Color.DIM_GRAY;
			elif event.keycode == KEY_3:
				sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
				noClipSprite.billboardMode = NoClipBillboardSprite3D.BillboardMode.FACING_CAMERA;
				
				if updateHud:
					billboardType1.label_settings.font_color = Color.DIM_GRAY;
					billboardType2.label_settings.font_color = Color.DIM_GRAY;
					billboardType3.label_settings.font_color = Color.GREEN;
	elif event is InputEventMouseMotion:
		cameraRotation -= event.relative.x;

func setTexture(newTexture:Texture2D) -> void:
	sprite.texture = newTexture;
	noClipSprite.texture = newTexture;
