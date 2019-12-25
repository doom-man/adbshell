runeXL = class("runeXL",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeXL:create(...)
    local layer = runeXL.new(...)
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

local COLOR_ORIGINAL = cc.c3b(103, 255, 2)
local COLOR_LOCK     = cc.c3b(174, 174, 174)
local COLOR_OTHER   = cc.c3b(232, 188, 70)

local LOCK_COST_YB = {[1]=50, [2]=100, [3]=200, [4]=500}
local STONE_NUMS = 1
local LOCK_ITEM_NUMS = 3

function runeXL:ctor()
end

function runeXL:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeXL:onEnterTransitionDidFinish()
end

function runeXL:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeXL:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.MSG_RUNE_XL) then -- 洗炼圣物
        disWaitLayer()
        local runeInfo = user.runeBackpack[msg.c.id]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.runeInfo.plan]
            runeInfo = nowEquip[self.runeInfo.index]
        end
        self.runeInfo=runeInfo

        --[[
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_STRENGTH)
        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2+50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
        ]]

        self:updateXLResult(msg.c.rst)
        self:XLResultPrompt(msg.c)
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RUNE_UPDATE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then -- 更新圣物
        local runeInfo = user.runeBackpack[self.runeInfo.id]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.runeInfo.plan]
            runeInfo = nowEquip[self.runeInfo.index]
        end
        self.runeInfo=runeInfo
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_XL_EXPECT) then -- 洗炼替换圣物
        self:replaceAttr()
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_XL_EXPECT_RESULT) then -- 圣物洗炼结果
        self:getXLResult(msg.c)
    elseif checkMsg(msg.t, MsgCode.ROLE_PAYGEM_UPDATE) then
        self:updateCost()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then -- 背包数量改变
        self:updateCost()
    end
end

function runeXL:init()
    print("runeXL init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        if #self.xlResultList>0 then
            me.showMessageDialog("确定放弃所有洗炼结果吗？\n\n(取消并点击洗炼结果上方替换按钮可保存洗炼结果)", handler(self, self.giveUpReplace))
        else
            self:giveUpReplace("ok")
        end
    end )

    self.srcAttrNodeList = {}
    self.lockNums = 0
    self.srcAttrNode = me.assignWidget(self, "srcAttrNode")
    self.topNode = me.assignWidget(self, "topNode")
    self.xlResultNode = me.assignWidget(self, "xlResultNode")
    self.xlResultList={}

    self.listView = me.assignWidget(self, "ListView")
    self.listView:setSwallowTouches(false)
    self.listView:setScrollBarWidth(8)
    self.listView:setScrollBarPositionFromCornerForHorizontal(cc.p(7, 2))
    self.listView:removeAllItems()
    local arrow = me.assignWidget(self, "arrow")
    arrow:setVisible(false)

    self.needYb = me.assignWidget(self, "needYb")
    self.haveYb = me.assignWidget(self, "haveYb")
    self.ybAdd = me.assignWidget(self, "ybAdd")
    self.needXLStone = me.assignWidget(self, "needXLStone")
    self.haveXLStone = me.assignWidget(self, "haveXLStone")
    self.xlAdd = me.assignWidget(self, "xlAdd")
    me.registGuiClickEvent(self.ybAdd, function(node)
        toRechageShop()
    end)

    me.registGuiClickEvent(self.xlAdd, function(node)
        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
        me.runningScene():addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView,"bg")
        getWayView:setData(80)
    end)
    self:updateCost()
    

    local descBtn = me.assignWidget(self,"descBtn")
    self.mDescBool = false
    me.registGuiClickEvent(descBtn,function (node)     
         if self.mDescBool then
            me.assignWidget(self, "descNode"):setVisible(false)     
            self.mDescBool = false
         else
            me.assignWidget(self, "descNode"):setVisible(true)   
            me.assignWidget(self, "descTxt"):setString("可以锁定"..LOCK_ITEM_NUMS.."条属性")
            self.mDescBool = true
         end         
                             
   end)
    local function onTouchBegan()
        if self.mDescBool then
            me.assignWidget(self, "descNode"):setVisible(false)     
            self.mDescBool = false
        end
    end
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, me.assignWidget(self,"bg"))


    me.registGuiClickEventByName(self, "expectNode", function(node)
        local xlExpectView = runeXLExpectAttr:create("rune/runeXLExpectAttr.csb")
        me.runningScene():addChild(xlExpectView, me.MAXZORDER)
        xlExpectView:setXLRuneInfo(self.runeInfo, self.expectList)
        xlExpectView:setCloseCallback(handler(self, self.updateExpectList))
        me.showLayer(xlExpectView,"bg")
    end )
    
    me.registGuiClickEventByName(self, "btn_xl", function(node)
        self.batchXL=0
        self:requestXL()
    end )
    me.registGuiClickEventByName(self, "btn_xl_more", function(node)
        self.batchXL=1
        self:requestXL()
    end )

    self.expectList={}
    for i=1, 3 do
        me.assignWidget(self, "expectTxt"..i):setVisible(false) 
    end

    return true
    
end

---
-- 关闭界面时 确定放弃洗炼结果
--
function runeXL:giveUpReplace(str)
    if str=="ok" then
        if #self.xlResultList>0 then
            NetMan:send(_MSG.Rune_xl_expect(self.runeInfo.id, -1))
        end

        if self.closeCallback~=nil then
            self.closeCallback()
        end
        self:removeFromParentAndCleanup(true)
    end
end

---
-- 改变锁定状态时是否确定放弃洗炼结果
--
function runeXL:giveupRequest(str)
    if str=="ok" then
        NetMan:send(_MSG.Rune_xl_expect(self.runeInfo.id, -1))

        self.listView:removeAllItems()
        local arrow = me.assignWidget(self, "arrow")
        arrow:setVisible(false)
        self.xlResultList={}

        --继续操作锁定操作
        local node = self.srcAttrNodeList[self.nodeIndex].node
        self:clickAttrLock(me.assignWidget(node,"lockBtn"))
        self.nodeIndex = 0
    else
        self.nodeIndex = 0
    end
end

function runeXL:requestXL()
    if self.conditionEnough==1 then
        askToRechage(1)
        return
    elseif self.conditionEnough==2 then
        showTips("洗炼石不足")
        return
    end

    if #self.expectList==0 then
        if self.batchXL==0 then
            me.showMessageDialog("设置期待属性后，洗炼结果中如有期待属性，将有明显提示方便查看。\n\n尚未设置期待属性，是否仍要继续？", handler(self, self.doSubmit))
        else
            me.showMessageDialog(" 设置期待属性后，当洗炼时出现期待属性时将自动停止洗炼。\n\n尚未设置期待属性，是否仍要继续？", handler(self, self.doSubmit))
        end
        return
    end
    self:doSubmit("ok")
end

function runeXL:doSubmit(str)
    if str=="ok" then
        local want=nil
        if #self.expectList>0 then
            want = table.concat(self.expectList, ":")
        end
        local lockIds = nil
        local lockTbl = {}
        for i, v in ipairs(self.srcAttrNodeList) do
            if v.lockState==true then
                table.insert(lockTbl, i)
            end
        end
        if #lockTbl>0 then
            lockIds = table.concat(lockTbl, ":")
        end

        NetMan:send(_MSG.Rune_xl(self.runeInfo.id, self.batchXL, want, lockIds))
        showWaitLayer()
    else
        local xlExpectView = runeXLExpectAttr:create("rune/runeXLExpectAttr.csb")
        me.runningScene():addChild(xlExpectView, me.MAXZORDER)
        xlExpectView:setXLRuneInfo(self.runeInfo, self.expectList)
        xlExpectView:setCloseCallback(handler(self, self.updateExpectList))
        me.showLayer(xlExpectView,"bg")
    end
end

----
-- 替换属性请求
--
function runeXL:replaceAttrRequest(node)
    local index=node.index
    me.showMessageDialog("确定要替换此结果吗？", function(str)
        if str=="ok" then
            NetMan:send(_MSG.Rune_xl_expect(self.runeInfo.id, index))
            showWaitLayer()
        end
    end)
end

----
-- 替换属性请求
--
function runeXL:replaceAttr()
    self.listView:removeAllItems()
    local arrow = me.assignWidget(self, "arrow")
    arrow:setVisible(false)

    self.xlResultList={}


    self:updateView()
    disWaitLayer()
end

----
-- 获取洗炼结果
--
function runeXL:getXLResult(data)
    for _, v in ipairs(data.list) do
        LOCK_COST_YB[v.nm]=v.nd
    end

    LOCK_ITEM_NUMS = table.getn(data.list)
    STONE_NUMS = data.need

    self:updateExpectList(data.want)

    local lockList = data.locapt
    self.lockIndex={}
    for _, index in ipairs(lockList) do
        self.lockIndex[index]=true
    end

    self:updateView()
    self:updateXLResult(data.rst)

    self:updateCost()

end

function runeXL:setXLRuneInfo(runeInfo)
	self.runeInfo = runeInfo
    NetMan:send(_MSG.Rune_xl_expect_result(self.runeInfo.id))
end


----
-- 洗炼后的结果提示
--
function runeXL:XLResultPrompt(data)
    if data.batch==0 then return end
    local gemStr=''
    if data.paygem>0 then
        gemStr="、元宝x"..data.paygem
    end

    if data.type==0 then
        me.DelayRun(function()
            self.listView:scrollToPercentHorizontal(0, 0, true)
        end, 0.5)
        me.showMessageDialog("洗炼结束\n\n本次洗炼"..data.times.."次，消耗洗炼石x"..(STONE_NUMS*data.times)..gemStr, nil, 1)
    elseif data.type==1 then
        me.DelayRun(function()
            self.listView:scrollToPercentHorizontal(0, 0, true)
        end, 0.5)
        me.showMessageDialog("元宝不足，自动洗炼中止\n\n本次批量洗炼共洗炼"..data.times.."次\n\n消耗洗炼石x"..(STONE_NUMS*data.times)..gemStr, nil, 1)
    elseif data.type==2 then
        me.DelayRun(function()
            self.listView:scrollToPercentHorizontal(0, 0, true)
        end, 0.5)
        me.showMessageDialog("洗炼石不足，自动洗炼中止\n\n本次批量洗炼共洗炼"..data.times.."次\n\n消耗洗炼石x"..(STONE_NUMS*data.times)..gemStr, nil, 1)
    elseif data.type==3 then
        me.DelayRun(function()
            self.listView:scrollToPercentHorizontal(100, 0.3, true)
        end, 0.5)
        me.showMessageDialog("出现期待属性，自动洗炼中止\n\n本次批量洗炼共洗炼"..data.times.."次\n\n消耗洗炼石x"..(STONE_NUMS*data.times)..gemStr, nil, 1)
    end
end

----
-- 更新洗炼后的结果
--
function runeXL:updateXLResult(list)
    self.listView:removeAllItems()

    local arrow = me.assignWidget(self, "arrow")
    arrow:stopAllActions()
    if #list>3 then
        arrow:setVisible(true)
        me.clickAni(arrow)
    else
        arrow:setVisible(false)
    end

    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
    local statusColor = {}
    for _, id in ipairs(self.expectList) do --期待属性
        statusColor[id]=1
    end

    local statusLock = {}
    for i, v in ipairs(self.srcAttrNodeList) do --鑜定属性
        if v.lockState==true then
            statusLock[i]=true
        end
    end

    self.xlResultList = list
    for i, v1 in ipairs(list) do
        local rsNode = self.xlResultNode:clone():setVisible(true)
        self.listView:pushBackCustomItem(rsNode)

        local aptPro = getRuneStrengthAttr(runeStrengthCfg, v1)
        local count=0
        for k, v in ipairs(aptPro) do
            local attStr = cfg[CfgType.LORD_INFO][v.k].name .. ":+" .. v.v..v.unit
            local attrNode = me.assignWidget(rsNode, "attr"..k)
            local txt = me.assignWidget(attrNode,"txt")
            txt:setString(attStr)
            if statusLock[k]==true then
                txt:setTextColor(COLOR_LOCK)
            elseif statusColor[v.id]==1 then
                txt:setTextColor(COLOR_ORIGINAL)
            else
                txt:setTextColor(COLOR_OTHER)
            end
            local replaceBtn = me.assignWidget(rsNode, "replaceBtn")
            me.registGuiClickEvent(replaceBtn, handler(self, self.replaceAttrRequest))
            replaceBtn.index=i
            attrNode:setVisible(true)
            count=count+1
        end
        for j=count+1, 7 do
            local attrNode = me.assignWidget(rsNode, "attr"..j)
            attrNode:setVisible(false)
        end
    end
end


----
-- 更新期待列表
--
function runeXL:updateExpectList(list)
    for i=1, 3 do
        me.assignWidget(self, "expectTxt"..i):setVisible(false) 
    end

    self.expectList = list
    local runePropertyCfg = cfg[CfgType.RUNE_PROPERTY]
    for i, id in ipairs(list) do
        me.assignWidget(self, "expectTxt"..i):setVisible(true) 
        me.assignWidget(self, "expectTxt"..i):setString(runePropertyCfg[id].name)
    end
end

----
-- 更新花费
--
function runeXL:updateCost()
    self.conditionEnough=0
    self.haveYb:setString(user.paygem)
    if self.lockNums>0 then
        self.needYb:setString("/"..LOCK_COST_YB[self.lockNums])
        self.needYb:setPositionX(self.haveYb:getPositionX()+self.haveYb:getContentSize().width)
        if LOCK_COST_YB[self.lockNums]>user.paygem then
            --self.ybAdd:setVisible(true)
            self.haveYb:setTextColor(COLOR_RED)
            self.conditionEnough=1
        end
    else
        self.needYb:setString("/0")
        self.needYb:setPositionX(self.haveYb:getPositionX()+self.haveYb:getContentSize().width)
        self.ybAdd:setVisible(false)
        self.haveYb:setTextColor(COLOR_ORIGINAL)
    end

    local itemObj = getBackpackDatasByCfgId(tonumber(80))
    self.needXLStone:setString("/"..STONE_NUMS)
    self.haveXLStone:setString(tostring(itemObj.nums))
    self.needXLStone:setPositionX(self.haveXLStone:getPositionX()+self.haveXLStone:getContentSize().width)
    if itemObj.nums<STONE_NUMS then
        self.xlAdd:setVisible(true)
        self.haveXLStone:setTextColor(COLOR_RED)
        self.conditionEnough=2
    else
        self.xlAdd:setVisible(false)
        self.haveXLStone:setTextColor(COLOR_ORIGINAL)
    end
end

----
-- 更新按钮状态
--
function runeXL:updateLockBtnState()
    self.lockIndex={}
    local lockNums=0
    for i, v in ipairs(self.srcAttrNodeList) do
        if v.lockState==false then
            if self.lockNums>=LOCK_ITEM_NUMS then
                me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL10.png")
            else
                me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL9.png")
            end
        else
            me.assignWidget(v.node,"lockBtn"):loadTexture("runeXL9.png")
            lockNums=lockNums+1
            self.lockIndex[i]=true
        end
    end
    self.lockNums = lockNums
end

----
-- 点击属性鑜定
--
function runeXL:clickAttrLock(node)
    local nodeData=self.srcAttrNodeList[node.index]
    local appendNode = nodeData.node

    if nodeData.lockState==false then
        if self.lockNums>=LOCK_ITEM_NUMS then
            showTips("锁定数量已达到上限")
            return
        end
        if #self.xlResultList>0 then
            self.nodeIndex = node.index
            me.showMessageDialog("改变锁定属性将自动放弃本次洗炼结果，是否继续？", handler(self, self.giveupRequest))
            return
        end
        nodeData.lockState=true
        self.lockNums =self.lockNums+1
        me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_LOCK)
        me.assignWidget(appendNode,"lockIco"):setVisible(true)
    else
        if #self.xlResultList>0 then
            self.nodeIndex = node.index
            me.showMessageDialog("改变锁定属性将自动放弃本次洗炼结果，是否继续？", handler(self, self.giveupRequest))
            return
        end
        me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_ORIGINAL)
        me.assignWidget(appendNode,"lockIco"):setVisible(false)
        nodeData.lockState=false
        self.lockNums =self.lockNums-1
    end

    self:updateLockBtnState()
    self:updateCost()
end
function runeXL:updateView()
    for _, v in ipairs(self.srcAttrNodeList) do
        v.node:removeFromParentAndCleanup(true)
    end
    self.srcAttrNodeList={}

    self.lockNums = 0

    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]
    local aptPro = getRuneStrengthAttr(runeStrengthCfg, self.runeInfo.apt)
    local count=0
    for k, v in ipairs(aptPro) do
        local attStr = cfg[CfgType.LORD_INFO][v.k].name .. ":+" .. v.v..v.unit
        local appendNode = self.srcAttrNode:clone():setVisible(true)
        me.assignWidget(appendNode,"attrName"):setString(attStr)
        local lockBtn = me.assignWidget(appendNode,"lockBtn")
        
        local lockState = false
        if self.lockIndex[k]==true then
            me.assignWidget(appendNode,"lockIco"):setVisible(true)
            me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_LOCK)
            self.lockNums =self.lockNums+1
            lockState=true
        else
            me.assignWidget(appendNode,"lockIco"):setVisible(false)
            me.assignWidget(appendNode,"attrName"):setTextColor(COLOR_ORIGINAL)
        end

        me.registGuiClickEvent(lockBtn, handler(self, self.clickAttrLock))
        appendNode:setPosition(4, 336-count*52)
        lockBtn.index=count+1
        me.assignWidget(self, "Image_27"):addChild(appendNode)
        --self.topNode:addChild(appendNode)
        table.insert(self.srcAttrNodeList, {node=appendNode, key=k, lockState=lockState})
        count=count+1
    end

    self:updateLockBtnState()
end


function runeXL:setGotoRunePackCallback(goRunePackCallback)
    self.goRunePackCallback = goRunePackCallback
end
function runeXL:setCloseCallback(closeCallback)
    self.closeCallback = closeCallback
end


