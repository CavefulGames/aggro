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

function vector_main_utils.vectorSing(vec: Vector3): Vector3
    local singVector = Vector3.zero

    if vec.X > 0 then
        singVector += Vector3.new(1, 0, 0)
    elseif vec.X < 0 then
        singVector -= Vector3.new(1, 0, 0)
    end

    if vec.Y > 0 then
        singVector += Vector3.new(0, 1, 0)
    elseif vec.Y < 0 then
        singVector -= Vector3.new(0, 1, 0)
    end

    if vec.Z > 0 then
        singVector += Vector3.new(0, 0, 1)
    elseif vec.Z < 0 then
        singVector -= Vector3.new(0, 0, 1)
    end

    return singVector
end

return vector_main_utils