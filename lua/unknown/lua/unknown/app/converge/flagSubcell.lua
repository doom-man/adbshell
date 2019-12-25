flagSubcell = class("flagSubcell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
flagSubcell.__index = flagSubcell
function flagSubcell:create(...)
    local layer = flagSubcell.new(...)
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
function flagSubcell:setFatherNode(fNode)
    self.fNode = fNode
end
function flagSubcell:ctor()
    self.itemGap = 10
    print("flagSubcell:ctor()")
end
function flagSubcell:init()
    self.ScrollView_item = me.assignWidget(self, "ScrollView_item")
    self.Panel_attack_EX = nil
    self.Panel_help_EX = nil
    self.timer = nil
    -- 基础面板的计时器
    self.timerEx = nil
    -- 展开面板的计时器
    self.currentUnfold = nil
    self.attackData = nil
    -- 集火科技
    self.helpData = nil
    -- 援助科技
    self.attackData2 = nil

    self.helpData2 = nil
    return true
end
function flagSubcell:onEnter()
    print("flagSubcell:onEnter()")
    self:initFlagData()
    self:initScroll()
    self:setPanelBaseData()

    self.listener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or
            checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
            local tmpData = nil
            local tmpPanel = nil
            if self.currentUnfold == self.Panel_attack then
                tmpData = self.attackData
                tmpPanel = self.Panel_attack_EX
            elseif self.currentUnfold == self.Panel_help then
                tmpData = self.helpData
                tmpPanel = self.Panel_help_EX
            elseif self.currentUnfold == self.Panel_help2 then
                tmpData = self.helpData2
                tmpPanel = self.Panel_help_EX2
            elseif self.currentUnfold == self.Panel_attack2 then
                tmpData = self.attackData2
                tmpPanel = self.Panel_attack_EX2
            end
            if tmpData and tmpData.lockStatus ~= techData.lockStatus.TECH_TECHING then --正在升级 则没有资源界面，不能刷新
                local tempDef, _, _ = self:getLevelUpDef(tmpData)
                self:setAllItems(tmpPanel, tempDef)                
            end
        elseif checkMsg(msg.t, MsgCode.CITY_TECH_FINISH) or checkMsg(msg.t, MsgCode.CITY_BUILDING_FARMERCHANGE) or checkMsg(msg.t, MsgCode.CITY_TECH_UPLEVEL) then
            me.clearTimer(self.timer)
            self.timer = nil
            me.clearTimer(self.timerEx)
            self.timerEx = nil
            self.currentUnfold = nil
            self:cleanUnfoldItemEx()
            self:initFlagData()
            self:setPanelBaseData()
        end
    end,"flagSubcell")
end
-- 返回当前显示的科技，如果未开启该科技则是显示1级，反之都显示下一等级
function flagSubcell:getLevelUpDef(data)
    --dump(data)
    local currentDef = data:getDef()
    local getMax = false
    -- 达到满级
    local isUp = false
    -- 正在升级
    local showLv = 0
    -- 显示当前等级
    if data.lockStatus == techData.lockStatus.TECH_TECHING then
        isUp = true
    else
        if currentDef.nextid ~= 0 and user.techServerDatas[currentDef.id] ~= nil then
            -- 不是满级或者零级,显示下一级属性
            currentDef = cfg[CfgType.TECH_UPDATE][me.toNum(currentDef.nextid)]
        elseif user.techServerDatas[currentDef.id] == nil and currentDef.nextid ~= 0 then
            -- 零级

        else
            getMax = true
        end
    end

    if isUp == false and getMax == true then
        showLv = currentDef.level
    else
        showLv = currentDef.level - 1
    end

    return currentDef, getMax, isUp, showLv
end
function flagSubcell:initFlagData()
    local toftid_, buildId_ = nil, nil
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if def.type == cfg.BUILDING_TYPE_TOWER then
            toftid_, buildId_ = var.index, var.defid
            break
        end
    end

    if toftid_ == nil or buildId_ == nil then
        __G__TRACKBACK__("未找到塔楼数据!!!")
        return
    end

    techDataMgr.setCurToftid(toftid_)
    techDataMgr.setCurbuildId(buildId_)
    local buildDef = cfg[CfgType.BUILDING][me.toNum(buildId_)]
    local ext = buildDef.ext
    local tabs = me.split(ext, ",")
    local _, _, _, buildType = string.find(tabs[3], "%s*(%a+)%s*:%s*(%d+)%s*")
    local techs = techDataMgr.getConvergeTechDatas(buildType)

    for key, var in pairs(techs) do
        local def = var:getDef()
        if me.toNum(def.techid) == getFlagTechIdByCountryID(21000) then
            self.helpData = var
        elseif me.toNum(def.techid) == getFlagTechIdByCountryID(22000) then
            self.attackData = var
        elseif me.toNum(def.techid) == getFlagTechIdByCountryID(23000) then
            self.helpData2 = var
        elseif me.toNum(def.techid) == getFlagTechIdByCountryID(24000) then
            self.attackData2 = var
        end
    end
end
function flagSubcell:setPanelBaseData()
    -- 设置基础面板的数据信息
    local function setBaseData(node, isUp, title, lv, curNum, nextNum, isMax)
        me.assignWidget(node, "Text_title"):setString("Lv." .. lv)
        me.assignWidget(node, "Panel_process"):setVisible(isUp)
        me.assignWidget(node, "Text_desc_process"):setVisible(isUp)
        me.assignWidget(node, "Text_desc"):setVisible(not isUp)
        if isMax then
            me.assignWidget(node, "Text_curLv_num"):setString(nextNum)
            me.assignWidget(node, "Text_nextLv"):setVisible(false)
            me.assignWidget(node, "Text_nextLv_num"):setVisible(false)
        else
            me.assignWidget(node, "Text_curLv_num"):setString(curNum)
            me.assignWidget(node, "Text_nextLv_num"):setVisible(true)
            me.assignWidget(node, "Text_nextLv"):setVisible(true)
            me.assignWidget(node, "Text_nextLv_num"):setString(nextNum)
        end
    end

    local function setUpgradingData(node, curT, totalT)
        local process = me.assignWidget(self, "Image_process"):clone()
        process:setVisible(true)
        me.assignWidget(node, "Text_desc_process"):setString("正在升级...")
        me.assignWidget(node, "Panel_process"):removeAllChildren()
        me.assignWidget(node, "Panel_process"):addChild(process)

        local function setTime(curTime, totalTime)
            me.assignWidget(process, "LoadingBar_time"):setPercent((totalTime - curTime) / totalTime * 100)
            me.assignWidget(process, "Text_precent"):setString("升级中..." .. me.formartSecTime(curTime))
        end

        setTime(curT, totalT)
        if self.timer ~= nil then
            me.clearTimer(self.timer)
            self.timer = nil
        end
        self.timer = me.registTimer(-1, function()
            setTime(curT, totalT)
            curT = curT - 1
            if curT <= 0 then
                curT = 0
            end
        end , 1)
    end

    local attackDef, attackUpMax, Panel_attack_isUp, lv = self:getLevelUpDef(self.attackData)
    setBaseData(self.Panel_attack, Panel_attack_isUp, attackDef.name, lv, attackDef.beforetxt, attackDef.successtxt, attackUpMax)
    if Panel_attack_isUp then
        -- 正在升级
        local leftTime = self.attackData:getBuildTime() / 1000 -(me.sysTime() - self.attackData.startTime) / 1000
        setUpgradingData(self.Panel_attack, leftTime, attackDef.time1)
    else
        me.assignWidget(self.Panel_attack, "Text_desc"):setString(attackDef.desc)
    end

    local attackDef, attackUpMax, Panel_attack_isUp, lv = self:getLevelUpDef(self.attackData2)
    setBaseData(self.Panel_attack2, Panel_attack_isUp, attackDef.name, lv, attackDef.beforetxt, attackDef.successtxt, attackUpMax)
    if Panel_attack_isUp then
        -- 正在升级
        local leftTime = self.attackData2:getBuildTime() / 1000 -(me.sysTime() - self.attackData2.startTime) / 1000
        setUpgradingData(self.Panel_attack2, leftTime, attackDef.time1)
    else
        me.assignWidget(self.Panel_attack2, "Text_desc"):setString(attackDef.desc)
    end

    local helpDef, helpUpMax, Panel_help_isUp, lv = self:getLevelUpDef(self.helpData)
    setBaseData(self.Panel_help, Panel_help_isUp, helpDef.name, lv, helpDef.beforetxt, helpDef.successtxt, helpUpMax)
    if Panel_help_isUp then
        -- 正在升级
        local leftTime = self.helpData:getBuildTime() / 1000 -(me.sysTime() - self.helpData.startTime) / 1000
        setUpgradingData(self.Panel_help, leftTime, helpDef.time1)
    else
        me.assignWidget(self.Panel_help, "Text_desc"):setString(helpDef.desc)
    end

    local helpDef, helpUpMax, Panel_help_isUp, lv = self:getLevelUpDef(self.helpData2)
    setBaseData(self.Panel_help2, Panel_help_isUp, helpDef.name, lv, helpDef.beforetxt, helpDef.successtxt, helpUpMax)
    if Panel_help_isUp then
        -- 正在升级
        local leftTime = self.helpData2:getBuildTime() / 1000 -(me.sysTime() - self.helpData2.startTime) / 1000
        setUpgradingData(self.Panel_help2, leftTime, helpDef.time1)
    else
        me.assignWidget(self.Panel_help2, "Text_desc"):setString(helpDef.desc)
    end
end

-- 设置List里的子控件（金币，木材，矿石，建筑物等级，科技等级等条件）
function flagSubcell:setListItems(techId, buildId, node, itemID, itemNum, optBtn_lvup, optBtn_lvup_imm)
    if itemID then
        local def = cfg[CfgType.ETC][me.toNum(itemID)]
        local status = techDetailView.DescStatus.GREEN
        local haveNum = 0
        for key, var in pairs(user.pkg) do
            local pkgDef = var:getDef()
            if me.toNum(pkgDef.id) == me.toNum(itemID) then
                haveNum = haveNum + var.count
            end
        end
        if me.toNum(haveNum) < me.toNum(itemNum) then
            status = techDetailView.DescStatus.RED
            me.setButtonDisable(optBtn_lvup, false)
            me.setButtonDisable(optBtn_lvup_imm, false)
            optBtn_lvup_imm:setTitleColor(COLOR_GRAY)
            optBtn_lvup:setTitleColor(COLOR_GRAY)
        end
        self:setSingleItems(node, def.name .. " x" .. itemNum, status, getItemIcon(def.icon), me.plistType, techDetailView.itemType.Tech)
    elseif techId then
        local def = cfg[CfgType.TECH_UPDATE][techId]
        local status = techDetailView.DescStatus.GREEN
        if techDataMgr.getUseStatusByTypeAndLv(def.techid, def.level) == false then
            status = techDetailView.DescStatus.RED
            me.setButtonDisable(optBtn_lvup, false)
            me.setButtonDisable(optBtn_lvup_imm, false)
            optBtn_lvup_imm:setTitleColor(COLOR_GRAY)
            optBtn_lvup:setTitleColor(COLOR_GRAY)
        end
        self:setSingleItems(node, def.name .. " " .. TID_LEVEL .. def.level, status, techIcon(def.icon), me.plistType, techDetailView.itemType.Tech)
    elseif buildId then
        local finded = false
        local buildDef = cfg[CfgType.BUILDING][me.toNum(buildId)]
        local info = { }
        info.name = buildDef.name
        info.lv = buildDef.level
        info.id = buildDef.id
        info.icon = buildDef.icon
        info.type = buildDef.type
        for key, var in pairs(user.building) do
            if buildDef.type == var.def.type and me.toNum(buildDef.level) <= me.toNum(var.def.level) then
                info.sts = techDetailView.DescStatus.GREEN
                finded = true
            end
        end
        if finded == false then
            info.name = buildDef.name
            info.lv = buildDef.level
            info.sts = techDetailView.DescStatus.RED
            info.id = buildDef.id
            info.icon = buildDef.icon
            info.type = buildDef.type
            me.setButtonDisable(optBtn_lvup, false)
            me.setButtonDisable(optBtn_lvup_imm, false)
            optBtn_lvup_imm:setTitleColor(COLOR_GRAY)
            optBtn_lvup:setTitleColor(COLOR_GRAY)
        end
        if info then
            self:setSingleItems(node, info.name .. " " .. TID_LEVEL .. info.lv, info.sts, buildSmallIcon(info), me.plistType, techDetailView.itemType.Building, buildId)
        end
    end
end

function flagSubcell:getUnfoldPanelWithData(node)
    -- 设置展开面板的数据信息并返回对象
    local currentData = nil
    local panel = nil

    if node == self.Panel_attack then
        currentData = self.attackData
    elseif node == self.Panel_help then
        currentData = self.helpData
    elseif node == self.Panel_help2 then
        currentData = self.helpData2
    elseif node == self.Panel_attack2 then
        currentData = self.attackData2
    end
    self.currentData=currentData

    local currentDef, getMax, isUp = self:getLevelUpDef(currentData)
    local function getDiamond(time)
        -- 钻石的消耗
        local price = { }
        price.food = currentDef.food
        price.wood = currentDef.wood
        price.stone = currentDef.stone
        price.gold = currentDef.gold
        price.time = time or currentDef.time1*getTimePercentByPropertyValue("TechTime")
        price.index = 3
        local allCost = getGemCost(price)
        return math.ceil(allCost)
    end

    if isUp then
        -- 正在升级
        panel = cc.CSLoader:createNode("Panel_converge_imm.csb")
        local diamondNum = me.assignWidget(panel, "diamondNum")
        local ntime = me.assignWidget(panel, "ntime")
        local leftTime = currentData:getBuildTime() / 1000 -(me.sysTime() - currentData.startTime) / 1000
        diamondNum:setString(getDiamond(leftTime))
        ntime:setString(me.formartSecTime(leftTime))
        self.timerEx = me.registTimer(-1, function()
            ntime:setString(me.formartSecTime(leftTime))
            diamondNum:setString(getDiamond(leftTime))
            leftTime = leftTime - 1
            if leftTime<=0 then
                leftTime = 0
            end
        end,1)
        me.registGuiClickEventByName(panel, "optBtn_lvup", function()
            -- 道具加速
            local tarTools = getBackpackDatasByType(BUILDINGSTATE_WORK_STUDY.key)
            if table.nums(tarTools) > 0 then
                -- 判断是否加速道具
                local tmpView = useToolsView:create("useToolsView.csb")
                tmpView:setToolsType(BUILDINGSTATE_WORK_STUDY.key, techDataMgr.getCurToftid())
				tmpView:setRelatedObj(self)
                tmpView:setTime((me.sysTime() - currentData.startTime) / 1000, currentData:getBuildTime() / 1000)
                self.fNode:addChild(tmpView, me.MAXZORDER)
                me.showLayer(tmpView, "bg")
            else
                showTips("道具数量不足")
            end
        end )
        me.registGuiClickEventByName(panel, "optBtn_lvup_imm", function()
            -- 钻石加速
            local function diamondUse()
                NetMan:send(_MSG.buildQuickGem(techDataMgr.getCurToftid()))
            end
            local needDiamond = tonumber(diamondNum:getString())
            if user.diamond<needDiamond then
                diamondNotenough(needDiamond, diamondUse)  
            else
                diamondUse()
            end
        end )
    else
        -- 等待升级
        panel = cc.CSLoader:createNode("Panel_converge_upgrade.csb")
        local diamondNum = me.assignWidget(panel, "diamondNum")
        local ntime = me.assignWidget(panel, "ntime")
        if getMax == false then
            diamondNum:setString(getDiamond())
            ntime:setString(me.formartSecTime(currentDef.time1*getTimePercentByPropertyValue("TechTime")))
            me.registGuiClickEventByName(panel, "optBtn_lvup", function()
                -- 开始研究
                NetMan:send(_MSG.techUpLevel(currentDef.techid, currentDef.level, techDataMgr.getCurToftid(), 0))
            end )
            me.registGuiClickEventByName(panel, "optBtn_lvup_imm", function()
                -- 钻石加速
                local function diamondUse()
                    NetMan:send(_MSG.techUpLevel(currentDef.techid, currentDef.level, techDataMgr.getCurToftid(), 1))
                end
                local needDiamond = tonumber(diamondNum:getString())
                if user.diamond<needDiamond then
                    diamondNotenough(needDiamond, diamondUse)  
                else
                    diamondUse()
                end
            end )
            self:setAllItems(panel, currentDef)
        else
            diamondNum:setString(0)
            ntime:setString(me.formartSecTime(0))
            local optBtn_lvup = me.assignWidget(panel, "optBtn_lvup")
            local optBtn_lvup_imm = me.assignWidget(panel, "optBtn_lvup_imm")
            me.buttonState(optBtn_lvup, false)
            me.buttonState(optBtn_lvup_imm, false)
            optBtn_lvup_imm:setTitleColor(COLOR_GRAY)
            optBtn_lvup:setTitleColor(COLOR_GRAY)
        end
    end
    return panel
end

-- 设置升级条件item
function flagSubcell:setAllItems(panel, currentDef)
    local nlist_right = me.assignWidget(panel, "nlist_right")
    local nlist_left = me.assignWidget(panel, "nlist_left")
    local optBtn_lvup = me.assignWidget(panel, "optBtn_lvup")
    me.setButtonDisable(optBtn_lvup, true)
    optBtn_lvup:setTitleColor(COLOR_WHITE)
    local optBtn_lvup_imm = me.assignWidget(panel, "optBtn_lvup_imm")
    me.setButtonDisable(optBtn_lvup_imm, true)
    optBtn_lvup_imm:setTitleColor(COLOR_WHITE)
    local builds = me.split(currentDef.buildLevel, ",")
    -- 添加一条研究需要其他建筑等级ListItem
    nlist_right:removeAllChildren()
    nlist_left:removeAllChildren()
    for key, var in pairs(builds) do
        self:setListItems(nil, var, nlist_left, nil, nil, optBtn_lvup, optBtn_lvup_imm)
    end
    -- 添加一条研究解锁需要科技ListItem
    local tmpTables = techDataMgr.splitTechOps(currentDef.needtekId)
    if tmpTables then
        for key, var in pairs(tmpTables) do
            local id = techDataMgr.getTechIDByTypeAndLV(key, var)
            self:setListItems(id, nil, nlist_left, nil, nil, optBtn_lvup, optBtn_lvup_imm)
        end
    end

    -- 添加需要的道具
    local tools = me.split(currentDef.item, ":")
    if table.nums(tools) > 0 then
        self:setListItems(nil, nil, nlist_left, tools[1], tools[2], optBtn_lvup, optBtn_lvup_imm)
    end

    -- 添加需要金币，木材，石头，食物
    self:setSingleItems(nlist_right, currentDef.gold, self:getRightItemStatus("gold", currentDef), ICON_RES_GOLD, me.localType, techDetailView.itemType.Res, optBtn_lvup)
    self:setSingleItems(nlist_right, currentDef.wood, self:getRightItemStatus("wood", currentDef), ICON_RES_LUMBER, me.localType, techDetailView.itemType.Res, optBtn_lvup)
    self:setSingleItems(nlist_right, currentDef.stone, self:getRightItemStatus("stone", currentDef), ICON_RES_STONE, me.localType, techDetailView.itemType.Res, optBtn_lvup)
    self:setSingleItems(nlist_right, currentDef.food, self:getRightItemStatus("food", currentDef), ICON_RES_FOOD, me.localType, techDetailView.itemType.Res, optBtn_lvup)
end

function flagSubcell:getRightItemStatus(key, def)
    local tmpStatus = nil
    if def[key] <= 0 then
        tmpStatus = techDetailView.DescStatus.EMPTY
    elseif user[key] >= def[key] then
        tmpStatus = techDetailView.DescStatus.GREEN
    elseif user[key] < def[key] then
        tmpStatus = techDetailView.DescStatus.RED
    end
    return tmpStatus
end

-- 设置每条List的item数据
function flagSubcell:setSingleItems(list, desc, status, resPNG, resType, itemType, targetBid, optBtn_lvup)
    if status == techDetailView.DescStatus.EMPTY then
        return
    end
    local tItem = me.createNode("bNeedConvageItem.csb")
    local bItem = me.assignWidget(tItem, "bg"):clone()
    local ticon = me.assignWidget(bItem, "icon")
    local tdesc = me.assignWidget(bItem, "desc")
    local tcomplete = me.assignWidget(bItem, "complete")
    local toptBtn = me.assignWidget(bItem, "optBtn")      
    me.registGuiClickEventByName(bItem, "optBtn", function(node)
        if itemType == techDetailView.itemType.Building and targetBid then
            if CUR_GAME_STATE == GAME_STATE_CITY then
                local ndata = cfg[CfgType.BUILDING][me.toNum(targetBid)]
                jumpToTarget(ndata)
                if self.fNode then
                    self.fNode:close()
                end
            else
                showTips("领主大人，请切换至内城!")
            end
        elseif itemType == techDetailView.itemType.Res then
            if CUR_GAME_STATE == GAME_STATE_CITY then
                local tmpView = recourceView:create("rescourceView.csb")
                local typeKey_ = nil
                if resPNG == ICON_RES_FOOD then
                    typeKey_ = "food"
                elseif resPNG == ICON_RES_LUMBER then
                    typeKey_ = "wood"
                elseif resPNG == ICON_RES_GOLD then
                    typeKey_ = "gold"
                elseif resPNG == ICON_RES_STONE then
                    typeKey_ = "stone"
                end
                tmpView:setRescourceType(typeKey_)
				tmpView:setRescourceNeedNums(tonumber(desc))
                mainCity:addChild(tmpView, me.MAXZORDER)
                me.showLayer(tmpView, "bg")
            else
                showTips("领主大人，请切换至内城!")
            end
        elseif itemType == techDetailView.itemType.Tech then
            if CUR_GAME_STATE == GAME_STATE_CITY then
                local tmpView = hornShopView:create("hornShopView.csb")
                tmpView:initWithType(8)
                mainCity:addChild(tmpView, me.MAXZORDER)
                me.showLayer(tmpView, "bg")
            else
                showTips("领主大人，请切换至内城!")
            end
        end
    end )

    ticon:loadTexture(resPNG, resType)
    if status == techDetailView.DescStatus.RED then
        tdesc:setColor(COLOR_RED)
        tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
        if itemType == techDetailView.itemType.Tech then
            toptBtn:setVisible(true)
        elseif itemType == techDetailView.itemType.Building then
            toptBtn:setVisible(true)
            toptBtn:setTitleText(TID_BUTTON_JUMPTO)
        elseif itemType == techDetailView.itemType.Res then
            toptBtn:setVisible(true)
            toptBtn:setTitleText(TID_BUTTON_GETMORE)
        end
        if optBtn_lvup then
            me.setButtonDisable(optBtn_lvup, false)
            optBtn_lvup:setTitleColor(COLOR_GRAY)
        end
    elseif status == techDetailView.DescStatus.GREEN then
        tcomplete:loadTexture("waicheng_beijing_kuang_gou.png", me.localType)
        toptBtn:setVisible(false)
        tdesc:setColor(COLOR_GREEN_FLAG)
    end
    tdesc:setString(desc)
    list:pushBackCustomItem(bItem)
    return true
end
function flagSubcell:initScroll()
    if self.Panel_help then
        self.Panel_help:removeFromParent()
        self.Panel_help = nil
    end
    if self.Panel_attack then
        self.Panel_attack:removeFromParent()
        self.Panel_attack = nil
    end
    if self.Panel_help2 then
        self.Panel_help2:removeFromParent()
        self.Panel_help2 = nil
    end
    if self.Panel_attack2 then
        self.Panel_attack2:removeFromParent()
        self.Panel_attack2 = nil
    end

    self.ScrollView_item:removeAllChildren()
    self.Panel_attack = me.assignWidget(self, "Panel_attack"):clone()
    self.ScrollView_item:addChild(self.Panel_attack)
    self.Panel_attack:setVisible(true)
    local h = self.Panel_attack:getContentSize().height * 4
    self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))

    self.Panel_help = me.assignWidget(self, "Panel_help"):clone()
    self.ScrollView_item:addChild(self.Panel_help)
    self.Panel_help:setVisible(true)
    self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2))

    self.Panel_attack2 = me.assignWidget(self, "Panel_attack"):clone()
    me.assignWidget(self.Panel_attack2, "Image_2"):loadTexture("converge_red_flag2.png")
    local img_flag_icon = me.assignWidget(self.Panel_attack2, "img_flag_icon")
    img_flag_icon:loadTexture("lianmeng_69.png")
    img_flag_icon:ignoreContentAdaptWithSize(true)
    self.ScrollView_item:addChild(self.Panel_attack2)
    self.Panel_attack2:setVisible(true)
    self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3))
    
    self.Panel_help2 = me.assignWidget(self, "Panel_help"):clone()
    me.assignWidget(self.Panel_help2, "Image_2"):loadTexture("converge_blue_flag2.png")
    local img_flag_icon = me.assignWidget(self.Panel_help2, "img_flag_icon")
    img_flag_icon:loadTexture("lianmeng_70.png")
    img_flag_icon:ignoreContentAdaptWithSize(true)
    self.ScrollView_item:addChild(self.Panel_help2)
    self.Panel_help2:setVisible(true)
    self.Panel_help2:setPosition(cc.p(0,  h - self.Panel_attack:getContentSize().height*4))

    self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))

    me.registGuiTouchEventByName(self.Panel_help, "Panel_help", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self:unfoldItem(node)
    end )
    me.registGuiTouchEventByName(self.Panel_help2, "Panel_help", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self:unfoldItem(node)
    end )
    me.registGuiTouchEventByName(self.Panel_attack, "Panel_attack", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self:unfoldItem(node)
    end )
    me.registGuiTouchEventByName(self.Panel_attack2, "Panel_attack", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            return
        end
        self:unfoldItem(node)
    end )
end

function flagSubcell:cleanUnfoldItemEx()
    if self.Panel_attack_EX then
        self.Panel_attack_EX:stopAllActions()
        self.Panel_attack_EX:removeFromParent()
        self.Panel_attack_EX = nil
    end
    if self.Panel_help_EX then
        self.Panel_help_EX:stopAllActions()
        self.Panel_help_EX:removeFromParent()
        self.Panel_help_EX = nil
    end
    if self.Panel_help_EX2 then
        self.Panel_help_EX2:stopAllActions()
        self.Panel_help_EX2:removeFromParent()
        self.Panel_help_EX2 = nil
    end
    if self.Panel_attack_EX2 then
        self.Panel_attack_EX2:stopAllActions()
        self.Panel_attack_EX2:removeFromParent()
        self.Panel_attack_EX2 = nil
    end

    local h = self.Panel_attack:getContentSize().height * 4
    self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))

    self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))
    self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2))
    self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3))
    self.Panel_help2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4))

    me.assignWidget(self.Panel_attack, "Image_arrow"):setRotation(0)
    me.assignWidget(self.Panel_help, "Image_arrow"):setRotation(0)
    me.assignWidget(self.Panel_attack2, "Image_arrow"):setRotation(0)
    me.assignWidget(self.Panel_help2, "Image_arrow"):setRotation(0)
end

function flagSubcell:unfoldItem(node)

    local function rotationArrow(node)
        local action = cc.RotateTo:create(0.2, 90)
        node:runAction(action)
    end

    local function resetPanelPos()
        me.assignWidget(self.Panel_attack, "Image_arrow"):stopAllActions()
        me.assignWidget(self.Panel_help, "Image_arrow"):stopAllActions()
        me.assignWidget(self.Panel_attack, "Image_arrow"):setRotation(0)
        me.assignWidget(self.Panel_help, "Image_arrow"):setRotation(0)
        me.assignWidget(self.Panel_attack2, "Image_arrow"):stopAllActions()
        me.assignWidget(self.Panel_help2, "Image_arrow"):stopAllActions()
        me.assignWidget(self.Panel_attack2, "Image_arrow"):setRotation(0)
        me.assignWidget(self.Panel_help2, "Image_arrow"):setRotation(0)
        self:cleanUnfoldItemEx()
    end

    me.clearTimer(self.timerEx)
    resetPanelPos()

    if node == self.Panel_attack then
        if self.currentUnfold ~= node then
            -- 展开升级详情
            rotationArrow(me.assignWidget(self.Panel_attack, "Image_arrow"))
            self.currentUnfold = node
            self.Panel_attack_EX = self:getUnfoldPanelWithData(node)
            
            local h1 = self.Panel_attack_EX:getContentSize().height
            local h = self.Panel_attack:getContentSize().height * 4 + h1

            self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))
            self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))
            self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2-h1))
            self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3-h1))
            self.Panel_help2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4-h1))
            
            self.Panel_attack_EX:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height-h1))

            self.Panel_attack_EX:setVisible(true)
            self.ScrollView_item:addChild(self.Panel_attack_EX)
            self.ScrollView_item:scrollToTop(0.2, true)
        else
            -- 关闭升级详情
            self.currentUnfold = nil
        end
    elseif node == self.Panel_help then
        if self.currentUnfold ~= node then
            -- 展开升级详情
            rotationArrow(me.assignWidget(self.Panel_help, "Image_arrow"))
            self.currentUnfold = node
            self.Panel_help_EX = self:getUnfoldPanelWithData(node)
            local h1 = self.Panel_help_EX:getContentSize().height
            local h = self.Panel_attack:getContentSize().height * 4 + h1

            self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))
            self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))
            self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2))
            self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3-h1))
            self.Panel_help2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4-h1))
           
            self.Panel_help_EX:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2-h1))
            self.Panel_help_EX:setVisible(true)
            self.ScrollView_item:addChild(self.Panel_help_EX)
            self.ScrollView_item:scrollToPercentVertical(33,0.2, true)
        else
            -- 关闭升级详情
            self.currentUnfold = nil
        end
    elseif node == self.Panel_attack2 then
        if self.currentUnfold ~= node then
            -- 展开升级详情
            rotationArrow(me.assignWidget(self.Panel_attack2, "Image_arrow"))
            self.currentUnfold = node
            self.Panel_attack_EX2 = self:getUnfoldPanelWithData(node)
            
            local h1 = self.Panel_attack_EX2:getContentSize().height
            local h = self.Panel_attack:getContentSize().height * 4 + h1

            self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))
            self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))
            self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2))
            self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3))
            self.Panel_help2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4-h1))
            
            self.Panel_attack_EX2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3-h1))

            self.Panel_attack_EX2:setVisible(true)
            self.ScrollView_item:addChild(self.Panel_attack_EX2)
            self.ScrollView_item:scrollToPercentVertical(66,0.2, true)
        else
            -- 关闭升级详情
            self.currentUnfold = nil
        end
    elseif node == self.Panel_help2 then
        if self.currentUnfold ~= node then
            -- 展开升级详情
            rotationArrow(me.assignWidget(self.Panel_help2, "Image_arrow"))
            self.currentUnfold = node
            self.Panel_help_EX2 = self:getUnfoldPanelWithData(node)
            local h1 = self.Panel_help_EX2:getContentSize().height
            local h = self.Panel_attack:getContentSize().height * 4 + h1

            self.ScrollView_item:setInnerContainerSize(cc.size(self.ScrollView_item:getContentSize().width, h))
            self.Panel_attack:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height))
            self.Panel_help:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*2))
            self.Panel_attack2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*3))
            self.Panel_help2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4))
           
            self.Panel_help_EX2:setPosition(cc.p(0, h - self.Panel_attack:getContentSize().height*4-h1))
            self.Panel_help_EX2:setVisible(true)
            self.ScrollView_item:addChild(self.Panel_help_EX2)
            self.ScrollView_item:scrollToPercentVertical(99,0.2, true)
        else
            -- 关闭升级详情
            self.currentUnfold = nil
        end
    end
end
function flagSubcell:onEnterTransitionDidFinish()
    print("flagSubcell:onEnterTransitionDidFinish()")
end
function flagSubcell:onExit()
    me.clearTimer(self.timer)
    me.clearTimer(self.timerEx)
    UserModel:removeLisener(self.listener)
    print("flagSubcell:onExit()")
end

---
-- 获取加速时间
--
function flagSubcell:getAccelerateTime()
    local currentDef, getMax, isUp = self:getLevelUpDef(self.currentData)
    if isUp then
        return (me.sysTime() - self.currentData.startTime) / 1000, self.currentData:getBuildTime() / 1000
    else
         return 0, 0
    end
end
---
-- 获取免费时间
--
function flagSubcell:getFreeTime()
    return 0
end