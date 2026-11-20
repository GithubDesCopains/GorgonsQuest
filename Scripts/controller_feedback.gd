extends RefCounted
class_name ControllerFeedback

## Small, safe vibration helper for connected gamepads.

static func vibrate(duration: float = 0.12, weak_magnitude: float = 0.15, strong_magnitude: float = 0.45) -> void:
	var duration_safe := clampf(duration, 0.0, 1.0)
	var weak_safe := clampf(weak_magnitude, 0.0, 1.0)
	var strong_safe := clampf(strong_magnitude, 0.0, 1.0)
	if duration_safe <= 0.0:
		return
	for device in Input.get_connected_joypads():
		Input.start_joy_vibration(device, weak_safe, strong_safe, duration_safe)

static func stop_all() -> void:
	for device in Input.get_connected_joypads():
		Input.stop_joy_vibration(device)
