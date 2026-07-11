extends Node3D

@export var moveSpeed:float;
@export var attackDuration:float;

@export var rotateSpeed:float;
@export var cameraRollSpeed:float;
@export var cameraRollMax:float;

@export var idleTexture:Texture2D;
@export var attackTexture:Texture2D;

@export_group("Node references")
@export var camera : Camera3D;
@export var noClipSpriteArray : Array[NoClipSprite3D];

@export_group("Hud")
@export var facingDirectionLabel:Label;
@export var upDirectionLabel:Label;

var navigationYRange:float = 0.5;

var movement:Vector2;
var cameraRotation:float;
var cameraRoll:float;
var attackDurationLeft:float;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	setTexture(idleTexture);
	
	for noClipSprite in noClipSpriteArray:
		noClipSprite.visible = true;
		noClipSprite.facing_direction = NoClipSprite3D.SpriteFacingDirection.CAMERA_DIRECTION;
		noClipSprite.up_direction = NoClipSprite3D.SpriteUpDirection.CAMERA_Y;
	
	updateLabels()

func _process(delta: float) -> void:
	if NavigationServer3D.map_get_iteration_id(get_world_3d().navigation_map) == 0:
		return;

	if attackDurationLeft > 0:
		attackDurationLeft -= delta;
		if attackDurationLeft <= 0:
			setTexture(idleTexture);
	
	var newPosition = position;
	
	newPosition += basis.x * movement.x * moveSpeed * delta;
	newPosition -= basis.z * movement.y * moveSpeed * delta;
	
	newPosition = NavigationServer3D.map_get_closest_point_to_segment(get_world_3d().navigation_map, newPosition + Vector3.UP * navigationYRange, newPosition - Vector3.UP * navigationYRange);

	if newPosition.length() != 0:
		position = newPosition
	
	rotate_y(cameraRotation * rotateSpeed * delta);
	cameraRotation = 0.0;

	if cameraRoll == 0 and camera.rotation_degrees.z != 0:
		var camera_sign = sign(camera.rotation_degrees.z)
		camera.rotation_degrees.z += -sign(camera.rotation_degrees.z) * cameraRollSpeed * delta;
		if camera_sign != sign(camera.rotation_degrees.z):
			camera.rotation_degrees.z = 0
	else:
		camera.rotation_degrees.z += cameraRoll * cameraRollSpeed * delta;
		camera.rotation_degrees.z = sign(camera.rotation_degrees.z) * min(abs(camera.rotation_degrees.z), cameraRollMax)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_echo():
		var pressed = 1.0 if event.pressed else -1.0;
		
		if event.keycode == KEY_W:
			movement.y += pressed;
		elif event.keycode == KEY_S:
			movement.y -= pressed;
		elif event.keycode == KEY_A:
			movement.x -= pressed;
		elif event.keycode == KEY_D:
			movement.x += pressed;
		elif event.keycode == KEY_Q:
			cameraRoll -= pressed;
		elif event.keycode == KEY_E:
			cameraRoll += pressed;
		elif event.pressed:
			if event.keycode == KEY_SPACE and attackDuration > 0.0:
				attackDurationLeft = attackDuration;
				setTexture(attackTexture);
			elif event.keycode == KEY_1:
				var idx = NoClipSprite3D.SpriteFacingDirection.values().find(noClipSpriteArray[0].facing_direction) + 1
				if idx >= len(NoClipSprite3D.SpriteFacingDirection.values()):
					idx = 0
				for noClipSprite in noClipSpriteArray:
					noClipSprite.facing_direction = NoClipSprite3D.SpriteFacingDirection.values()[idx]
				updateLabels()
			elif event.keycode == KEY_2:
				var idx = NoClipSprite3D.SpriteUpDirection.values().find(noClipSpriteArray[0].up_direction) + 1
				if idx >= len(NoClipSprite3D.SpriteUpDirection.values()):
					idx = 0
				for noClipSprite in noClipSpriteArray:
					noClipSprite.up_direction = NoClipSprite3D.SpriteUpDirection.values()[idx]
				updateLabels()
	elif event is InputEventMouseMotion:
		cameraRotation -= event.relative.x;

func updateLabels() -> void:
	facingDirectionLabel.text = NoClipSprite3D.SpriteFacingDirection.keys()[NoClipSprite3D.SpriteFacingDirection.values().find(noClipSpriteArray[0].facing_direction)]
	upDirectionLabel.text = NoClipSprite3D.SpriteUpDirection.keys()[NoClipSprite3D.SpriteUpDirection.values().find(noClipSpriteArray[0].up_direction)]

func setTexture(newTexture:Texture2D) -> void:
	for noClipSprite in noClipSpriteArray:
		noClipSprite.texture = newTexture;
