local physics = require('./physics')

export type Knife = physics.Entity & {

}

local knife_throwing = {}

function knife_throwing.knife(): Knife
    local knife = physics.entity() :: Knife

    return knife
end

function knife_throwing.frame(self: Knife, deltaTime: number)
    --// 회전역학 또는 칼에 위치에 대한 개념이 들어갈 예정
    
end

return knife_throwing
