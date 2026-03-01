extends RigidBody3D

@export var dash_speed: float = 30.0
@export var roll_acceleration: float = 20.0

func enable():
	set_process(true)
	set_physics_process(true)
	freeze = false
	$Mesh.visible = true
	$Collider.disabled = false

func disable():
	set_process(false)
	set_physics_process(false)
	freeze = true
	$Mesh.visible = false
	$Collider.disabled = true
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _process(_delta: float) -> void:
	$RotationLock.global_rotation = Vector3.ZERO

func _physics_process(_delta: float) -> void:
	
	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_global := Vector3(-move.y, 0.0, move.x) * get_parent_node_3d().global_basis
	
	apply_central_force(move_global * roll_acceleration)
