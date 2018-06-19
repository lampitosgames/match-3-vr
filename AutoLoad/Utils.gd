extends Node

static func vector_max(vecArray):
	#Store the zero vector as the initial return value
	var currentMax = Vector3(0, 0, 0)
	#Loop through the array of vectors
	for vec in vecArray:
		#If this vector is longer than the current maximum found
		if (vec.length_squared() > currentMax.length_squared()):
			#Replace current max with this vector
			currentMax = vec
	#Return found maximum
	return currentMax