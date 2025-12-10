extends Node3D

@onready var tween := create_tween()

var start_pos
var end_pos := Vector3(0, 0, -10) 

func _ready():
	start_pos = global_transform.origin
	mover_plataforma()
	
func mover_plataforma():
	tween.tween_property(self, "global_transform:origin", start_pos + end_pos, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_transform:origin", start_pos, 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()

func _on_body_entered(body):
	if body.is_in_group("player"):  # O cualquier forma de identificarlo
		body.set_parent(self)  # Se convierte en hijo de la plataforma

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.get_parent().remove_child(body)
		get_tree().get_root().add_child(body)  # Lo regresamos a la escena principal
