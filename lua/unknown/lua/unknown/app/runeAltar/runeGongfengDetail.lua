runeGongfengDetail = class("runeGongfengDetail",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeGongfengDetail:create(...)
    local layer = runeGongfengDetail.new(...)
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

function runeGongfengDetail:ctor()
end

function runeGongfengDetail:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
    if self.okBtn then
        guideHelper.nextStepByOpt(false,self.okBtn)
    end
end

function runeGongfengDetail:onEnterTransitionDidFinish()
end

function runeGongfengDetail:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeGongfengDetail:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_STRENGTH) then -- 强化符文
        local runeInfo = user.runeBackpack[msg.c.id]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.runeInfo.plan]
            runeInfo = nowEquip[self.runeInfo.index]
        end
        self:setSelectRuneInfo(runeInfo)
        disWaitLayer()
    end
end

function runeGongfengDetail:init()
    print("runeGongfengDetail init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    self.baseTxt = me.assignWidget(self, "baseTxt")
    self.appendTxt = me.assignWidget(self, "appendTxt")

    -- 符文icon
	self.srcRuneIcon = runeItem:create(me.assignWidget(self, "srcRuneIcon"), 1) 
    self.targetRuneIcon = runeItem:create(me.assignWidget(self, "targetRuneIcon"), 1) 


    self.srcPropertyList = me.assignWidget(self, "srcPropertyList")
    self.srcPropertyList:setScrollBarEnabled (false)

    self.targetPropertyList = me.assignWidget(self, "targetPropertyList")
    self.targetPropertyList:setScrollBarEnabled (false)


    me.registGuiClickEventByName(self, "cancelBtn", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    self.okBtn = me.registGuiClickEventByName(self, "okBtn", handler(self, self.startGongfeng))

    return true
end
function runeGongfengDetail:startGongfeng()
    if self.runeSelecCallback then
        self.runeSelecCallback(self.targetRuneInfo)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 11 then
            guideHelper.setGuideIndex(guideHelper.guideIndex+1)
            guideHelper.nextTaskStep()   
    end
    self:removeFromParentAndCleanup(true)
end
function runeGongfengDetail:setData(srcData, targetData)
	self.srcRuneInfo = srcData
    self.targetRuneInfo = targetData
	self:updateStrenghView()
end

function runeGongfengDetail:setGotoRunePackCallback(goRunePackCallback)
    self.goRunePackCallback = goRunePackCallback
end


function runeGongfengDetail:updateStrenghView ()
	local targetRuneBaseCfg = cfg[CfgType.RUNE_DATA][self.targetRuneInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.targetRuneInfo.glv]
    self.targetRuneIcon:setData(self.targetRuneInfo)

    local targetBaseAttr = {}
	local strPropKV = runeStrengthCfg.property~=nil and string.split(runeStrengthCfg.property, ",") or {}
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        targetBaseAttr[attKey]=attValue
    end
    
    local targetAddAttr = getRuneStrengthAttr(runeStrengthCfg, self.targetRuneInfo.apt)
    table.sort(targetAddAttr, function(a, b) return a.k < b.k end)

    local srcRuneBaseCfg=nil
    if self.srcRuneInfo==nil then
        self.srcRuneIcon:setVisible(false)
        self.srcPropertyList:removeAllItems()

        for k, v in pairs (targetBaseAttr) do
            local attStr = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (v*100).."%"
            local baseTxt = self.baseTxt:clone():setVisible(true)
            baseTxt:setString(attStr)
            self.targetPropertyList:pushBackCustomItem(baseTxt)
        end
        for k1, v1 in pairs (targetAddAttr) do
            local attStr = cfg[CfgType.LORD_INFO][v1.k].name .. ":+" .. v1.v..v1.unit
            local baseTxt = self.appendTxt:clone():setVisible(true)
            baseTxt:setString(attStr)
            self.targetPropertyList:pushBackCustomItem(baseTxt)
        end
        return
    else
        self.srcRuneIcon:setVisible(true)
        srcRuneBaseCfg = cfg[CfgType.RUNE_DATA][self.srcRuneInfo.cfgId]
        self.srcRuneIcon:setData(self.srcRuneInfo)
    end
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.srcRuneInfo.glv]
    local srcBaseAttr = {}
	local strPropKV = runeStrengthCfg.property~=nil and string.split(runeStrengthCfg.property, ",") or {}
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        srcBaseAttr[attKey]=attValue
    end

    local srcAddAttr = getRuneStrengthAttr(runeStrengthCfg, self.srcRuneInfo.apt)
    table.sort(srcAddAttr, function(a, b) return a.k < b.k end)

    self.srcPropertyList:removeAllItems()
    self.targetPropertyList:removeAllItems()
    


    local baseTxt = self.baseTxt:clone():setVisible(true)
    self.srcPropertyList:pushBackCustomItem(baseTxt)
    local baseTxt = self.baseTxt:clone():setVisible(true)
    self.targetPropertyList:pushBackCustomItem(baseTxt)

    --基础属性填充
    local baseAttrLeftNums = 0
    local baseAttrRightNums = 0
    for k, v in pairs (srcBaseAttr) do
        local attStr = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (v*100).."%"
        local baseTxt = self.baseTxt:clone():setVisible(true)
        baseTxt:setString(attStr)
        self.srcPropertyList:pushBackCustomItem(baseTxt)

        if targetBaseAttr[k] then
            local attStr1 = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (targetBaseAttr[k]*100).."%"
            local baseTxt1 = self.baseTxt:clone():setVisible(true)
            baseTxt1:setString(attStr1)
            self.targetPropertyList:pushBackCustomItem(baseTxt1)

            baseAttrRightNums=baseAttrRightNums+1
            if targetBaseAttr[k]*100>v*100 then        --右边大于左边  显示红色
                --baseTxt1:setTextColor(cc.c3b(255, 0, 0))
            end

            targetBaseAttr[k]=nil
        else
            --baseTxt:setTextColor(cc.c3b(255, 0, 0))   --右边没有文字 显示红色
        end
        baseAttrLeftNums = baseAttrLeftNums+1
    end
    for k, v in pairs (targetBaseAttr) do         --右边 显示剩余属性
        local attStr = cfg[CfgType.LORD_INFO][k].name .. ":+" .. (v*100).."%"
        local baseTxt = self.baseTxt:clone():setVisible(true)
        --baseTxt:setTextColor(cc.c3b(255, 0, 0))
        baseTxt:setString(attStr)
        self.targetPropertyList:pushBackCustomItem(baseTxt)
        baseAttrRightNums=baseAttrRightNums+1
    end
    ---填充缺失的属性
    local list = nil
    local diff = 0
    if baseAttrLeftNums<baseAttrRightNums then
        list=self.srcPropertyList
        diff = baseAttrRightNums-baseAttrLeftNums
    else
        list=self.targetPropertyList
        diff = baseAttrLeftNums-baseAttrRightNums
    end
    for i=1, diff do
        local baseTxt = self.baseTxt:clone():setVisible(true)
        baseTxt:setString("")
        list:pushBackCustomItem(baseTxt)
    end

    local baseTxt = self.appendTxt:clone():setVisible(true)
    self.srcPropertyList:pushBackCustomItem(baseTxt)
    local baseTxt = self.appendTxt:clone():setVisible(true)
    self.targetPropertyList:pushBackCustomItem(baseTxt)
    --追加属性填充
    local appendAttrLeftNums = 0
    local appendAttrRightNums = 0
    for k1, v1 in ipairs (srcAddAttr) do
        local attStr = cfg[CfgType.LORD_INFO][v1.k].name .. ":+" .. v1.v..v1.unit
        local baseTxt = self.appendTxt:clone():setVisible(true)
        baseTxt:setString(attStr)
        self.srcPropertyList:pushBackCustomItem(baseTxt)

        appendAttrLeftNums = appendAttrLeftNums+1
    end
    for k1, v1 in ipairs (targetAddAttr) do         --右边 显示剩余属性
        local attStr = cfg[CfgType.LORD_INFO][v1.k].name .. ":+" .. v1.v..v1.unit
        local baseTxt = self.appendTxt:clone():setVisible(true)
        --baseTxt:setTextColor(cc.c3b(255, 0, 0))
        baseTxt:setString(attStr)
        self.targetPropertyList:pushBackCustomItem(baseTxt)
        appendAttrRightNums=appendAttrRightNums+1
    end
    ---填充缺失的属性
    local list = nil
    local diff = 0
    if appendAttrLeftNums<appendAttrRightNums then
        list=self.srcPropertyList
        diff = appendAttrRightNums-appendAttrLeftNums
    else
        list=self.targetPropertyList
        diff = appendAttrLeftNums-appendAttrRightNums
    end
    for i=1, diff do
        local baseTxt = self.appendTxt:clone():setVisible(true)
        baseTxt:setString("")
        list:pushBackCustomItem(baseTxt)
    end
end

function runeGongfengDetail:registerSelecCallback(selecCallback)
    self.runeSelecCallback = selecCallback
end