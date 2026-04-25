@tool
class_name MusicEntry extends Resource

@export_group("Track Data")
@export_file("*.ogg", "*.mp3", "*.wav", "*.tres") var stream_path: String = "":
    set(value):
        stream_path = value
        _validate_stream()

@export_group("Mixing")
@export_range(-80.0, 24.0) var volume_offset: float = 0.0

func _validate_stream() -> void:
    if not Engine.is_editor_hint() or stream_path.is_empty():
        return
        
    if stream_path.ends_with(".tres") or stream_path.ends_with(".res"):
        var res_type: String = EditorInterface.get_resource_filesystem().get_file_type(stream_path)
        
        if not ClassDB.is_parent_class(res_type, "AudioStream"):
            printerr("MusicEntry Error: The file '%s' is a '%s', NOT an AudioStream!" % [stream_path.get_file(), res_type])
            stream_path = ""
            notify_property_list_changed()