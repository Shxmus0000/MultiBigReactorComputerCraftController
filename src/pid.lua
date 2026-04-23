local PID = {}

function PID.new()
    return {
        kp = -0.08,
        ki = -0.0015,
        kd = -0.01,
        integral = 0,
        lastError = 0
    }
end

function PID.step(p, error)
    local P = p.kp * error

    p.integral = p.integral + p.ki * error
    p.integral = math.max(-100, math.min(100, p.integral))

    local D = p.kd * (error - p.lastError)
    p.lastError = error

    return P + p.integral + D
end

return PID
