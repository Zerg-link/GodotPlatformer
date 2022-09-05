extends KinematicBody2D


# Константы
onready var animatedSprite = $AnimatedSprite
const FRICTION = 0.75
const JUMP_FORCE = 750
const AIR_RESISTANCE = 0.03
const GameOverScreen = preload("res://Player/GameOverScreen.tscn")

# Переменная для вектора перемещения
var motion = Vector2.ZERO

# Просто глобальные переменные
var wall_jump = false
var block_input_x = false
var MAX_SPEED = 500
var stop_in_air = false
var GRAVITY = 750
var ACCELERATION = 1000
var way_jump = "none"
var jump_way_prev = "none"
var still_exist = true


# Функция по определению: "С какой стороны стена?"
func _get_which_wall_collided():
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		if collision.normal.x > 0:
			return "left"
		elif collision.normal.x < 0:
			return "right"
	return "none"
	
# Функция ввода клавиш
# Именно используя её мы будем управлять персонажем
#func _input(event):
#	if event is InputEventKey:
#		print("Key pressed " + char(event.scancode))
#		#if char(event.scancode) == 'X':
#		#	MAX_SPEED = 400
#		if event.echo == true:
#			print("Key was held down")
#		else:
#			print("First press")
			
# Обработка специальных клавиш
func _input(event):
	# Ввели с клавиатуры
	
	if event is InputEventKey:
		# Спринт
		if char(event.scancode) == 'X':
			if event.echo == true:
				MAX_SPEED = 750
			else:
				MAX_SPEED = 500



# Системная функция движка. Она нужна, чтобы привязать к персонажу физку.
# В нашем случае - это физика перемещния и сила гравитации
func _physics_process(delta):
	
	# Следующая строчка отвечает за управление по оси X.
	# Метод Input помогает нам считывать те самые кнопки для управления
	var x_input
	if !block_input_x:
		x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
		
	else:
		x_input = 0
	
	if x_input == 0:
		animatedSprite.animation = "Idle"
	if x_input < 0:
		animatedSprite.animation = "Walking"
		animatedSprite.flip_h = false
	if x_input > 0:
		animatedSprite.animation = "Walking"
		animatedSprite.flip_h = true
	
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		#print("I collided with ", collision.collider.name) # Здесь можно настроить всё так, что при касании с 
		# TileMapDemoDangerZone игрок погибал - уничтожался персонаж
		if collision.collider.name == "TileMapDemoDangerZone":
			# Игрок проиграл. 
			# Проигрывается анимация смерти персонажа
			yield(get_tree().create_timer(2.00), "timeout")
			# Переход на экран проигрыша
			emit_signal("player_died")
			var game_over = GameOverScreen.instance()
			add_child(game_over)
			#get_tree().paused = true
			
			
			still_exist = false
			#queue_free()
	 
	
	# Строчка, проверяющая, нажали ли мы на кнопку
	if x_input != 0:
		# Прибавляем к коорденате игрока произведение направления по координате на ускорение и delta
		motion.x += x_input * ACCELERATION * delta
		#  clamp "сжимает" значение переменной (?). Сделано это для оптимизации и плавности движения.
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		
	# Гравитация. Мы прибавляем к motion.y силу тяжести, умноженную на delta	
	motion.y += GRAVITY * delta * 4
	
	
	# Проверка на нахождении на полу. 
	if self.is_on_floor():
		way_jump = "none"
		jump_way_prev = "none"
		block_input_x = false
		if x_input == 0:
			# lerp - это функция плавного перехода от одного значения к другому
			motion.x = lerp(motion.x, 0, FRICTION)
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE 
		

	else:
		# Не на земле
		
		# Ускорение вниз
		if Input.is_action_just_pressed("ui_down"):
			
			motion.y = 0
			motion.x = 0
			block_input_x = true
			GRAVITY = 50
			#yield(get_tree().create_timer(0.15), "timeout")
			GRAVITY = 750
			block_input_x = false
			motion.y += GRAVITY * 150 * delta
			motion.x = 0
			
		if _get_which_wall_collided() != "none": 
			# Прицепиться к стене
			#print(way_jump)
			
			if way_jump != _get_which_wall_collided(): #Заставит прыгать без остановк
				wall_jump = true
				way_jump = _get_which_wall_collided()
			

				
		if Input.is_action_just_pressed("ui_up"):

			if jump_way_prev == way_jump:
				#print("DONT JUMP")
				wall_jump = false
					
			if wall_jump:
				#print(way_jump)
				jump_way_prev = way_jump
				block_input_x = true
				motion.y = -JUMP_FORCE
				if way_jump == "left":
					motion.x +=JUMP_FORCE
				if way_jump == "right":
					motion.x -=JUMP_FORCE
			
			
			
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)
	
	# Запуск передвижения игрока	
	motion = move_and_slide(motion, Vector2.UP)

	
