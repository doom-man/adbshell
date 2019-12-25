--[Comment]
--jnmo
mapSetMarkKing = class("mapSetMarkKing",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
mapSetMarkKing.__index = mapSetMarkKing
function mapSetMarkKing:create(...)
    local layer = mapSetMarkKing.new(...)
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
function mapSetMarkKing:ctor()   
    print("mapSetMarkKing ctor") 
end
function mapSetMarkKing:init()   
    print("mapSetMarkKing init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.Text_Crood = me.assignWidget(self,"Text_Crood")
    self.Text_Owner = me.assignWidget(self,"Text_Owner")
    self.Text_Desc = me.assignWidget(self,"Text_Desc")
    me.registGuiClickEventByName(self,"btn_go",function (node)
         LookMap(cc.p(self.data.x,self.data.y),"fortWorldClose")
         self:close()
    end) 
    self.btn_del =  me.registGuiClickEventByName(self,"btn_del",function (node)
          local function continue(str)
            if str=="ok"  then               
                GMan():send(_MSG.mapMarkKing(-1, -1,""))  
                self:close()
            end
        end
        me.showMessageDialog("是否确定删除此标记？", continue)
    end) 
    return true
end
function mapSetMarkKing:initWithData(data)
    self.data = data
    self.Text_Crood:setString("(".. data.x..","..data.y..")" )
    self.Text_Owner:setString("["..data.familyName.."]"..data.playerName )
    self.Text_Desc:setString(data.txt)
    me.setButtonDisable(self.btn_del,data.mine == true)
end
function mapSetMarkKing:onEnter()
    print("mapSetMarkKing onEnter") 
	me.doLayout(self,me.winSize)  
end
function mapSetMarkKing:onEnterTransitionDidFinish()
	print("mapSetMarkKing onEnterTransitionDidFinish") 
end
function mapSetMarkKing:onExit()
    print("mapSetMarkKing onExit")    
end
function mapSetMarkKing:close()
    self:removeFromParent()  
end
