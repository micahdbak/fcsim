extends CharacterBody3D

var movement_speed: float = 2.0  # Slightly faster for better responsiveness
var movement_target_position: Vector3 = Vector3(-3.0, 0.0, 2.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var player: Node3D  # Drag the player node into this export field

func _ready():
	navigation_agent.path_desired_distance = 0.8
	navigation_agent.target_desired_distance = 0.8
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame  # Wait for navigation sync

	if player:
		set_movement_target(player.global_transform.origin)
	else:
		set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	if navigation_agent.target_position.distance_to(movement_target) > 0.5:
		navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	# Update the target only if the player moves significantly
	if player and player.global_transform.origin.distance_to(navigation_agent.target_position) > 0.5:
		set_movement_target(player.global_transform.origin)

	var next_path_position = navigation_agent.get_next_path_position()
	var direction = (next_path_position - global_position).normalized()

	# Move smoothly
	velocity = direction * movement_speed
	move_and_slide()

	# Collision detection & scene switch
	if navigation_agent.is_navigation_finished() and global_position.distance_to(player.global_position) < navigation_agent.target_desired_distance:
		call_deferred("switch_scene")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func switch_scene():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
