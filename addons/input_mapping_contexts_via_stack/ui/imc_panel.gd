@tool
extends Control
class_name IMCPanel

var imc_set: IMCSet

const CONTEXT_UNIT_SCENE = preload("res://addons/input_mapping_contexts_via_stack/ui/imc_context_unit/imc_context_unit.tscn")
const ACTION_UNIT_SCENE = preload("res://addons/input_mapping_contexts_via_stack/ui/imc_action_unit/imc_action_unit.tscn")

const INPUT_CONTEXTS_PATH: String = "res://my_imc_stack_data/generated/input_contexts.gd"
const INPUT_ACTIONS_PATH: String = "res://my_imc_stack_data/generated/input_actions.gd"

const IMCSET_PATH: String = "res://my_imc_stack_data/resources/imc_set.tres"

@export var imc_context_unit_holder: GridContainer
@export var imc_action_unit_holder: GridContainer
@export var imc_add_context_unit: IMCAddContextUnit
@export var imc_add_action_unit: IMCAddActionUnit
@export var imc_refresh_unit: IMCRefreshUnit

func setup(_imc_set: IMCSet) -> void:
	imc_set = _imc_set
	if not imc_set.id_to_imc_dict.has(0):
		imc_set.id_to_imc_dict[0] = IMC.new(0, "global", Input.MOUSE_MODE_VISIBLE)
	imc_set.id_to_imc_dict.sort()

func _update() -> void:
	if not imc_set:
		return
	
	if not imc_set.changed.is_connected(save):
		imc_set.changed.connect(save)
	if not imc_set.changed.is_connected(_update):
		imc_set.changed.connect(_update)
	
	_update_actions()
	_update_adders()
	_update_context_holder()
	_update_action_holder()
	_update_input_contexts_api()
	_update_input_actions_api()
	await _refresh_filesystem()

func _update_actions():
	ProjectSettings.save()
	var cf := ConfigFile.new()
	cf.load("res://project.godot")
	var actions: PackedStringArray = cf.get_section_keys("input") if cf.has_section("input") else PackedStringArray()
	
	for action: String in actions:
		if imc_set.action_to_imc_dict.has(action):
			pass
		else:
			imc_set.action_to_imc_dict[action] = imc_set.id_to_imc_dict[0]
	
	for action: String in imc_set.action_to_imc_dict:
		if actions.has(action):
			pass
		else:
			imc_set.action_to_imc_dict.erase(action)
	
	imc_set.action_to_imc_dict.sort()
	
	for action: String in imc_set.action_to_imc_dict:
		var i: int = 0
		for context_id: int in imc_set.id_to_imc_dict:
			if imc_set.id_to_imc_dict[context_id] == imc_set.action_to_imc_dict[action]:
				i += 1
		if i == 0:
			imc_set.action_to_imc_dict[action] = imc_set.id_to_imc_dict[0]

func _update_adders() -> void:
	imc_add_context_unit.setup(imc_set)
	imc_add_action_unit.setup(imc_set)
	imc_refresh_unit.setup(imc_set)

func _update_context_holder() -> void:
	for imc_context_unit: IMCContextUnit in imc_context_unit_holder.get_children():
		imc_context_unit.queue_free()
	
	var id_to_imc_dict: Dictionary[int, IMC] = imc_set.id_to_imc_dict
	for id: int in id_to_imc_dict:
		var imc_name: String = id_to_imc_dict[id].name
		var mouse_mode: Input.MouseMode = id_to_imc_dict[id].mouse_mode
		var imc_context_unit: IMCContextUnit = CONTEXT_UNIT_SCENE.instantiate() as IMCContextUnit
		if id == 0:
			imc_context_unit.context_name_edit_line.editable = false
			imc_context_unit.mouse_mode_option_button.disabled = true
			imc_context_unit.delete_button.disabled = true
		imc_context_unit.setup(imc_set, id, imc_name, mouse_mode)
		imc_context_unit_holder.add_child(imc_context_unit)

func _update_action_holder() -> void:
	for imc_action_unit: IMCActionUnit in imc_action_unit_holder.get_children():
		imc_action_unit.queue_free()

	var action_to_imc_dic: Dictionary[String, IMC] = imc_set.action_to_imc_dict
	for action: String in action_to_imc_dic:
		var imc: IMC = action_to_imc_dic[action]
		var imc_action_unit: IMCActionUnit = ACTION_UNIT_SCENE.instantiate() as IMCActionUnit
		imc_action_unit.setup(imc_set, action, imc)
		imc_action_unit_holder.add_child(imc_action_unit)


func _update_input_contexts_api() -> void:
	DirAccess.make_dir_recursive_absolute(INPUT_CONTEXTS_PATH.get_base_dir())
	
	var file: FileAccess = FileAccess.open(INPUT_CONTEXTS_PATH, FileAccess.WRITE)
	
	file.store_line("class_name InputContexts")
	
	var id_to_imc_dict: Dictionary[int, IMC] = imc_set.id_to_imc_dict
	
	for id: int in id_to_imc_dict:
		var name: String = id_to_imc_dict[id].name
		var const_name: String = name.to_upper().replace(" ", "_").replace("-", "_")
		if not const_name.is_valid_identifier():
			push_warning("Ungültiger Context-Name für Konstante: ", const_name)
			continue
		file.store_line("const " + const_name + ": int = " + str(id))
	
	file.close()

func _update_input_actions_api() -> void:
	DirAccess.make_dir_recursive_absolute(INPUT_ACTIONS_PATH.get_base_dir())
	
	var file: FileAccess = FileAccess.open(INPUT_ACTIONS_PATH, FileAccess.WRITE)
	
	file.store_line("class_name InputActions")
	
	var action_to_imc_dict: Dictionary[String, IMC] = imc_set.action_to_imc_dict
	
	for action: String in action_to_imc_dict:
		var action_name: String = action.replace(" ", "_").replace("-", "_")
		if not action_name.is_valid_identifier():
			push_warning("Ungültiger Action-Name für Konstante: ", action_name)
		file.store_line("const " + action_name + ": String = " + '"' + action + '"')
	
	file.close()

func save() -> void:
	ResourceSaver.save(imc_set, IMCSET_PATH)


func _refresh_filesystem() -> void:
	var fs: EditorFileSystem = EditorInterface.get_resource_filesystem()
	while fs.is_scanning():
		await get_tree().process_frame
	fs.scan()
