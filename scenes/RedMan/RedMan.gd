extends Sprite


onready var animation_player = $AnimationPlayer
export (bool) var idle_playing = false



func _ready():
	if idle_playing:
		animation_player.play("idle")



func _on_Area2D_area_entered(area: Node2D):
	animation_player.play("death")
	area.queue_free()