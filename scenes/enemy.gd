extends CharacterBody3D

var movement_speed: float = 1.0
var movement_target_position: Vector3 = Vector3(-3.0,0.0,2.0)

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var player: Node3D  # Drag the player node into this export field

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.2
	navigation_agent.target_desired_distance = 0.2

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	if player:
		set_movement_target(player.global_transform.origin)
	else:
		set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if player:
		set_movement_target(player.global_transform.origin)

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()
	
	# Add code for player collision 
	if navigation_agent.is_navigation_finished() and global_position.distance_to(player.global_position) < navigation_agent.target_desired_distance:
		call_deferred("switch_scene")

func switch_scene():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
