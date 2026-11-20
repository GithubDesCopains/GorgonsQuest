extends RefCounted
class_name ControllerInput

## Adds standard Godot joypad controls to existing keyboard actions once.

static var _configured := false

static func configure() -> void:
	if _configured:
		return
	_configured = true
	_add_button("move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_button("move_left", JOY_BUTTON_DPAD_LEFT)
	_add_button("move_up", JOY_BUTTON_DPAD_UP)
	_add_button("move_down", JOY_BUTTON_DPAD_DOWN)
	_add_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_axis("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_add_axis("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_button("petrify_shot", JOY_BUTTON_A)
	_add_button("petrify_shot", JOY_BUTTON_X)
	_add_button("create_pillar", JOY_BUTTON_B)
	_add_button("create_pillar", JOY_BUTTON_Y)
	if not InputMap.has_action("break_statue"):
		InputMap.add_action("break_statue")
	_add_key("break_statue", KEY_Q)
	_add_button("break_statue", JOY_BUTTON_RIGHT_SHOULDER)
	# Turn the mirror the hero is facing (E, or the left shoulder button).
	if not InputMap.has_action("rotate_mirror"):
		InputMap.add_action("rotate_mirror")
	_add_key("rotate_mirror", KEY_E)
	_add_button("rotate_mirror", JOY_BUTTON_LEFT_SHOULDER)
	_add_button("ui_accept", JOY_BUTTON_A)
	_add_button("ui_cancel", JOY_BUTTON_B)
	_add_button("ui_cancel", JOY_BUTTON_START)
	_add_button("ui_up", JOY_BUTTON_DPAD_UP)
	_add_button("ui_down", JOY_BUTTON_DPAD_DOWN)
	_add_button("ui_left", JOY_BUTTON_DPAD_LEFT)
	_add_button("ui_right", JOY_BUTTON_DPAD_RIGHT)

static func _add_button(action: StringName, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		return
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)

static func _add_key(action: StringName, keycode: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

static func _add_axis(action: StringName, axis_index: JoyAxis, direction: float) -> void:
	if not InputMap.has_action(action):
		return
	var event := InputEventJoypadMotion.new()
	event.axis = axis_index
	event.axis_value = direction
	InputMap.action_add_event(action, event)
