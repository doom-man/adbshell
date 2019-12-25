runeStrengthView = class("runeStrengthView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeStrengthView:create(...)
    local layer = runeStrengthView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)
            return layer
        end
    end
    return nil
end

function runeStrengthView:ctor()
end

function runeStrengthView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeStrengthView:onEnterTransitionDidFinish()
end

function runeStrengthView:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeStrengthView:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_STRENGTH) then -- 强化符文
        local runeInfo = user.runeBackpack[msg.c.id]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.runeInfo.plan]
            runeInfo = nowEquip[self.runeInfo.index]
        end

        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_STRENGTH)
        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2+50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)

        self:setSelectRuneInfo(runeInfo)
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or  
           checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or  
           checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then -- 背包数量改变
        self:updateStrenghView()
    end
end

function runeStrengthView:init()
    print("runeStrengthView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        if self.closeCallback~=nil then
            self.closeCallback(self.runeInfo)
        end
        self:removeFromParentAndCleanup(true)
    end )

    self.baseTxt = me.assignWidget(self, "baseTxt")
    self.appendTxt = me.assignWidget(self, "appendTxt")

    -- 符文icon
	self.runeIcon = runeItem:create(me.assignWidget(self, "runeIcon"), 1) 
	-- 符文名称
    self.prevName = me.assignWidget(self, "prevName")
    self.nextName = me.assignWidget(self, "nextName")
    self.prevLevel     = me.assignWidget(self, "prevLevel")
	self.nextLevel     = me.assignWidget(self, "nextLevel")

    self.runePropListPrev = me.assignWidget(self, "list_property_prev")
    self.runePropListPrev:setScrollBarEnabled (false)

    self.runePropListNext = me.assignWidget(self, "list_property_next")
    self.runePropListNext:setScrollBarEnabled (false)

    self.stoneIcon = me.assignWidget(self, "text_stone_icon")
    self.goldIcon = me.assignWidget(self, "text_gold_icon")
	self.woodIcon  = me.assignWidget(self, "text_wood_icon")

	-- 消耗强化石等资源数量
	self.textStoneNum1 = me.assignWidget(self, "text_stone_num_1")
    self.textStoneNum2 = me.assignWidget(self, "text_stone_num_2")
	self.textWoodNum2  = me.assignWidget(self, "text_wood_num_2")
	self.textWoodNum1  = me.assignWidget(self, "text_wood_num_1")
    self.textGoldNum2  = me.assignWidget(self, "text_gold_num_2")
	self.textGoldNum1  = me.assignWidget(self, "text_gold_num_1")


    self.stone_icon_enough = me.assignWidget(self, "stone_icon_enough")
    self.gold_icon_enough = me.assignWidget(self, "gold_icon_enough")
    self.wood_icon_enough = me.assignWidget(self, "wood_icon_enough")
    self.btn_get_more_stone = me.assignWidget(self, "btn_get_more_stone")
    self.btn_get_more_gold = me.assignWidget(self, "btn_get_more_gold")
	self.btn_get_more_wood = me.assignWidget(self, "btn_get_more_wood")

    me.registGuiClickEvent(self.btn_get_more_gold, function (sender)
        -- 商店
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(sender.shopKey)
        tmpView:setRescourceNeedNums(sender.needNums)
        me.runningScene():addChild(tmpView, self:getLocalZOrder())
        me.showLayer(tmpView, "bg")
        --self:removeFromParentAndCleanup(true)
    end)
    me.registGuiClickEvent(self.btn_get_more_wood, function (sender)
        -- 商店
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(sender.shopKey)
        tmpView:setRescourceNeedNums(sender.needNums)
        me.runningScene():addChild(tmpView, self:getLocalZOrder())
        me.showLayer(tmpView, "bg")
        --self:removeFromParentAndCleanup(true)
    end)

    local function openGetRuneStoneCallback (sender)
        local function findUserEquip(id)
            local nowEquip = user.runeEquiped[self.runeInfo.plan]
            for _, v in pairs(nowEquip) do
                if v.id==id then
                    return true
                end
            end
            return false
        end
        local function closeCallback()
            if user.runeBackpack[self.runeInfo.id]==nil and findUserEquip(self.runeInfo.id)==false then 
                self:removeFromParentAndCleanup(true)
            end
        end
        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
        me.runningScene():addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView,"bg")
        getWayView:setData(self.btn_get_more_stone:getTag())
        getWayView:setCloseCallback(closeCallback)
    end
    self.btn_get_more_stone:addClickEventListener(openGetRuneStoneCallback)
	-- 强化
	self.btnStrength = me.assignWidget(self, "btn_strength")
	self.btnStrength:addClickEventListener(function (sender)
        -- 请求强化
        if self.tipStr ~= "" then
            showTips(self.tipStr)
            return
        end

        local id = self.runeInfo.id
        NetMan:send(_MSG.Rune_strength(id))
        showWaitLayer ()
	end)
    return true
end

function runeStrengthView:setSelectRuneInfo(runeInfo)
	self.runeInfo = runeInfo
	self:updateStrenghView()
end

function runeStrengthView:setGotoRunePackCallback(goRunePackCallback)
    self.goRunePackCallback = goRunePackCallback
end
function runeStrengthView:setCloseCallback(closeCallback)
    self.closeCallback = closeCallback
end


function runeStrengthView:updateStrenghView ()
	local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.runeInfo.cfgId]
    self.prevName:setString(runeBaseCfg.name)

    self.runeIcon:setData(self.runeInfo)
    -- 属性
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
    local nextRuneStrengthCfg = cfg[CfgType.RUNE_STRENGTH][runeStrengthCfg.nextId]

    self.prevLevel:setString("+" .. runeStrengthCfg.level)

    self.runePropListPrev:removeAllItems()
    self.runePropListNext:removeAllItems()

    -- TODO : 符文强化等级最大时30级
    if runeStrengthCfg.level >= 30 then
        self.nextName:setString('')
        self.nextLevel:setString('')
        self.btnStrength:setBright(false)
        self.btnStrength:setTouchEnabled(false)
        me.assignWidget(self, "tipsTxt"):setVisible(true)
        me.assignWidget(self, "resNode"):setVisible(false)
        return
    end
    me.assignWidget(self, "tipsTxt"):setVisible(false)
    me.assignWidget(self, "resNode"):setVisible(true)

    self.nextName:setString(runeBaseCfg.name)
    self.nextLevel:setString("+" .. nextRuneStrengthCfg.level)

    self.btnStrength:setBright(true)
    self.btnStrength:setTouchEnabled(true)
    
    local prevBaseAttr = {}
	local strPropKV = runeStrengthCfg.property~=nil and string.split(runeStrengthCfg.property, ",") or {}
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        prevBaseAttr[attKey]=attValue
    end

    local prevAddAttr = getRuneStrengthAttr(runeStrengthCfg, self.runeInfo.apt)

    local nextBaseAttr = {}
	local strPropKV = nextRuneStrengthCfg.property~=nil and string.split(nextRuneStrengthCfg.property, ",") or {}
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        nextBaseAttr[attKey]=attValue
    end

    local nextAddAttr = getRuneStrengthAttr(nextRuneStrengthCfg, self.runeInfo.apt)

    local baseTxt = self.baseTxt:clone():setVisible(true)
    self.runePropListPrev:pushBackCustomItem(baseTxt)
    local baseTxt = self.baseTxt:clone():setVisible(true)
    self.runePropListNext:pushBackCustomItem(baseTxt)

    --基础属性填充
    local baseAttrLeftNums = 0
    local baseAttrRightNums = 0
    for k, v in pairs (prevBaseAttr) do
        local attStr = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (v*100).."%"
        local baseTxt = self.baseTxt:clone():setVisible(true)
        baseTxt:setString(attStr)
        self.runePropListPrev:pushBackCustomItem(baseTxt)

        if nextBaseAttr[k] then
            local attStr1 = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (nextBaseAttr[k]*100).."%"
            local baseTxt1 = self.baseTxt:clone():setVisible(true)
            baseTxt1:setString(attStr1)
            self.runePropListNext:pushBackCustomItem(baseTxt1)

            baseAttrRightNums=baseAttrRightNums+1
            if nextBaseAttr[k]*100>v*100 then        --右边大于左边  显示红色
                --baseTxt1:setTextColor(cc.c3b(255, 0, 0))
            end

            nextBaseAttr[k]=nil
        else
            --baseTxt:setTextColor(cc.c3b(255, 0, 0))   --右边没有文字 显示红色
        end
        baseAttrLeftNums = baseAttrLeftNums+1
    end
    for k, v in pairs (nextBaseAttr) do         --右边 显示剩余属性
        local attStr = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (v*100).."%"
        local baseTxt = self.baseTxt:clone():setVisible(true)
        --baseTxt:setTextColor(cc.c3b(255, 0, 0))
        baseTxt:setString(attStr)
        self.runePropListNext:pushBackCustomItem(baseTxt)
        baseAttrRightNums=baseAttrRightNums+1
    end
    ---填充缺失的属性
    local list = nil
    local diff = 0
    if baseAttrLeftNums<baseAttrRightNums then
        list=self.runePropListPrev
        diff = baseAttrRightNums-baseAttrLeftNums
    else
        list=self.runePropListNext
        diff = baseAttrLeftNums-baseAttrRightNums
    end
    for i=1, diff do
        local baseTxt = self.baseTxt:clone():setVisible(true)
        baseTxt:setString("")
        list:pushBackCustomItem(baseTxt)
    end

    local baseTxt = self.appendTxt:clone():setVisible(true)
    self.runePropListPrev:pushBackCustomItem(baseTxt)
    local baseTxt = self.appendTxt:clone():setVisible(true)
    self.runePropListNext:pushBackCustomItem(baseTxt)
    --追加属性填充
    local appendAttrLeftNums = 0
    local appendAttrRightNums = 0
    for k1, v1 in ipairs (prevAddAttr) do
        local attStr = cfg[CfgType.LORD_INFO][v1.k].name .. ":+" .. v1.v..v1.unit
        local baseTxt = self.appendTxt:clone():setVisible(true)
        baseTxt:setString(attStr)
        self.runePropListPrev:pushBackCustomItem(baseTxt)

        appendAttrLeftNums = appendAttrLeftNums+1
    end
    for k1, v1 in ipairs (nextAddAttr) do         --右边 显示剩余属性
        local attStr = cfg[CfgType.LORD_INFO][v1.k].name .. ":+" .. v1.v..v1.unit
        local baseTxt = self.appendTxt:clone():setVisible(true)
        --baseTxt:setTextColor(cc.c3b(255, 0, 0))
        baseTxt:setString(attStr)
        self.runePropListNext:pushBackCustomItem(baseTxt)
        appendAttrRightNums=appendAttrRightNums+1
    end
    ---填充缺失的属性
    local list = nil
    local diff = 0
    if appendAttrLeftNums<appendAttrRightNums then
        list=self.runePropListPrev
        diff = appendAttrRightNums-appendAttrLeftNums
    else
        list=self.runePropListNext
        diff = appendAttrLeftNums-appendAttrRightNums
    end
    for i=1, diff do
        local baseTxt = self.appendTxt:clone():setVisible(true)
        baseTxt:setString("")
        list:pushBackCustomItem(baseTxt)
    end


    
    -- 消耗材料（粮食，木头等）
    local arrTbRes = {}
    local stoneRes = nil
	local resourceStr = me.split(nextRuneStrengthCfg.upNeed, ",")
	for k, v in pairs (resourceStr) do
		local tbRes = {}
    	tbRes.color = cc.c4b (65, 229, 33, 255)
	    local resStr = string.split(v, ":")
	    if tonumber(resStr[1]) == 9004 and tonumber(resStr[2]) ~= 0 then
	    	tbRes.resIcon = "gongyong_tubiao_jingbi.png"
            tbRes.shopKey = "gold"
	    	tbRes.resNum = tonumber(resStr[2])
            tbRes.resNowNum = user.gold
            tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
            tbRes.isEnough = true
	    	if tbRes.resNum > user.gold then
    			tbRes.color = cc.c4b (255, 0, 0, 255)
                tbRes.isEnough = false
                tbRes.enoughIcon = "shengji_tubiao_buzu.png"
                tbRes.tipStr = "金币不足"
	    	end
	    	table.insert (arrTbRes, tbRes)
	    elseif tonumber(resStr[1]) == 9003  and tonumber(resStr[2]) ~= 0 then
	        tbRes.resIcon = "gongyong_tubiao_shitou.png"
            tbRes.shopKey = "stone"
	    	tbRes.resNum = tonumber(resStr[2])
            tbRes.resNowNum = user.stone
            tbRes.isEnough = true
            tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
	    	if tbRes.resNum > user.stone then
    			tbRes.color = cc.c4b (255, 0, 0, 255)
                tbRes.isEnough = false
                tbRes.enoughIcon = "shengji_tubiao_buzu.png"
                tbRes.tipStr = "石头不足"
	    	end
	    	table.insert (arrTbRes, tbRes)
	    elseif tonumber(resStr[1]) == 9002  and tonumber(resStr[2]) ~= 0 then
	        tbRes.resIcon = "gongyong_tubiao_mucai.png"
            tbRes.shopKey = "wood"
	    	tbRes.resNum = tonumber(resStr[2])
            tbRes.resNowNum = user.wood
            tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
            tbRes.isEnough = true
	    	if tbRes.resNum > user.wood then
                tbRes.isEnough = false
                tbRes.enoughIcon = "shengji_tubiao_buzu.png"
    			tbRes.color = cc.c4b (255, 0, 0, 255)
                tbRes.tipStr = "木材不足"
	    	end
	    	table.insert (arrTbRes, tbRes)
	    elseif tonumber(resStr[1]) == 9001  and tonumber(resStr[2]) ~= 0 then
	        tbRes.resIcon = "gongyong_tubiao_liangshi.png"
            tbRes.shopKey = "food"
	    	tbRes.resNum = tonumber(resStr[2])
            tbRes.resNowNum = user.food
            tbRes.isEnough = true
            tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
	    	if tbRes.resNum > user.food then
                tbRes.isEnough = false
                tbRes.enoughIcon = "shengji_tubiao_buzu.png"
    			tbRes.color = cc.c4b (255, 0, 0, 255)
                tbRes.tipStr = "粮食不足"
	    	end
	    	table.insert (arrTbRes, tbRes)
        elseif tonumber(resStr[2]) ~= 0 then
            strengthStoneNum = tonumber(resStr[2])
            local itemObj = getBackpackDatasByCfgId(tonumber(resStr[1]))
            self.stoneIcon:loadTexture(itemObj.icon)
            self.stoneIcon:ignoreContentAdaptWithSize (false)
            self.textStoneNum1:setString(tostring(itemObj.nums))
            self.textStoneNum2:setString("/"..tostring(strengthStoneNum))
            self.btn_get_more_stone:setTag(tonumber(resStr[1]))
            tbRes.isEnough = true
            self.textStoneNum1:setTextColor(cc.c4b (65, 229, 33, 255))
            self.stone_icon_enough:setTexture("shengji_tubiao_manzhu.png")
            if strengthStoneNum > itemObj.nums then
                self.textStoneNum1:setTextColor(cc.c4b (255, 0, 0, 255))
                self.stone_icon_enough:setTexture("shengji_tubiao_buzu.png")
                tbRes.tipStr = itemObj.name.."不足"
                tbRes.isEnough = false
            end
            stoneRes = tbRes
	    end
	end

    local tipStr = ""
    if arrTbRes[1].isEnough == false then
        tipStr = arrTbRes[1].tipStr
    elseif arrTbRes[2].isEnough == false then
        tipStr = arrTbRes[2].tipStr
     elseif stoneRes.isEnough == false then
        tipStr = stoneRes.tipStr
    elseif not bLessLevelBuilding(cfg.BUILDING_TYPE_ALTAR , runeStrengthCfg.level) then
        tipStr = "强化等级不能超过圣殿等级"
    end


    self.goldIcon:setTexture(arrTbRes[1].resIcon)
    self.textGoldNum1:setString(tostring(Scientific(arrTbRes[1].resNowNum)))
    self.textGoldNum1:setTextColor(arrTbRes[1].color)
    self.textGoldNum2:setString("/"..tostring(arrTbRes[1].resNum))
    self.gold_icon_enough:setTexture (arrTbRes[1].enoughIcon)

    self.woodIcon:setTexture(arrTbRes[2].resIcon)
    self.textWoodNum1:setString(tostring(Scientific(arrTbRes[2].resNowNum)))
    self.textWoodNum1:setTextColor(arrTbRes[2].color)
    self.textWoodNum2:setString("/"..tostring(arrTbRes[2].resNum))
    self.wood_icon_enough:setTexture (arrTbRes[2].enoughIcon)


    self.btn_get_more_gold:setVisible (not arrTbRes[1].isEnough)
    self.btn_get_more_wood:setVisible (not arrTbRes[2].isEnough)
    self.btn_get_more_stone:setVisible (not stoneRes.isEnough)

    self.btn_get_more_gold.shopKey = arrTbRes[1].shopKey
    self.btn_get_more_gold.needNums = arrTbRes[1].resNum
    self.btn_get_more_wood.shopKey = arrTbRes[2].shopKey
    self.btn_get_more_wood.needNums = arrTbRes[2].resNum
    
    self.tipStr = tipStr
end