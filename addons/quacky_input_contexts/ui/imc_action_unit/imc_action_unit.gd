@tool
extends HBoxContainer
class_name IMCActionUnit

var imc_set: IMCSet
var action: String = ""
var imc: IMC = null

@export var action_edit_line: LineEdit
@export var context_option_button: IMCContextOptionButton
@export var delete_button: Button

func setup(_imc_set: IMCSet, _action: String, _imc: IMC) -> void:
	imc_set = _imc_set
	action = _action
	imc = _imc

func _ready() -> void:
	apply()

func apply() -> void:
	if imc == null:
		return
	action_edit_line.text = action
	context_option_button.update_imc_items(imc.id, imc_set)
	#context_option_button.selected = context_option_button.get_item_index(imc.id)

func _on_action_edit_line_text_submitted(new_text: String) -> void:
	if new_text == "" or new_text == "global":
		return
	var old_action_name: String = action
	action = new_text
	var old_action_settings = ProjectSettings.get_setting("input/" + old_action_name)
	ProjectSettings.set_setting("input/" + old_action_name, null)
	ProjectSettings.set_setting("input/" + action, old_action_settings)
	var old_action_imc: IMC = imc_set.action_to_imc_dict[old_action_name]
	imc_set.action_to_imc_dict.erase(old_action_name)
	imc_set.action_to_imc_dict[action] = old_action_imc
	ProjectSettings.save()
	InputMap.load_from_project_settings()
	imc_set.emit_changed.call_deferred()

func _on_imc_context_option_button_item_selected(index: int) -> void:
	var imc_id: int = context_option_button.get_item_id(index)
	var imc: IMC = imc_set.id_to_imc_dict[imc_id]
	imc_set.action_to_imc_dict[self.action] = imc
	imc_set.emit_changed.call_deferred()

func _on_delete_button_pressed() -> void:
	if ProjectSettings.has_setting("input/" + action):
		ProjectSettings.set_setting("input/" + action, null)
	imc_set.action_to_imc_dict.erase(self.action)
	ProjectSettings.save()
	InputMap.load_from_project_settings()
	imc_set.emit_changed.call_deferred()
