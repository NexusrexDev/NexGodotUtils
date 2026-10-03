## Defines an RTPC parameter and the audio effects it controls.
@tool
class_name RTPCData extends Resource

@export_group("Identification")
## Identifier used to update this RTPC through [method AudioManager.set_rtpc_value].
@export var parameter_id: StringName

@export_group("Effect Bindings")
## Audio effects and parameter mappings driven by this RTPC.
@export var effect_bindings: Array[RTPCEffectBinding] = []