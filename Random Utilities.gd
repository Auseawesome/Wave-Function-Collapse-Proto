class_name RandomUtilities

func _init():
	randomize()

func random_choice(choices: Array,weights: Array=[]):
	var total_weight: float
	if weights == []:
		for i in choices.size():
			weights = weights + [1.0]
	for weight in weights:
		total_weight += weight
	var rand_position: float = randf() * total_weight
	var weight_progress: float
	for i in weights.size():
		weight_progress += weights[i]
		if weight_progress > rand_position:
			return choices[i]
	return "Error occurred in random_choice"
	
