## Associates an RTPC with an injected audio effect on a logical audio bus.
@tool
class_name RTPCEffectBinding extends Resource

## Logical audio bus that receives the injected effect.
@export var target_bus: AudioEnums.Buses

## Audio effect instance controlled by the associated RTPC mappings.
@export var injected_effect: AudioEffect:
	set(value):
		injected_effect = value
		_update_children_effects()
		notify_property_list_changed()

@export_group("Mappings")
## Effect properties controlled by the associated RTPC.
@export var parameter_mappings: Array[RTPCParameterMapping] = []:
	set(value):
		parameter_mappings = value
		_update_children_effects()

func _update_children_effects() -> void:
	for mapping in parameter_mappings:
		if mapping != null:
			mapping._parent_effect = injected_effect