runeHeceng = class("runeHeceng",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHeceng:create(...)
    local layer = runeHeceng.new(...)
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

function runeHeceng:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )

    self.arrRuneBackpack={}
    self.caclCache={}
end

function runeHeceng:onEnter()
    if self.clickArea1s[1] then
        guideHelper.nextStepByOpt(false,self.clickArea1s[1])
    end
end

function runeHeceng:onExit()
    UserModel:removeLisener(self.netListener)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end

    me.RemoveCustomEvent(self.uiRedPointListener)

    if self.checkEquipschId then
        me.Scheduler:unscheduleScriptEntry(self.checkEquipschId)    
        self.checkEquipschId = nil
    end
end

function runeHeceng:init()
    self.equipEmpty={}
    self.equip={}
    local fightTotal = 0
    self.clickArea1s = {}
    local nowEquip = user.runeEquiped[user.runeEquipIndex]
    for i=1, 4 do
        local eqEmpey = me.assignWidget(self, "equip_empty_"..i)
        self.equipEmpty[i]=eqEmpey
        self.clickArea1s[i] = me.assignWidget(self, "clickArea"..i)
        local eq = runeItem:create(me.assignWidget(self, "equip_"..i), 1) 
        self.equip[i]=eq

        if nowEquip[i] then
            eqEmpey:setVisible(false)
            eq:setData(nowEquip[i])
            fightTotal = fightTotal+nowEquip[i].fight
        else
            eq:setVisible(false)
            me.clickAni(me.assignWidget(eqEmpey, "jia"))
        end

        me.registGuiClickEvent(self.clickArea1s[i], handler(self, self.clickRune))
    end
    --me.assignWidget(self, "fightTotal"):setString(fightTotal)

    if user.runeEquipedRedpoint[user.runeEquipIndex]==true then   --显示当前特性红点
        me.assignWidget(me.assignWidget(self, "texinBtn"), "redpoint"):setVisible(true)
    else
        me.assignWidget(me.assignWidget(self, "texinBtn"), "redpoint"):setVisible(false)
    end

    me.registGuiClickEvent(me.assignWidget(self, "allAttrBtn"), handler(self, self.openAllAttrPanel))
    me.registGuiClickEvent(me.assignWidget(self, "texinBtn"), handler(self, self.openTexinPanel))
    me.registGuiClickEvent(me.assignWidget(self, "searchBtn"), handler(self, self.openSearchPanel))
    me.registGuiClickEvent(me.assignWidget(self, "handbookBtn"), handler(self, self.openHandbookPanel))
    if user.UI_REDPOINT.relicBtn[tostring(999)]==1 then
        me.assignWidget(me.assignWidget(self, "searchBtn"), "redpoint"):setVisible(true)
    end

    if user.rune_handbook_new==1 then
        me.assignWidget(me.assignWidget(self, "handbookBtn"), "redpoint"):setVisible(true)
    end

    -- 活动等UI红点显示
    self.uiRedPointListener = me.RegistCustomEvent("UI_RED_POINT", handler(self, self.updateUIRedPoint))

    self:initRuneTable()

    local altar_id = 41702
    for key, var in pairs(user.building) do
        if var.def ~= nil then
            if var.def.type == "altar" then
                altar_id = var.def.id
                print("altar_id1111 = "..altar_id)
                break
            end
        end
    end
    self.altarId=altar_id

    self.checkEquipschId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.checkHigherEquip), 0, false)

    self.nowCaseIndex = user.runeEquipIndex
    self:updateActiveState(user.runeEquipIndex)
    self:updateCaseBtnState(user.runeEquipIndex)

    for k=1, 4 do
        local caseBtn = me.assignWidget(self, "equipCase"..k)
        me.registGuiClickEvent(caseBtn, handler(self, self.switchCase))
    end

    --激活方案
    me.registGuiClickEventByName(self, "activeBtn", handler(self, self.activeCase))

    return true
end

-- 活动等UI红点显示
function runeHeceng:updateUIRedPoint()
    if user.UI_REDPOINT.relicBtn[tostring(999)]==1 then
        me.assignWidget(me.assignWidget(self, "searchBtn"), "redpoint"):setVisible(true)
    else
        me.assignWidget(me.assignWidget(self, "searchBtn"), "redpoint"):setVisible(false)
    end
end


---
-- 激活方案
--
function runeHeceng:activeCase(node)
    if self.nowCaseIndex~=user.runeEquipIndex then
        me.showMessageDialog("切换方案将改变供奉圣物与特性效果，是否确认？",function (args)
            if args == "ok" then
                NetMan:send(_MSG.Rune_case_active(self.nowCaseIndex))
            end
        end)
    else
        showTips("激活中")
    end
end


---
-- 切换到其它方案
--
function runeHeceng:switchCase(node)
    self.nowCaseIndex = node:getTag()
    self:updateActiveState(self.nowCaseIndex)
    self:updateCaseBtnState(self.nowCaseIndex)
    self:updateRuneEquip()
end

---
-- 更新方案按钮状态
--
function runeHeceng:updateCaseBtnState(nowCase)
    for k, v in ipairs(user.runeEquiped) do
        local caseBtn = me.assignWidget(self, "equipCase"..k)
        if k==nowCase then
            caseBtn:loadTextureNormal("rune_heceng_btn3.png",me.localType)
        else
            caseBtn:loadTextureNormal("rune_heceng_btn2.png",me.localType)
        end

        if user.runeEquipIndex==k then
            if k==nowCase then
                me.assignWidget(caseBtn, "selectImg"):setVisible(false)
                caseBtn:loadTextureNormal("rune_heceng_btn9.png",me.localType)
            else
                me.assignWidget(caseBtn, "selectImg"):setVisible(true)
            end
        else
            me.assignWidget(caseBtn, "selectImg"):setVisible(false)
        end
        if table.getn(table.keys(v))==0 then
            me.assignWidget(caseBtn, "jiaImg"):setVisible(true)
            me.assignWidget(caseBtn, "nameTxt"):setVisible(false)
        else
            me.assignWidget(caseBtn, "jiaImg"):setVisible(false)
            me.assignWidget(caseBtn, "nameTxt"):setVisible(true)
        end
    end
end

---
-- 激活按钮状态
--
function runeHeceng:updateActiveState(nowCase)
    local activeBtn = me.assignWidget(self, "activeBtn")
    local activeTxt = me.assignWidget(activeBtn, "nameTxt")
    if nowCase==user.runeEquipIndex then
        activeBtn:loadTextureNormal("rune_heceng_btn7.png",me.localType)
        activeTxt:setString("激活中")
        activeTxt:setTextColor(cc.c3b(0, 255, 0))
    else
        activeBtn:loadTextureNormal("rune_heceng_btn6.png",me.localType)
        activeTxt:setString("点击激活")
        activeTxt:setTextColor(cc.c3b(237, 213, 137))
    end
end

---
-- 打开所有属性面板
--
function runeHeceng:openAllAttrPanel()
    local attrPanel = runeAllAttr:create("rune/runeAllAttr.csb")
    me.runningScene():addChild(attrPanel, me.MAXZORDER)
    attrPanel:initData(self.nowCaseIndex)
    me.showLayer(attrPanel, "bg")
end

---
-- 打开特性面板
--
function runeHeceng:openTexinPanel()
    local texinPanel = runeGongfengTexin:create("rune/runeGongfengTexin.csb")
    me.runningScene():addChild(texinPanel, me.MAXZORDER)

    local caseBtn = me.assignWidget(self, "equipCase"..self.nowCaseIndex)
    texinPanel:initData(self.nowCaseIndex,me.assignWidget(caseBtn, "nameTxt"):getString())
    me.showLayer(texinPanel, "bg")

    me.assignWidget(me.assignWidget(self, "texinBtn"), "redpoint"):setVisible(false)
end


---
-- 打开圣器搜寻
--
function runeHeceng:openSearchPanel()
    local runesearch = runeSearch:create("rune/runeSearch.csb")
    me.runningScene():addChild(runesearch, me.MAXZORDER)
    me.showLayer(runesearch,"bg")
end

---
-- 打开图鉴面板
--
function runeHeceng:openHandbookPanel()
    NetMan:send(_MSG.Rune_handbook_active())
    local handbook = runeHandbook:create("rune/runeHandbook.csb")
    me.runningScene():addChild(handbook, me.MAXZORDER)
    me.showLayer(handbook,"bg")

    user.rune_handbook_new=0
    me.assignWidget(me.assignWidget(self, "handbookBtn"), "redpoint"):setVisible(false)
end


function runeHeceng:clickRune(node)
    local runeEquiped = user.runeEquiped[self.nowCaseIndex]
    local runeInfo = runeEquiped[node:getTag()]
    if runeInfo then
        -- 符文详细信息
        local runeDetail = runeDetailView:create ("rune/runeDetailView.csb")
        
        me.runningScene():addChild(runeDetail, me.MAXZORDER)
        
        me.showLayer(runeDetail, "bg")
        runeDetail:setRuneInfo(runeInfo)
    else
        local arrRuneBackpack = table.values(user.runeBackpack)
        local len=#arrRuneBackpack
        while len>0 do
            local tmp = arrRuneBackpack[len]
            if cfg[CfgType.RUNE_DATA][tmp.cfgId].type==99 then
                table.remove(arrRuneBackpack, len)
            end
            len=len-1
        end
        if #arrRuneBackpack <= 0 then
            -- 提示背包无当前选中类型的符文
            print ("背包无当前选中类型的符文")
            showTips("背包没有圣物")
        else

            local function registerConfirmChange (runeData)
                NetMan:send(_MSG.Rune_equip(node:getTag(), runeData.id, self.nowCaseIndex))
                showWaitLayer ()   
            end
            local function registerSelecCallback (runeData)
                local detail = runeGongfengDetail:create("rune/runeGongfengDetail.csb")
                me.runningScene():addChild(detail, me.MAXZORDER)
                me.showLayer(detail,"bg")
                detail:setData(runeEquiped[node:getTag()], runeData)
                detail:registerSelecCallback(registerConfirmChange)
            end

            -- 符文选择
            local selectView = runeSelectView:create("rune/runeSelectView.csb")
            me.runningScene():addChild(selectView, me.MAXZORDER)
            me.showLayer(selectView,"bg")
            selectView:setRuneBagData(arrRuneBackpack)
            selectView:registerSelecCallback(registerSelecCallback)
        end
    end
end

function runeHeceng:updateRuneEquip()
    local runeEquiped = user.runeEquiped[self.nowCaseIndex]
    local fightTotal = 0
    for i=1, 4 do
        local eqEmpey = self.equipEmpty[i]
        local eq = self.equip[i]
        if runeEquiped[i] then
            eqEmpey:setVisible(false)
            eq:setVisible(true)
            eq:setData(runeEquiped[i])
            fightTotal = fightTotal+runeEquiped[i].fight
            me.assignWidget(eq, "higher"):stopAllActions()
            me.assignWidget(eq, "higher"):setVisible(false)
        else
            eq:setVisible(false)
            eqEmpey:setVisible(true)
            me.assignWidget(eqEmpey, "jia"):stopAllActions()
            --me.clickAni(me.assignWidget(eqEmpey, "jia"))
        end
    end
    --me.assignWidget(self, "fightTotal"):setString(fightTotal)
    self:checkHigherEquip()

    --显示当前特性红点
    if user.runeEquipedRedpoint[self.nowCaseIndex]==true then
        me.assignWidget(me.assignWidget(self, "texinBtn"), "redpoint"):setVisible(true)
    else
        me.assignWidget(me.assignWidget(self, "texinBtn"), "redpoint"):setVisible(false)
    end
end

function runeHeceng:checkHigherEquip()
    local level = {}
    for k, v in pairs (user.runeBackpack) do
        local runeBaseCfg = cfg[CfgType.RUNE_DATA][v.cfgId]
        table.insert(level, {runeBaseCfg.level,v.star})
    end
    table.sort (level, function (a, b)
        if a[1] == b[1] then
           return a[2] > b[2]
        else
            return a[1]>b[1]
        end
        
    end)
    local n = #level

    local runeEquiped = user.runeEquiped[self.nowCaseIndex]
    for i=1, 4 do
        local eqEmpey = self.equipEmpty[i]
        local eq = self.equip[i]
        if runeEquiped[i] then
            local runeBaseCfg = cfg[CfgType.RUNE_DATA][runeEquiped[i].cfgId]
            if n>0 and level[1][1]>runeBaseCfg.level and level[1][2]>=runeEquiped[i].star then
                me.assignWidget(eq, "higher"):setVisible(true)
                me.clickAni(me.assignWidget(eq, "higher"))
            end
        else
            if n>0 then
                me.clickAni(me.assignWidget(eqEmpey, "jia"))
            end
        end
    end
end

function runeHeceng:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_UPDATE) or
        checkMsg(msg.t, MsgCode.RUNE_REMOVE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then
        self:updateRuneEquip()
        disWaitLayer()
        -- 强化
        -- 卸下
        -- 替换
    elseif checkMsg(msg.t, MsgCode.RUNE_CASE_ACTIVE) then
        user.runeEquipIndex = msg.c.plan
        self:updateActiveState(self.nowCaseIndex)
        self:updateCaseBtnState(self.nowCaseIndex)

        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_RUNE_CASE_ACTIVE)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2+50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
    elseif checkMsg(msg.t, MsgCode.RUNE_HANDBOOK_NEW) then --圣物图鉴有新增
        me.assignWidget(me.assignWidget(self, "handbookBtn"), "redpoint"):setVisible(true)
    end
end

---
-- 首次延时加载
--
function runeHeceng:firstLoad(nowCate, jumpToNoActive)
    showWaitLayer()
    me.DelayRun(function()
        self:setData(nowCate, jumpToNoActive)
        disWaitLayer()
    end, 0.1)
end
function runeHeceng:setData(nowCate, jumpToNoActive)
    me.assignWidget(self, "loadTips"):setVisible(false)

    local runeDatasAll = cfg[CfgType.RUNE_DATA]
    local activeTbl = {}
    local activeTblNot={}
    for _, v in pairs(runeDatasAll) do
        if v.type~=99 and (nowCate==0 or v.level==nowCate) then
            local unlockLevel = getRuneBuildingCfgInfoByid(self.altarId)
            if v.level <= unlockLevel then
                table.insert(activeTbl, {data=v, flag=1})
            else
                table.insert(activeTblNot, {data=v, flag=3})
            end
        end
    end

    table.sort(activeTbl, function(a, b)
        if tonumber(a.data.level) == tonumber(b.data.level) then
            return a.data.id < b.data.id
        else
            return tonumber(a.data.level) > tonumber(b.data.level)
        end
    end)

    table.sort(activeTblNot, function(a, b)
        if tonumber(a.data.level) == tonumber(b.data.level) then
            return a.data.id < b.data.id
        else
            return tonumber(a.data.level) < tonumber(b.data.level)
        end
    end)

    local activeNums = #activeTbl
    local middle = {flag=0, height=0}
    if activeNums==0 then
        middle["height"]=50
    elseif activeNums<3 then
        middle["height"]=298
    elseif activeNums<5 then
        middle["height"]=188
    else
        middle["height"]=80
    end
    if activeNums%2~=0 then
        table.insert(activeTbl, {flag=2})
    end
    table.insert(activeTbl, middle)                ---中间线
    table.insert(activeTbl, {flag=-1, height=0})   ---中间线

    local jumpIndex=0  --图鉴未激活时，跳转到当前页面
    if jumpToNoActive==5 then
        jumpIndex = math.ceil(#activeTbl/2)
    end

    for k, v in ipairs(activeTblNot) do
        table.insert(activeTbl, v)      
    end

    self.arrRuneBackpack=activeTbl
    self.runeTableView:reloadData()

    if jumpToNoActive==5 then    --图鉴未激活时，跳转到当前页面
        local pOffest = self.runeTableView:getContentOffset()
        local size = self.runeTableView:getContentSize()
        pOffest.y=593-(math.ceil(#self.arrRuneBackpack / 2)-jumpIndex+1)*148-40
        if size.height<593 then
            pOffest.y=593-size.height
        elseif pOffest.y>0 then
            pOffest.y=0
        end
        self.runeTableView:setContentOffset(pOffest)
    end

    self.cthread = coroutine.create(function ()
        self:complexCacl(false)
    end)

    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
    self.schid = me.coroStart(self.cthread)
end

function runeHeceng:reComplexCacl()
    self.caclCache={}
    self.cthread = coroutine.create(function ()
        self:complexCacl(true)
    end)

    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
    self.schid = me.coroStart(self.cthread)
end
function runeHeceng:complexCacl(isReCacl)
    for k, v in ipairs(self.arrRuneBackpack) do
        if v.flag==1 then
            if v.data.needRunNum>0 then
                if self.caclCache[v.data.id]==nil then
                    local needrunlevel = v.data.needRunLevel:split(",")
                    local count=0
                    --[[
                    for key, var in pairs(needrunlevel) do
                        local needLevelCfgId = var
                        for k, v in pairs (user.runeBackpack) do
                            if v.lock==false and tonumber(v.cfgId) == tonumber(needLevelCfgId) then
                                count=count+1
                                break
                            end
                        end
                    end
                    ]]
                    v["hasRuneNums"]=count
                    self.caclCache[v.data.id]=count
                    coroutine.yield()
                else
                    v["hasRuneNums"]=self.caclCache[v.data.id]
                end
            end
        elseif v.flag==3 then
            if self.caclCache[v.data.id]==nil then
                local level = v.data.level
                local info = getAllRuneBuildingCfgInfo()
                local need_altar_level = 100
                for key, var in pairs(info) do
                    local unlock_level = getRuneBuildingCfgInfoByid(var.id)
                    if unlock_level == level then
                        if var.level <= need_altar_level then
                            need_altar_level = var.level
                        end
                    end
                end
                v["altarLevel"]=need_altar_level
                self.caclCache[v.data.id]=need_altar_level
                coroutine.yield() 
            else
                v["altarLevel"]=self.caclCache[v.data.id]
            end
        end     
    end

    if isReCacl==true then
        local offset=self.runeTableView:getContentOffset()
        self.runeTableView:reloadData()
        self.runeTableView:setContentOffset(offset)
    end
end

function runeHeceng:onClickHecengItem(node)
    local cellData = self.arrRuneBackpack[node:getTag()]
    if cellData["flag"]==1 then
        local rune_view = runeComposeView2nd:create("runeComposeView2nd.csb")        
        me.runningScene():addChild(rune_view,me.MAXZORDER)        
        me.showLayer(rune_view,"bg_frame")
        rune_view:setData(cellData.data)
        rune_view:setParentView(self)
    end
end

function runeHeceng:initRuneTable()
    self.runeTableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end
    local function cellSizeForTable(table, idx)
        local cellData = self.arrRuneBackpack[idx*2+1]
        if cellData["flag"]==0 or cellData["flag"]==-1 then  --分隔线
            return 658, cellData["height"]
        else
            return 658, 148
        end
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        if nil == cell then
            cell = cc.TableViewCell:new()
            
            for  var = 1,2 do
                local pTag = idx*2+var
                local cellData = self.arrRuneBackpack[pTag]
                if cellData then
                    if cellData["flag"]==1 or cellData["flag"]==3 then
                        local leftCell = runeComposecell:create(me.assignWidget(self,"hecengItem"):clone():setVisible(true), 1) 
                        leftCell:setName('normal'..var)  
                        me.registGuiClickEvent(leftCell, handler(self, self.onClickHecengItem)) 
                        leftCell:setSwallowTouches(false)
                        leftCell:setPosition(cc.p((var-1)*327-22,-10))     
                        local runeItemNode = me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true)
                        leftCell:initRuneItem(runeItemNode)
                        leftCell:setTag(pTag)
                        leftCell:setData(cellData)
                        cell:addChild(leftCell)
                    elseif cellData["flag"]==0 then  --分隔线
                        local line = me.assignWidget(self,"hecengLine"):clone():setVisible(true)
                        line:setName('line'..var)  
                        line:setPosition(cc.p(500,36))   
                        cell:addChild(line)
                    end
                end
             end
        else
            for  var = 1, 2  do
                local pTag = idx*2+var
                local cellData = self.arrRuneBackpack[pTag]
                if cellData then
                    if cellData["flag"]==1 or cellData["flag"]==3 then
                        local leftCell = cell:getChildByName('normal'..var)
                        if leftCell~=nil then
                            leftCell:setData(cellData)
                        else
                            leftCell = runeComposecell:create(me.assignWidget(self,"hecengItem"):clone():setVisible(true), 1) 
                            leftCell:setName('normal'..var)  
                            me.registGuiClickEvent(leftCell, handler(self, self.onClickHecengItem)) 
                            leftCell:setSwallowTouches(false)
                            leftCell:setPosition(cc.p((var-1)*327-22,-10)) 
                            local runeItemNode = me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true)    
                            leftCell:initRuneItem(runeItemNode)
                            leftCell:setData(cellData)
                            cell:addChild(leftCell)
                        end
                        leftCell:setTag(pTag)
                        cell:removeChildByName('gray'..var)
                    elseif cellData["flag"]==2 then  --占位
                        cell:removeChildByName('gray'..var)
                        cell:removeChildByName('normal'..var)
                    elseif cellData["flag"]==0 then  --分隔线
                        local leftCell = cell:getChildByName('line'..var)
                        if leftCell==nil then
                            local line = me.assignWidget(self,"hecengLine"):clone():setVisible(true)
                            line:setName('line'..var)  
                            line:setPosition(cc.p(500,36))   
                            cell:addChild(line)
                        end
                        cell:removeChildByName('normal'..var)
                    elseif cellData["flag"]==-1 then  --分隔线
                        cell:removeChildByName('normal'..var)
                    end
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        local num = math.ceil(#self.arrRuneBackpack / 2)
        return num
    end

    local tableView = cc.TableView:create(cc.size(658, 593))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "tbl_node"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end