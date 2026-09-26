@tool
extends EditorPlugin

const AUDIO_MANAGER_PATH: String = "res://addons/nex_audio_manager/Scripts/Core/AudioManager.gd"
const BUS_LAYOUT_PATH: String = "res://addons/nex_audio_manager/Resources/bus_layout.tres"
const CONFIG_SETTING_PATH: String = "plugins/nex_audio_manager/active_config"

var _submenu: PopupMenu
var _config_dialog: EditorFileDialog

enum MenuAction {
    SYNC_BUSES,
}

func _enable_plugin() -> void:
    add_autoload_singleton("AudioManager", AUDIO_MANAGER_PATH)
    _setup_project_settings()
    _setup_buses_from_enum()

func _disable_plugin() -> void:
    remove_autoload_singleton("AudioManager")
    
    ProjectSettings.set_setting("audio/buses/default_bus_layout", "")
    ProjectSettings.set_setting(CONFIG_SETTING_PATH, null)
    ProjectSettings.save()

func _enter_tree() -> void:
    _submenu = PopupMenu.new()
    _submenu.add_item("Sync Buses from Enum", MenuAction.SYNC_BUSES)
    _submenu.id_pressed.connect(_on_submenu_id_pressed)
    
    add_tool_submenu_item("Nex's Audio Manager", _submenu)

func _exit_tree() -> void:
    remove_tool_menu_item("Nex's Audio Manager")
    if _submenu:
        _submenu.queue_free()
    _cleanup_dialog()

func _on_submenu_id_pressed(id: int) -> void:
    match id:
        MenuAction.SYNC_BUSES:
            _setup_buses_from_enum()

func _setup_buses_from_enum() -> void:
    for key_index in AudioEnums.Buses.values():
        var bus_name: String = AudioEnums.get_bus_name(key_index)

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

func _setup_project_settings() -> void:
    var current_path = ProjectSettings.get_setting(CONFIG_SETTING_PATH, "")
    
    if current_path == "" or not FileAccess.file_exists(current_path):
        _prompt_for_config_save()
    else:
        _apply_setting_properties(current_path)

func _prompt_for_config_save() -> void:
    _config_dialog = EditorFileDialog.new()
    _config_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
    _config_dialog.title = "Save Config File"
    _config_dialog.add_filter("*.tres", "Godot Resource")
    _config_dialog.current_file = "nex_audio_config.tres" 
    _config_dialog.exclusive = false
    
    var base_control = EditorInterface.get_base_control()
    base_control.add_child(_config_dialog)
    
    _config_dialog.file_selected.connect(_on_config_file_selected)
    _config_dialog.canceled.connect(_on_config_dialog_canceled)
    
    _config_dialog.popup_centered_ratio(0.4)

func _on_config_file_selected(path: String) -> void:
    var new_config = AudioConfig.new()
    ResourceSaver.save(new_config, path)
    print("[NexAudioManager] Generated config at: ", path)
    
    _apply_setting_properties(path)
    _cleanup_dialog()

func _on_config_dialog_canceled() -> void:
    push_warning("[NexAudioManager] Initialization canceled. You must manually create an AudioConfig and assign it in Project Settings -> Nex Audio Manager.")
    _apply_setting_properties("")
    _cleanup_dialog()

func _apply_setting_properties(path: String) -> void:
    ProjectSettings.set_setting(CONFIG_SETTING_PATH, path)
    
    ProjectSettings.add_property_info({
        "name": CONFIG_SETTING_PATH,
        "type": TYPE_STRING,
        "hint": PROPERTY_HINT_FILE,
        "hint_string": "*.tres"
    })
    
    ProjectSettings.set_initial_value(CONFIG_SETTING_PATH, "")

    ProjectSettings.save()

func _cleanup_dialog() -> void:
    if _config_dialog and is_instance_valid(_config_dialog):
        _config_dialog.queue_free()
        _config_dialog = null