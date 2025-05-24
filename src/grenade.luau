local physics = require('./include/physics')
local physics_main_utils = require('./include/physics_main_utils')

export type Grenade = physics.Entity & typeof(setmetatable({} :: {
    --// 충돌시 탄성계수
    elasticity: number,
}, {}))

local grenade = {}

function grenade.grenade(): Grenade
    local entitiy = physics.entity() :: Grenade

    entitiy.elasticity = 1
    
    return entitiy
end

function grenade.physics(self: Grenade)
    --// 탄성계수 clamp (0, 0.9)
    local totalElasticity = math.clamp(self.elasticity, 0, 0.9)

    --// velocity 를 반사됀 velocity 로 변경
    --// (반사됀 백터를 구함 (반사강도 = 2 = 완벽히 반사)) * 탄성계수 (totalElasticity)
    local velocity = physics_main_utils.clipVelocity(self.velocity, self.normal, 2) * totalElasticity
    
    --// velocity 의 스칼라를 구함 (속도의 제곱값 (Square))
    local speedSquare = velocity:Dot(velocity)

    --// 바닥충돌처리 (y 가 위쪽)
    if self.normal.Y > 0.7 then
        --// 충돌 각도가 0.7 을 넘는다면 (바닥이라면) velocity 적용
        self.velocity = velocity

        --// velocity 값이 30보다 작다면
        if speedSquare < (30 * 30) then
            --// 속도와 각도 초기화
            self.velocity = Vector3.zero
            self.angularVelocity = Vector3.zero

            
        end
    end

end

return grenade
