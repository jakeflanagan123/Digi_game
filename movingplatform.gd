extends Path2D


@export var loop = true
@export var speed = 2.0
@export var speed_scale = 1.0

@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
		animation.play("moving_platform1")
		animation.speed_scale = speed_scale
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path.progress += speed
