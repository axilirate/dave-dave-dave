class_name WorldData
extends DataResource


signal online_player_bodies_data_changed
signal online_player_bodies_data_loaded


export(Resource) var local_player_body_data = local_player_body_data as PlayerBodyData setget _local_player_body_data

export(Dictionary) var online_player_bodies_data: Dictionary setget _online_player_bodies_data


export(bool) var played setget _played




func _local_player_body_data(value):
	if not DataLoader.finished:
		local_player_body_data = value


func _online_player_bodies_data(value):
	if not DataLoader.finished:
		online_player_bodies_data = value


func _played(value):
	if not DataLoader.finished:
		played = value



