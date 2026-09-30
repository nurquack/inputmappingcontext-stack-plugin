@tool
extends OptionButton
class_name IMCContextOptionButton

func update_imc_items(_id: int, imc_set: IMCSet) -> void:
	clear()
	for id: int in imc_set.id_to_imc_dict:
		var context_name: String = imc_set.id_to_imc_dict[id].name
		var context_mouse_mode: String
		match imc_set.id_to_imc_dict[id].mouse_mode:
			0:
				context_mouse_mode = "Visible"
			1:
				context_mouse_mode = "Hidden"
			2:
				context_mouse_mode = "Captured"
			3:
				context_mouse_mode = "Confined"
			4:
				context_mouse_mode = "Confined Hidden"
		add_item(context_name + ": " + context_mouse_mode, id)
	
	if imc_set.id_to_imc_dict.has(_id):
		select(get_item_index(_id))
	else:
		select(0)
