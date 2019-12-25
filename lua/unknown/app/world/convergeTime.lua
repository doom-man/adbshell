 --[Comment]
--jnmo
convergeTime = class("convergeTime",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
convergeTime.__index = convergeTime
function convergeTime:create(...)
    local layer = convergeTime.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function convergeTime:ctor()   
    print("convergeTime ctor") 
end
function convergeTime:init()   
    print("convergeTime init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.MassTime = {5,10,20,30}

    for var = 1 , 4 do
        local pLine = (var - 1) % 2  -- 行
        local pList = math.ceil(var / 2)  -- 列      
        local pButtonTime = me.assignWidget(self,"Button_time"):clone():setVisible(true)
        pButtonTime:setAnchorPoint(cc.p(0,0))
        pButtonTime:setPosition(cc.p(146 + 260 * pLine, 74 - 65 * (pList - 1)))
        pButtonTime:setTag(var)
        me.assignWidget(pButtonTime, "text_title_btn"):setString(self.MassTime[var].."分钟")
        me.registGuiClickEvent(pButtonTime,function (node)
             local pIndex = node:getTag()
              pWorldMap:showconverge(cc.p(user.x, user.y),cc.p(self.tag.x, self.tag.y),self.Team_type,self.MassTime[pIndex],0)             
              self:close()  
        end)
        me.assignWidget(self,"Node_time"):addChild(pButtonTime)
    end
    
    return true
end
function convergeTime:setPoint(tag,Team_type) 
    self.tag = tag
    self.Team_type = Team_type
end
function convergeTime:onEnter()
    print("convergeTime onEnter") 
	me.doLayout(self,me.winSize)  
end
function convergeTime:onEnterTransitionDidFinish()
	print("convergeTime onEnterTransitionDidFinish") 
end
function convergeTime:onExit()
    print("convergeTime onExit")    
end
function convergeTime:close()
    self:removeFromParentAndCleanup(true)  
end

