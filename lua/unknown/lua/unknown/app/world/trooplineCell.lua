trooplineCell = class("trooplineCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
trooplineCell.__index = trooplineCell
function trooplineCell:create(...)
    local layer = trooplineCell.new(...)
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
function trooplineCell:ctor()

end
function trooplineCell:init()
    return true
end
function trooplineCell:setData(pData, idx)
    if pData then
        -- dump(pData)
        me.clearTimer(self.pTime)
        self.time = pData["countdown"]
        -- 剩余时间
        self.pTotalTime = pData["time"]
        -- 总时间
        -- 时间
        self.timeLabel = me.assignWidget(self, "troopline_time")
        self.timeLabel:setString(me.formartSecTime(self.time))
        -- 进度条
        self.LoadingBar = me.assignWidget(self, "LoadingBar_Time")
        self.LoadingBar:setVisible(true)
        if pData["m_Status"] == EXPED_STATE_COLLECTING then
            self.LoadingBar:loadTexture("waicheng_biejing_jiasu_tiao_lv.png", me.localType)
        else
            self.LoadingBar:loadTexture("waicheng_biejing_jiasu_tiao.png", me.localType)
        end
        local pIcon = me.assignWidget(self, "troopline_icon")
        local pPointX = pData["m_Paths"]["tag"]["x"]
        local pPointY = pData["m_Paths"]["tag"]["y"]
        local Button_Farter = me.assignWidget(self, "Button_Farter")
        Button_Farter:setVisible(true)
        Button_Farter:loadTextureNormal("troop_backBtn.png", me.localType)
        me.assignWidget(self, "converge_type"):setVisible(false)
        me.assignWidget(self, "defener_type"):setVisible(false)
        -- Button_Farter:setTitleText("召回")
        local Text_2 = me.assignWidget(self, "Text_2"):setVisible(true)
        me.assignWidget(self, "Coordinate_X"):setVisible(true)
        me.assignWidget(self, "Coordinate_Y"):setVisible(true)
        me.assignWidget(self, "troopline_time"):setVisible(true)
        pIcon:setVisible(true)
        local Queuetag = me.assignWidget(self, "Queuetag"):setVisible(true)
        me.assignWidget(self, "Image_1"):setVisible(true)
        Queuetag:setString(pData.queueTag)
        if pData.queueTag == -1 then
            Queuetag:setVisible(false)
            me.assignWidget(self, "Image_1"):setVisible(false)
        end
        if pData["m_Status"] == EXPED_STATE_COLLECTING then
            pIcon:loadTexture("troop_state_27.png", me.localType)
            pPointX = pData["m_OriPoint"]["x"]
            pPointY = pData["m_OriPoint"]["y"]
            me.assignWidget(self, "Text_2"):setVisible(false)
            local pCoordinateX = me.assignWidget(self, "Coordinate_X")
            pCoordinateX:setPosition(cc.p(Text_2:getPositionX(), pCoordinateX:getPositionY()))
            local pCorrdinateY = me.assignWidget(self, "Coordinate_Y")
            pCorrdinateY:setPosition(cc.p(Text_2:getPositionX() + 40, pCorrdinateY:getPositionY()))
        elseif pData["m_Status"] == EXPED_STATE_STATIONED then
            pIcon:loadTexture("troop_state_29.png", me.localType)
            pPointX = pData["m_OriPoint"]["x"]
            pPointY = pData["m_OriPoint"]["y"]
            me.assignWidget(self, "Text_2"):setVisible(false)
            local pCoordinateX = me.assignWidget(self, "Coordinate_X")
            pCoordinateX:setPosition(cc.p(Text_2:getPositionX(), pCoordinateX:getPositionY()))
            local pCorrdinateY = me.assignWidget(self, "Coordinate_Y")
            pCorrdinateY:setPosition(cc.p(Text_2:getPositionX() + 40, pCorrdinateY:getPositionY()))
        elseif pData["m_Status"] == EXPED_STATE_OCC  or pData["m_Status"] == EXPEND_STATE_PLUNDER or pData["m_Status"] == EXPED_STATE_MOBILIZE or pData["m_Status"] == EXPED_STATE_STATION or pData["m_Status"] == HERO_EXPER or pData["m_Status"] == 84 then
            pIcon:loadTexture("troop_state_33.png", me.localType)
        elseif pData["m_Status"] == EXPED_STATE_PILLAGE then
            pIcon:loadTexture("troop_state_31.png", me.localType)
        elseif pData["m_Status"] == EXPED_STATE_ARCH then
            pIcon:loadTexture("troop_state_32.png", me.localType)
        elseif pData["m_Status"] == EXPED_STATE_SCOUT then
            pIcon:loadTexture("troop_state_50.png", me.localType)
        elseif pData["m_Status"] == EXPED_STATE_ARCHING then
            pIcon:loadTexture("troop_state_32.png", me.localType)
            pPointX = pData["m_OriPoint"]["x"]
            pPointY = pData["m_OriPoint"]["y"]
            me.assignWidget(self, "Text_2"):setVisible(false)
            local pCoordinateX = me.assignWidget(self, "Coordinate_X")
            pCoordinateX:setPosition(cc.p(Text_2:getPositionX(), pCoordinateX:getPositionY()))
            local pCorrdinateY = me.assignWidget(self, "Coordinate_Y")
            pCorrdinateY:setPosition(cc.p(Text_2:getPositionX() + 40, pCorrdinateY:getPositionY()))
        elseif pData["m_Status"] == TEAM_WAIT then
            -- Button_Farter:setTitleText("查看")            
            Button_Farter:loadTextureNormal("btn_chakan.png", me.localType)
            pIcon:loadTexture("troop_state_30.png", me.localType)
            me.assignWidget(self, "Text_2"):setVisible(false)
            me.assignWidget(self, "Coordinate_X"):setVisible(false)
            me.assignWidget(self, "Coordinate_Y"):setVisible(false)
            me.assignWidget(self, "converge_type"):setVisible(true)
        elseif pData["m_Status"] == TEAM_RUN then
            pIcon:loadTexture("troop_state_52.png", me.localType)
            if pData.leader ~= nil then
                if pData["leader"] > 0 then
                    self:setButton(Button_Farter, true)
                else
                    self:setButton(Button_Farter, false)
                end
            end
        elseif pData["m_Status"] == THRONE_DEFEND or pData["m_Status"] == THRONE_TEAM_RUN then
            -- 走新的召回协议
            -- Button_Farter:setTitleText("召回")
            
            Button_Farter:loadTextureNormal("troop_backBtn.png", me.localType)
            pIcon:loadTexture("troop_state_28.png", me.localType)
            if pData.leader ~= nil then
                if pData["leader"] > 0 then
                    self:setButton(Button_Farter, true)
                else
                    self:setButton(Button_Farter, false)
                end
            end
        elseif pData["m_Status"] == EXPED_STATE_BACKHOME then
            -- 回城的立即召回
            Button_Farter:loadTextureNormal("troop_quickBtn.png", me.localType)
            pIcon:loadTexture("troop_state_28.png", me.localType)
        elseif pData["m_Status"] == TEAM_ARMY_JOIN or pData["m_Status"] == THRONE_TEAM_JOIN then         
            pIcon:loadTexture("troop_state_51.png", me.localType)
            self:setButton(Button_Farter, false)
        elseif pData["m_Status"] == TEAM_ARMY_WAIT or pData["m_Status"] == THRONE_TEAM_WAIT then
            -- Button_Farter:setTitleText("查看")
            Button_Farter:loadTextureNormal("btn_chakan.png", me.localType)
            pIcon:loadTexture("troop_state_30.png", me.localType)
            me.assignWidget(self, "Text_2"):setVisible(false)
            me.assignWidget(self, "Coordinate_X"):setVisible(false)
            me.assignWidget(self, "Coordinate_Y"):setVisible(false)
            me.assignWidget(self, "converge_type"):setVisible(true)
        elseif pData["m_Status"] == TEAM_ARMY_DEFENS then
            pIcon:loadTexture("troop_state_53.png", me.localType)
            -- Button_Farter:setTitleText("召回")
            self:setButton(Button_Farter, true)
            Button_Farter:loadTextureNormal("troop_backBtn.png", me.localType)
        elseif pData["m_Status"] == TEAM_ARMY_DEFENS_WAIT then
            -- Button_Farter:setTitleText("召回")
            pIcon:loadTexture("troop_state_54.png", me.localType)
            Button_Farter:loadTextureNormal("troop_backBtn.png", me.localType)
            self:setButton(Button_Farter, true)
            me.assignWidget(self, "Text_2"):setVisible(false)
            me.assignWidget(self, "defener_type"):setVisible(true)
            me.assignWidget(self, "Coordinate_X"):setVisible(false)
            me.assignWidget(self, "Coordinate_Y"):setVisible(false)
            me.assignWidget(self, "converge_type"):setVisible(false)
            me.assignWidget(self, "troopline_time"):setVisible(false)
        end
        --        dump(pData)
        if pData["m_Status"] == EXPED_STATE_ARCHING or pData["m_Status"] == EXPED_STATE_COLLECTING or pData["m_Status"] == EXPED_STATE_STATIONED or pData["m_Status"] == THRONE_DEFEND then
            self.LoadingBar:setPercent(100)
            self.pTime = me.registTimer(-1, function(dt)
                if self.time == 0 then
                    me.clearTimer(self.pTime)
                end
                self.time = self.time - 1
                self.timeLabel:setString(me.formartSecTime(self.time))
                self.LoadingBar:setPercent(100)
            end , 1)
        elseif pData["m_Status"] == TEAM_ARMY_DEFENS_WAIT then
            self.LoadingBar:setPercent(100)
        else
            self.LoadingBar:setPercent(100 -(self.time / self.pTotalTime * 100))
            self.pTime = me.registTimer(-1, function(dt)
                if self.time == 0 then
                    me.clearTimer(self.pTime)
                end
                self.time = self.time - 1
                self.timeLabel:setString(me.formartSecTime(self.time))
                self.LoadingBar:setPercent(100 -(self.time / self.pTotalTime * 100))
            end , 1)
        end
        local pX = me.assignWidget(self, "Coordinate_X")
        pX:setString("X:" .. pPointX)
        local pY = me.assignWidget(self, "Coordinate_Y")
        pY:setString("Y:" .. pPointY)
        pY:setPositionX(pX:getContentSize().width+pX:getPositionX()+2)
        if pData["m_Status"] == EXPED_STATE_BACKHOME then
            Button_Farter:setVisible(true)
        end
        if pData["m_Status"] ~= EXPED_STATE_BACKHOME then
    
            me.registGuiClickEvent(Button_Farter, function(node)            
                if pData then
                    if pData["m_Status"] == TEAM_WAIT or pData["m_Status"] == TEAM_ARMY_WAIT or pData["m_Status"] == THRONE_TEAM_WAIT then
                        GMan():send(_MSG.worldTeamArmyInfo(pData["teamUid"]))
                    elseif pData["m_Status"] == TEAM_RUN or pData["m_Status"] == THRONE_TEAM_RUN then
                        -- 高级召回
                        pWorldMap.av = armyCallBackView:create("ArmyCallBackView.csb")                       
                        local function cb(userDiamond)
                            GMan():send(_MSG.worldTeamcallbackArmy(pData["m_TroopId"], userDiamond))
                        end
                        pWorldMap.av:setCurrentData(pData["m_TroopId"], 71, cb)
                        pWorldMap:addChild(pWorldMap.av)
                    else
                        -- 普通召回
                        if pData["m_Status"] ~= TEAM_ARMY_JOIN and pData["m_Status"] ~= THRONE_TEAM_JOIN then
                            me.showMessageDialog("确定要召回这只部队吗", function(node)
                                if node == "ok" then                                   
                                    if pData["m_Status"] == THRONE_DEFEND then
                                        GMan():send(_MSG.worldTeamcallbackArmy(pData["m_TroopId"]))
                                    else
                                        GMan():send(_MSG.callbackArmy(pData["m_TroopId"]))
                                    end
                                end
                            end )
                        end

                    end
                end
            end )
            Button_Farter:setSwallowTouches(true)
        else
            -- 立即返回
            me.registGuiClickEvent(Button_Farter, function(node)
                local date = os.date("%Y-%m-%d")
                local saveDiamondNotenoughTime = cc.UserDefault:getInstance():getStringForKey("armycallback_MessageDialog", "")
                if saveDiamondNotenoughTime == date then
                    GMan():send(_MSG.worldArmycallbackArmy(pData["m_TroopId"], true))
                    return
                end
                pWorldMap.av = armyCallBackView:create("ArmyCallBackView.csb")
                local function cb(userDiamond)
                    GMan():send(_MSG.worldArmycallbackArmy(pData["m_TroopId"], userDiamond))
                end
                pWorldMap.av:setCurrentData(pData["m_TroopId"], 72, cb)
                pWorldMap:addChild(pWorldMap.av)
            end )
        end
    end
end
function trooplineCell:setButton(button, b)
    button:setBright(b)
    button:setSwallowTouches(b)
    button:setTouchEnabled(b)
    if b then
        button:setTitleColor(me.convert3Color_("#ffffff"))
    else
        button:setTitleColor(me.convert3Color_("#767676"))
    end
end
function trooplineCell:onEnter()
    -- me.doLayout(self,me.winSize)
end
function trooplineCell:onExit()
    me.clearTimer(self.pTime)
end

