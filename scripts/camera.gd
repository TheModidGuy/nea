extends Camera2D

# camera controller
@export var moveSpeed: float = 200.0
@export var moveMultiplier: float = 2.0
@export var acceleration: float = 5.0
@export var zoomSpeed: float = 0.25
@export var zoomMin: float = 0.5
@export var zoomMax: float = 5.0

var currentSpeed = 0.0

func _process(delta: float) -> void:
	# spriting check
	var targetSpeed = moveSpeed
	if Input.is_action_pressed("sprint"):
		targetSpeed *= moveMultiplier

	currentSpeed = lerp(currentSpeed, targetSpeed, delta * acceleration)

	var input_vector = Vector2.ZERO
	
	# movement handling
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		position += input_vector * currentSpeed * delta
		
# zoom
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoomSpeed, zoomSpeed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoomSpeed, zoomSpeed)

		# Clamp zoom
		zoom.x = clamp(zoom.x, zoomMin, zoomMax)
		zoom.y = clamp(zoom.y, zoomMin, zoomMax)
