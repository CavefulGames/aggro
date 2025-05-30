local vector_main_utils = {}

function vector_main_utils.setX(vec: Vector3, x: number): Vector3
    return Vector3.new(x, vec.Y, vec.Z)
end

function vector_main_utils.setY(vec: Vector3, y: number): Vector3
    return Vector3.new(vec.X, y, vec.Z)
end

function vector_main_utils.setZ(vec: Vector3, z: number): Vector3
    return Vector3.new(vec.X, vec.Y, z)
end

function vector_main_utils.getXYZ(vec: Vector3): (number, number, number)
    return vec.X, vec.Y, vec.Z
end

return vector_main_utils