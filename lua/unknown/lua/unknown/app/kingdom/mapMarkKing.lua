--[Comment]
--jnmo
mapMarkKing = class("mapMarkKing",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
mapMarkKing.__index = mapMarkKing
function mapMarkKing:create(...)
    local layer = mapMarkKing.new(...)
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
function mapMarkKing:ctor()   
    print("mapMarkKing ctor") 
end
function mapMarkKing:init()   
    print("mapMarkKing init")
	me.registGuiClickEventByName(self,"btn_cancel",function (node)
        self:close()     
    end)    
    me.registGuiClickEventByName(self,"btn_ok",function (node)
        if user.officeDegree == false then
            -- 是否是国王
            showTips("只有盟主才能标记")
        else
            if me.isValidStr( self.desc:getString() ) then 
                GMan():send(_MSG.mapMarkKing(self.croodX, self.croodY,self.desc:getString()))
            else
                showTips("请输入标记内容")
            end
            self:close()
        end 
    end) 
    self.Text_Crood = me.assignWidget(self,"Text_Crood")
    self.desc = me.assignWidget(self,"TextField_1")
    return true
end
function mapMarkKing:initCrood(x,y)
     self.croodX = x
     self.croodY = y
     self.Text_Crood:setString("("..x..","..y..")" )
end
function mapMarkKing:onEnter()
    print("mapMarkKing onEnter") 
	me.doLayout(self,me.winSize)  
end
function mapMarkKing:onEnterTransitionDidFinish()
	print("mapMarkKing onEnterTransitionDidFinish") 
end
function mapMarkKing:onExit()
    print("mapMarkKing onExit")    
end
function mapMarkKing:close()
    self:removeFromParent()  
end
