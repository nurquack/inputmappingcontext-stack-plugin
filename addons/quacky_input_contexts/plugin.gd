@tool
extends EditorPlugin

const AUTOLOAD_NAME: String = "InputManager"
const AUTOLOAD_PATH: String = "res://addons/quacky_input_contexts/runtime/input_manager.gd"
const PANEL_PATH: String = "res://addons/quacky_input_contexts/ui/imc_panel.tscn"

const IMCSET_PATH: String = "res://quacky_input_contexts_data/resources/imc_set.tres"

var panel: IMCPanel

func _enable_plugin() -> void:
	# Add autoloads here.
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		ProjectSettings.set_setting(
			"autoload/" + AUTOLOAD_NAME,
			"*" + AUTOLOAD_PATH
		)
		ProjectSettings.save()

func _disable_plugin() -> void:
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		var path: String = ProjectSettings.get_setting("autoload/" + AUTOLOAD_NAME)
		if path == "*" + AUTOLOAD_PATH:
			
			ProjectSettings.set_setting(
				"autoload/" + AUTOLOAD_NAME,
				null
			)
			ProjectSettings.save()


func _enter_tree() -> void:
	_create_panel()

func _exit_tree() -> void:
	_destroy_panel()

func _create_panel() -> void:
	var imc_set: IMCSet
	if ResourceLoader.exists(IMCSET_PATH):
		imc_set = load(IMCSET_PATH)
	else:
		DirAccess.make_dir_recursive_absolute(IMCSET_PATH.get_base_dir())
		imc_set = IMCSet.new()
		var err: Error = ResourceSaver.save(imc_set, IMCSET_PATH)
		if err != OK:
			push_error("IMCSet konnte nicht gespeichert werden: %s (%s)" % [error_string(err), IMCSET_PATH])
			return
		imc_set = load(IMCSET_PATH)
	
	panel = load(PANEL_PATH).instantiate()
	add_control_to_bottom_panel(panel, "Input Contexts")
	panel.setup(imc_set)
	
	await panel._update()
	
	await _refresh_filesystem()

func _destroy_panel() -> void:
	remove_control_from_bottom_panel(panel)
	panel.queue_free()

func _refresh_filesystem() -> void:
	var fs: EditorFileSystem = EditorInterface.get_resource_filesystem()
	while fs.is_scanning():
		await get_tree().process_frame
	fs.scan()
