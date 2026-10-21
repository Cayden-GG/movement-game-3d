extends Node
class_name AudioManager

@export var player: Player

@export var audioPlayer: AudioStreamPlayer3D
@export var windPlayer: AudioStreamPlayer3D

@export var minWindSpeed: float = 12.0
@export var maxWindSpeed: float = 25.0 

@export var min_db: float = -80.0
@export var max_db: float = -60.0    

func _ready() -> void:
	windPlayer.volume_db = min_db

func _physics_process(delta: float) -> void:
	updateWind(delta)

func updateAudio(audio: String, velocity: float = 0.0) -> void:
	audioPlayer.volume_db = -15
	if audio == "none":
		audioPlayer.stop()
		return
	
	if audio == "walk":
		audioPlayer.pitch_scale = randf_range(0.95, 1.05)
	else:
		audioPlayer.pitch_scale = 1.0
	
	if audio == "land":
		audioPlayer.volume_db = clamp(remap(velocity, -5, -40, -20.0, -15.0), -50.0, -15.0) if velocity < -5 else -80
	
	audioPlayer["parameters/switch_to_clip"] = audio
	if not audioPlayer.playing:
		audioPlayer.play()

func updateWind(delta: float) -> void:
	if not windPlayer.playing:
		windPlayer.play()
	
	var currentSpeed = player.velocity.length()
	
	var speedFactor = clamp(remap(currentSpeed, minWindSpeed, maxWindSpeed, 0.0, 1.0), 0.0, 1.0)
	
	# Calculate target volume (dB) and target pitch
	var target_db = lerp(min_db, max_db, speedFactor)
	var targetPitch = lerp(0.85, 1.45, speedFactor) # Lower pitch when starting, higher pitch when flying
	
	# Smoothly lerp current values to prevent audio pops
	windPlayer.volume_db = lerp(windPlayer.volume_db, target_db, 10.0 * delta)
	windPlayer.pitch_scale = lerp(windPlayer.pitch_scale, targetPitch, 10.0 * delta)
