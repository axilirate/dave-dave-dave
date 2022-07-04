class_name InputPacket
extends Packet


var id: int
var input: Vector2



func to_dictionary() -> Dictionary:
	var dictionary = {
		"type": Type.INPUT,
		"id": id,
		"input": input
	}
	return dictionary




func from_dictionary(dictionary: Dictionary) -> InputPacket:
	id = dictionary["id"]
	input = dictionary["input"]
	return self