## Configuration [Resource] for ["addons/nex_audio_manager/Scripts/Core/AudioManager.gd"], assigned via the plugin's
## [code]plugins/nex_audio_manager/active_config[/code] project setting.
##
## Toggles which audio modules ([MusicEngine] and the SFX/UI/Voiceline pools) are
## instantiated, sets their voice pool sizes, configures pause and ducking behavior,
## and holds the registries each enabled module reads its entries from. Fields are
## shown/hidden in the inspector via [method _validate_property] depending on which
## modules are enabled, so only relevant settings are visible at a time.
@tool
class_name AudioConfig extends Resource

@export_group("Modules")
## Enables UI audio playback ([method AudioManager.play_ui_audio]) and instantiates
## its dedicated [NonSpatialAudioPool]. Requires [member ui_registry] to be assigned.
@export var enable_ui_audio: bool = true:
    set(value):
        enable_ui_audio = value
        notify_property_list_changed()

## Enables nonspatial SFX playback ([method AudioManager.play_sfx_nonspatial]) and
## instantiates its dedicated [NonSpatialAudioPool]. Requires [member sfx_registry]
## to be assigned.
@export var enable_nonspatial_sfx: bool = true:
    set(value):
        enable_nonspatial_sfx = value
        notify_property_list_changed()

## Enables 2D spatial SFX playback ([method AudioManager.play_sfx_2d_positioned],
## [method AudioManager.play_sfx_2d_targeted]) and instantiates a [Spatial2DAudioPool].
## Requires [member sfx_registry] to be assigned.
@export var enable_2d_sfx: bool = true:
    set(value):
        enable_2d_sfx = value
        notify_property_list_changed()

## Enables 3D spatial SFX playback ([method AudioManager.play_sfx_3d_positioned],
## [method AudioManager.play_sfx_3d_targeted]) and instantiates a [Spatial3DAudioPool].
## Requires [member sfx_registry] to be assigned.
@export var enable_3d_sfx: bool = false:
    set(value):
        enable_3d_sfx = value
        notify_property_list_changed()

## Enables music playback ([method AudioManager.play_music] and related methods) and
## instantiates the [MusicEngine]. Requires [member music_registry] to be assigned.
@export var enable_music: bool = true:
    set(value):
        enable_music = value
        notify_property_list_changed()

## Enables voiceline playback ([method AudioManager.play_voiceline]) and instantiates
## its dedicated [NonSpatialAudioPool]. Requires [member voiceline_registry] to be
## assigned.
@export var enable_voicelines: bool = false:
    set(value):
        enable_voicelines = value
        notify_property_list_changed()

@export_group("Pooling")
## Number of pooled voices for UI audio. Hidden unless [member enable_ui_audio] is set.
@export var max_ui_voices: int = 8
## Number of pooled voices for nonspatial SFX. Hidden unless [member enable_nonspatial_sfx] is set.
@export var max_nonspatial_sfx_voices: int = 32
## Number of pooled voices for 2D spatial SFX. Hidden unless [member enable_2d_sfx] is set.
@export var max_2d_sfx_voices: int = 32
## Number of pooled voices for 3D spatial SFX. Hidden unless [member enable_3d_sfx] is set.
@export var max_3d_sfx_voices: int = 32
## Number of pooled voices for voicelines. Hidden unless [member enable_voicelines] is set.
@export var max_voiceline_voices: int = 1

@export_group("Pause Features")
## Determines what pauses when the game pauses: only gameplay SFX (spatial, nonspatial,
## and voicelines) while music keeps playing, or both music and SFX together. See
## [enum PauseOptions].
@export var pause_on_pause: PauseOptions = PauseOptions.SFX:
    set(value):
        pause_on_pause = value
        notify_property_list_changed()
## Effects applied to the Music bus while paused, used only when [member pause_on_pause]
## is [constant PauseOptions.SFX] (i.e. music keeps playing under pause). Hidden when
## [member pause_on_pause] is [constant PauseOptions.MUSIC_AND_SFX].
@export var effects_on_pause: Array[AudioEffect] = []

@export_group("Voiceline Features")
## Whether playing a voiceline automatically ducks music and enabled SFX pools for its
## duration, restoring them once the voiceline finishes. Hidden unless
## [member enable_voicelines] is set.
@export var enable_ducking_on_voiceline: bool = true:
    set(value):
        enable_ducking_on_voiceline = value
        notify_property_list_changed()
## Volume, in decibels, applied to ducked audio while a voiceline is playing. Hidden
## unless both [member enable_voicelines] and [member enable_ducking_on_voiceline] are set.
@export_range(-24.0, 0.0) var ducking_volume_db: float = -5.0

@export_group("Registries")
## Registry of [SFXEntry] resources for UI sounds, keyed by [enum AudioEnums.UI].
## Required when [member enable_ui_audio] is set; hidden otherwise.
@export var ui_registry: UIAudioRegistry
## Registry of [SFXEntry] resources for sound effects, keyed by [enum AudioEnums.SFX].
## Required when any of [member enable_nonspatial_sfx], [member enable_2d_sfx], or
## [member enable_3d_sfx] is set; hidden when none are.
@export var sfx_registry: SFXRegistry
## Registry of [MusicEntry] resources, keyed by [enum AudioEnums.Music]. Required when
## [member enable_music] is set; hidden otherwise.
@export var music_registry: MusicRegistry
## Registry of [SFXEntry] resources for voicelines, keyed by [enum AudioEnums.Voiceline].
## Required when [member enable_voicelines] is set; hidden otherwise.
@export var voiceline_registry: VoicelineRegistry

## Determines which audio categories pause together. [constant SFX] pauses only
## gameplay SFX and voicelines, leaving music playing (optionally with
## [member effects_on_pause] applied to the Music bus); [constant MUSIC_AND_SFX]
## pauses music as well.
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