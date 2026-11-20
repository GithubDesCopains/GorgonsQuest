extends Node
class_name AudioBusSetup

## Creates dedicated runtime buses so music and effects have independent volume.

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"

static func ensure_buses() -> void:
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)

static func _ensure_bus(bus_name: String) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		return
	AudioServer.add_bus()
	index = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")

static func set_volume(bus_name: String, value: float) -> void:
	ensure_buses()
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		var clamped := clampf(value, 0.0, 1.0)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(clamped, 0.0001)))
		AudioServer.set_bus_mute(index, clamped <= 0.0)

static func get_volume(bus_name: String) -> float:
	ensure_buses()
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0 or AudioServer.is_bus_mute(index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(index)), 0.0, 1.0)

static func apply_saved_volumes(save_data: Dictionary) -> void:
	set_volume(MUSIC_BUS, float(save_data.get("music_volume", 1.0)))
	set_volume(SFX_BUS, float(save_data.get("sfx_volume", 1.0)))
