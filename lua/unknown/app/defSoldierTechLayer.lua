--[Comment]
--jnmo
defSoldierTechLayer = class("defSoldierTechLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
defSoldierTechLayer.__index = defSoldierTechLayer
function defSoldierTechLayer:create(...)
    local layer = defSoldierTechLayer.new(...)
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
function defSoldierTechLayer:ctor()   
    print("defSoldierTechLayer ctor") 
end
function defSoldierTechLayer:init()   
    print("defSoldierTechLayer init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_INIT) then
              user.guard_tech = msg.c.list
              self:initTech(msg.c.list)
        elseif checkMsg(msg.t, MsgCode.MSG_GUARD_TECH_UP_LEVLE) then
            --user.guard_tech[self.choose_idx].id = msg.c.next
            --user.guard_tech[self.choose_idx].red = msg.c.red           
            self:initTech(user.guard_tech)
        end
    end )
    self.list = me.assignWidget(self,"list")
    self.choose_idx = 1
    self.viewData = {}
    for key, var in pairs(cfg[CfgType.LORD_INFO]) do
        self.viewData[var.key]  = var          
    end
    return true
end
function defSoldierTechLayer:initTech(data)    
    self.listData  = {}
    self.list:removeAllChildren()
    local guard_def = cfg[CfgType.ARMYTECH]
    for key, var in pairs(data) do
       table.insert(self.listData,var)
    end
    for key, var in pairs(self.listData) do
       local node = defSoldierTechCell:create(self,"guardTechItem")           
       node:setVisible(true)
       node:initWithData(var,key,#self.listData,self.viewData) 
       self.list:pushBackCustomItem(node)   
       me.registGuiClickEvent(node,function (node)
          self.choose_idx = node.idx 
          me.dispatchCustomEvent("defSoldierTechCell_choose",self.choose_idx) 
       end)
    end    
    me.dispatchCustomEvent("defSoldierTechCell_choose",self.choose_idx) 
end

function defSoldierTechLayer:onEnter()
    print("defSoldierTechLayer onEnter") 
	me.doLayout(self,me.winSize)  
end
function defSoldierTechLayer:onEnterTransitionDidFinish()
	print("defSoldierTechLayer onEnterTransitionDidFinish") 
end
function defSoldierTechLayer:onExit()
    print("defSoldierTechLayer onExit")  
    UserModel:removeLisener(self.modelkey)  
end
function defSoldierTechLayer:close()
    self:removeFromParent()  
end
