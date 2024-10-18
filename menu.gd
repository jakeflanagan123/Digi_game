extends Control


func _on_play_pressed() -> void:
	Soundcontrol.play_menubutton()
	get_tree().change_scene_to_file("res://world.tscn")



func _on_options_pressed() -> void:
	Soundcontrol.play_menubutton()
	get_tree().change_scene_to_file("res://options_menu.tscn")



func _on_quit_pressed() -> void:
	Soundcontrol.play_menubutton()
	get_tree().quit()

func _on_credits_pressed() -> void:
	
	get_tree().change_scene_to_file("res://GodotCredits.tscn")
