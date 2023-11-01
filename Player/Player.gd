extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var attacking = false

func die():
	queue_free()
	
func attack():
	if $Attack.is_colliding():
		var target = $Attack.get_collider()
		if target.has_method("damage"):
			target.damage()

func set_animation(a):
	if $Sprite.animation and not attacking:
		if a == "Attack": 
			$Sprite.offset = Vector2(2,8)
			attacking = true
			$Attacking.start()
		else: $Sprite.offset = Vector2.ZERO
		$Sprite.play(a)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		set_animation("Fall")
	elif abs(velocity.x)>0 and $Sprite.animation !="Walk":
		set_animation("Walk")
	elif velocity.x==0:
		set_animation("Idle")
		
	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		set_animation("Jump")
		
	if Input.is_action_just_pressed("Attack") and is_on_floor():
		set_animation("Attack")
		attack()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if direction<0:
			$Sprite.flip_h=true
	else:
		$Sprite.flip_h=false;
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()


func _on_attacking_timeout():
	attacking = false
