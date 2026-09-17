@tool
class_name MusicEntry extends Resource

@export_group("Track Data")
@export var stream: AudioStream = null:
    set(value):
        stream = value
        _validate_stream()

@export_group("Mixing")
@export_range(-80.0, 24.0) var volume_offset: float = 0.0

func _validate_stream() -> void:
    if not Engine.is_editor_hint() or stream.is_empty():
        return