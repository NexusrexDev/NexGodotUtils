@tool
class_name SFXEntry extends Resource

@export_group("Audio Files")
@export_file("*.wav", "*.ogg", "*.mp3") var streams: Array[String] = []

@export_group("Pitch Jitter (Linear)")
@export_range(0.1, 4.0) var min_pitch: float = 1.0:
    set(value):
        min_pitch = value
        if min_pitch > max_pitch: max_pitch = min_pitch
@export_range(0.1, 4.0) var max_pitch: float = 1.0:
    set(value):
        max_pitch = value
        if max_pitch < min_pitch: min_pitch = max_pitch

@export_group("Volume Jitter (Decibels)")
@export_range(-80.0, 24.0) var min_volume: float = 0.0:
    set(value):
        min_volume = value
        if min_volume > max_volume: max_volume = min_volume
@export_range(-80.0, 24.0) var max_volume: float = 0.0:
    set(value):
        max_volume = value
        if max_volume < min_volume: min_volume = max_volume

@export_group("Spatial Control")
@export_range(0.0, 4000.0, 0.1, "or_greater") var max_distance: float = 2000.0

@export_subgroup("2D")
@export_exp_easing("attenuation") var attenuation_2d: float = 1.0

@export_subgroup("3D")
@export var attenuation_model_3d: AudioStreamPlayer3D.AttenuationModel = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

var _last_played_index: int = -1

func get_stream_path() -> String:
    if streams.is_empty():
        return ""
    
    if streams.size() == 1:
        return streams[0]
    
    var pick: int = randi() % streams.size()
    if pick == _last_played_index:
        pick = (pick + 1) % streams.size()

    _last_played_index = pick
    return streams[pick]

func get_pitch_offset() -> float:
    return randf_range(min_pitch, max_pitch)

func get_volume_offset() -> float:
    return randf_range(min_volume, max_volume)