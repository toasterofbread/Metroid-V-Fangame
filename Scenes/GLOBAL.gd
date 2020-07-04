extends Control

# Global variables:


const selectable_weapons = [ 
	["missile"],
	["super missile"],
]

const selectable_weapons_morph = [
	["power bomb"]
]

const amount_gained_per_tank = {
	"missile": 5,
	"super missile": 5,
	"power bomb": 5
}

var samusData = {
	
	"amounts": {
		"energy": 99,
		"missile": 50,
		"super missile": 5,
		"power bomb": 5
	},
	
	"upgrades": {
		"etank": 2,
		"missile": 10,
		"super missile": 1,
		"power bomb": 1,
		"bomb": 0,
		"morph ball": 1,
	}
	
}


# Global functions:

func saveFile(slot, data):
	pass

func loadFile(slot):
	pass
