convergeView = class("convergeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
convergeView.__index = convergeView
function convergeView:create(...)
    local layer = convergeView.new(...)
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
function convergeView:ctor()
    print("convergeView:ctor()")
    self.mAlliancenode = nil
    self.showFlagView = true
    self.bshowBattleView = false
end
function convergeView:showFlag(show) 
    self.showFlagView = show
end
function convergeView:enterFlagSubcell()
    self:switchButtons(self.Button_flag)
    local flag = flagSubcell:create("flagSubcell.csb")
    flag:setFatherNode(self)
    self.Panel_bottom:addChild(flag)
    flag:setAnchorPoint(cc.p(0.5,0.5))
    flag:setPosition(cc.p(self.Panel_bottom:getContentSize().width/2,self.Panel_bottom:getContentSize().height/2))
end
function convergeView:switchButtons(node)
    me.setButtonDisable(self.Button_reinforce,node ~= self.Button_reinforce)
    me.setButtonDisable(self.Button_battle,node ~= self.Button_battle)
    me.setButtonDisable(self.Button_flag,node ~= self.Button_flag)
    -- 字体颜色
    me.assignWidget(self.Button_reinforce, "text_title"):setTextColor(node ~= self.Button_reinforce and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))
    me.assignWidget(self.Button_reinforce, "text_title"):enableShadow(node ~= self.Button_reinforce and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))

    me.assignWidget(self.Button_battle, "text_title"):setTextColor(node ~= self.Button_battle and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))
    me.assignWidget(self.Button_battle, "text_title"):enableShadow(node ~= self.Button_battle and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))

    me.assignWidget(self.Button_flag, "text_title"):setTextColor(node ~= self.Button_flag and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))
    me.assignWidget(self.Button_flag, "text_title"):enableShadow(node ~= self.Button_flag and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
end
function convergeView:init()
    print("convergeView:init()")
    self.Button_flag=me.assignWidget(self,"Button_flag")
    self.Button_battle=me.assignWidget(self,"Button_battle")
    self.Button_reinforce=me.assignWidget(self,"Button_reinforce")
    self.Panel_bottom = me.assignWidget(self,"Panel_bottom")

    me.registGuiClickEvent(self.Button_flag,function (node)
        self:switchButtons(node)
        self.Panel_bottom:removeAllChildren()
        self.mAlliancenode = nil
        self:enterFlagSubcell()
    end)
    me.registGuiClickEvent(self.Button_battle,function (node)
        self:switchButtons(node)
        GMan():send(_MSG.worldTeamInfo())
    end)
    me.registGuiClickEvent(self.Button_reinforce,function (node)
        self:switchButtons(node)
        GMan():send(_MSG.worldTeamCityArmy())
    end)

    me.registGuiClickEventByName(self,"close",function (node)        
        self:close()
    end)
    return true
end
function convergeView:showBattleView()       
        self.bshowBattleView = true
end
function convergeView:update(msg)
   if checkMsg(msg.t, MsgCode.WORLD_TEAM_INFO) then
        if self.mAlliancenode == nil then
            self.Panel_bottom:removeAllChildren()
            local allianceNode = convergealliance:create("allianceconverge.csb")
            allianceNode:setData()
            allianceNode:setAnchorPoint(cc.p(0, 0))
            allianceNode:setPosition(cc.p(0, 0))
            self.Panel_bottom:addChild(allianceNode)  
            self.mAlliancenode = allianceNode
        else
            self.mAlliancenode:setData()               
        end                          
   elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CITY_ARMY) then
        self.mAlliancenode = nil
        self.Panel_bottom:removeAllChildren()
        local ReliefNode = convergeRelief:create("convergeRelief.csb")
        ReliefNode:setHaveAid()
        self.Panel_bottom:addChild(ReliefNode) 
   elseif checkMsg(msg.t, MsgCode.ALLIANCE_CONVERGE_RENIVE_HINT) then
        if self.showFlagView  then
            self:setAllianceHint()    
        end   
   end
end
function convergeView:setAllianceHint()
       local pHint = user.allianceConvergeHint.attack + user.allianceConvergeHint.defener
         if pHint > 0 then
             me.assignWidget(self,"allianceConvergeHint"):setVisible(true)
         else
            me.assignWidget(self,"allianceConvergeHint"):setVisible(false)         
         end
end
function convergeView:showDefaultCell()
    if self.showFlagView then                
         self:setAllianceHint()    
         self:enterFlagSubcell()
    else
        self.Button_flag:setVisible(false) 
        local x,y = me.assignWidget(self,"Node_flag"):getPosition()
        self.Button_battle:setPosition(cc.p(x,y))
        local x1,y2 = me.assignWidget(self,"Node_battle"):getPosition()
        self.Button_reinforce:setPosition(cc.p(x1,y2))
        self:switchButtons(self.Button_battle)
        GMan():send(_MSG.worldTeamInfo())
    end    
end
function convergeView:onEnter()
    print("convergeView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    self.close_event = me.RegistCustomEvent("convergeView",function (evt)
        self:close()
    end)
    if self.bshowBattleView then
        self:switchButtons(self.Button_battle)
        GMan():send(_MSG.worldTeamInfo())
    else    
        self:showDefaultCell()
    end
    -- 小红点
    self:setAllianceHint()
end
function convergeView:onEnterTransitionDidFinish()
    print("convergeView:onEnterTransitionDidFinish()")
end
function convergeView:onExit()
    print("convergeView:onExit()")
    UserModel:removeLisener(self.modelkey)
    me.RemoveCustomEvent(self.close_event)
end
function convergeView:close()
    self:removeFromParentAndCleanup(true)
end
