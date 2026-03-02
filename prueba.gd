extends Node2D  # o Control, según tu nodo raíz

# Señal personalizada
signal contador_aumentado

@onready var label = $Label

var contador = 0

func _ready():
	contador_aumentado.connect(_on_contador_aumentado)

	label.text = str(contador)
	# Conectar botón si existe
	if has_node("Button"):
		$Button.pressed.connect(aumentar_contador)

func aumentar_contador():
	contador += 1
	label.text = str(contador)
	# Emitir la señal
	contador_aumentado.emit()

# Ejemplo de conexión a la señal (opcional)
func _on_contador_aumentado():
	print("El contador aumentó a: ", contador)
