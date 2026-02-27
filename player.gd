extends CharacterBody3D

@export var run_speed: float = 5.0
@export var run_accel: float = 20.0
@export var run_accel_turn_bonus: float = 5.0
@export var gravity: float = 9.8
@export var jump_speed: float = 10.0

func _process(delta: float) -> void:
	
	# TODO dashing/balling
	
	# jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	
	if Input.is_action_just_released("jump") and velocity.y > jump_speed / 2:
		velocity.y = jump_speed / 2
	
	# running
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move == Vector2.ZERO:
		
		if Vector2(velocity.x, velocity.z).length_squared() < 1.0:
		
			velocity.x = 0
			velocity.z = 0
		
		else:
			
			var anti_velocity := Vector2(velocity.x, velocity.z).normalized() * -run_accel
			
			# apply drag
			velocity.x += anti_velocity.x * delta
			velocity.z += anti_velocity.y * delta
		
	else:
		
		var move_global := Vector3(move.x, 0.0, move.y) * global_basis
		
		# acceleration is higher when changing direction
		var opposition := Vector3(velocity.x, 0.0, velocity.z).normalized().dot(move_global)
		opposition = 1.0 - (opposition + 1.0) / 2.0
		
		move_global *= opposition * run_accel_turn_bonus + 1.0
		move_global *= run_accel * delta
		
		# apply move
		velocity.x += move_global.x
		velocity.z += move_global.z
		
	if Vector2(velocity.x, velocity.z).length() > run_speed:
		
		var new_velocity := Vector2(velocity.x, velocity.z).normalized() * run_speed
		
		velocity.x = new_velocity.x
		velocity.z = new_velocity.y
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
	
	# turn mesh towards direction of motion
	if Vector2(velocity.x, velocity.z).length_squared() > 1.0:
		$Mesh.global_rotation.y = lerp_angle($Mesh.global_rotation.y, atan2(velocity.x, velocity.z) - PI/2, 10.0 * delta)
