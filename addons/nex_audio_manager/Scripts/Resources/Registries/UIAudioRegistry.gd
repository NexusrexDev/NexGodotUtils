class_name UIAudioRegistry extends Resource

@export var registry: Dictionary[StringName, SFXEntry] = {}

func get_entry(ui_key: StringName) -> SFXEntry:
    return registry.get(ui_key, null)