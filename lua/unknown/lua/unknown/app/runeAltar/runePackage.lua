local filterTbl={btn_quality_iorder="品质倒序",
                 btn_quality_rorder="品质顺序",
                 btn_level_iorder="等级倒序",
                 btn_level_rorder="等级顺序",
                 btn_star_iorder="星级倒序",
                 btn_star_rorder="星级顺序",
                 }

runePackage = class("runePackage",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runePackage:create(...)
    local layer = runePackage.new(...)
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

function runePackage:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )

    self.arrRuneBackpack={}
    self.nowCate = 0
end

function runePackage:onEnter()
    
end

function runePackage:onExit()
    UserModel:removeLisener(self.netListener)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
end

function runePackage:init()
    self.equipEmpty={}
    self.equip={}
    for i=1, 4 do
        local eqEmpey = me.assignWidget(self, "equip_empty_"..i)
        self.equipEmpty[i]=eqEmpey

        local eq = runeItem:create(me.assignWidget(self, "equip_"..i), 1) 
        self.equip[i]=eq
        me.registGuiClickEvent(me.assignWidget(self, "clickArea"..i), handler(self, self.clickRuneEquip))
    end
    me.assignWidget(self, "fightTotal"):setString('0')

    self:initRuneTable()

    self.panelRuneEquip = me.assignWidget(self, "Image_Right")  --装备面板
    self.panelRuneEquip:setVisible(false)

    self.panelRuneInfo = me.assignWidget(self, "Panel_runeInfo") --圣器信息面板
    self.panelRuneInfo:setVisible(true)

    self.currentItem = runeItem:create("rune/runeItem.csb")
    self.currentItem:setPosition(70, 271.49)
    self.currentItem:setScale(0.9)
    self.panelRuneInfo:addChild(self.currentItem)
    me.registGuiClickEvent(self.currentItem.icon, handler(self, self.openSkillReset))

    self.infoGray = me.assignWidget(self.panelRuneInfo, "infoGray")
    self.fengjieBtn = me.assignWidget(self.panelRuneInfo, "btn_fengjie")
    self.fengjieBatchBtn = me.assignWidget(self.panelRuneInfo, "btn_fengjie_batch")
    self.qianghuaBtn = me.assignWidget(self.panelRuneInfo, "btn_qianghua")
    self.XLBtn = me.assignWidget(self.panelRuneInfo, "btn_xl")
    self.awakenBtn = me.assignWidget(self.panelRuneInfo, "btn_awaken")
    self.fengjieBtn:addClickEventListener(handler(self, self.onOpenFengjie))
    self.qianghuaBtn:addClickEventListener(handler(self, self.onOpenQianghua))
    self.XLBtn:addClickEventListener(handler(self, self.onOpenXL))
    self.awakenBtn:addClickEventListener(handler(self, self.onOpenAwaken))
    self.fengjieBatchBtn:addClickEventListener(handler(self, self.onOpenFengjieBatch))

    self.lockBtn = me.assignWidget(self, "lockBtn")
    self.lockBtn:addClickEventListener(handler(self, self.changeLockState))

    --属性汇总页面
    me.registGuiClickEvent(me.assignWidget(self, "allAttrBtn"), handler(self, self.openAllAttrPanel))

    -- 符文属性列表
    self.runePropList = me.assignWidget(self, "list_property")
    self.runePropList:setScrollBarEnabled (false)

    ---条件过滤
    self.nowFilter = "btn_quality_iorder"
    local function selectFilter (sender)
        self.nowFilter = sender:getName()
        me.assignWidget(self, "popfilter"):setVisible(false)
        me.assignWidget(self, "pingzhiName"):setString(filterTbl[self.nowFilter])

        self.selectRune=nil
        self.selectRuneData=nil
        self:initRuneList()
    end
    for key, var in pairs(filterTbl) do
        me.assignWidget(self, key):addClickEventListener(selectFilter)
    end
    me.assignWidget(self, "pingzhiName"):setString(filterTbl[self.nowFilter])


    local function onOpenFilterPanel(sender)
        me.assignWidget(self, "popfilter"):setVisible(true)
    end
    me.assignWidget(self, "pingzhiBtn"):addClickEventListener(onOpenFilterPanel)
    me.registGuiClickEventByName(self,"popfilterPanel",function (node)
        local pTouch = node:getTouchBeganPosition()    
        local popfilter = me.assignWidget(self, "popfilter")    
        local pRect = cc.rect(0,0,popfilter:getContentSize().width,popfilter:getContentSize().height)  
        local locationInNode = popfilter:convertToNodeSpace(pTouch) 
        if not cc.rectContainsPoint(pRect, locationInNode) then
            popfilter:setVisible(false)
        end
    end)      

    self.selectRune = nil
    self.selectRuneData=nil

    return true
end

---
-- 打开所有属性面板
--
function runePackage:openAllAttrPanel()
    local attrPanel = runeAllAttr:create ("rune/runeAllAttr.csb")
    me.runningScene():addChild(attrPanel, me.MAXZORDER)
	attrPanel:initData(user.runeEquipIndex)
    me.showLayer(attrPanel, "bg")
end

---
-- 打开分解页面
--
function runePackage:onOpenFengjie()
    if self.selectRuneData.lock==true then
        showTips("圣物锁定不能被分解")
        return 
    end
    local breakView = runeBreakView:create("rune/runeBreakView.csb")    
    me.runningScene():addChild(breakView, me.MAXZORDER)   
    breakView:setSelectRuneInfo(self.selectRuneData)
    me.showLayer(breakView, "bg")
end

---
-- 打开批量分解页面
--
function runePackage:onOpenFengjieBatch()
    local breakView = runeBreakBatch:create("rune/runeBreakBatch.csb")    
    me.runningScene():addChild(breakView, me.MAXZORDER)   
    me.showLayer(breakView, "bg")
end

---
-- 打开强化页面
--
function runePackage:onOpenQianghua()
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.selectRuneData.cfgId]
    if runeBaseCfg.type==99 then
        return
    end

    local strengthView = runeStrengthView:create("rune/runeStrengthView.csb")
    me.runningScene():addChild(strengthView, me.MAXZORDER)
    strengthView:setSelectRuneInfo(self.selectRuneData)
    me.showLayer(strengthView, "bg")
    local function refreshData()
        self:onClickRune(self.selectRune)
    end
    strengthView:setCloseCallback(refreshData)
end
---
-- 打开洗炼页面
--
function runePackage:onOpenXL()
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.selectRuneData.cfgId]
    if runeBaseCfg.type==99 then
        return
    end
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.selectRuneData.glv]
    if runeStrengthCfg.level<10 then
        showTips("圣物强化10级开启")
        return
    end

    local xlView = runeXL:create("rune/runeXL.csb")
    me.runningScene():addChild(xlView, me.MAXZORDER)
    me.showLayer(xlView,"bg")
    xlView:setXLRuneInfo(self.selectRuneData)
end

---
-- 打开觉醒页面
--
function runePackage:onOpenAwaken()
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.selectRuneData.cfgId]
    if runeBaseCfg.type==99 then
        return
    end

    if self.selectRuneData.star<4 then
        showTips("4星及以上圣物才可进行觉醒")
        return
    end

    local awakenView = runeAwaken:create("rune/runeAwaken.csb")
    me.runningScene():addChild(awakenView, me.MAXZORDER)
    awakenView:setData(self.selectRuneData)
    me.showLayer(awakenView, "bg")
end
---
-- 打开技能重置
--
function runePackage:openSkillReset()
    if self.selectRuneData.runeSkillId==0 then
        return
    end

    local skillResetView = runeSkillReset:create("rune/runeSkillReset.csb")
    me.runningScene():addChild(skillResetView, me.MAXZORDER)
    skillResetView:setData(self.selectRuneData)
    me.showLayer(skillResetView, "bg")
end

---
-- 圣器解锁或锁定
--
function runePackage:changeLockState()
    NetMan:send(_MSG.Rune_lock(self.selectRuneData.id))
    showWaitLayer ()
end

function runePackage:clickRuneEquip(node)
    local nowEquip = user.runeEquiped[user.runeEquipIndex]
    local src = nowEquip[node:getTag()]
    
    local function registerSelecCallback (runeData)
        NetMan:send(_MSG.Rune_equip(node:getTag(), runeData.id, src.plan))
        showWaitLayer ()
    end

    local detail = runeGongfengDetail:create("rune/runeGongfengDetail.csb")
    me.runningScene():addChild(detail, me.MAXZORDER)
    me.showLayer(detail,"bg")
    detail:setData(src, self.selectRuneData)
    detail:registerSelecCallback(registerSelecCallback)
end

function runePackage:blink(node)
    local a1 = cc.FadeTo:create(0.7, 100)
    local a2 = cc.FadeIn:create(0.7)
    local a3 = cc.Sequence:create(a1, a2)

    local a11 = cc.ScaleTo:create(0.7, 1.02)
    local a12 = cc.ScaleTo:create(0.7, 1)
    local a13 = cc.Sequence:create(a11, a12)

    local act = cc.RepeatForever:create(cc.Spawn:create(a3, a13))
    node:runAction(act)
end
function runePackage:updateRuneEquip()
    local nowEquip = user.runeEquiped[user.runeEquipIndex]
    local fightTotal = 0
    for i=1, 4 do
        local eqEmpey = self.equipEmpty[i]
        local eq = self.equip[i]
        if nowEquip[i] then
            eqEmpey:setVisible(false)
            eq:setVisible(true)
            eq:setData(nowEquip[i])
            eq:select()
            eq.selected:stopAllActions()
            self:blink(eq.selected)
            fightTotal = fightTotal+nowEquip[i].fight
        else
            eq:setVisible(false)
            eqEmpey:setVisible(true)
            me.assignWidget(eqEmpey, "selected"):stopAllActions()
            me.clickAni(me.assignWidget(eqEmpey, "selected"))
        end
    end
    me.assignWidget(self, "fightTotal"):setString(fightTotal)
end
function runePackage:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_UPDATE) or
        checkMsg(msg.t, MsgCode.RUNE_REMOVE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then
        self:updateRuneEquip()

        --更新背包列表
        local offset=self.runeTableView:getContentOffset()
        if self.selectRuneData and user.runeBackpack[self.selectRuneData.id]==nil then
            self.selectRune=nil
            self.selectRuneData=nil
        end

        self:initRuneList()
        self.runeTableView:setContentOffset(offset)

        self:onClickRune(self.selectRune)

        disWaitLayer()
        -- 强化
        -- 卸下
        -- 替换
    elseif checkMsg(msg.t, MsgCode.RUNE_RESOLVE) then  -- 分解圣器
        --更新背包列表
        local offset=self.runeTableView:getContentOffset()
        self.selectRune=nil
        self.selectRuneData=nil
        self:initRuneList()
        --self:removeOneRuneData()
        
        local size=self.runeTableView:getContentSize()
        if offset.y<548-size.height then
            offset.y=548-size.height
        elseif offset.y>0 then
            offset.y=0
        end
        self.runeTableView:setContentOffset(offset)

        disWaitLayer()

        local tbValues = json.decode (msg.c.got)
        for k, v in pairs (tbValues) do
            local etc = cfg[CfgType.ETC][me.toNum(v[1])]
            showTips ("分解成功，获得"..etc.name.."×" .. v[2])
        end
     elseif checkMsg(msg.t, MsgCode.RUNE_UPDATE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then -- 更新圣物
        local runeInfo = user.runeBackpack[msg.c.id]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[user.runeEquipIndex]
            runeInfo = nowEquip[self.runeInfo.index]
        end
        self.selectRuneData=runeInfo
        self.selectRune.data=runeInfo
        self:updatePropertyList()


    --[[
    elseif checkMsg(msg.t, MsgCode.RUNE_LOCK) then  -- 圣器锁定
        local offset=self.runeTableView:getContentOffset()
        self:initRuneList()
        self.runeTableView:setContentOffset(offset)

        self:onClickRune(self.selectRune)

        disWaitLayer()
    ]]
    end
end




function runePackage:initRuneTable()
    self.runeTableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
        --local offset=self.runeTableView:getContentOffset()
        --local size=self.runeTableView:getContentSize()
        --print(offset.y..",,,"..size.height)
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end
    local function cellSizeForTable(table, idx)
        return 658, 260
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        if nil == cell then
            cell = cc.TableViewCell:new()
            local line = ccui.ImageView:create()
            line:loadTexture("rune_line1.png", me.localType)
            line:setPosition(328, 5)
            cell:addChild(line)

            for  var = 1,4 do
                local pTag = idx*4+var
                local pData = self.arrRuneBackpack[pTag]
                if pData and pData~=0 then
                    local leftCell = runeItem:create(me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true), 1) 
                    leftCell.nameTxt:setFontSize(36)
                    leftCell:setScale(0.53) 
                    leftCell:setName('normal'..var)  
                    me.registGuiClickEvent(leftCell, handler(self, self.onClickRune)) 
                    leftCell:setSwallowTouches(false)
                    leftCell:setPosition(cc.p((var-1)*163+4,20))     
                    leftCell:setData(pData)
                    cell:addChild(leftCell)

                    --[[
                    local gongfengBtn = me.assignWidget(me.assignWidget(self,"RuneItem"), "gongfengBtn"):clone():setVisible(false)
                    gongfengBtn:setPosition(30.68, -69.82)
                    gongfengBtn:setContentSize(cc.size(246, 61))
                    leftCell:addChild(gongfengBtn)
                    me.registGuiClickEvent(gongfengBtn, handler(self, self.onClickGongfeng)) 

                    local gongfengQuxiaoBtn = me.assignWidget(me.assignWidget(self,"RuneItem"), "gongfengQuxiaoBtn"):clone():setVisible(false)
                    gongfengQuxiaoBtn:setPosition(30.68, -69.82)
                    gongfengQuxiaoBtn:setContentSize(cc.size(246, 61))
                    leftCell:addChild(gongfengQuxiaoBtn)
                    me.registGuiClickEvent(gongfengQuxiaoBtn, handler(self, self.onClickQuxiaoGongfeng)) 
                    ]]

                    self:fillCellData(leftCell, pData)
                    if pTag==1 and self.selectRune==nil then
                        self:onClickRune(leftCell)
                    end
                else
                    local leftCell = me.assignWidget(self,"RuneGray"):clone():setVisible(true)  
                    leftCell:setName('gray'..var)  
                    leftCell:setPosition(cc.p((var-1)*166+6,30))     
                    cell:addChild(leftCell)
                end
             end
        else
            for  var = 1, 4  do
                local pTag = idx*4+var
                local pData = self.arrRuneBackpack[pTag]
                if pData and pData~=0 then
                    local leftCell = cell:getChildByName('normal'..var)
                    if leftCell~=nil then
                        leftCell:setData(pData)
                        --me.assignWidget(leftCell,"gongfengQuxiaoBtn"):setVisible(false)
                        --me.assignWidget(leftCell,"gongfengBtn"):setVisible(false)
                    else
                        leftCell = runeItem:create(me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true), 1)  
                        leftCell:setScale(0.53) 
                        leftCell:setName('normal'..var)  
                        me.registGuiClickEvent(leftCell, handler(self, self.onClickRune)) 
                        leftCell:setSwallowTouches(false)
                        leftCell:setPosition(cc.p((var-1)*163+4,20))     
                        leftCell:setData(pData)
                        cell:addChild(leftCell)

                        --[[
                        local gongfengBtn = me.assignWidget(me.assignWidget(self,"RuneItem"), "gongfengBtn"):clone():setVisible(false)
                        gongfengBtn:setPosition(30.68, -69.82)
                        gongfengBtn:setContentSize(cc.size(246, 61))
                        leftCell:addChild(gongfengBtn)
                        me.registGuiClickEvent(gongfengBtn, handler(self, self.onClickGongfeng)) 

                        local gongfengQuxiaoBtn = me.assignWidget(me.assignWidget(self,"RuneItem"), "gongfengQuxiaoBtn"):clone():setVisible(false)
                        gongfengQuxiaoBtn:setPosition(30.68, -69.82)
                        gongfengQuxiaoBtn:setContentSize(cc.size(246, 61))
                        leftCell:addChild(gongfengQuxiaoBtn)
                        me.registGuiClickEvent(gongfengQuxiaoBtn, handler(self, self.onClickQuxiaoGongfeng)) 
                        ]]
                    end
                    self:fillCellData(leftCell, pData)
                    if pTag==1 and self.selectRune==nil then
                        self:onClickRune(leftCell)
                    end
                    cell:removeChildByName('gray'..var)
                else
                    local leftCell = cell:getChildByName('gray'..var)
                    if leftCell==nil then
                        leftCell = me.assignWidget(self,"RuneGray"):clone():setVisible(true)  
                        leftCell:setName('gray'..var)  
                        leftCell:setPosition(cc.p((var-1)*166+6,30))     
                        cell:addChild(leftCell)
                    end
                    cell:removeChildByName('normal'..var)
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        local num = math.ceil(#self.arrRuneBackpack / 4)
        return num
    end

    local tableView = cc.TableView:create(cc.size(658, 548))
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

function runePackage:fillCellData(leftCell, data)
    leftCell:unSelect()
    if self.selectRuneData ~= nil and self.selectRuneData.id==data.id then
        self.selectRune=leftCell
        self.selectRune:select()
    end
end

--点击供奉
function runePackage:onClickGongfeng(node)
    self.panelRuneEquip:setVisible(true)
    self.panelRuneInfo:setVisible(false)

    --me.assignWidget(self.selectRune, "gongfengBtn"):setVisible(false)
    --me.assignWidget(self.selectRune, "gongfengQuxiaoBtn"):setVisible(true)

    self:updateRuneEquip()
end
--点击取消供奉
function runePackage:onClickQuxiaoGongfeng(node)
    self.panelRuneEquip:setVisible(false)
    self.panelRuneInfo:setVisible(true)

    --me.assignWidget(self.selectRune, "gongfengBtn"):setVisible(true)
    --me.assignWidget(self.selectRune, "gongfengQuxiaoBtn"):setVisible(false)
end
--点击列表中的圣器
function runePackage:onClickRune(node)
    if node==nil then return end

    if self.selectRune ~= nil and self.selectRune:getParent():getParent()~=nil then
        --me.assignWidget(self.selectRune, "gongfengBtn"):setVisible(false)
        --me.assignWidget(self.selectRune, "gongfengQuxiaoBtn"):setVisible(false)
        self.selectRune:unSelect()
    end

    self.panelRuneEquip:setVisible(false)
    self.panelRuneInfo:setVisible(true)

    self.selectRune=node
    self.selectRuneData=self.selectRune.data
    self.selectRune:select()
    self.currentItem:setData(self.selectRune.data)

    --me.assignWidget(self.selectRune, "gongfengBtn"):setVisible(true)
    --me.assignWidget(self.selectRune, "gongfengQuxiaoBtn"):setVisible(false)

    if me.assignWidget(self.selectRune, "newIcon"):isVisible()==true then
        me.assignWidget(self.selectRune, "newIcon"):setVisible(false)
    end


    self:updateLockState()
    self:updatePropertyList()
end

---
-- 分解时移除数据
--
function runePackage:removeOneRuneData()
    for i, v in ipairs(self.arrRuneBackpack) do
        if v.id==self.selectRuneData.id then
            table.remove(self.arrRuneBackpack, i)
            break
        end
    end
    self.selectRuneData=nil
    local runeNum = #self.arrRuneBackpack
    if runeNum==0 then
        self.infoGray:setVisible(true)
        self.currentItem:setVisible(false)
        self.selectRune=nil
        self.selectRuneData=nil
        self.runePropList:removeAllItems()

        self.fengjieBtn:setBright(false)
        self.fengjieBtn:setTouchEnabled(false)
        self.fengjieBtn:setVisible(false)
        self.qianghuaBtn:setBright(false)
        self.qianghuaBtn:setTouchEnabled(false)
        self.qianghuaBtn:setVisible(false)
        self.XLBtn:setBright(false)
        self.XLBtn:setTouchEnabled(false)
        self.XLBtn:setVisible(false)

        self.lockBtn:setVisible(false)
    else
        self.infoGray:setVisible(false)
        self.currentItem:setVisible(true)

        self.fengjieBtn:setBright(true)
        self.fengjieBtn:setTouchEnabled(true)
        self.fengjieBtn:setVisible(true)
        self.qianghuaBtn:setBright(true)
        self.qianghuaBtn:setTouchEnabled(true)
        self.qianghuaBtn:setVisible(true)
        self.XLBtn:setBright(true)
        self.XLBtn:setTouchEnabled(true)
        self.XLBtn:setVisible(true)

        self.lockBtn:setVisible(true)
    end
    if runeNum<12 then
        for k=runeNum+1, 12 do
            table.insert(self.arrRuneBackpack, 0)
        end
    end
    self.runeTableView:reloadData()
end
---
-- 初始化背包数据
--
function runePackage:setData(nowCate)
    self.nowCate=nowCate
    self.selectRune=nil
    self.selectRuneData=nil
    self:initRuneList()
end
function runePackage:initRuneList()
    self.arrRuneBackpack={}
    for _, v in pairs(user.runeBackpack) do
        if self.nowCate==0 or cfg[CfgType.RUNE_DATA][v.cfgId].level==self.nowCate then
            table.insert(self.arrRuneBackpack, v)
        end
    end
    
    if self.nowFilter=="btn_quality_iorder" then  --品质倒序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = a.star
            local strengthLvB = b.star

            if baseLvA == baseLvB then
                return strengthLvA > strengthLvB
            else
                return baseLvA > baseLvB
            end
        end)
    elseif self.nowFilter=="btn_quality_rorder" then  --品质顺序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = a.star
            local strengthLvB = b.star

            if baseLvA == baseLvB then
                return strengthLvA > strengthLvB
            else
                return baseLvA < baseLvB
            end
        end)
    elseif self.nowFilter=="btn_level_iorder" then  --等级倒序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
            local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level

            if strengthLvA == strengthLvB then
                return baseLvA > baseLvB
            else
                return strengthLvA > strengthLvB
            end
        end)
    elseif self.nowFilter=="btn_level_rorder" then  --等级顺序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
            local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level

            if strengthLvA == strengthLvB then
                return baseLvA > baseLvB
            else
                return strengthLvA < strengthLvB
            end
        end)
    elseif self.nowFilter=="btn_star_iorder" then  --星级倒序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
            local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level

            if a.star == b.star then
                return baseLvA > baseLvB
            else
                return a.star > b.star
            end
        end)
    elseif self.nowFilter=="btn_star_rorder" then  --星级顺序
        table.sort (self.arrRuneBackpack, function (a, b)
            local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
            local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
            local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
            local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level

            if a.star == b.star then
                return baseLvA > baseLvB
            else
                return a.star < b.star
            end
        end)
    end

    local runeNum = #self.arrRuneBackpack
    if runeNum==0 then
        self.infoGray:setVisible(true)
        self.currentItem:setVisible(false)
        self.selectRune=nil
        self.selectRuneData=nil
        self.runePropList:removeAllItems()

        self.fengjieBtn:setBright(false)
        self.fengjieBtn:setTouchEnabled(false)
        self.fengjieBtn:setVisible(false)
        self.qianghuaBtn:setBright(false)
        self.qianghuaBtn:setTouchEnabled(false)
        self.qianghuaBtn:setVisible(false)
        self.XLBtn:setBright(false)
        self.XLBtn:setTouchEnabled(false)
        self.XLBtn:setVisible(false)

        self.lockBtn:setVisible(false)
    else
        self.infoGray:setVisible(false)
        self.currentItem:setVisible(true)

        self.fengjieBtn:setBright(true)
        self.fengjieBtn:setTouchEnabled(true)
        self.fengjieBtn:setVisible(true)
        self.qianghuaBtn:setBright(true)
        self.qianghuaBtn:setTouchEnabled(true)
        self.qianghuaBtn:setVisible(true)
        self.XLBtn:setBright(true)
        self.XLBtn:setTouchEnabled(true)
        self.XLBtn:setVisible(true)

        self.lockBtn:setVisible(true)
    end
    if runeNum<12 then
        for k=runeNum+1, 12 do
            table.insert(self.arrRuneBackpack, 0)
        end
    end
    self.runeTableView:reloadData()
end

-- 更新锁状态
function runePackage:updateLockState()
    local runeInfo = self.selectRuneData
    if runeInfo.lock==true then
        self.lockBtn:loadTextureNormal("rune_unlocked.png",me.localType)
        self.lockBtn:loadTexturePressed("rune_unlocked.png",me.localType)
    else
        self.lockBtn:loadTextureNormal("rune_locked.png",me.localType)
        self.lockBtn:loadTexturePressed("rune_locked.png",me.localType)
    end
end
-- 更新属性
function runePackage:updatePropertyList()
    self.runePropList:removeAllItems()


    local runeInfo = self.selectRuneData

    local runeBaseCfg = cfg[CfgType.RUNE_DATA][runeInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][runeInfo.glv]
    local extendRuneAttCfg = cfg[CfgType.RUNE_PROPERTY]

    if runeBaseCfg.type==99 then
        self.awakenBtn:setBright(false)
        self.XLBtn:setBright(false)
        self.qianghuaBtn:setBright(false)
        self.lockBtn:setVisible(false)
    else
        if runeInfo.star>=4 then
            self.awakenBtn:setBright(true)
        else
            self.awakenBtn:setBright(false)
        end
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][runeInfo.glv]
        if runeStrengthCfg.level<10 then
            self.XLBtn:setBright(false)
        else
            self.XLBtn:setBright(true)
        end
        self.qianghuaBtn:setBright(true)
        self.lockBtn:setVisible(true)
    end
    
    local addAtt = getRuneStrengthAttr(runeStrengthCfg, runeInfo.apt)

    --self.runeStrLv:setString("强化等级 " .. runeStrengthCfg.level)
    -- 基础属性
    local strengthCfgAtt = {}
    local strPropKV = runeStrengthCfg.property~=nil and string.split(runeStrengthCfg.property, ",") or {}
    local attrNode = me.assignWidget(self, "attrNode")
    local count=1
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = tonumber(arrKV[2])
        local attStr = cfg[CfgType.LORD_INFO][attKey].name .. ":+" .. (attValue*100).."%"
        local node = attrNode:clone():setVisible(true)
        me.assignWidget(node, "txt1"):setString(attStr)

        if addAtt[count] then
            local attStr1 = cfg[CfgType.LORD_INFO][addAtt[count].k].name .. ":+" .. addAtt[count].v..addAtt[count].unit
            me.assignWidget(node, "txt2"):setString(attStr1)
        end
        count = count+1
        self.runePropList:pushBackCustomItem(node)
    end

    local t = count
    for i=count, #addAtt  do
        local node = attrNode:clone():setVisible(true)
        local attStr1 = cfg[CfgType.LORD_INFO][addAtt[i].k].name .. ":+" .. addAtt[i].v..addAtt[i].unit
        me.assignWidget(node, "txt2"):setString(attStr1)
        self.runePropList:pushBackCustomItem(node)
        t = t+1
    end

    self.runePropList:jumpToTop()

    local arrow = me.assignWidget(self.panelRuneInfo, "arrow")
    arrow:stopAllActions()
    if t-1>4 then
        arrow:setVisible(true)
        me.clickAni(arrow)
    else
        arrow:setVisible(false)
    end
end