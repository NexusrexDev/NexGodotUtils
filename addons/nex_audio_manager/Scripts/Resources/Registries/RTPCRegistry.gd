class_name RTPCRegistry extends Resource

@export var registry: Array[RTPCData] = []

func get_all_entries() -> Array[RTPCData]:
    return registry