class_name SFXRegistry extends Resource

@export var registry: Dictionary[AudioEnums.SFX, SFXEntry] = {}

func get_entry(sfx_type: AudioEnums.SFX) -> SFXEntry:
    return registry.get(sfx_type, null)