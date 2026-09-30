@tool
extends VBoxContainer
class_name IMCAddActionUnit

@export var imc_action_unit_holder: GridContainer
@export var name_line_edit: LineEdit
@export var context_option_button: IMCContextOptionButton
@export var button: Button

var imc_set: IMCSet

func _ready() -> void:
	name_line_edit.text_changed.connect(_update_button.unbind(1))
	context_option_button.item_selected.connect(_update_button.unbind(1))
	_update_button()

func setup(_imc_set: IMCSet) -> void:
	imc_set = _imc_set

func _on_button_pressed() -> void:
	if name_line_edit.text != "" && context_option_button.selected != -1:
		if not _is_name_original(name_line_edit.text):
			return
		#add_imc_action.emit(name_line_edit.text, context_option_button.get_item_id(context_option_button.selected))
		if not imc_set:
			printerr(name + ": wollte eine Action hinzufügen, aber kein IMCSet vorhanden")
			return
		
		var imc_id: int = context_option_button.get_item_id(context_option_button.selected)
		var imc: IMC = imc_set.id_to_imc_dict[imc_id]
		imc_set.action_to_imc_dict[name_line_edit.text] = imc
		imc_set.emit_changed.call_deferred()
		
		name_line_edit.text = ""
		context_option_button.selected = -1
		_update_button()

func _update_button() -> void:
	if name_line_edit.text != "" && context_option_button.selected != -1:
		if _is_name_original(name_line_edit.text):
			button.disabled = false
			return
	button.disabled = true

func _is_name_original(_name: String) -> bool:
	for imc_context_unit: IMCActionUnit in imc_action_unit_holder.get_children():
		if imc_context_unit.action == _name:
			return false
	return true
