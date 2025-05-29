local vector_main_utils = {} :: VectorImpl & {
    create: (x: number, y: number, z: number) -> Vector,
    zero: Vector,
    one: Vector,
}
vector_main_utils.__index = vector_main_utils

type VectorImpl = {
    __index: VectorImpl,
    add: (((vec1: Vector, vec2: Vector) -> Vector) & ((vec1: Vector, vec2: number) -> Vector)),
    sub: (((vec1: Vector, vec2: Vector) -> Vector) & ((vec1: Vector, vec2: number) -> Vector)),
    mul: (((vec1: Vector, vec2: Vector) -> Vector) & ((vec1: Vector, vec2: number) -> Vector)),
    div: (((vec1: Vector, vec2: Vector) -> Vector) & ((vec1: Vector, vec2: number) -> Vector)),
    dot: (vec1: Vector, vec2: Vector) -> number,
    
    getMagnitude: (vec: Vector) -> number,
    getUnit: (vec: Vector) -> Vector,

    toVector3: (vec: Vector) -> Vector3,
    fromVector3: (vector3: Vector3) -> Vector,
    getXYZ: (vec: Vector) -> (number, number, number),
    
    syncSourceEngine: (vec: Vector) -> Vector,
}

export type Vector = typeof(setmetatable({} :: {
    x: number,
    y: number,
    z: number
}, {} :: VectorImpl))

function vector_main_utils.create(x, y, z)
    return setmetatable({
        x = x,
        y = y,
        z = z,
    }, vector_main_utils)
end

function vector_main_utils.add(vec1, vec2: any)
    if typeof(vec2) == 'number' then
        return vector_main_utils.create(
            vec1.x + vec2,
            vec1.y + vec2,
            vec1.z + vec2
        )
    end

    return vector_main_utils.create(
        vec1.x + vec2.x,
        vec1.y + vec2.y,
        vec1.z + vec2.z
    )
end

function vector_main_utils.sub(vec1, vec2: any)
    if typeof(vec2) == 'number' then
        return vector_main_utils.create(
            vec1.x - vec2,
            vec1.y - vec2,
            vec1.z - vec2
        )
    end

    return vector_main_utils.create(
        vec1.x - vec2.x,
        vec1.y - vec2.y,
        vec1.z - vec2.z
    )
end

function vector_main_utils.mul(vec1, vec2: any)
    if typeof(vec2) == 'number' then
        return vector_main_utils.create(
            vec1.x * vec2,
            vec1.y * vec2,
            vec1.z * vec2
        )
    end

    return vector_main_utils.create(
        vec1.x * vec2.x,
        vec1.y * vec2.y,
        vec1.z * vec2.z
    )
end

function vector_main_utils.div(vec1, vec2: any)
    if typeof(vec2) == 'number' then
        return vector_main_utils.create(
            vec1.x / vec2,
            vec1.y / vec2,
            vec1.z / vec2
        )
    end

    return vector_main_utils.create(
        vec1.x / vec2.x,
        vec1.y / vec2.y,
        vec1.z / vec2.z
    )
end

function vector_main_utils.dot(vec1, vec2)
    return vec1.x * vec2.x + vec1.y * vec2.y + vec1.z * vec2.z
end

function vector_main_utils.syncSourceEngine(vec)
    return vec:mul(0.0254)
end

function vector_main_utils.toVector3(vec)
    return Vector3.new(vec.x, vec.y, vec.z)
end

function vector_main_utils.fromVector3(vector3)
    return vector_main_utils.create(vector3.X, vector3.Y, vector3.Z)
end

function vector_main_utils.getXYZ(vec)
    return vec.x, vec.y, vec.z
end

function vector_main_utils.getMagnitude(vec)
    return (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
end

function vector_main_utils.getUnit(vec)
    local magnitude = vec:getMagnitude()
    
    if magnitude == 0 then
        return vector_main_utils.zero
    end

    return vec:div(magnitude)
end

vector_main_utils.zero = vector_main_utils.create(0, 0, 0)
vector_main_utils.one = vector_main_utils.create(1, 1, 1)

return vector_main_utils
