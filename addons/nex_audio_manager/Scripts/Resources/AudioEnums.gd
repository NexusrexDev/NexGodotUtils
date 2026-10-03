## Identifiers for the audio system's managed buses.
##
## Audio registry entries are keyed by [StringName] values supplied by the
## project. Only buses are kept here because they are managed by the plugin.
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