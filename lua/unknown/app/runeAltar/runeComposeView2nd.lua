local runeHecengItem = class("runeHecengItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHecengItem:create(...)
    local layer = runeHecengItem.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function runeHecengItem:ctor()

end

function runeHecengItem:onEnter()

end

function runeHecengItem:onExit()

end

function runeHecengItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.nameTxt = me.assignWidget(self, "nameTxt")
    self.lvTxt = me.assignWidget(self, "lvTxt")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.typeIco = me.assignWidget(self, "typeIco")
    self.lvBox:setVisible(false)

    self.lvBox = me.assignWidget(self, "lvBox")
    self.typeBox = me.assignWidget(self, "typeBox")

    return true
end

function runeHecengItem:setData(data)
    self.data=data
    self.icon:loadTexture(getRuneIcon(self.data.icon), me.plistType)
    self.box:loadTexture("levelbox"..self.data.level..".png", me.plistType)
    self.nameTxt:setString(self.data.name)
    self.typeIco:loadTexture("rune_type_"..self.data.type..".png",me.plistType)
    self.lvBox:loadTexture("levelbox"..self.data.level.."_c1.png", me.plistType)
    self.typeBox:loadTexture("levelbox"..self.data.level.."_c2.png", me.plistType)
end

runeComposeView2nd = class("runeComposeView2nd", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
runeComposeView2nd.__index = runeComposeView2nd
function runeComposeView2nd:create(...)
    local layer = runeComposeView2nd.new(...)

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
        else
        print("---------------------->>>>")
    end
    return nil
end

function runeComposeView2nd:ctor()
    self.view_name = "runeComposeView2nd"
end

function runeComposeView2nd:setData(data)
    self.data = data

    self.runeIcon:setData(data)

    local strPropKV = string.split(data.basePro, ",")
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        local txt = self.baseAttrTxt:clone():setVisible(true)
        txt:setString(cfg[CfgType.LORD_INFO][attKey].name)
        me.assignWidget(txt, "valueTxt"):setString("+" .. (attValue*100).."%")
        self.baseAttrList:pushBackCustomItem(txt)
    end

    

    --材料数量
    self.numsTxt1:setTextColor(cc.c3b(121,255,44))
    if self.data.needRunNum==0 then
        self.numsTxt1:setString("-")
        self.numsTxt2:setString("/-")

        self.numsTxt1:setVisible(false)
        me.assignWidget(self, "autoPlayBtn"):setVisible(false)
        self.ctxt:setVisible(false)

        for i=1, 6 do
            local eqEmpey = self.equipEmpty[i]
            local eq = self.equip[i]
            eq:setVisible(false)
            eqEmpey:setVisible(true)
            me.assignWidget(eqEmpey, "jia"):setVisible(false)
            me.assignWidget(eqEmpey, "lock"):setVisible(true)
        end

        self:requestProbability() --请求概率
    else
        self.numsTxt1:setVisible(true)
        me.assignWidget(self, "autoPlayBtn"):setVisible(true)
        self.ctxt:setVisible(true)

        self.needRunLevel = self.data.needRunLevel:split(",")
        local count=0
        for key, var in pairs(self.needRunLevel) do
            local needLevelCfgId = var
            for k, v in pairs (user.runeBackpack) do
                if tonumber(v.cfgId) == tonumber(needLevelCfgId) then
                    count=count+1
                end
            end
        end
        self.numsTxt1:setString(count)
        self.numsTxt2:setString("/"..self.data.needRunNum)
        self.numsTxt2:setPositionX(self.numsTxt1:getContentSize().width+10)
        if count<self.data.needRunNum then
            self.numsTxt1:setTextColor(cc.c3b(255,0,0))
        end
        for i=1, self.data.needRunNum do
            local eq = self.equip[i]
            eq:setVisible(false)
            local eqEmpey = self.equipEmpty[i]
            eqEmpey:setVisible(true)
            me.assignWidget(eqEmpey, "jia"):setVisible(true)
            me.assignWidget(eqEmpey, "lock"):setVisible(false)

            me.assignWidget(eqEmpey, "jia"):stopAllActions()
            if count>0 then
                me.clickAni(me.assignWidget(eqEmpey, "jia"))
            end
        end
        for i=self.data.needRunNum+1, 6 do
            local eqEmpey = self.equipEmpty[i]
            local eq = self.equip[i]
            eq:setVisible(false)
            eqEmpey:setVisible(true)
            me.assignWidget(eqEmpey, "jia"):setVisible(false)
            me.assignWidget(eqEmpey, "lock"):setVisible(true)
        end
    end

    self.table_need_item = self:analysisNeedItem()
    self:setCailiao()
    self:updateCailiaoNum()
end

function runeComposeView2nd:reCaclInPackageNums()
    --材料数量
    self.numsTxt1:setTextColor(cc.c3b(121,255,44))
    if self.data.needRunNum==0 then
        self.numsTxt1:setString("-")
        self.numsTxt2:setString("/-")

        self.numsTxt1:setVisible(false)
        me.assignWidget(self, "autoPlayBtn"):setVisible(false)
        self.ctxt:setVisible(false)
    else
        self.numsTxt1:setVisible(true)
        me.assignWidget(self, "autoPlayBtn"):setVisible(true)
        self.ctxt:setVisible(true)

        self.needRunLevel = self.data.needRunLevel:split(",")
        local count=0
        for key, var in pairs(self.needRunLevel) do
            local needLevelCfgId = var
            for k, v in pairs (user.runeBackpack) do
                if tonumber(v.cfgId) == tonumber(needLevelCfgId) then
                    count=count+1
                end
            end
        end
        self.numsTxt1:setString(count)
        self.numsTxt2:setString("/"..self.data.needRunNum)
        self.numsTxt2:setPositionX(self.numsTxt1:getContentSize().width+10)
        if count<self.data.needRunNum then
            self.numsTxt1:setTextColor(cc.c3b(255,0,0))
        end
    end
end

function runeComposeView2nd:analysisNeedItem()
--"2030:62,2031:63,2032:67,2033:69"
    local table_needItem = {}
    local temp1 = self.data.needItem:split(",")
    for key, var in pairs(temp1) do
        local temp2 = var:split(":")
        local id = tonumber(temp2[1])
        local num = tonumber(temp2[2])
        local temp = {id = id, num = num}
        table.insert(table_needItem, temp)
    end
    return table_needItem
end

function runeComposeView2nd:close()
    --mMailCross = self.CurrentSever
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
    --guideHelper.nextStepByOpt()
end

--点击选择圣器
function runeComposeView2nd:clickRune(node)
    local index = node:getTag()
    if index>self.data.needRunNum then return end  --判断是否锁定

    self.currentRuneIndex = index

    local function isIndex(hashTable, value)
        for k, v in pairs (hashTable) do
            if v.id == value then return true end
        end
        return false
    end
    local arrRune = {}
    for key, var in pairs(self.needRunLevel) do
        local needLevelCfgId = var
        for k, v in pairs (user.runeBackpack) do
            if tonumber(v.cfgId) == tonumber(needLevelCfgId) and not isIndex (self.runeAddedList, v.id) then
                table.insert (arrRune, v)
            end
        end
    end
    
    if #arrRune <= 0 then
        -- 提示背包无当前选中类型的符文
        showTips("背包里没有所需的上阶圣物")
        print ("背包无当前选中类型的圣物")
    else
        local function registerSelecCallback (data)
            -- 这个是装备卸载符文!!
            -- NetMan:send(_MSG.Rune_equip(runeType, runeId))
            -- showWaitLayer ()
            self:addOneRune(data)
        end
        local selectView = runeSelectView:create("rune/runeSelectView.csb")
        
        me.runningScene() :addChild(selectView, me.MAXZORDER)
        
        me.showLayer(selectView,"bg")
        selectView:setRuneBagData(arrRune, "compose")
        selectView:registerSelecCallback(registerSelecCallback)
    end

end

--
--  一健放入
--
function runeComposeView2nd:autoPlay()
    if self.needRunLevel==nil then
        showTips("不需要上阶圣物")
        return
    end
    local function isIndex(hashTable, value)
        for k, v in pairs (hashTable) do
            if v.id == value then return true end
        end
        return false
    end
    local arrRune = {}
    for key, var in pairs(self.needRunLevel) do
        local needLevelCfgId = var
        for k, v in pairs (user.runeBackpack) do
            if tonumber(v.cfgId) == tonumber(needLevelCfgId) and not isIndex (self.runeAddedList, v.id) then
                table.insert (arrRune, v)
            end
        end
    end

    table.sort (arrRune, function (a, b)
        local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
        local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level
        if a.lock==b.lock then
            if a.star == b.star then
                return strengthLvA < strengthLvB
            else
                return a.star > b.star
            end
        elseif a.lock==false then
            return true
        else
            return false
        end
    end)
    if #arrRune==0 then
        showTips("背包里没有所需的上阶圣物")
        return
    end

    local hasLock=false
    local hasRune=false
    local j=1
    local emptyNums=0
    local fillNums=0
    for i=1, self.data.needRunNum do
        if self.runeAddedList[i]==nil then
            emptyNums=emptyNums+1
            if arrRune[j]==nil then
                break
            elseif arrRune[j].lock==true then
                hasLock=true
                break
            else
                self.runeAddedList[i]=arrRune[j]
                hasRune=true
                fillNums=fillNums+1
                j=j+1
            end
        end
    end
    if hasLock==true and hasRune==false then
        showTips("背包里有被锁定的上阶圣物")
    elseif emptyNums>0 and emptyNums~=fillNums then
        showTips("背包里上阶圣物不足")
    elseif emptyNums==0 then  --没有空位置了，不用一健填充
        return 
    end
    self:updateView()
    self:updateAppendAttr()

    if emptyNums>0 and emptyNums==fillNums then  --填充满
        self:requestProbability()
    end
end

function runeComposeView2nd:init()
    print("runeComposeView2nd:init() ")
    me.doLayout(self, me.winSize)
    
    -- 符文icon
	self.runeIcon = runeHecengItem:create(me.assignWidget(self, "runeIcon"), 1) 

    self.baseAttrList = me.assignWidget(self, "baseAttrList")
    self.baseAttrTxt = me.assignWidget(self, "baseAttrTxt")
    self.numsTxt1 = me.assignWidget(self, "numsTxt1")
    self.numsTxt2 = me.assignWidget(self, "numsTxt2")
    self.ctxt = me.assignWidget(self, "ctxt")

    self.runeAddedList = {}  --已选中的圣物

    self.cailiaoList={}
    for i = 1, 4 do
        --材料图片
        local cailiaoItem = me.registGuiClickEventByName(self, "cailiaoItem"..i, function(node)
            self:showMtrInfoView(node)
        end )
        self.cailiaoList[i] = cailiaoItem
    end

    self.equipEmpty={}
    self.equip={}
    self.clickArea={}
    for i=1, 6 do
        local eqEmpey = me.assignWidget(self, "equip_empty_"..i)
        self.equipEmpty[i]=eqEmpey

        local eq = runeItem:create(me.assignWidget(self, "equip_"..i), 1) 
        self.equip[i]=eq

        local clickArea = me.assignWidget(self, "clickArea"..i)
        clickArea:setTag(i)
        self.clickArea[i]=clickArea
        me.registGuiClickEvent(clickArea, handler(self, self.clickRune))

        me.assignWidget(clickArea, "Image_cancel"):setVisible(false)
        me.assignWidget(clickArea, "Image_cancel"):setTag(i)
        me.registGuiClickEventByName(clickArea, "Image_cancel", function(node)
            self:cancelOneRune(node:getTag())
        end )
    end

    self.probabilityList={}
    for i=1, 7 do
        local probabilityTxt = me.assignWidget(self, "probabilityTxt"..i)
        probabilityTxt:setString('-')
        self.probabilityList[i]=probabilityTxt
    end

    --符文属性列表
    self.appendAttrList = me.assignWidget(self,"appendAttrList")
    self.appendAttrList:setScrollBarEnabled (false)

    self.appendAttrTxt = me.assignWidget(self,"appendAttrTxt")

    me.registGuiClickEventByName(self, "btn_help", function(sender)
        -- 帮助
        local str = cfg[CfgType.RUNE_INTRODUCE][2].content
        local wd = sender:convertToWorldSpace(cc.p(0, 0))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,ffffff>"..str.."&", wd)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end )

    self.closeBtn = me.registGuiClickEventByName(self, "Button_cancel", function(node)
        --self:removeMtrInfoView()
        self:close()
    end )

    me.registGuiClickEventByName(self, "Button_compose", function(node)
        
        local idList={}
        for _, v in pairs(self.runeAddedList) do
            table.insert(idList, v.id)
        end
        if #idList<self.data.needRunNum then
            showTips("所需上阶圣物数量不足")
            return
        end
        if self.IS_MTR_ENOUGH==false then
            showTips("材料不足")
            return
        end

        showWaitLayer()
        NetMan:send(_MSG.Rune_compound(self.data.id, idList))
    end )

    me.registGuiClickEventByName(self, "autoPlayBtn", handler(self, self.autoPlay))

    
    return true
end


function runeComposeView2nd:updateAppendAttr()
    self.appendAttrList:removeAllItems()

    local attInfo = {}
    for k, v in pairs (self.runeAddedList) do
        local extendRuneAttCfg = cfg[CfgType.RUNE_PROPERTY]
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][v.glv]
        local aptPro = getRuneStrengthAttr(runeStrengthCfg, v.apt)
        for k1, v1 in ipairs (aptPro) do
            local attKey = v1.k
            local attName = cfg[CfgType.LORD_INFO][attKey].name .. ": "
            local str = attName..v1.v..v1.unit
            table.insert(attInfo, str)
        end
    end

    dump(attInfo)
    local txtNode = nil
    for k, v in pairs (attInfo) do
        local point = cc.p(245, 24)
        print("tonumber(k) = "..tonumber(k))
        if tonumber(k) % 2 == 1 then
            txtNode = self.appendAttrTxt:clone():setVisible(true)
            txtNode:setString(v)
            me.assignWidget(txtNode, "appendAttrTxt1"):setString('')
            self.appendAttrList:pushBackCustomItem(txtNode)
        else
            me.assignWidget(txtNode, "appendAttrTxt1"):setString(v)
        end
    end
end

--更新界面显示
function runeComposeView2nd:updateView()
    for i=1, self.data.needRunNum do
        local eq = self.equip[i]
        local eqEmpey = self.equipEmpty[i]
        if self.runeAddedList[i]~=nil then
            eq:setVisible(true)
            eq:setData(self.runeAddedList[i])

            eqEmpey:setVisible(false)

            local clickArea = self.clickArea[i]
            me.assignWidget(clickArea, "Image_cancel"):setVisible(true)
        else
            eq:setVisible(false)
            eqEmpey:setVisible(true)

            local clickArea = self.clickArea[i]
            me.assignWidget(clickArea, "Image_cancel"):setVisible(false)
        end
    end
end

--设置材料图片
function runeComposeView2nd:setCailiao()
    local count = 1
    for key, var in pairs(self.table_need_item) do
        print("设置材料图片var.id = "..var.id)
        local cf = cfg[CfgType.ETC][tonumber(var.id)]
        self.cailiaoList[count]:loadTexture("fuwen_kuang_pingzhi_"..cf.quality..".png", me.plistType)
        me.assignWidget(self.cailiaoList[count], "cailiaoIcon"):loadTexture(getItemIcon(var.id), me.localType)
        self.cailiaoList[count].id = var.id
        count = count + 1
    end
end

--更新材料数量
function runeComposeView2nd:updateCailiaoNum()
    --dump(user.pkg)
    --print("更新材料数量")
    self.IS_MTR_ENOUGH = true--材料足够合成
    local count = 1
    for key, var in pairs(self.table_need_item) do
        --print("更新材料数量var.id = "..var.id)
        local needNum = var.num
        local userItem = self:getPkgItemById(var.id)
        local hasNum = 0
        if userItem ~= nil then
            --print("userItem.count")
            --dump(userItem)
            hasNum = userItem.count
        end
        me.assignWidget(self.cailiaoList[count], "cailiaoNums1"):setString(hasNum)
        me.assignWidget(self.cailiaoList[count], "cailiaoNums2"):setString("/"..needNum)
        if tonumber(hasNum) < tonumber(needNum) then
            me.assignWidget(self.cailiaoList[count], "cailiaoNums1"):setTextColor(cc.c3b(255,0, 0))
            self.IS_MTR_ENOUGH=false
        else
            me.assignWidget(self.cailiaoList[count], "cailiaoNums1"):setTextColor(cc.c3b(97,255, 6))
        end
        count = count + 1
    end
end

function runeComposeView2nd:getPkgItemById(id)
    for key, var in pairs(user.materBackpack) do
        --print("var.defid = "..var.defid)
        if tonumber(var.defid) == tonumber(id) then
            return var
        end
    end
    return nil
end

function runeComposeView2nd:showMtrInfoView(node)
    ----self:removeMtrInfoView()
    --local id = node.id
    self.mtrInfoView = runeGetWayView:create("rune/runeGetWayView.csb")
    -- self.selectView:setParentView(self)

    me.runningScene():addChild(self.mtrInfoView, me.MAXZORDER)
    
--    self.mtrInfoView:setPosition(cc.p(- 90, 100))
    me.showLayer(self.mtrInfoView, "bg")
    self.mtrInfoView:setData(node.id)
--    self.mtrInfoView:setParent(self)
--    --print("id = "..id)
--    local cfg_data = cfg[CfgType.ETC]
--    local data = {}
--    for key, var in pairs(cfg_data) do
--        if tonumber(var.id) == tonumber(id) then
--            data = var
--            break
--        end
--    end
--    self.mtrInfoView:setData(data)
--    local point = node:convertToWorldSpace(cc.p(215, 0))
--    if point.x > me.winSize.width then
--        local dif = point.x - me.winSize.width
--        print(dif)
--        local x = - 90 - dif
--        self.mtrInfoView:setPosition(cc.p(x, 100))
--    end

end

function runeComposeView2nd:removeMtrInfoView()
    if self.mtrInfoView ~= nil then
        self.mtrInfoView:removeFromParent()
        self.mtrInfoView = nil
    end
end


function runeComposeView2nd:close()
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end

function runeComposeView2nd:onEnter()

    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
--    self.close_event = me.RegistCustomEvent("runeComposeView2nd",function (evt)
--        self:close()
--    end)
    --runeComposeView:removeFromParent()
end
function runeComposeView2nd:onExit()
    UserModel:removeLisener(self.netListener)
    me.RemoveCustomEvent(self.close_event)
end

function runeComposeView2nd:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_COMPOUND) then
        print("runeComposeView2nd:onRevMsg")
        local i = {}
        i[#i] = {}
        i[#i]["defId"] = msg.c.defId
        i[#i]["itemNum"] = 1
        i[#i]["needColorLayer"] = true
        i[#i]["is_rune"] = true --表示物品类型为符文
        --dump(i)
        getRuneAnim(msg.c)
        disWaitLayer()

        self.runeAddedList = {}

        self:cleanProbability()
        self:updateCailiaoNum()
        self:updateView()
        self:updateAppendAttr()
        self:reCaclInPackageNums()

        if self.data.needRunNum==0 then
            self:requestProbability() --请求概率
        end

        if self.parentView ~= nil then  --更新上级页面上阶圣器数量
            self.parentView:reComplexCacl()
        end

        -- 返还道具展示
        if msg.c.items and #msg.c.items > 0 then
            local txtList = {"合成返还以下道具"}
            local etc = cfg[CfgType.ETC]
            for k, v in pairs(msg.c.items) do
                table.insert(txtList, string.format("%s x%s", etc[v[1]].name, v[2]))
            end
            showMultipleTipWithBg(txtList)
        end
    end
    if checkMsg(msg.t, MsgCode.BOX_REMAKE) then
        if msg.c.id then
            local varCfg = cfg[CfgType.ETC][msg.c.id]
            if varCfg then
                if varCfg.useType == 124 then
                    self:updateCailiaoNum()
                    self:updateView()
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.RUNE_PROBABILITY) then
        self:cleanProbability()
        local list = msg.c.list
        for _, v in ipairs(list) do
            local txt = self.probabilityList[v.star+1]
            if txt then
                txt:setString(string.format("%.2f",v.per).."%")
            end
        end
    end
end

function runeComposeView2nd:addOneRune(data)
    self.runeAddedList[self.currentRuneIndex] = data
    self:updateView()
    self:updateAppendAttr()

    local flag=true
    for i=1, self.data.needRunNum do
        if self.runeAddedList[i]==nil then
            flag=false
            break
        end
    end
    if flag==true then --填充满，请求概率
        self:requestProbability()
    end
end

function runeComposeView2nd:cancelOneRune(index)
    self.runeAddedList[index] = nil
    self:updateView()
    self:updateAppendAttr()
    self:cleanProbability()
end

function runeComposeView2nd:requestProbability()
    local idList={}
    for _, v in pairs(self.runeAddedList) do
        table.insert(idList, v.id)
    end
    NetMan:send(_MSG.Rune_probability(self.data.id, idList))
end

function runeComposeView2nd:cleanProbability()
    for i=1, 7, 1 do
        local txt = self.probabilityList[i]
        txt:setString('-')
    end
end

function runeComposeView2nd:setParentView(parent)
    self.parentView = parent
end