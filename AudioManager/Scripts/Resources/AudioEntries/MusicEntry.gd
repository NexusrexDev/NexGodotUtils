class_name MusicEntry extends Resource

@export_group("Track Data")
@export_file("*.ogg", "*.mp3", "*.wav", "*.tres") var stream_path: String = ""

@export_group("Mixing")
@export_range(-80.0, 24.0) var volume_offset: float = 0.0