@tool
class_name AudioConfig extends Resource

@export_group("Modules")
@export var enable_ui_audio: bool = true:
    set(value):
        enable_ui_audio = value
        notify_property_list_changed()

@export var enable_global_sfx: bool = true:
    set(value):
        enable_global_sfx = value
        notify_property_list_changed()

@export var enable_2d_sfx: bool = true:
    set(value):
        enable_2d_sfx = value
        notify_property_list_changed()

@export var enable_3d_sfx: bool = false:
    set(value):
        enable_3d_sfx = value
        notify_property_list_changed()

@export var enable_music: bool = true

@export var enable_voicelines: bool = false:
    set(value):
        enable_voicelines = value
        notify_property_list_changed()

@export_group("Pooling")
@export var max_ui_voices: int = 8
@export var max_global_sfx_voices: int = 32
@export var max_2d_sfx_voices: int = 32
@export var max_3d_sfx_voices: int = 32
@export var max_voiceline_voices: int = 1

@export_group("Garbage Collection")
@export var enable_gc: bool = true:
    set(value):
        enable_gc = value
        notify_property_list_changed()
@export var gc_interval_minutes: float = 5.0

@export_group("Pause Features")
@export var stop_on_pause: PauseOptions = PauseOptions.SFX
@export var enable_effects_on_pause: bool = true:
    set(value):
        enable_effects_on_pause = value
        notify_property_list_changed()
@export var effects_on_pause: Array[AudioEffect] = []

@export_group("Voiceline Features")
@export var enable_ducking_on_voiceline: bool = true

@export_group("Registries")
@export var ui_registry: UIRegistry
@export var sfx_registry: SFXRegistry
@export var music_registry: MusicRegistry
@export var voiceline_registry: VoicelineRegistry

enum PauseOptions
{
    ALL,
    MUSIC_AND_SFX,
    SFX
}

func _validate_property(property: Dictionary) -> void:
    if property.name == "max_ui_voices" and not enable_ui_audio:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_global_sfx_voices" and not enable_global_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_2d_sfx_voices" and not enable_2d_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "max_3d_sfx_voices" and not enable_3d_sfx:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name in ["max_voiceline_voices", "enable_ducking_on_voiceline"] and not enable_voicelines:
        property.usage &= ~PROPERTY_USAGE_EDITOR
    
    if property.name == "gc_interval_minutes" and not enable_gc:
        property.usage &= ~PROPERTY_USAGE_EDITOR

    if property.name == "effects_on_pause" and not enable_effects_on_pause:
        property.usage &= ~PROPERTY_USAGE_EDITOR