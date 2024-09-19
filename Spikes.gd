extends Node2D





func _on_area_2d_area_entered(area):
	if area.get_parent() is Player:
		area.get_parent().die()
		


func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if area.get_parent() is Player:
		area.get_parent().die()
