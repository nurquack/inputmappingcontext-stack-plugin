extends Resource
class_name IMC

@export var id: int
@export var name: StringName
@export var mouse_mode: Input.MouseMode

func _init(_id: int = 0, _name: StringName = "", _mouse_mode: Input.MouseMode = 0 as Input.MouseMode) -> void:
	id = _id
	name = _name
	mouse_mode = _mouse_mode
