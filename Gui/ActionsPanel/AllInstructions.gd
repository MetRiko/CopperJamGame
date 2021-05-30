extends Resource

const ALL_INSTRUCTIONS = {
	'nop': {
		'frameId': 5,
		'name': 'Empty instruction'
	},
	'missing_instruction': {
		'frameId': 29,
		'name': 'Missing instruction'
	},
	'node_start': {
		'frameId': 3,
		'name': 'Node start'
	},
	'node_end': {
		'frameId': 4,
		'name': 'Node end'
	},
	'move_right': {
		'frameId': 8,
		'name': 'Move right'
	},
	'move_left': {
		'frameId': 10,
		'name': 'Move left'
	},
	'move_up': {
		'frameId': 7,
		'name': 'Move up'
	},
	'move_down': {
		'frameId': 9,
		'name': 'Move down'
	},	
	'turn_on_diode': {
		'frameId': 25,
		'name': 'turn_on_diode'
	},
	'turn_off_diode': {
		'frameId': 24,
		'name': 'turn_off_diode'
	},
	'is_diode_on': {
		'frameId': 27,
		'name': 'is_diode_on'
	},
	'is_diode_off': {
		'frameId': 26,
		'name': 'is_diode_off'
	},
	'turn_on_drill': {
		'frameId': 20,
		'name': 'Turn on drill'
	},
	'turn_off_drill': {
		'frameId': 21,
		'name': 'Turn off drill'
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
