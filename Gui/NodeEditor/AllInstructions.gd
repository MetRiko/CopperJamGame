extends Resource

const ALL_INSTRUCTIONS = {
	'nop': {
		'frameId': 2,
		'name': 'Empty instruction'
	},
	'missing_instruction': {
		'frameId': 16,
		'name': 'Missing instruction'
	},
	'node_start': {
		'frameId': 7,
		'name': 'Node start'
	},
	'node_end': {
		'frameId': 8,
		'name': 'Node end'
	},
	'move_right': {
		'frameId': 15,
		'name': 'Move right'
	},
	'move_left': {
		'frameId': 17,
		'name': 'Move left'
	},
	'move_up': {
		'frameId': 14,
		'name': 'Move up'
	},
	'move_down': {
		'frameId': 16,
		'name': 'Move down'
	},	
	'turn_on_diode': {
		'frameId': 43,
		'name': 'turn_on_diode'
	},
	'turn_off_diode': {
		'frameId': 42,
		'name': 'turn_off_diode'
	},
	'is_diode_on': {
		'frameId': 45,
		'name': 'is_diode_on',
		'condition': true
	},
	'is_diode_off': {
		'frameId': 44,
		'name': 'is_diode_off',
		'condition': true
	}
}
