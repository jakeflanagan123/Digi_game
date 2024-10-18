extends Control


func _on_back_pressed() -> void:
	Soundcontrol.play_menubutton()
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_mute_pressed():
	if Soundcontrol.mute == true:
		Soundcontrol.mute = false
		Soundcontrol.play_music()
	else:
		Soundcontrol.mute = true
		Soundcontrol.play_music()
