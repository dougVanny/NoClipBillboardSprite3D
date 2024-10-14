@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("NoClipBillboardSprite3D", "MeshInstance3D", preload("res://addons/no_clip_billboard_sprite3d/no_clip_billboard_sprite3d.gd"), preload("res://icon.svg"));


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("NoClipBillboardSprite3D");
