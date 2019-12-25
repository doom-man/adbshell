fortLayer = class("fortLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortLayer.__index = fortLayer
function fortLayer:create(...)
    local layer = fortLayer.new(...)
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
function fortLayer:ctor()
    print("fortLayer ctor")
end
function fortLayer:init()
    print("fortLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun( function()
            self:close()
        end )
    end )
    self.Button_bastion = me.assignWidget(self, "Button_bastion")
    self.Button_Move = me.assignWidget(self, "Button_Move")
    me.registGuiClickEvent(self.Button_bastion, function(node)
        if node.state == "enable" then
            pWorldMap.buildTrade = buildTradeLayer:create("buildTradeLayer.csb")
            pWorldMap.buildTrade:initWithData(buildTradeLayer.CreateType, 1)
            pWorldMap.buildTrade:setTagPoint(self.m_tag)
            pWorldMap:addChild(pWorldMap.buildTrade, me.MAXZORDER)
            me.showLayer(pWorldMap.buildTrade, "bg")
            self:close()
        elseif node.state == "disable" then
            showTips("主城5级才能建造据点")
        end
    end )
    me.registGuiClickEvent(self.Button_Move, function(node)
        if node.state == "enable" then
            if CaptiveMgr:isCaptured() then
                showTips("沦陷状态下无法迁城！")
            else
                GMan():send(_MSG.moveCity(self.m_tag.x, self.m_tag.y))
            end
            self:close()
        elseif node.state == "disable" then
            local moveInfo = fortInfoLayer:create("moveCityInfoLayer.csb")
            pWorldMap:addChild(moveInfo, me.MAXZORDER)
            me.showLayer(moveInfo, "bg")
        end
    end )
    local Text_Name = me.assignWidget(self, "Text_Name_")
    self.Text_Info2 = me.assignWidget(me.assignWidget(self, "border2"), "Text_Info")
    self.Text_Info1 = me.assignWidget(me.assignWidget(self, "border1"), "Text_Info")
    if user.Cross_Sever_Status == mCross_Sever then
        self.Text_Info2:setString("跨服海战活动中普通关隘解锁前可迁城至本服任意空城，仅限一次")
    else
        self.Text_Info2:setString("迁城至此处")
    end
    return true
end
function fortLayer:onEnter()
    print("fortLayer onEnter")
    me.doLayout(self, me.winSize)
end
function fortLayer:initState(cp)
    self.m_tag = cp
    local celldata = pWorldMap:getCellDataByCrood(cp)
    if isCanBuildBastion(cp) and user.centerBuild.def.level > 4 then
        if (user.Cross_Sever_Status == mCross_Sever and celldata.origin == 1) then
            self.Button_bastion:setBright(false)
            me.Helper:grayImageView(me.assignWidget(self, "ico"))
            self.Button_bastion.state = "disable"
            self.strong_num = me.assignWidget(self, "border_num"):setVisible(true)
            self.strong_num:setString("空城上无法建造据点")
        else
            self.Button_bastion.state = "enable"
            local pHavenum = 0
            for key, var in pairs(gameMap.bastionData) do
                pHavenum = pHavenum + 1
            end
            self.strong_num = me.assignWidget(self, "border_num"):setVisible(true)
            self.strong_num:setString("(" .. pHavenum .. "/" .. user.centerBuild.def.extValue.city .. ")")
        end
    else
        self.Button_bastion:setBright(false)
        me.Helper:grayImageView(me.assignWidget(self, "ico"))
        self.Button_bastion.state = "disable"
        self.strong_num = me.assignWidget(self, "border_num"):setVisible(true)
        self.strong_num:setString("主城5级开启")
    end
    local btn_icon = me.assignWidget(self, "ico1")
    btn_icon:loadTexture(buildIcon(user.centerBuild:getDef()), me.localType)

    local btn_icon1 = me.assignWidget(self, "ico")
    btn_icon1:loadTexture("fortImg.png", me.localType)
    me.assignWidget(self, "Text_not_factor"):setVisible(false)
    me.assignWidget(self, "Text_free"):setVisible(false)
    me.assignWidget(self, "Image_diamond"):setVisible(false)
    me.assignWidget(self, "Image_prop"):setVisible(false)
    me.setButtonDisable(self.Button_Move,true)
    if isGrid(cp) or(user.Cross_Sever_Status == mCross_Sever and celldata.origin == 1) then
        if user.Cross_Sever_Status == mCross_Sever then
            if celldata.origin == 1 then
                if user.movecity_canable == true and me.sysTime() - user.movecity_st < user.movecity_cd and user.movecity_num < 1 then
                    self.Button_Move.state = "enable"                 
                     if self:getProp() then
                        me.assignWidget(self, "Image_prop"):setVisible(true)
                    else
                        me.assignWidget(self, "Text_free"):setVisible(true)
                        me.assignWidget(self, "Image_diamond"):setVisible(false)
                    end
                else
                    self.Button_Move.state = "disable"
                    me.assignWidget(self, "Text_not_factor"):setVisible(true)
                    self.Button_Move:setBright(false)
                    me.Helper:grayImageView(me.assignWidget(self, "ico1"))
                    me.setButtonDisable(self.Button_Move,false)
                end
            else
                self.Button_Move.state = "disable"
                me.assignWidget(self, "Text_not_factor"):setVisible(true)
                self.Button_Move:setBright(false)
                me.Helper:grayImageView(me.assignWidget(self, "ico1"))
            end
        else
            self.Button_Move.state = "enable"
            if user.movecity > 1 then
                if self:getProp() then
                    me.assignWidget(self, "Image_prop"):setVisible(true)
                else
                    local pNum =(user.movecity - 2) * 500 + 500
                    me.assignWidget(self, "Image_diamond"):setVisible(true)
                    me.assignWidget(self, "Text_3"):setString("x" .. pNum)
                    me.assignWidget(self, "Text_free"):setVisible(false)
                end
            else
                me.assignWidget(self, "Text_free"):setVisible(true)
                me.assignWidget(self, "Image_diamond"):setVisible(false)
            end
        end

    else
        self.Button_Move:setBright(false)
        me.Helper:grayImageView(me.assignWidget(self, "ico1"))
        self.Button_Move.state = "disable"
        me.assignWidget(self, "Text_not_factor"):setVisible(true)

    end
end
function fortLayer:getProp()
    local pUse = user.pkg
    for key, var in pairs(pUse) do
        local def = var:getDef()
        if me.toNum(def.id) == 69 then
            return true
        end
    end
    return false
end
function fortLayer:onEnterTransitionDidFinish()
    print("fortLayer onEnterTransitionDidFinish")
end
function fortLayer:onExit()
    print("fortLayer onExit")
end
function fortLayer:close()
    self:removeFromParentAndCleanup(true)
end
