extends Area2D
@onready var cshape = $CollisionShape2D

var standing_cshape = preload("res://Assets/standing.tres")
var crouching_cshape = preload("res://Assets/crouching.tres")
var sliding_cshape = preload("res://Assets/sliding.tres")

func tilt():
	standing_cshape.y = 10




func _on_area_entered(area):
	tilt()
