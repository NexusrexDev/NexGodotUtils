class_name NonSpatialAudioPool extends BaseAudioPool

func _init(node_name: String, max_voices: int, bus: AudioEnums.Buses, duck_volume_db: float, process_mode_set: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_PAUSABLE) -> void:
    name = node_name
    _initialize_base(max_voices, bus, AudioStreamPlayer, duck_volume_db, process_mode_set)

func play(stream: AudioStream, entry: SFXEntry, pitch: float = INF, volume: float = INF) -> void:
    var player: AudioStreamPlayer = _get_available_base() as AudioStreamPlayer

    if not player: return

    player.stream = stream

    if volume != INF:
        player.volume_db = volume
    else:
        player.volume_db = entry.get_volume_offset()

    if pitch != INF:
        player.pitch_scale = pitch
    else:
        player.pitch_scale = entry.get_pitch_offset()
    
    player.play()
    player.finished.connect(emit_voice_ended.bind(player), CONNECT_ONE_SHOT)