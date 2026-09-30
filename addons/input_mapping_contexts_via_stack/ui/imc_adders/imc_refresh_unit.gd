@tool
extends VBoxContainer
class_name IMCRefreshUnit

var imc_set: IMCSet

func setup(_imc_set: IMCSet) -> void:
	imc_set = _imc_set

func _on_button_pressed() -> void:
	if imc_set:
		imc_set.emit_changed.call_deferred()
