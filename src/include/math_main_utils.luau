local vector = require('./vecotr_main_utils')

local math_main_utils = {}

function math_main_utils.vectorAngle(forward: vector.Vector)
    --// pitch: 위아래로 얼마나 기울여져있는지 (Y축을 기준으로)
    --// yaw: 좌우로 어느방향인지 (지면을 기준으로 얼마나 회전해있는지 (Z 축을 기준으로))
    local yaw: number, pitch: number
    
    --// 만약 y 에만 값이 있는상태가 아니라면 
    if not (forward.x == 0 and forward.z == 0) then
        --// 좌우 값이 없음 --> yaw 값은 0
        yaw = 0

        --// y 기준으로 pitch 정하기 
        if forward.y > 0 then
            --// 양수라면 (위를 향한다면) 270 (-90)
            pitch = 270
        else
            --// 음수라면 (아래를 향한다면) 90
            pitch = 90
        end

    --// 값이 y 이외에도 있는상태라면
    else
        --// atan2 (아크탄젠트) (탄젠트의 역함수) 설명
        
        --// 일단 atan 설명
        --// atan 은 기울기를 각도로 바꾸고싶을대 씀
        --// tan(x) = y 라면 atan(y) = x 임 (역함수니깐)
        --// -> atan(1) = pi/4(rad) 왜냐하면 tan(pi/4) = 1 이니깐 (pi/4 (rad) = 45 deg)
        
        --// 기울기가 왜 각도로 감?
        --// y = ax+b 에서 a = 기울기
        --// tan(A) = a / b (이때 a 는 높이, b 는 밑변) 즉 y / x
        --// -> a = y / x (즉 tan(A) 는 기울기)
        
        --// 여기서 atan 은 tan 의 역함수이니깐
        --// tan(A) = a / b
        --// atan(a / b) = A 즉 각도가됌

        --// atan 은 (pi/2 rad)(90 deg) 에서 (-pi/2 rad)(-90 deg) 사이의 값을 줌
        --// 왜냐하면 탄젠트는 다른 인수에 같은 결과값을 낼수도 있음 (대응돼는 세타가 무수히 많음)
        --// tan(pi/4)(45deg) = 1
        --// tan(5pi/4)(180*5/4deg) = 1
        
        --// 하지만 atan 은 유일한 해를 반환해야하기 때문에 범위를 제한함
        --// atan(1 / 1) = 1, atan(-1 / -1) = 1
        
        --// 그래서 atan 은 (pi/2 rad)(90 deg) 에서 (-pi/2 rad)(-90 deg) 사이의 값을 줌 --> 방향을 모름
        --// 그리고 이제 이 방향을 알기위해 atan2 를 사용
        --// math.atan2(x, y)

        --// atan2 에서 x 가 양수라면 (1, 4 사분면 이라면)
        --// math.atan(y / x (y / x 는 기울기니깐)) 
        --// 왜 한번에 처리하냐면 어차피 파이 안더해도 돼고 그냥 +- 처리가 자동으로 됌

        --// atan2 에서 x 가 음수이고 y 가 0 이거나 양수일때 (2 사분면 이라면)
        --// math.atan(y / x) + math.pi(180deg)
        --// 이러면 각도가 음수가 나옴 즉 4사분면에 위치 (atan(n) <= 90(deg))
        --// 만약 (1, -1) 을 넣으면 -45(deg) 여기에 pi(180deg) 를 더해주면 
        --// 180 - 45 = 135 --> 2사분면에 원하는 위치에 감

        --// atan2 에서 x 가 음수이고 y 가 음수라면 (3 사분면 이라면)
        --// math.atan(y / x) - math.pi(180deg)
        --// 이러면 각도가 양수가 나옴
        --// 만약 (-1, -1) 을 넣으면 45(deg) 가 나옴 즉 1사분면에 위치
        --// 여기에 pi(180deg) 를 빼주면 (45 - 180) = -135 즉 3사분면에 위치

        --// 즉 atan2 는 y, x 로 방향을 포함한 atan 값을 준다

        --// 참고
        --//          B
        --//         /|
        --//        / |
        --//    c  /  | a
        --//      /   |
        --//     /____|
        --//    A  b  C

        --// sin(A) = a / c
        --// cos(A) = b / c 
        --// tan(A) = a / b = sin(A) / cos(A) 
        --// -> (a / c) / (b / c) = (a / c) * (c / b) = (a * c) / (c * b) = a / b

        --// pi(rad) = 180(deg)
        --// pi/2(rad) = 90(deg)
        --// pi/4(rad) = 180 / 4(deg) = 45(deg)

        --// tan 의 파라미터는 라디안
        --// atan2 의 출력은 라디안 (no degree)

        --// 디그리 -> 라디안 = n * pi / 180
        --// 라디안 -> 디그리 = n * 180 / pi
        
        --// math.atan2 함수의 첫번째 파라미터는 y, 두번째 파라미터는 x 임 
        --// y = ax+b 에서 a = 기울기
        --// a = y / x

        --// forward Z 와 X 의 각도를 구함 (방향을 포함한)
        --// yaw 는 deg 이므로 180 / pi 를 곱해줌
        yaw = math.atan2(forward.z, forward.x) * 180 / math.pi

        --// atan2 는 3, 4 사분면에 위치하는 각의경우 음수를 주기때문에
        --// 양수 각도로 바꿔줌 (360 - 45 = 315(deg))
        if yaw < 0 then
            yaw += 360
        end

        --// tmp 는 forward 의 x 와 z 사이의 거리임 (피타고라스 (x*x + y*y) = z*z)
        local tmp = (forward.x*forward.x + forward.z*forward.z) ^ 0.5

        --// 기울기는 x 와 z 사이의 선과 y 의 기울기
        --// 즉 각도는 밑변과 높이사이의 각도
        
        --// TODO: 테스트 해보고 - 넣어야할지 결정
        
        --// 즉 pitch 는 밑면과 높이의 각도 즉 위 아래로 얼마나 기우러져있는지
        pitch = math.atan2(-forward.y, tmp) * 180 / math.pi

        --// pitch 가 음수이면 양수로 바꿔주기
        if pitch < 0 then
            pitch += 360
        end
    end

    --// roll 값은 처리 안함

    return vector.create(pitch, yaw, 0)
end

return math_main_utils
