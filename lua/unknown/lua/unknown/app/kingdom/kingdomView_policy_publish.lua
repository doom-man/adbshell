kingdomView_policy_publish = class("kingdomView_policy_publish", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )

kingdomView_policy_publish.__index = kingdomView_policy_publish
function kingdomView_policy_publish:create(...)
    local layer = kingdomView_policy_publish.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function kingdomView_policy_publish:ctor()
    print("kingdomView_policy_publish:ctor()")
end
function kingdomView_policy_publish:setDefData(defId)
    self.defId = defId
end
function kingdomView_policy_publish:init()
    print("kingdomView_policy_publish:init()")
    me.doLayout(self,me.winSize)  
    self.Image_icon = me.assignWidget(self,"Image_icon")
    self.Text_title = me.assignWidget(self,"Text_title")
    self.Text_decs = me.assignWidget(self,"Text_decs")
    self.Text_food1 = me.assignWidget(self,"Text_food1")
    self.Text_food2 = me.assignWidget(self,"Text_food2")

    self.Text_wood2 = me.assignWidget(self,"Text_wood2")
    self.Text_wood1 = me.assignWidget(self,"Text_wood1")

    self.Text_stone1 = me.assignWidget(self,"Text_stone1")
    self.Text_stone2 = me.assignWidget(self,"Text_stone2")

    self.Text_gold1 = me.assignWidget(self,"Text_gold1")
    self.Text_gold2 = me.assignWidget(self,"Text_gold2")

    self.ndiamond = me.assignWidget(self, "ndiamond")

    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)

    self.Text_food1:setString(tostring(Scientific(user.kingdon_foundationData.food)))
    self.Text_wood1:setString(tostring(Scientific(user.kingdon_foundationData.wood)))
    self.Text_stone1:setString(tostring(Scientific(user.kingdon_foundationData.stone)))
    self.Text_gold1:setString(tostring(Scientific(user.kingdon_foundationData.gold)))
    
    me.registGuiClickEventByName(self, "Button_stone",function (node)
        showWaitLayer()
        NetMan:send(_MSG.kingdom_policy_publish(self.def.id, "", 1))
    end)
    me.registGuiClickEventByName(self, "Button_res",function (node)
        showWaitLayer()
        NetMan:send(_MSG.kingdom_policy_publish(self.def.id, "", 0))
    end)

    return true
end
function kingdomView_policy_publish:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_NATIONAL_POLICY_PUBLISH) then
        disWaitLayer()
        self:close()
    end
end
function kingdomView_policy_publish:onEnter()
    print("kingdomView_policy_publish:onEnter()")
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_policy_publish")
end
function kingdomView_policy_publish:setDefData(def)
    self.def = def

    self.Text_decs:setString(def.desc)
    self.Text_title:setString(def.name)
    self.Image_icon:loadTexture("guoce_tb_"..def.icon..".png")

    local pData = user.kingdom_policyData_national.list[def.id]
    self.ndiamond:setString("x"..pData.gem)

    self.Text_food2:setString("/"..pData.food)
    if pData.food>user.kingdon_foundationData.food then
        self.Text_food1:setTextColor(cc.c3b(255, 0,0))
    end
    self.Text_food2:setPositionX(self.Text_food1:getPositionX()+self.Text_food1:getContentSize().width+3)
    self.Text_wood2:setString("/"..pData.wood)
    if pData.wood>user.kingdon_foundationData.wood then
        self.Text_wood1:setTextColor(cc.c3b(255, 0,0))
    end

    self.Text_wood2:setPositionX(self.Text_wood1:getPositionX()+self.Text_wood1:getContentSize().width+3)
    self.Text_stone2:setString("/"..pData.stone)
    if pData.stone>user.kingdon_foundationData.stone then
        self.Text_stone1:setTextColor(cc.c3b(255, 0,0))
    end
    self.Text_stone2:setPositionX(self.Text_stone1:getPositionX()+self.Text_stone1:getContentSize().width+3)
    self.Text_gold2:setString("/"..pData.gold)
    if pData.gold>user.kingdon_foundationData.gold then
        self.Text_gold1:setTextColor(cc.c3b(255, 0,0))
    end
    self.Text_gold2:setPositionX(self.Text_gold1:getPositionX()+self.Text_gold1:getContentSize().width+3)
end
function kingdomView_policy_publish:onEnterTransitionDidFinish()
    print("kingdomView_policy_publish:onEnterTransitionDidFinish()")
end
function kingdomView_policy_publish:onExit()
    UserModel:removeLisener(self.modelkey)
    print("kingdomView_policy_publish:onExit()")
end
function kingdomView_policy_publish:close()
    self:removeFromParentAndCleanup(true)
end