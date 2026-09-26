## Autoload singleton for the Nex Audio Manager plugin.
##
## Autoload singleton (registered by the plugin as [code]AudioManager[/code]) that wraps
## music, spatial/nonspatial SFX, UI audio, and voicelines behind a simple API, along with
## direct control over the plugin's managed audio buses.
extends Node

var _music_engine: MusicEngine
var _sfx_pool_3d: Spatial3DAudioPool
var _sfx_pool_2d: Spatial2DAudioPool
var _sfx_pool_nonspatial: NonSpatialAudioPool 
var _ui_audio_pool: NonSpatialAudioPool
var _voiceline_pool: NonSpatialAudioPool

var _bus_cache: Dictionary[AudioEnums.Buses, int] = {}

var _config: AudioConfig

func _ready() -> void:
	var config_path = ProjectSettings.get_setting("plugins/nex_audio_manager/active_config")
	assert(ResourceLoader.exists(config_path), "AudioManager Error: No AudioConfig resource found at path: %s" % config_path)
	_config = ResourceLoader.load(config_path)

	process_mode = ProcessMode.PROCESS_MODE_ALWAYS
	
	_validate_registries()
	
	_instantiate_submodules()

	_generate_bus_cache()

func _validate_registries() -> void:
	if _config.enable_music:
		assert(_config.music_registry, "AudioManager Error: No MusicRegistry resource assigned.")
	
	if _config.enable_3d_sfx or _config.enable_2d_sfx or _config.enable_nonspatial_sfx:
		assert(_config.sfx_registry, "AudioManager Error: No SFXRegistry resource assigned.")

	if _config.enable_voicelines:
		assert(_config.voiceline_registry, "AudioManager Error: No VoicelineRegistry resource assigned.")

	if _config.enable_ui_audio:
		assert(_config.ui_registry, "AudioManager Error: No UIAudioRegistry resource assigned.")

func _instantiate_submodules() -> void:
	if _config.enable_music:
		var _music_process_mode: Node.ProcessMode = Node.ProcessMode.PROCESS_MODE_ALWAYS if _config.pause_on_pause == AudioConfig.PauseOptions.SFX else Node.ProcessMode.PROCESS_MODE_PAUSABLE
		_music_engine = MusicEngine.new(_config.ducking_volume_db, _music_process_mode)
		add_child(_music_engine)

	if _config.enable_3d_sfx:
		_sfx_pool_3d = Spatial3DAudioPool.new("3D SFX", _config.max_3d_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_3d)

	if _config.enable_2d_sfx:
		_sfx_pool_2d = Spatial2DAudioPool.new("2D SFX", _config.max_2d_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_2d)

	if _config.enable_nonspatial_sfx:
		_sfx_pool_nonspatial = NonSpatialAudioPool.new("Nonspatial SFX", _config.max_nonspatial_sfx_voices, AudioEnums.Buses.SFX, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_sfx_pool_nonspatial)

	if _config.enable_ui_audio:
		_ui_audio_pool = NonSpatialAudioPool.new("UI Audio", _config.max_ui_voices, AudioEnums.Buses.UI, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_ALWAYS)
		add_child(_ui_audio_pool)

	if _config.enable_voicelines:
		_voiceline_pool = NonSpatialAudioPool.new("Voicelines", _config.max_voiceline_voices, AudioEnums.Buses.VOICE, _config.ducking_volume_db, Node.ProcessMode.PROCESS_MODE_PAUSABLE)
		add_child(_voiceline_pool)
		_voiceline_pool.voice_ended.connect(_handle_voiceline_ended)

func _generate_bus_cache() -> void:
	for bus_enum in AudioEnums.Buses.values():
		var bus_index: int = AudioServer.get_bus_index(AudioEnums.get_bus_name(bus_enum))
		_bus_cache[bus_enum] = bus_index

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PAUSED:
			_toggle_pause_effects(true)
		NOTIFICATION_UNPAUSED:
			_toggle_pause_effects(false)

func _toggle_pause_effects(paused: bool) -> void:
	if paused:
		if _config.pause_on_pause == AudioConfig.PauseOptions.SFX:
			for effect in _config.effects_on_pause:
				AudioServer.add_bus_effect(_bus_cache[AudioEnums.Buses.MUSIC], effect, 0)

	if not paused:
		if _config.pause_on_pause == AudioConfig.PauseOptions.SFX:
			for effect in _config.effects_on_pause:
				AudioServer.remove_bus_effect(_bus_cache[AudioEnums.Buses.MUSIC], 0)

func _handle_voiceline_ended(_player: AudioStreamPlayer) -> void:
	if _config.enable_ducking_on_voiceline:
		if _config.enable_music:
			_music_engine.toggle_ducking(false)

		if _config.enable_3d_sfx:
			_sfx_pool_3d._set_ducking(false)

		if _config.enable_2d_sfx:
			_sfx_pool_2d._set_ducking(false)

		if _config.enable_nonspatial_sfx:
			_sfx_pool_nonspatial._set_ducking(false)

#region Music Control

## Plays a [MusicEntry] from the configured [MusicRegistry]. Crossfades from the
## current track over [param crossfade_time] seconds if greater than [code]0.0[/code],
## otherwise switches immediately. No-op if music is disabled or the entry is invalid.
func play_music(music_enum: AudioEnums.Music, crossfade_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	var entry: MusicEntry = _config.music_registry.get_entry(music_enum)
	if not entry:
		printerr("AudioManager Error: Invalid MusicEntry provided to play_music()")
		return
	_music_engine.play(entry, crossfade_time)

## Pauses the currently playing music track, remembering its playback position.
## No-op if music is disabled.
func pause_music() -> void:
	if not _config.enable_music:
		return
	_music_engine.pause()

## Resumes music from where it was last paused. No-op if music is disabled.
func unpause_music() -> void:
	if not _config.enable_music:
		return
	_music_engine.unpause()

## Stops the current music track, optionally fading out over [param fadeout_time]
## seconds first. No-op if music is disabled.
func stop_music(fadeout_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	_music_engine.stop(fadeout_time)

## Returns whether music is currently playing. Always returns [code]false[/code]
## if music is disabled.
func is_music_playing() -> bool:
	if not _config.enable_music:
		return false
	return _music_engine.is_playing()

## Switches to a named clip on an [AudioStreamPlaybackInteractive] track.
## No-op if music is disabled.
func switch_music_section(clip_name: StringName) -> void:
	if not _config.enable_music:
		return
	_music_engine.switch_section(clip_name)

## Enables or disables a stem [param index] on an [AudioStreamSynchronized] track,
## optionally fading over [param fade_time] seconds. No-op if music is disabled.
func toggle_music_stem(index: int, enable: bool, fade_time: float = 0.0) -> void:
	if not _config.enable_music:
		return
	_music_engine.toggle_stem(index, enable, fade_time)

#endregion

#region 3D SFX Control

## Plays an [SFXEntry] from the pooled 3D SFX voices at a fixed world [param position].
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if 3D SFX is disabled.
func play_sfx_3d_positioned(sfx_enum: AudioEnums.SFX, position: Vector3, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_3d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_3d_positioned()")
		return
	_sfx_pool_3d.play_positioned(entry, position, pitch, volume)

## Plays an [SFXEntry] from the pooled 3D SFX voices, following [param target] until the sound finishes.
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if 3D SFX is disabled.
func play_sfx_3d_targeted(sfx_enum: AudioEnums.SFX, target: Node3D, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_3d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_3d_targeted()")
		return
	_sfx_pool_3d.play_targeted(entry, target, pitch, volume)

#endregion

#region 2D SFX Control

## 2D equivalent of [method play_sfx_3d_positioned]. 
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if 2D SFX is disabled.
func play_sfx_2d_positioned(sfx_enum: AudioEnums.SFX, position: Vector2, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_2d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_2d_positioned()")
		return
	_sfx_pool_2d.play_positioned(entry, position, pitch, volume)

## 2D equivalent of [method play_sfx_3d_targeted].
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if 2D SFX is disabled.
func play_sfx_2d_targeted(sfx_enum: AudioEnums.SFX, target: Node2D, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_2d_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_2d_targeted()")
		return
	_sfx_pool_2d.play_targeted(entry, target, pitch, volume)

#endregion

#region Nonspatial SFX, UI, and Voiceline Control

## Plays a non-positional [SFXEntry] from the nonspatial pool. 
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if nonspatial SFX is disabled.
func play_sfx_nonspatial(sfx_enum: AudioEnums.SFX, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_nonspatial_sfx:
		return
	var entry: SFXEntry = _config.sfx_registry.get_entry(sfx_enum)
	if not entry:
		printerr("AudioManager Error: Invalid SFXEntry provided to play_sfx_nonspatial()")
		return
	_sfx_pool_nonspatial.play(entry, pitch, volume)

## Plays a UI sound from the [UIAudioRegistry] through a dedicated, always-processing
## pool, so it plays even while the game is paused.
## [code]INF[/code] [param pitch]/[param volume] defer to the entry's own jitter ranges.
## No-op if UI audio is disabled.
func play_ui_audio(ui_audio_enum: AudioEnums.UI, pitch: float = INF, volume: float = INF) -> void:
	if not _config.enable_ui_audio:
		return
	var entry: SFXEntry = _config.ui_registry.get_entry(ui_audio_enum)
	if not entry:
		printerr("AudioManager Error: Invalid UIAudioEntry provided to play_ui_audio()")
		return
	_ui_audio_pool.play(entry, pitch, volume)

## Plays a voiceline from the [VoicelineRegistry] and, if [member AudioConfig.enable_ducking_on_voiceline]
## is set, ducks music/SFX for its duration. Ducking is released automatically once the
## voiceline finishes. No-op if voicelines are disabled.
func play_voiceline(voiceline_enum: AudioEnums.Voiceline) -> void:
	if not _config.enable_voicelines:
		return
	var entry: SFXEntry = _config.voiceline_registry.get_entry(voiceline_enum)
	if not entry:
		printerr("AudioManager Error: Invalid VoicelineEntry provided to play_voiceline()")
		return
	_voiceline_pool.play(entry)

	if _config.enable_ducking_on_voiceline:
		if _config.enable_music:
			_music_engine.toggle_ducking(true)
		if _config.enable_3d_sfx:
			_sfx_pool_3d._set_ducking(true)
		if _config.enable_2d_sfx:
			_sfx_pool_2d._set_ducking(true)
		if _config.enable_nonspatial_sfx:
			_sfx_pool_nonspatial._set_ducking(true)

#endregion

#region Bus Control

## Sets the volume, in decibels, of the given logical [param bus].
func set_bus_volume(bus: AudioEnums.Buses, volume_db: float) -> void:
	var bus_index: int = _bus_cache[bus]
	AudioServer.set_bus_volume_db(bus_index, volume_db)

## Mutes or unmutes the given logical [param bus].
func set_bus_mute(bus: AudioEnums.Buses, mute: bool) -> void:
	var bus_index: int = _bus_cache[bus]
	AudioServer.set_bus_mute(bus_index, mute)

## Adds [param effect] to the given logical [param bus] at slot [param index].
func add_bus_effect(bus: AudioEnums.Buses, effect: AudioEffect, index: int) -> void:
	var bus_index: int = _bus_cache[bus]
	AudioServer.add_bus_effect(bus_index, effect, index)

## Removes the effect at [param effect_index] from the given logical [param bus].
func remove_bus_effect(bus: AudioEnums.Buses, effect_index: int) -> void:
	var bus_index: int = _bus_cache[bus]
	AudioServer.remove_bus_effect(bus_index, effect_index)

## Returns how many effects are on the given logical [param bus].
func get_bus_effect_count(bus: AudioEnums.Buses) -> int:
	var bus_index: int = _bus_cache[bus]
	return AudioServer.get_bus_effect_count(bus_index)

## Returns the effect at [param effect_index] on the given logical [param bus].
func get_bus_effect(bus: AudioEnums.Buses, effect_index: int) -> AudioEffect:
	var bus_index: int = _bus_cache[bus]
	return AudioServer.get_bus_effect(bus_index, effect_index)

## Enables or disables (bypasses) the effect at [param effect_index] on the given
## logical [param bus].
func set_bus_effect_enabled(bus: AudioEnums.Buses, effect_index: int, enabled: bool) -> void:
	var bus_index: int = _bus_cache[bus]
	AudioServer.set_bus_effect_enabled(bus_index, effect_index, enabled)

#endregion