class_name Spatial3DAudioPool extends BaseAudioPool

func initialize(max_voices: int, bus: AudioEnums.Buses) -> void:
    _initialize_base(max_voices, bus, AudioStreamPlayer3D)

func play_positioned(stream: AudioStream, entry: SFXEntry, position: Vector3) -> void:
    var player: AudioStreamPlayer3D = _get_available_base() as AudioStreamPlayer3D

    if not player: return

    player.global_position = position

    player.stream = stream
    player.volume_db = entry.get_volume_offset()
    player.pitch_scale = entry.get_pitch_offset()
    player.attenuation_model = entry.attenuation_model_3d
    player.max_distance = entry.max_distance
    player.play()

func play_targeted(stream: AudioStream, entry: SFXEntry, target: Node3D) -> void:
    var player: AudioStreamPlayer3D = _get_available_base() as AudioStreamPlayer3D

    if not player: return

    var remote_transform: RemoteTransform3D = RemoteTransform3D.new()

    target.add_child(remote_transform)

    remote_transform.remote_path = remote_transform.get_path_to(player)

    remote_transform.update_rotation = false
    remote_transform.update_scale = false

    player.stream = stream
    player.volume_db = entry.get_volume_offset()
    player.pitch_scale = entry.get_pitch_offset()
    player.attenuation_model = entry.attenuation_model_3d
    player.max_distance = entry.max_distance

    player.play()

    player.finished.connect(
        func() -> void: 
        if is_instance_valid(remote_transform): 
            remote_transform.queue_free()
        player.global_position = Vector3.ZERO
        , CONNECT_ONE_SHOT)