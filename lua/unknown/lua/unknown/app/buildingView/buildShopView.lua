
buildShopView = class("buildShopView", function(csb)
    return cc.CSLoader:createNode(csb)
end )
buildShopView.__index = buildShopView
function buildShopView:create(csb)
    local layer = buildShopView.new(csb)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
                print(tag)
            end )
            return layer
        end
    end
    return nil
end
function buildShopView:ctor()
    print("buildShopView ctor")
    self.list = nil
    self.shopType = 1
    self.btns = nil
    -- 类型按钮
    self.tarType = nil
    -- 引导到指定的类型
    self.rechargeFinishInit = nil
    self.isInWorldMap = false
end
buildShopView.SHOPTYPE_RES = 1 -- 经济
buildShopView.SHOPTYPE_MTY = 2 -- 军事
buildShopView.SHOPTYPE_ITA = 3 -- 科技
buildShopView.SHOPTYPE_MAE = 4 -- 奇迹
buildShopView.SHOPTYPE_IAP = 5 -- 宝石
function buildShopView:init()
    print("buildShopView init")
    -- 注册触摸事件
    --    me.registGuiTouchEventByName(self,"fixLayout",function (node,event)
    --        if event ~= ccui.TouchEventType.ended then
    --            return
    --        end
    --        self:close()
    --    end)
    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.list = me.assignWidget(self, "list"):setVisible(false)
    self.listRecharge = me.assignWidget(self, "listRecharge"):setVisible(false)
    if self.btns == nil then
        self.btns = { }
        self.btns[#self.btns + 1] = me.assignWidget(self, "bs_IAP")
        self.btns[#self.btns]:setTag(buildShopView.SHOPTYPE_IAP)
        self.btns[#self.btns + 1] = me.assignWidget(self, "bs_RES")
        self.btns[#self.btns]:setTag(buildShopView.SHOPTYPE_RES)
        self.btns[#self.btns + 1] = me.assignWidget(self, "bs_ITA")
        self.btns[#self.btns]:setTag(buildShopView.SHOPTYPE_ITA)
        self.btns[#self.btns + 1] = me.assignWidget(self, "bs_MTY")
        self.btns[#self.btns]:setTag(buildShopView.SHOPTYPE_MTY)
        self.btns[#self.btns + 1] = me.assignWidget(self, "bs_MAE")
        self.btns[#self.btns]:setTag(buildShopView.SHOPTYPE_MAE)
        self.zOrder = self.btns[#self.btns]:getLocalZOrder()
    end
    --    if user.lv > 3 then
    --       me.assignWidget(self,"bs_IAP"):setVisible(true)
    --    else
    --       me.assignWidget(self,"bs_IAP"):setVisible(false)
    --    end
    for key, var in pairs(self.btns) do
        me.registGuiClickEvent(var, function(node)
            self:setBtnClicked(node)
        end )
    end
    self.rechargeFinishInit = false
    return true
end
function buildShopView:coroCreate()
    self.mH = coroutine.create( function()
        self:initList()
    end )
end
function buildShopView:close()
    self:removeFromParentAndCleanup(true)
end
function buildShopView:onEnter()
    print("buildShopView onEnter")
    me.doLayout(self, me.winSize)
    if guideHelper.guideIndex < 8 then
        guideHelper.nextStepByOpt()
    end
    self:setBtnClickedByGuide()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:updateMsg(msg)
    end )
    self:setNewBuildingTypeOpen()

end

-- 建筑商店类型按钮的新开启提示
function buildShopView:setNewBuildingTypeOpen()
    local function getBtnByType(type_)
        for key, var in pairs(self.btns) do
            if var:getTag() == type_ then
                return var
            end
        end
    end

    for i = buildShopView.SHOPTYPE_RES, buildShopView.SHOPTYPE_MAE do
        local status = SharedDataStorageHelper():getNewBuildingPage(me.toNum(i))
        print("  status = " .. status)
        if status == 1 then
            local redPoint = ccui.ImageView:create()
            redPoint:loadTexture("gongyong_icon_tishi.png", me.localType)
            getBtnByType(i):addChild(redPoint)
            redPoint:setTag(99999)
            redPoint:setPosition(cc.p(10, 66))
            redPoint:setAnchorPoint(cc.p(0.5, 0.5))
        end
    end
end

function buildShopView:updateMsg(msg)
    if self.rechargeFinishInit then
        if checkMsg(msg.t, MsgCode.RECHARGE) then
            self:doRecharge()
        end
    end
end

function buildShopView:doRecharge()
    showTips("购买成功")
    self:coroCreate()
    self.schid = me.coroStart(self.mH)
end

-- type:跳转类型， needForce：是否强制
function buildShopView:setGuideTarget(type_, needForce_)
    print("buildShopView:setGuideTarget(type_, needForce_)")
    self.tarType = type_
    self.needForce = needForce_
end
-- 根据引导,找到目标类型，并点击类型按钮
function buildShopView:setBtnClickedByGuide()
    print("buildShopView:setBtnClickedByGuide()")
    if self.tarType == buildShopView.SHOPTYPE_IAP then
        -- 引导去宝石界面
        for key, var in pairs(self.btns) do
            if me.toNum(var:getTag()) == me.toNum(self.tarType) then
                self:setBtnClicked(var)
                break
            end
        end
    elseif self.tarType ~= nil then
        -- 引导去建造界面
        local shopType = nil
        print("1111111111111111111", self.tarType)
        for key, var in pairs(cfg[CfgType.BUILDING_SHOP_TYPE][user.countryId]) do
            for ikey, ivar in pairs(var) do
                local build = ivar.def
                if build.type == self.tarType then
                    shopType = ivar.shopType
                    break
                end
            end
        end
        if shopType == nil then
--            if self.tarType == cfg.BUILDING_TYPE_TOWER then

--                me.DelayRun( function(args)
--                    self.list:jumpToRight()
--                end )
--            end
            return
        end
        for key, var in pairs(self.btns) do
            if me.toNum(var:getTag()) == me.toNum(shopType) then
                self:setBtnClicked(var)
                break
            end
        end
--        if self.tarType == cfg.BUILDING_TYPE_TOWER then

--            me.DelayRun( function(args)
--                self.list:jumpToRight()
--            end )
--        end
    else
        self:setBtnClicked(self.btns[2])
    end
end
function buildShopView:setBtnClicked(node)
    for key, var in pairs(self.btns) do
        if me.toNum(node:getTag()) == me.toNum(var:getTag()) then
            me.buttonState(var, false)
            var:setContentSize(cc.size(275, 83))
            var:setLocalZOrder(self.zOrder + 100)
            me.assignWidget(var, "title1"):setTextColor(cc.c3b(251, 236, 167))
            SharedDataStorageHelper():setNewBuildingPage(var:getTag(), 2)
            local redP = node:getChildByTag(99999)
            if redP then
                redP:removeFromParentAndCleanup(true)
            end
        else
            me.buttonState(var, true)
            var:setContentSize(cc.size(260, 83))
            me.assignWidget(var, "title1"):setTextColor(cc.c3b(192, 178, 151))
            var:setLocalZOrder(self.zOrder)
        end
    end
    self.shopType = node:getTag()
    self:coroCreate()
    self.schid = me.coroStart(self.mH)
end
function buildShopView:initList()
    -- me.LogTable( cfg[CfgType.BUILDING_SHOP_TYPE][user.countryId][self.shopType] )
    self.list:removeAllChildren()
    local t = me.sysTime()
    local width_list = self:getContentSize().width
    local height_list = self:getContentSize().height
    local spw = 4
    local sph = 1
    local index = 0
    local i = 0
    local j = 1
    local m = 3
    local n = 1
    local function doBuild(evt)
        self:close()
    end
    local function buildcallback(node)
        if not node.locked then
            if not node.blimit then
                local toft = mainCity:getCroundwork(node.bdata:getDef())
                if node.bdata:getDef().type == cfg.BUILDING_TYPE_BOAT then
                    toft = mainCity:getBoatwork(6)
                end
                if node.bdata:getDef().type == cfg.BUILDING_TYPE_ALTAR then
                    toft = mainCity:getBoatwork(7)
                end
                if node.bdata:getDef().type == cfg.BUILDING_TYPE_HALL then
                    toft = mainCity:getBoatwork(88)
                end
                if toft then
                    SharedDataStorageHelper():setNewOpenBuildings(node.bdata:getDef().id, 2)
                    local redP = node:getChildByTag(99999)
                    if redP then
                        redP:removeFromParentAndCleanup(true)
                    end

                    mainCity.bLevelUpLayer = buildLevelUpLayer:create("buildLevelUpLayer.csb")
                    mainCity.bLevelUpLayer:addEvtLisenter(doBuild)
                    node.bdata.index = toft.tid
                    me.assignWidget(mainCity.bLevelUpLayer,"image_title"):setString("建 造")
                    mainCity.bLevelUpLayer:initWithData(node.bdata)
                    mainCity:addChild(mainCity.bLevelUpLayer, me.MAXZORDER)
                    me.showLayer(mainCity.bLevelUpLayer, "fixLayout")
                else
                    showTips(TID_BUILD_NO_TILED)
                end
            else
                showTips(TID_BUILD_LIMIT)
            end
        else
            showTips(TID_BUILD_LOCKED)
        end
    end

    if self.shopType == buildShopView.SHOPTYPE_IAP then
        self.list:setVisible(false)
        self.listRecharge:setVisible(true)
        for key, var in pairs(user.recharge) do
            if var.type < 3 then
                local item = bRechargeItem:create("shopItem/rechargeItem.csb")
                item:initWithData(var, self.tarType, self.needForce)
                local iSize = item:getContentSize()
                if var.id > 7 then
                    item:setPosition((iSize.width + spw) * m + 10,(n % 2) *(iSize.height + sph))
                    if n % 2 == 0 then
                        m = m + 1
                    end
                    n = n + 1
                    self.listRecharge:setInnerContainerSize(cc.size(iSize.width *(m + 1) + 48, self.listRecharge:getContentSize().height + 3))
                    self.listRecharge:addChild(item)
                else
                    item:setPosition((iSize.width + spw) * index + 10,(j % 2) *(iSize.height + sph))
                    index =(index + 1) % 3
                    if index == 0 then
                        j = j + 1
                    end
                    self.listRecharge:setInnerContainerSize(cc.size(iSize.width * index, self.listRecharge:getContentSize().height + 3))
                    self.listRecharge:addChild(item)
                end
            end
            coroutine.yield()
        end
        self.rechargeFinishInit = true
    else
        -- 构造每个Item
        self.list:setVisible(true)
        self.listRecharge:setVisible(false)
        local sdata = cfg[CfgType.BUILDING_SHOP_TYPE][user.countryId][self.shopType]
        local function comp(a, b)
            return me.toNum(a.sort) < me.toNum(b.sort)
        end
        local tempdata = { }
        for key, var in pairs(sdata) do
            table.insert(tempdata, var)
        end
        table.sort(tempdata, comp)
        -- 排序

        for key, var in me.pairs(tempdata) do
            local build = var.def
            local root = bShopItem:create("shopItem/buildItem.csb")
            root:initWithBuildData(build, self.tarType, self.needForce)
            local buildBtn = me.assignWidget(root, "needBtn")
            local iSize = root:getContentSize()
            i = i + 1
            print("iiiiiiiiiiiiiiii ", i)
            root:setPosition((iSize.width + spw) * index,(i % 2) *(iSize.height + sph))
            -- if i>1 and i%2 == 1 then
            --    index = index + 1
            -- end
            if i % 2 == 0 then
                index = index + 1
            end
            print("index ", index)
            -- 这里需要传递建筑信息过去
            buildBtn.bdata = BuildIngData.new(0, build.id, 0)
            buildBtn.bdata.state = BUILDINGSTATE_BUILD.key
            buildBtn.bdata.shopId = var.id
            me.registGuiClickEvent(buildBtn, buildcallback)
            buildBtn:setSwallowTouches(false)
            self.list:addChild(root)
            self.list:setInnerContainerSize(cc.size(iSize.width * math.ceil(i / 2), self.list:getContentSize().height + 3))
            if i > 6 then
                self.list:setBounceEnabled(true)
            else
                self.list:setBounceEnabled(false)
            end
            coroutine.yield()
        end
        -- 如果引导是去建造禁卫营帐，就跳转到list的最右侧
        if self.tarType == cfg.BUILDING_TYPE_MONK then
            self.list:jumpToRight()
        end
    end
end 
function buildShopView:enterTransitionFinish()
end
function buildShopView:onExit()
    if self.isInWorldMap then
        if pWorldMap and pWorldMap.bshopBox then
            pWorldMap.bshopBox = nil
        end
    else
        if mainCity and mainCity.bshopBox then
            mainCity.bshopBox = nil
        end
    end
    self.tarType = nil
    self.needForce = nil
    me.coroClear(self.schid)
    print("buildShopView onExit")
    UserModel:removeLisener(self.modelkey)
end
function buildShopView:resetForWorldMap()
    for i = 2, 5 do
        self.btns[i]:setVisible(false)
    end
    self.isInWorldMap = true
end