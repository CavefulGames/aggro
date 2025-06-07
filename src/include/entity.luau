export type Entity = {
    angularVelocity: Vector3,
    velocity: Vector3,
    
    cframe: CFrame,
    position: Vector3,
    angle: CFrame,

    elasticity: number,

    flags: {
        fCollideWorld: boolean?,
        fGravity: boolean?,
    },
    
    collisionSize: Vector3,
    isColliding: boolean,
    normal: Vector3,
}

return function(): Entity
    return {
        angularVelocity = Vector3.zero,
        velocity = Vector3.zero,

        cframe = CFrame.new(0, 0, 0),
        position = Vector3.zero,
        angle = CFrame.Angles(0, 0, 0),

        elasticity = 0.3,

        flags = {},

        collisionSize = Vector3.zero,
        isColliding = false,
        normal = Vector3.zero,
    }
end