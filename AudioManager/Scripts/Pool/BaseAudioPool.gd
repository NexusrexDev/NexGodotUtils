class_name BaseAudioPool extends Node

var _pool: Array = []
var _current_index: int = 0

func _initialize_base(max_voices: int, bus: AudioEnums.Buses, node_class: Variant) -> void:
    var bus_name: StringName = AudioEnums.Buses.keys()[bus]
    
    for i in range(max_voices):
        var player: Variant = node_class.new()
        player.bus = bus_name
        add_child(player)
        _pool.append(player)

func _get_available_base() -> Variant:
    var player: Variant = _pool[_current_index]
    _current_index = (_current_index + 1) % _pool.size()
    return player