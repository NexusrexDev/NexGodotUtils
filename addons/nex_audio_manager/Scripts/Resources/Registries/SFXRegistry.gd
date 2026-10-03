class_name SFXRegistry extends Resource

@export var registry: Dictionary[StringName, SFXEntry] = {}

func get_entry(sfx_key: StringName) -> SFXEntry:
    return registry.get(sfx_key, null)