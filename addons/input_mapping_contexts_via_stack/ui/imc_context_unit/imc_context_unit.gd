@tool
extends HBoxContainer
class_name IMCContextUnit

var imc_set: IMCSet
var id: int = 0
var imc_name: String = ""
var mouse_mode: Input.MouseMode = Input.MOUSE_MODE_VISIBLE

@export var context_name_edit_line: LineEdit
@export var mouse_mode_option_button: OptionButton
@export var delete_button: Button

func setup(_imc_set: IMCSet, _id: int, _imc_name: String, _mouse_mode: Input.MouseMode) -> void:
	imc_set = _imc_set
	id = _id
	imc_name = _imc_name
	mouse_mode = _mouse_mode

func _ready() -> void:
	apply()

func apply() -> void:
	context_name_edit_line.text = imc_name
	mouse_mode_option_button.selected = mouse_mode_option_button.get_item_index(mouse_mode)

func _on_name_edit_line_text_submitted(new_text: String) -> void:
	if new_text == "" or new_text == "global":
		return
	imc_set.id_to_imc_dict[self.id].name = new_text
	imc_set.emit_changed.call_deferred()

func _on_mouse_mode_option_button_item_selected(index: int) -> void:
	var mouse_mode: Input.MouseMode = mouse_mode_option_button.get_item_id(index)
	imc_set.id_to_imc_dict[self.id].mouse_mode = mouse_mode
	imc_set.emit_changed.call_deferred()

func _on_delete_button_pressed() -> void:
	imc_set.id_to_imc_dict.erase(self.id)
	imc_set.emit_changed.call_deferred()
