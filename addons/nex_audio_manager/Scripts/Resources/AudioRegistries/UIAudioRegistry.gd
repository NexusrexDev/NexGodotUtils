class_name UIAudioRegistry extends Resource

@export var registry: Dictionary[AudioEnums.UI, SFXEntry] = {}

func get_entry(ui_type: AudioEnums.UI) -> SFXEntry:
    return registry.get(ui_type, null)