extends Node2D

@export var mute: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not mute:
		play_music()
		
		
func play_music():
	if not mute:
		$music.play()
	if mute:
		$music.stop()
		

func play_jump() -> void:
	if not mute:
		$jump.play()
		
func play_death() -> void:
	if not mute:
		$death.play()
		
func play_menubutton() -> void:
	if not mute:
		$menubutton.play()
