class_name PlayerBody
extends KinematicBody2D

signal second_jumped
signal stepped

enum {IDLE, MOVING, AIR}




export(NodePath) onready var world_scene = get_node(world_scene) as WorldScene

onready var player_body_editor = world_scene.world_data.player_body_data as PlayerBodyEditor
onready var player_body_data: PlayerBodyData = player_body_editor as PlayerBodyData

onready var checkpoint_data = world_scene.world_data.checkpoint_data as CheckpointData






onready var damage_area_data = DataLoader.damage_area_data as DamageAreaData
onready var second_jump_data = DataLoader.second_jump_data as SecondJumpData



export(bool) var new_game


export(bool) var controllable = true


export(int) var speed = 800
export(float) var gravity = 0.25



onready var animation_player = $AnimationPlayer
onready var jump_timer = $JumpTimer
onready var jump_audio_cooldown = $JumpAudioCooldown
onready var boots_sprite = $Sprites/BootsSprite
onready var crown_sprite = $Sprites/CrownSprite
onready var pet_body = $PetBody
onready var pet_position = $PetPosition



var jumped: bool = false
var double_jumped: bool = false

var velocity: Vector2
var displacement: Vector2







func _ready():
	checkpoint_data.connect("activated", self, "_on_checkpoint_activated")
	damage_area_data.connect("last_collided_body_set", self, "_on_damage_area_last_collided_body_set")
	player_body_editor.set_body(self)
	
	if new_game:
		player_body_editor.set_play_time(0)
		player_body_editor.set_respawn_location(global_position)
		player_body_editor.set_last_position(global_position)
		return
		
	global_position = player_body_editor.last_position






func _on_checkpoint_activated():
	if checkpoint_data.last_collided_body == self:
		player_body_editor.set_respawn_location(checkpoint_data.last_collided_position)
		




func _on_damage_area_last_collided_body_set():
	if damage_area_data.last_collided_body == self:
		_die()




func _process(delta):
	player_body_editor.add_to_play_time(delta)





func _physics_process(delta):
	if is_playing_death_animation():
		return
		
	animation_player.playback_speed = (1.0 / speed) * float(get_speed())
	
	player_body_editor.remove_from_haste(delta)
	player_body_editor.set_haste(max(0.0, player_body_editor.haste))
	
	
	displacement = move_and_slide_with_snap(Vector2(velocity.x  * get_speed(), velocity.y * speed), 
						Vector2.DOWN if gravity > 0 else Vector2.UP * int(is_on_floor()), 
						Vector2.UP if gravity > 0 else Vector2.DOWN , false, 4, PI/4, false)
						
						
	velocity.y = min(velocity.y + gravity, gravity * 10) if gravity > 0 else max(velocity.y + gravity, gravity * 10)
	
	if is_on_floor():
		velocity.y = 0
		jump_timer.start()
		jumped = false
		double_jumped = false
		
	if is_on_ceiling():
		velocity.y = gravity
		
		
		
	if is_moving():
		boots_sprite.offset.x = 2 * int(displacement.x < 0) if gravity > 0 else int(displacement.x > 0)
		crown_sprite.offset.x = 2 * int(displacement.x < 0) if gravity > 0 else int(displacement.x > 0)
		boots_sprite.flip_h = displacement.x < 0 if gravity > 0 else displacement.x > 0
		crown_sprite.flip_h = displacement.x < 0 if gravity > 0 else displacement.x > 0


		if displacement.x < 0:
			pet_position.position.x = 8

		if displacement.x > 0:
			pet_position.position.x = -8


	_play_animation_from_state(get_state())

	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider is RigidBody2D:
			collision.collider.apply_central_impulse(-collision.normal * 50)










func _move(direction: int):
	velocity.x = direction





func _jump():
	if second_jump_data.overlapping_bodies.has(self):
		player_body_editor.emit_signal("second_jumped")
#		Audio.play("res://assets/sounds/second_jump.wav", -10)
		jump_timer.start()


	if Input.is_action_just_pressed("jump"):

		if not player_body_data.double_jump:
			return

		if double_jumped:
			return

		if is_on_floor():
			return

		if not jumped and jump_timer.is_stopped():
			if jump_audio_cooldown.is_stopped():
				jump_audio_cooldown.start()
#				Audio.play("res://assets/sounds/jump.wav")

			velocity.y = -3 if gravity > 0 else 3
			double_jumped = true


		if jumped:

			if jump_audio_cooldown.is_stopped():
				jump_audio_cooldown.start()
#				Audio.play("res://assets/sounds/jump.wav")

			velocity.y = -3 if gravity > 0 else 3
			double_jumped = true



	if not jump_timer.is_stopped():
		if jump_audio_cooldown.is_stopped():
			jump_audio_cooldown.start()
#			Audio.play("res://assets/sounds/jump.wav")
		jump_timer.stop()
		jumped = true
		velocity.y = -3 if gravity > 0 else 3







func _play_animation_from_state(state: int):
	if is_playing_death_animation():
		return
		
	match state:
		IDLE:
			animation_player.play("idle")
		MOVING:
			if Input.get_action_strength("move_right") - Input.get_action_strength("move_left"):
				animation_player.play("move")
			else:
				animation_player.play("idle")
		AIR:
			animation_player.play("air")







func _die():
	player_body_editor.add_to_deaths(1)
	animation_player.play("death")






func _respawn():
	global_position = player_body_editor.respawn_location
	pet_body.global_position = pet_position.global_position
	velocity = Vector2.ZERO
	jumped = false






func get_speed() -> int:
	return (speed + (300 * int(player_body_editor.haste > 0)))





func get_state() -> int:
	if not is_on_floor() and abs(velocity.y) > 0.25:
		return AIR

	if is_moving():
		return MOVING

	return IDLE






func is_moving() -> bool:
	return displacement.x > 0.1 or displacement.x < -0.1




func is_playing_death_animation() -> bool:
	return animation_player.current_animation == "death" and animation_player.is_playing()







#export(bool) var has_crown: bool = false



#var inventory: Array





#var pet_chamber_overlapping: bool = false










#func _ready():
#	Game.damage_area_data.connect("last_collided_body_set", self, "_on_damage_area_last_collided_body_set")
#
#
#
#	if Save.exists() and not Globals.zero_deaths_mode:
#		time = Save.get_player_time()
#		double_jump = Save.get_player_double_jump()
#		if double_jump:
#			boots_sprite.show()
#		has_crown = Save.get_player_crown()
#		if has_crown:
#			crown_sprite.show()
#		diamonds_collected = Save.get_player_diamonds_collected()
#
#
#		var saved_position = Save.get_player_global_position()
#		if saved_position != null:
#			global_position = saved_position
#
#
#		inventory = Save.get_player_inventory()
##		update_inventory()
#
#	pet_body.global_position = pet_position.global_position
#
#
#
#
#
#
#
#func _on_damage_area_last_collided_body_set():
#	if Game.damage_area_data.last_collided_body == self:
#		Audio.play("res://assets/sounds/death.wav")
#		animation_player.play("death")







#













#
#
#
#func add_item_to_inventory(item: Item):
#	inventory.push_back(item)
##	update_inventory()
#
#
#
#
##func remove_item_from_inventory(item: Item):
##	inventory.erase(item)
##	update_inventory()
#
#
#
#
##func update_inventory():
##	for child in items_container.get_children():
##		child.queue_free()
##
##	for element in inventory:
##		var item: Item = element
##		var texture_rect = TextureRect.new()
##		texture_rect.name = item.name
##		texture_rect.texture = load(item.texture_path)
##		items_container.add_child(texture_rect)
##		texture_rect.modulate = item.color
##		texture_rect.set_size(Vector2(1,1))
#
#
#
#
#
#func apply_haste(haste_time: int):
#	haste = haste_time
#	haste_progress_bar.max_value = haste_time * 10
#
#
#

#
#
#
#
#func update_diamonds_collected(arg_total_diamonds) -> void:
#	diamonds_label.text = str(diamonds_collected) + "/" + str(arg_total_diamonds)
#
#
#

#
#
#
#func play_footstep():
#	Audio.play("res://assets/sounds/step.wav", -15.0, rand_range(0.85, 1.15))


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		_respawn()


func _on_PlayerBody_tree_exiting():
	player_body_editor.set_last_position(global_position)
