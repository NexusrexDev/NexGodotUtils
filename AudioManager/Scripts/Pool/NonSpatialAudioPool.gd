class_name NonSpatialAudioPool extends BaseAudioPool

func initialize(max_voices: int, bus: AudioEnums.Buses) -> void:
    _initialize_base(max_voices, bus, AudioStreamPlayer)

func play(stream: AudioStream, entry: SFXEntry) -> void:
    var player: AudioStreamPlayer = _get_available_base() as AudioStreamPlayer

    if not player: return

    player.stream = stream
    player.volume_db = entry.get_volume_offset()
    player.pitch_scale = entry.get_pitch_offset()
    
    player.play()