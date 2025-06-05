local world = require('./world')
local physics_main_utils = require('./physics_main_utils')
local vector_main_utils = require('./vector_main_utils')
local define = require('./define')

export type Entity = {
    angularVelocity: Vector3 , --// 회전 가속도 (deg)
    velocity: Vector3, --// 속도 (v)
    acceleration: Vector3, --// 가속도 (a)
    
    cframe: CFrame, --// Entitiy 의 CFrame
    position: Vector3, -- //위치
    angle: CFrame, --// 회전한 각도 (CFrame Angle) (rad)

    collisionSize: Vector3,

    --// 플레그들 (앞의 f 는 flag 라는 뜻)
    flags: {
        fCollideWorld: boolean?, --// World 충돌을 받는지
        fGravity: boolean?, --// 중력의 영향을 받는지
        fCollisionBounce: boolean?, --// 충돌반사를 사용하는지
        fNaverDie: boolean?, --// 안죽는지
        fCollisionSize: boolean?, --// entity 의 부피를 사용하는지
    },

    --// 레이케스트 법선백터
    normal: Vector3,

    --// 충돌여부
    isColliding: boolean,

    --// 프레임마다 렌더링될 파트
    render: Part?,

    --// 죽을시간 (ex os.clock() + 10 << base)
    die: number,

    --// 죽어있는지
    isDie: boolean,

    --// Events

    --// 충돌시 callback
    onCollide: (self: Entity) -> ()?,

    --// 죽었을때 callback
    onDie: (self: Entity) -> ()?,
}

local physics = {}

physics.world = table.clone(world)

physics.entitys = {} :: { [number]: Entity }
physics.max_entitys = define.max_entitys

function physics.entity(): Entity
    if #physics.entitys >= physics.max_entitys then
        return error('overflow the max entitys')
    end

    local entity = {
        angularVelocity = Vector3.zero,
        velocity = Vector3.zero,
        acceleration = Vector3.zero,

        cframe = CFrame.new(Vector3.zero),
        position = Vector3.zero,
        angle = CFrame.Angles(0, 0, 0),

        collisionSize = Vector3.zero,

        flags = {},

        normal = Vector3.zero,

        isColliding = false,

        die = os.clock() + 10,

        isDie = false,
    }

    physics.entitys[#physics.entitys + 1] = entity

    return entity
end

function physics.update(deltaTime: number)
    for i=1, #physics.entitys do
        local entity = physics.entitys[i]
        
        if not entity.flags.fNaverDie then
            if entity.die < os.clock() then
                table.remove(physics.entitys, i)
                entity.isDie = true

                if entity.onDie then
                    entity.onDie(entity)
                end
            end
        end

        physics.frame(entity, deltaTime)

        if not entity.render then
            continue
        end

        entity.render.CFrame = entity.cframe
    end
end

function physics.frame(self: Entity, deltaTime: number)
    --// gravity 를 적용한후 위치
    local currentPosition = physics.physicsPosition(self, deltaTime) + self.position
    
    --// 각속도 처리
    local currentAngle = physics.physicsAngular(self, deltaTime) * self.angle

    --// 충돌처리등..
    physics.physicsTrace(self, self.position, currentPosition)
    
    --// self 의 cframe 에 중력, 회전 적용
    self.cframe = CFrame.new(vector_main_utils.getXYZ(currentPosition)) * currentAngle
    self.position = currentPosition
    self.angle = currentAngle
end

function physics.physicsAngular(self: Entity, deltaTime: number)
    --// 회전 적용 (라디안)
    return CFrame.Angles(vector_main_utils.getXYZ(self.angularVelocity * deltaTime * math.pi / 180))
end

function physics.physicsPosition(self: Entity, deltaTime: number): Vector3
    --// if Entity is colliding then, return no move 
    if self.isColliding then
        return Vector3.zero
    end

    --// s = v * t
    local distance = self.velocity * deltaTime

    --// if not use gravity then, return distance
    if not self.flags.fGravity then
        return distance
    end

    --// a = v / t
    --// v = a * t
    local velocity = self.velocity

    --// apply gravity to velocity
    self.velocity = Vector3.new(
        velocity.X,
        velocity.Y - physics.world.gravity * deltaTime,
        velocity.Z
    )

    --// average velocity = (v0 + v1) / 2
    --// s(distance) = v(velocity) * t(deltaTime)
    distance = Vector3.new(
        velocity.X,
        (velocity.Y + self.velocity.Y) / 2,
        velocity.Z
    ) * deltaTime

    return distance
end

--// v0: 이전위치 v1: 현제위치
function physics.physicsTrace(self: Entity, v0: Vector3, v1: Vector3)
    --// 충돌할때 entity 크기를 구함
    local collisionSize = Vector3.zero

    if self.flags.fCollisionSize then
        --// 부피 / 2
        collisionSize = self.collisionSize / 2
    end

    --// velocity 의 부호들을 구함
    local velocitySingVector = vector_main_utils.vectorSing(self.velocity)

    --// trace (레이가 이동한 거리 (스칼라), raycast result) 
    --// 부피계산은 레이를 velocity 의 방향에 부피 / 2 를 곱해줌
    local distance, result = physics_main_utils.traceLine(v0, v1 + (velocitySingVector * collisionSize))

    --// self 가 충돌하지 않음 으로 변경
    self.isColliding = false

    --// result 가 없으면 반환
    if not result then
        return
    end

    --// distance 는 실제 이동거리 result.Distance 는 충돌지점과의 거리
    --// 만약 이 둘이 같을때 나누면 몫은 1, 즉 충돌하지 않았다는뜻 
    --// 충돌하지 않았기에 리턴
    if result.Distance / distance == 1 then
        return
    end

    --// self 의 normal 을 설정
    self.normal = result.Normal

    --// self 가 충돌함으로 변경
    self.isColliding = true

    if self.flags.fCollisionBounce then
        physics.physicsCollisionBounce(self)
    end

    if self.onCollide then
        self.onCollide(self)
    end
end

function physics.physicsCollisionBounce(self: Entity)
    --// 탄성계수는 0.3
    local totalElasticity = 0.3

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
            --// 속도 초기화
            self.velocity = Vector3.zero

            --// 각속도 초기화
            self.angularVelocity = Vector3.zero

            --// 플레그 비활성화 (중력, 충돌)
            self.flags.fGravity = false
            self.flags.fCollideWorld = false
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

return physics
