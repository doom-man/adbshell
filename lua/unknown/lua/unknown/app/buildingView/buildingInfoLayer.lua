
buildingInfoLayer = class("buildingInfoLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
buildingInfoLayer.__index = buildingInfoLayer
function buildingInfoLayer:create(...)
    local layer = buildingInfoLayer.new(...)
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
function buildingInfoLayer:ctor()
    self.leftTime = nil
    self.objData = nil
    self.buildTofId = nil
    self.maxWorker = 0
    self.titleWidth = { }
    self.Node_buildingState = me.assignWidget(self, "Node_buildingState")
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)

    end )
end

-- 设置正在升级/研究/制造等状态的数据
function buildingInfoLayer:setBuidingData(BuidData, objData_, buildTime_, buildTof_)
    self.leftTime = buildTime_
    self.objData = objData_
    self.buildTofId = buildTof_
    if self.leftTime == nil or self.objData == nil or self.buildTofId == nil then
        return
    end

    if self.objData and self.objData.state ~= BUILDINGSTATE_NORMAL.key then
        self.Node_buildingState:setVisible(true)
        local tmpStr = nil
        for key, var in pairs(BUILDINGSTATE_TOTAL) do
            if me.toNum(var.key) == self.objData.state then
                tmpStr = var.name
                break
            end
        end
        local tText_buildingTime = me.assignWidget(self, "Text_buildingTime")
        tText_buildingTime:setString(tmpStr .. "中" .. me.formartSecTime(self.leftTime))
        self.buildTime = me.registTimer(self.leftTime, function(dt, b)
            self.leftTime = self.leftTime - dt
            tText_buildingTime:setString(tmpStr .. "中" .. me.formartSecTime(self.leftTime))
            if b then
                self.Node_buildingState:setVisible(false)
            end
        end , 1)

        local bButton_cancel = me.registGuiClickEventByName(self, "Button_cancel", function()
            me.showMessageDialog("主人，你是否要取消" .. BuidData.name .. "的" .. tmpStr .. "?" .. "\n(取消后将会返回一部分资源)", function(args)
                if args == "ok" then
                    NetMan:send(_MSG.buildingCancel(self.buildTofId))
                    -- self:removeFromParentAndCleanup(true)
                    self:removeFromParentAndCleanup(true)
                end
            end )
        end )
    else
        self.Node_buildingState:setVisible(false)
    end
end

--  获取建筑物的数据 填充UI数据
function buildingInfoLayer:setBuidData(BuidData, state)
    if BuidData then
        self.maxWorker = BuidData.inmaxfarmer
        self.state = state
        local pBuidName = me.assignWidget(self, "name")
        pBuidName:setString(BuidData.name)
        -- 等级
        local pBuidLevel = me.assignWidget(self, "bLevel")
        if state == BUILDINGSTATE_LEVEUP.key then
            pBuidLevel:setString(BuidData.level - 1)
        else
            pBuidLevel:setString(BuidData.level)
        end
        local pbuidIcon = me.assignWidget(self, "bIcon")
        pbuidIcon:loadTexture(buildIcon(BuidData), me.plistType)    
        me.resizeImage(pbuidIcon,300,280)
        pbuidIcon:setPositionY(me.assignWidget(self, "back_Image_18"):getContentSize().height / 2)
        local pBuidIntroduction = me.assignWidget(self, "infoText")
        pBuidIntroduction:setString(BuidData.desc)
        self:initList(BuidData)
        self:setTilteUI(BuidData)
    end
    self.Node_buildingState:setVisible(false)
end
-- 获取标题
function buildingInfoLayer:getBuidTitle(BuidData)
    if (BuidData ~= nil) then
        local pBuidData = cfg[CfgType.CFG_BUILDING_INFO_TITLE]["" .. 1]
        local pBuidTitle = nil
        if pBuidData ~= nil then
            pBuidTitle = pBuidData[BuidData.type]["title"]
        end
        if pBuidTitle then
            local pTitleStr = me.split(pBuidTitle, ',')
            return pTitleStr
        end
    end
    return nil
end
-- 获取tableview的数据
function buildingInfoLayer:getBuidTitleData(BuidData)
    if BuidData ~= nil then
        local pBuidData = cfg[CfgType.BUILDING_INFO_CFG][BuidData.countryId][BuidData.type]
        return pBuidData
    end
    return nil
end
-- listview的数据填充 作废
function buildingInfoLayer:FillListVew(BuidData)
    if BuidData ~= nil then
        local pBuidInfoListView = me.assignWidget(self, "ListView_1")
        pBuidInfoListView:setScrollBarEnabled(false)

        local pBuidTileData = self:getBuidTitleData(BuidData)
        -- 建筑物详情数据
        local pBuidTitleStr = self:getBuidTitle(BuidData)
        -- 建筑物详情标题
        local pStandrd = pBuidInfoListView:getItem(0)

        local pSizeX = 10
        for key, var in pairs(pBuidTitleStr) do
            local pLabel = me.assignWidget(self, "bLevel"):clone()
            pLabel:setAnchorPoint(cc.p(0, 0.5))
            pLabel:setPosition(cc.p(pSizeX, pStandrd:getContentSize().height / 2))
            pLabel:setString(var)
            pLabel:setTag(key)
            pStandrd:addChild(pLabel)

            pSizeX = pSizeX + pLabel:getContentSize().width + 10
        end

        for key, var in pairs(pBuidTileData) do
            local pTitleData = me.split(var, ',')
            local pStandrdEach = pBuidInfoListView:getItem(0):clone()
            for key, var in pairs(pTitleData) do
                local pLabel = pStandrdEach:getChildByTag(key)
                local Var = me.toNum(var)
                if Var > 1000 then
                    Var = math.ceil(Var / 1000)
                    pLabel:setString(Var .. "K")
                else

                    pLabel:setString(Var .. "")
                end

            end
            pBuidInfoListView:setItemModel(pStandrdEach)
            pBuidInfoListView:pushBackDefaultItem()
        end
    end
end
function buildingInfoLayer:setLabelWidth(pBuidTileData, pBuidTitleStr)
    self.One = 0
    self.Two = 0
    self.Three = 0
    self.Four = 0
    self.Five = 0
    self.Six = 0
    self.Seven = 0
    local pMaxWidth = 0
    if pBuidTitleStr ~= nil then


        for key, var in pairs(pBuidTitleStr) do
            local pMaxWidth = self:getDataWidth(key, pBuidTileData, pBuidTitleStr)
            local pLabel = me.assignWidget(self, "Text_4"):clone()
            pLabel:setVisible(true)
            pLabel:setString(var)
            if pLabel:getContentSize().width > pMaxWidth then
                pMaxWidth = pLabel:getContentSize().width
            end
            if key == 1 then
                self.One = pMaxWidth
            elseif key == 2 then
                self.Two = pMaxWidth  
            elseif key == 3 then
                self.Three = pMaxWidth
            elseif key == 4 then
                self.Four = pMaxWidth
            elseif key == 5 then
                self.Five = pMaxWidth
            elseif key == 6 then
                self.Six = pMaxWidth
            elseif key == 7 then
                self.Seven = pMaxWidth
            end
        end
    end
end
function buildingInfoLayer:getDataWidth(pKey, pBuidTileData, pBuidTitleStr)
    local pMaxWidth = 0;
    for key, var in pairs(pBuidTileData) do
        local pTitleData = me.split(pBuidTileData[key], ',')
        local Var = pTitleData[pKey]
        local pLabel = me.assignWidget(self, "Text_4"):clone()
        pLabel:setVisible(true)
        pLabel:setString(Var)
        if pLabel:getContentSize().width > pMaxWidth then
            pMaxWidth = pLabel:getContentSize().width
        end
    end
    return pMaxWidth
end

function buildingInfoLayer:getLabelWidth(key)
    local pMaxWidth = 0
    if key == 1 then
        pMaxWidth = self.One
    elseif key == 2 then
        pMaxWidth = self.Two
    elseif key == 3 then
        pMaxWidth = self.Three
    elseif key == 4 then
        pMaxWidth = self.Four
    elseif key == 5 then
        pMaxWidth = self.Five
    elseif key == 6 then
        pMaxWidth = self.Six
    elseif key == 7 then
        pMaxWidth = self.Seven
    end
    return pMaxWidth
end
function buildingInfoLayer:setTilteUI(BuidData)

    local pBuidTitleStr = self:getBuidTitle(BuidData)
    local pLabelSpace = 15
    -- 属性的间隔
    local pNode = cc.Node:create()
    pNode:setContentSize(cc.size(812, 66))
    pNode:setAnchorPoint(cc.p(0, 0))
    pNode:setPosition(cc.p(0, 523))
    me.assignWidget(self, "boxright"):addChild(pNode)
    local pImageViewStr = "default.png"
    local selectImg = ccui.ImageView:create()
    selectImg:setAnchorPoint(cc.p(0, 0))
    selectImg:loadTexture(pImageViewStr, me.localType)
    selectImg:setPosition(cc.p(-1, 0))
    selectImg:setContentSize(cc.size(816, 66))
    selectImg:ignoreContentAdaptWithSize(false)
    selectImg:setTag(134)
    pNode:addChild(selectImg)
    local pSizeX = 45
    local ofy = 10
    if pBuidTitleStr ~= nil then
        for key, var in pairs(pBuidTitleStr) do
            local pLabel = me.assignWidget(self, "Text_4"):clone()
            pLabel:setVisible(true)
            pLabel:setTextColor(me.convert3Color_("d0c797"))
            self.titleWidth[key] = pLabel:getContentSize().width
            pLabel:setString(var)
            local pLableWith = self:getLabelWidth(key) / 2
            if key == 1 then
                pLabel:setAnchorPoint(cc.p(0.5, 0.5))
                pLabel:setPosition(cc.p(pSizeX + pLableWith, pNode:getContentSize().height / 2+ofy))
            else
                pLabel:setAnchorPoint(cc.p(0.5, 0.5))
                pLabel:setPosition(cc.p(pSizeX + pLableWith, pNode:getContentSize().height / 2+ofy))
            end
            if key >= 2 then
                pSizeX = pSizeX + self:getLabelWidth(key) + pLabelSpace + 25
            else
                pSizeX = pSizeX + self:getLabelWidth(key) + pLabelSpace + 15
            end
            pNode:addChild(pLabel)
        end
    end
end
-- tableViews数据填充
function buildingInfoLayer:initList(BuidData)

    local pBuidTileData = self:getBuidTitleData(BuidData)
    --   dump(pBuidTileData)
    -- 建筑物详情数据
    local pBuidTitleStr = self:getBuidTitle(BuidData)
    -- 建筑物详情标题
    self:setLabelWidth(pBuidTileData, pBuidTitleStr)
    local iNum = #pBuidTileData
    local pLabelSpace = 15
    -- 属性的间隔
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 810, 51
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local pRemainder = idx % 2
        local pImageViewStr = "ui_jz_buildinfo_cell_bg_03.png"
        -- if pRemainder == 1 then
        --    pImageViewStr = "zhucheng_beijng_huadong_3.png"
        -- end
        local pLevel = 0
        if self.state and self.state == BUILDINGSTATE_LEVEUP.key then
            pLevel = 1
        else

        end
        if (idx + 1) ~= 0 and (idx + 1) ==(BuidData.level - pLevel) then
            pRemainder = 1
            pImageViewStr = "ui_jz_buildinfo_cell_bg_01.png"
        end
        local label = nil
        local selectImg = nil
        local firstLabel = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pNode = cc.Node:create()
            pNode:setContentSize(cc.size(780, 47))
            pNode:setAnchorPoint(cc.p(0, 0.5))
            pNode:setPosition(cc.p(0, 27))
            pNode:setTag(133)
            selectImg = ccui.ImageView:create()
            selectImg:setAnchorPoint(cc.p(0, 0))
            selectImg:loadTexture(pImageViewStr, me.localType)
            selectImg:ignoreContentAdaptWithSize(false)
            selectImg:setContentSize(cc.size(780,51))
            selectImg:setPosition(cc.p(0, 0))
            selectImg:setTag(134)
            cell:addChild(selectImg)
            cell:addChild(pNode)
            local pSizeX = 20
            local pTitleData = self:getStr(pBuidTileData[idx + 1], ',')
            if pBuidTitleStr ~= nil then
                for key, var in pairs(pBuidTitleStr) do
                    local pLabel = me.assignWidget(self, "Text_4"):clone()
                    pLabel:setVisible(true)
                    pLabel:setTextColor(cc.c3b(32, 16, 0))
                    local pLableWith = self:getLabelWidth(key) / 2
                    if key == 1 then
                        pLabel:setAnchorPoint(cc.p(0.5, 0.5))
                        pLabel:setPosition(cc.p(pSizeX + pLableWith, pNode:getContentSize().height / 2))
                        firstLabel = pLabel
                    else
                        pLabel:setAnchorPoint(cc.p(0.5, 0.5))
                        pLabel:setPosition(cc.p(pSizeX + pLableWith, pNode:getContentSize().height / 2))
                    end
                    pLabel:setTag(key)
                    pNode:addChild(pLabel)
                    if key >= 2 then
                        pSizeX = pSizeX + self:getLabelWidth(key) + pLabelSpace + 25
                    else
                        pSizeX = pSizeX + self:getLabelWidth(key) + pLabelSpace + 15
                    end
                    local Var = pTitleData[key]
                    local pVarNum = me.toNum(Var)

                    if pVarNum ~= nil then
                        local pLen = string.len(Var)
                        local pVarStr = string.sub(Var, pLen - 2, pLen)
                        if pVarNum > 999 then
                            pVarNum = math.floor(pVarNum / 1000)
                            pLabel:setString(pVarNum .. "," .. pVarStr)
                        else
                            pLabel:setString(pVarNum .. "")
                        end
                    else
                        pLabel:setString(Var)
                    end
                end
            end
        else
            local pNode = cell:getChildByTag(133)
            selectImg = cell:getChildByTag(134)
            selectImg:loadTexture(pImageViewStr, me.localType)
            local pSizeX = 20
            local pTitleData = self:getStr(pBuidTileData[idx + 1], ',')
            if pBuidTitleStr ~= nil then
                for key, var in pairs(pBuidTitleStr) do
                    local pLabel = pNode:getChildByTag(key)
                    local Var = pTitleData[key]
                    local pVarNum = me.toNum(Var)
                    if pVarNum ~= nil then
                        local pLen = string.len(Var)
                        local pVarStr = string.sub(Var, pLen - 2, pLen)
                        if pVarNum > 999 then
                            pVarNum = math.floor(pVarNum / 1000)
                            pLabel:setString(pVarNum .. "," .. pVarStr)
                        else
                            pLabel:setString(pVarNum .. "")
                        end
                    else
                        pLabel:setString(Var)
                    end
                    if key == 1 then
                        firstLabel = pLabel
                    end
                end
            end
        end
        selectImg:setVisible(true)
        if pRemainder == 0 then
            selectImg:setVisible(false)
        end

        -- 显示选中行的圈圈
        if firstLabel ~= nil then
            local pQuan = firstLabel:getParent():getChildByTag(1330)
            if pQuan ~= nil then
                pQuan:setVisible(false)
            end
            if pImageViewStr == "ui_jz_buildinfo_cell_bg_01.png" then
                if pQuan == nil then
                    pQuan = me.assignWidget(self,"Image_select"):clone()                   
                    pQuan:setTag(1330)                  
                    firstLabel:getParent():addChild(pQuan)
                end
                pQuan:setVisible(true)  
                pQuan:setPosition(390,21)                 
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end
    local tableView = cc.TableView:create(cc.size(794, 486))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(26, 41)
    tableView:setDelegate()
    me.assignWidget(self, "boxright"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    --    --
end
 
function buildingInfoLayer:init()
    return true
end
function buildingInfoLayer:onEnter()
    print("buildingInfoLayer:onEnter()")
    me.doLayout(self, me.winSize)
end
function buildingInfoLayer:onExit()
    print("buildingInfoLayer:onExit()")
    me.clearTimer(self.buildTime)
end
function buildingInfoLayer:getStr(str, split_char)
    if str == nil or split_char == nil then
        print("split str is nil or key is nil")
        return nil
    end
    local res = { }
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            if string.len(str) > 0 then
                table.insert(res, str)
            end
            break;
        end
        local splitLen = string.len(split_char)
        if pos - 1 > 0 then
            local sub_str = string.sub(str, 1, pos - 1);
            table.insert(res, sub_str);
            local t = string.len(str);
            str = string.sub(str, pos + splitLen, t);

        elseif pos == 1 then
            table.insert(res, "");
            local t = string.len(str);
            str = string.sub(str, pos + 1, t);

        else
            break
        end
    end
    return res;
end

function buildingInfoLayer:setResData(bType, resInfo, curWorker)
    local str = ""
    if bType == "food" then
        str = "已生产粮食:"
    elseif bType == "lumber" then
        str = "已生产木材:"
    elseif bType == "stone" then
        str = "已生产石材:"
    end
    local resNum = resInfo
    if not resNum then
        resNum = 0
    end
    local resText = ccui.Text:create(str .. resNum, "", 20)
    resText:setTextColor(cc.c3b(255, 230, 207))
    resText:setAnchorPoint(0.5, 0)
    resText:setPosition(cc.p(178, 20))
    resText:enableShadow(cc.c4b(0,0,0,255),cc.size(-1,-1))
    local bg = me.assignWidget(self, "back_Image_18")
    bg:addChild(resText)

    if curWorker then
        local bg = me.assignWidget(self,"Image_food_info"):setVisible(true)
        local t1 = ccui.Text:create("工人:" .. curWorker .. "/" .. self.maxWorker, "", 20)
        local t2 = ccui.Text:create("工人越多产量加成越多", "", 20)
        t1:enableShadow(cc.c4b(0,0,0,255),cc.size(-1,-1))
        t2:enableShadow(cc.c4b(0,0,0,255),cc.size(-1,-1))
        t1:setAnchorPoint(cc.p(0.5, 1))
        t2:setAnchorPoint(cc.p(0.5, 1))
        t1:setPosition(cc.p(140, bg:getContentSize().height - 8))
        t2:setPosition(cc.p(140, t1:getPositionY() - t1:getContentSize().height - 3))
        t1:setTextColor(cc.c3b(255, 230, 207))
        t2:setTextColor(cc.c3b(255, 230, 207))
        bg:addChild(t1,me.MAXZORDER)
        bg:addChild(t2,me.MAXZORDER)
    end
end