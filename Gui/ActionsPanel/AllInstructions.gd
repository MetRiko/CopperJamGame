extends Resource

const ALL_INSTRUCTIONS = {
	'nop': {
		'frameId': 5,
		'name': 'Pusta instrukcja (NOP)'
	},
	'missing_instruction': {
		'frameId': 29,
		'name': 'Nieznana instrukcji'
	},
	'node_start': {
		'frameId': 3,
		'name': 'START'
	},
	'node_end': {
		'frameId': 4,
		'name': 'KONIEC (wróć na START)'
	},
	'move_right': {
		'frameId': 8,
		'name': 'Ruch w prawo'
	},
	'move_left': {
		'frameId': 10,
		'name': 'Ruch w lewo'
	},
	'move_up': {
		'frameId': 7,
		'name': 'Ruch w górę'
	},
	'move_down': {
		'frameId': 9,
		'name': 'Ruch w dół'
	},	
	'turn_on_diode': {
		'frameId': 25,
		'name': 'Włącz diodę'
	},
	'turn_off_diode': {
		'frameId': 24,
		'name': 'Wyłącz diodę'
	},
	'is_diode_on': {
		'frameId': 27,
		'name': 'Czy dioda jest włączona?'
	},
	'is_diode_off': {
		'frameId': 26,
		'name': 'Czy dioda jest wyłączona?'
	},
	'turn_on_drill': {
		'frameId': 20,
		'name': 'Włącz wiertło'
	},
	'turn_off_drill': {
		'frameId': 21,
		'name': 'Wyłącz wiertło'
	},
	'turn_on_turret': {
		'frameId': 14,
		'name': 'Włącz działko'
	},
	'turn_off_turret': {
		'frameId': 15,
		'name': 'Wyłącz działko'
	},
	'turn_on_tesla': {
		'frameId': 18,
		'name': 'Włącz teslę'
	},
	'turn_off_tesla': {
		'frameId': 19,
		'name': 'Wyłącz teslę'
	}
}
