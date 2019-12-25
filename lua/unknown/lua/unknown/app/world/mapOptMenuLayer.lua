mapOptMenuLayer = class("mapOptMenuLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
mapOptMenuLayer.__index = mapOptMenuLayer
function mapOptMenuLayer:create(...)
    local layer = mapOptMenuLayer.new(...)
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
function mapOptMenuLayer:ctor()
    self.bmove = false
    -- 当前触发块的ID 由地图坐标系转换而来
    self.cid = nil
    self.infoTexts = { }
    self.infoQueue = Queue.new()
    self.selecetData = nil
    self.contactBtn = nil
    self.mStronghold = nil
    self.pThroneTime = nil
    self.mTeamID = 0
    self.m_PitchFortId = 0
    self.Throne_Point = cc.p(600, 600)
end
function mapOptMenuLayer:init()
    print("mapOptMenuLayer:init()")
    me.assignWidget(self, "fixLayout"):setSwallowTouches(false)
    --[[
    me.registGuiTouchEventByName(self, "fixLayout", function(node, event)
        if event == ccui.TouchEventType.began then
            self.bmove = false
        elseif event == ccui.TouchEventType.moved then
            self.bmove = true
            --self:hide()
            node:setSwallowTouches(false)
        elseif event == ccui.TouchEventType.ended then
            --if not self.bmove then
                self:hide()
                print("11111111111111111111111111111")
                node:setSwallowTouches(false)
            --end
        elseif event == ccui.TouchEventType.canceled then
            self:hide()
            -- node:setSwallowTouches(false)
        end
    end )
    --]]
    self.info = me.assignWidget(self, "info"):setVisible(false)
    self.eventInfo = me.assignWidget(self, "eventInfo"):setVisible(false)
    self.optMenus = me.assignWidget(self, "optMenus")
    self.cellName = me.assignWidget(self, "cellName")
    self.NodePositions = { }
    self.NodePositions["cellName"] = cc.p(self.cellName:getPositionX(), self.cellName:getPositionY())
    self.Text_LordCrood = me.assignWidget(self, "Text_LordCrood")
    self.Button_Sign = me.assignWidget(self, "Button_Sign"):setVisible(false)
    self.Button_Sign_King = me.assignWidget(self, "Button_Sign_King"):setVisible(false)
    self.Button_SignCancel = me.assignWidget(self, "Button_SignCancel")
    self.Button_Lord = me.assignWidget(self, "Button_Lord")
    self.Button_Exile = me.assignWidget(self, "Button_Exile")
    self.Button_ArchBattle = me.assignWidget(self, "Button_ArchBattle")
    self.Button_ArchDef = me.assignWidget(self, "Button_ArchDef")
    self.Button_ArchInfo = me.assignWidget(self, "Button_ArchInfo")
    self.Button_Fort_General = me.assignWidget(self, "Button_Fort_General")
    self.Text_LordTitle = me.assignWidget(self, "Text_LordTitle")
    self.Button_Battle = me.assignWidget(self, "Button_Battle")
    self.Button_Battle_Fort = me.assignWidget(self, "Button_Battle_Fort")
    self.Button_Spy = me.assignWidget(self, "Button_Spy")
    self.Button_Eexplore = me.assignWidget(self, "Button_Eexplore")
    self.Button_Station = me.assignWidget(self, "Button_Station")
    self.Button_Fort = me.assignWidget(self, "Button_Fort")
    self.Button_open_fort_exper = me.assignWidget(self, "Button_open_fort_exper")
    self.Button_open_once = me.assignWidget(self, "Button_open_once")
    self.Button_AttBoss = me.assignWidget(self, "Button_AttBoss")
    self.Button_detail = me.assignWidget(self, "Button_detail")
    self.Button_Back = me.assignWidget(self, "Button_Back")
    self.Button_GiveUp = me.assignWidget(self, "Button_GiveUp")
    self.Button_GiveUpCancel = me.assignWidget(self, "Button_GiveUpCancel")
    self.Button_GiveUp_Fortress = me.assignWidget(self, "Button_GiveUp_Fortress")
    self.Button_GiveUpCancel_Fortress = me.assignWidget(self, "Button_GiveUpCancel_Fortress")
    self.Button_BossMark = me.assignWidget(self, "Button_BossMark")
    self.Button_Medal = me.assignWidget(self, "Button_Medal")
    self.stationInfo = me.assignWidget(self, "stationInfo")
    self.fort_hero_exper_Panel = me.assignWidget(self, "fort_hero_exper_Panel"):setVisible(false)
    self.LoadingBar_Hp = me.assignWidget(self, "LoadingBar_Hp")
    self.Text_Hp = me.assignWidget(self, "Text_Hp")
    self.Button_Mobilize = me.assignWidget(self, "Button_mobilize")
    self.Button_Plunder = me.assignWidget(self, "Button_Plunder")
    -- 调动
    self.Button_Recall = me.assignWidget(self, "Button_recall")
    -- 撤回
    self.Button_Hold_Info = me.assignWidget(self, "Button_hold_Info")
    -- 详情
    self.Throne_Info = me.assignWidget(self, "Throne_Info")
    -- 王座
    self.Button_throne = me.assignWidget(self, "Button_throne")
    -- 跨服退出
    self.Button_Cross_out = me.assignWidget(self, "Button_Cross_out")
    -- 王座集火
    self.Button_arch_throne = me.assignWidget(self, "Button_arch_throne")
    -- 王座占领
    self.Button_occupy = me.assignWidget(self, "Button_occupy")
    -- 策略
    self.Button_strategy = me.assignWidget(self, "Button_strategy")
    -- 王座事件
    self.Button_Throne_event = me.assignWidget(self, "Button_Throne_event")

    self.Cross_Score_rank = me.assignWidget(self, "Cross_Score_rank"):setVisible(false)
    -- 王座集火驻守 跨服
    self.Button_arch_throne_Cross = me.assignWidget(self, "Button_arch_throne_Cross")
    -- 驻守 跨服
    self.Button_occupy_Cross = me.assignWidget(self, "Button_occupy_Cross")
    -- 召唤
    self.Button_zhaohuan = me.assignWidget(self, "Button_zhaohuan")

    me.registGuiClickEvent(self.Button_Sign, function(node)
        self:Button_Sign_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Sign_King, function(node)
        self:Button_Sign_King_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Plunder, function(node)
        self:Button_Plunder_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )

    me.registGuiClickEvent(self.Button_SignCancel, function(node)
        self:Button_SignCancel_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Battle, function(node)
        self:Button_Battle_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Battle_Fort, function(node)
        self:Button_Battle_Fort_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Fort, function(node)
        self:Button_Fort_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_AttBoss, function(node)
        self:Button_AttBoss_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )

    me.registGuiClickEvent(self.Button_detail, function(node)
        local celldata = pWorldMap:getCellDataByCrood(self.cp)
        if celldata then
            local bdata = celldata:getBossData()
            if bdata and bdata.bossType == 7 then
                -- 蛮族军团
                self.promotionView = promotionView:create("promotionView.csb")
                self.promotionView:setViewTypeID(1)
                self.promotionView:setTaskGuideIndex(ACTIVITY_ID_RESIST_INVASION_NEW)
                self:addChild(self.promotionView, me.MAXZORDER)
                me.showLayer(self.promotionView, "bg_frame")
            end
        end
        me.setWidgetCanTouchDelay(node, 0.5)
    end )

    me.registGuiClickEvent(self.Button_Spy, function(node)
        self:Button_Spy_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Medal, function(node)
        -- 击杀端午守军
        self:Button_Medal_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_BossMark, function(node)
        local count = 0
        for key, var in pairs(user.pkg) do
            if var.defid == 558 then
                -- 年兽令。
                count = var.count
            end
        end
        if count >= 1 then
            NetMan:send(_MSG.markBoss(self.cp.x, self.cp.y))
            self:hide()
        else
            showTips("道具不足")
        end
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Station, function(node)
        self:Button_Station_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Eexplore, function(node)
        if me.assignWidget(self.Button_Eexplore, "Text_EexploreTitle"):getString() == TID_ARCH then
            self:Button_Arch_callback(node)
        else
            self:Button_Eexplore_callback(node)
        end
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Back, function(node)

        GMan():send(_MSG.callbackArmy(node.tid))
        self:hide()
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_Lord, function(node)
        self:hide()
        pWorldMap:cloudClose( function(args)
            pWorldMap:goCityView()
        end )
        -- 跨服请求测试
        -- getNetBattleDataMsg
    end )
    -- 要塞试炼
    me.registGuiClickEvent(self.Button_open_fort_exper, function(node)
        print("要塞试炼")
        self:Button_Fort_Exper_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    me.registGuiClickEvent(self.Button_open_once, function(node)
        local pData = user.fortheroRankList
        local pHeroConfig = cfg[CfgType.HERO][pData["heroid"]]
        local pStr = "是否花费" .. pHeroConfig["coldtimeprice"] .. "钻石清除冷却时间"
        me.showMessageDialog(pStr, function(args)
            if args == "ok" then
                if user.diamond >= pHeroConfig["coldtimeprice"] then
                    NetMan:send(_MSG.worldfortcleartime(pHeroConfig["herotype"]))
                else
                    showTips("钻石不足")
                end

            end
        end )
    end )
    me.registGuiClickEvent(self.Button_Fort_General, function(node)
        print("名将要塞")
        self:hide()
        pWorldMap:setFortHero()
        pWorldMap:setPitchFortPoint(self.m_PitchFortId)
        NetMan:send(_MSG.worldfortherogeneral())
    end )
    me.registGuiClickEvent(self.Button_ArchBattle, function(node)
        self:hide()
        if CaptiveMgr:isCaptured() then
            showTips("沦陷中无法发起集火")
        else
            pWorldMap:setConvergeAidPoint(self.cp)
            local celldata = pWorldMap:getCellDataByCrood(self.cp)
            if celldata then
                local ldata = celldata:getOwnerData()
                if ldata and not ldata:isCaptived() then
                    if not ldata:isProtected() then
                        self.convergeTime = convergeTime:create("convergeTime.csb")
                        self.convergeTime:setPoint(self.cp, TEAM_WAIT)
                        pWorldMap:addChild(self.convergeTime, me.MAXZORDER)
                    else
                        showTips("坚守或新手保护中不能被集火")
                    end
                else
                    showTips("沦陷中不能被集火")
                end
            end
        end
        print("盟战集火")
    end )
    me.registGuiClickEvent(self.Button_ArchDef, function(node)
        self:hide()
        print("盟战援助")
        pWorldMap:setConvergeAidPoint(self.cp)
        local celldata = pWorldMap:getCellDataByCrood(self.cp)
        if celldata then
            local ldata = celldata:getOwnerData()
            if ldata then
                GMan():send(_MSG.worldTeamCityTeam(ldata.uid))
            end
        end
        -- pWorldMap:showconverge(cc.p(user.x, user.y),cc.p(self.cp.x, self.cp.y),TEAM_ARMY_DEFENS,0,0)
    end )
    me.registGuiClickEvent(self.Button_ArchInfo, function(node)
        self:hide()
        print("盟战查看援军")
        GMan():send(_MSG.worldTeamArmyDetail(self.mTeamID))
    end )
    me.registGuiClickEvent(self.Button_GiveUp, function(node)
        me.showMessageDialog("主人，你是否要放弃当前土地?", function(args)
            if args == "ok" then
                local tag = me.converCoordbyId(self.cid)
                GMan():send(_MSG.dropPoint(tag.x, tag.y))
                self:hide()
            end
        end )
        me.setWidgetCanTouchDelay(node, 0.5)
    end )

    me.registGuiClickEvent(self.Button_Exile, function(node)
        local pNode = exilePrompt:create("ExilePrompt.csb", 1, self.cp)
        me.runningScene():addChild(pNode, me.MAXZORDER)
        me.showLayer(pNode, "bg")
    end )
    me.registGuiClickEvent(self.Button_GiveUp_Fortress, function(node)
        if user.familyDegree and(user.familyDegree == 1 or user.familyDegree == 2) then
            -- 盟主和副盟主
            me.showMessageDialog("主人，你是否要放弃当前要塞?", function(args)
                if args == "ok" then
                    local mdata = gameMap.mapCellDatas[self.cid]
                    local fid = mdata:getFortId()
                    local tag = me.getCoordByFortId(fid)
                    GMan():send(_MSG.world_fortress_giveup(tag.x, tag.y))
                    self:hide()
                end
            end )
            me.setWidgetCanTouchDelay(node, 0.5)
        else
            showTips("只有盟主和副盟主才有此权限")
        end
    end )
    me.registGuiClickEvent(self.Button_GiveUpCancel_Fortress, function(node)
        if user.familyDegree and(user.familyDegree == 1 or user.familyDegree == 2) then
            local mdata = gameMap.mapCellDatas[self.cid]
            local fid = mdata:getFortId()
            local tag = me.getCoordByFortId(fid)
            GMan():send(_MSG.world_fortress_giveup_cancel(tag.x, tag.y))
            self:hide()
            me.setWidgetCanTouchDelay(node, 0.5)
        else
            showTips("只有盟主和副盟主才有此权限")
        end
    end )
    me.registGuiClickEvent(self.Button_GiveUpCancel, function(node)
        local tag = me.converCoordbyId(self.cid)
        GMan():send(_MSG.cancelDropPoint(tag.x, tag.y))
        self:hide()
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    -- 调动
    me.registGuiClickEvent(self.Button_Mobilize, function(node)
        self.StongHoldList = strongholdlist:create("strongholdtransfer.csb")
        self.StongHoldList:setCpData(self.cp, EXPED_STATE_MOBILIZE, self.mStronghold)
        pWorldMap:addChild(self.StongHoldList, me.MAXZORDER)
        self:hide()
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    -- 撤回
    me.registGuiClickEvent(self.Button_Recall, function(node)
        if self.mStronghold ~= nil then
            dump(self.mStronghold)
            local army = self.mStronghold:getarmydata()
            --  local pArmy = pStrongHoldData:getarmydata()
            pWorldMap:showMobilize(self.mStronghold.pos, cc.p(user.x, user.y), STRONG_ARMY_RETURN, army, self.mStronghold, strongholdlist.STONGHOLD, nil)
        end
        self:hide()
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    -- 据点详情
    me.registGuiClickEvent(self.Button_Hold_Info, function(node)
        print("me.registGuiClickEvent(self.Button_Hold_Info, function(node)")
        --        dump(self.cid)
        --        dump(self.mStronghold)
        local mdata = gameMap.mapCellDatas[self.cid]
        --        dump(mdata)
        if self.mStronghold ~= nil or mdata ~= nil then
            self.shDetailView = strongHoldDetailView.create("stronghold/StrongholdDetailLayer.csb")
            self.shDetailView:initWithBaseData(self.mStronghold, mdata)
            pWorldMap:addChild(self.shDetailView, me.MAXZORDER)
            me.setWidgetCanTouchDelay(node, 0.5)
        end
        self:hide()
    end )
    -- 王座集火
    me.registGuiClickEvent(self.Button_arch_throne, function(node)
        self:hide()
        if CaptiveMgr:isCaptured() then
            showTips("沦陷中无法发起集火")
        else
            pWorldMap:setConvergeAidPoint(self.cp)
            local celldata = pWorldMap:getCellDataByCrood(self.cp)
            if celldata then
                self.convergeTime = convergeTime:create("convergeTime.csb")
                self.convergeTime:setPoint(self.Throne_Point, THRONE_TEAM_WAIT)
                pWorldMap:addChild(self.convergeTime, me.MAXZORDER)
            end
        end
        print("盟战集火")
    end )
    -- 王座集火 跨服
    me.registGuiClickEvent(self.Button_arch_throne_Cross, function(node)
        self:hide()
        if CaptiveMgr:isCaptured() then
            showTips("沦陷中无法发起集火")
        else
            pWorldMap:setConvergeAidPoint(self.cp)
            local celldata = pWorldMap:getCellDataByCrood(self.cp)
            if celldata then
                self.convergeTime = convergeTime:create("convergeTime.csb")
                self.convergeTime:setPoint(self.Throne_Point, THRONE_TEAM_WAIT)
                pWorldMap:addChild(self.convergeTime, me.MAXZORDER)
            end
        end
        print("盟战集火")
    end )
    -- 王座单人出征 跨服
    me.registGuiClickEvent(self.Button_occupy_Cross, function(node)
        self:Button_occupy_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    -- 王座单人出征
    me.registGuiClickEvent(self.Button_occupy, function(node)
        self:Button_occupy_callback(node)
        me.setWidgetCanTouchDelay(node, 0.5)
    end )
    -- 策略
    me.registGuiClickEvent(self.Button_strategy, function(node)
        self:hide()
        NetMan:send(_MSG.worldthronestartegy())
    end )
    -- 王座
    me.registGuiClickEvent(self.Button_throne, function(node)
        self:hide()
        --        if user.throne_create.Thronr_type == 3 then
        --            if pWorldMap.kmv == nil then
        --                pWorldMap.kmv = kingdomMainView:create("kingdomMainView.csb")
        --                pWorldMap:addChild(pWorldMap.kmv,me.MAXZORDER)
        --                me.showLayer(pWorldMap.kmv,"fixLayout")
        --            end
        --        else
        --            NetMan:send(_MSG.worldthronemorle())
        --        end
        if CaptiveMgr:isCaptured() and user.Cross_Sever_Status == mCross_Sever then
            GMan():send(_MSG.Cross_Sever_onExit())
        else
            if pWorldMap.kmv == nil then
                pWorldMap.kmv = kingdomMainView:create("kingdomMainView.csb")
                pWorldMap:addChild(pWorldMap.kmv, me.MAXZORDER)
                me.showLayer(pWorldMap.kmv, "fixLayout")
            end
        end
    end )
    me.registGuiClickEvent(self.Button_Cross_out, function(node)
        self:hide()
        if CaptiveMgr:isCaptured() and user.Cross_Sever_Status == mCross_Sever then
            GMan():send(_MSG.Cross_Sever_onExit())
        end
    end )
    -- 商队召唤道具
    me.registGuiClickEvent(self.Button_zhaohuan, function(node)
        NetMan:send(_MSG.mapZhaohuan(self.cp.x, self.cp.y, 268))
        self:hide()
        me.setWidgetCanTouchDelay(node, 0.5)
    end )

    me.assignWidget(self.Button_Battle_Fort, "Text_BattleFortTitle"):setString(TID_BATTLE)
    self.Panel_Reward = me.assignWidget(self.eventInfo, "Panel_Reward")
    self.Image_Hp = me.assignWidget(self, "Image_Hp")
    return true
end
function mapOptMenuLayer:ThroneInfo()
    local w = 310
    local h = 40
    local sp = me.convertToScreenCoord(tmxMap, self.cp)
    local pThroneData = user.throne_create
    pos = cc.pAdd(sp, cc.p(tmxMap:getPositionX(), tmxMap:getPositionY()))
    self.Throne_Info:setVisible(true)
    self.Throne_Info:setPosition(cc.p(pos.x - w / 2 - self.fort_hero_exper_Panel:getContentSize().width / 2, pos.y - h / 2))
    -- 王座
    self.Button_throne:setVisible(true)
    -- 王座集火
    self.Button_arch_throne:setVisible(true)
    -- 王座占领
    self.Button_occupy:setVisible(true)
    -- 策略
    self.Button_strategy:setVisible(true)

    -- 王座事件
    me.registGuiClickEvent(self.Button_Throne_event, function(node)
        self:hide()
        NetMan:send(_MSG.worldthroneinit())
    end )
    --     dump(pThroneData)
    local throne_Occupy = me.assignWidget(self, "throne_Occupy_Text_20")
    local throne_Occupy_name = me.assignWidget(self, "throne_Occupy_name")
    local LoadingBar_maral = me.assignWidget(self, "LoadingBar_maral")
    -- 民心
    local Panel_king = me.assignWidget(self, "Panel_king")
    local Panel_occupy = me.assignWidget(self, "Panel_occupy")
    if pThroneData.Thronr_type == 1 then
        -- 争夺中
        throne_Occupy:setString("争夺中")
        Panel_king:setVisible(false)
        Panel_occupy:setVisible(true)
        if pThroneData.FamilyName == "" then
            throne_Occupy_name:setString("无联盟占领")
        else
            throne_Occupy_name:setString("[" .. pThroneData.FamilyShorName .. "]" .. pThroneData.FamilyName)
        end
        for key, var in pairs(pThroneData.Steategy) do
            local LoadingBar_attck = me.assignWidget(self, "LoadingBar_attck_" .. var.id)
            local pTotalNum = cfg[CfgType.THRONE_STRATEGY][var.id]["schedule"]
            LoadingBar_attck:setPercent(var.curs / pTotalNum * 100)
        end
        LoadingBar_maral:setPercent(pThroneData.PeopleHeart / pThroneData.PeopleHeartM * 100)
    elseif pThroneData.Thronr_type == 2 then
        -- 占领中
        throne_Occupy:setString("占领中")
        throne_Occupy_name:setVisible(true)
        if pThroneData.FamilyName == "" then
            throne_Occupy_name:setString("无联盟占领")
        else
            throne_Occupy_name:setString("[" .. pThroneData.FamilyShorName .. "]" .. pThroneData.FamilyName)
        end
        --   throne_Occupy_name:setString("["..pThroneData.FamilyShorName.."]" ..pThroneData.FamilyName)
        Panel_king:setVisible(false)
        Panel_occupy:setVisible(true)
        for key, var in pairs(pThroneData.Steategy) do
            local LoadingBar_attck = me.assignWidget(self, "LoadingBar_attck_" .. var.id)
            local pTotalNum = cfg[CfgType.THRONE_STRATEGY][var.id]["schedule"]
            LoadingBar_attck:setPercent(var.curs / pTotalNum * 100)
        end
        LoadingBar_maral:setPercent(pThroneData.PeopleHeart / pThroneData.PeopleHeartM * 100)
    elseif pThroneData.Thronr_type == 3 then
        -- 被占领中 有国王
        Panel_king:setVisible(true)
        Panel_occupy:setVisible(false)
        local throne_king_name = me.assignWidget(self, "throne_king_name")
        throne_king_name:setString("[" .. pThroneData.FamilyShorName .. "]" .. pThroneData.KingName)
        local throne_king_declaration = me.assignWidget(self, "throne_king_declaration")
        throne_king_declaration:setString(pThroneData.ThroneKingdecl)
        local pTotalTime = pThroneData.ThroneKingTerm / 1000
        local Throne_dount_down = me.assignWidget(self, "Throne_dount_down")
        Throne_dount_down:setString(me.formartSecTime(pTotalTime))
        if self.pThroneTime ~= nil then
            me.clearTimer(self.pThroneTime)
        end
        self.pThroneTime = me.registTimer(-1, function(dt)
            if pTotalTime > 1 then
                pTotalTime = pTotalTime - 1
                Throne_dount_down:setString(me.formartSecTime(pTotalTime))
            else
                self:hide()
                NetMan:send(_MSG.worldthronecreate())
            end
        end , 1)
    end
end
function mapOptMenuLayer:CrossThroneInfo(celldata)
    if CaptiveMgr:isCaptured() and user.Cross_Sever_Status == mCross_Sever then
        self.Button_Cross_out:setVisible(true)
    else
        self.Button_Cross_out:setVisible(false)
    end
    if celldata and celldata.occState == OCC_STATE_ALLIED then
        -- 自己的王座
        -- 王座集火驻守 跨服
        self.Button_arch_throne_Cross:setVisible(true)
        -- 驻守 跨服
        self.Button_occupy_Cross:setVisible(true)
    elseif celldata and celldata.occState == OCC_STATE_HOSTILE then
        -- 敌对的王座
        -- 王座集火
        self.Button_arch_throne:setVisible(true)
        -- 王座占领
        self.Button_occupy:setVisible(true)
    end
    if user.Cross_Sever_Status == mCross_Sever then
        -- 跨服地图，都可标记国王目标
        self.Button_Sign_King:setVisible(true)
    end
end
function mapOptMenuLayer:CrossScoreRank()
    self.Cross_Score_rank:setVisible(true)
    me.assignWidget(self, "Panel_3"):removeAllChildren()
    local iNum = #user.CrossScoreRank

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 270, 24
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local rank_cell = me.assignWidget(self, "Panel_cell"):clone():setVisible(true)
            self:RankCell(rank_cell, user.CrossScoreRank[idx + 1], idx + 1)
            rank_cell:setAnchorPoint(cc.p(0, 0))
            rank_cell:setPosition(cc.p(0, 0))
            cell:addChild(rank_cell)
        else
            local rank_cell = me.assignWidget(cell, "Panel_cell")
            self:RankCell(rank_cell, user.CrossScoreRank[idx + 1], idx + 1)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(270, 276))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(0, 10)
    tableView:setDelegate()
    me.assignWidget(self, "Panel_3"):addChild(tableView):setVisible(true)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end
function mapOptMenuLayer:RankCell(node, data, index)
    if data then
        local cell_rank = me.assignWidget(node, "cell_rank")
        cell_rank:setString(me.toStr(index))
        local R_cell_Sever_name = me.assignWidget(node, "cell_name")
        R_cell_Sever_name:setString(data.rname .. "(" .. data.Severid .. "区)")
        R_cell_Sever_name:setString(data.rname)
        -- R_cell_Sever_name:setVisible(false)
        local R_cell_Score = me.assignWidget(node, "cell_score")
        R_cell_Score:setString(data.score)
        if data.rname == user.name then
            cell_rank:setTextColor(me.convert3Color_("#FAFF6A"))
            R_cell_Sever_name:setTextColor(me.convert3Color_("#FAFF6A"))
            R_cell_Score:setTextColor(me.convert3Color_("#FAFF6A"))
        else
            cell_rank:setTextColor(me.convert3Color_("#FFFFFF"))
            R_cell_Sever_name:setTextColor(me.convert3Color_("#FFFFFF"))
            R_cell_Score:setTextColor(me.convert3Color_("#FFFFFF"))
        end
    end
end
function mapOptMenuLayer:initFortHeroRank(pos)
    local pData = user.fortheroRankList
    if pData then
        if self.pExperTime ~= nil then
            me.clearTimer(self.pExperTime)
            self.pExperTime = nil
        end

        local pHeroConfig = cfg[CfgType.HERO][pData["heroid"]]
        local pHeroName = me.assignWidget(self, "exper_hero_name")
        pHeroName:setString(pHeroConfig["name"])

        local pAmicaNum = pData["surplusBlood"] / pHeroConfig["hp"] * 100

        local pLoadingamicable = me.assignWidget(self, "LoadingBar_Blood_num")
        pLoadingamicable:setPercent(pAmicaNum)

        local pSurplusNum = me.assignWidget(self, "exper_surplus")
        pSurplusNum:setString(pData["SurplusNum"])

        local hp_num = me.assignWidget(self, "hp_num")
        hp_num:setString(pData["surplusBlood"])

        local pOnce_time = me.assignWidget(self, "once_time")

        local pExperTime = me.assignWidget(self, "exper_count_time")
        local pCountTime = pData["CountTime"] / 1000
        pExperTime:setString(me.formartSecTime(pCountTime))
        local pCountExperTime = pData["CountExperTime"] / 1000
        pOnce_time:setString(me.formartSecTime(pCountExperTime))
        local pCountExperBool = true
        if pCountExperTime == 0 then
            pCountExperBool = false
        end
        self.pExperTime = me.registTimer(pCountTime, function(dt)
            if pCountTime > 0 then
                pCountTime = pCountTime - 1
                pExperTime:setString(me.formartSecTime(pCountTime))
                if pCountExperBool then
                    if pCountExperTime > 1 then
                        me.assignWidget(self, "Image_10"):setVisible(true)
                        pCountExperTime = pCountExperTime - 1
                        pOnce_time:setString(me.formartSecTime(pCountExperTime))
                    else
                        self:hide()
                        me.clearTimer(self.pExperTime)
                        local pPoint = me.getCoordByFortId(self.m_PitchFortId)
                        NetMan:send(_MSG.worldfortherorankgeneral(pPoint))
                        me.assignWidget(self, "Image_10"):setVisible(false)
                    end
                end
            else
                me.clearTimer(self.pExperTime)
                self.pExperTime = nil
            end
        end , 1)
        local w = 310
        local h = 130
        self.fort_hero_exper_Panel:setVisible(true)
        pos = cc.pAdd(pos, cc.p(tmxMap:getPositionX(), tmxMap:getPositionY()))
        pColor = me.convert3Color_("#F4E9C8")
        local pHeight = 240
        local function setRankCell(var, pHeight, pColor)
            local pRankCell = me.assignWidget(self, "exper_rank_cell"):clone():setVisible(true)
            pRankCell:setPosition(cc.p(0, - pHeight + 240))

            local pRanking = me.assignWidget(pRankCell, "exper_ranking")
            pRanking:setString(var.Ranking)
            pRanking:setTextColor(pColor)

            local pRankName = me.assignWidget(pRankCell, "exper_name")
            pRankName:setString(var.name)
            pRankName:setTextColor(pColor)

            local pRankHt = me.assignWidget(pRankCell, "exper_num")
            pRankHt:setString(var.HurtPercent)
            pRankHt:setTextColor(pColor)

            me.assignWidget(self, "Panel_table"):addChild(pRankCell)
        end
        me.assignWidget(self, "Panel_table"):removeAllChildren()
        if table.maxn(pData.RankList) ~= 0 then
            for key, var in pairs(pData.RankList) do
                setRankCell(var, pHeight, pColor)
                pHeight = pHeight + 30
            end
        end

        if pData.meInfo ~= nil then
            pColor = me.convert3Color_("#EDC666")
            setRankCell(pData.meInfo, pHeight, pColor)
            --   pHeight = pHeight + 30
        end
        self.fort_hero_exper_Panel:setPosition(cc.p(pos.x - w / 2 - self.fort_hero_exper_Panel:getContentSize().width / 2, self.cellName:getPositionY() - self.fort_hero_exper_Panel:getContentSize().height / 2))
        self.info:setVisible(false)
        self.fort_hero_exper_Panel:setSwallowTouches(false)
        local pBg = me.assignWidget(self, "fort_hero_exper")
        pBg:setContentSize(cc.size(328, pHeight))

    end
end
function mapOptMenuLayer:ChoosePoint(tag, pType, bossType)
    local pBoosType = 0
    if bossType then
        pBoosType = bossType
    end
    if table.maxn(gameMap.bastionData) ~= 0 then
        self.StongHoldList = strongholdlist:create("strongholdtransfer.csb")
        self.StongHoldList:setCpData(tag, pType, nil, pBoosType)
        pWorldMap:addChild(self.StongHoldList, me.MAXZORDER)
        self:hide()
    else
        pWorldMap:setWorldArmy(user.soldierData, strongholdlist.CITY, pBoosType)
        GMan():send(_MSG.worldMapPath(user.x, user.y, tag.x, tag.y, pType))
    end

end
function mapOptMenuLayer:adjust(pos)
    local w = 250
    local h = 130
    --pos = cc.pAdd(pos, cc.p(tmxMap:getPositionX(), tmxMap:getPositionY()))
    --self:setPosition(pos.x-me.winSize.width/2, pos.y-me.winSize.height/2)

    pos.x=me.winSize.width/2
    pos.y=me.winSize.height/2
    
    self.cellName:setPosition(cc.p(pos.x, pos.y + self.cellName:getContentSize().height / 2 + h / 2))

    -- self.cellName:getPositionY() - self.cellName:getContentSize().height / 2 - self.info:getContentSize().height / 2
    self.info:setPosition(cc.p(pos.x - w / 2 - self.info:getContentSize().width / 2, pos.y))
    self.eventInfo:setPosition(cc.p(pos.x - w / 2 - self.eventInfo:getContentSize().width / 2, self.cellName:getPositionY() - self.cellName:getContentSize().height / 2 - self.eventInfo:getContentSize().height / 2))
    self.optMenus:setPosition(cc.p(pos.x + w / 2 + self.optMenus:getContentSize().width / 2, self.cellName:getPositionY() + self.cellName:getContentSize().height / 2 - self.optMenus:getContentSize().height / 2))

    self.Button_Sign:setPosition(cc.p(pos.x, pos.y - h / 2 - self.Button_Sign:getContentSize().height / 2))
    self.Button_SignCancel:setPosition(cc.p(pos.x, pos.y - h / 2 - self.Button_SignCancel:getContentSize().height / 2))

    self.Button_GiveUp_Fortress:setPosition(self.Button_Sign:getPositionX(), self.Button_Sign:getPositionY() -80)
    self.Button_GiveUpCancel_Fortress:setPosition(self.Button_Sign:getPositionX(), self.Button_Sign:getPositionY() -80)

    -- self.stationInfo:setPosition(cc.p(self.optMenus:getPositionX() + self.stationInfo:getContentSize().width / 2 + 90,self.optMenus:getPositionY() - 90))
    me.putNodeOnBottom(self.Button_Sign, self.Button_GiveUp, 30, cc.p(0, 2))
    me.putNodeOnBottom(self.Button_Sign, self.Button_GiveUpCancel, 30, cc.p(0, 2))
    if guideHelper.guideIndex == guideHelper.guideConquest + 3 or guideHelper.guideIndex == guideHelper.guideExplore + 2 or guideHelper.guideIndex == guideHelper.guideGoToArch + 2 then
        guideHelper.nextStepByOpt(false, self.Button_Battle, false)
    end
end
function mapOptMenuLayer:getcid()
    return self.cid
end
function mapOptMenuLayer:setcid(cid_)
    self.cid = cid_
end
function mapOptMenuLayer:initTitle(cp)
    self.cellName:setVisible(true)
    local cellType = POINT_NONE
    local celldata = pWorldMap:getCellDataByCrood(cp)
    local titleStr = ""
    local configData = getMapConfigData(cp)
    local showLv = ""
    self.LoadingBar_Hp:setPercent(100)
    self.Text_Hp:setString("100%")
    self.Text_Hp:setVisible(true)
    if celldata then
        -- //该地块已经被占领或者是要塞地块
        cellType = celldata.pointType
        local lordData = celldata:getOwnerData()
        if lordData then
            titleStr = lordData.name
        end
        if cellType == POINT_FBASE or cellType == POINT_FORT then
            local fdata = celldata:getFortDefData()
            titleStr = fdata.name
        elseif cellType == POINT_NORMAL then
            titleStr = configData.name
            showLv = "LV." .. configData.landlv
        end
        if cellType == POINT_FBASE or cellType == POINT_FORT then
            local fdata = celldata:getFortData()
            --            dump(fdata)
            if fdata and fdata.defense and fdata.srcDefense then
                local p = fdata.defense * 100 / fdata.srcDefense
                self.LoadingBar_Hp:setPercent(p)
                self.Text_Hp:setString(fdata.mine == 1 and fdata.defense .. "/" .. fdata.srcDefense or math.ceil(p) .. "%")
            else
                self.LoadingBar_Hp:setPercent(100)
                self.Text_Hp:setString("100%")
            end
        elseif cellType == POINT_NORMAL and celldata:bHaveBoss() then
            local bdata = celldata:getBossData()
            local def = bdata:getDef()
            if def.hp ~= nil and def.hp ~= 0 then
                local p = bdata.bossHp * 100 / def.hp
                self.LoadingBar_Hp:setPercent(p)
                self.Text_Hp:setString(math.ceil(p) .. "%")
                self.Text_Hp:setVisible(true)
                showLv = "LV." .. def.level
            elseif bdata.bossType == 7 then
                -- 蛮族军团
                self.LoadingBar_Hp:setPercent(100)
                self.Text_Hp:setString("100%")
                self.Text_Hp:setVisible(true)
                showLv = ""
            else
                self.Text_Hp:setVisible(false)
                self.LoadingBar_Hp:setPercent(0)
                showLv = "LV." .. def.level
            end
            titleStr = def.name

        elseif (cellType == POINT_THRONE or cellType == POINT_TBASE) and CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            local throneData = celldata:getCrossThroneData()
            if throneData and throneData.cityDefense and throneData.cityMaxDefense then
                titleStr = throneData.name
                if throneData.cityMaxDefense > 0 then
                    local p = throneData.cityDefense * 100 / throneData.cityMaxDefense
                    if p >= 0 and p <= 100 then
                        self.LoadingBar_Hp:setPercent(p)
                        self.Text_Hp:setString(math.ceil(p) .. "%")
                    end
                else
                    self.Text_Hp:setString("????")
                end
            end
        elseif cellType == POINT_STRONG_HOLD then
            --  local strongData = gameMap.bastionData[celldata.strongHoldId]
            local Def = cfg[CfgType.BASTION_DATA][celldata.strongHoldLv]
            if user.Cross_Sever_Status == mCross_Sever then      
                Def = cfg[CfgType.CROSS_STRONG_HOLD][celldata.strongHoldLv] 
            end
            if Def then
                local cityDefense = celldata.strongHoldDef
                local cityMaxDefense = Def.defense
                if cityDefense and cityMaxDefense then
                    local p = cityDefense * 100 / cityMaxDefense
                    if p >= 0 and p <= 100 then
                        self.LoadingBar_Hp:setPercent(p)
                        self.Text_Hp:setString(celldata:getOccState() == OCC_STATE_OWN and cityDefense .. "/" .. cityMaxDefense or math.ceil(p) .. "%")
                    end
                else
                    self.Text_Hp:setString("????")
                end
            end
        elseif cellType == POINT_CITY or cellType == POINT_CBASE then
            if lordData and lordData.cityDefense and lordData.cityMaxDefense then
                if lordData.cityMaxDefense > 0 then
                    local p = lordData.cityDefense * 100 / lordData.cityMaxDefense
                    if p >= 0 and p <= 100 then
                        self.LoadingBar_Hp:setPercent(p)
                        self.Text_Hp:setString(celldata:getOccState() == OCC_STATE_OWN and lordData.cityDefense .. "/" .. lordData.cityMaxDefense or math.ceil(p) .. "%")
                    end
                else
                    self.Text_Hp:setString("????")
                end
            end
        else
        end
    else
        titleStr = configData.name
        showLv = "LV." .. configData.landlv
    end
    self.cellName:removeChildByTag(0xffcc)
    local rcf = mRichText:create("<txt0018,ffffff>" .. titleStr .. "&<txt0018,efec18>" .. showLv .. " &")
    rcf:setTag(0xffcc)
    self.cellName:addChild(rcf)

    me.putNodeOnTop(self.Image_Hp, rcf, 0, cc.p(0, 2))
    self.Text_LordCrood:setString("(" .. cp.x .. "," .. cp.y .. ")")
end

--[[
if cellType == POINT_CITY then --主城
        elseif cellType == POINT_CBASE then --主城区
        elseif cellType == POINT_FBASE then -- 要塞城区
        elseif cellType == POINT_FORT then --要塞
        elseif cellType == POINT_NORMAL then  --普通地块
        elseif cellType == POINT_POST then --驿站
        end
]]
ICON_OPT_FOOD = 1
ICON_OPT_WOOD = 2
ICON_OPT_STONE = 3
ICON_OPT_GLOD = 4
ICON_OPT_TEC = 5
ICON_OPT_ROLE = 6
ICON_OPT_FAM = 7 -- 联盟
CON_OPT_NPC = 8
ICON_OPT_CAPTIVE = 18
local function constructLine()
    return "<img0000,000000>alliance_fenge.png&<txt0018,000000>#n&"
end
local function constructInfoItem(iconId, dec, v)
    return "<img0000,000000>icon_mapopt_" .. iconId .. ".png&<txt0018,f4cb69>" .. (dec or "") .. "&<txt0018,fbefd3>  " ..(v or "") .. "#n&"
end

local function constructCaptiveItem(ldata)
    local pUpFamily = "上级联盟"
    local name = ldata.cityMasterName
    if ldata.masterCamp then
        pUpFamily = "上级区服"
        name = ldata.masterCamp .. ldata.cityMasterName
    end
    return "<img0000,000000>icon_mapopt_" .. ICON_OPT_CAPTIVE .. ".png&<txt0018,f4cb69>" .. pUpFamily .. "&<txt0018,fbefd3>" .. name .. "#n&"
end
local function constructCrossCaptiveItem(cityMasterName, masterCamp)
    local pUpFamily = "上级区服"
    local name = masterCamp .. cityMasterName
    return "<img0000,000000>icon_mapopt_" .. ICON_OPT_CAPTIVE .. ".png&<txt0018,f4cb69>" .. pUpFamily .. "&<txt0018,fbefd3>" .. name .. "#n&"
end

local function constructRoleItem(ldata)
    local def = cfg[CfgType.BUILDING][ldata.centerId]
    local curTime = overlordView.Time["TIME_" .. def.era]
    return "<img0000,000000>icon_mapopt_" .. ICON_OPT_ROLE .. ".png&<txt0018,ffffff>" .. ldata.camp .. "[" ..(ldata.familyName or "流浪") .. "]&<txt0018,ffffff>" .. ldata.name .. "#n&" ..
    "<img0000,000000>" .. curTime.sicon .. "&<txt0018,ffffff>" .. curTime.name .. " 城镇中心" ..def.level.. "级#n&"
end
local function constructFamItem(fdata)
    if fdata then
        return "<img0000,000000>icon_mapopt_" .. ICON_OPT_FAM .. ".png&<txt0018,ffffff>" .. fdata.camp ..(fdata.name) .. "#n&"
    else
        return "<img0000,000000>icon_mapopt_" .. ICON_OPT_FAM .. ".png&<txt0018,ffffff>[尚未占领]#n&"
    end
end
local function constructDrillItem(fdata)
    local str = ""
    if fdata and fdata.firstDrop then
        local dic = me.split(fdata.firstDrop, ",")
        if dic then
            for key, var in pairs(dic) do
                local ret = me.split(var, ":")
                if ret then
                    -- 117/58
                    local icon = ""
                    local s16 = 0
                    icon = getItemIcon(ret[1])
                    s16 = string.format("%06x", ret[1])
                    str = str .. "<pet0000,%s>" .. icon .. "&"
                    str = string.format(str, s16)
                end
            end
        end
    end
    return str
end
local function constructArchItem(cdata)
    -- kaoguItems

    local str = ""
    if cdata.toolId and cdata.toolId > 0 then
        local canUse = archDress:betterThan(cdata.toolId)
        local tid_str = string.format("%06x", tostring(cdata.toolId))
        str = str .. "<txt0018,f4cb69>考古产出#n&"
        if cdata.kaoguItems then
            local dic = me.split(cdata.kaoguItems, ",")
            if dic then
                for key, var in pairs(dic) do
                    local ret = me.split(var, ":")
                    if ret then
                        -- 117/58
                        local icon = ""
                        local s16 = 0
                        if true then
                            icon = getItemIcon(ret[1])
                            s16 = string.format("%06x", ret[1])
                        else
                            icon = "waicheng_beijing_kuang_wenhao.png"
                            s16 = "000000"
                        end
                        str = str .. "<pet3131,%s>" .. icon .. "&"
                        str = string.format(str, s16)
                        str = str .. "<txt0018,000000> &"
                    end
                end
            end
            str = str .. "<txt0018,000000>#n&"
        end
    end
    return str
end
local function constructRuneItem(cdata)
    local pConfig = cdata:getDef()
    local str = ""
    local pHeight = 0
    if cdata.bossId and cdata.bossId > 0 then
        local pStr = ""
        if pConfig.level > user.Rune_Create_info_level then
            pStr = "<txt0012,ff0000>需先击败&<txt0012,ff0000>Lv." ..(user.Rune_Create_info_level) .. "&<txt0012,ff0000>的遗迹守军#n&"
            pHeight = pHeight + 20
        end
        if cdata.fk == true then
            str = pStr .. "<txt0016,ffffff>首杀奖励" .. "#n&"
            local pTable = me.split(pConfig.extReward, ",")
            if table.nums(pTable) > 4 then
                pHeight = pHeight + 70
            end
            if pTable then
                for key, var in pairs(pTable) do
                    local ret = me.split(var, ":")
                    if ret then
                        local icon = ""
                        local s16 = 0
                        icon = getItemIcon(ret[1])
                        s16 = string.format("%06x", ret[1])
                        str = str .. "<pet3131,%s>" .. icon .. "&"
                        str = string.format(str, s16)
                        str = str .. "<txt0018,000000> &"
                    end
                end
                str = str .. "<txt0018,000000>#n&"
            end 
        else
            str = pStr .. "<txt0016,ffffff>几率获得" .. "#n&"  
            local pTable = me.split(pConfig.rewardShow, ",")
            if table.nums(pTable) > 4 then
                pHeight = pHeight + 70
            end
            if pTable then
                for key, var in pairs(pTable) do                   
                        local icon = ""
                        local s16 = 0
                        icon = getItemIcon(var)
                        s16 = string.format("%06x", var)
                        str = str .. "<pet3131,%s>" .. icon .. "&"
                        str = string.format(str, s16)
                        str = str .. "<txt0018,000000> &"                    
                end
                str = str .. "<txt0018,000000>#n&"
            end 
        end
    end
    return str, pHeight
end
function mapOptMenuLayer:initInfo_(cp)
    print("mapOptMenuLayer:initInfo_(cp)")
    self.info:setVisible(true)
    self.info:removeAllChildren()
    self.Panel_Reward:removeAllChildren()
    self.buffRichtxt = nil
    self.contactBtn = nil
    local cellType = POINT_NONE
    local celldata = pWorldMap:getCellDataByCrood(cp)
    local configData = getMapConfigData(cp)
    local info_height = 0
    local infoStr = ""
    -- 地块信息
    if celldata then
        cellType = celldata.pointType
        local ldata = celldata:getOwnerData()
        if user.Cross_Sever_Status == mCross_Sever and ldata == nil and celldata.cityMasterName ~= nil and celldata.masterCamp ~= nil then
            infoStr = infoStr .. constructCrossCaptiveItem(celldata.cityMasterName, celldata.masterCamp)
        else
            infoStr =(ldata and ldata.cityMasterName) and infoStr .. constructCaptiveItem(ldata) or infoStr
        end
        if cellType == POINT_CITY or cellType == POINT_CBASE or cellType == POINT_STRONG_HOLD then
            -- 主城 或者 主城区 或者 据点          
            if user.Cross_Sever_Status == mCross_Sever and celldata.origin == 1 then

            else
                infoStr = infoStr .. constructRoleItem(ldata)
            end

        elseif cellType == POINT_FBASE or cellType == POINT_FORT then
            -- 要塞城区  --  dump(celldata)
            local fdata = celldata:getFortData()
            if fdata then
                local famdata = fdata:getOwnFamily()
                -- 获取所属工会
                local pStr = "<txt0018,fbefd3>联盟加成#n&"
                if user.Cross_Sever_Status == mCross_Sever then
                    pStr = "<txt0018,fbefd3>区服加成#n&"
                end
                infoStr = infoStr .. constructFamItem(famdata)
                infoStr = infoStr .. constructLine()
                infoStr = infoStr .. pStr
                local fdef = fdata:getDef()
                local desc = fdef.desc
                if desc then
                    local t = me.split(desc, "|")
                    if t then
                        for key, var in pairs(t) do
                            local ret = me.split(var, ":")
                            if ret then
                                infoStr = infoStr .. constructInfoItem(ret[1], ret[2], ret[3])
                            end
                        end
                    end
                end
                -- infoStr = infoStr .. "<txt0018,fbefd3>首次演武奖励#n&"
                -- infoStr = infoStr .. constructDrillItem(fdef)
                if user.Cross_Sever_Status ~= mCross_Sever then
                    infoStr = infoStr .. constructLine()
                    infoStr = infoStr .. "<txt0018,ffffff>领地加成 &<img5050,100000>shangcheng_anniu_xiangqing_zhengchang.png&<txt0018,000000>#n&"
                end
                local heroId = nil
                if fdata.heroId then
                    heroId = tonumber(fdata.heroId)
                else
                    heroId = tonumber(fdata.heroDefId)
                end
                local pHeroConfig = cfg[CfgType.HERO][heroId]
                if pHeroConfig then
                    local landClassdesc = pHeroConfig.landClassdesc
                    if landClassdesc then
                        local t = me.split(landClassdesc, "|")
                        if t then
                            for key, var in pairs(t) do
                                local ret = me.split(var, ":")
                                if ret then
                                    infoStr = infoStr .. constructInfoItem(ret[1], ret[2], ret[3])
                                end
                            end
                        end
                    end
                end
                infoStr = infoStr .. constructLine()
                if fdata and(fdata.oType == 3 or fdata.oType == 2) then
                    -- 守军剩余波数
                    infoStr = infoStr .. "<img0000,000000>icon_mapopt_" .. CON_OPT_NPC .. ".png&<txt0018,f4cb69>" .. TID_NPC_LEVEL .. "&<txt0018,ff0000>   " ..(fdata.npc or "") .. "&<txt0018,fbefd3>/" ..(fdata.srcNpc or "") .. "#n&"
                else
                    infoStr = infoStr .. "<img0000,000000>icon_mapopt_" .. CON_OPT_NPC .. ".png&<txt0018,f4cb69>" .. TID_NPC_LEVEL .. "&<txt0018,fbefd3>   " ..(fdata.srcNpc or "") .. "&<txt0018,fbefd3>/" ..(fdata.srcNpc or "") .. "#n&"
                end

            else
                infoStr = infoStr .. constructFamItem(nil)
            end

        elseif cellType == POINT_NORMAL then
            -- 普通地块
            local randEvent = celldata:getEventDef()
            if celldata:bHaveBoss() then
                local bossdata = celldata:getBossData()
                dump(bossdata)
                if bossdata then
                    self:initBossInfo(bossdata)
                end
                -- 获取是否有随机事件
            elseif randEvent then
                self:initRandEventInfo(celldata)
            else
                dump(ldata)
                if ldata then
                    infoStr = infoStr .. constructRoleItem(ldata)
                end
                local extdesc = configData.extdesc
                if extdesc then
                    local t = me.split(extdesc, "|")
                    if t then
                        for key, var in pairs(t) do
                            local ret = me.split(var, ":")
                            if ret then
                                infoStr = infoStr .. constructInfoItem(ret[1],nil, ret[2])
                            end
                        end
                    end
                end
                infoStr = infoStr .. constructLine()
                if user.newBtnIDs[tostring( OpenButtonID_Arch)] ~= nil  then
                    local aStr = constructArchItem(configData)
                    if me.isValidStr(aStr) then
                        infoStr = infoStr .. aStr
                        infoStr = infoStr .. constructLine()
                    end
                end
                infoStr = infoStr .. constructInfoItem(CON_OPT_NPC, TID_NPC_LEVEL, configData.npclv)
            end
        elseif cellType == POINT_POST then
            -- 驿站
            infoStr = infoStr .. constructRoleItem(ldata)
        else
            self.info:setVisible(false)
        end
    else
        print("没有网络传过来的数据，也就是还是无主土地!!!")
        -- 没有网络传过来的数据，也就是还是无主土地
        dump(configData)
        local extdesc = configData.extdesc
        if extdesc then
            local t = me.split(extdesc, "|")
            if t then
                for key, var in pairs(t) do
                    local ret = me.split(var, ":")
                    if ret then
                        infoStr = infoStr .. constructInfoItem(ret[1],nil, ret[2])
                    end
                end
            end
        end
        infoStr = infoStr .. constructLine()
        if user.newBtnIDs[tostring( OpenButtonID_Arch)] ~= nil then
            local aStr = constructArchItem(configData)
            if me.isValidStr(aStr) then
                infoStr = infoStr .. aStr
                infoStr = infoStr .. constructLine()
            end
        end
        infoStr = infoStr .. constructInfoItem(CON_OPT_NPC, TID_NPC_LEVEL, configData.npclv)
    end
    local function rt_callback(sender, event)
        if event ~= ccui.TouchEventType.ended or sender.pId == 0 then
            return
        end
        if sender.pId == 1048576 then
            me.showMessageDialog("联盟占领要塞后，联盟成员主城在要塞领地内可以享受加成。要塞名将试炼度越高领地加成越大。", nil, 1)
            return
        end
        local etc = cfg[CfgType.ETC][me.toNum(sender.pId)]
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithStr(etc.name, wd)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)

    end
    local rcf = mRichText:create(infoStr, 360, nil, 5)
    rcf:registCallback(rt_callback)
    local h = 0
    if celldata then
        if celldata:bHaveProtect() and celldata:getOccState() == OCC_STATE_OWN then
            -- 免战中
            h = 50
            --   self.info:removeChildByTag(12300)
            local globalItems = me.createNode("Node_mapOptInfoItem.csb")
            local mitem = me.assignWidget(globalItems, "mapOptInfoItem"):clone()
            me.assignWidget(mitem, "icon"):setVisible(true)
            local Text_info = me.assignWidget(mitem, "Text_info")
            Text_info:setString(TID_CELL_PROTECT)
            local Text_time = me.assignWidget(mitem, "Text_time")
            mitem:setTag(12300)
            self.info:addChild(mitem)
            self.info:setContentSize(cc.size(rcf:getContentSize().width + 40, rcf:getContentSize().height + 40 + h))
            mitem:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - mitem:getContentSize().height + 15))

            local ltime =(celldata.gtime * 1000 -(me.sysTime() - celldata.revTime)) / 1000
            Text_time:setString(me.formartSecTime(ltime))
            self.dropTimer = me.registTimer(ltime, function(dt)
                ltime =(celldata.gtime * 1000 -(me.sysTime() - celldata.revTime)) / 1000
                -- dump(ltime)
                if ltime <= 0 then
                    ltime = 0
                    self.info:removeChildByTag(12300)
                    me.clearTimer(self.dropTimer)
                else
                    Text_time:setString(me.formartSecTime(ltime))
                end
            end , 0.2)
        end
        local fortdata_m = celldata:getFortData()
        if fortdata_m and(fortdata_m.oType == 3 or fortdata_m.oType == 2 or fortdata_m.oType == 4) then
            -- 守军恢复
            h = 50
            --  self.info:removeChildByTag(12300)
            local globalItems = me.createNode("Node_mapOptInfoItem.csb")
            local mitem = me.assignWidget(globalItems, "mapOptInfoItem"):clone()
            local Text_info = me.assignWidget(mitem, "Text_info")
            if fortdata_m.oType == 2 then
                me.assignWidget(mitem, "icon"):setVisible(true)
                Text_info:setString(TID_CELL_PROTECT)
            elseif fortdata_m.oType == 4 then
                me.assignWidget(mitem, "icon"):setVisible(true)
                Text_info:setString(TID_CELL_LOCK)
            else
                me.assignWidget(mitem, "icon"):setVisible(false)
                Text_info:setString(TID_CELL_DEF_RESET)
            end
            local Text_time = me.assignWidget(mitem, "Text_time")
            mitem:setTag(12300)
            self.info:setContentSize(cc.size(rcf:getContentSize().width + 40, rcf:getContentSize().height + 40 + h))
            self.info:addChild(mitem)
            mitem:setPosition(20, h);
            local ltime =(fortdata_m.dtime -(me.sysTime() - fortdata_m.revTime)) / 1000
            Text_time:setString(me.formartSecTime(ltime))
            self.defendTimer = me.registTimer(ltime, function(dt)
                ltime =(fortdata_m.dtime -(me.sysTime() - fortdata_m.revTime)) / 1000
                if ltime <= 0 then
                    ltime = 0
                    self.info:removeChildByTag(12300)
                    me.clearTimer(self.defendTimer)
                else
                    Text_time:setString(me.formartSecTime(ltime))
                end
            end , 0.2)
        end
    end
    if h == 0 then
        self.info:setContentSize(cc.size(rcf:getContentSize().width + 40, rcf:getContentSize().height + 40 + h))
    end
    if celldata then
        local ldata = celldata:getOwnerData()
        if ldata and ldata.uid ~= user.uid then
            self.contactBtn = me.assignWidget(self, "contactBtn"):clone():setVisible(true)
            self.contactBtn:setPosition(cc.p(self.info:getContentSize().width - 20, self.info:getContentSize().height - 20))
            self.contactBtn.uid = ldata.uid
            self.contactBtn.name = ldata.name
            self.info:addChild(self.contactBtn)
            me.registGuiClickEvent(self.contactBtn, function(node)
                self:popupMailView(self.contactBtn)
            end )
        end
    end
    rcf:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - 20))
    self.info:addChild(rcf)
    local function getSkillBuff()
        if self.buffRichtxt ~= nil then
            self.buffRichtxt:removeFromParent()
            self.buffRichtxt = nil
        end
        local skillBuff = ""
        -- 技能buff
        if celldata then
            -- 设置buff状态
            if celldata.pointType == POINT_CITY or celldata.pointType == POINT_CBASE or celldata.pointType == POINT_STRONG_HOLD then
                local tmpBuffs = nil
                if me.toNum(celldata.ownerId) == me.toNum(user.uid) then
                    -- 玩家自己
                    tmpBuffs = user.heroBuffList
                else
                    -- 别人
                    tmpBuffs = celldata.buffs
                end
                if tmpBuffs then
                    for key, var in pairs(tmpBuffs) do
                        local skillDef = cfg[CfgType.HERO_SKILL][var.id]
                        local icon = getHeroSkillIcon(skillDef.skillicon)
                        local cd = nil
                        if var.tm and me.toNum(var.tm) > 0 then
                            cd = var.tm -(me.sysTime() - var.sysT) / 1000
                            if cd > 0 then
                                cd = me.formartSecTime(cd)
                                skillBuff = skillBuff .. "<img2a2a,000000>" .. icon .. "&<txt0018,f4cb69>" .. skillDef.skillname .. "&<txt0018,ff0000> " .. cd .. "#n&"
                            end
                        end
                    end
                end
            end
        end
        return skillBuff
    end
    local buffRichStr = getSkillBuff()
    if me.isValidStr(buffRichStr) then
        self.buffRichtxt = mRichText:create(buffRichStr, 360, nil, 5)
        local width = math.max(self.buffRichtxt:getContentSize().width, self.info:getContentSize().width)
        self.info:setContentSize(cc.size(width + 20, self.info:getContentSize().height + self.buffRichtxt:getContentSize().height))
        self.info:addChild(self.buffRichtxt)
        rcf:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - 20))
        self.buffRichtxt:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - self.buffRichtxt:getContentSize().height - 20))
        if self.buffTimer ~= nil then
            me.clearTimer(self.buffTimer)
            self.buffTimer = nil
        end
        self.buffTimer = me.registTimer(-1, function()
            local tmpStr = getSkillBuff()
            if me.isValidStr(tmpStr) then
                self.buffRichtxt = mRichText:create(tmpStr, 360, nil, 5)
                self.info:addChild(self.buffRichtxt)
                rcf:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - 20))
                self.buffRichtxt:setPosition(cc.p(20, self.info:getContentSize().height - rcf:getContentSize().height - self.buffRichtxt:getContentSize().height - 20))
            else
                me.clearTimer(self.buffTimer)
            end
        end , 1)
    end
end

function mapOptMenuLayer:isCityBorder(c)
    if not isBorder(c) then
        local cityP = nil
        for x = -1, 1 do
            for y = -1, 1 do
                local data = gameMap.mapCellDatas[me.getIdByCoord(cc.p(c.x + x, c.y + y))]
                if data and data.pointType == POINT_CITY then
                    cityP = cc.p(c.x + x, c.y + y)
                end
            end
        end
        if cityP then
            return isBorder(cc.p(cityP.x - 1, cityP.y)) or isBorder(cc.p(cityP.x, cityP.y - 1)) or isBorder(cc.p(cityP.x - 1, cityP.y - 1))
        else
            print("mapOptMenuLayer isCityBorder error! pointType ~= POINT_CITY")
            return false
        end
    else
        return true
    end

end
function mapOptMenuLayer:getArmyAid()
    for key, var in pairs(gameMap.troopData) do
        if user.uid == var.uid then
            if var.m_Status == TEAM_ARMY_DEFENS or var.m_Status == TEAM_ARMY_DEFENS_WAIT then
                if var.m_Paths.tag.x == self.cp.x and var.m_Paths.tag.y == self.cp.y then
                    self.mTeamID = var.m_TroopId
                    return true
                end
            end
        end
    end
    return false
end
function mapOptMenuLayer:initOptBtns(cp)
    local cellType = POINT_NONE
    local celldata = pWorldMap:getCellDataByCrood(cp)
    local configData = getMapConfigData(cp)
    local info_height = 0
    local infoStr = ""
    if celldata then
        cellType = celldata.pointType
        local occ = celldata:getOccState()
        local ldata = celldata:getOwnerData()
        local bCaptured = CaptiveMgr:isCaptured()

        self.Button_Exile:setVisible(false)
        self.Button_ArchDef:setVisible(false)
        self.Button_ArchInfo:setVisible(false)
        self.Button_ArchBattle:setVisible(false)
        self.Button_zhaohuan:setVisible(false)
        self.Button_detail:setVisible(false)
        self.Button_Plunder:setVisible(false)
        --        dump(celldata)
        if cellType == POINT_CITY or cellType == POINT_CBASE then
            -- 主城 和 主城区
            if occ == OCC_STATE_OWN then
                -- 回城
                self.Button_Lord:setVisible(true)
                self.Button_Station:setVisible(false)
            elseif occ == OCC_STATE_ALLIED then
                -- 驻守
                self.Button_Station:setVisible(true)
                self.Button_ArchDef:setVisible(true)
                if self:getArmyAid() then
                    self.Button_ArchInfo:setVisible(true)
                else
                    if celldata.origin == 1 then
                        -- 跨服没出生
                        self.Button_ArchDef:setVisible(false)
                        self.Button_Fort:setVisible(true)
                    else
                        self.Button_ArchDef:setVisible(true)
                        self.Button_Fort:setVisible(false)
                    end

                end
            elseif occ == OCC_STATE_HOSTILE then
                -- 掠夺 侦查 相邻 征服
                self.Button_Lord:setVisible(false)
                self.Button_Battle:setVisible(true)
                -- 盟战集火
                self.Button_ArchBattle:setVisible(true)
                -- end
                if user.Cross_Sever_Status == mCross_Sever and celldata.origin == 1 then
                    if self:isCityBorder(cp) then
                        me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_BATTLE)
                    else
                        self.Button_Battle:setVisible(false)
                    end
                else
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(self:isCityBorder(cp) and TID_BATTLE or TID_TAKE)
                end
                self.Button_Spy:setVisible(true)
            elseif occ == OCC_STATE_CAPTIVE then
                -- 驻守
                self.Button_Station:setVisible(true)
                self.Button_Exile:setVisible(user.Cross_Sever_Status ~= mCross_Sever)
            elseif occ == OCC_STATE_CAPTIVE_ALLYED then
                -- 掠夺 侦查 相邻 解救
                self.Button_Battle:setVisible(true)
                if CaptiveMgr:isCaptured() then
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_TAKE)
                else
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(self:isCityBorder(cp) and TID_SAVE or TID_TAKE)
                end
                self.Button_Spy:setVisible(true)
            end
        elseif cellType == POINT_FBASE or cellType == POINT_FORT then
            -- 要塞城
            -- 要塞
            local fdata = celldata:getFortData()
            self.m_PitchFortId = celldata["m_FortId"]
            --            dump(fdata)
            if fdata.famdata and me.toNum(fdata.famdata.mine) == 1 then
                --                dump(mData)
                self.Button_GiveUp_Fortress:setVisible(celldata.giveup <= 0)
                self.Button_GiveUpCancel_Fortress:setVisible(celldata.giveup > 0)
                self.Button_Station:setVisible(true)
                if user.Cross_Sever_Status == mCross_Sever then
                    self.Button_Fort_General:setVisible(false)
                else
                    self.Button_Fort_General:setVisible(true)
                end
                if fdata.start == 1 then
                    local pExperData = user.fortheroRankList
                    --                   dump(pExperData)
                    if pExperData["CountExperTime"] > 0 then
                        self.Button_open_once:setVisible(true)
                    else
                        self.Button_open_fort_exper:setVisible(true)
                    end
                    self.Button_Station:setPosition(cc.p(92, 35))
                    self.Button_Sign_King:setPosition(cc.p(92, 35 - 90))
                end
            else
                self.Button_Battle_Fort:setVisible(true)
                self.Button_Spy:setVisible(true)
                self.Button_Fort_General:setVisible(false)
                self.Button_open_fort_exper:setVisible(false)
                self.Button_Medal:setVisible(false)
            end
        elseif cellType == POINT_NORMAL then
            -- 普通地块
            local isShowZhaohuan = true
            -- 是否显示召唤按钮
            local randEvent = celldata:getEventDef()
            if celldata:bHaveBoss() then
                isShowZhaohuan = false

                local bdata = celldata:getBossData()
                --                dump(bdata)
                if bdata and bdata.bossType == 1 then
                    self.Button_AttBoss:setVisible(true)
                    local count = 0
                    for key, var in pairs(user.pkg) do
                        if var.defid == 558 then
                            -- 年兽令。
                            count = var.count
                        end
                    end
                    local num = me.assignWidget(self.Button_BossMark, "Text_BossMarkNum")
                    num:setString(count)
                    self.Button_BossMark:setVisible(false)
                elseif bdata and bdata.bossType == 2 or bdata.bossType == 3 then
                    -- 考古守卫
                    self.Button_Medal:setVisible(true)
                elseif bdata and bdata.bossType == 4 then
                    isShowZhaohuan = true
                    -- 符文boss
                    self.Button_AttBoss:setVisible(true)
                    self.Button_Spy:setVisible(true)                    
                    if isBorder(cp) and occ == OCC_STATE_HOSTILE then
                        self.Button_Battle:setVisible(true)
                        self.Button_Battle:setPosition(cc.p(92, 243))
                        self.Button_Spy:setPosition(cc.p(92, 50))
                        self.Button_AttBoss:setPosition(cc.p(92, 150))
                        me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_BATTLE)
                    else
                        self.Button_Battle:setVisible(false)
                    end
                elseif bdata and bdata.bossType == 9 then
                    self.Button_ArchBattle:setVisible(true)
                else
                    self.Button_AttBoss:setVisible(true)
                end
                if celldata.pstatus == 1 and celldata.gtime and celldata.gtime > 0 then
                    -- 正在放弃的可以取消放弃
                    self.Button_GiveUpCancel:setVisible(true)
                    self.Button_GiveUp:setVisible(false)
                else
                    if not celldata.pstatus or celldata.pstatus ~= 2 then
                        -- 免战期间不能放弃
                        if bdata and bdata.bossType == 4 then
                            self.Button_GiveUp:setVisible(false)
                        else
                            self.Button_GiveUp:setVisible(true)
                        end
                        self.Button_GiveUpCancel:setVisible(false)
                    end
                end

                if bdata and bdata.bossType == 7 then
                    -- 蛮族军团
                    self.Button_AttBoss:setVisible(false)
                    self.Button_GiveUp:setVisible(false)
                    self.Button_detail:setVisible(true)
                end
                
                -- 获取是否有随机事件
            elseif randEvent then
                --                dump(occ)
                if occ == OCC_STATE_OWN then
                    -- 探索 驻守 筑城
                    self.Button_Eexplore:setVisible(true)
                    self.Button_Fort:setVisible(true)
                    local icon = me.assignWidget(self.Button_Eexplore, "Image_33")
                    icon:loadTexture("troop_state_24.png", me.localType)
                    if celldata.pstatus == 1 and celldata.gtime and celldata.gtime > 0 then
                        -- 正在放弃的可以取消放弃
                        self.Button_GiveUpCancel:setVisible(true)
                        self.Button_GiveUp:setVisible(false)
                    else
                        if not celldata.pstatus or celldata.pstatus ~= 2 then
                            -- 免战期间不能放弃
                            self.Button_GiveUp:setVisible(true)
                            self.Button_GiveUpCancel:setVisible(false)
                        end
                    end
                elseif occ == OCC_STATE_ALLIED then
                    -- 探索 驻守
                    self.Button_Eexplore:setVisible(true)
                    local icon = me.assignWidget(self.Button_Eexplore, "Image_33")
                    icon:loadTexture("troop_state_24.png", me.localType)
                elseif occ == OCC_STATE_HOSTILE then
                    -- 侦查 相邻 征服
                    self.Button_Plunder:setVisible(true)
                    -- jnmo
                    if isBorder(cp) then
                        self.Button_Battle:setVisible(true)
                    end
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(isBorder(cp) and TID_BATTLE or TID_TAKE)
                    self.Button_Spy:setVisible(true)
                elseif occ == OCC_STATE_CAPTIVE then
                    -- 探索 驻守
                    self.Button_Eexplore:setVisible(true)
                    local icon = me.assignWidget(self.Button_Eexplore, "Image_33")
                    icon:loadTexture("troop_state_24.png", me.localType)
                elseif occ == OCC_STATE_CAPTIVE_ALLYED then
                    -- 侦查 相邻 征服
                    self.Button_Battle:setVisible(true)
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(isBorder(cp) and TID_BATTLE or TID_TAKE)
                    self.Button_Spy:setVisible(true)
                elseif occ == OCC_STATE_CAPTIVE_MATSTER_FAMILY then
                    -- 掠夺
                    self.Button_Battle:setVisible(true)
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_TAKE)
                end
            else
                if occ == OCC_STATE_OWN then
                    -- 筑城 考古 驻守
                    self.Button_Fort:setVisible(true)
                    if user.newBtnIDs[me.toStr(OpenButtonID_Arch)] ~= nil and user.Cross_Sever_Status == mCross_Sever_Out then
                        -- 判断考古是否开启
                        self.Button_Eexplore:setVisible(true)
                        local title = me.assignWidget(self.Button_Eexplore, "Text_EexploreTitle")
                        local icon = me.assignWidget(self.Button_Eexplore, "Image_33")
                        icon:loadTexture("troop_state_11.png", me.localType)
                        title:setString(TID_ARCH)
                    end
                    if celldata.pstatus == 1 and celldata.gtime and celldata.gtime > 0 then
                        -- 正在放弃的可以取消放弃
                        self.Button_GiveUpCancel:setVisible(true)
                        self.Button_GiveUp:setVisible(false)
                    else
                        if not celldata.pstatus or celldata.pstatus ~= 2 then
                            -- 免战期间不能放弃
                            self.Button_GiveUp:setVisible(true)
                            self.Button_GiveUpCancel:setVisible(false)
                        end
                    end
                elseif occ == OCC_STATE_ALLIED then                 -- 驻守
                    self.Button_Station:setVisible(true)                    
                elseif occ == OCC_STATE_HOSTILE or occ == OCC_STATE_CAPTIVE_ALLYED then
                    -- 掠夺 相邻 征服  侦查
                    self.Button_Lord:setVisible(false)
                    self.Button_Battle:setVisible(true)
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(isBorder(cp) and TID_BATTLE or TID_TAKE)
                    self.Button_Spy:setVisible(true)
                elseif occ == OCC_STATE_CAPTIVE then
                    self.Button_Station:setVisible(true)
                elseif occ == OCC_STATE_NONE then
                    -- 当该地块boss被消灭后，就变成无主之地，可以征服
                    self.Button_Lord:setVisible(false)
                    self.Button_Battle:setVisible(true)
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_BATTLE)
                    self.Button_Spy:setVisible(true)
                    self.Button_ArchDef:setVisible(false)
                    self.Button_ArchInfo:setVisible(false)
                    self.Button_ArchBattle:setVisible(false)
                end
            end
            if occ == OCC_STATE_OWN and isShowZhaohuan == true and user.zhaohuanItemNums > 0 and user.Cross_Sever_Status ~= mCross_Sever then
                self.Button_zhaohuan:setVisible(true)
                me.assignWidget(self.Button_zhaohuan, "numsTxt"):setString(user.zhaohuanItemNums)
            end
        elseif cellType == POINT_STRONG_HOLD then
            -- 据点
            self.Button_Hold_Info:setVisible(true)
            self.mStronghold = gameMap.bastionData[celldata.strongHoldId]
            --   dump(self.mStronghold)
            if occ == OCC_STATE_OWN then
                -- 自己的据点
                if self.mStronghold ~= nil and self.mStronghold.state ~= 2 then
                    -- 建造完成
                    self.Button_Battle:setVisible(false)
                    self.Button_Spy:setVisible(false)
                    if self.mStronghold:getArmyNum() > 0 then
                        self.Button_Station:setVisible(true)
                        self.Button_Mobilize:setVisible(true)
                        self.Button_Recall:setVisible(true)
                        self.Button_Hold_Info:setPosition(cc.p(92, 285))
                        self.Button_Station:setPosition(cc.p(92, 35))
                        self.Button_Sign_King:setPosition(cc.p(92, 35 - 90))
                        self.Button_Mobilize:setPosition(cc.p(92, 201))
                    else
                        self.Button_Station:setVisible(true)
                        self.Button_Mobilize:setVisible(true)
                        self.Button_Recall:setVisible(false)
                        self.Button_Hold_Info:setPosition(cc.p(92, 201))
                        self.Button_Mobilize:setPosition(cc.p(92, 118))
                        self.Button_Station:setPosition(cc.p(92, 35))
                        self.Button_Sign_King:setPosition(cc.p(92, 35 - 90))
                    end
                else
                    self.Button_Station:setVisible(false)
                    self.Button_Mobilize:setVisible(false)
                    self.Button_Hold_Info:setVisible(false)
                    self.Button_Hold_Info:setPosition(cc.p(92, 174))
                end
                if celldata.pstatus == 1 and celldata.gtime and celldata.gtime > 0 then
                    -- 正在放弃的可以取消放弃
                    self.Button_GiveUpCancel:setVisible(true)
                    self.Button_GiveUp:setVisible(false)
                else
                    if not celldata.pstatus or celldata.pstatus ~= 2 then
                        -- 免战期间不能放弃
                        self.Button_GiveUp:setVisible(true)
                        self.Button_GiveUpCancel:setVisible(false)
                    end
                end
            elseif occ == OCC_STATE_HOSTILE or occ == OCC_STATE_CAPTIVE_ALLYED then
                self.Button_Station:setVisible(false)
                self.Button_Mobilize:setVisible(false)
                self.Button_Hold_Info:setVisible(false)
                self.Button_Battle:setVisible(true)
                -- self.Button_Spy:setVisible(true)
                if isBorder(cp) then
                    me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_BATTLE)
                else
                    self.Button_Battle:setVisible(false)
                end
            else
                self.Button_Station:setVisible(false)
                self.Button_Mobilize:setVisible(false)
                self.Button_Hold_Info:setVisible(false)
            end
        elseif cellType == POINT_TBASE or cellType == POINT_THRONE then
            -- 王座
            print("王座")
        end
        if cellType ~= POINT_CBASE and cellType ~= POINT_CITY then
            if occ == OCC_STATE_OWN or(occ == OCC_STATE_ALLIED and not bCaptured) or(occ == OCC_STATE_CAPTIVE) then
                if celldata:bHaveBoss() then
                    self.Button_Station:setVisible(false)
                else
                    if getCenterBuildingLevel() > 6 then
                        self.Button_Station:setVisible(true)
                    else
                        self.Button_Station:setVisible(false)
                    end
                end
            else
                self.Button_Station:setVisible(false)
            end
        end
    else
        -- 没有网络传过来的数据，也就是还是无主土地
        self.Button_Lord:setVisible(false)
        self.Button_Battle:setVisible(true)
        me.assignWidget(self.Button_Battle, "Text_BattleTitle"):setString(TID_BATTLE)
        self.Button_Spy:setVisible(true)
        self.Button_ArchDef:setVisible(false)
        self.Button_ArchInfo:setVisible(false)
        self.Button_ArchBattle:setVisible(false)
        self.Button_Exile:setVisible(false)
        self.Button_zhaohuan:setVisible(false)
    end
    if user.Cross_Sever_Status == mCross_Sever then
        -- 跨服地图，都可标记国王目标
        self.Button_Sign_King:setVisible(true)
    end
end

function mapOptMenuLayer:initSignState(id)
    local bSigned = WorldMapView.SignPoints[id]
    if bSigned then
        self.Button_SignCancel:setVisible(true)
        self.Button_Sign:setVisible(false)
    else
        self.Button_Sign:setVisible(true)
        self.Button_SignCancel:setVisible(false)
    end
end
function mapOptMenuLayer:initOptMenu(cp)

    me.clearTimer(self.mapRandEventTimer)
    me.clearTimer(self.mapCollectTimer)
    me.clearTimer(self.defendTimer)
    me.clearTimer(self.dropTimer)
    me.clearTimer(self.pExperTime)
    me.clearTimer(self.pThroneTime)
    me.clearTimer(self.buffTimer)

    local id = me.getIdByCoord(cp)
    self:setcid(id)
    self:initTitle(cp)
    self.cp = cp
    local def = nil
    local celldata = pWorldMap:getCellDataByCrood(cp)

    -- cfg[CfgType.MAP_EVENT_DATA][me.Helper:getMapDataById(me.getIdByCoord(cp))]
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
        def = cfg[CfgType.MAP_EVENT_DATA][me.Helper:getMapDataById(me.getIdByCoord(cp))]
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        if celldata and(celldata.pointType == POINT_TBASE or celldata.pointType == POINT_THRONE) then
            self.Throne_Point = celldata.crood
        end
        local celltype = pWorldMap:isWater(cp)
        if celltype == 153 or celltype == 154 or celltype == 155 then
            --            self.cellName:removeChildByTag(0xffcc)
            --            local rcf = mRichText:create("<txt0018,ffffff>山脉(不可占领)&<txt0018,efec18>&")
            --            rcf:setTag(0xffcc)
            --            self.cellName:addChild(rcf)
            --            me.putNodeOnTop(self.Image_Hp, rcf, 0, cc.p(0, 2))
            --            return

            def = getMapConfigData(cp)
        end
    end
    if me.toNum(def.isTaken) == 1 or pWorldMap:getCellDataByCrood(cp) then
        if celldata and(celldata.pointType == POINT_TBASE or celldata.pointType == POINT_THRONE) then
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
                self.cellName:setVisible(false)
                self.Button_SignCancel:setVisible(false)
                self.Button_Sign:setVisible(false)
                self.Button_Sign_King:setVisible(false)
                if user.throne_create.Thronr_type == 0 then
                    --
                    local ThroneOpen = ThroneOpen:create("ThroneOpen.csb")
                    ThroneOpen:setType(ThroneOpen.OPEN)
                    pWorldMap:addChild(ThroneOpen, me.MAXZORDER)
                else
                    self:ThroneInfo()
                end
                --   self:ThroneInfo()
            elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                self:CrossThroneInfo(celldata)
                self:initSignState(id)
                GMan():send(_MSG.Cross_Sever_Score_Rank(101))
            end
        else
            if celldata and celldata.origin == 1 then
                self:initOptBtns(cp)
                self:initSignState(id)
            else
                self.cellName:setVisible(true)
                self:initInfo_(cp)
                self:initOptBtns(cp)
                self:initSignState(id)
            end

        end
    end
end
function mapOptMenuLayer:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_FORT_CLEAR_TIME) then
        self:Button_Fort_Exper_callback(node)
    elseif checkMsg(msg.t, MsgCode.CROSS_SEVER_SCORE_RANK) then
        self:CrossScoreRank()
    end
end
function mapOptMenuLayer:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function mapOptMenuLayer:initBossInfo(bdata)
    self.info:setVisible(false)
    self.eventInfo:setVisible(true)
    local Image_EventIcon = me.assignWidget(self.eventInfo, "Image_EventIcon")
    Image_EventIcon:ignoreContentAdaptWithSize(true)
    local Text_Time = me.assignWidget(self.eventInfo, "Text_Time")
    local Text_Info = me.assignWidget(self.eventInfo, "Text_Info")
    local def = bdata:getDef()
    if def then
        -- me.assignWidget(self.eventInfo, "img_Role"):loadTexture("icon_mapopt_6.png", me.plistType)
        me.assignWidget(self.eventInfo, "img_Role"):setVisible(false)
        me.assignWidget(self.eventInfo, "Text_EventName"):removeAllChildren()
        if def.type == 4 then
            me.assignWidget(self.eventInfo, "Text_EventName"):setString("")
            local pNameStr = "<txt0014,FAD16C>" .. def.name .. "&"
            local name = mRichText:create(pNameStr, 200, nil, 5)
            name:setPosition(cc.p(0, -10))
            me.assignWidget(self.eventInfo, "Text_EventName"):addChild(name)
        else
            me.assignWidget(self.eventInfo, "Text_EventName"):setString(def.name)
        end
    end
    if tonumber(def.icon) == 81 or tonumber(def.icon) == 82 or tonumber(def.icon) == 84 or tonumber(def.icon) == 83 then
        Image_EventIcon:loadTexture("boss_" .. def.icon .. ".png", me.localType)
    elseif tonumber(def.icon) >= 51 then
        Image_EventIcon:loadTexture("boss_97.png", me.localType)
    elseif tonumber(def.icon) >= 31 then
        Image_EventIcon:loadTexture("boss_98.png", me.localType)
    elseif tonumber(def.icon) >= 8 then
        Image_EventIcon:loadTexture("boss_99.png", me.localType)
    else
        Image_EventIcon:loadTexture("boss_" .. def.icon .. ".png", me.localType)
    end
    local Text_LeftLabel = me.assignWidget(self.eventInfo, "Text_LeftLabel"):setVisible(false)
    local Text_Num = me.assignWidget(self.eventInfo, "Text_Num"):setVisible(false)
    local tPos = cc.p(Text_Num:getPositionX(), Text_Num:getPositionY())
    me.clearTimer(self.mapRandEventTimer)
    local ltime = bdata.bossTime / 1000
    local Text_Left = me.assignWidget(self.eventInfo, "Text_Left"):setVisible(false)
    self.mapRandEventTimer = me.registTimer(ltime, function(dt)
        -- if math.floor(ltime) ~= math.floor(ltime - dt) then
        ltime = ltime - dt
        Text_Time:setString(me.formartSecTime(math.floor(ltime)))
        -- end
    end , 0.2)
    Text_Info:setString(def.desc)
    local height = 260
    if bdata.bossType == 4 then
        height = 350
        local infoStr, pheight = constructRuneItem(bdata)
        height = height + pheight
        local function rt_callback(sender, event)
            local etc = cfg[CfgType.ETC][me.toNum(sender.pId)]
            local wd = sender:convertToWorldSpace(cc.p(0, 0))
            local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
            if bdata.fk == true then
                local pTable = me.split(bdata:getDef().extReward, ",")    
                local num = 0 
                for key, var in pairs(pTable) do
                    local ret = me.split(var, ":")
                    if tonumber( ret[1] ) == tonumber( sender.pId) then
                         num = ret[2]
                    end
                end              
                local str = "<txt0016,ffffff>"..etc.name.."*"..num.."#n"..(etc.describe and etc.describe or "").."&"
                stips:initWithRichStr(str, wd)            
            else
                local str = "<txt0016,ffffff>"..etc.name.."#n"..(etc.describe and etc.describe or "").."&"
                stips:initWithRichStr(str, wd) 
            end
            me.runningScene():addChild(stips, me.MAXZORDER + 1)
        end
        local rcf = mRichText:create(infoStr, 300, nil, 5)
        rcf:registCallback(rt_callback)
        rcf:setPosition(0, 20)
        self.Panel_Reward:removeAllChildren()
        self.Panel_Reward:setContentSize(cc.size(300, rcf:getContentSize().height + 10))
        self.Panel_Reward:addChild(rcf)
    elseif me.isValidStr(bdata.bossUName) then
        height = 310
        self.Panel_Reward:removeAllChildren()
        local fstr = "<img0000,000000>icon_mapopt_6.png&<txt0015,e8d79f>%s &<txt0015,ffffff>%s#n&"
        local str = nil
        if bdata.bossType == 9 then
            str = string.format(fstr, "召唤者", bdata.bossUName)
        else
            str = string.format(fstr, "标记者", bdata.bossUName)
        end
        local rt = mRichText:create(str, 300)
        self.Panel_Reward:setContentSize(cc.size(300, rt:getContentSize().height + 10))
        rt:setPosition(10, 10)
        self.Panel_Reward:addChild(rt)
        self.eventInfo:setContentSize(cc.size(302, 260 + rt:getContentSize().height))
    end

    self.eventInfo:setContentSize(cc.size(310, height))
    me.doLayout(self.eventInfo, self.eventInfo:getContentSize())
end
function mapOptMenuLayer:initRandEventInfo(cdata)
    self.info:setVisible(false)
    self.eventInfo:setVisible(true)
    local Image_EventIcon = me.assignWidget(self.eventInfo, "Image_EventIcon")
    Image_EventIcon:ignoreContentAdaptWithSize(true)
    local Text_Time = me.assignWidget(self.eventInfo, "Text_Time")
    local Text_Info = me.assignWidget(self.eventInfo, "Text_Info")


    local ldata = cdata:getOwnerData()
    if ldata then
        me.assignWidget(self.eventInfo, "img_Role"):loadTexture("icon_mapopt_6.png", me.plistType)
        me.assignWidget(self.eventInfo, "Text_EventName"):removeAllChildren()
        me.assignWidget(self.eventInfo, "Text_EventName"):setString("[" ..(ldata.shorName or "流浪") .. "]" .. ldata.name)
    end

    Image_EventIcon:loadTexture(getMapRandEventIcon(cdata:getEventDef()), me.localType)
    local Text_LeftLabel = me.assignWidget(self.eventInfo, "Text_LeftLabel"):setVisible(false)
    local Text_Num = me.assignWidget(self.eventInfo, "Text_Num"):setVisible(false)
    local tPos = cc.p(Text_Num:getPositionX(), Text_Num:getPositionY())
    me.clearTimer(self.mapRandEventTimer)
    local ltime = cdata:getEventTime()
    local Text_Left = me.assignWidget(self.eventInfo, "Text_Left"):setVisible(false)
    self.mapRandEventTimer = me.registTimer(ltime, function(dt)
        -- if math.floor(ltime) ~= math.floor(ltime - dt) then
        ltime = ltime - dt
        Text_Time:setString(me.formartSecTime(math.floor(ltime)))
        -- end
    end , 0.2)
    local def = cdata:getEventDef()
    Text_Info:setString(def.desc)

    local reward = def.reward
    local fstr = "<txt0018,e8d79f>%s &<txt0018,ffffff>%d#n&"
    local str = ""
    local cellObj = pWorldMap.cellMoudels[cdata:getId()]
    local troopdata = cdata:bHaveCollecting()
    if troopdata then
        Text_Left:setVisible(true)
        Text_LeftLabel:setVisible(true)
        local fstr = "<img0000,000000>icon_mapopt_6.png&<txt0015,e8d79f>%s &<txt0015,ffffff>%s#n&"
        str = str .. string.format(fstr, TID_MAP_COLLECTER, troopdata.name)
        fstr = "<img0000,000000>icon_mapopt_5.png&<txt0015,e8d79f>%s &<txt0015,ffffff>%s#n&"
        str = str .. string.format(fstr, TID_MAP_COLLECT_VALUE,(troopdata.cSpeed * 3600) .. "/h")
        local leftnum = troopdata.cTotalData - troopdata.cData -(me.sysTime() - troopdata.revTime) / 1000 * troopdata.cSpeed
        leftnum = math.max(0, leftnum)
        Text_Left:setString(math.floor(leftnum))
        me.clearTimer(self.mapCollectTimer)
        self.mapCollectTimer = me.registTimer(-1, function(dt)
            leftnum =
            -- troopdata.cTotalData -  troopdata.cData - (me.sysTime() - troopdata.revTime) * troopdata.cSpeed
            leftnum - troopdata.cSpeed / 10
            leftnum = math.max(0, leftnum)
            Text_Left:setString(math.floor(leftnum))
            --                    Text_Num:setVisible(true)
            --                    Text_Num:setString(math.floor(troopdata.cSpeed))
            --                    Text_Num:setPosition(tPos)
            --                    local a0 =cc.FadeIn:create(0)
            --                    local a1 = cc.MoveBy:create(0.5,cc.p(0,20))
            --                    local a2 = cc.FadeOut:create(0.5)
            --                    local a3 = cc.Sequence:create(a0,cc.Spawn:create(a1,a2))
            --                    Text_Num:runAction(a3)
        end , 0.1)
    else
        if def.type > 4 and reward then
            local temp = me.split(reward, ",")
            if temp then
                for key, var in pairs(temp) do
                    local res = me.split(var, ":")
                    if res then
                        local data = cfg[CfgType.ETC][me.toNum(res[1])]

                        str = str .. string.format(fstr, data.name, res[2])
                    end
                end
            end
        else
            local res = me.split(reward, ":")
            if res and cdata.eventData then
                local data = cfg[CfgType.ETC][me.toNum(res[1])]
                str = str .. string.format(fstr, data.name, me.toNum(cdata.eventData))
            end
        end
    end
    self.Panel_Reward:removeAllChildren()
    local rt = mRichText:create(str, 300)
    self.Panel_Reward:setContentSize(cc.size(300, rt:getContentSize().height + 10))
    rt:setPosition(10, 10)
    self.Panel_Reward:addChild(rt)
    self.eventInfo:setContentSize(cc.size(302, 260 + rt:getContentSize().height))
    me.doLayout(self.eventInfo, self.eventInfo:getContentSize())
end
function mapOptMenuLayer:hide()
    pWorldMap:hideRoadDisTips()
    self.info:setVisible(false)
    self.eventInfo:setVisible(false)
    self.Button_GiveUp:setVisible(false)
    self.Button_GiveUpCancel:setVisible(false)
    self.Button_GiveUp_Fortress:setVisible(false)
    self.Button_GiveUpCancel_Fortress:setVisible(false)
    self.Button_Battle:setVisible(false)
    self.Button_Battle:setPosition(cc.p(92, 173))
    self.Button_Battle_Fort:setVisible(false)
    self.Button_Battle_Fort:setPosition(cc.p(92, 172))
    self.Button_Lord:setVisible(false)
    self.Button_Fort:setVisible(false)
    self.Button_AttBoss:setVisible(false)
    self.Button_AttBoss:setPosition(cc.p(92, 172))
    self:setVisible(false)
    self.Button_Sign:setVisible(false)
    self.Button_SignCancel:setVisible(false)
    self.Button_Spy:setVisible(false)
    self.Button_Plunder:setVisible(false)
    self.Button_Spy:setPosition(cc.p(92, 77))
    self.Button_BossMark:setVisible(false)
    self.Button_Eexplore:setVisible(false)
    local title = me.assignWidget(self.Button_Eexplore, "Text_EexploreTitle")
    title:setString(TID_EXPLORE)
    self.Button_Station:setVisible(false)
    self.Button_Station:setPosition(cc.p(92, 71))
    self.Button_Sign_King:setVisible(false)
    self.Button_Sign_King:setPosition(cc.p(92, 71 - 90))
    self.Button_Back:setVisible(false)
    self.Button_Mobilize:setVisible(false)
    self.Button_Hold_Info:setVisible(false)
    self.Button_Recall:setVisible(false)
    self.Button_open_fort_exper:setVisible(false)
    self.Button_Medal:setVisible(false)
    self.Button_open_once:setVisible(false)
    self.Button_Fort_General:setVisible(false)
    self.fort_hero_exper_Panel:setVisible(false)
    self.Button_zhaohuan:setVisible(false)
    -- 王座
    self.Button_throne:setVisible(false)
    self.Button_Cross_out:setVisible(false)
    -- 王座集火
    self.Button_arch_throne:setVisible(false)
    -- 王座占领
    self.Button_occupy:setVisible(false)
    -- 策略
    self.Button_arch_throne_Cross:setVisible(false)
    -- 驻守 跨服
    self.Button_occupy_Cross:setVisible(false)
    self.Button_strategy:setVisible(false)
    self.Throne_Info:setVisible(false)
    self.Cross_Score_rank:setVisible(false)
    self.Button_ArchBattle:setVisible(false)
    self.Button_ArchDef:setVisible(false)
    me.clearTimer(self.mapRandEventTimer)
    me.clearTimer(self.mapCollectTimer)
    me.clearTimer(self.defendTimer)
    me.clearTimer(self.dropTimer)
    me.clearTimer(self.pExperTime)
    me.clearTimer(self.pThroneTime)
    me.clearTimer(self.buffTimer)
    self.buffTimer = nil

end

function mapOptMenuLayer:move(dx, dy)
    local px, py = self:getPosition()
    self:setPosition(cc.p(px + dx, py + dy))
end

function mapOptMenuLayer:Button_Sign_King_callback(node)
    local crood = me.converCoordbyId(self:getcid())
    if user.officeDegree == true then
        local signdata = user.markKingPos[self:getcid()]
        if signdata then
            local markinfo = mapSetMarkKing:create("mapSetMarkKing.csb")
            markinfo:initWithData(signdata)
            me.popLayer(markinfo)
        else
            local mark = mapMarkKing:create("mapMarkKing.csb")
            mark:initCrood(crood.x, crood.y)
            me.popLayer(mark)
        end
    else
        local signdata = user.markKingPos[self:getcid()]
        if signdata then
            local markinfo = mapSetMarkKing:create("mapSetMarkKing.csb")
            markinfo:initWithData(signdata)
            me.popLayer(markinfo)
        else
            showTips("只有盟主才能标记")
            return
        end
    end
    self:hide()
end
function mapOptMenuLayer:Button_Sign_callback(node)
    local crood = me.converCoordbyId(self:getcid())
    local mData = gameMap.mapCellDatas[self:getcid()]
    local pName = ""
    if mData then
        if mData.pointType == POINT_CITY then
            pName = mData:getOwnerData().name
        elseif mData.pointType == POINT_STRONG_HOLD then
            pName = mData.strongHoldName
        else
            local event = getMapConfigData(crood)
            if event then
                pName = event.name
            end
        end
    else
        local event = getMapConfigData(crood)
        if event then
            pName = event.name
        end
    end
    pWorldMap:setMapPoint(crood.x, crood.y, pName)
    self:hide()
end
function mapOptMenuLayer:Button_SignCancel_callback(node)
    local crood = me.converCoordbyId(self:getcid())
    pWorldMap:removeMapPoint(crood)
    self:hide()
end
function mapOptMenuLayer:Button_Battle_Fort_callback(node)
    if getAllSoldierNum() > 0 then
        local mdata = gameMap.mapCellDatas[self.cid]
        local fid = mdata:getFortId()
        local tag = me.getCoordByFortId(fid)

        -- if isBorder(tag) then
        self:ChoosePoint(tag, EXPED_STATE_OCC)
        self:hide()
        --   NetMan:send(_MSG.worldMapPath(tag.x, tag.y, EXPED_STATE_OCC))
        -- else
        --    showTips(TID_BATTLE_NOT_BORDER)
        -- end

        --   pWorldMap:showExped(me.converCoordbyId(self.cid))
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_occupy_callback(node)
    if getAllSoldierNum() > 0 then
        local mdata = gameMap.mapCellDatas[self.cid]
        local fid = mdata:getFortId()
        local tag = self.Throne_Point
        self:ChoosePoint(tag, THRONE_SINGLE_BATTLE)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Medal_callback(node)
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        local celldata = pWorldMap:getCellDataByCrood(tag)
        if celldata and(celldata:bHaveProtect()) then
            showTips("免战中，无法出战")
            return
        end
        self:ChoosePoint(tag, BOSS_OCCUPATION)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Battle_callback(node)
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        local celldata = pWorldMap:getCellDataByCrood(tag)
        if celldata and(celldata:bHaveProtect()) then
            showTips("免战中，无法出战")
            return
        end
        --        if (celldata.pointType == POINT_CITY or celldata.pointType == POINT_CBASE) and user.protectedType == 2 then
        --            me.showMessageDialog("主城被沦陷，系统自动给与免战12小时保护时间，进攻其他玩家主城将立即结束免战，是否立即结束免战？", function(rev)
        --                if rev == "ok" then
        --                end
        --            end )
        --        end
        self:ChoosePoint(tag, EXPED_STATE_OCC)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Plunder_callback(node)
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        local celldata = pWorldMap:getCellDataByCrood(tag)
        if celldata and(celldata:bHaveProtect()) then
            showTips("免战中，无法出战")
            return
        end
        self:ChoosePoint(tag, EXPEND_STATE_PLUNDER)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Arch_callback(node)
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        self:ChoosePoint(tag, EXPED_STATE_ARCH)
        self:hide()
        -- NetMan:send(_MSG.worldMapPath(tag.x, tag.y, EXPED_STATE_ARCH))
        --   pWorldMap:showExped(me.converCoordbyId(self.cid))
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Eexplore_callback(node)
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        self:ChoosePoint(tag, EXPED_STATE_PILLAGE)
        self:hide()
        --    NetMan:send(_MSG.worldMapPath(tag.x, tag.y, EXPED_STATE_PILLAGE))
        --   pWorldMap:showExped(me.converCoordbyId(self.cid))
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Fort_callback(node)
    pWorldMap:showFortView(me.converCoordbyId(self.cid))
    self:hide()
end
function mapOptMenuLayer:Button_AttBoss_callback(node)
    print("打BOSS")
    if getAllSoldierNum() > 0 then
        local tag = me.converCoordbyId(self.cid)
        local celldata = pWorldMap:getCellDataByCrood(self.cp)
        local boosType = 0
        if celldata then
            local bdata = celldata:getBossData()
            if bdata and bdata.bossType == 4 then
                -- 符文boss
                boosType = BOOS_RUNEALTAR
                local def = bdata:getDef()
                if not bHaveBuildingType(cfg.BUILDING_TYPE_ALTAR, BUILDINGSTATE_BUILD.key) then
                    showTips("城镇中心8级建造圣殿后开启")
                    return
                end
                -- if def.level > user.Rune_Create_info_level then
                --     showTips("您需要先击败Lv." ..(user.Rune_Create_info_level) .. "的遗迹守军！")
                --     return
                -- end
            elseif bdata and(bdata.bossType == 0 or bdata.bossType == 1) then
                boosType = BOSS_OCCUPATION
            end
        end
        self:ChoosePoint(tag, BOSS_OCCUPATION, boosType)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Fort_Exper_callback(node)
    if getAllSoldierNum() > 0 then
        local mdata = gameMap.mapCellDatas[self.cid]
        local fid = mdata:getFortId()
        local tag = me.getCoordByFortId(fid)
        self:ChoosePoint(tag, HERO_EXPER)
        self:hide()
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:Button_Spy_callback(node)
    -- pWorldMap:showFortView(me.converCoordbyId(self.cid))
    local tag = me.converCoordbyId(self.cid)
    GMan():send(_MSG.worldMapSpy(tag.x, tag.y))
    self:hide()
end
function mapOptMenuLayer:Button_Station_callback(node)
    if getAllSoldierNum() > 0 then
        local mdata = gameMap.mapCellDatas[self.cid]
        if mdata and mdata.pointType == POINT_FBASE then
            local fid = mdata:getFortId()
            local tag = me.getCoordByFortId(fid)
            self:ChoosePoint(tag, EXPED_STATE_STATION)
        else
            local tag = me.converCoordbyId(self.cid)
            self:ChoosePoint(tag, EXPED_STATE_STATION)
        end
        self:hide()
        --  NetMan:send(_MSG.worldMapPath(tag.x, tag.y, EXPED_STATE_STATION))
    else
        showTips("请先训练军队")
    end
end
function mapOptMenuLayer:initLordBtn(ldata)
    if ldata.uid == user.uid then
        self.Button_Lord:setVisible(false)
        self.Button_Fort:setVisible(true)
    else
        self.Text_LordTitle:setString(ldata.name)
        self.Button_Lord:setVisible(true)
    end
end
-- 要出征打的地图坐标
function mapOptMenuLayer:initOcc(ostate_)
    if ostate_ == OCC_STATE_HOSTILE then
        self.Button_Battle:setVisible(true)
        self.Button_Spy:setVisible(true)
        self.Button_Station:setVisible(false)
    elseif ostate_ == OCC_STATE_OWN then
        self.Button_Battle:setVisible(false)
        self.Button_Spy:setVisible(false)
        --   self.Button_Station:setVisible(true)
    end
end
function mapOptMenuLayer:initStationInfo()
    local tb = { }
    local celldata = pWorldMap:getCellDataByCrood(self.cp)
    if celldata and(celldata.pointType == POINT_TBASE or celldata.pointType == POINT_THRONE) then
        local pos = self:getThrone(self.cp.x, self.cp.y)
        -- 王座中心点
        for key, var in pairs(gameMap.troopData) do
            if (var.m_Status == THRONE_DEFEND or var.m_Status == EXPED_STATE_STATIONED) and var.m_OriPoint.x == pos.x and var.m_OriPoint.y == pos.y then
                table.insert(tb, var)
            end
        end
    else
        for key, var in pairs(gameMap.troopData) do
            if var.m_Status == EXPED_STATE_STATIONED and var.m_OriPoint.x == self.cp.x and var.m_OriPoint.y == self.cp.y then
                table.insert(tb, var)
            end
        end
    end
    if tb and #tb > 0 then
        self.stationInfo:setVisible(true)
        self:initStationList(tb)
    else
        self.stationInfo:setVisible(false)
    end
end
function mapOptMenuLayer:getThrone(pX, pY)
    if user.Cross_Sever_Status == mCross_Sever then
        for key, var in pairs(user.throne_plot) do
            if pX == var.x and pY == var.y then
                return cc.p(var.x, var.y)
            end
            local near = getThroneNearCrood(cc.p(var.x, var.y)) or { }
            for k, v in pairs(near) do
                if pX == v.x and pY == v.y then
                    return cc.p(var.x, var.y)
                end
            end
        end
    end
    return cc.p(600, 600)
end

function mapOptMenuLayer:initStationList(tb)
    if self.stationTableView then
        me.assignWidget(self.stationInfo, "stationList"):removeChildByTag(999)
        self.stationTableView = nil
    end
    local num = #tb
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        local data = gameMap.troopData[tb[cell:getIdx() + 1].m_TroopId]
        self:popupInfoView(data)
    end

    local function cellSizeForTable(table, idx)
        return 299, 59
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local data = gameMap.troopData[tb[idx + 1].m_TroopId]
            if data then
                local stationCell = me.assignWidget(self.stationInfo, "stationCell"):clone():setVisible(true)
                stationCell:setPosition(cc.p(6, 0))
                local text = me.assignWidget(stationCell, "stationText")
                local queuetag = me.assignWidget(stationCell, "queuetag"):setVisible(false)
                if data.occ == 0 then
                    text:setColor(me.convert3Color_("53b9df"))
                elseif data.occ == -1 or data.occ == -2 then
                    text:setColor(me.convert3Color_("b64343"))
                end
                if data.queueTag == -1 then
                    queuetag:setVisible(false)
                else
                    queuetag:setString(data.queueTag)
                    queuetag:setVisible(true)
                end
                local shorName = data.shorName
                if shorName then
                    text:setString("(" .. shorName .. ")" .. data.name)
                else
                    text:setString(data.name)
                end
                cell:addChild(stationCell)
            end
        else
            local data = gameMap.troopData[tb[idx + 1].m_TroopId]
            if data then
                local stationCell = me.assignWidget(cell, "stationCell")
                local text = me.assignWidget(stationCell, "stationText")
                local queuetag = me.assignWidget(stationCell, "queuetag"):setVisible(false)
                if data.occ == 0 then
                    text:setColor(me.convert3Color_("53b9df"))
                elseif data.occ == -1 or data.occ == -2 then
                    text:setColor(me.convert3Color_("b64343"))
                end
                text:setString(data.name)
                if data.queueTag == -1 then
                    queuetag:setVisible(false)
                else
                    queuetag:setString(data.queueTag)
                    queuetag:setVisible(true)
                end
            end
        end
        return cell
    end

    local function numberOfCellsInTableView(table)
        return num
    end
    self.stationTableView = cc.TableView:create(cc.size(306, 310))
    self.stationTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.stationTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.stationTableView:setPosition(cc.p(0, 0))
    self.stationTableView:setDelegate()
    self.stationTableView:setTag(999)
    me.assignWidget(self.stationInfo, "stationList"):addChild(self.stationTableView)

    self.stationTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.stationTableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.stationTableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.stationTableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.stationTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.stationTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.stationTableView:reloadData()
end

function mapOptMenuLayer:onExit()
    print("mapOptMenuLayer:onExit()")
    me.clearTimer(self.buffTimer)
    UserModel:removeLisener(self.modelkey)
end


function mapOptMenuLayer:popupInfoView(data)
    if data.uid == user.uid then
        NetMan:send(_MSG.worldArmyInfo(data.m_TroopId))
        self:hide()
        return
    end
    self.selecetData = data
    if self.layout == nil then
        self.layout = ccui.Layout:create()
        self.layout:setContentSize(cc.size(me.winSize.width, me.winSize.height))
        self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
        self.layout:setAnchorPoint(cc.p(0, 0))
        self.layout:setPosition(cc.p(0, 0))
        self.layout:setSwallowTouches(true)
        self.layout:setTouchEnabled(true)
        self:addChild(self.layout, me.MAXZORDER)
    end
    local c = cc.CSLoader:createNode("Node_Role_Info.csb")
    local info = me.assignWidget(c, "Panel_Info"):clone()
    info:setTouchEnabled(true)
    info:setSwallowTouches(true)
    self.layout:addChild(info)
    info:setVisible(true)
    info:setAnchorPoint(cc.p(0.5, 0.5))
    info:setPosition(cc.p(me.winSize.width / 2 + 100, me.winSize.height / 2 + 60))
    me.assignWidget(info, "Text_name"):setString(data.name)
    me.assignWidget(info, "fightNum"):setVisible(data.power ~= nil)
    if data.power then
        me.assignWidget(info, "fightNum"):setString(me.toNum(data.power))
    end
    me.assignWidget(info, "Text_union"):setVisible(data.familyName ~= nil)
    if data.familyName then
        me.assignWidget(info, "Text_union"):setString("联盟：" .. data.familyName)
    end
    me.assignWidget(info, "Text_dep"):setVisible(data.degree ~= nil)
    if data.degree then
        me.assignWidget(info, "Text_dep"):setString("职位：" .. me.alliancedegree(data.degree))
    end

    me.registGuiTouchEvent(self.layout, function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self.layout:removeFromParent()
        self.layout = nil
    end )

    me.registGuiClickEvent(me.assignWidget(info, "Button_mail"), function()
        self.layout:removeAllChildren()
        self:popupMailView()
    end )
end

function mapOptMenuLayer:popupMailView(data)
    local mail = sendMailCell:create("sendMailCell.csb")
    if not data then
        if self.selecetData then
            mail:setData(self.selecetData.uid, self.selecetData.name, user.Cross_Sever_Status)
        end
    else
        mail:setData(data.uid, data.name, user.Cross_Sever_Status)
    end
    if pWorldMap then
        pWorldMap:addChild(mail, me.MAXZORDER)
        me.showLayer(mail, "bg_frame")
    end
    
    if self.layout then
        self.layout:removeFromParent()
        self.layout = nil
    end
    self.selecetData = nil
end