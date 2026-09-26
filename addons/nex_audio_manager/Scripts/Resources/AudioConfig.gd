@tool
class_name AudioConfig extends Resource

@export_group("Modules")
@export var enable_ui_audio: bool = true:
    set(value):
        enable_ui_audio = value
        notify_property_list_changed()

@export var enable_nonspatial_sfx: bool = true:
    set(value):
        enable_nonspatial_sfx = value
        notify_property_list_changed()

@export var enable_2d_sfx: bool = true:
    set(value):
        enable_2d_sfx = value
        notify_property_list_changed()

@export var enable_3d_sfx: bool = false:
    set(value):
        enable_3d_sfx = value
        notify_property_list_changed()

@export var enable_music: bool = true:
    set(value):
        enable_music = value
        notify_property_list_changed()

@export var enable_voicelines: bool = false:
    set(value):
        enable_voicelines = value
        notify_property_list_changed()

@export_group("Pooling")
@export var max_ui_voices: int = 8
@export var max_nonspatial_sfx_voices: int = 32
@export var max_2d_sfx_voices: int = 32
@export var max_3d_sfx_voices: int = 32
@export var max_voiceline_voices: int = 1

@export_group("Pause Features")
@export var pause_on_pause: PauseOptions = PauseOptions.SFX:
    set(value):
        pause_on_pause = value
        notify_property_list_changed()
@export var effects_on_pause: Array[AudioEffect] = []

@export_group("Voiceline Features")
@export var enable_ducking_on_voiceline: bool = true:
    set(value):
        enable_ducking_on_voiceline = value
        notify_property_list_changed()
@export_range(-24.0, 0.0) var ducking_volume_db: float = -5.0

@export_group("Registries")
@export var ui_registry: UIAudioRegistry
@export var sfx_registry: SFXRegistry
@export var music_registry: MusicRegistry
@export var voiceline_registry: VoicelineRegistry

enum PauseOptions
{
    MUSIC_AND_SFX,
    SFX
}

func _validate_property(property: Dictionary) -> void:
    if property.name == "max_ui_voices" and not enable_ui_audio:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_nonspatial_sfx_voices" and not enable_nonspatial_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_2d_sfx_voices" and not enable_2d_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_3d_sfx_voices" and not enable_3d_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name in ["max_voiceline_voices", "enable_ducking_on_voiceline", "ducking_volume_db"] and not enable_voicelines:
        property.usage &= ~PROPERTY_USAGE_EDITOR
    
    if property.name == "ducking_volume_db" and not enable_ducking_on_voiceline:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "effects_on_pause" and pause_on_pause == PauseOptions.MUSIC_AND_SFX:
        property.usage &= ~PROPERTY_USAGE_EDITOR
    
    if property.name == "music_registry" and not enable_music:
        property.usage &= ~PROPERTY_USAGE_EDITOR
    
    if property.name == "voiceline_registry" and not enable_voicelines:
        property.usage &= ~PROPERTY_USAGE_EDITOR
    
    if property.name == "sfx_registry" and not (enable_nonspatial_sfx or enable_2d_sfx or enable_3d_sfx):
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "ui_registry" and not enable_ui_audio:
        property.usage &= ~PROPERTY_USAGE_EDITOR