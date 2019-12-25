sheepModel = class("sheepModel",mAnimation)
sheepModel.__index = sheepModel

function sheepModel:ctor(name_)
    super(self)   
    self.speed = 10 --绵羊速度
    self.center = {} --以center为中心点 随机走动
end

function sheepModel:setCenterPos(x_, y_)
     self.center.x, self.center.y = x_, y_
end

function sheepModel:getCenterPos()
    return self.center
end

function sheepModel:createAni(name)
    local layer = sheepModel.new(name)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end

    return nil
end

function sheepModel:init()
    return true
end

function sheepModel:onEnter()
end

function sheepModel:onExit()
end
