extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const HOVER_HEIGHT = 2.0
const HOVER_FORCE = 1.0
const HOVER_DAMPING = 0.3
const ACCELERATION = 12.0
const DECELERATION = 24.0

@onready var ground_ray: RayCast3D = $GroundRay

func _physics_process(delta: float) -> void:
	# Ground detection
	var is_grounded = ground_ray.is_colliding()
	
	# Hover logic
	if is_grounded:
		var collision_point = ground_ray.get_collision_point()
		var desired_y = collision_point.y + HOVER_HEIGHT
		var error = desired_y - global_position.y
		
		# Apply proportional force and damping
		velocity.y += error * HOVER_FORCE * delta
		velocity.y -= velocity.y * HOVER_DAMPING * delta
	else:
		# Apply gravity when airborne
		velocity += get_gravity() * delta

	# Jump handling
	if Input.is_action_just_pressed("ui_accept") and is_grounded:
		velocity.y = JUMP_VELOCITY

	# Smooth movement input
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Calculate target horizontal velocity
	var target_velocity = direction * SPEED
	
	# Smoothly interpolate velocity
	if direction != Vector3.ZERO:
		velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0, DECELERATION * delta)

	move_and_slide()
