# Nex's Audio Manager
A simple plugin that adds an autoload (`AudioManager`) that wraps music, SFX (Spatial -2D/3D- and Nonspatial), UI sounds and voicelines behind a simple API, along with automatic bus setup.

## Installing
1. Copy `addons/nex_audio_manager/` into your project's `addons/` folder.
2. In **Project > Project Settings > Plugins**, enable "Nex's Audio Manager".
3. On enable, the plugin automatically:
   - Registers `Scripts/Core/AudioManager.gd` directly as an autoload singleton named `AudioManager`
   - Makes sure an `AudioConfig` is configured by showing a dialog to set the config file's location. If you cancel the dialog, you'll need to create the `AudioConfig` yourself and assign it manually (**Project Settings > General > Plugins > Nex Audio Manager > Active Config**, requires **Advanced Settings** to be on).
   - Sets the default audio bus to `Resources/bus_layout.tres` and updates it to resemble the entries in `AudioEnums.Buses`
4. Toggle the features as needed in your project, create the needed audio registries, fill them with the needed data and assign their references back in the `AudioConfig` resource. Missing any registries will stop the initialization process.
5. You can re-run the bus setup at any time from the editor's **Tools** menu under **Nex's Audio Manager > Sync Buses from Enum**. Use it after you add a new bus to the enum.
6. Disabling the plugin removes the autoload, and clears both the default bus layout and the project settings (it does not delete the underlying `.tres` files).

## Settubg up registries
1. Create/open a registry's `.tres` file and expand its `registry` dictionary.
2. Add an entry per `StringName` key you want to support, e.g. `&"jump" -> <a resource>`.
3. For the value, create a `MusicEntry` or `SFXEntry` inline and fill it in.
4. Assign the registry to its slots on your `AudioConfig`.

## Setting Up RTPCs
1. Create a `RTPCRegistry` resource and assign it to the `rtpc_registry` field on your `AudioConfig`.
2. Expand the registry's `registry` array and add an `RTPCData` resource.
3. Set the `parameter_id` to the `StringName` you will pass to `AudioManager.set_rtpc_value`, such as `&"underwater"`.
4. Add an `RTPCEffectBinding` to the RTPC's `effect_bindings`, select the target bus, and assign an `AudioEffect` to inject on that bus.
5. Add an `RTPCParameterMapping` to the binding for each effect property you want to control. Select the target parameter, assign a mapping curve, and set its minimum and maximum values.
6. Update the parameter at runtime by passing its identifier and a value to `AudioManager.set_rtpc_value`:
```gdscript
AudioManager.set_rtpc_value(&"underwater", underwater_amount)
```

## Features
- Simple autoload singleton to interface with the music and sfx submodules, accessed through `AudioManager`. (Check the class' documentation for methods)
```gdscript
AudioManager.play_sfx_nonspatial(&"jump")
AudioManager.play_music(&"track_1", 1.5)
```
- `StringName` keys to assign entries in the registries and call methods instead of referring to `AudioStream` resources. Add keys directly to each registry. Bus identifiers remain in `Scripts/Resources/AudioEnums.gd`.
- Registries with properties for easier use
    - Music Entries allow to assign any type of appropriate `AudioStream` (with API support for `AudioStreamInteractive` and `AudioStreamSynchronized`) along with an audio offset
    - SFX Entries allow to assign an array of `AudioStream`s for random audio selection, plus optional pitch and volume jitter ranges and 2D/3D spatial attenuation settings.
- Spatial sound effects with support for both positioned and Node targetting/following settings.
- Voicelines with toggleable volume ducking.
- Configurable pause behavior, allowing to only pause gameplay SFX (spatial, nonspatial and voicelines), or both gameplay SFX and music, plus adding effects to apply on the music bus when paused.
- Real-time parameter controls (RTPCs) that map values through curves to properties on injected audio effects, allowing effects such as environment-driven reverb or low-pass filtering.