extends CharacterBody2D

const SPEED = 300.0
var can_move = true
var movement_enabled = true
var target_position = null
var sprite_width = 0
var sprite = null
var start_position = Vector2.ZERO
var move_direction = Vector2.ZERO
var initial_rotation = 0.0
var falling = false
var pending_sprite_change = null
var pending_tileset_change = null
var pending_disable_movement = false
var selected = false

@export var player_texture: Texture2D:
	set(value):
		player_texture = value
		if has_node("Sprite2D"): $Sprite2D.texture = value

func _ready():
	if player_texture: $Sprite2D.texture = player_texture
	collision_layer = 3 if player_texture.resource_path.ends_with("grey.png") else 2
	collision_mask = 3 if player_texture.resource_path.ends_with("grey.png") else 1
	add_to_group("players")
	sprite = $Sprite2D
	sprite_width = sprite.texture.get_width() * sprite.scale.x
	var timer = Timer.new()
	timer.wait_time = 0.2
	timer.connect("timeout", func(): if not target_position and not has_floor_below() and movement_enabled: fall_down())
	add_child(timer)
	timer.start()

func change_texture(new_texture):
	player_texture = load(new_texture)
	$Sprite2D.texture = load(new_texture)
	collision_layer = 3 if player_texture.resource_path.ends_with("grey.png") else 2
	collision_mask = 3 if player_texture.resource_path.ends_with("grey.png") else 1

func is_path_clear(direction: Vector2) -> bool:
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + (direction * sprite_width)
	query.exclude = [self]
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if result.is_empty():
		return true
	
	var collider = result["collider"]
	if collider.is_in_group("players"):
		var i_am_grey = player_texture and player_texture.resource_path.ends_with("grey.png")
		var collider_is_grey = collider.player_texture and collider.player_texture.resource_path.ends_with("grey.png")
		if i_am_grey or (not i_am_grey and collider_is_grey):
			return false
		if not i_am_grey and not collider_is_grey:
			return true
		return true
	
	return false

func has_floor_below() -> bool:
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = global_position + Vector2(0, sprite_width)
	query.exclude = [self]
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	
	if not result.is_empty():
		var collider = result["collider"]
		if collider.is_in_group("players"):
			if player_texture and player_texture.resource_path.ends_with("grey.png"):
				return true
			if collider.player_texture and collider.player_texture.resource_path.ends_with("grey.png"):
				return true
			return false
		return not collider.is_in_group("portals")
	return false

func fall_down():
	if target_position: return
	falling = true
	can_move = false
	var down_direction = Vector2(0, 1)
	if is_path_clear(down_direction):
		start_position = global_position
		move_direction = down_direction
		target_position = Vector2(global_position.x, global_position.y + sprite_width)
		initial_rotation = sprite.rotation
	else:
		falling = false
		can_move = true

func is_occupied_portal_at_position(pos: Vector2) -> bool:
	for portal in get_tree().get_nodes_in_group("portals"):
		if portal.global_position.distance_to(pos) < 5 and portal.has_player_inside:
			return true
	return false

func is_in_portal() -> bool:
	for portal in get_tree().get_nodes_in_group("portals"):
		if portal.overlapping_players.has(self):
			return true
	return false

func is_in_any_portal() -> bool:
	for portal in get_tree().get_nodes_in_group("portals"):
		var area = portal.get_node_or_null("CollisionArea")
		if area and area.overlaps_body(self):
			return true
	return false

func _physics_process(_delta):
	if target_position:
		velocity = (target_position - global_position).normalized() * SPEED
		
		if not falling:
			var progress = global_position.distance_to(start_position) / start_position.distance_to(target_position)
			var rotation_direction = 1.0 if move_direction.x >= 0 else -1.0
			sprite.rotation = initial_rotation + (progress * PI / 2 * rotation_direction)
		
		if global_position.distance_to(target_position) < 5:
			velocity = Vector2.ZERO
			global_position = target_position
			target_position = null
			process_pending_actions()
			
			if not falling:
				var root = get_tree().get_root()
				var moves_counter = root.find_child("MovesCounter", true, false)
				if moves_counter and moves_counter.has_method("increment"):
					moves_counter.increment()
				
				var audio_manager = get_node_or_null("/root/AudioManager")
				if audio_manager and audio_manager.has_method("play_move_sound"):
					audio_manager.play_move_sound()
			
			if falling:
				falling = false
				can_move = not call_deferred("fall_down") and has_floor_below()
			else:
				can_move = true
				sprite.rotation = fmod(initial_rotation + (PI / 2 * (1 if move_direction.x >= 0 else -1)), 2 * PI)
				if sprite.rotation < 0: sprite.rotation += 2 * PI
	elif not movement_enabled:
		velocity = Vector2.ZERO
	elif not has_floor_below():
		call_deferred("fall_down")
	elif can_move and movement_enabled and selected:
		var direction = Vector2.ZERO
		if Input.is_action_just_pressed("ui_right"): direction.x = 1
		elif Input.is_action_just_pressed("ui_left"): direction.x = -1
		if player_texture and player_texture.resource_path.ends_with("grey.png"):
			var query = PhysicsRayQueryParameters2D.new()
			query.from = global_position
			query.to = global_position + Vector2(0, sprite_width)
			query.exclude = [self]
			# var result = get_world_2d().direct_space_state.intersect_ray(query)

		if direction != Vector2.ZERO and is_path_clear(direction):
			var potential_position = global_position + (direction * sprite_width)
			if is_occupied_portal_at_position(potential_position):
				return
				
			start_position = global_position
			move_direction = direction
			target_position = potential_position
			can_move = false
			initial_rotation = sprite.rotation
			check_portal_status()
	
	move_and_slide()

func process_pending_actions():
	if pending_sprite_change:
		change_sprite_texture(pending_sprite_change)
		pending_sprite_change = null
	elif pending_tileset_change:
		change_to_tileset_sprite(pending_tileset_change)
		pending_tileset_change = null
	if pending_disable_movement:
		movement_enabled = false
		pending_disable_movement = false

func check_portal_status():
	for portal in get_tree().get_nodes_in_group("portals"):
		if portal.has_method("is_player_inside") and portal.is_player_inside() and portal.overlapping_players.has(self):
			return true
	return false

func change_sprite_texture(new_texture_path):
	var new_texture = load(new_texture_path)
	if new_texture:
		sprite.texture = new_texture
		reset_rotation()

func queue_sprite_change(texture_path):
	if target_position: pending_sprite_change = texture_path
	else: change_sprite_texture(texture_path)

func change_to_tileset_sprite(_tilemap):
	var tileset_texture = preload("res://images/map-tilemap.png")
	if tileset_texture:
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = tileset_texture
		atlas_texture.region = Rect2(0, 0, 32, 32)
		sprite.texture = atlas_texture
		sprite.scale = Vector2(1, 1)
		reset_rotation()

func queue_tileset_sprite_change(tilemap):
	if target_position: pending_tileset_change = tilemap
	else: change_to_tileset_sprite(tilemap)

func reset_rotation():
	sprite.rotation = 0
	initial_rotation = 0

func set_movement_enabled(enabled):
	if enabled:
		movement_enabled = true
		pending_disable_movement = false
	else:
		if target_position: pending_disable_movement = true
		else:
			movement_enabled = false
			velocity = Vector2.ZERO

func set_visibility(visible_state: bool):
	sprite.visible = visible_state
