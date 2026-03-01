extends Node3D

@export var camera_dist := 30

var is_rolling: bool = false

func _ready() -> void:
	
	$PlayerBall.disable()
	
	$Camera3D.position = $PlayerRun.position + Vector3(0.0, camera_dist * 0.6, camera_dist)
	$Camera3D.global_rotation = Vector3(deg_to_rad(-26), -PI / 4, 0)

func _process(delta: float) -> void:
	
	# place camera
	$Camera3D.global_position = lerp($Camera3D.global_position, ($PlayerBall if is_rolling else $PlayerRun).global_position + Vector3(-camera_dist, camera_dist * 0.8, camera_dist), 20.0 * delta)

func _physics_process(_delta: float) -> void:
	
	$PlayerBall/RotationLock.global_rotation = Vector3.ZERO
	
	# stop rolling if speed is too slow
	if is_rolling and $PlayerBall.linear_velocity.length() < $PlayerBall.dash_speed * 0.8:
		
		is_rolling = false
		_refresh_rolling()
	
	# dash into a roll
	if Input.is_action_just_pressed("dash") and not is_rolling:
		
		is_rolling = true
		_refresh_rolling()
	
	# jump out of a roll (if ball is grounded)
	elif Input.is_action_just_pressed("jump") and is_rolling and ($PlayerBall/RotationLock/GroundingRay1.is_colliding() or $PlayerBall/RotationLock/GroundingRay2.is_colliding() or $PlayerBall/RotationLock/GroundingRay3.is_colliding() or $PlayerBall/RotationLock/GroundingRay4.is_colliding()):
		
		is_rolling = false
		_refresh_rolling()

func _refresh_rolling() -> void:
	
	if is_rolling:
		
		var y = $PlayerRun.global_position.y
		var wall_bounce = $PlayerRun/Mesh/WallBounceRay.is_colliding()
		
		# disable PlayerRun
		$PlayerRun.disable()
		$PlayerRun.global_position.y = 1000.0
		
		# enable PlayerBall
		$PlayerBall.enable()
		$PlayerBall.global_position = Vector3($PlayerRun.global_position.x, y + 0.5, $PlayerRun.global_position.z)
		
		# dash PlayerBall in direction of input, unless WallBounceRay is colliding,
		# in which case we're trying to dash into a wall (which would cause us
		# to immediately exit the ball state, allowing us to scale walls), in which
		# case simply dash opposite to the direction of input
		var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var move_global: Vector3 = (Vector3(-move.y, 0.0, move.x) * global_basis) if (move != Vector2.ZERO) else ($PlayerRun/Mesh.global_basis.y)
		
		if wall_bounce:
			move_global = -move_global
		
		$PlayerBall.linear_velocity = (move_global.normalized() + Vector3.UP * 0.5) * $PlayerBall.dash_speed
		$PlayerBall.angular_velocity = Vector3.UP.cross($PlayerBall.linear_velocity)
		
	else:
		
		var y = $PlayerBall.global_position.y
		
		# copy velocity from PlayerBall to PlayerRun
		$PlayerRun.velocity = $PlayerBall.linear_velocity
		
		# disable PlayerBall
		$PlayerBall.disable()
		$PlayerBall.global_position.y = 1000.0
		
		# enable PlayerRun
		$PlayerRun.enable()
		$PlayerRun.global_position = Vector3($PlayerBall.global_position.x, y - 0.5, $PlayerBall.global_position.z)
