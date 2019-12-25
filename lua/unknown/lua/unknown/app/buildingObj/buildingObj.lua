-- 建筑对象
buildingObj = class("buildingObj", function()
    return cc.CSLoader:createNode("build/building.csb")
end )

buildingObj.__index = buildingObj
local i_width = 98
local i_height = 50

USETYPE_ALL = { key = 112, name = "通用" } -- 通用加速道具

BUILDINGSTATE_NORMAL = { key = 1, name = "正常", btn = nil }
BUILDINGSTATE_BUILD = { key = 2, name = "建造", btn = nil }  -- 建造 (可以联盟帮助)
BUILDINGSTATE_LEVEUP = { key = 3, name = "升级", btn = nil } -- 升级 (可以联盟帮助)
BUILDINGSTATE_CHANGE = { key = 4, name = "转换", btn = nil } -- 转换 (可以联盟帮助)

-- 以下的几种工作状态，对应其工作状态的名字，和其特有的按钮,和提示
BUILDINGSTATE_WORK_TRAIN = { key = 114, name = "训练", btn = buildingOptMenuLayer.BTN_TRAIN } -- 训练
BUILDINGSTATE_WORK_STUDY = { key = 113, name = "研究", btn = buildingOptMenuLayer.BTN_STUDY } -- 研究 (可以联盟帮助)
BUILDINGSTATE_WORK_PRODUCE = { key = 116, name = "制造", btn = buildingOptMenuLayer.BTN_BUILD } -- 制造（陷阱）
BUILDINGSTATE_WORK_TREAT = { key = 115, name = "治疗", btn = buildingOptMenuLayer.BTN_TREAT } -- 治疗 (可以联盟帮助)

BUILDINGSTATE_TOTAL = {
    BUILDINGSTATE_NORMAL,
    BUILDINGSTATE_BUILD,
    BUILDINGSTATE_LEVEUP,
    BUILDINGSTATE_CHANGE,
    BUILDINGSTATE_WORK_TRAIN,
    BUILDINGSTATE_WORK_STUDY,
    BUILDINGSTATE_WORK_PRODUCE,
    BUILDINGSTATE_WORK_TREAT
}
OBJ_ANI = "obj_ani"

function buildingObj:create()
    local layer = buildingObj.new()
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
function buildingObj:ctor()
    print("buildingObj ctor")
    self.icon = nil
    self.name = nil
    self.menuGroup = { }
    self.bclicked = true
    self.state = BUILDINGSTATE_NORMAL.key
    self.toftid = nil
    self.pace_width = 0
    self.m_path = nil
    self.nearPoint = 1
    self.workPoint = 0
    self.nearofset = -90
    self.canStartTime = true
    self.pAnimation = nil
    -- 空闲状态特效
    self.pWounde = nil
    -- 伤兵特效
    self.pCityAttack = nil
    -- 收到攻击特效
    self.pPlayTime = 0
    -- 空闲状态特效播放持续时间
    self.pPauseTime = 0
    -- 空闲状态特效暂停时间
    -- 计时器
    self.produce_timer = nil
    -- 单个训练时间的本地的偏移量
    self.curTime = 0
    -- 5分钟免费状态
    self.freeBtnState = false
    -- 有新瞭望塔信息状态
    self.towerBtnState = false
    -- 联盟帮助状态
    self.helpBtnState = false
    -- 远征按钮
    self.netBattleBtnState = false
    -- 联盟帮助状态
    self.captiveBtnState = false

    self.drawNode = nil

    -- 当前倒计时时间
    self.time = nil
    -- 最大倒计时时间
    self.maxTime = nil
    -- 当前建筑物正在研究的科技
    self.techDef = nil

    self.resInfo = nil

    self.isBusy = nil

    -- 建筑物建造或者升级完成提示
    self.BuildTipStr = TID_BUILDINGOBJ_BUILDCOMPLETE

end

function buildingObj:init()
    print("buildingObj init")
    self:initialize()
    return true
end

function buildingObj:getCurTime()
    return self.curTime
end
function buildingObj:initDraw()
    local w = self.pace_width

end
-- 初始化
function buildingObj:initialize()
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.icon = me.assignWidget(self, "icon")
    self.name = me.assignWidget(self, "name")
    self.icon:ignoreContentAdaptWithSize(true)
    self.produceLayer = me.assignWidget(self, "produceLayer")
    self.farmerProduceBar = me.assignWidget(self, "ProduceBar")
    self.fIcon = me.assignWidget(self.farmerProduceBar, "fIcon")
    self.fInfo = me.assignWidget(self.farmerProduceBar, "fInfo")
    self.fInfo_num = me.assignWidget(self.farmerProduceBar, "fInfo_num")
    self.fLoadbar = me.assignWidget(self.farmerProduceBar, "fLoadbar")
    self.levelupani = me.assignWidget(self, "levelupLayer")
    self.helpBtn = me.assignWidget(self, "Button_help")
    self.totem = me.assignWidget(self, "totem")
    self.helpBtn:setVisible(false)
    self.helpBtn:addTouchEventListener( function(node, event)
        if event == ccui.TouchEventType.ended then
            -- 通信
            if self.freeBtnState then
                NetMan:send(_MSG.buildQuickFree(self:getToftId()))
                buildingOptMenuLayer:getInstance():clearnButton()
                self.helpBtn:setVisible(false)
            elseif self.netBattleBtnState then
                NetMan:send(_MSG.Cross_Promotion_List())
                local netBattleEnterLayer = netBattleEnterLayer:create("netBattleEnterLayer.csb")
                me.popLayer(netBattleEnterLayer)
            elseif self.helpBtnState then
                buildingOptMenuLayer:getInstance():clearnButton()
                local def = self:getDef()
                if def.type == cfg.BUILDING_TYPE_CENTER then
                    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
                        NetMan:send(_MSG.requestHelpFamily(self.toftid))
                        NetMan:send(_MSG.allHelp())
                    else
                        NetMan:send(_MSG.allHelp())
                    end
                else
                    NetMan:send(_MSG.requestHelpFamily(self.toftid))
                end
                self.helpBtn:setVisible(false)
                self.helpBtnState = false
                self:showTowerBtn()
            elseif self.towerBtnState then
                buildingOptMenuLayer:getInstance():clearnButton()
                if self:getDef().type == cfg.BUILDING_TYPE_TOWER then
                    print("瞭望塔点击事件！！！！")
                    local eiv = EventInforView:create("eventInfor.csb")
                    mainCity:addChild(eiv, me.MAXZORDER)
                    me.showLayer(eiv, "bg_frame")
                    buildingOptMenuLayer:getInstance():clearnButton()
                    self.helpBtn:setVisible(false)
                    self.towerBtnState = false
                end
            elseif self.captiveBtnState then
                buildingOptMenuLayer:getInstance():clearnButton()
                local pCaptiveView = CaptiveView:create("CaptiveView.csb")
                mainCity:addChild(pCaptiveView, me.MAXZORDER)
                me.showLayer(pCaptiveView, "bg")
            end
        end
    end )
    -- 训练按钮
    self.btn_train = me.assignWidget(self, "btn_train")
    self.btn_train:setVisible(false)
    me.registGuiClickEvent(self.btn_train, function(sender)
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.prodSoldierView(self:getToftId()))
    end )
end
function buildingObj:showLevel()
    local Image_Level_bg = me.assignWidget(self, "Image_Level_bg")
    if self:getState() == BUILDINGSTATE_BUILD.key then
        Image_Level_bg:setVisible(false)
    else
        local def = self:getDef()
        if def.levelshow then
            local ctime = me.split(def.levelshow, ";")
            local time = getCenterBuildingTime() + 1
            local ds = nil
            if  ctime[time] then
                 ds = ctime[time]
            else
                ds = ctime[1]
            end
            local c = me.split(ds, ",")
            Image_Level_bg:setPosition(tonumber(c[1]), tonumber(c[2]))
            Image_Level_bg:setVisible(true)
            local level = def.level
            local ten = math.floor(level / 10)
            local x = level % 10
            local level2 = me.assignWidget(Image_Level_bg, "level2")
            local level1 = me.assignWidget(Image_Level_bg, "level1")
            if ten == 0 then
                level1:setVisible(false)
                level2:setPosition(23, 23)
                level2:setString(x)
            else
                level1:setVisible(true)
                level1:setPosition(17, 20)
                level2:setPosition(26, 25)
                level2:setString(x)
                level1:setString(ten)
            end
        else
            Image_Level_bg:setVisible(false)
        end
    end
end
function buildingObj:getDef()
    return self:getData():getDef()
end
function buildingObj:getData()
    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
        self.data = user.buildingDateLine[self:getToftId()]
    else
        self.data = user.building[self:getToftId()]
    end
    return self.data
end
-- 取消所有工作
function buildingObj:cancelWorking()
    if user.building[self:getToftId()] then
        if user.building[self:getToftId()].state == BUILDINGSTATE_LEVEUP.key or
            user.building[self:getToftId()].state == BUILDINGSTATE_CHANGE.key then
            print(" 取消升级/转换  ")
            user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
            self:initBuildForData(user.building[self:getToftId()])
            self:hideFreeHelpBtn()
            mainCity:orderFarmerBack(self:getToftId())
        elseif user.building[self:getToftId()].state == BUILDINGSTATE_WORK_TRAIN.key or
            user.building[self:getToftId()].state == BUILDINGSTATE_WORK_PRODUCE.key then

            print("取消训练/制造")
            self:stopTraining()
        elseif user.building[self:getToftId()].state == BUILDINGSTATE_WORK_STUDY.key then
            print("取消研究")
            self:stopStudying()
        elseif user.building[self:getToftId()].state == BUILDINGSTATE_WORK_TREAT.key then
            print("取消治疗")
            self:stoprTreating()
        elseif user.building[self:getToftId()].state == BUILDINGSTATE_CHANGE.key then
            print("取消转换")
            self:stopChanging()
        end
    else
        -- 取消建造,从地图上消失
        print(" 取消建造  ")
        mainCity:orderFarmerBack(self:getToftId())
        self:hideFreeHelpBtn()
        local toft = mainCity:getCroundworkById(self:getToftId())
        if toft then
            toft.used = false
        end
        mainCity.buildingMoudles[self:getToftId()] = nil
        self:removeFromParentAndCleanup(true)
    end
end
function buildingObj:updateSkin()
    if user.adornment then
        if user.adornment == 0 then
            self.icon:loadTexture(buildIcon(self:getDef()), me.plistType)
        else
            local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(user.adornment)]
            self.icon:loadTexture("cityskin" .. skindata.icon .. "_1.png", me.localType)
        end
        if self:getDef().type ~= cfg.BUILDING_TYPE_MONK then
            self.icon:loadNormalTransparentInfoFromFile()
        end
    end
    if user.totem and user.totem > 0 then
        local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(user.totem)]
        self.totem:loadTexture("skin" .. skindata.icon .. ".png", me.localType)
        self.totem:ignoreContentAdaptWithSize(true)
        self.totem:setVisible(true)
    else
        self.totem:setVisible(false)
    end
end
function buildingObj:initBuildForData(data_)
    print("initBuildForData.index = " .. data_.index)
    local def = data_:getDef()
    self:setToftId(data_.index)
    -- 更新训练提示按钮
    self:updateTrainTipBtn(def.type)
    if data_.state ~= nil then
        self:setState(data_.state, true)
    end
    if self:getState() == BUILDINGSTATE_BUILD.key then
        self:initBuildState(data_)
    elseif self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
        self:initLevelUpState(data_)
    else
        self:initNormalState(data_)
    end
    local function optcallcallback(node)
        print(node.opt)
        self:doOptcallback(node.opt)
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
                    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
                        buildingOptMenuLayer:getInstance():showBuildingOpt(user.buildingDateLine[self:getToftId()], optcallcallback)
                    else
                        buildingOptMenuLayer:getInstance():showBuildingOpt(user.building[self:getToftId()], optcallcallback)
                    end
                end
                selectBuilding(self, callbakc_)
                self:playVoc()
                node:setSwallowTouches(true)
            end
        elseif event == ccui.TouchEventType.canceled then
            node:setSwallowTouches(false)
        end
    end )
    self.icon:setSwallowTouches(false)
    --    me.doLayout(self.produceLayer, self:getContentSize())
    --    me.doLayout(self.levelupani, self:getContentSize())
    me.doLayout(self, self:getContentSize())
    self:BuildSleepAnimation()
    local kind = def.type
    if kind == cfg.BUILDING_TYPE_CENTER then
        self:updateSkin()
    end
    self:showLevel()
end

-- 更新训练提示按钮
function buildingObj:updateTrainTipBtn(buildType)
    local tempImg
    if buildType == cfg.BUILDING_TYPE_BARRACK then
        tempImg = "zhucheng_xunlian_tip_binying.png"
    elseif buildType == cfg.BUILDING_TYPE_RANGE then
        tempImg = "zhucheng_xunlian_tip_bachang.png"
    elseif buildType == cfg.BUILDING_TYPE_HORSE then
        tempImg = "zhucheng_xunlian_tip_majiu.png"
    elseif buildType == cfg.BUILDING_TYPE_SIEGE then
        tempImg = "zhucheng_xunlian_tip_wuqi.png"
    elseif buildType == cfg.BUILDING_TYPE_WONDER then
        tempImg = "zhucheng_xunlian_tip_qiji.png"
    end
    if tempImg then
        self.btn_train:loadTextures(tempImg, "", "", me.localType)
    end
end

function buildingObj:playVoc()
    local def = self:getDef()
    local kind = def.type
    local state = self:getData().state
    local pMusicStr = nil
    -- 播放的音乐名字

    if kind == cfg.BUILDING_TYPE_CENTER then
        -- 城镇中心
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_CENTER
    elseif kind == cfg.BUILDING_TYPE_HOUSE then
        -- 房屋
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_HOUSE
    elseif kind == cfg.BUILDING_TYPE_DOOR then
        -- 城门
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_DOOR
    elseif kind == cfg.BUILDING_TYPE_TOWER then
        -- 瞭望塔
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_TOWER
    elseif kind == cfg.BUILDING_TYPE_BARRACK then
        -- 军营
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_BARRACK
    elseif kind == cfg.BUILDING_TYPE_RANGE then
        -- 靶场
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_RANGE
    elseif kind == cfg.BUILDING_TYPE_HORSE then
        -- 马厩
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_HORSE
    elseif kind == cfg.BUILDING_TYPE_BLACKSMITH then
        -- 铁匠铺
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_BLACKSMIT
    elseif kind == cfg.BUILDING_TYPE_SIEGE then
        -- 武器场
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_SIGIE
    elseif kind == cfg.BUILDING_TYPE_ABBEY then
        -- 修道院
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_ABBEY
    elseif kind == cfg.BUILDING_TYPE_CASTLE then
        -- 城堡
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_CASTLE
    elseif kind == cfg.BUILDING_TYPE_COLLEGE then
        -- 大学
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_COLLEGE
    elseif kind == cfg.BUILDING_TYPE_FOOD then
        -- 磨坊
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_FOOD
    elseif kind == cfg.BUILDING_TYPE_LUMBER then
        -- 伐木场
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_LUMBER
    elseif kind == cfg.BUILDING_TYPE_MARKET then
        -- 市场
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_MARKET
    elseif kind == cfg.BUILDING_TYPE_WONDER then
        -- 奇迹
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_WONDER
    elseif kind == cfg.BUILDING_TYPE_STONE then
        -- 采石场
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_STONE
    end

    local state = self:getData().state
    if state == BUILDINGSTATE_BUILD.key then
        -- 建造
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_BUILF_TRAIN
    elseif state == BUILDINGSTATE_LEVEUP.key or state == BUILDINGSTATE_CHANGE.key then
        -- 升级
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_BUILD_UPGRADE
    elseif state == BUILDINGSTATE_WORK_STUDY.key then
        -- 升级
        pMusicStr = MUSIC_TYPE.MUSIC_EFFECT_CITY_BUILD_STUDY
    end

    if pMusicStr ~= nil then
        mAudioMusic:setPlayEffect(pMusicStr, false, true)
    end
end
-- 获取建造或者升级 加速立即完成的消费
function buildingObj:getImmeCost()
    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
        --        local x = 1 - self.time / self.maxTime
        --        local minTime = self:getDef().time2
        --        local xtime = minTime * x
        local xtime = math.max(self.maxTime - self.time -(user.propertyValue["FreeTime"] or 0), 0)
        local tprice = getXresPrice(1, xtime) * xtime
        return math.ceil(tprice)
    elseif self:getState() == BUILDINGSTATE_WORK_TRAIN.key or self:getState() == BUILDINGSTATE_WORK_PRODUCE.key then
        local price = { }
        local sData = user.produceSoldierData[self:getToftId()]
        local def = cfg[CfgType.CFG_SOLDIER][me.toNum(sData.sid)]
        --        price.food = def.food
        --        price.wood = def.wood
        --        price.stone = def.stone
        --        price.gold = def.gold
        price.food = 0
        price.wood = 0
        price.stone = 0
        price.gold = 0
        if sData.stype == 1 then
            price.time =(sData.time - sData.ptime) / 1000 - self:getCurTime()
        else
            price.time = self:getTrainTotalTime()
        end
        price.index = 2
        local def = self:getDef()
        local kind = def.type
        return math.ceil(getGemCost(price))
    elseif self:getState() == BUILDINGSTATE_WORK_STUDY.key then
        for key, var in pairs(user.techServerDatas) do
            if var:getTofid() == self:getToftId() then
                local def = var:getDef()
                local price = { }
                --                price.food = def.food
                --                price.wood = def.wood
                --                price.stone = def.stone
                --                price.gold = def.gold
                price.food = 0
                price.wood = 0
                price.stone = 0
                price.gold = 0
                price.time = self.maxTime - self.time
                -- def.time2
                print(" price.time = " .. price.time)
                price.index = 3
                return math.ceil(getGemCost(price))
            end
        end
    elseif self:getState() == BUILDINGSTATE_WORK_TREAT.key then
        local gold = 0
        local food = 0
        local wood = 0
        local stone = 0
        local price = { }
        price.food = 0
        price.wood = 0
        price.stone = 0
        price.gold = 0
        price.time = self.time
        price.index = 2
        return math.ceil(getGemCost(price))
    end
    return nil
end
function buildingObj:initAni()
    local aniCfg = self:getData():getDef().ani
    if aniCfg then
        -- 1080:0|0
        local time = getCenterBuildingTime() + 1
        local ids = me.split(aniCfg, ";")
        local aniids = ""

        if ids[time] then
            aniids = ids[time]
        else
            aniids = aniCfg
        end
        local _, _, aniId, px, py = string.find(aniids, "(%d+):(%d+)|(%d+)")
        if aniId and px and py then
            if not self.ani or self.ani:getAniID() ~= aniId then
                self.icon:removeChildByName(OBJ_ANI)
                self.ani = buildingAni:createById(aniId)
                self.ani:setName(OBJ_ANI)
                self.ani:getAnimation():play("idle")
                self.ani:setPosition(cc.p(px, py))
                self.icon:addChild(self.ani)
            end
        else
            if tonumber(aniids) == 0 then
            else
                __G__TRACKBACK__("ani: " .. aniCfg .. "is error !!!")
            end
        end
    end
    self:showLevel()
end
function buildingObj:doOptcallback(opt)
    print("点击按钮: opt = " .. opt)
    if opt == buildingOptMenuLayer.BTN_UPGRADE then
        if self:getData().state ~= BUILDINGSTATE_NORMAL.key then
            showTips(TID_BUILDINGOBJ_PRODUCTING)
            return
        end
        self:showlevelUpLayer()
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_INFO then
        local info = buildingInfoLayer:create("buildingInfoLayer.csb")
        info:setBuidData(self:getDef(), self:getState())
        if self:getDef().type == "food" or self:getDef().type == "stone" or self:getDef().type == "lumber" then
            info:setResData(self:getDef().type, self.resInfo, self:getData().worker)
        end

        if self:getDef().type == "abbey" and self:getState() == BUILDINGSTATE_WORK_TREAT.key then
            -- 治疗的取消
            local time, maxTime = self:getAccelerateTime()
            info:setBuidingData(self:getDef(), self:getData(), time, self:getToftId())
        elseif self:getData() and self.maxTime and self.time and self:getToftId() then
            -- 建造和升级的取消
            info:setBuidingData(self:getDef(), self:getData(), self.maxTime - self.time, self:getToftId())
        elseif self:getData() and self:getToftId() and self:getCurTime() and self:getCurTime() > 0 then
            -- 造兵的取消
            info:setBuidingData(self:getDef(), self:getData(), self:getTrainTotalTime(), self:getToftId())
        elseif self:getDef().type == "wonder" then
            -- 转换的取消
            info:setBuidingData(self:getDef(), self:getData(), self:getChangeTotalTime(), self:getToftId())
        end
        mainCity:addChild(info, me.MAXZORDER)
        me.DelayRun( function()
            me.showLayer(info, "bg_frame")
        end , 0.01)
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_STUDY then
        -- todo 科技
        local tv = techView:getInstance()
        tv:initData(self:getDef().id, self.toftid)
        mainCity:addChild(tv, 100)
        me.showLayer(tv, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_FARMER then
        --        if user.curfarmer < user.maxfarmer then
        --            if user.produceframerdata and user.produceframerdata.num > 0 then
        --                if user.curfarmer + user.produceframerdata.num + 1 > user.maxfarmer then
        --                    showTips(TID_BUILDINGOBJ_POPULATION)
        --                else
        --                    user.produceframerdata.num = user.produceframerdata.num + 1
        --                end
        --            end
        --            NetMan:send(_MSG.prodFarmer())
        --        else
        --            showTips(TID_BUILDINGOBJ_POPULATION)
        --        end
    elseif opt == buildingOptMenuLayer.BTN_TRAIN then
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.prodSoldierView(self:getToftId()))
    elseif opt == buildingOptMenuLayer.BTN_BOATPVP then
        NetMan:send(_MSG.msg_ship_refit_enter_pvp())
        local pvp = warshipPvPView:create("warshipPVP.csb")
        me.popLayer(pvp)
    elseif opt == buildingOptMenuLayer.BTN_INBUILDING then
        local bdata = self:getData()
        local allotPopLayer_ = nil
        if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
            allotPopLayer_ = allotBuilderPopOver:create("allotPopover.csb")
            local d = user.buildingDateLine[self:getToftId()]
            allotPopLayer_:initWithData(d)
            allotPopLayer_:setLeftTime(self.maxTime - self.time, self.maxTime)
        elseif self:getState() == BUILDINGSTATE_WORK_STUDY.key then
            allotPopLayer_ = allotWorkerPopOver:create("allotPopover.csb")
            allotPopLayer_:initWithData(bdata)
            allotPopLayer_:initForTech(self.techDef)
            allotPopLayer_:setLeftTime(self.maxTime - self.time, self.maxTime)
        else
            local def = self:getDef()
            local buildType = def.type
            if buildType == cfg.BUILDING_TYPE_FOOD then
                allotPopLayer_ = allotWorkerPopOver:create("allotPopover.csb")
                allotPopLayer_:initWithData(bdata)
                allotPopLayer_:initForFood(self:getState())
            else
                local sdata = user.produceSoldierData[self:getToftId()]
                if sdata and sdata.num > 0 then
                    allotPopLayer_ = allotWorkerPopOver:create("allotPopover.csb")
                    allotPopLayer_:initWithData(bdata)
                    allotPopLayer_:initForBarrack(sdata, self:getState(), self.curTime)
                else
                    allotPopLayer_ = allotWorkerPopOver:create("allotPopover.csb")
                    allotPopLayer_:initWithData(bdata)
                end
            end
        end
        mainCity:addChild(allotPopLayer_, me.MAXZORDER)
        me.showLayer(allotPopLayer_, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_FASTER then
        local function diamondUse()
            buildingOptMenuLayer:getInstance():clearnButton()
            NetMan:send(_MSG.buildQuickGem(self:getToftId()))
        end
        local building = mainCity.buildingMoudles[self:getToftId()]
        local needDiamond = tonumber(building:getImmeCost())
        if user.diamond < needDiamond then
            diamondNotenough(needDiamond, diamondUse)
        else
            diamondCostMsgBox(needDiamond, diamondUse)
        end
    elseif opt == buildingOptMenuLayer.BTN_FASTER_ITEM then
        local tmpView = useToolsView:create("useToolsView.csb")
        tmpView:setToolsType(self:getState(), self:getToftId())
        tmpView:setRelatedObj(self)
        local def = self:getDef()
        if (def.type == "barrack" or def.type == "range" or def.type == "horse" or def.type == "siege" or def.type == "door"
            or def.type == "wonder") and(self:getState() == BUILDINGSTATE_WORK_TRAIN.key or self:getState() == BUILDINGSTATE_WORK_PRODUCE.key) then
            -- 造兵的建筑物特殊处理时间
            tmpView:setTime(self:getTrainTotalTime())
        elseif self:getState() == BUILDINGSTATE_WORK_TREAT.key then
            -- 伤兵治疗
            local time, maxTime = self:getAccelerateTime()
            tmpView:setTime(time)
        else
            tmpView:setTime(self.time, self.maxTime)
        end
        mainCity:addChild(tmpView, 100)
        me.showLayer(tmpView, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_BUILD then
        if self:getDef().type == cfg.BUILDING_TYPE_DOOR and me.toNum(self:getDef().level) < 6 then
            -- 不满6级的城门，不能显示训练界面
            showTips(TID_TRAIN_NOT_ENOUGH)
            return
        end
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.prodSoldierView(self:getToftId()))
    elseif opt == buildingOptMenuLayer.BTN_TREAT then
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.revertSoldierInit())
    elseif opt == buildingOptMenuLayer.BTN_FUHUO then
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.reliveSoldierInit())
    elseif opt == buildingOptMenuLayer.BTN_DEFENSE then
        showTips("功能未开启")
        --        local tmp = defenseView:create("defenseView.csb")
        --        mainCity:addChild(tmp, 100)
        --        me.showLayer(tmp, "bg")
        --        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_CHANGE then
        print("奇迹转换")
        buildChangeView = wonderChangeView:create("buildChangeView.csb")
        buildChangeView:initWithData(self:getData(), self:getToftId(), self:getCurTime())
        mainCity:addChild(buildChangeView, 100)
        me.showLayer(buildChangeView, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_LOG then
        print("瞭望塔点击事件！！！！")
        local eiv = EventInforView:create("eventInfor.csb")
        mainCity:addChild(eiv, me.MAXZORDER)
        me.showLayer(eiv, "bg_frame")
        buildingOptMenuLayer:getInstance():clearnButton()
        -- 市场礼包按钮点击
    elseif opt == buildingOptMenuLayer.BTN_HORSE then
        if user.packageData.status == 0 then
            showTips("贸易驿站建成后开启")
        elseif user.packageData.status == 2 then
            print("发送领取礼包消息")
            buildingOptMenuLayer:getInstance():clearnButton()
            NetMan:send(_MSG.getPackage(user.packageData.id))
        end
    elseif opt == buildingOptMenuLayer.BTN_TAX then
        buildingOptMenuLayer:getInstance():removeButtonAni(buildingOptMenuLayer.BTN_TAX)
        buildingOptMenuLayer:getInstance():clearnButton()
        NetMan:send(_MSG.taxInfo())
    elseif opt == buildingOptMenuLayer.BTN_ALLIANCESHOP then
        if user.familyUid then
            if user.familyUid ~= 0 then
                buildingOptMenuLayer:getInstance():clearnButton()
                local shop = allianceshop:create("allianceshop.csb")
                shop:initShopInfo(self:getDef())
                mainCity:addChild(shop)
                me.showLayer(shop, "bg_frame")
            else
                showTips("尚未加入联盟")
            end
        else
            print("user.familyUid is nil!!!!")
        end
    elseif opt == buildingOptMenuLayer.BTN_GUARD then
        NetMan:send(_MSG.RoleProtectedInfo())
        local protectedView = ProtectedView:create("ProtectedView.csb")
        mainCity:addChild(protectedView, me.MAXZORDER)
        me.showLayer(protectedView, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_WAR then
        -- 联盟战争
        print("联盟战争")
        local converge = convergeView:create("convergeView.csb")
        mainCity:addChild(converge, me.MAXZORDER)
        me.showLayer(converge, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_BOAT then
        -- 跨服海战
        print("跨服海战")
        local warshipView = warshipView:create("warning/warshipView.csb")
        mainCity:addChild(warshipView, me.MAXZORDER)
        warshipView:setCurShipType(user.curSelectShipType)
        me.showLayer(warshipView, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
        --        if mainCity and mainCity.maplayer then
        --           local p = me.assignWidget(mainCity.maplayer,"bg")
        --           cameraLookAtPoint(cc.p(p:getContentSize().width,p:getContentSize().height))
        --         end
    elseif opt == buildingOptMenuLayer.BTN_ALTAR then
        -- 祭坛
        print("祭坛")
        if user.newBtnIDs[tostring(OpenButtonID_RELIC)] ~= nil then
            mainCity.runeAltar = runeAltarView:create("rune/runeAltarView.csb", 1, 1)
            mainCity:addChild(mainCity.runeAltar, me.MAXZORDER)
            me.showLayer(mainCity.runeAltar, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        else
            showTips("暂未开启，领取任务奖励后开启")
        end
    elseif opt == buildingOptMenuLayer.BTN_TRAIT then
        -- 搜索
        if user.newBtnIDs[tostring(OpenButtonID_RELIC)] ~= nil then
            mainCity.runeSearch = runeSearch:create("rune/runeSearch.csb")
            mainCity:addChild(mainCity.runeSearch, me.MAXZORDER)
            me.showLayer(mainCity.runeSearch, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        else
            showTips("暂未开启，领取任务奖励后开启")
        end
    elseif opt == buildingOptMenuLayer.BTN_HERO then
        if user.Cross_Sever_Status == mCross_Sever then
            showTips("跨服中，无法进入")
        else
            NetMan:send(_MSG.worldHeroIdentifyList())
        end
    elseif opt == buildingOptMenuLayer.BTN_CHALLENGE then
        local heroLevel = herolevel:create("herolevel/herolevel.csb")
        mainCity:addChild(heroLevel, me.MAXZORDER)
        me.showLayer(heroLevel, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_SAILING then
        print("航行")
        if table.nums(user.warshipData) <= 0 then
            showTips("请先打造战舰")
            return
        end
        NetMan:send(_MSG.ship_expedition_init())
        local shipSail = shipSailView:create("warning/shipSailView.csb")
        mainCity:addChild(shipSail, me.MAXZORDER)
        me.showLayer(shipSail, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    elseif opt == buildingOptMenuLayer.BTN_SKIN then
        -- 皮肤
        NetMan:send(_MSG.citySkinList())

    elseif opt == buildingOptMenuLayer.BTN_SOLDIERSGUARD then
        NetMan:send(_MSG.guard_init())
        local defsoldier = defSoldierLayer:create("defSoldierLayer.csb")
        me.popLayer(defsoldier)
    elseif opt == buildingOptMenuLayer.BTN_SOLDIERSINFO then
        -- 部队详情
        NetMan:send(_MSG.armyinfo())
    elseif opt == buildingOptMenuLayer.BTN_HORNOR then
        -- 荣誉
        NetMan:send(_MSG.hornor_init())
        local hornor = hornorLayer:create("hornorLayer.csb")
        me.popLayer(hornor)

    elseif opt == buildingOptMenuLayer.BTN_EXPEDITION then
        -- 远征
        NetMan:send(_MSG.Cross_Promotion_List())
        local netBattleEnterLayer = netBattleEnterLayer:create("netBattleEnterLayer.csb")
        me.popLayer(netBattleEnterLayer)
    end
end

-- 设置瞭望塔最新信息状态
function buildingObj:setTowerState(state_)
    self.towerBtnState = state_
end
-- 瞭望塔信息查看按钮
function buildingObj:showTowerBtn()
    if self.freeBtnState == false and self.helpBtnState == false and self.towerBtnState == true and self:getDef().type == cfg.BUILDING_TYPE_TOWER then
        print("显示----瞭望塔信息查看按钮")
        self.helpBtn:loadTextureNormal("zhucheng_shijian_zhengchang.png", me.localType)
        self.helpBtn:loadTexturePressed("zhucheng_shijian_zhengchang.png", me.localType)
        self.helpBtn:setVisible(true)
    end
end
function buildingObj:showNetBattleBtn()
    self.helpBtn:loadTextureNormal("zhucheng_anniu_yuanzheng.png", me.localType)
    self.helpBtn:loadTexturePressed("zhucheng_anniu_yuanzheng.png", me.localType)
    self.helpBtn:setVisible(true)
    self:shakeTopBtn()
    self.netBattleBtnState = true
end
function buildingObj:hideNetBattleBtn()
    self.netBattleBtnState = false
    self.helpBtn:setVisible(false)
end
-- 当退出联盟的时候隐藏帮助按钮
function buildingObj:hideHelpBtn()
    self.helpBtn:setVisible(false)
    self.helpBtnState = false
    self:showTowerBtn()
end
-- 当建造升级完成时，隐藏免费/帮助按钮
function buildingObj:hideFreeHelpBtn()
    me.clearTimer(self.m_buildtimer)
    me.clearTimer(self.levelupTimer)
    me.clearTimer(self.produce_timer)
    mainCity:removeFarmerPathById(self:getToftId())
    self.freeBtnState = false
    self.helpBtnState = false
    self.helpBtn:stopAllActions()
    self.helpBtn:setVisible(false)
    self:showTowerBtn()
end
-- 显示5分钟免费按钮
function buildingObj:showFreeBtn(lTime)
    if not user.propertyValue["FreeTime"] then
        user.propertyValue["FreeTime"] = 300
    end
    if lTime > user.propertyValue["FreeTime"] then
        if self.freeBtnState == true then
            self.helpBtn:stopAllActions()
            self.helpBtn:setVisible(false)
            self.freeBtnState = false
        end
        return
    end
    if self.freeBtnState == false then
        self.helpBtn:loadTextureNormal("zhucheng_mf_zhengchang.png", me.localType)
        -- self.helpBtn:loadTexturePressed("zhucheng_mf_zhengchang.png",me.localType)
        self.helpBtn:setVisible(true)
        self.freeBtnState = true
        self:shakeTopBtn()
    end
end
-- 帮助联盟按钮
function buildingObj:showCenterHelpBtn()
    if self:getState() == BUILDINGSTATE_NORMAL.key or self:getState() == BUILDINGSTATE_LEVEUP.key then
        self.helpBtn:loadTextureNormal("zhucheng_lm_lm_bangzhu_zhengchang.png", me.localType)
        -- self.helpBtn:loadTexturePressed("zhucheng_lm_lm_bangzhu_anxia.png",me.localType)
        self.helpBtn:setVisible(true)
        self.helpBtnState = true
        self:shakeTopBtn()
    end
end

-- 沦陷捐献按钮
function buildingObj:showCenterCaptiveBtn()
    self.helpBtn:loadTextureNormal("zhucheng_anniu_lunxian.png", me.localType)
    -- self.helpBtn:loadTexturePressed("zhucheng_anniu_lunxian.png", me.localType)
    self.helpBtn:setVisible(true)
    self.captiveBtnState = true
    self:shakeTopBtn()
end

function buildingObj:closeCenterCaptiveBtn()
    self.helpBtn:setVisible(false)
    self.captiveBtnState = false
end
-- 请求联盟帮助按钮
function buildingObj:showHelpBtn()
    local function isHelped(bid)
        for key, var in pairs(user.familyHelpedBid) do
            if me.toNum(var.bulidUid) == bid then
                return true
            end
        end
        return false
    end

    if user.familyUid == 0 or isHelped(self:getToftId()) == true then
        -- 没有联盟
        return
    end

    if self:getState() == BUILDINGSTATE_NORMAL.key or
        self:getState() == BUILDINGSTATE_WORK_TRAIN.key or
        self:getState() == BUILDINGSTATE_WORK_PRODUCE.key then
        self.helpBtn:setVisible(false)
        self.helpBtnState = false
    else
        self.helpBtn:loadTextureNormal("zhucheng_lm_zj_bangzhu_zhengchang.png", me.localType)
        -- self.helpBtn:loadTexturePressed("zhucheng_lm_zj_bangzhu_anxia.png",me.localType)
        self.helpBtn:setVisible(true)
        self.helpBtnState = true
        self:shakeTopBtn()
    end
    
end

-- 检测是否显示训练按钮
function buildingObj:checkShowTrainBtn()
    local function show()
        self.btn_train:setVisible(true)
        self.btn_train:stopAllActions()
        self.btn_train:setRotation(0)
        local rotate = cc.RotateBy:create(0.06, 18)
        local rotateR = rotate:reverse()
        local rotate1 = cc.RotateBy:create(0.06, 10)
        local rotateR1 = rotate1:reverse()
        local delay = cc.DelayTime:create(3)
        local seq = cc.Sequence:create(rotate, rotateR, rotateR, rotate, rotate1, rotateR1, rotateR1, rotate1, delay)
        self.btn_train:runAction(cc.RepeatForever:create(seq))
    end
    local function hide()
        self.btn_train:setVisible(false)
        self.btn_train:stopAllActions()
        self.btn_train:setRotation(0)
    end
    -- 空闲状态下，军营、马厩、靶场、武器厂、奇迹要显示训练按钮，提示玩家去训练
    if self:getState() == BUILDINGSTATE_NORMAL.key then
        local buildType = self:getDef().type
        if buildType == cfg.BUILDING_TYPE_BARRACK or buildType == cfg.BUILDING_TYPE_RANGE
            or buildType == cfg.BUILDING_TYPE_HORSE or buildType == cfg.BUILDING_TYPE_SIEGE
            or buildType == cfg.BUILDING_TYPE_WONDER then
            show()
        else
            hide()
        end
    else
        hide()
    end
end
-- 显示出当前建筑物的菜单按钮条
function buildingObj:showBuildingMenu(aniTag_)
    local ani = aniTag_
    local function optcallcallback(node)
        print(node.opt)
        self:doOptcallback(node.opt)
    end
    me.DelayRun( function()
        local tarB = user.buildingDateLine[self:getToftId()]
        if tarB == nil then
            tarB = user.building[self:getToftId()]
        end
        local bom = buildingOptMenuLayer:getInstance()
        if ani then
            bom:setAniTag(ani)
            user.newBtnIDs[me.toStr(OpenButtonID_Tax)] = OpenButtonID_Tax
        end
        bom:showBuildingOpt(tarB, optcallcallback)
    end , 0.1)
end
function buildingObj:showTreat(bid_)
    if table.nums(user.revertingSoldiers) > 0 or table.nums(user.revertingSoldiers_c) > 0 then
        if table.nums(user.revertingSoldiers) > 0 then
            local treat = treatView:getInstance()
            treat:setBuildTofid(bid_, TREAT_TYPE_SERVER, true)
            mainCity:addChild(treat, 100)
            me.showLayer(treat, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        elseif table.nums(user.revertingSoldiers_c) > 0 then
            local treat = treatView:getInstance()
            treat:setBuildTofid(bid_, TREAT_TYPE_NETSERVER, true)
            mainCity:addChild(treat, 100)
            me.showLayer(treat, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        end
    else
        if table.nums(user.desableSoldiers) > 0 then
            local treat = treatView:getInstance()
            treat:setBuildTofid(bid_, TREAT_TYPE_SERVER)
            mainCity:addChild(treat, 100)
            me.showLayer(treat, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        elseif table.nums(user.desableSoldiers_c) > 0 then
            local treat = treatView:getInstance()
            treat:setBuildTofid(bid_, TREAT_TYPE_NETSERVER)
            mainCity:addChild(treat, 100)
            me.showLayer(treat, "bg")
            buildingOptMenuLayer:getInstance():clearnButton()
        else
            showTips("暂无伤兵")
        end
    end
end

function buildingObj:showRelive(data)
    if data.total > 0 then
        local treat = fuhuoView:getInstance()
        treat:setData(data)
        mainCity:addChild(treat, 100)
        me.showLayer(treat, "bg")
        buildingOptMenuLayer:getInstance():clearnButton()
    else
        showTips("暂无死兵")
    end
end
function buildingObj:stopChanging()
    self:setState(BUILDINGSTATE_NORMAL.key)
end
function buildingObj:stoprTreating()
    self:setState(BUILDINGSTATE_NORMAL.key)
    if user.revertingSoldiers[self:getToftId()] then
        me.tableClear(user.revertingSoldiers[self:getToftId()])
        user.revertingSoldiers[self:getToftId()] = nil
    end
    me.clearTimer(self.produce_timer)
    self.produceLayer:setVisible(false)
    self:stopCityAniation()
    user.building[self.toftid].state = BUILDINGSTATE_NORMAL.key
    self.isBusy = false
end
function buildingObj:stopStudying()
    self:setState(BUILDINGSTATE_NORMAL.key)
    UserModel:stopTeching(self:getToftId())
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
    me.clearTimer(self.produce_timer)
    self.levelupani:setVisible(false)
end
function buildingObj:stopTraining()
    self.isBusy = false
    self:setState(BUILDINGSTATE_NORMAL.key)
    user.building[self:getToftId()].state = BUILDINGSTATE_NORMAL.key
    me.clearTimer(self.produce_timer)
    self.produceLayer:setVisible(false)
    user.produceSoldierData[self:getToftId()] = nil
    self.curTime = 0
end
function buildingObj:showTrain()
    mainCity.train = trainLayer:create("trainLayer.csb")
    mainCity.train:initWithData(self:getData(), self:getToftId(), self:getCurTime())
    mainCity:addChild(mainCity.train, 100)
    me.showLayer(mainCity.train, "bg")
end
function buildingObj:initNormalState(data_)
    self.levelupani:setVisible(false)
    if self:getDef().icon then
        self.icon:loadTexture(buildIcon(self:getDef()), me.plistType)
        if self:getDef().type ~= cfg.BUILDING_TYPE_MONK then
            self.icon:loadNormalTransparentInfoFromFile()
        end
        self.icon:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:initAni()
        self:setAllLayerSize()
    end
    local def = self:getDef()
    local kind = def.type
    if kind == cfg.BUILDING_TYPE_CENTER then
        self:updateSkin()
    end
end
function buildingObj:setAllLayerSize()
    me.doLayout(self, self.icon:getContentSize())
end
-- 显示分配工人的动画
function buildingObj:showFarmerChange(num_)
    if nil == num_ or num_ == 0 then
        return
    end
    -- 从集结点方向走过来的方案
    --    local crowdsPos = cc.p(mainCity.crowds:getPositionX(), mainCity.crowds:getPositionY())
    --    local ang = me.getAngle(self:getCenterPoint(),crowdsPos)
    --    local orgPos = me.circular(self:getCenterPoint(),500,ang) --画面外的坐标
    --    local tarPos = self:getCenterPoint() --城中心
    --    num_ = math.min(num_,8)
    --    if num_ < 0 then
    --        orgPos = self:getCenterPoint() --城中心
    --        tarPos = me.circular(self:getCenterPoint(),500,ang) --画面外的坐标
    --    end
    mAudioMusic:setPlayEffect(MUSIC_EFFECT_WORKER_YES, false)
    for var = 1, math.abs(num_) do
        local orgPos = me.randInCircle2(self:getLeftPoint(), 180)
        local tarPos = self:getCenterPoint()
        if num_ < 0 then
            orgPos = self:getCenterPoint()
            tarPos = me.randInCircle2(self:getLeftPoint(), 180)
        end

        local farmer = farmerMoudle:createAni("nongminAni")
        mainCity.buildLayer:addChild(farmer)
        farmer:setPosition(orgPos)
        local function arrive(node)
            farmer:doAction(MANI_STATE_IDLE)
            farmer:stopAllActions()
            farmer:removeFromParentAndCleanup(true)
        end
        farmer:getAnimation():setSpeedScale(1.7)
        farmer:moveToPoint(tarPos, arrive)
    end
end
-- 房屋升级或者建造完毕，增加工人的动画
function buildingObj:showProduceFarmer(num)
    mAudioMusic:setPlayEffect(MUSIC_EFFECT_WORKER_YES, false)
    for var = 1, num do
        local farmer = farmerMoudle:createAni("nongminAni")
        farmer:setPosition(self:getBottomPoint())
        mainCity.buildLayer:addChild(farmer)
        local function arrive(node)
            local crowdsPos = cc.p(mainCity.crowds:getPositionX(), mainCity.crowds:getPositionY())
            local fp = me.circular(crowdsPos, 60, me.getRandom(10) + 1 * 36)
            if user.idlefarmer >= MAX_SHOW_FARMER then
                farmer:moveToPoint(fp, function(node)
                    farmer:doAction(MANI_STATE_IDLE)
                    farmer:stopAllActions()
                    farmer:removeFromParentAndCleanup(true)
                end )
            else
                if mainCity.farmerMoudles == nil then
                    mainCity.farmerMoudles = { }
                end
                farmer.fid = #mainCity.farmerMoudles + 1
                mainCity.farmerMoudles[farmer.fid] = farmer
                farmer:moveToPoint(fp, function(node)
                    farmer:doAction(MANI_STATE_IDLE)
                end )
            end
        end
        farmer:setTagBuildingId(self:getToftId())
        farmer:getAnimation():setSpeedScale(1.7)
        local newQ = Queue.reverse(self:getPath())
        farmer:moveOnPaths(newQ, arrive)
    end
end
-- 显示工人去修建筑物
function buildingObj:showFarmerWork(num, cmd)
    mAudioMusic:setPlayEffect(MUSIC_EFFECT_WORKER_YES, false)
    num = math.min(3, num)
    for var = 1, num do

        local farmer = mainCity:getIdleFarmer()
        if farmer then
            local function arrive(node)
                farmer:dirToPoint(self:getCenterPoint())
                farmer:doAction(MANI_STATE_BUILD)
                mainCity:removeFarmerPathById(self:getToftId())
                self.canStartTime = true
            end
            farmer:setTagBuildingId(self:getToftId())
            farmer:getAnimation():setSpeedScale(1.7)
            farmer:moveOnPaths(self:getPath(), arrive)
            mainCity:showFarmerPath(self:getPath(), self:getToftId(), farmer:getBasePoint())
        else
            -- 显示农民动画的对象没有了
            ---  showTips(TID_BUILDINGOBJ_NOFAEMER)
        end
    end
    self:resetBuildPoint()
end
-- 工人直接到达建筑物
function buildingObj:showDirectWork(num, cmd)
    for var = 1, num do
        local farmer = mainCity:getIdleFarmer()
        if farmer then
            farmer:setPosition(self:getDirectPath())
            farmer:dirToPoint(self:getCenterPoint())
            farmer:getAnimation():setSpeedScale(1.7)
            farmer:setTagBuildingId(self:getToftId())
            farmer:doAction(MANI_STATE_BUILD)
            self.canStartTime = true
        end
    end
    self.workPoint = 1
end
function buildingObj:resetBuildPoint()
    self.workPoint = 1
end
function buildingObj:initLevelUpState(data_)
    print("initLevelUpState")
    self.levelupani = me.assignWidget(self, "levelupLayer")
    self.levelupani:setVisible(false)
    if self:getDef().icon then
        self.icon:loadTexture(buildIcon(self:getDef()), me.plistType)
        if self:getDef().type ~= cfg.BUILDING_TYPE_MONK then
            self.icon:loadNormalTransparentInfoFromFile()
        end
        self:setAllLayerSize()
        self.icon:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:showLevelUpAni(data_, data_.countdown)
        self:initAni()
    end
end
function buildingObj:initBuildState(data_)
    self.icon:loadTexture("bBase" .. self.pace_width .. "_1.png", me.localType)
    -- self.icon:loadNormalTransparentInfoFromFile()
    self:setAllLayerSize()
    self.icon:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
    self.maxTime = getCurFarmerBuildCostTime(self:getData().builder, self:getDef())
    -- getCostTime(self:getData().builder, self:getDef().farmer, self:getDef().maxfarmer, self:getDef().time, self:getDef().time2)
    if data_.countdown then
        self.time = self.maxTime - data_.countdown / 1000
    else
        self.time = 0
    end

    self.levelupani:setVisible(true)
    local timebarbg =   me.assignWidget(self,"timebarbg")
    if timebarbg:getPositionY() > 280 then
        timebarbg:setPositionY(280)
    else
        timebarbg:setPositionY(self.icon:getContentSize().height - timebarbg:getContentSize().height/2 - 8)
    end
    local timebarbg =   me.assignWidget(self,"timebarbg")
    self.helpBtn:setPositionY(timebarbg:getPositionY() + 10)
    local timebar = me.assignWidget(self.levelupani, "timebar")
    local time = me.assignWidget(self.levelupani, "time")
    timebar:setPercent(0)
    local function update(dt)
        if self.canStartTime then
            if self.time < self.maxTime then
                self.time = self.time + dt
                timebar:setPercent(self.time / self.maxTime * 100)
                time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
                self:showFreeBtn(self.maxTime - self.time)
                if self.time < self.maxTime + dt and self.time > self.maxTime - dt then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schId)
                    self.schId = nil
                    if self.buildLisenter then
                        self.buildLisenter(self, evt)
                    end
                elseif self.time < self.maxTime * 0.3 + dt and self.time > self.maxTime * 0.3 - dt then
                    self.icon:loadTexture("bBase" .. self.pace_width .. "_2.png", me.localType)
                    -- self.icon:loadNormalTransparentInfoFromFile()
                    self:setAllLayerSize()
                elseif self.time < self.maxTime * 0.7 + dt and self.time > self.maxTime * 0.7 - dt then
                    self.icon:loadTexture("bBase" .. self.pace_width .. "_3.png", me.localType)
                    -- self.icon:loadNormalTransparentInfoFromFile()
                    self:setAllLayerSize()
                end
            end
        end
    end
    self.m_buildtimer = me.registTimer(self.maxTime, update)

    time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime))
    if data_["needWorker"] == true then
        self:showDirectWork(self:getDef().farmer, MANI_STATE_BUILD)
    else
        self:showFarmerWork(self:getDef().farmer, MANI_STATE_BUILD)
    end
    self:showLevel()
end
-- 更新分配后建筑或升级时间
function buildingObj:updateBuildAllot(ctime)
    local data = self:getData()
    local def = data:getDef()
    self.maxTime = getCurFarmerBuildCostTime(data.builder, def)
    self.time = self.maxTime - data.countdown / 1000
end
function buildingObj:showLevelUpAni(data_, ctime_)
    -- 初始化时正在升级显示正在升级的时间。
    if self:getState() ~= BUILDINGSTATE_CHANGE.key then
        -- 如果是奇迹转换的话，标题不变依然显示转换文字。
        self:setState(BUILDINGSTATE_LEVEUP.key)
    end
    data = data_:getDef()
    self.maxTime = getCurFarmerBuildCostTime(self:getData().builder, data)
    if ctime_ then
        self.time = self.maxTime - ctime_ / 1000
    else
        self.time = 0
    end
    local timebar = me.assignWidget(self.levelupani, "timebar")
    local time = me.assignWidget(self.levelupani, "time")
    timebar:setPercent(0)
    local function update(dt)
        self.time = self.time + dt
        if self.time <= self.maxTime then
            timebar:setPercent(100 * self.time / self.maxTime)
            --            print("100 * self.time / self.maxTime = "..100 * self.time / self.maxTime)
            time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
            self:showFreeBtn(self.maxTime - self.time)
        end
    end
    self.levelupTimer = me.registTimer(-1, update)
    time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
    self.levelupani:setVisible(true)
    if data_["needWorker"] == true then
        self:showDirectWork(self:getDef().farmer, MANI_STATE_BUILD)
    else
        self:showFarmerWork(self:getDef().farmer, MANI_STATE_BUILD)
    end
    local timebarbg =   me.assignWidget(self,"timebarbg")
    if timebarbg:getPositionY() > 280 then
        timebarbg:setPositionY(280)
        else
        timebarbg:setPositionY(self.icon:getContentSize().height - timebarbg:getContentSize().height/2 - 8)
    end
    local timebarbg =   me.assignWidget(self,"timebarbg")
    self.helpBtn:setPositionY(timebarbg:getPositionY() + 10)
end
function buildingObj:showChangeAni(data_, ctime_)
    -- 初始化时正在升级就有正在升级的时间
    self:setState(BUILDINGSTATE_CHANGE.key)
    data = data_:getDef()
    self.maxTime = getCurFarmerBuildCostTime(self:getData().builder, data)
    if ctime_ then
        self.time = self.maxTime - ctime_ / 1000
    else
        self.time = 0
    end

    local timebar = me.assignWidget(self.levelupani, "timebar")
    local time = me.assignWidget(self.levelupani, "time")
    timebar:setPercent(0)
    local function update(dt)
        self.time = self.time + dt
        if self.time <= self.maxTime then
            timebar:setPercent(100 * self.time / self.maxTime)
            --            print("100 * self.time / self.maxTime = "..100 * self.time / self.maxTime)
            time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
            self:showFreeBtn(self.maxTime - self.time)
        end
    end
    self.levelupTimer = me.registTimer(self.maxTime, update)
    time:setString(self:getNameByState() .. me.formartSecTime(self.maxTime - self.time))
    self.levelupani:setVisible(true)
    local timebarbg =   me.assignWidget(self,"timebarbg")
    if timebarbg:getPositionY() > 280 then
        timebarbg:setPositionY(280)
        else
        timebarbg:setPositionY(self.icon:getContentSize().height - timebarbg:getContentSize().height/2 - 8)
    end
    local timebarbg =   me.assignWidget(self,"timebarbg")
    self.helpBtn:setPositionY(timebarbg:getPositionY() + 10)
    if data_["needWorker"] == true then
        self:showDirectWork(self:getDef().farmer, MANI_STATE_BUILD)
    else
        self:showFarmerWork(self:getDef().farmer, MANI_STATE_BUILD)
    end
end
function buildingObj:showlevelUpLayer()
    local bdata = user.building[self:getToftId()]
    if bdata then
        local nextbuildingDef = bdata:getNextLevelDef()
        --[[
        local function buildingLevelUp(evt)
            if evt.cmd == "imme" then
                 self:showLevelUpAni(evt.data:getDef())
            elseif evt.cmd == "lvup" then
                self:showLevelUpAni(evt.data:getDef())
            end
            self.levelup:close()
        end
        ]]
        if nextbuildingDef then
            local nextbuildingData = BuildIngData.new(self:getToftId(), nextbuildingDef.id, 0)
            mainCity.bLevelUpLayer = buildLevelUpLayer:create("buildLevelUpLayer.csb")
            -- self.levelup:addEvtLisenter(buildingLevelUp)
            mainCity.bLevelUpLayer:initWithData(nextbuildingData, self:getToftId())
            mainCity:addChild(mainCity.bLevelUpLayer, me.MAXZORDER)
            me.showLayer(mainCity.bLevelUpLayer, "bg")
        else
            --  error("next building is nil")
            showTips(TID_BUILDINGOBJ_BUILDMAXLV)
        end

    end
end
function buildingObj:onEnter()
    print("buildingObj onEnter")
end
function buildingObj:onExit()
    print("buildingObj onExit")
    me.clearTimer(self.levelupTimer)
    me.clearTimer(self.produce_timer)
    me.clearTimer(self.m_timer)
    me.clearTimer(self.m_buildtimer)
end
function buildingObj:setToftId(tid)
    self.toftid = tid
    local tid_ = tid
    while tid_ > 10 do
        tid_ = tid_ / 10
    end
    self.pace_width = math.floor(tid_)
    if self.pace_width == 8 then
        self.pace_width = 2
    end
    print("self.toftid =  " .. self.toftid)
end
function buildingObj:getToftId()
    return self.toftid
end
function buildingObj:setState(state_, pBool)
    self.state = state_
    self:showHelpBtn()
    self:checkShowTrainBtn()
    --  self:CityAnimation()
    if pBool == nil then
        self:BuildSleepAnimation()
    end
end
function buildingObj:getState()
    return self.state
end
function buildingObj:getLeftPoint()
    return cc.p(self:getPositionX() -20, self:getPositionY() + self.pace_width * i_height / 2)
end
function buildingObj:getRightPoint()
    return cc.p(self:getPositionX() + i_width * self.pace_width + 20, self:getPositionY() + self.pace_width * i_height / 2)
end
function buildingObj:getTopPoint()
    return cc.p(self:getPositionX() + i_width * self.pace_width / 2, self:getPositionY() + self.pace_width * i_height + 20)
end
function buildingObj:getBottomPoint()
    return cc.p(self:getPositionX() + i_width * self.pace_width / 2, self:getPositionY() -20)
end
function buildingObj:getCenterPoint()
    return cc.p(self:getPositionX() + i_width * self.pace_width / 2, self:getPositionY() + self.pace_width * i_height / 2)
end
function buildingObj:getNearPointInFour(p)
    local groups = { }
    groups["left"] = self:getLeftPoint()
    groups["right"] = self:getRightPoint()
    groups["bottom"] = self:getBottomPoint()
    groups["top"] = self:getTopPoint()
    local mindis = 999999999
    local key_ = nil
    for key, var in pairs(groups) do
        local dis = cc.pDistanceSQ(var, p)
        if dis < mindis then
            mindis = dis
            key_ = key
        end
    end
    self.nearPoint = groups[key_]
    if key_ == "left" then
        self.nearofset = -180
    elseif key_ == "right" then
        self.nearofset = 0
    elseif key_ == "top" then
        self.nearofset = -270
    elseif key_ == "bottom" then
        self.nearofset = -90
    end
    return groups[key_]
end
function buildingObj:getPath()
    if self.m_path == nil then
        self.m_path = Queue.new()
        local range = math.floor(self.toftid / 1000)
        local index = self.toftid % 1000
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
        if lastP then
            Queue.push(self.m_path, self:getNearPointInFour(lastP))
        else
            Queue.push(self.m_path, self:getNearPointInFour(cc.p(mainCity.crowds:getPositionX(), mainCity.crowds:getPositionY())))
        end
    end

    local ctable = me.copyTab(self.m_path)
    local center = self:getCenterPoint()
    local workPoint = me.oval(center, self.pace_width * i_width / 2, self.pace_width * i_height / 2, self.workPoint * 25 + self.nearofset)
    self.workPoint = self.workPoint + 1
    print(self.pace_width)
    Queue.push(ctable, workPoint)
    return ctable
end

function buildingObj:getDirectPath()
    if self.m_path == nil then
        self.m_path = Queue.new()
        local range = math.floor(self.toftid / 1000)
        local index = self.toftid % 1000
        local name = "bPace" .. range .. "_" .. index
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
        if lastP then
            Queue.push(self.m_path, self:getNearPointInFour(lastP))
        else
            Queue.push(self.m_path, self:getNearPointInFour(cc.p(mainCity.crowds:getPositionX(), mainCity.crowds:getPositionY())))
        end
    end

    local ctable = me.copyTab(self.m_path)
    local center = self:getCenterPoint()
    local workPoint = me.oval(center, self.pace_width * i_width / 2, self.pace_width * i_height / 2, self.workPoint * 45 + self.nearofset)
    self.workPoint = self.workPoint + 1
    Queue.push(ctable, workPoint)
    return workPoint
end

function buildingObj:buildComplete()
    print("buildComplete")
    mainCity:removeFarmerPathById(self:getToftId())
    me.clearTimer(self.m_buildtimer)
    self:setState(BUILDINGSTATE_NORMAL.key)
    self:initNormalState(self:getData())
    -- 声音
    self:hideFreeHelpBtn()
    mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_CITY_END_STUDY, false)
    self.BuildTipStr = TID_BUILD_COMPLETE
    self:BuildAnimation()
    local def = self:getDef()
    local kind = def.type
    if kind == cfg.BUILDING_TYPE_CENTER then
        self:updateSkin()
    end
end
function buildingObj:levelUpComplete()
    mainCity:removeFarmerPathById(self:getToftId())
    self:setState(BUILDINGSTATE_NORMAL.key)
    self.levelupani:setVisible(false)
    self:hideFreeHelpBtn()
    me.clearTimer(self.levelupTimer)
    --  showTips(self:getData():getDef().name..TID_BUILDINGOBJ_BUILDCOMPLETE)
    self:initAni()
    mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_CITY_END_UPGRADE, false)
    self.BuildTipStr = TID_BUILDINGOBJ_BUILDCOMPLETE
    self:BuildAnimation()
    local def = self:getDef()
    local kind = def.type
    if kind == cfg.BUILDING_TYPE_CENTER then
        self:updateSkin()
    end
end
function buildingObj:changeComplete()
    mainCity:removeFarmerPathById(self:getToftId())
    self:setState(BUILDINGSTATE_NORMAL.key)
    self.levelupani:setVisible(false)
    self:hideFreeHelpBtn()
    me.clearTimer(self.levelupTimer)
    --  showTips(self:getData():getDef().name..TID_BUILDINGOBJ_BUILDCOMPLETE)
    self:initAni()
    mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_CITY_END_UPGRADE, false)
    self.BuildTipStr = TID_BUILDINGOBJ_CHANGECOMPLETE
    self:BuildAnimation()
end
function buildingObj:updateCityBuffAni()
    local buildType = self:getDef().type
    local bshow = false
    for key, var in pairs(user.Role_Buff) do
        for kk, vv in pairs(var) do
            if vv.getDef then
                local def = vv:getDef()
                if def.building then
                    local mds = me.split(def.building, ",")
                    if mds then
                        for k, v in pairs(mds) do
                            if v == buildType then
                                bshow = true
                            end
                        end
                    end
                end
            end
        end
    end
    if bshow then
        if self.pcitybuffani == nil then
            self.pcitybuffani = allAnimation:createAnimation("keji_jiesuo")
            self.pcitybuffani:getAnimation():play("donghua")
            self.pcitybuffani:setPosition(cc.p(self.icon:getContentSize().width / 2, self.icon:getContentSize().height / 2))
            self:addChild(self.pcitybuffani)
        end
    else
        if self.pcitybuffani ~= nil then
            self.pcitybuffani:removeFromParentAndCleanup(true)
            self.pcitybuffani = nil
        end
    end
end
function buildingObj:CityAnimation()

    local def = self:getDef()
    local buildType = def.type
    if buildType == cfg.BUILDING_TYPE_ABBEY then
        dump(self.state)
        if self.state == BUILDINGSTATE_WORK_TREAT.key then
            if self.pWounde == nil then
                self.pWounde = allAnimation:createAnimation("scene_build_work_3_05")
                self.pWounde:WoundedSoldier()
                self.pWounde:setPosition(cc.p(self.icon:getContentSize().width / 2, self.icon:getContentSize().height / 2))
                self:addChild(self.pWounde)
            end
        else
            if self.pWounde ~= nil then
                self.pWounde:removeFromParentAndCleanup(true)
                self.pWounde = nil
            else
                --                 self.pWounde = allAnimation:createAnimation("scene_build_work_3_05")
                --                 self.pWounde:WoundedSoldier()
                --                 self.pWounde:setPosition(cc.p(self.icon:getContentSize().width/2,self.icon:getContentSize().height/2))
                --                 self:addChild(self.pWounde)
            end
        end
    end
end
function buildingObj:stopCityAniation()
    if self.pWounde ~= nil then
        self.pWounde:removeFromParentAndCleanup(true)
        self.pWounde = nil
    end
end
function buildingObj:BuildSleepAnimation()
    local def = self:getDef()
    local buildType = def.type
    if self.state == BUILDINGSTATE_NORMAL.key then

        if buildType == cfg.BUILDING_TYPE_BARRACK then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_RANGE then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_HORSE then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_SIEGE then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_BLACKSMITH then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_ABBEY then
            if table.nums(user.desableSoldiers) > 0 and self:getState() == BUILDINGSTATE_NORMAL and table.nums(user.desableSoldiers_c) > 0 then
                self:PauseRandSleep()
            end
        elseif buildType == cfg.BUILDING_TYPE_CASTLE then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_COLLEGE then
            self:PauseRandSleep()
        elseif buildType == cfg.BUILDING_TYPE_WONDER then
            self:PauseRandSleep()
        end
    else
        if self.pAnimation ~= nil then
            self.pAnimation:removeFromParentAndCleanup(true)
            self.pAnimation = nil
        end
    end
end
function buildingObj:PauseRandSleep()
    local pTime = me.getRandom(10)
    -- 暂停时间
    self.pPauseTime = pTime
end
function buildingObj:BuildSleep()
    if self.pAnimation == nil and self.pPauseTime == 0 then
        local pTime = me.getRandom(20)
        -- 播放的时间
        if pTime < 5 then
            pTime = 10
        end
        self.pPlayTime = pTime

        self.pAnimation = allAnimation:createAnimation("scene_uild_sleep")
        self.pAnimation:CitySleep()
        self.pAnimation:setPosition(cc.p(self.icon:getContentSize().width * 0.4, self.icon:getContentSize().height * 0.6))
        self.icon:addChild(self.pAnimation, me.MAXZORDER)
        --  print(" name = "..self:getDef().name)
        --    print("xxxxxxxx = "..self.icon:getContentSize().width)
        --  print("yyyyyyyy = "..self.icon:getContentSize().height)
        local function animationEvent(armatureBack, movementType, movementID)
            if movementType == ccs.MovementEventType.loopComplete then
                if self.pPlayTime == 0 then
                    self.pAnimation:removeFromParentAndCleanup(true)
                    self.pAnimation = nil
                    local pTime = me.getRandom(20)
                    -- 暂停时间
                    if pTime < 5 then
                        pTime = 10
                    end
                    self.pPauseTime = pTime
                end
            end
        end
        self.pAnimation:getAnimation():setMovementEventCallFunc(animationEvent)
    end
end
function buildingObj:setSleepTime()
    local def = self:getDef()
    local buildType = def.type
    if buildType == cfg.BUILDING_TYPE_BARRACK then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_RANGE then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_HORSE then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_SIEGE then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_BLACKSMITH then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_ABBEY then
        if table.nums(user.desableSoldiers) > 0 and self:getState() == BUILDINGSTATE_NORMAL and table.nums(user.desableSoldiers_c) > 0 then
            self:setSleepCountDown()
        end
    elseif buildType == cfg.BUILDING_TYPE_CASTLE then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_COLLEGE then
        self:setSleepCountDown()
    elseif buildType == cfg.BUILDING_TYPE_WONDER then
        self:setSleepCountDown()
    end
end
function buildingObj:setSleepCountDown()
    if self.pPlayTime > 0 then
        self.pPlayTime = self.pPlayTime - 1
    else
        self.pPlayTime = 0
    end
    if self.pPauseTime > 0 then
        self.pPauseTime = self.pPauseTime - 1
    else

        self.pPauseTime = 0
        if self.pPlayTime == 0 and self.state == BUILDINGSTATE_NORMAL.key then
            self:BuildSleep()
        end
    end
end
function buildingObj:BuildAnimation()

    local pScaleX = self.icon:getContentSize().width / 281
    local pScaleY = self.icon:getContentSize().height / 263

    local pScale = math.min(pScaleX, pScaleY)

    local
    -- pCityC = allAnimation:createAnimation("scene_tech_update")
    --    pCityC:UpGarde()
    --    pCityC:setScale(pScale)
    --    pCityC:setPosition(cc.p(self.icon:getContentSize().width / 2, self.icon:getContentSize().height / 2))
    pCityC = createArmature("levelup")
    pCityC:setPosition(cc.p(self.icon:getContentSize().width / 2, self.icon:getContentSize().height / 2 - 100))
    self:addChild(pCityC, me.MAXZORDER)
    pCityC:getAnimation():playWithIndex(0)
    local function animationEvent(armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.complete then
            -- showTips(self:getData():getDef().name .. self.BuildTipStr)
        end
        armatureBack:removeFromParentAndCleanup()
    end
    pCityC:getAnimation():setMovementEventCallFunc(animationEvent)
end

function buildingObj:shakeTopBtn()
    self.helpBtn:stopAllActions()
    self.helpBtn:setRotation(0)
    local rotate = cc.RotateBy:create(0.06, 18)
    local rotateR = rotate:reverse()
    local rotate1 = cc.RotateBy:create(0.06, 10)
    local rotateR1 = rotate1:reverse()
    local delay = cc.DelayTime:create(3)
    local seq = cc.Sequence:create(rotate, rotateR, rotateR, rotate, rotate1, rotateR1, rotateR1, rotate1, delay)
    self.helpBtn:runAction(cc.RepeatForever:create(seq))
end 
function buildingObj:showCenterFire()
    local def = self:getDef()
    local buildType = def.type
    if buildType == cfg.BUILDING_TYPE_CENTER then
        if self.pCityAttack == nil then
            self.pCityAttack = allAnimation:createAnimation("gongji_huo_zhucheng")
            self.pCityAttack:CityCenter()
            self.pCityAttack:setPosition(cc.p(200, 160))
            self:addChild(self.pCityAttack, me.MAXZORDER)
        end
    end
end
function buildingObj:removeCneter()
    if self.pCityAttack ~= nil then
        self.pCityAttack:removeFromParentAndCleanup(true)
        self.pCityAttack = nil
    end
end

-- 根据
function buildingObj:getNameByState()
    for key, var in pairs(BUILDINGSTATE_TOTAL) do
        if self:getState() == var.key then
            return var.name .. "中"
        end
    end
    return ""
end

-- -
-- 获取加速时间
--
function buildingObj:getAccelerateTime()
    local def = self:getDef()
    if (def.type == "barrack" or def.type == "range" or def.type == "horse" or def.type == "siege" or def.type == "door"
        or def.type == "wonder") and(self:getState() == BUILDINGSTATE_WORK_TRAIN.key or self:getState() == BUILDINGSTATE_WORK_PRODUCE.key) then
        -- 造兵的建筑物特殊处理时间
        return self:getTrainTotalTime(), nil
    elseif self:getState() == BUILDINGSTATE_NORMAL.key then
        return 0, 0
    else
        return self.time, self.maxTime
    end

end
-- -
-- 获取免费时间
--
function buildingObj:getFreeTime()
    if self:getState() == BUILDINGSTATE_BUILD.key or self:getState() == BUILDINGSTATE_LEVEUP.key or self:getState() == BUILDINGSTATE_CHANGE.key then
        if not user.propertyValue["FreeTime"] then
            user.propertyValue["FreeTime"] = 300
        end
        return user.propertyValue["FreeTime"]
    elseif self:getState() == BUILDINGSTATE_WORK_TRAIN.key or self:getState() == BUILDINGSTATE_WORK_PRODUCE.key then
        return 0
    elseif self:getState() == BUILDINGSTATE_WORK_STUDY.key then
        return 0
    elseif self:getState() == BUILDINGSTATE_WORK_TREAT.key then
        return 0
    end
    return 0
end

-- 返回当前奇迹转换时间
function buildingObj:getChangeTotalTime()
    return self.time
end

-- 返回当前训练总时间
function buildingObj:getTrainTotalTime()
    local pdata = user.produceSoldierData[self:getToftId()]
    if pdata then
        local total_time =(pdata.time *(pdata.num - 1)) / 1000 +(pdata.time / 1000 - self:getCurTime())
        if pdata.stype == 1 then
            total_time = pdata.time / 1000 - self:getCurTime() - pdata.ptime / 1000
        end
        return total_time
    end
    return nil
end

-- 返回当前治疗总时间
function buildingObj:getTreatTotalTime()
    return self.time
end