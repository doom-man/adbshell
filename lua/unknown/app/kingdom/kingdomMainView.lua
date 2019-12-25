kingdomMainView = class("kingdomMainView", function(...)
    local arg = { ...}
    if table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    else
        return cc.CSLoader:createNode(arg[1])
    end
end )

kingdomMainView.__index = kingdomMainView
kingdomMainView.type_officer = 1
kingdomMainView.type_foundation = 2
kingdomMainView.type_nationalPolicy = 3
kingdomMainView.type_militaryPolicy = 4

function kingdomMainView:create(...)
    local layer = kingdomMainView.new(...)
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
function kingdomMainView:ctor(...)
    _, _, self.opentype = ...
    self.curBtn = nil
    print("kingdomMainView:ctor()")
end
function kingdomMainView:setButton(button,b)
	local selectImg = me.assignWidget(button,"Image_26")
	if b then
		selectImg:setVisible(true) 
	else
		selectImg:setVisible(false) 
	end
end

function kingdomMainView:switchButtons(node)
    if self.curBtn and self.curBtn == node then
        return
    end
    self.curBtn = node
    self:setButton(self.Button_officer,false)
    self:setButton(self.Button_foundation,false)
    self:setButton(self.Button_nationalPolicy,false)
    self.Panel_content:removeAllChildren()
    if self.Button_officer == node then
        self:setButton(self.Button_officer,true)
        NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_officer))
    elseif self.Button_foundation == node then
        self:setButton(self.Button_foundation,true)
        if user.kingdom_OfficerData==nil then
            self.clickOfficer = true
            NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_officer))
        end
        NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_foundation))
    elseif self.Button_nationalPolicy == node then
        self:setButton(self.Button_nationalPolicy,true)
        if user.kingdon_foundationData==nil then
            self.clickPolicy = true
            NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_foundation))
        end
        NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_nationalPolicy))
    elseif self.Button_militaryPolicy == node then
        NetMan:send(_MSG.Cross_Promotion_List())
    end
    self.officerSubcell = nil
    self.militaryPolicySubcell = nil
    self.nationalPolicySubcell = nil
    self.foundationSubcell = nil
end
function kingdomMainView:init()
    print("kingdomMainView:init()")
    self.Button_officer = me.assignWidget(self,"Button_officer")
    self.Button_foundation = me.assignWidget(self,"Button_foundation")
    self.Button_nationalPolicy = me.assignWidget(self,"Button_nationalPolicy")
    self.Button_militaryPolicy = me.assignWidget(self,"Button_militaryPolicy")
    self.Panel_content = me.assignWidget(self,"Panel_content")

    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)
    me.registGuiClickEvent(self.Button_officer,function (node)
        self:switchButtons(node)
    end)
    me.registGuiClickEvent(self.Button_foundation,function (node)
        self:switchButtons(node)
    end)
    me.registGuiClickEvent(self.Button_nationalPolicy,function (node)
        self:switchButtons(node)
    end)
    me.registGuiClickEvent(self.Button_militaryPolicy,function (node)
        self:switchButtons(node)
    end)
    --NetMan:send(_MSG.Cross_Promotion_List())
    return true
end
function kingdomMainView:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_TYPE_DETAIL) then
        if msg.c.type == kingdomMainView.type_officer then
            if self.clickOfficer == true then return end
            self:enterOfficerSubcell()
        elseif msg.c.type == kingdomMainView.type_foundation then
            if self.clickPolicy == true then return end
            self.clickOfficer = false
            self:enterFoundationSubcell()
        elseif msg.c.type == kingdomMainView.type_nationalPolicy then
            self.clickPolicy = false
            self.clickOfficer = false
            self:enterNationalPolicy(msg.c.type)        
        end
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_PROMOTION_LIST) then -- 军政
        -- self:enterMilitaryPolicy()
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then -- 奖励
         if self.kingdom_cross_rewards == nil then
            self.kingdom_cross_rewards = nil
            if msg.c.type == kingdom_cross_rewards.RankRewardType or msg.c.type == kingdom_cross_rewards.totalRewardType then
                self.kingdom_cross_rewards = kingdom_cross_rewards:create("kingdom_cross_rewards.csb")          
            end          
            self.kingdom_cross_rewards:setRewardType(msg.c.type,msg.c.stp,msg.c.award,function ()
                self.kingdom_cross_rewards = nil
            end)
            self:addChild(self.kingdom_cross_rewards)
        else
            self.kingdom_cross_rewards:setRewardType(msg.c.type,msg.c.stp,msg.c.award,function ()
                self.kingdom_cross_rewards = nil
            end)
            self.kingdom_cross_rewards:setRewardInfos()
        end
    end
end
function kingdomMainView:Cross_des(id)
    local Cross_des_bg = me.assignWidget(self,"Cross_des_bg"):setVisible(true)
    local Text_des = me.assignWidget(self,"Text_des")
    local pDef = cfg[CfgType.CROSS_ACTIVEITY_DEF][id]
    Text_des:setString(pDef["des"])
    me.registGuiTouchEventByName(self,"Panel_8",function (node)
       me.assignWidget(self,"Cross_des_bg"):setVisible(false)
    end)    
end
function kingdomMainView:onEnter()
    print("kingdomMainView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomMainView")
    if self.opentype==3 then
        if user.kingdom_OfficerData==nil then
            self.clickOfficer = true
            NetMan:send(_MSG.kingdom_detail_type(kingdomMainView.type_officer))
        end
        self:switchButtons(self.Button_nationalPolicy)
    else
        self:switchButtons(self.Button_officer)
    end
end
function kingdomMainView:onEnterTransitionDidFinish()
    print("kingdomMainView:onEnterTransitionDidFinish()")
end
function kingdomMainView:onExit()
    pWorldMap.kmv = nil
    print("kingdomMainView:onExit()")
end
function kingdomMainView:close()
    UserModel:removeLisener(self.modelkey)
    self:removeFromParentAndCleanup(true)
end

function kingdomMainView:enterOfficerSubcell()
    if self.officerSubcell == nil then
        self.officerSubcell = kingdomView_officer:create("kingdomView_officer.csb")
        self.Panel_content:addChild(self.officerSubcell)    
    end
end

function kingdomMainView:enterFoundationSubcell()
    if self.foundationSubcell == nil then
        self.foundationSubcell = kingdomView_foundation:create("kingdomView_foundation.csb")
        self.Panel_content:addChild(self.foundationSubcell)    
    end
end
function kingdomMainView:enterNationalPolicy(type)
    if self.nationalPolicySubcell == nil then
        self.nationalPolicySubcell = kingdomView_policy:create("kingdomView_policy.csb")
        self.nationalPolicySubcell:setTypeData(type)
        self.Panel_content:addChild(self.nationalPolicySubcell)    
    end
end
function kingdomMainView:enterMilitaryPolicy(type)
    if self.militaryPolicySubcell == nil then
        self.militaryPolicySubcell = kingdomView_Cross:create("kingdomView_Cross.csb")
      --  self.militaryPolicySubcell:setTypeData(type)
        self.Panel_content:addChild(self.militaryPolicySubcell)  
    end
end