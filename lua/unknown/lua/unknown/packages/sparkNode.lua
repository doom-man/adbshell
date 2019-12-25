--[[
spark.png会流光图片
    local tt = ccui.TextBMFont:create("jnmogod is god","font-issue1343.fnt")
    local spark = sparkNode:create(tt,"spark.png")
    layer:addChild(spark)
]]
sparkNode = class("sparkNode",function ()
    return cc.Node:create()
end)
sparkNode.__index = sparkNode
function sparkNode:create(tag,file)
    local layer = sparkNode.new()
    if layer then 
        if layer:init() then 
            layer:initWithSpark(tag,file)
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function sparkNode:ctor()
    self.tag_ = nil
    self.spark = nil
    self.stencil = nil
end
function sparkNode:init()   
    return true
end
function sparkNode:initWithSpark(tag,file)
	local cNode = cc.ClippingNode:create()
	self.tag_ = tag
	self.stencil = tag
    self.spark = cc.Sprite:create(file)
    self.spark:setPosition(-self.tag_:getContentSize().width,0)
    cNode:setAlphaThreshold(0.5)
    cNode:setStencil(self.stencil);
    cNode:addChild(self.tag_);
    cNode:addChild(self.spark);
    self:addChild(cNode)
    local moveto = cc.MoveTo:create(2.0,cc.p(self.tag_:getContentSize().width,0))
    local delay = cc.DelayTime:create(3)
    local moveback  = cc.MoveTo:create(0,cc.p(-self.tag_:getContentSize().width,0))
    local seq = cc.Sequence:create(moveto,delay,moveback)
    local rev = cc.RepeatForever:create(seq)    
    self.spark:runAction(rev)
end

function sparkNode:onEnter()

end
function sparkNode:onExit()
    
end