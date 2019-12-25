mapObj = class("mapObj", function()
    return cc.CSLoader:createNode("build/mapCell.csb")
end )
mapObj.__index = mapObj
-- mapCellData.id
function mapObj:create(id)
    local layer = mapObj.new()
    layer.m_id = id
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
CELL_STATE_TAG = 157157157
CELL_EVENT_TAG = 156156156
CELL_MIANZ_TAG = 146146146
CELL_ARCH_TAG = 17423131
CELL_ARCHBAT_TAG = 18231231
function mapObj:ctor()
    self.m_id = nil
    self.m_TroopId = nil
    self.timeBar = nil

    self.lastEventType = 0
end
-- [Comment]
-- 当前地块驻扎 或者采集等的军队ID 有ID的地块则不更新
function mapObj:getTroopId()
    return self.m_TroopId
end
function mapObj:setTroopId(m_TroopId_)
    self.m_TroopId = m_TroopId_
end

function mapObj:init()
    self.Image_Occupy = me.assignWidget(self, "Image_Occupy")
    self.icon = me.assignWidget(self, "icon")
    self.Node_Event = me.assignWidget(self, "Node_Event")
    self.Node_Manor = me.assignWidget(self, "Node_Manor")
    self.Node_Boss = me.assignWidget(self, "Node_Boss")
    self.Node_Event_Mark = me.assignWidget(self, "Node_Event_Mark")
    self.Node_Arch_Mark = me.assignWidget(self, "Node_Arch_Mark")
    self.Node_STATION = me.assignWidget(self, "Node_STATION")
    self.Node_MZ = me.assignWidget(self, "Node_MZ")
    self.icon:ignoreContentAdaptWithSize(true)
    self.name = me.assignWidget(self, "name")
    self.nameBg = me.assignWidget(self, "nameBg")
    self.protectIcon = me.assignWidget(self, "protectIcon")
    self.captiveIcon = me.assignWidget(self, "captiveIcon")
    self.isInCross = me.assignWidget(self, "isInCross")
    self.totem = me.assignWidget(self, "totem")
    self.Image_role_title = me.assignWidget(self, "Image_role_title")
    self:initObj()
    return true
end

function mapObj:getCellData()
    local data = gameMap.mapCellDatas[self.m_id]
    return data
end
function mapObj:initObj()
    self.icon:setVisible(false)
    self.Node_Event:setVisible(false)
    self.Node_Boss:setVisible(false)
    self.Node_Event_Mark:setVisible(false)
    self.Node_Arch_Mark:setVisible(false)
    self.Node_STATION:setVisible(false)
    self.nameBg:setVisible(false)
    self.isInCross:setVisible(false)
    self:initOccupyState()
    self:updateEventState()
    self:updateTimeBar()
end
function mapObj:initName()
    local pName = self.nameBg:clone()
    self.nameBg:setVisible(false)
    return pName
end
function mapObj:updateTimeBar()
    local data = self:getCellData()
    if data.pstatus and data.gtime and data.gtime > 0 and data.origin ~= 1 then
        if data.pstatus == 2 then
            self.Node_MZ:setVisible(true)
            if nil == self.Node_MZ:getChildByTag(CELL_MIANZ_TAG) then
                local img = ccui.ImageView:create()
                img:loadTexture("waicheng_tubiao_mianzhan.png", me.plistType)
                img:setTag(CELL_MIANZ_TAG)
                self.Node_MZ:addChild(img)
            end
        elseif data.pstatus == 1 and me.toNum(data.ownerId) == me.toNum(user.uid) then
            self:initTimeBar()
        end
    else
        if nil ~= self.Node_MZ:getChildByTag(CELL_MIANZ_TAG) then
            -- 去除免战图
            local chl = self.Node_MZ:getChildByTag(CELL_MIANZ_TAG)
            chl:removeFromParentAndCleanup(true)
        end
        self:clearTimeBar()
    end
end
function mapObj:initTimeBar()
    local data = self:getCellData()
    if self.timeBar == nil then
        local maxtime = 1800
        local gtime = data.gtime
        self.timeBar = me.createNode("loadingBar.csb")
        local bg = me.assignWidget(self.timeBar, "bg")
        local Text_time = me.assignWidget(self.timeBar, "Text_time")
        local LoadingBar_time = me.assignWidget(self.timeBar, "LoadingBar_time")
        self.timeBar:setPosition(cc.p(self:getContentSize().width / 2 - self.timeBar:getContentSize().width / 2, self:getContentSize().height / 2))
        local t = 0
        LoadingBar_time:setPercent(0)
        self.gTimer = me.registTimer(gtime, function(dt)
            gtime = gtime - dt
            if math.floor(t) ~= math.floor(maxtime - gtime) then
                t = maxtime - gtime
                if t > 0 then
                    Text_time:setString(me.formartSecTime(gtime))
                    LoadingBar_time:setPercent(t * 100 / maxtime)
                end
            end
        end )
        self:addChild(self.timeBar, 10)
    end
end
function mapObj:clearTimeBar()
    if self.timeBar and self.timeBar.getPositionX then
        self.timeBar:removeFromParentAndCleanup(true)
        local chl = self.Node_MZ:getChildByTag(CELL_MIANZ_TAG)
        if chl and chl.getPositionX then
            chl:removeFromParentAndCleanup(true)
        end
        me.clearTimer(self.gTimer)
        self.timeBar = nil
    end
end
function mapObj:initOccupyState()
    local cdata = self:getCellData()
    local ostate = cdata:getOccState()
    self.Image_Occupy:setVisible(false)

    local objStatePng = {
        [OCC_STATE_OWN] = "own.png",
        [OCC_STATE_ALLIED] = "allied.png",
        [OCC_STATE_HOSTILE] = "hostility.png",
        [OCC_STATE_CAPTIVE_ALLYED] = "lxm.png",
        [OCC_STATE_CAPTIVE] = "cursor_lx.png",
        [OCC_STATE_CAPTIVE_MATSTER_FAMILY] = "cursor_zs.png"
    }
    if objStatePng[ostate] then
        self.Image_Occupy:setVisible(true)
        if ostate == OCC_STATE_ALLIED then
            if user.Cross_Sever_Status == mCross_Sever then
                self.Image_Occupy:loadTexture(objStatePng[ostate], me.plistType)
            else
                self.Image_Occupy:loadTexture("allied_c.png", me.plistType)
            end
        else
            self.Image_Occupy:loadTexture(objStatePng[ostate], me.plistType)
        end
    end
end
function mapObj:updateEventState()

    local mdata = self:getCellData()
    local colldata = mdata:bHaveCollecting()
    if colldata then
        self.Node_Event_Mark:setVisible(true)
        if colldata:getStatus() == EXPED_STATE_COLLECTING then
            local img = ccui.ImageView:create()
            if colldata.occ == 1 then
                img:loadTexture("shijian_zhanling_ziji.png", me.localType)
            elseif colldata.occ == 0 then
                img:loadTexture("shijian_zhanling_mengyou.png", me.localType)
            elseif colldata.occ == -1 or colldata.occ == -2 then
                img:loadTexture("shijian_zhanling_dieren.png", me.localType)
            else
                img:loadTexture("shijian_zhanling_ziji.png", me.localType)
            end
            img:setScale(0.5)
            img:setPosition(0, 30)
            img:setTag(CELL_EVENT_TAG)
            self.Node_Event_Mark:addChild(img)

        end
    else
        self.Node_Event_Mark:setVisible(false)
        self.Node_Event_Mark:removeChildByTag(CELL_EVENT_TAG)
    end

    -- 驻扎
    local tdata = mdata:bHaveStation()
    if tdata then
        if tdata:getStatus() == EXPED_STATE_STATIONED or tdata:getStatus() == THRONE_DEFEND then
            self.Node_STATION:setVisible(true)
            if self.Node_STATION:getChildByTag(CELL_STATE_TAG) == nil then
                local img = ccui.ImageView:create()
                img:setTag(CELL_STATE_TAG)
                if (tdata:getStatus() == THRONE_DEFEND or tdata:getStatus() == EXPED_STATE_STATIONED) and mdata.pointType == POINT_THRONE then
                    img:loadTexture("wangzuo_zhushou_datu.png", me.localType)
                    img:setPosition(0, 0)
                else
                    img:loadTexture("waicheng_zhuzha_bing_xiao.png", me.localType)
                    img:setPosition(0, 0)
                end
                self.Node_STATION:addChild(img)
            end
        end
    else
        self.Node_STATION:setVisible(false)
        self.Node_STATION:removeChildByTag(CELL_STATE_TAG)
    end
    -- 正在考古
    local archdata = mdata:bHaveArch()
    if archdata then
        self.Node_Arch_Mark:setVisible(true)
        if archdata:getStatus() == EXPED_STATE_ARCHING then
            print("archdata.occ .." .. archdata.occ)
            if archdata.occ == 1 then
                if self.timeArchBar == nil then
                    local img = ccui.ImageView:create()
                    img:loadTexture("waicheng_tubiao_kaogu_zhufang.png", me.plistType)
                    -- img:setScale(0.5)
                    img:setPosition(0, 20)
                    img:setTag(CELL_ARCH_TAG)
                    self.Node_Arch_Mark:addChild(img)
                    dump(archdata)
                    self.timeArchBar = me.createNode("loadingBar.csb")
                    local bg = me.assignWidget(self.timeArchBar, "bg")
                    self.timeArchBar:setTag(CELL_ARCHBAT_TAG)
                    bg:loadTexture("waicheng_kaogu_kuang.png")

                    local Text_time = me.assignWidget(self.timeArchBar, "Text_time")
                    local LoadingBar_time = me.assignWidget(self.timeArchBar, "LoadingBar_time")
                    self.timeArchBar:setPosition(cc.p(self.Node_Arch_Mark:getContentSize().width / 2 -
                    self.timeArchBar:getContentSize().width / 2,
                    self.Node_Arch_Mark:getContentSize().height - self.timeArchBar:getContentSize().height))
                    local t = 0
                    LoadingBar_time:setPercent(0)
                    local archTime = archdata.archBookTime
                    local gtime =(archdata.countdown) % archTime
                    local t = 0
                    self.gArchTimer = me.registTimer(-1, function(dt)
                        gtime = gtime - dt
                        if gtime <= 0 then
                            t = 0
                            gtime = archTime
                            LoadingBar_time:setPercent(0)
                            Text_time:setString(me.formartSecTime(gtime))
                        else
                            if math.floor(t) ~= math.floor(archTime - gtime) then
                                t = archTime - gtime
                                if t >= 0 then
                                    Text_time:setString(me.formartSecTime(gtime))
                                    LoadingBar_time:setPercent(t * 100 / archTime)
                                end
                            end
                        end
                    end , 1)
                    self.Node_Arch_Mark:addChild(self.timeArchBar, 10)
                end
            end
        end
    else
        me.clearTimer(self.gArchTimer)
        self.Node_Arch_Mark:setVisible(false)
        self.Node_Arch_Mark:removeAllChildren()
        self.timeArchBar = nil
    end
    if mdata:bHaveEvent() then
        -- 有事件
        local edata = mdata:getEventDef()
        if edata then
            self.icon:setVisible(false)
            self.Node_Event:setVisible(true)
            print("self.Node_Event:getChildrenCount() = " .. self.Node_Event:getChildrenCount())
            if self.Node_Event:getChildrenCount() == 0 then
                self.lastEventType = edata.type
                if edata.type == 5 then
                    local ani = createArmature("boss_bing_" .. edata.landitem)
                    ani:getAnimation():playWithIndex(0)
                    ani:getAnimation():setSpeedScale(0.5)
                    self.Node_Event:setPosition(cc.p(120, 51))
                    self.Node_Event:addChild(ani)
                elseif edata.type == 6 then
                    local ani = createArmature("bing_shijian_daoju")
                    ani:getAnimation():play("dile")
                    self.Node_Event:addChild(ani)
                else
                    local ani = nil
                    if mdata.eventWagon == 1 then
                        ani = createArmature("boss_wagon")
                        ani:getAnimation():play("idle2")
                        ani:setPosition(cc.p(-60,10))
                    else
                        ani = createArmature("wagon")
                        ani:getAnimation():play("idle2")
                        ani:setPosition(cc.p(-20,20))
                    end
                    self.Node_Event:addChild(ani)
                    local mark = me.createNode("Node_EventMark.csb")
                    local level = me.assignWidget(mark, "Text_Level")
                    level:setString(edata.caijilv)
                    mark:setPosition(cc.p(30, -20))
                    self.Node_Event:addChild(mark, 1)
                end
            else
                if self.lastEventType ~= edata.type then
                    self.Node_Event:removeAllChildren()
                    if edata.type == 5 then
                        local ani = createArmature("boss_bing_" .. edata.landitem)
                        ani:getAnimation():playWithIndex(0)
                        ani:getAnimation():setSpeedScale(0.5)
                        self.Node_Event:setPosition(cc.p(120, 51))
                        self.Node_Event:addChild(ani)
                    elseif edata.type == 6 then
                        local ani = createArmature("bing_shijian_daoju")
                        ani:getAnimation():play("dile")
                        self.Node_Event:addChild(ani)
                    else
                        local ani = nil
                        if mdata.eventWagon == 1 then
                            ani = createArmature("boss_wagon")
                            ani:getAnimation():play("idle2")
                            ani:setPosition(cc.p(-60,10))
                        else
                            ani = createArmature("wagon")
                            ani:getAnimation():play("idle2")
                            ani:setPosition(cc.p(-20,20))
                        end
                        self.Node_Event:addChild(ani)
                        local mark = me.createNode("Node_EventMark.csb")
                        local level = me.assignWidget(mark, "Text_Level")
                        level:setString(edata.caijilv)
                        mark:setPosition(cc.p(30, -20))
                        self.Node_Event:addChild(mark, 1)
                    end
                end

            end
        else
            self.Node_Event:setVisible(false)
            self.Node_Event:removeAllChildren()
        end
    else
        self.Node_Event:setVisible(false)
        self.Node_Event:removeAllChildren()
    end
    -- 世界BOSS
    if mdata:bHaveBoss() then
        local bossdata = mdata:getBossData()
        local bossDef = bossdata:getDef()
        if bossdata then
            self.icon:setVisible(false)
            self.Node_Boss:setVisible(true)
            -- self:setLocalZOrder(10)
            if self.Node_Boss:getChildrenCount() == 0 then
                self.lastBossType = bossDef.icon
                local aniName = nil
                self.Node_Boss:setPosition(cc.p(118, 61))
                if me.toNum(bossDef.icon) then
                    aniName = "boss_bing_" .. bossDef.icon
                    self.Node_Boss:setPosition(cc.p(120, 51))
                else
                    aniName = "boss_bing_1"
                end
                local ani = createArmature(aniName)

                if me.toNum(bossDef.icon) == 81 or me.toNum(bossDef.icon) == 83 or me.toNum(bossDef.icon) == 84 then
                    ani:getAnimation():play("idle2")
                else
                    ani:getAnimation():playWithIndex(0)
                end
                --------- 如果是飞龙，单独设置坐标 ---------
                if me.toNum(bossDef.icon) == 81 then
                    ani:setPosition(cc.p(-10,124/2 - 20))
                end
                -------------------------------------------
                ani:getAnimation():setSpeedScale(1)
                self.Node_Boss:addChild(ani)
            else
                if self.lastBossType ~= bossDef.icon then
                    self.Node_Boss:removeAllChildren()
                    self.Node_Boss:setPosition(cc.p(118, 61))
                    self.lastBossType = bossDef.icon
                    local aniName = nil
                    if me.toNum(bossDef.icon) then
                        aniName = "boss_bing_" .. bossDef.icon
                        self.Node_Boss:setPosition(cc.p(120, 51))
                    else
                        aniName = "boss_bing_1"
                    end
                    local ani = createArmature(aniName)
                    -- ani:getAnimation():play("idle")
                    if me.toNum(bossDef.icon) == 81 or me.toNum(bossDef.icon) == 83 or me.toNum(bossDef.icon) == 84 then
                        ani:getAnimation():play("idle2")
                    else
                        ani:getAnimation():playWithIndex(0)
                    end
                    --------- 如果是飞龙，单独设置坐标 ---------
                    if me.toNum(bossDef.icon) == 81 then
                        ani:setPosition(cc.p(-10,124/2 - 20))
                    end
                    -------------------------------------------
                    ani:getAnimation():setSpeedScale(0.5)
                    self.Node_Boss:addChild(ani)
                end

            end
        else
            self.Node_Boss:setVisible(false)
            self.Node_Boss:removeAllChildren()
        end
    else

        self.Node_Boss:setVisible(false)
        self.Node_Boss:removeAllChildren()
    end
end
function mapObj:getOwnerData()
    return self:getCellData():getOwnerData()
end
function mapObj:setPos(sp)
    self:setPosition(cc.p(sp.x - self:getContentSize().width / 2, sp.y - self:getContentSize().height / 2))
end
function mapObj:onExit()
    self:clearTimeBar()
    me.clearTimer(self.gArchTimer)
end
function mapObj:purge(args)
    self:removeFromParentAndCleanup(true)
end
function mapObj:onEnter()

end