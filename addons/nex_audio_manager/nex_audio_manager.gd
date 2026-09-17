@tool
extends EditorPlugin

const AUDIO_MANAGER_PATH: String = "res://addons/nex_audio_manager/Scenes/audio_manager.tscn"
const BUS_LAYOUT_PATH: String = "res://addons/nex_audio_manager/Resources/bus_layout.tres"

var _submenu: PopupMenu

enum MenuAction {
	SYNC_BUSES,
}

func _enable_plugin() -> void:
	add_autoload_singleton("AudioManager", AUDIO_MANAGER_PATH)
	_setup_buses_from_enum()

func _disable_plugin() -> void:
	remove_autoload_singleton("AudioManager")
	ProjectSettings.set_setting("audio/buses/default_bus_layout", "")
	ProjectSettings.save()

func _enter_tree() -> void:
	_submenu = PopupMenu.new()
	_submenu.add_item("Sync Buses from Enum", MenuAction.SYNC_BUSES)
	_submenu.id_pressed.connect(_on_submenu_id_pressed)
	
	add_tool_submenu_item("Nex Audio Manager", _submenu)

func _exit_tree() -> void:
	remove_tool_menu_item("Nex Audio Manager")
	if _submenu:
		_submenu.queue_free()

func _on_submenu_id_pressed(id: int) -> void:
	match id:
		MenuAction.SYNC_BUSES:
			_setup_buses_from_enum()

func _setup_buses_from_enum() -> void:
	var keys: Array = AudioEnums.Buses.keys()

	for key in keys:
		var bus_name: String = key.capitalize()
		if key in ["SFX", "UI"]:
			bus_name = key
			
		if AudioServer.get_bus_index(bus_name) != -1:
			continue
			
		var new_index: int = AudioServer.bus_count
		AudioServer.add_bus(new_index)
		AudioServer.set_bus_name(new_index, bus_name)
		if new_index > 0:
			AudioServer.set_bus_send(new_index, &"Master")

	var layout: AudioBusLayout = AudioServer.generate_bus_layout()
	ResourceSaver.save(layout, BUS_LAYOUT_PATH)
	ProjectSettings.set_setting("audio/buses/default_bus_layout", BUS_LAYOUT_PATH)
	ProjectSettings.save()
	print("[NexAudioManager] Audio buses synced successfully.")