class_name Checkpoint
extends Area2D


export(NodePath) onready var world_scene = get_node(world_scene) as WorldScene

onready var local_player_body_data = world_scene.world_data.local_player_body_data

onready var checkpoint_editor = DataLoader.checkpoint_data as CheckpointEditor



onready var sprite = $Sprite


var activated: bool


func _ready():
	local_player_body_data.connect("activated_checkpoints_set", self, "_on_activated_checkpoints_set")
		
	checkpoint_editor.connect("activated", self, "_on_checkpoint_activated")
	_update_checkpoint()



func _on_activated_checkpoints_set():
	_update_checkpoint()




func _on_checkpoint_activated():
	if not checkpoint_editor.position == global_position:
		if activated:
			deactivate()




func _update_checkpoint():
	if checkpoint_editor.position == global_position:
		activate()
		return
		
	if local_player_body_data.activated_checkpoints.has(global_position):
		deactivate()
		return
		
	sprite.frame = 0



func activate():
	activated = true
	sprite.frame = 1
	
	

func deactivate():
	sprite.frame = 2



func _on_Checkpoint_body_entered(body):
	checkpoint_editor.set_entered_body(body)
	checkpoint_editor.set_position(global_position)
	checkpoint_editor.emit_signal("activated")
	activate()
