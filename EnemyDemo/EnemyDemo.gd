extends KinematicBody2D

# Переменная для вектора перемещения
var motion = Vector2.ZERO

var GRAVITY = 750

func _physics_process(delta):
	motion.y += GRAVITY * delta * 4
	motion.x += 0.1
	#motion.x = get_node()
	#get_node("\\Player\\Player.tscn")
	
	# Похоже, придётся делать кого-то дочерним узлом
	
		# Запуск передвижения игрока	
	motion = move_and_slide(motion, Vector2.UP)
	
