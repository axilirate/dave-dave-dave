class_name DamageArea
extends Area2D


onready var damage_area_editor = DataLoader.damage_area_data as DamageAreaEditor



func _on_DamageArea_body_entered(body):
	damage_area_editor.set_last_collided_body(body)
