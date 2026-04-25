class_name AudioCache extends Node

class CacheEntry:
    var stream: AudioStream
    var last_used_time: float

    func _init(s: AudioStream, t:float) -> void:
        stream = s
        last_used_time = t

var _sfx_cache: Dictionary[String, CacheEntry] = {}
var _ui_cache: Dictionary[String, CacheEntry] = {}
var _voiceline_cache: Dictionary[String, CacheEntry] = {}
var _music_cache: Dictionary[String, CacheEntry] = {}

var _gc_timer: Timer
var wait_time: float

func _ready() -> void:
    _gc_timer = Timer.new()
    _gc_timer.timeout.connect(_on_gc_timeout)
    add_child(_gc_timer)

func set_gc_params(enabled: bool, interval_minutes: float) -> void:
    if not enabled: return
    
    wait_time = interval_minutes * 60.0
    _gc_timer.wait_time = wait_time
    _gc_timer.start()

func _on_gc_timeout() -> void:
    _flush_timeout(_sfx_cache)
    _flush_timeout(_ui_cache)
    _flush_timeout(_voiceline_cache)

func get_sfx(path: String) -> AudioStream:
    return _get_audio(path, _sfx_cache)

func flush_all_sfx() -> void:
    _sfx_cache.clear()

func get_ui(path: String) -> AudioStream:
    return _get_audio(path, _ui_cache)

func get_voiceline(path: String) -> AudioStream:
    return _get_audio(path, _voiceline_cache)

func flush_all_voicelines() -> void:
    _voiceline_cache.clear()

func flush_all() -> void:
    _sfx_cache.clear()
    _ui_cache.clear()
    _voiceline_cache.clear()

func get_music(path: String) -> AudioStream:
    return _get_audio(path, _music_cache)

func unload_music(path: String) -> void:
    if path.is_empty(): return

    if _music_cache.has(path):
        _music_cache.erase(path)

func _get_audio(path: String, cache_dict: Dictionary[String, CacheEntry]) -> AudioStream:
    if path.is_empty(): return null

    var current_time: float = Time.get_ticks_msec() / 1000.0

    if cache_dict.has(path):
        cache_dict[path].last_used_time = current_time
        return cache_dict[path].stream
    
    var loaded_stream: AudioStream = load(path)
    if loaded_stream:
        cache_dict[path] = CacheEntry.new(loaded_stream, current_time)
        return loaded_stream
    
    return null

func _flush_timeout(cache_dict: Dictionary[String, CacheEntry]) -> void:
    var current_time: float = Time.get_ticks_msec() / 1000.0
    for key: String in cache_dict.keys():
        if abs(current_time - cache_dict[key].last_used_time) >= wait_time:
            cache_dict.erase(key)