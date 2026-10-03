class_name MusicRegistry extends Resource

@export var registry: Dictionary[StringName, MusicEntry] = {}

func get_entry(music_key: StringName) -> MusicEntry:
    return registry.get(music_key, null)