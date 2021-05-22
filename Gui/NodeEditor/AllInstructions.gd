extends Resource

const ALL_INSTRUCTIONS = {
	'nop': {
		'frameId': 0,
		'name': 'Empty instruction'
	},
	'node_start': {
		'frameId': 2,
		'name': 'Node start'
	},
	'node_end': {
		'frameId': 1,
		'name': 'Node end'
	},
	'move_right': {
		'frameId': 8,
		'name': 'Move right'
	},
	'move_left': {
		'frameId': 9,
		'name': 'Move left'
	},
	'move_up': {
		'frameId': 10,
		'name': 'Move up'
	},
	'move_down': {
		'frameId': 11,
		'name': 'Move down'
	},	
	'turn_on_diode': {
		'frameId': 12,
		'name': 'turn_on_diode'
	},
	'turn_off_diode': {
		'frameId': 13,
		'name': 'turn_off_diode'
	},
	'is_diode_on': {
		'frameId': 14,
		'name': 'is_diode_on'
	},
	'is_diode_off': {
		'frameId': 15,
		'name': 'is_diode_off'
	}
}
