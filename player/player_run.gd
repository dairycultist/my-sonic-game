extends CharacterBody3D

@export var run_speed: float = 5.0
@export var run_accel: float = 20.0
@export var run_accel_turn_bonus: float = 5.0
@export var jump_speed: float = 10.0

var orient_up: Vector3 = Vector3.UP

func enable():
	set_process(true)
	$Mesh.visible = true
	$Collider.disabled = false

func disable():
	set_process(false)
	$Mesh.visible = false
	$Collider.disabled = true
	$AnimationPlayer.current_animation = "RESET"

func _process(delta: float) -> void:
	
	# jumping (we're using a ray since it's a little more consistent when
	# jumping out of ball form)
	if Input.is_action_pressed("jump") and $GroundingRay.is_colliding():
		velocity.y = jump_speed
	
	if Input.is_action_just_released("jump") and velocity.y > jump_speed / 2:
		velocity.y = jump_speed / 2
	
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if move == Vector2.ZERO:
		
		# drag
		if Vector2(velocity.x, velocity.z).length_squared() < 1.0:
		
			velocity.x = 0
			velocity.z = 0
		
		else:
			
			var anti_velocity := Vector2(velocity.x, velocity.z).normalized() * -run_accel
			
			# apply drag
			velocity.x += anti_velocity.x * delta
			velocity.z += anti_velocity.y * delta
		
	else:
		
		var prev_speed := Vector2(velocity.x, velocity.z).length()
		
		# running
		var move_global := Vector3(-move.y, 0.0, move.x) * get_parent_node_3d().global_basis
		
		# acceleration is higher when changing direction
		var opposition := Vector3(velocity.x, 0.0, velocity.z).normalized().dot(move_global)
		opposition = 1.0 - (opposition + 1.0) / 2.0
		
		move_global *= opposition * run_accel_turn_bonus + 1.0
		move_global *= run_accel * delta
		
		# apply running
		velocity.x += move_global.x
		velocity.z += move_global.z
	
		# when current speed is greater than run_speed, speed cannot increase from running
		# (allows for maintaining speeds greater than run_speed after exiting a roll)
		if prev_speed > run_speed and Vector2(velocity.x, velocity.z).length() > prev_speed:
			
			var new_velocity := Vector2(velocity.x, velocity.z).normalized() * prev_speed
			
			velocity.x = new_velocity.x
			velocity.z = new_velocity.y
	
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	move_and_slide()
	
	# turn mesh towards direction of motion, orienting up with floor normal
	orient_up = lerp(orient_up, get_floor_normal() if is_on_floor() else Vector3.UP, 10.0 * delta)
		
	$Mesh.look_at(orient_up + $Mesh.global_position, Vector3(velocity.x, 0.0, velocity.z) if (Vector2(velocity.x, velocity.z).length_squared() > 1.0) else $Mesh.global_basis.y, true)
	
	# animate bones
	if is_on_floor():
		if velocity.length_squared() > 1.0:
			$AnimationPlayer.current_animation = "run"
			$AnimationPlayer.speed_scale = Vector2(velocity.x, velocity.z).length() * 0.15
		else:
			$AnimationPlayer.current_animation = "idle"
			$AnimationPlayer.speed_scale = 1.5
	else:
		if velocity.y > 0.0:
			$AnimationPlayer.current_animation = "jump"
		else:
			$AnimationPlayer.current_animation = "fall"
