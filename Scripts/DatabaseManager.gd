extends Node

var db : SQLite
const DB_PATH := "user://game_data.db"

func _ready():
	db = SQLite.new()
	db.path = DB_PATH
	db.open_db()
	crear_tablas()

# --- TABLAS ---
func crear_tablas():
	var progreso := """
	CREATE TABLE IF NOT EXISTS progreso (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		nivel INTEGER,
		vidas INTEGER
	);
	"""
	db.query(progreso)

# --- PROGRESO ---
func guardar_progreso(nivel:int, vidas:int):
	db.query("DELETE FROM progreso;")
	db.query_with_bindings(
		"INSERT INTO progreso (nivel, vidas) VALUES (?, ?);",
		[nivel, vidas]
	)

func cargar_progreso() -> Dictionary:
	db.query("SELECT * FROM progreso LIMIT 1;")
	if db.query_result.is_empty():
		return {}
	var fila = db.query_result[0]
	return {
		"nivel": fila["nivel"],
		"vidas": fila["vidas"]
	}
