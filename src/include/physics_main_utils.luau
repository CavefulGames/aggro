local vector = require('./vecotr_main_utils')

local physics_main_utils = {}

--// 반사속도 계산
--// velocity: 속도, normal: 법선벡터, overbounce: 반사강도
function physics_main_utils.clipVelocity(velocity: vector.Vector, normal: vector.Vector, overbounce: number)
    --// velocity 와 normal 의 내적 (방향이 비슷함 정도 (physics.luau 설명 참고)) * overbounce (반사강도)
    --// 즉 부딪친 강도에 overbounce 를 곱한값 (backoff 는 스칼라)
    local backoff = velocity:dot(normal) * overbounce

    --// result 를 속도 - 법선백터 * 부딪친 가중치 (백터 반사공식)
    --// 백터 반사공식(physics.luau 참고) v - 2 * (v * n) << 여기서 상수 2 = overbounce 
    --// 즉 overbounce 가 2 라면 완벽하게 튕김 (v - overbounce * (v (스칼라) * n (법선백터)))
    local result = velocity:sub(normal:mul(backoff))

    --// 속도가 0.1 이네라면 0 으로 (정지상태) 
    if result.x > -0.1 and result.x < 0.1 then
        result.x = 0
    end

    if result.y > -0.1 and result.y < 0.1 then
        result.y = 0
    end

    if result.z > -0.1 and result.z < 0.1 then
        result.z = 0
    end

    return result
end

return physics_main_utils
