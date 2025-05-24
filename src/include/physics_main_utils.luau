local physics_main_utils = {}

--// 반사속도 계산
--// velocity: 속도, normal: 법선벡터, overbounce: 반사강도
function physics_main_utils.clipVelocity(velocity: Vector3, normal: Vector3, overbounce: number)
    --// velocity 와 normal 의 내적 (방향이 비슷함 정도 (physics.luau 설명 참고)) * overbounce (반사강도)
    --// 즉 부딪친 강도에 overbounce 를 곱한값 (backoff 는 스칼라)
    local backoff = velocity:Dot(normal) * overbounce

    --// result 를 속도 - 법선백터 * 부딪친 가중치
    --// 백터 반사공식(physics.luau 참고) v - 2 * (v * n) << 여기서 상수 2 = overbounce 
    --// 즉 overbounce 가 2 라면 완벽하게 튕김 (v - overbounce * (v (스칼라) * n (법선백터)))
    local result = velocity - normal * backoff

    --// 속도가 0.1 이네라면 0 으로 (정지상태) 
    if result.X > -0.1 and result.X < 0.1 then
        result.X = 0
    end

    if result.Y > -0.1 and result.Y < 0.1 then
        result.Y = 0
    end

    if result.Z > -0.1 and result.Z < 0.1 then
        result.Z = 0
    end

    return result
end

return physics_main_utils
