## Maps an RTPC value to a numeric property on an injected audio effect.
@tool
class_name RTPCParameterMapping extends Resource

var _parent_effect: AudioEffect:
	set(value):
		_parent_effect = value
		notify_property_list_changed()

## Name of the numeric property on the injected effect to update.
@export var target_parameter: StringName:
	set(value):
		target_parameter = value
		notify_property_list_changed()

## Curve used to transform the RTPC value before it is remapped to the target
## property's range.
@export var mapping_curve: Curve
## Minimum value of the target effect property after curve mapping.
@export var min_value: float = 0.0
## Maximum value of the target effect property after curve mapping.
@export var max_value: float = 1.0

func _validate_property(property: Dictionary) -> void:
	if property.name == "target_parameter":
		if not _parent_effect:
			property.usage &= ~PROPERTY_USAGE_EDITOR
			return
			
		var valid_properties: PackedStringArray = []
		for prop in _parent_effect.get_property_list():
			if (prop["usage"] & PROPERTY_USAGE_EDITOR) and prop["type"] in [TYPE_FLOAT, TYPE_INT]:
				valid_properties.append(prop["name"])
		
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(valid_properties)

	if property.name == "min_value" or property.name == "max_value":
		if not _parent_effect or target_parameter.is_empty():
			return
			
		for prop in _parent_effect.get_property_list():
			if prop["name"] == target_parameter:
				property.hint = prop["hint"]
				property.hint_string = prop["hint_string"]
				return