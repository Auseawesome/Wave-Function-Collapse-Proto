class_name RandomUtilities

## A class containing a variety of functions for randomised actions using psuedo-random number generators

func _init():
	randomize()

## Picks a random choice out of a provided array using an optional weights array for weighted values
func random_choice(choices: Array,weights: Array=[]):
	var total_weight: float = 0.0
	if weights == []:
		for i in choices.size():
			weights = weights + [1.0]
	for weight in weights:
		total_weight += weight
	var rand_position: float = randf() * total_weight
	var weight_progress: float = 0.0
	for i in weights.size():
		weight_progress += weights[i]
		if weight_progress > rand_position:
			return choices[i]
	return "Error occurred in random_choice"
	
