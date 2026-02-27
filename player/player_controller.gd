extends Node3D

@export var camera_dist := 30

var is_rolling: bool = false

func _ready() -> void:
	
	$PlayerBall.disable()
	
	$Camera3D.global_position = $PlayerRun.global_position + Vector3(-camera_dist, camera_dist * 0.8, camera_dist)
	$Camera3D.global_rotation = Vector3(deg_to_rad(-26), -PI / 4, 0)

func _process(delta: float) -> void:
	
	# place camera
	$Camera3D.global_position = lerp($Camera3D.global_position, ($PlayerBall if is_rolling else $PlayerRun).global_position + Vector3(-camera_dist, camera_dist * 0.8, camera_dist), 20.0 * delta)
	
	# stop rolling if speed is too slow
	if is_rolling and $PlayerBall.linear_velocity.length() < 10.0:
		
		is_rolling = false
		_refresh_rolling()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("dash") and not is_rolling:
		
		is_rolling = true
		_refresh_rolling()
	
	elif event.is_action_pressed("jump") and is_rolling:
		
		is_rolling = false
		_refresh_rolling()

func _refresh_rolling() -> void:
	
	if is_rolling:
		
		$PlayerRun.disable()
		$PlayerBall.enable()
		
		$PlayerBall.global_position = $PlayerRun.global_position + Vector3(0.0, 0.5, 0.0)
		
		$PlayerBall.linear_velocity = ($PlayerRun/Mesh.global_basis.y + Vector3.UP * 0.5) * max($PlayerBall.dash_speed, $PlayerRun.velocity.length())
		$PlayerBall.angular_velocity = Vector3.UP.cross($PlayerBall.linear_velocity)
		
	else:
		
		$PlayerBall.disable()
		$PlayerRun.enable()
		
		$PlayerRun.global_position = $PlayerBall.global_position - Vector3(0.0, 0.5, 0.0)
		
		$PlayerRun.velocity = $PlayerBall.linear_velocity
