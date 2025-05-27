local physics = require('./physics')
local physics_main_utils = require('./physics_main_utils')
local math_main_utils = require('./math_main_utils')

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
        --// 레이케스트가 아무곳에도 닿지 않았을때 적용해줄 중력 (음수)
    local gravity = physics.gravity * -deltaTime

    --// flag 중에 느린 중력이 켜져있을때 적용시킬 중력
    local gravitySlow = gravity * 0.5

    --// 나중에 raycast 쓸때 사용할 origin
    local localOrigin = self.cframe.Position

    --// 충돌하지 않았음으로 변경
    self.isCollision = false

    --// v += a * dt
    self.velocity += self.acceleration * deltaTime 
    
    --// cframe 에 속도 더해주고 각도설정
    self.cframe = CFrame.new(localOrigin + self.velocity * deltaTime) * CFrame.Angles(self.cframe:ToEulerAnglesXYZ())

    --// 속도로 회전 제어
    if self.flags.fRotate then
        --// 엥귤러 벨로시티를 velocity * dt 로 변경 
        self.angularVelocity = self.velocity * deltaTime
    end

    --// 회전 적용 (라디안)
    local angularVelocity = self.angularVelocity * math.pi / 180
    self.cframe *= CFrame.Angles(angularVelocity.X, angularVelocity.Y, angularVelocity.Z)

    --// trace (레이가 이동한 거리, raycast result)
    local distance, result = physics.traceLine(localOrigin, self.cframe.Position)
    
    --// 만약 충돌하지 않았다면
    if not result then
        --// 기본 중력의 영향을 받는 상태라면
        if self.flags.fGravity then
            --// velocity 의 y 에 중력만 더해줌
            self.velocity = Vector3.new(self.velocity.X, self.velocity.Y + gravity, self.velocity.Z)
        --// 느린 중력의 영향을 받는 상태라면
        elseif self.flags.fSlowGravity then
            --// velocity 의 y 에 Slow 상태일때의 중력을 더해줌 (gravity * 0.5)
            self.velocity = Vector3.new(self.velocity.X, self.velocity.Y + gravitySlow, self.velocity.Z)
        end

        --// 리턴
        return
    end

    --// 충돌처리를 안한다면 리턴
    if not self.flags.fCollideWorld then
        return        
    end

    --// 다른곳에서도 trace 로 사용하여야 하기 때문에 따로 self 에 넣어줌
    self.normal = result.Normal

    --// distance 는 실제 이동거리 result.Distance 는 충돌지점과의 거리
    --// 만약 이 둘이 같을때 나누면 몫은 1, 즉 충돌하지 않았다는뜻 
    --// 충돌하지 않았기에 리턴
    if result.Distance / distance == 1 then
        return
    end

    --// 충돌중임을 나타냄
    -- self.isCollision = true

    -- --// 감쇠 계수 (기본값은 1)
    -- local dampingFactor = 1
    
    -- --// 중력의 영향을 받는다면
    if self.flags.fGravity or self.flags.fSlowGravity then
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
end

return grenade
