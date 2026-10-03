class_name VoicelineRegistry extends Resource

@export var registry: Dictionary[StringName, SFXEntry] = {}

func get_entry(voiceline_key: StringName) -> SFXEntry:
    return registry.get(voiceline_key, null)