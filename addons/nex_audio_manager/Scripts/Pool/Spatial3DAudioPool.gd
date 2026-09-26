class_name Spatial3DAudioPool extends BaseAudioPool

func _init(node_name: String, max_voices: int, bus: AudioEnums.Buses, duck_volume_db: float, process_mode_set: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_PAUSABLE) -> void:
    name = node_name
    _initialize_base(max_voices, bus, AudioStreamPlayer3D, duck_volume_db, process_mode_set)

func play_positioned(entry: SFXEntry, position: Vector3, pitch: float = INF, volume: float = INF) -> void:
    var player: AudioStreamPlayer3D = _get_available_base() as AudioStreamPlayer3D
    if not player: return

    player.global_position = position

    _setup_player(player, entry, pitch, volume)

    player.play()


func play_targeted(entry: SFXEntry, target: Node3D, pitch: float = INF, volume: float = INF) -> void:
    var player: AudioStreamPlayer3D = _get_available_base() as AudioStreamPlayer3D

    if not player: return

    var remote_transform: RemoteTransform3D = RemoteTransform3D.new()

    target.add_child(remote_transform)

    remote_transform.remote_path = remote_transform.get_path_to(player)

    remote_transform.update_rotation = false
    remote_transform.update_scale = false

    _setup_player(player, entry, pitch, volume)

    player.play()

    player.finished.connect(
        func() -> void: 
        if is_instance_valid(remote_transform): 
            remote_transform.queue_free()
        player.global_position = Vector3.ZERO
        , CONNECT_ONE_SHOT)

func _setup_player(player: AudioStreamPlayer3D, entry: SFXEntry, pitch: float, volume: float) -> void:
    var stream: AudioStream = entry.get_stream()
    if not stream:
        printerr("Spatial3DAudioPool Error: Invalid AudioStream provided to _setup_player()")
        return
    player.stream = stream

    if volume != INF:
        player.volume_db = volume
    else:
        player.volume_db = entry.get_volume_offset()

    if pitch != INF:
        player.pitch_scale = pitch
    else:
        player.pitch_scale = entry.get_pitch_offset()

    player.attenuation_model = entry.attenuation_model_3d
    player.max_distance = entry.max_distance