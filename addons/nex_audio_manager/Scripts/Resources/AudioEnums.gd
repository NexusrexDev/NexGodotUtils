## Centralized identifiers for the audio system, used in place of raw strings
## or direct resource references throughout the plugin.
##
## Each enum here is a lookup key into a corresponding registry (e.g.
## [AudioEnums.SFX] values are keyed against an [SFXRegistry]), except for
## [Buses], which identifies the plugin's managed audio buses directly.
## Extend these enums with your own values as your project grows.
class_name AudioEnums extends RefCounted

## The logical audio buses this plugin creates and manages. Used both to
## auto-create/sync buses via [method get_bus_name] and to route/control
## them from [AudioManager]'s bus-control methods.
enum Buses
{
	MASTER,
	MUSIC,
	SFX,
	VOICE,
	UI
}

## Keys into a [MusicRegistry] to select a [MusicEntry] for [method AudioManager.play_music].
enum Music
{
	TRACK_1,
	TRACK_2
}

## Keys into an [SFXRegistry] to select an [SFXEntry] for spatial or
## nonspatial sound effect playback.
enum SFX
{
	JUMP
}

## Keys into a [UIAudioRegistry] to select an [SFXEntry] for UI sounds.
enum UI
{
	CLICK
}

## Keys into a [VoicelineRegistry] to select an [SFXEntry] for voicelines.
enum Voiceline
{
	PLAYER_VO_T1
}

## Returns the actual [AudioServer] bus name for a given [enum Buses] value.
## [param SFX] and [param UI] are kept as-is; every other bus name is
## title-cased (e.g. [param MUSIC] -> "Music") to match Godot's own
## "Master" bus convention. Always route bus name lookups through this
## method rather than reading [method @GlobalScope.Buses.keys] directly,
## so bus creation and bus lookup can never drift out of sync.
static func get_bus_name(bus_enum: Buses) -> String:
	var bus_name: String = Buses.keys()[bus_enum]
	if bus_name in ["SFX", "UI"]:
		return bus_name
	return bus_name.capitalize()