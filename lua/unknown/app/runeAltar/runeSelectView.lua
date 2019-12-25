runeSelectView = class("runeSelectView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)

local filterTbl={btn_quality_iorder="品质倒序",
                 btn_quality_rorder="品质顺序",
                 btn_level_iorder="等级倒序",
                 btn_level_rorder="等级顺序",
                 btn_star_iorder="星级倒序",
                 btn_star_rorder="星级顺序",
                 }

function runeSelectView:create(...)
    local layer = runeSelectView.new(...)
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

function runeSelectView:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
    self.arrRuneBackpack = {}
end

function runeSelectView:onEnter()
    if self.btnSelect then
         guideHelper.nextStepByOpt(false,self.btnSelect)
    end
end

function runeSelectView:onEnterTransitionDidFinish()
end

function runeSelectView:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeSelectView:init()
    print("runeSelectView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    self.panelRuneInfo = me.assignWidget(self, "Panel_runeInfo")

    self.currentItem = runeItem:create("rune/runeItem.csb")
    self.currentItem:setPosition(70, 271.49)
    self.currentItem:setScale(0.9)
    self.panelRuneInfo:addChild(self.currentItem)

    self.infoGray = me.assignWidget(self.panelRuneInfo, "infoGray")
    
    self.runeStrLv = me.assignWidget(self, "Text_set_name")
    self.runeExtend = me.assignWidget(self, "Text_str_name")

    -- 符文属性列表
    self.runePropList = me.assignWidget(self, "list_property")
    self.runePropList:setScrollBarEnabled (false)
    
    self.lockBtn = me.assignWidget(self, "lockBtn")
    self.lockBtn:addClickEventListener(handler(self, self.changeLockState))

    self.arrRuneBackpack={}
    self:initRuneTable()

    self.nowCate = 0
    
    
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


    -- 选择
    local function selectRuneCallback (sender)
        if self.selectRuneData and self.runeSelecCallback then
            if self.from=='compose' and self.selectRuneData.lock==true then
                showTips("圣物锁定不能被合成")
                return
            end
            self.runeSelecCallback(self.selectRuneData)
        end

        self:removeFromParentAndCleanup(true)
    end
    self.btnSelect = me.assignWidget(self, "btn_select")
    self.btnSelect:addClickEventListener(selectRuneCallback)

    local btns = {"cateAllBtn", "cate1Btn", "cate2Btn", "cate3Btn", "cate4Btn", "cate5Btn", "cate6Btn"}
    local function selectRuneCate (sender)
        self.nowCate = sender:getTag()
        for key, var in pairs(btns) do
            if var ~= sender:getName() then
                me.assignWidget(self, var):loadTextureNormal("rune_catebox.png",me.localType)
            else        
                me.assignWidget(self, var):loadTextureNormal("rune_catebox_select.png",me.localType)
            end
        end

        self.selectRune=nil
        self.selectRuneData=nil

        self:initRuneList()
    end
    for key, var in pairs(btns) do
        me.assignWidget(self, var):addClickEventListener(selectRuneCate)
    end
    me.assignWidget(self, "cateAllBtn"):loadTextureNormal("rune_catebox_select.png",me.localType)
    self.selectRune = nil
    self.selectRuneData=nil


    

    return true
end


---
-- 圣器解锁或锁定
--
function runeSelectView:changeLockState()
    NetMan:send(_MSG.Rune_lock(self.selectRuneData.id))
    showWaitLayer ()
end

function runeSelectView:initRuneTable()
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
      
        return 658, 228
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        if nil == cell then
            cell = cc.TableViewCell:new()
            
            for  var = 1,4 do
                local pTag = idx*4+var
                if self.arrRuneBackpack[pTag] and self.arrRuneBackpack[pTag]~=0 then
                    local leftCell = runeItem:create(me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true), 1) 
                    leftCell:setScale(0.5) 
                    leftCell:setName('normal'..var)  
                    me.registGuiClickEvent(leftCell, handler(self, self.onClickRune)) 
                    leftCell:setSwallowTouches(false)
                    leftCell:setPosition(cc.p((var-1)*163+4,0))     
                    leftCell:setData(self.arrRuneBackpack[pTag])
                    cell:addChild(leftCell)

                    self:fillCellData(leftCell, self.arrRuneBackpack[pTag])
                    if pTag==1 and self.selectRune==nil then
                        self:onClickRune(leftCell)
                    end
                else
                    local leftCell = me.assignWidget(self,"RuneGray"):clone():setVisible(true)  
                    leftCell:setName('gray'..var)  
                    leftCell:setPosition(cc.p((var-1)*166+6,10))     
                    cell:addChild(leftCell)
                end
             end
        else
            for  var = 1, 4  do
                local pTag = idx*4+var
                if self.arrRuneBackpack[pTag] and self.arrRuneBackpack[pTag]~=0 then
                    local leftCell = cell:getChildByName('normal'..var)
                    if leftCell~=nil then
                        leftCell:setData(self.arrRuneBackpack[pTag])
                    else
                        leftCell = runeItem:create(me.assignWidget(me.assignWidget(self,"RuneItem"), "Panel"):clone():setVisible(true), 1)  
                        leftCell:setScale(0.5) 
                        leftCell:setName('normal'..var)  
                        me.registGuiClickEvent(leftCell, handler(self, self.onClickRune)) 
                        leftCell:setSwallowTouches(false)
                        leftCell:setPosition(cc.p((var-1)*163+4,0))     
                        leftCell:setData(self.arrRuneBackpack[pTag])
                        cell:addChild(leftCell)
                    end
                    self:fillCellData(leftCell, self.arrRuneBackpack[pTag])
                    if pTag==1 and self.selectRune==nil then
                        self:onClickRune(leftCell)
                    end
                    cell:removeChildByName('gray'..var)
                else
                    local leftCell = cell:getChildByName('gray'..var)
                    if leftCell==nil then
                        leftCell = me.assignWidget(self,"RuneGray"):clone():setVisible(true)  
                        leftCell:setName('gray'..var)  
                        leftCell:setPosition(cc.p((var-1)*166+6,10))     
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

    local tableView = cc.TableView:create(cc.size(658, 596))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "tbl_node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end
function runeSelectView:fillCellData(leftCell, data)
    leftCell:unSelect()
    if self.selectRuneData ~= nil and self.selectRuneData.id==data.id then
        self.selectRune=leftCell
        self.selectRune:select()
    end
end

function runeSelectView:onClickRune(node)
    if self.selectRune ~= nil then
        self.selectRune:unSelect()
    end
    self.selectRune=node
    self.selectRuneData=self.selectRune.data
    self.selectRune:select()
    self.currentItem:setData(self.selectRune.data)

    self:updateLockState()
    self:updatePropertyList()
end
function runeSelectView:setRuneBagData(arrRuneBackpack, from)
    self.arrRuneBackpackSrc = arrRuneBackpack

    self.from=from
    self.selectRune=nil
    self.selectRuneData=nil
    self:initRuneList ()
end

-- 设置可用圣物数据
function runeSelectView:setPvpRuneData(list)
    self:setRuneBagData(list)
    self.lockBtn:setVisible(false)
end

function runeSelectView:initRuneList()
    self.arrRuneBackpack={}
    for _, v in ipairs(self.arrRuneBackpackSrc) do
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
    else
        self.infoGray:setVisible(false)
        self.currentItem:setVisible(true)
    end
    if runeNum<12 then
        for k=runeNum+1, 12 do
            table.insert(self.arrRuneBackpack, 0)
        end
    end
    self.runeTableView:reloadData()
end

function runeSelectView:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_UPDATE) or
        checkMsg(msg.t, MsgCode.RUNE_REMOVE) or checkMsg(msg.t, MsgCode.RUNE_INFO) then
        for _, v in ipairs(msg.c.list) do
            for _, v1 in ipairs(self.arrRuneBackpackSrc) do
                if v.id==v1.id then
                    v1.lock=v.lock
                end
            end
        end

        --更新背包列表
        local offset=self.runeTableView:getContentOffset()
        self:initRuneList()
        self.runeTableView:setContentOffset(offset)

        self:onClickRune(self.selectRune)

        disWaitLayer()
    end
end

-- 更新锁状态
function runeSelectView:updateLockState()
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
function runeSelectView:updatePropertyList()
    self.runePropList:removeAllItems()


    local runeInfo = self.selectRuneData
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][runeInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][runeInfo.glv]
    local extendRuneAttCfg = cfg[CfgType.RUNE_PROPERTY]
    
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

    local arrow = me.assignWidget(self.panelRuneInfo, "arrow")
    arrow:stopAllActions()
    if t-1>4 then
        arrow:setVisible(true)
        me.clickAni(arrow)
    else
        arrow:setVisible(false)
    end
end

function runeSelectView:registerSelecCallback(selecCallback)
    self.runeSelecCallback = selecCallback
end
