extends GenericButton



onready var adventure_world_data = DataLoader.adventure_world_data as WorldData



func _on_AdventureContinueGenericButton_visibility_changed():
	if adventure_world_data.completed:
		disabled = true
		return
		
	disabled = !adventure_world_data.played

