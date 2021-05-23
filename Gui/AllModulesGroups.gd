extends Resource


const ALL_MODULES_GROUPS = [
	{
		'groupName': "Group 1",
		'elements': [
			{
				'name': "Pusty moduł",
				'moduleId' : "empty_module",
				'frameId':11,
				'tooltip' : "To jest pusty moduł",
				'cost': 10,
				'state':true
			},
			{
				'name': "Moduł Dpad",
				'moduleId' : "dpad_module",
				'frameId':4,
				'tooltip' : "To jest moduł ruchu w czterech kierunkach",
				'cost': 10,
				'state':true
			},
			{
				'name': "Dioda", 
				'moduleId' : "diode_module",
				'frameId':10,
				'tooltip' : "To jest dioda",
				'cost': 10,
				'state':true
			},
			{
				'name': "Drill",
				'moduleId': "drill",
				'frameId':14,
				'tooltip': "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer volutpat eros a aliquet lobortis. Mauris viverra mauris urna, vitae rhoncus elit fermentum id.",
				'cost': 10,
				'state':true
			},
			{
				'name': "Turret", 
				'moduleId' : "turret_module",
				'frameId':18,
				'tooltip': "To jest wieżyczka",
				'cost': 15,
				'state':true
			},
			{
				'name': "Pylon", 
				'moduleId' : "pylon_module",
				'frameId':43,
				'tooltip': "To jest pylon zwiększający zasięg pracy maszyny",
				'cost': 30,
				'state':true
			},
			{
				'name': "Generator", 
				'moduleId' : "generator_module",
				'frameId':33,
				'tooltip': "To jest generator, po jego zniszczeniu przegrasz grę",
				'cost': 0,
				'state':true
			},
			{
				'name': "Turret", 
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Tank", 
				'moduleId' : "tank",
				'frameId':null,
				'state':false
			}
		]
	},
	{
		'groupName': "Group 2",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			}
		]
	},
	{
		'groupName': "Group 3",
		'elements': [
			{
				'name': "Tank",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Turret",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			},
			{
				'name': "Drill",
				'moduleId' : "turret",
				'frameId':null,
				'state':false
			}
		]
	}
]
