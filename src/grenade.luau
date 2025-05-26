local physics = require('./include/physics')
local physics_main_utils = require('./include/physics_main_utils')
local math_main_utils = require('./include/math_main_utils')

export type Grenade = physics.Entity & typeof(setmetatable({} :: {
    --// 충돌시 탄성계수
    elasticity: number,
}, {}))

local grenade = {}

function grenade.grenade(): Grenade
    local entitiy = physics.entity() :: Grenade

    entitiy.elasticity = 0.5
    
    return entitiy
end

function grenade.frame(self: Grenade, deltaTime: number)
    --// 일반물리 적용하기
    physics.frame(self, deltaTime)

    --// 충돌했을때만 실행하게
    if not self.isCollision then
		return
	end

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
            --// 속도와 초기화
            self.velocity = Vector3.zero
            
            --// normal 각도 구하기
            local angle = math_main_utils.vectorAngle(self.normal)

            --// angle 의 y 를 랜덤으로 (yaw 값 (지면기준))
            angle = Vector3.new(angle.X, math.random(1, 360), 0)

            --// 반사각도로 각속도 주기
            self.angularVelocity = angle
        end

    --// 바닥에 충돌한게 아니라면
    else
        --// 충돌 각도가 0.7 이하이고
        --// velocity 값이 30보다 작다면
        if speedSquare < (30 * 30) then
            --// 각속도, 속도 초기화
            self.velocity = Vector3.zero
            self.angularVelocity = Vector3.zero
            
        --// velocity 값이 30 이상이라면
        else
            --// 수류탄 velocity 를 반사백터로 변경
            self.velocity = velocity
        end
    end
end

return grenade
