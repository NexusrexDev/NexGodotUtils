extends Node

var _music_engine: MusicEngine
var _sfx_pool_3d: Spatial3DAudioPool
var _sfx_pool_2d: Spatial2DAudioPool
var _sfx_pool_global: NonSpatialAudioPool 
var _ui_audio_pool: NonSpatialAudioPool
var _voiceline_pool: NonSpatialAudioPool

@export var _config: AudioConfig

func _ready() -> void:
	if not _config:
		printerr("AudioManager Error: No AudioConfig resource assigned.")
		return
	
	if not _config.music_registry:
		printerr("AudioManager Error: No MusicRegistry resource assigned.")
		return

	if not _config.sfx_registry:
		printerr("AudioManager Error: No SFXRegistry resource assigned.")
		return

	if not _config.voiceline_registry:
		printerr("AudioManager Error: No VoicelineRegistry resource assigned.")
		return

	if not _config.ui_registry:
		printerr("AudioManager Error: No UIAudioRegistry resource assigned.")
		return
	
	if _config.enable_music:
		var _music_process_mode: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_INHERIT if _config.pause_on_pause == AudioConfig.PauseOptions.SFX else Node.ProcessMode.PROCESS_MODE_PAUSABLE
		_music_engine = MusicEngine.new(_config.ducking_volume_db, _music_process_mode)
		add_child(_music_engine)

	if _config.enable_3d_sfx:
		_sfx_pool_3d = Spatial3DAudioPool.new("3D SFX", _config.max_3d_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_3d)

	if _config.enable_2d_sfx:
		_sfx_pool_2d = Spatial2DAudioPool.new("2D SFX", _config.max_2d_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_2d)

	if _config.enable_global_sfx:
		_sfx_pool_global = NonSpatialAudioPool.new("Global SFX", _config.max_global_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_global)

	if _config.enable_ui_audio:
		_ui_audio_pool = NonSpatialAudioPool.new("UI Audio", _config.max_ui_voices, AudioEnums.Buses.UI, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_INHERIT)
		add_child(_ui_audio_pool)

	if _config.enable_voicelines:
		_voiceline_pool = NonSpatialAudioPool.new("Voicelines", _config.max_voiceline_voices, AudioEnums.Buses.VOICE, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_voiceline_pool)
		_voiceline_pool.voice_ended.connect(_handle_voiceline_ended)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			_toggle_pause_effects(true)
		NOTIFICATION_UNPAUSED:
			_toggle_pause_effects(false)

func _toggle_pause_effects(paused: bool) -> void:
	if not _config:
		return

	if paused:
		if _config.pause_on_pause != AudioConfig.PauseOptions.MUSIC_AND_SFX:
			for effect in _config.effects_on_pause:
				AudioServer.add_bus_effect(AudioServer.get_bus_index("Master"), effect, 0)

	if not paused:
		if _config.pause_on_pause != AudioConfig.PauseOptions.MUSIC_AND_SFX:
			for effect in _config.effects_on_pause:
				AudioServer.remove_bus_effect(AudioServer.get_bus_index("Master"), 0)

func _handle_voiceline_ended(_player: AudioStreamPlayer) -> void:
	if _config.enable_ducking_on_voiceline:
		if _config.enable_music:
			_music_engine.toggle_ducking(false)

		if _config.enable_3d_sfx:
			_sfx_pool_3d._set_ducking(false)

		if _config.enable_2d_sfx:
			_sfx_pool_2d._set_ducking(false)

		if _config.enable_global_sfx:
			_sfx_pool_global._set_ducking(false)

#region Music Control

func play_music(music_enum: AudioEnums.Music, crossfade_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	var entry: MusicEntry = _config.music_registry.get_entry(music_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid MusicEntry provided to play_music()")
		return
	_music_engine.play(entry.stream, entry, crossfade_time)

func pause_music() -> void:
	if not _config.enable_music:
		return
	_music_engine.pause()

func unpause_music() -> void:
	if not _config.enable_music:
		return
	_music_engine.unpause()

func stop_music(fadeout_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	_music_engine.stop(fadeout_time)

func is_music_playing() -> bool:
	if not _config.enable_music:
		return false
	return _music_engine.is_playing()

func switch_music_section(clip_name: StringName) -> void:
	if not _config.enable_music:
		return
	_music_engine.switch_section(clip_name)

func toggle_music_stem(index: int, enable: bool, fade_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	_music_engine.toggle_stem(index, enable, fade_time)

#endregion

#region 3D SFX Control

func play_sfx_3d_positioned(sfx_enum: AudioEnums.SFX, position: Vector3) -> void:
	if not _config.enable_3d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_3d_positioned()")
		return
	_sfx_pool_3d.play_positioned(entry.stream, entry, position)

func play_sfx_3d_targeted(sfx_enum: AudioEnums.SFX, target: Node3D) -> void:
	if not _config.enable_3d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_3d_targeted()")
		return
	_sfx_pool_3d.play_targeted(entry.stream, entry, target)

#endregion

#region 2D SFX Control

func play_sfx_2d_positioned(sfx_enum: AudioEnums.SFX, position: Vector2) -> void:
	if not _config.enable_2d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_2d_positioned()")
		return
	_sfx_pool_2d.play_positioned(entry.stream, entry, position)

func play_sfx_2d_targeted(sfx_enum: AudioEnums.SFX, target: Node2D) -> void:
	if not _config.enable_2d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_2d_targeted()")
		return
	_sfx_pool_2d.play_targeted(entry.stream, entry, target)

#endregion

#region Global SFX Control

func play_sfx_global(sfx_enum: AudioEnums.SFX) -> void:
	if not _config.enable_global_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_global()")
		return
	_sfx_pool_global.play(entry.stream, entry)

func play_ui_audio(ui_audio_enum: AudioEnums.UI) -> void:
	if not _config.enable_ui_audio:
		return
	var entry: SFXEntry = _config.ui_audio_registry.get_entry(ui_audio_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid UIAudioEntry provided to play_ui_audio()")
		return
	_ui_audio_pool.play(entry.stream, entry)

func play_voiceline(voiceline_enum: AudioEnums.Voiceline) -> void:
	if not _config.enable_voicelines:
		return
	var entry: SFXEntry = _config.voiceline_registry.get_entry(voiceline_enum)
	if not entry or not entry.stream:
		printerr("AudioManager Error: Invalid VoicelineEntry provided to play_voiceline()")
		return
	_voiceline_pool.play(entry.stream, entry)

	if _config.enable_ducking_on_voiceline:
		if _config.enable_music:
			_music_engine.toggle_ducking(true)
		if _config.enable_3d_sfx:
			_sfx_pool_3d._set_ducking(true)
		if _config.enable_2d_sfx:
			_sfx_pool_2d._set_ducking(true)
		if _config.enable_global_sfx:
			_sfx_pool_global._set_ducking(true)

#endregion

#region Bus Control

func set_bus_volume(bus: AudioEnums.Buses, volume_db: float) -> void:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), volume_db)

func set_bus_mute(bus: AudioEnums.Buses, mute: bool) -> void:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	AudioServer.set_bus_mute(AudioServer.get_bus_index(bus_name), mute)

func add_bus_effect(bus: AudioEnums.Buses, effect: AudioEffect, index: int) -> void:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	AudioServer.add_bus_effect(AudioServer.get_bus_index(bus_name), effect, index)

func remove_bus_effect(bus: AudioEnums.Buses, effect_index: int) -> void:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	AudioServer.remove_bus_effect(AudioServer.get_bus_index(bus_name), effect_index)

func get_bus_effect_count(bus: AudioEnums.Buses) -> int:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	return AudioServer.get_bus_effect_count(AudioServer.get_bus_index(bus_name))

func get_bus_effect(bus: AudioEnums.Buses, effect_index: int) -> AudioEffect:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	return AudioServer.get_bus_effect(AudioServer.get_bus_index(bus_name), effect_index)

func set_bus_effect_enabled(bus: AudioEnums.Buses, effect_index: int, enabled: bool) -> void:
	var bus_name: StringName = AudioEnums.Buses.keys()[bus]
	AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index(bus_name), effect_index, enabled)

#endregion