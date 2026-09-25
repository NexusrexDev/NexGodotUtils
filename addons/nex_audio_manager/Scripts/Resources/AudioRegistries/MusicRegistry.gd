class_name MusicRegistry extends Resource

@export var registry: Dictionary[AudioEnums.Music, MusicEntry] = {}

func get_entry(music_type: AudioEnums.Music) -> MusicEntry:
    return registry.get(music_type, null)