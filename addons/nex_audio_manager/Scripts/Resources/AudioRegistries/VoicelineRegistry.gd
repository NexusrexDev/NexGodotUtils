class_name VoicelineRegistry extends Resource

@export var registry: Dictionary[AudioEnums.Voiceline, SFXEntry] = {}

func get_entry(voiceline_type: AudioEnums.Voiceline) -> SFXEntry:
    return registry.get(voiceline_type, null)