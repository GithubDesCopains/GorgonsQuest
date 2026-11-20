extends Node
class_name SoundManager

const AUDIO_BUS_SETUP = preload("res://Scripts/audio_bus_setup.gd")

## Sound Manager - Procedurally generates 8-bit retro sound effects

var audio_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var current_music_world: int = 0
var boss_music_active: bool = false
var _sfx_cache: Dictionary = {}

# ponytail: musique coupée (trop forte). Passer à true pour la réactiver; le volume reste réglable dans Options.
const MUSIC_ENABLED := false
const MUSIC_SAMPLE_RATE := 22050
const MUSIC_WORLD_PROFILES := {
	1: {"bpm": 112.0, "scale": [0, 2, 4, 7, 9], "root": 220.0, "wave": "triangle"},
	2: {"bpm": 82.0, "scale": [0, 3, 5, 7, 10], "root": 146.83, "wave": "sine"},
	3: {"bpm": 124.0, "scale": [0, 2, 4, 7, 11], "root": 196.0, "wave": "square"},
	4: {"bpm": 96.0, "scale": [0, 3, 5, 8, 10], "root": 164.81, "wave": "triangle"}
}
const MUSIC_MELODIES := {
	1: [0, 2, 4, 2, 1, 3, 4, 3, 0, 2, 4, 1, 3, 2, 1, 0],
	2: [0, 3, 1, 4, 2, 1, 3, 0, 4, 2, 1, 3, 0, 1, 2, 0],
	3: [0, 2, 4, 3, 2, 4, 1, 3, 0, 2, 4, 2, 3, 4, 2, 0],
	4: [0, 3, 2, 4, 1, 3, 0, 2, 4, 3, 1, 2, 0, 4, 2, 0]
}

func _ready():
	audio_player = AudioStreamPlayer.new()
	audio_player.name = "AudioPlayer"
	audio_player.bus = "SFX"
	AUDIO_BUS_SETUP.ensure_buses()
	add_child(audio_player)
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

func play_shoot():
	"""Petrify gaze: mythic breath rising into a shimmering hum (TASK-9.3)"""
	_play_sfx("gaze")

func play_petrify():
	"""Enemy petrified / freeze sound (high tone blip)"""
	var stream = generate_tone(600, 900, 0.15, "square")
	play_stream(stream)

func play_push():
	"""Push / slide sound (low thud)"""
	var stream = generate_tone(180, 120, 0.1, "triangle")
	play_stream(stream)

func play_squash():
	"""Enemy crushed by a heavy sliding block: deep thud, stone crack and rumble (TASK-9.3)"""
	_play_sfx("crush")

func play_shatter():
	"""Stone statue shattered: marble clinks over crumbling grit (TASK-9.3)"""
	_play_sfx("marble")

func play_bridge():
	"""Statue sinks in water: splash with bubbles (TASK-9.3)"""
	_play_sfx("splash")

func play_collect():
	"""Soul urn collected sound (arpeggio chime)"""
	var stream = generate_arpeggio([523, 659, 784, 1046], 0.04, "square")
	play_stream(stream)

func play_death():
	"""Player death sound (falling sadness pitch)"""
	var stream = generate_tone(400, 100, 0.5, "sawtooth")
	play_stream(stream)

func play_victory(final: bool = false):
	"""Level-clear fanfare; the longer one when the campaign is won (TASK-9.2)"""
	_play_sfx("final_fanfare" if final else "level_fanfare")

func play_game_over():
	"""Game over jingle: slow descending minor line (TASK-9.2)"""
	_play_sfx("game_over")

func play_boss_music() -> void:
	"""Switch to the intense boss loop; no-op while it already plays (TASK-9.2)"""
	if not MUSIC_ENABLED or music_player == null:
		return
	if boss_music_active and music_player.playing:
		return
	boss_music_active = true
	current_music_world = 0
	music_player.stream = _cached("boss_theme")
	music_player.play()

func end_boss_music(world: int) -> void:
	"""Boss beaten: hand the music back to the world theme."""
	if not boss_music_active:
		return
	boss_music_active = false
	play_world_music(world, true)

func play_stream(stream: AudioStreamWAV):
	if stream and audio_player:
		audio_player.stream = stream
		audio_player.play()

func play_world_music(world: int, force_restart: bool = false) -> void:
	"""Start or keep the original procedural ambient theme for selected world."""
	if not MUSIC_ENABLED:
		return
	var normalized_world := clampi(world, 1, 4)
	if current_music_world == normalized_world and music_player.playing and not force_restart:
		return
	boss_music_active = false   # a world theme always replaces the boss loop
	current_music_world = normalized_world
	var stream := generate_world_music(normalized_world)
	if not stream:
		return
	music_player.stream = stream
	music_player.play()

func stop_world_music() -> void:
	if music_player:
		music_player.stop()
	current_music_world = 0
	boss_music_active = false

func is_world_music_playing(world: int) -> bool:
	return music_player != null and music_player.playing and current_music_world == clampi(world, 1, 4)

func generate_world_music(world: int) -> AudioStreamWAV:
	"""Generate an original loop from melody, bass pulse and world-specific scale/timbre."""
	var normalized_world := clampi(world, 1, 4)
	var profile: Dictionary = MUSIC_WORLD_PROFILES[normalized_world]
	var melody: Array = MUSIC_MELODIES[normalized_world]
	var beat_seconds: float = 60.0 / float(profile["bpm"])
	var step_seconds: float = beat_seconds * 0.5
	var total_seconds: float = step_seconds * melody.size()
	var sample_count := int(MUSIC_SAMPLE_RATE * total_seconds)
	var data := PackedByteArray()
	data.resize(sample_count)
	var scale: Array = profile["scale"]
	var root: float = profile["root"]
	var waveform: String = profile["wave"]
	for sample_index in range(sample_count):
		var time := float(sample_index) / MUSIC_SAMPLE_RATE
		var step_index := mini(int(time / step_seconds), melody.size() - 1)
		var step_phase := fposmod(time, step_seconds) / step_seconds
		var note_index: int = melody[step_index]
		var semitones: int = int(scale[note_index])
		# Melody sits above the root; each four-step phrase shifts chord color.
		var phrase_shift := 0 if int(step_index / 4) % 2 == 0 else 5
		var melody_freq := root * pow(2.0, float(semitones + phrase_shift + 12) / 12.0)
		var beat_index := int(time / beat_seconds)
		var bass_freq := root * (0.5 if beat_index % 4 == 0 else 0.75)
		var melody_env := minf(1.0, step_phase * 12.0) * (1.0 - step_phase * 0.72)
		var bass_env := maxf(0.0, 1.0 - fposmod(time, beat_seconds) / beat_seconds) * 0.35
		var melody_wave := _wave_sample(time, melody_freq, waveform)
		var bass_wave := _wave_sample(time, bass_freq, "sine")
		# Quiet click-like pulse, softened to avoid harsh square-wave clipping.
		var pulse := 0.0
		if fposmod(time, beat_seconds) < 0.035:
			pulse = 0.08 * (1.0 - fposmod(time, beat_seconds) / 0.035)
		var sample := clampf(melody_wave * melody_env * 0.30 + bass_wave * bass_env * 0.42 + pulse, -0.85, 0.85)
		data[sample_index] = int(clampf((sample + 1.0) * 127.5, 0.0, 255.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = MUSIC_SAMPLE_RATE
	wav.data = data
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	wav.loop_end = sample_count
	return wav

func _wave_sample(time: float, frequency: float, waveform: String) -> float:
	return _shape(fposmod(time * frequency, 1.0), waveform)

func _shape(phase: float, waveform: String) -> float:
	match waveform:
		"square": return 1.0 if phase < 0.5 else -1.0
		"triangle": return 1.0 - 4.0 * absf(phase - 0.5)
		"sawtooth": return phase * 2.0 - 1.0
		_: return sin(phase * TAU)

# --- TASK-9.2 / 9.3: layered procedural SFX, jingles and boss theme (16-bit, mixed from float buffers) ---

const SFX_NAMES := ["gaze", "crush", "marble", "splash", "level_fanfare", "final_fanfare", "game_over", "boss_theme"]
# Phrygian-flavoured riff, in semitones above the root (-1 = rest); eighth notes, played twice.
const BOSS_RIFF := [0, -1, 0, 1, 0, -1, 7, 6, 0, -1, 0, 1, 3, -1, 1, 0]
const BOSS_BPM := 148.0
const BOSS_ROOT := 110.0

func _play_sfx(sfx_name: String) -> void:
	play_stream(_cached(sfx_name))

func _cached(sfx_name: String) -> AudioStreamWAV:
	if not _sfx_cache.has(sfx_name):
		_sfx_cache[sfx_name] = generate_sfx(sfx_name)
	return _sfx_cache[sfx_name]

func generate_sfx(sfx_name: String) -> AudioStreamWAV:
	"""Build one named effect, jingle or loop. Deterministic: noise uses a fixed seed."""
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(sfx_name)
	var buf: PackedFloat32Array
	match sfx_name:
		"gaze":
			buf = _new_buffer(0.32)
			_add_noise(buf, rng, 0.0, 0.2, 0.35, 0.25, 1.5)       # breath
			_add_tone(buf, 0.0, 0.3, 260.0, 880.0, "sine", 0.4, 1.2)  # rising hum
			_add_tone(buf, 0.04, 0.26, 523.0, 1318.0, "triangle", 0.18, 1.6)  # shimmer
		"crush":
			buf = _new_buffer(0.42)
			_add_tone(buf, 0.0, 0.3, 120.0, 38.0, "sine", 0.9, 2.0)   # deep thud
			_add_noise(buf, rng, 0.0, 0.4, 0.5, 0.08, 2.5)             # rumble
			_add_noise(buf, rng, 0.015, 0.05, 0.5, 0.6, 3.0)           # stone crack
		"marble":
			buf = _new_buffer(0.45)
			for hit in [[0.0, 2400.0], [0.045, 3150.0], [0.1, 1850.0], [0.17, 2750.0]]:
				_add_tone(buf, hit[0], 0.12, hit[1], hit[1] * 0.96, "sine", 0.28, 4.0)   # clinking shards
			_add_noise(buf, rng, 0.0, 0.3, 0.3, 0.4, 2.5)              # crumbling grit
		"splash":
			buf = _new_buffer(0.5)
			_add_noise(buf, rng, 0.0, 0.34, 0.6, 0.18, 2.0)            # water body
			_add_noise(buf, rng, 0.0, 0.1, 0.35, 0.7, 3.0)             # spray
			for bubble in [0.12, 0.2, 0.28, 0.36]:
				_add_tone(buf, bubble, 0.07, 380.0 + bubble * 900.0, 900.0 + bubble * 1200.0, "sine", 0.22, 3.0)
		"level_fanfare":
			buf = _new_buffer(1.5)
			_add_notes(buf, [[523.25, 0.0, 0.14], [659.25, 0.14, 0.14], [783.99, 0.28, 0.14], [1046.5, 0.42, 0.3]], "square", 0.2)
			_add_notes(buf, [[261.63, 0.0, 0.42], [392.0, 0.42, 1.0], [523.25, 0.42, 1.0], [659.25, 0.42, 1.0]], "triangle", 0.22)
		"final_fanfare":
			buf = _new_buffer(3.6)
			_add_notes(buf, [[392.0, 0.0, 0.2], [523.25, 0.2, 0.2], [659.25, 0.4, 0.2], [783.99, 0.6, 0.2], [1046.5, 0.8, 0.5], [880.0, 1.3, 0.2], [1046.5, 1.5, 0.2], [1318.5, 1.7, 1.6]], "square", 0.18)
			_add_notes(buf, [[196.0, 0.0, 0.8], [261.63, 0.8, 0.9], [349.23, 1.7, 0.4], [261.63, 2.1, 1.4], [329.63, 1.7, 1.9], [523.25, 1.7, 1.9]], "triangle", 0.26)
		"game_over":
			buf = _new_buffer(2.3)
			_add_notes(buf, [[440.0, 0.0, 0.45], [349.23, 0.5, 0.45], [293.66, 1.0, 0.45], [220.0, 1.5, 0.75]], "triangle", 0.4)
			_add_notes(buf, [[110.0, 1.5, 0.75], [103.83, 0.0, 1.4]], "sine", 0.3)
		"boss_theme":
			return _generate_boss_theme()
		_:
			return null
	return _to_wav(buf, false)

func _generate_boss_theme() -> AudioStreamWAV:
	var eighth := 30.0 / BOSS_BPM
	var steps: int = BOSS_RIFF.size() * 2
	var buf := _new_buffer(eighth * steps)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for step in range(steps):
		var t := step * eighth
		var semitone: int = BOSS_RIFF[step % BOSS_RIFF.size()]
		var lift := 5 if step >= BOSS_RIFF.size() else 0     # second pass sits higher for tension
		if semitone >= 0:
			var bass := BOSS_ROOT * pow(2.0, float(semitone) / 12.0)
			var lead := bass * 4.0 * pow(2.0, float(lift) / 12.0)
			_add_tone(buf, t, eighth * 0.9, bass, bass, "sawtooth", 0.2, 1.2)
			_add_tone(buf, t, eighth * 0.8, lead, lead, "square", 0.07, 2.0)
		if step % 4 == 0:   # kick
			_add_tone(buf, t, 0.12, 140.0, 45.0, "sine", 0.55, 3.0)
		if step % 4 == 2:   # snare
			_add_noise(buf, rng, t, 0.09, 0.28, 0.55, 3.0)
	return _to_wav(buf, true)

func _new_buffer(seconds: float) -> PackedFloat32Array:
	var buf := PackedFloat32Array()
	buf.resize(int(MUSIC_SAMPLE_RATE * seconds))
	return buf

func _add_tone(buf: PackedFloat32Array, start: float, duration: float, f0: float, f1: float, waveform: String, amp: float, decay: float) -> void:
	"""Mix a pitch-sweeping tone into buf. 'decay' shapes the fade: higher = faster."""
	var first := int(start * MUSIC_SAMPLE_RATE)
	var count := mini(int(duration * MUSIC_SAMPLE_RATE), buf.size() - first)
	var phase := 0.0
	for i in range(maxi(count, 0)):
		var t := float(i) / float(maxi(count, 1))
		phase = fposmod(phase + lerpf(f0, f1, t) / MUSIC_SAMPLE_RATE, 1.0)
		var attack := minf(1.0, float(i) / 40.0)     # tiny fade-in avoids clicks
		buf[first + i] += _shape(phase, waveform) * amp * attack * pow(1.0 - t, decay)

func _add_noise(buf: PackedFloat32Array, rng: RandomNumberGenerator, start: float, duration: float, amp: float, brightness: float, decay: float) -> void:
	"""Mix low-passed noise into buf. brightness 0..1: low = rumble, high = hiss."""
	var first := int(start * MUSIC_SAMPLE_RATE)
	var count := mini(int(duration * MUSIC_SAMPLE_RATE), buf.size() - first)
	var smooth := 0.0
	for i in range(maxi(count, 0)):
		var t := float(i) / float(maxi(count, 1))
		smooth = lerpf(smooth, rng.randf_range(-1.0, 1.0), clampf(brightness, 0.02, 1.0))
		buf[first + i] += smooth * amp * pow(1.0 - t, decay)

func _add_notes(buf: PackedFloat32Array, notes: Array, waveform: String, amp: float) -> void:
	"""notes: [[frequency, start_seconds, duration_seconds], ...]"""
	for note in notes:
		_add_tone(buf, note[1], note[2], note[0], note[0], waveform, amp, 1.1)

func _to_wav(buf: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(buf.size() * 2)
	for i in range(buf.size()):
		data.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 30000.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = MUSIC_SAMPLE_RATE
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = buf.size()
	return wav

func generate_tone(start_freq: float, end_freq: float, duration: float, waveform: String) -> AudioStreamWAV:
	var sample_rate = 22050
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples)
	
	var phase = 0.0
	for i in range(num_samples):
		var t = float(i) / float(num_samples)
		var current_freq = lerp(start_freq, end_freq, t)
		phase += (current_freq / sample_rate) * TAU
		
		# Envelope (fade out at the end)
		var envelope = 1.0 - t
		
		var sample_val = 0.0
		match waveform:
			"square":
				sample_val = 1.0 if sin(phase) >= 0.0 else -1.0
			"triangle":
				sample_val = (abs(fmod(phase / PI, 2.0) - 1.0) - 0.5) * 2.0
			"sawtooth":
				sample_val = (fmod(phase / TAU, 1.0) - 0.5) * 2.0
			"sine", _:
				sample_val = sin(phase)
		
		# 8-bit unsigned PCM: range 0 to 255 (128 is silence)
		var byte_val = int(clamp((sample_val * envelope * 0.4 + 1.0) * 127.5, 0, 255))
		data[i] = byte_val
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func generate_arpeggio(notes: Array, note_duration: float, waveform: String) -> AudioStreamWAV:
	var sample_rate = 22050
	var total_duration = note_duration * notes.size()
	var num_samples = int(sample_rate * total_duration)
	var data = PackedByteArray()
	data.resize(num_samples)
	
	var samples_per_note = int(sample_rate * note_duration)
	
	for n_idx in range(notes.size()):
		var freq = notes[n_idx]
		var phase = 0.0
		for i in range(samples_per_note):
			var global_i = n_idx * samples_per_note + i
			if global_i >= num_samples:
				break
			
			phase += (freq / sample_rate) * TAU
			var t_note = float(i) / float(samples_per_note)
			var envelope = 1.0 - t_note * 0.5
			
			var sample_val = 1.0 if sin(phase) >= 0.0 else -1.0
			if waveform == "sawtooth":
				sample_val = (fmod(phase / TAU, 1.0) - 0.5) * 2.0
			
			var byte_val = int(clamp((sample_val * envelope * 0.4 + 1.0) * 127.5, 0, 255))
			data[global_i] = byte_val
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav
