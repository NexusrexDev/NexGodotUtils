class_name BaseAudioPool extends Node

var _pool: Array = []
var _current_index: int = 0
var _is_ducking: bool = false
var _duck_volume_db: float = -5.0

signal voice_ended(player: AudioStreamPlayer)

func _initialize_base(max_voices: int, bus: AudioEnums.Buses, node_class: Variant, duck_volume_db: float, process_mode_set: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_PAUSABLE) -> void:
    var bus_name: StringName = AudioEnums.Buses.keys()[bus]
    _duck_volume_db = duck_volume_db
    
    for i in range(max_voices):
        var player: Variant = node_class.new()
        player.bus = bus_name
        add_child(player)
        _pool.append(player)
        player.process_mode = process_mode_set

func _get_available_base() -> Variant:
    var player: Variant = _pool[_current_index]
    _current_index = (_current_index + 1) % _pool.size()
    return player

func _set_ducking(ducking: bool) -> void:
    _is_ducking = ducking
    if _is_ducking:
        for player: AudioStreamPlayer in _pool:
            if player.playing:
                player.volume_db = _duck_volume_db
    else:
        for player: AudioStreamPlayer in _pool:
            if player.playing:
                player.volume_db = 0.0

func stop_all() -> void:
    for player: AudioStreamPlayer in _pool:
        if player.playing:
            player.stop()

func emit_voice_ended(player: AudioStreamPlayer) -> void:
    voice_ended.emit(player)