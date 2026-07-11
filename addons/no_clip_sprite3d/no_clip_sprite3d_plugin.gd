@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("NoClipSprite3D", "MeshInstance3D", preload("res://addons/no_clip_sprite3d/no_clip_sprite3d.gd"), EditorInterface.get_base_control().get_theme_icon("Sprite3D", "EditorIcons"));


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("NoClipSprite3D");
