class_name Spatial2DAudioPool extends BaseAudioPool

func _init(node_name: String, max_voices: int, bus: AudioEnums.Buses, duck_volume_db: float, process_mode_set: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_PAUSABLE) -> void:
    name = node_name
    _initialize_base(max_voices, bus, AudioStreamPlayer2D, duck_volume_db, process_mode_set)

func play_positioned(stream: AudioStream, entry: SFXEntry, position: Vector2, pitch: float = INF, volume: float = INF) -> void:
    var player: AudioStreamPlayer2D = _get_available_base() as AudioStreamPlayer2D
    if not player: return

    player.global_position = position

    _setup_player(player, stream, entry, pitch, volume)

    player.play()

func play_targeted(stream: AudioStream, entry: SFXEntry, target: Node2D, pitch: float = INF, volume: float = INF) -> void:
    var player: AudioStreamPlayer2D = _get_available_base() as AudioStreamPlayer2D
    if not player: return

    var remote_transform: RemoteTransform2D = RemoteTransform2D.new()

    target.add_child(remote_transform)

    remote_transform.remote_path = remote_transform.get_path_to(player)

    remote_transform.update_rotation = false
    remote_transform.update_scale = false

    _setup_player(player, stream, entry, pitch, volume)

    player.play()

    player.finished.connect(
        func() -> void: 
        if is_instance_valid(remote_transform): 
            remote_transform.queue_free()
        player.global_position = Vector2.ZERO
        , CONNECT_ONE_SHOT)

func _setup_player(player: AudioStreamPlayer2D, stream: AudioStream, entry: SFXEntry, pitch: float, volume: float) -> void:
    player.stream = stream

    if volume != INF:
        player.volume_db = volume
    else:
        player.volume_db = entry.get_volume_offset()

    if pitch != INF:
        player.pitch_scale = pitch
    else:
        player.pitch_scale = entry.get_pitch_offset()
        
    player.attenuation = entry.attenuation_2d
    player.max_distance = entry.max_distance