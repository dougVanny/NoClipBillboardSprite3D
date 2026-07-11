@tool
extends MeshInstance3D
class_name NoClipSprite3D

@export var texture : Texture2D:
	set(value):
		material_override.set_shader_parameter("sprite", value);
		notify_property_list_changed();
	get:
		return material_override.get_shader_parameter("sprite");

@export var size : Vector2:
	set(value):
		mesh.size = value;
		mesh.center_offset = Vector3(0.0, mesh.size.y * 0.5, 0.0);
		material_override.set_shader_parameter("pivot", pivot*mesh.size.y);
		notify_property_list_changed();
	get:
		return mesh.size;

@export var pivot : Vector2:
	set(value):
		pivot = value;
		material_override.set_shader_parameter("pivot", pivot*mesh.size.y);
		notify_property_list_changed();
	get:
		return pivot;

enum SpriteFacingDirection {CAMERA_DIRECTION, CAMERA_POSITION}
@export var facing_direction: SpriteFacingDirection:
	set(value):
		material_override.set_shader_parameter("vertexModeFacing", value);
		notify_property_list_changed();
	get:
		return material_override.get_shader_parameter("vertexModeFacing");

enum SpriteUpDirection {CAMERA_Y, LOCAL_Y}
@export var up_direction: SpriteUpDirection:
	set(value):
		material_override.set_shader_parameter("vertexModeUp", value);
		notify_property_list_changed();
	get:
		return material_override.get_shader_parameter("vertexModeUp");

func _enter_tree() -> void:
	if mesh == null:
		mesh = PlaneMesh.new();
		mesh.size = Vector2.ONE;
		mesh.center_offset = Vector3(0.0, 0.5, 0.0);
		mesh.orientation = PlaneMesh.FACE_Z;
	
	if material_override == null:
		material_override = ShaderMaterial.new();
		material_override.shader = load("res://addons/no_clip_sprite3d/no_clip_sprite.gdshader");
