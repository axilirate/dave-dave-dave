extends Node

var path: String = "user://stats.cfg"
var config = ConfigFile.new()


func _ready():
	if Steamworks.is_owned():
		path = Steamworks.get_user_path() + "/GameData/stats.cfg"
	config.load(path)

func exists() -> bool:
	var file = File.new()
	return file.file_exists(path)
	

func set_completed(completed: bool) -> void:
	config.set_value("stats", "completed", completed)

func set_deaths(deaths: int) -> void:
	config.set_value("stats", "deaths", deaths)


func set_time(time: float) -> void:
	config.set_value("stats", "time", time)

func get_completed() -> bool:
	if config.load(path) != OK:
		return false
	return config.get_value("stats", "completed", false)

func get_deaths() -> int:
	if config.load(path) != OK:
		return 0
	return config.get_value("stats", "deaths")
	
func get_time() -> float:
	if config.load(path) != OK:
		return 0.0
	return config.get_value("stats", "time")
	
	
func write():
	config.save(path)
