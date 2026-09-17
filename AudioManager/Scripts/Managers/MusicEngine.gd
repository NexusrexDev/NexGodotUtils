class_name MusicEngine extends Node

var _player_A: AudioStreamPlayer = AudioStreamPlayer.new()
var _player_B: AudioStreamPlayer = AudioStreamPlayer.new()
var _current_player: AudioStreamPlayer = _player_A

var _current_entry: MusicEntry = null

var _last_playback_pos: float = -1.0
var _is_ducking: bool = false
var _duck_volume_db: float = -5.0

const ON_VOLUME_DB: float = 0.0
const OFF_VOLUME_DB: float = -80.0

func _ready() -> void:
    add_child(_player_A)
    add_child(_player_B)
    _player_A.bus = AudioEnums.Buses.keys()[AudioEnums.Buses.MUSIC]
    _player_B.bus = AudioEnums.Buses.keys()[AudioEnums.Buses.MUSIC]

func _initialize(duck_volume_db: float, process_mode: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_INHERIT) -> void:
    _duck_volume_db = duck_volume_db
    process_mode = process_mode

func play(stream: AudioStream, entry: MusicEntry, crossfade_time: float = 0.0) -> void:
    if not stream or not entry:
        printerr("MusicEngine Error: Invalid stream or entry provided to play()")
        return

    if _current_entry == entry:
        return

    _current_entry = entry

    if crossfade_time > 0.0:
        _crossfade_to(stream, entry, crossfade_time)
    else:
        _play_immediately(stream, entry)

func pause() -> void:
    _last_playback_pos = _current_player.get_playback_position()
    _current_player.stop()

func unpause() -> void:
    if _last_playback_pos >= 0.0:
        _current_player.play(_last_playback_pos)
        _last_playback_pos = -1.0

func stop(fadeout_time: float = 0.0) -> void:
    if fadeout_time > 0.0:
        var fade_tween: Tween = get_tree().create_tween()
        fade_tween.tween_property(_current_player, "volume_db", OFF_VOLUME_DB, fadeout_time)
        fade_tween.tween_callback(func() -> void:
            _current_player.stop()
            _current_entry = null)
    else:
        _current_player.stop()
        _current_entry = null

func is_playing() -> bool:
    return _current_player.playing

func switch_section(clip_name: StringName) -> void:
    var playback: AudioStreamPlayback = _current_player.get_stream_playback()

    if playback is AudioStreamPlaybackInteractive:
        (playback as AudioStreamPlaybackInteractive).switch_to_clip_by_name(clip_name)
        return
        
    printerr("MusicEngine: Current stream does not support interactive section switching.")

func toggle_stem(index: int, enable: bool, fade_time: float = 0.0) -> void:
    var stream: AudioStream = _current_player.stream
    var playback: AudioStreamPlayback = _current_player.get_stream_playback()
    var sync_stream: AudioStreamSynchronized = null

    if playback is AudioStreamPlaybackInteractive and stream is AudioStreamInteractive:
        var current_index: int = playback.get_current_clip_index()
        var inner_stream: AudioStream = stream.get_clip_stream(current_index)
        
        if inner_stream is AudioStreamSynchronized:
            sync_stream = inner_stream
        else:
            printerr("MusicEngine: Current interactive clip is not an AudioStreamSynchronized.")
            return
    
    elif stream is AudioStreamSynchronized:
        sync_stream = stream
        
    else:
        printerr("MusicEngine: Current stream does not support stem toggling.")
        return

    if sync_stream:
        _toggle_stem_on_resource(sync_stream, index, enable, fade_time)

func toggle_ducking(enable: bool) -> void:
    if _is_ducking == enable:
        return

    _is_ducking = enable
    var target_volume_db: float = _duck_volume_db if enable else ON_VOLUME_DB
    _current_player.volume_db = target_volume_db

func _play_immediately(stream: AudioStream, entry: MusicEntry) -> void:
    _current_player.stop()
    _current_player.stream = stream
    _current_player.volume_db = entry.volume_offset + (_duck_volume_db if _is_ducking else 0.0)
    _current_player.play()

func _crossfade_to(stream: AudioStream, entry: MusicEntry, crossfade_time: float) -> void:
    var next_player: AudioStreamPlayer = _player_B if _current_player == _player_A else _player_A
    next_player.stream = stream
    next_player.volume_db = entry.volume_offset
    next_player.play()
    var fade_tween: Tween = get_tree().create_tween()
    fade_tween.tween_property(_current_player, "volume_db", OFF_VOLUME_DB, crossfade_time)
    fade_tween.parallel().tween_property(next_player, "volume_db", entry.volume_offset + (_duck_volume_db if _is_ducking else 0.0), crossfade_time)
    fade_tween.tween_callback(_swap_players)

func _swap_players() -> void:
    _current_player.stop()
    _current_player = _player_B if _current_player == _player_A else _player_A

func _toggle_stem_on_resource(sync_stream: AudioStreamSynchronized, index: int, enable: bool, fade_time: float) -> void:
    if index < 0 or index >= sync_stream.stream_count:
        printerr("MusicEngine: Invalid stem index %d for toggle_stem." % index)
        return

    var target_volume_db: float = ON_VOLUME_DB if enable else OFF_VOLUME_DB

    if fade_time > 0.0:
        var fade_tween: Tween = get_tree().create_tween()
        var current_volume_db: float = sync_stream.get_sync_stream_volume(index)
        
        fade_tween.tween_method(
            func(val: float) -> void:
                sync_stream.set_sync_stream_volume(index, val),
            current_volume_db, 
            target_volume_db, 
            fade_time
        )
    else:
        sync_stream.set_sync_stream_volume(index, target_volume_db)