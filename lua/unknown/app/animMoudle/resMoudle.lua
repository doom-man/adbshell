-- 资源点
resMoudle = class("resMoudle", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
resMoudle.__index = resMoudle
resMoudle.RES_STATE_IDEL = 1    -- 正常
resMoudle.RES_STATE_WORK = 2    -- 工作       
resMoudle.RES_STATE_EXHAUSTED = 3    -- 枯竭
function resMoudle:create(...)
    local layer = resMoudle.new(...)
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

function resMoudle:ctor()
    print("resMoudle ctor")
    -- 变量state
    self.state = resMoudle.RES_STATE_IDEL
    self.data = nil
    -- 变量ToftId
    self.ToftId = nil
    self.workPoint = 1
    self.m_path = nil
    -- 已经采集了的时间
    self.produceTime = 0
    self.uiAni = nil
end
--- @CityRandResource
function resMoudle:initWithData(data)
    self.data = data
    self:setToftId(data.place)
    local def = data:getDef()
    local kind = def.type
    self.icon:loadTexture(self:getRandIcon(kind), me.localType)
    self.icon:ignoreContentAdaptWithSize(true)
    self:setContentSize(self.icon:getContentSize())
    self.icon:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    if kind == 1 then
        self.gain_img:loadTexture(ICON_RES_FOOD, me.localType)

    elseif kind == 2 then
        self.gain_img:loadTexture(ICON_RES_GOLD, me.localType)
    end

    if self.data.work == resMoudle.RES_STATE_WORK and mainCity.resMoudleBool == true then
        local num = me.toNum(self.data:getDef().worker)
        local dowork = MANI_STATE_GATHER
        if kind == 1 then
            dowork = MANI_STATE_GATHER
        elseif kind == 2 then
            dowork = MANI_STATE_MINING
        end
        --         dump(self.data)
        self:showFarmerWorkDirect(num, dowork)

    elseif self.data.work == resMoudle.RES_STATE_EXHAUSTED and me.toNum(self.data.outValue) == 0 then
        -- 枯竭
        self.gainBtn:setVisible(false)
    elseif self.data.work == resMoudle.RES_STATE_EXHAUSTED and me.toNum(self.data.outValue) > 0 then
        -- 枯竭
        self.gainBtn:setVisible(true)
    end
    local function optcallback(node)
        print(node.opt)
        if node.opt == buildingOptMenuLayer.BTN_GAHTER then
            buildingOptMenuLayer:getInstance():clearnButton()
            self:toGather()
        elseif node.opt == buildingOptMenuLayer.BTN_INFO then
            local resInfo = resInfoLayer:create("resInfoLayer.csb")
            resInfo:initWithData(data)
            me.runningScene():addChild(resInfo, me.MAXZORDER)
            me.showLayer(resInfo, "bg")
        elseif node.opt == buildingOptMenuLayer.BTN_MINING then
            -- todo
            buildingOptMenuLayer:getInstance():clearnButton()
            self:toMining()
        end
    end
    -- 注册点击事件
    me.registGuiTouchEvent(self.icon, function(node, event)
        if event == ccui.TouchEventType.began then
            self.bclicked = true
            node:setSwallowTouches(false)
        elseif event == ccui.TouchEventType.moved then
            local mp = node:getTouchMovePosition()
            local sp = node:getTouchBeganPosition()
            if math.abs(mp.x - sp.x) < 5 and math.abs(mp.y - sp.y) < 5 then
                node:setSwallowTouches(true)
                self.bclicked = true
            else
                node:setSwallowTouches(false)
                self.bclicked = false
            end
        elseif event == ccui.TouchEventType.ended then
            if self.bclicked then
                me.clickAni(node)
                local function callbakc_(node)
                    --   node:safeScale(cp,1.3)
                    buildingOptMenuLayer:getInstance():showResOpt(data, optcallback, self:getstate())
                end
                selectBuilding(self, callbakc_)
                node:setSwallowTouches(true)
            end
        elseif event == ccui.TouchEventType.canceled then
            node:setSwallowTouches(false)
        end
    end )
    self.icon:setSwallowTouches(false)

    -- 注册点击事件 采集
    me.registGuiClickEventByName(self, "optBtn", function(node)
        mainCity.resMoudleBool = false
        mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_WORKER_YES, false)
        if kind == 1 then
            self:toGather()
        elseif kind == 2 then
            self:toMining()
        end
        buildingOptMenuLayer:getInstance():clearnButton()
    end )


    -- 注册点击事件 收获
    me.registGuiClickEvent(self.gainBtn, function(node)
        print("--- gather..")
        mainCity.resMoudleBool = false
        self.gainBtn:setVisible(false)
        self.gainBtn:stopAllActions()
        NetMan:send(_MSG.getRandResource(self.data.place))
        --mainCity:collect(self:getToftId())
        mainCity:collectAction(self:getToftId())
        mainCity:setActionNum(2, self:getToftId())
        if self.data.def.type == 1 then
            mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_FOOD_HARVEST, false)
            -- 粮食
        elseif self.data.def.type == 2 then
            mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_GOLD_HAVREST, false)
            -- 粮食
        end
        me.clearTimer(self.m_timer)
        self.m_timer = me.registTimer(40, function(dt, ret)
            if ret then
                self.gainBtn:setVisible(true)
                self.gainBtn:stopAllActions()
                self.gainBtn:runAction(self.uiAni)
                self.uiAni:gotoFrameAndPlay(0, 40, true)
            end
        end , 0)
    end )

end
function resMoudle:getRandIcon(kind)
    if self.data then
        -- dump(self.data)
        if self.data.work ~= resMoudle.RES_STATE_EXHAUSTED then
            -- 正常 工作
            if kind == 1 then
                return "zhucheng_youguo_1.png"
            elseif kind == 2 then
                return "zhucheng_youkuang_1.png"
            end
        elseif self.data.work == resMoudle.RES_STATE_EXHAUSTED and me.toNum(self.data.outValue) == 0 then
            -- 枯竭
            me.clearTimer(self.m_timer)
            self.gainBtn:setVisible(false)
            if kind == 1 then
                return "zhucheng_youguo_11.png"
            elseif kind == 2 then
                return "zhucheng_youkuang_11.png"
            end
        elseif self.data.work == resMoudle.RES_STATE_EXHAUSTED and me.toNum(self.data.outValue) > 0 then
            -- 枯竭但可收获
            --     print("fffffffffffff")
            me.clearTimer(self.m_timer)
            self.gainBtn:setVisible(true)
            if kind == 1 then
                return "zhucheng_youguo_11.png"
            elseif kind == 2 then
                return "zhucheng_youkuang_11.png"
            end
        end
    end
end
function resMoudle:toGather()
    local num = me.toNum(self.data:getDef().worker)
    if user.curfarmer - user.workfarmer >= num then

        NetMan:send(_MSG.randResource(self:getToftId()))
    else
        showTips(TID_FARMER_NOT_ENOUGH)
    end
end

function resMoudle:toMining()
    local num = me.toNum(self.data:getDef().worker)
    if user.curfarmer - user.workfarmer >= num then

        NetMan:send(_MSG.randResource(self:getToftId()))
    else
        showTips(TID_FARMER_NOT_ENOUGH)
    end
end
function resMoudle:showFarmerWork(num, cmd)
    self.workPoint = 1
    for var = 1, num do
        local farmer = mainCity:getIdleFarmer()
        if farmer then
            local function arrive(node)
                farmer:dirToPoint(self:getCenterPoint())
                farmer:doAction(cmd)
                mainCity:removeFarmerPathById(self:getToftId())
            end
            farmer:setTagBuildingId(self:getToftId())
            farmer:moveOnPaths(self:getPath(), arrive)
            mainCity:showFarmerPath(self:getPath(), self:getToftId(), farmer:getBasePoint())
        end
    end
end
function resMoudle:getPath()
    if self.m_path == nil then
        self.m_path = Queue.new()
        local range = math.floor(self:getToftId() / 1000)
        local index = self:getToftId() % 1000
        local name = "bPace" .. range .. "_" .. index
        print(cfg_path[me.toStr(user.countryId)][name].path)
        local temp = me.split(cfg_path[me.toStr(user.countryId)][name].path, ",")
        local pathNode = me.assignWidget(mainCity.maplayer, "path")
        local lastP = nil
        if temp then
            for key, var in ipairs(temp) do
                local pname = "paht_p" .. var
                local p = me.assignWidget(pathNode, pname)
                lastP = cc.p(p:getPositionX(), p:getPositionY())
                Queue.push(self.m_path, lastP)
            end
        end
    end
    local ctable = me.copyTab(self.m_path)
    local center = self:getCenterPoint()
    local workPoint = me.oval(center, self:getContentSize().width / 2, self:getContentSize().height / 2, self.workPoint * 45 - 180)
    self.workPoint = self.workPoint + 1
    Queue.push(ctable, workPoint)
    return ctable
end
-- 直接到达工作位置
function resMoudle:showFarmerWorkDirect(num, cmd)
    self.workPoint = 1
    for var = 1, num do
        local farmer = mainCity:getIdleFarmer()
        if farmer then
            farmer:setTagBuildingId(self:getToftId())
            farmer:setPosition(self:getPathDirect())
            farmer:dirToPoint(self:getCenterPoint())
            farmer:doAction(cmd)

        end
    end
end
-- 计算出工作位置
function resMoudle:getPathDirect()
    if self.m_path == nil then
        self.m_path = Queue.new()
        local range = math.floor(self:getToftId() / 1000)
        local index = self:getToftId() % 1000
        local name = "bPace" .. range .. "_" .. index
        print(cfg_path[me.toStr(user.countryId)][name].path)
        local temp = me.split(cfg_path[me.toStr(user.countryId)][name].path, ",")
        local pathNode = me.assignWidget(mainCity.maplayer, "path")
        local lastP = nil
        if temp then
            for key, var in ipairs(temp) do
                local pname = "paht_p" .. var
                local p = me.assignWidget(pathNode, pname)
                lastP = cc.p(p:getPositionX(), p:getPositionY())
                Queue.push(self.m_path, lastP)
            end
        end
    end
    local ctable = me.copyTab(self.m_path)
    local center = self:getCenterPoint()
    local workPoint = me.oval(center, self:getContentSize().width / 2, self:getContentSize().height / 2, self.workPoint * 45 - 180)
    self.workPoint = self.workPoint + 1
    Queue.push(ctable, workPoint)
    return workPoint
end


function resMoudle:getstate()
    return self.state
end
function resMoudle:setstate(state_)
    self.state = state_ or resMoudle.RES_STATE_EXHAUSTED
    local def = self.data:getDef()
    local kind = def.type
    if kind == 1 then

        self.optBtn:loadTextureNormal("zhucheng_cj_1_zhengchang.png", me.localType)
    elseif kind == 2 then

        self.optBtn:loadTextureNormal("zhucheng_cj_zhengchang.png", me.localType)
    end
    self.optBtn:ignoreContentAdaptWithSize(false)
    self.optBtn:setContentSize(90, 99)

    if self.state == resMoudle.RES_STATE_IDEL then
        self.optBtn:setVisible(true)
        self.optBtn:stopAllActions()
        self.gainBtn:setVisible(false)
        self.uiAni:gotoFrameAndPlay(0, 40, true)

    elseif self.state == resMoudle.RES_STATE_WORK then
        self.optBtn:setVisible(false)
        self.gainBtn:setVisible(false)
        -- self.gainBtn:setVisible(true)
        local num = me.toNum(self.data:getDef().worker)
        local dowork = MANI_STATE_GATHER
        if kind == 1 then
            dowork = MANI_STATE_GATHER

        elseif kind == 2 then
            dowork = MANI_STATE_MINING

        end
        self:showFarmerWork(num, dowork)
        if self.data.outValue > 0 then
            self.gainBtn:setVisible(true)
            self.gainBtn:stopAllActions()
            self.gainBtn:runAction(self.uiAni)
            self.uiAni:gotoFrameAndPlay(0, 40, true)
        else
            me.clearTimer(self.m_timer)
            self.m_timer = me.registTimer(40, function(dt, ret)
                if ret then
                    self.gainBtn:setVisible(true)
                    self.gainBtn:stopAllActions()
                    self.uiAni:gotoFrameAndPlay(0, 40, true)
                end
            end , 0)
        end
    elseif self.state == resMoudle.RES_STATE_EXHAUSTED then
        self.optBtn:setVisible(false)
        self.gainBtn:setVisible(false)
        if self.data.outValue > 0 then
            self.gainBtn:setVisible(true)
            self.gainBtn:stopAllActions()
            self.gainBtn:runAction(self.uiAni)
            self.uiAni:gotoFrameAndPlay(0, 40, true)
        end
    end
end
function resMoudle:getToftId()
    return self.ToftId
end
function resMoudle:setToftId(ToftId_)
    self.ToftId = ToftId_
end
function resMoudle:getCenterPoint()
    return cc.p(self:getPositionX() + self:getContentSize().width / 2, self:getPositionY() + self:getContentSize().height / 2)
end
function resMoudle:init()
    print("resMoudle init")
    self.icon = me.assignWidget(self, "icon")
    self.icon:ignoreContentAdaptWithSize(true)
    self.optBtn = me.assignWidget(self, "optBtn")
    self.fIcon = me.assignWidget(self, "fIcon")
    self.kindIcon = me.assignWidget(self, "kindIcon")
    self.fNum = me.assignWidget(self, "fNum")
    self.gainBtn = me.assignWidget(self, "gainBtn")
    self.gain_img = me.assignWidget(self, "gain_img")
    self.uiAni = cc.CSLoader:createTimeline("build/resLayer.csb")
    self:runAction(self.uiAni)
    --    self.msgLisener =  UserModel:registerLisener(function (msg)

    -- end)


    return true
end
function resMoudle:onEnter()
    print("resMoudle onEnter")

end
function resMoudle:onExit()
    print("resMoudle onExit")
    me.clearTimer(self.m_timer)
    -- UserModel:removeLisener(self.msgLisener)
end
