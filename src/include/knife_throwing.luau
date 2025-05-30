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
    --// 회전 운동
    --// 각변위 (세타 θ), 각속도 (오메가 ω), 각가속도 (알파 a)
    --// θ = S / r
    --// v = r * ω

    --// d (칼이 한바퀴 회전할때마다 움직이는 거리)
    --// d = Vf * 2pi / ω
    --// Vf = Vc = r * ω
    --// d = (r * ω) * 2pi / ω
    --// d = (r * 2pi)

    --// 이까지가 회전공식

    local d = self.r * 2 * math.pi

    print(d)
end

return knife_throwing
