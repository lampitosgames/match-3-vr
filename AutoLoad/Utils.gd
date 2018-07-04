extends Node

static func vector_max(_vecArray):
	#Store the zero vector as the initial return value
	var currentMax = Vector3(0, 0, 0)
	#Loop through the array of vectors
	for vec in _vecArray:
		#If this vector is longer than the current maximum found
		if (vec.length_squared() > currentMax.length_squared()):
			#Replace current max with this vector
			currentMax = vec
	#Return found maximum
	return currentMax

static func vector_clamp(_vec, _maxLength):
	#If the vector is shorter, do nothing
	if (_vec.length_squared() < _maxLength * _maxLength):
		return _vec
	#Else, normalize the vector and set it to the max length
	return _vec.normalized() * _maxLength

static func vector_proj(_vec, _onto):
	if (!_onto.is_normalized()):
		_onto = _onto.normalized()
	return _vec.dot(_onto) * _onto

static func vector_snap(_vec, _snapBy):
	return Vector3(stepify(_vec.x, _snapBy.x), stepify(_vec.y, _snapBy.y), stepify(_vec.z, _snapBy.z))