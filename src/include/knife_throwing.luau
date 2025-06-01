local physics = require('./physics')

export type Knife = physics.Entity & {
    r: number
}

local knife_throwing = {}

function knife_throwing.knife(): Knife
    local knife = physics.entity() :: Knife

    knife.r = 1

    return knife
end

function knife_throwing.frame(self: Knife, deltaTime: number)
    --// 회전역학

end

return knife_throwing
