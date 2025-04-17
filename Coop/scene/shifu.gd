extends Sprite2D

const TOP = -435
const BOT = -400 #PLUS GRAND QUE TOT 

var is_bot = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.y = BOT
	is_bot = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)
	queue_redraw()
	
func move(arg: float) -> void:
	while(is_bot):
		position.y -= 1*arg
		if(position.y <= TOP):
			is_bot = false
			
			
	while(!is_bot):
		print(position.y)
		position.y += 1*arg
		if(position.y >= BOT):
			is_bot = true
			print("Monte")
