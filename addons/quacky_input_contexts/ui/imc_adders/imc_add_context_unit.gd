@tool
extends VBoxContainer
class_name IMCAddContextUnit

@export var imc_context_unit_holder: GridContainer
@export var name_line_edit: LineEdit
@export var mouse_mode_option_button: OptionButton
@export var button: Button

var imc_set: IMCSet

func _ready() -> void:
	name_line_edit.text_changed.connect(_update_button.unbind(1))
	mouse_mode_option_button.item_selected.connect(_update_button.unbind(1))
	_update_button()

func setup(_imc_set: IMCSet) -> void:
	imc_set = _imc_set

func _on_button_pressed() -> void:
	if name_line_edit.text != "" && mouse_mode_option_button.selected != -1:
		if not _is_name_original(name_line_edit.text):
			return
		#add_imc_context.emit(name_line_edit.text, mouse_mode_option_button.get_item_id(mouse_mode_option_button.selected))
		if not imc_set:
			printerr(name + ": wollte einen Context hinzufügen, aber kein IMCSet vorhanden")
			return
		
		var imc: IMC = IMC.new(
			imc_set.current_id,
			name_line_edit.text,
			mouse_mode_option_button.get_item_id(mouse_mode_option_button.selected)
		 )
		imc_set.id_to_imc_dict[imc.id] = imc
		imc_set.current_id += 1
		imc_set.emit_changed.call_deferred()
		
		name_line_edit.text = ""
		mouse_mode_option_button.selected = -1
		_update_button()

func _update_button() -> void:
	if name_line_edit.text != "" && mouse_mode_option_button.selected != -1:
		if _is_name_original(name_line_edit.text):
			button.disabled = false
			return
	button.disabled = true

func _is_name_original(_name: String) -> bool:
	for imc_context_unit: IMCContextUnit in imc_context_unit_holder.get_children():
		if imc_context_unit.imc_name.to_lower() == _name.to_lower():
			return false
	return true
