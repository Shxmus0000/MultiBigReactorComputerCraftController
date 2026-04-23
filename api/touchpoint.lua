local touchpoint = {}

function touchpoint.new()
    local obj = {
        buttons = {}
    }

    function obj.add(name, x1,y1,x2,y2,func)
        obj.buttons[name] = {x1=x1,y1=y1,x2=x2,y2=y2,func=func}
    end

    function obj.handle(x,y)
        for _,b in pairs(obj.buttons) do
            if x>=b.x1 and x<=b.x2 and y>=b.y1 and y<=b.y2 then
                b.func()
                return
            end
        end
    end

    return obj
end

return touchpoint
