extends Node

signal active_contexts_changed(active_contexts: Array[int], id_to_imc_dict: Dictionary[int, IMC])

const IMC_SET_PATH: String = "res://quacky_input_contexts_data/resources/imc_set.tres"
var imc_set: IMCSet

var active_contexts: Array[int] = [
]

func _ready() -> void:
	imc_set = load(IMC_SET_PATH) as IMCSet
	if imc_set == null:
		push_error("IMCSet nicht gefunden: " + IMC_SET_PATH)
		return
	update_current_mouse_mode()
	update_active_context_list()

#region ENABLE, DISABLE, IS_ACTIVE, UPDATE_LIST, UPDATE_MOUSE_MODE

func enable_context(context: int) -> void:
	if context == 0:
		printerr("Tried to enable global context. Global context cannot be enabled.")
		return
	if active_contexts.has(context):
		return
	else:
		active_contexts.push_back(context)
	
	update_current_mouse_mode()
	update_active_context_list()

func disable_context(context: int) -> void:
	if context == 0:
		printerr("Tried to disable global context. Global context cannot be disabled.")
		return
	if active_contexts.back() == context:
		active_contexts.pop_back()
	
	update_current_mouse_mode()
	update_active_context_list()

func is_context_active(context: int) -> bool:
	if context == 0:
		return true
	if active_contexts.is_empty():
		return false
	if active_contexts.back() == context:
		return true
	else:
		return false

func update_current_mouse_mode() -> void:
	if active_contexts.is_empty():
		return
	var current_active_context_id: int = active_contexts.back()
	var current_active_context: IMC = imc_set.id_to_imc_dict[current_active_context_id]
	var current_mouse_mode: Input.MouseMode = current_active_context.mouse_mode
	Input.mouse_mode = current_mouse_mode

func update_active_context_list() -> void:
	active_contexts_changed.emit(active_contexts, imc_set.id_to_imc_dict)

#endregion

#region EVENT_PRESSED, PRESSED, JUST_PRESSED, JUST_RELEASED

func event_is_action_pressed(event: InputEvent, action: StringName) -> bool:
	if not event.is_action_pressed(action):
		return false
	if not imc_set.action_to_imc_dict.has(action):
		return false
	var imc: IMC = imc_set.action_to_imc_dict[action]
	var id: int = imc_set.id_to_imc_dict.find_key(imc)
	return is_context_active(id)

func is_action_pressed(action: StringName) -> bool:
	if not Input.is_action_pressed(action):
		return false
	if not imc_set.action_to_imc_dict.has(action):
		return false
	var imc: IMC = imc_set.action_to_imc_dict[action]
	var id: int = imc_set.id_to_imc_dict.find_key(imc)
	return is_context_active(id)

func is_action_just_pressed(action: StringName) -> bool:
	if not Input.is_action_just_pressed(action):
		return false
	if not imc_set.action_to_imc_dict.has(action):
		return false
	var imc: IMC = imc_set.action_to_imc_dict[action]
	var id: int = imc_set.id_to_imc_dict.find_key(imc)
	return is_context_active(id)

func is_action_just_released(action: StringName) -> bool:
	if not Input.is_action_just_released(action):
		return false
	if not imc_set.action_to_imc_dict.has(action):
		return false
	var imc: IMC = imc_set.action_to_imc_dict[action]
	var id: int = imc_set.id_to_imc_dict.find_key(imc)
	return is_context_active(id)

#endregion
