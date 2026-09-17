class_name NonSpatialAudioPool extends BaseAudioPool

func initialize(max_voices: int, bus: AudioEnums.Buses, duck_volume_db: float, process_mode: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_PAUSABLE) -> void:
    _initialize_base(max_voices, bus, AudioStreamPlayer, duck_volume_db, process_mode)

func play(stream: AudioStream, entry: SFXEntry) -> void:
    var player: AudioStreamPlayer = _get_available_base() as AudioStreamPlayer

    if not player: return

    player.stream = stream
    player.volume_db = entry.get_volume_offset()
    player.pitch_scale = entry.get_pitch_offset()
    
    player.play()
    player.finished.connect(emit_voice_ended.bind(player), CONNECT_ONE_SHOT)