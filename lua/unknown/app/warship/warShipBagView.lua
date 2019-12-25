-- [Comment]
-- jnmo
warShipBagView = class("warShipBagView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warShipBagView.__index = warShipBagView
function warShipBagView:create(...)
    local layer = warShipBagView.new(...)
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
function warShipBagView:ctor()
    print("warShipBagView ctor")
end
local boxnum = 5
function warShipBagView:init()
    print("warShipBagView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.pCheckBox = { }
    self.bagKind = 1
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            if self.bagKind ~= sender.id then
                if sender.id == 5 then
                    me.assignWidget(self, "bg_left_0"):setVisible(true)
                    me.assignWidget(self, "bg_left"):setVisible(false)
                    self:metaBagUpdata()
                    self.bagKind = 0
                else
                    me.assignWidget(self, "bg_left_0"):setVisible(false)
                    me.assignWidget(self, "bg_left"):setVisible(true)
                    self.bagKind = sender.id
                    self:bagUpdata()
                end
                for var = 1, boxnum do
                    if var == sender.id then
                        self.pCheckBox[var]:setSelected(true)
                        self.pCheckBox[var]:setTouchEnabled(false)
                    else
                        self.pCheckBox[var]:setSelected(false)
                        self.pCheckBox[var]:setTouchEnabled(true)
                    end
                end
            end
        end
    end
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        if self.bagKind == self.pCheckBox[var].id then
            self.pCheckBox[var]:setSelected(true)
            self.pCheckBox[var]:setTouchEnabled(false)
        else
            self.pCheckBox[var]:setSelected(false)
            self.pCheckBox[var]:setTouchEnabled(true)
        end
    end
    return true
end
local tableheight = 500
function warShipBagView:bagUpdata()
    me.tableClear(self.pTable)
    self.pTable = { }
    local pUse = user.shipRefixBagData
    for key, var in pairs(pUse) do
        local pCfgData = cfg[CfgType.SHIP_REFIX_SKILL][var.defid]
        if pCfgData.type == self.bagKind then
            if var.location == 0 then
                table.insert(self.pTable, var)
            else
                table.insert(self.pTable, 1, var)
            end
        end
    end
    self.iNum = math.floor((#self.pTable) / 4)
    if #self.pTable % 4 ~= 0 then
        self.iNum = self.iNum + 1
    end
    self.iNum = math.max(self.iNum, 4)
    self:initList()
    local pOffest = self.tableView:getContentOffset()
    self.tableView:reloadData()
    -- 判断是否还有选中的道具
    if self.mData ~= nil and #self.pTable > 1 then
        local pHaveBool = false
        for key, var in ipairs(self.pTable) do
            if self.mData.id == var.id then
                self.pTagNum = key
                pHaveBool = true
                break
            else
                pHaveBool = false
            end
        end
        if pHaveBool == true then
            local size = self.tableView:getContentSize()
            if size.height < tableheight then
                pOffest.y = tableheight - size.height
            elseif pOffest.y > 0 then
                pOffest.y = 0
            end
            self.tableView:setContentOffset(pOffest)
            self.selectImg:setVisible(true)
            local pos = cc.p(self:getCellPoint(self.pTagNum, self.iNum))
            self.selectImg:setPosition(pos)
        else
            local ptag = -1
            if self.pTagNum then
                local pt = self.pTagNum
                if self.pTable[pt] == nil then
                    pt = self.pTagNum - 1
                    if self.pTable[pt] ~= nil then
                        ptag = pt
                    end
                else
                    ptag = pt
                end
            end
            if ptag ~= -1 then
                self:setRightUI(ptag)
                -- 判断背包是否为空
                local pos = cc.p(self:getCellPoint(ptag, self.iNum))
                self.selectImg:setPosition(pos)
                local size = self.tableView:getContentSize()
                if pOffest.y + pos.y < 170 or pos.y + pOffest.y > size.height then
                    local curRow = math.ceil(ptag / 4)
                    if curRow < 4 then
                        pOffest.y = tableheight - size.height
                    else
                        pOffest.y = pOffest.y + 170
                    end
                end
                if size.height < tableheight then
                    pOffest.y = tableheight - size.height
                elseif pOffest.y > 0 then
                    pOffest.y = 0
                end
                self.tableView:setContentOffset(pOffest)
            else
                self:setRightUI(1)
                -- 判断背包是否为空
                self.selectImg:setPosition(cc.p(self:getCellPoint(1, self.iNum)))
            end

            self.selectImg:setVisible(true)
        end
    else
        if #self.pTable > 0 then
            self:setRightUI(1)
            -- 判断背包是否为空
            self.selectImg:setPosition(cc.p(self:getCellPoint(1, self.iNum)))
            self.selectImg:setVisible(true)
        else
            self.selectImg:setVisible(false)
            self:setRightUI(nil)
        end
    end
end
function warShipBagView:metaBagUpdata()
    me.tableClear(self.metapTable)
    self.metapTable = { }
    local pUse = user.metaRefitBackpack
    for key, var in pairs(pUse) do   
       table.insert(self.metapTable, var)         
    end
    local function comp(a,b)
     return a.defid > b.defid
    end
    table.sort(self.metapTable,comp)
    self.metaiNum = math.floor((#self.metapTable) / 4)
    if #self.metapTable % 4 ~= 0 then
        self.metaiNum = self.metaiNum + 1
    end
    self.metaiNum = math.max(self.metaiNum, 4)
    self:initmeatList()
    local pOffest = self.metatableView:getContentOffset()
    self.metatableView:reloadData()
    -- 判断是否还有选中的道具
    if self.metaData ~= nil and #self.metapTable > 1 then
        local pHaveBool = false
        for key, var in ipairs(self.metapTable) do
            if self.metaData.id == var.id then
                self.metapTagNum = key
                pHaveBool = true
                break
            else
                pHaveBool = false
            end
        end
        if pHaveBool == true then
            local size = self.metatableView:getContentSize()
            if size.height < tableheight then
                pOffest.y = tableheight - size.height
            elseif pOffest.y > 0 then
                pOffest.y = 0
            end
            self.metatableView:setContentOffset(pOffest)
            self.metaselectImg:setVisible(true)
            local pos = cc.p(self:getCellPoint(self.metapTagNum, self.metaiNum))
            self.metaselectImg:setPosition(pos)
        else
            local ptag = -1
            if self.metapTagNum then
                local pt = self.metapTagNum
                if self.metapTable[pt] == nil then
                    pt = self.metapTagNum - 1
                    if self.metapTable[pt] ~= nil then
                        ptag = pt
                    end
                else
                    ptag = pt
                end
            end
            if ptag ~= -1 then
                self:setmetaRightUI(ptag)
                -- 判断背包是否为空
                local pos = cc.p(self:getCellPoint(ptag, self.metaiNum))
                self.metaselectImg:setPosition(pos)
                local size = self.metatableView:getContentSize()
                if pOffest.y + pos.y < 170 or pos.y + pOffest.y > size.height then
                    local curRow = math.ceil(ptag / 4)
                    if curRow < 4 then
                        pOffest.y = tableheight - size.height
                    else
                        pOffest.y = pOffest.y + 170
                    end
                end
                if size.height < tableheight then
                    pOffest.y = tableheight - size.height
                elseif pOffest.y > 0 then
                    pOffest.y = 0
                end
                self.metatableView:setContentOffset(pOffest)
            else
                self:setmetaRightUI(1)
                -- 判断背包是否为空
                self.metaselectImg:setPosition(cc.p(self:getCellPoint(1, self.metaiNum)))
            end

            self.metaselectImg:setVisible(true)
        end
    else
        if #self.metapTable > 0 then
            self:setmetaRightUI(1)
            -- 判断背包是否为空
            self.metaselectImg:setPosition(cc.p(self:getCellPoint(1, self.metaiNum)))
            self.metaselectImg:setVisible(true)
        else
            self.metaselectImg:setVisible(false)
            self:setmetaRightUI(nil)
        end
    end
end
function warShipBagView:initList()

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        --    table:onTouchBegan()

    end

    local function cellSizeForTable(table, idx)
        return 640, 166
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local pDataNum = #self.pTable
        local pCellNum = #self.pTable
        pCellNum = math.max(pCellNum, 16)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local pBackpackCell = warShipBagCell:create(me.createNode("Node_Refit_Item.csb"), "Image_itemBg")
                pBackpackCell:setTag(var)
                local buildBtn = me.assignWidget(pBackpackCell, "icon")
                buildBtn:setTag(123)
                buildBtn.tagid = pTag
                pBackpackCell:setPosition(cc.p((var - 1) * 165 + 76, 76))
                me.registGuiClickEvent(buildBtn, function(node)
                    local pTouch = node:getTouchBeganPosition()
                    local pNode = me.assignWidget(self, "bg_left")
                    local pTag = me.toNum(node.tagid)
                    local pPoint = self:contains(pNode, pTouch.x, pTouch.y)
                    if pPoint then
                        -- 点击在tableview中
                        local pDataCount = #self.pTable
                        if pTag <(pDataCount + 1) then
                            self.selectImg:setPosition(cc.p(self:getCellPoint(node.tagid, self.iNum)))
                            self.selectImg:setVisible(true)
                            self:setRightUI(pTag)
                        end
                    else
                        -- 点击在tableview外
                    end
                end )
                if pTag <(pCellNum + 1) then
                    pBackpackCell:setVisible(true)
                    if pTag <(pDataNum + 1) then
                        pBackpackCell:setUI(self.pTable[pTag])
                    else
                        pBackpackCell:setUI(nil)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                buildBtn:setSwallowTouches(false)
                buildBtn:setTouchEnabled(true)
                cell:addChild(pBackpackCell)
            end
        else
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local pBackpackCell = cell:getChildByTag(var)
                if pTag <(pCellNum + 1) then
                    pBackpackCell:setVisible(true)
                    if pTag <(pDataNum + 1) then
                        pBackpackCell:setUI(self.pTable[pTag])
                    else
                        pBackpackCell:setUI(nil)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                local p1 = pBackpackCell:getChildByTag(123)
                p1.tagid = pTag
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return self.iNum
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(655, tableheight))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(24, 5)
        --  tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        me.assignWidget(self, "bg_left"):addChild(self.tableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
    if self.selectImg == nil then
        self.selectImg = ccui.ImageView:create()
        self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
        self.selectImg:setPosition(cc.p(self:getCellPoint(1, self.iNum)))
        self.selectImg:setLocalZOrder(10)
        self.tableView:addChild(self.selectImg)
    end
    if #self.pTable > 0 then
        self:setRightUI(1)
        -- 判断背包是否为空
        self.selectImg:setVisible(true)
    else
        self.selectImg:setVisible(false)
        self:setRightUI(nil)
    end
end
function warShipBagView:initmeatList()

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        --    table:onTouchBegan()

    end

    local function cellSizeForTable(table, idx)
        return 640, 166
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local pDataNum = #self.metapTable
        local pCellNum = #self.metapTable
        pCellNum = math.max(pCellNum, 16)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local pBackpackCell = BackpackCell:create("backpack/backpackcell.csb")
                pBackpackCell:setTag(var)
                pBackpackCell:setTag(var)
                local buildBtn = me.assignWidget(pBackpackCell, "Button_bg")
                buildBtn:setTag(123)
                buildBtn.tagid = pTag
                pBackpackCell:setPosition(cc.p((var - 1) * 165 - 3 , -3))
                me.registGuiClickEvent(buildBtn, function(node)
                    local pTouch = node:getTouchBeganPosition()
                    local pNode = me.assignWidget(self, "bg_left_0")
                    local pTag = me.toNum(node.tagid)
                    local pPoint = self:contains(pNode, pTouch.x, pTouch.y)
                    if pPoint then
                        -- 点击在tableview中
                        local pDataCount = #self.metapTable
                        if pTag <(pDataCount + 1) then
                            self.metaselectImg:setPosition(cc.p(self:getCellPoint(node.tagid, self.metaiNum)))
                            self.metaselectImg:setVisible(true)
                            self:setmetaRightUI(pTag)
                        end
                    else
                        -- 点击在tableview外
                    end
                end )
                if pTag <(pCellNum + 1) then
                    pBackpackCell:setVisible(true)
                    if pTag <(pDataNum + 1) then
                        pBackpackCell:setUI(self.metapTable[pTag])
                    else
                        pBackpackCell:setUI(nil)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                buildBtn:setSwallowTouches(false)
                buildBtn:setTouchEnabled(true)
                cell:addChild(pBackpackCell)
            end
        else
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local pBackpackCell = cell:getChildByTag(var)
                if pTag <(pCellNum + 1) then
                    pBackpackCell:setVisible(true)
                    if pTag <(pDataNum + 1) then
                        pBackpackCell:setUI(self.metapTable[pTag])
                    else
                        pBackpackCell:setUI(nil)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                local p1 = pBackpackCell:getChildByTag(123)
                p1.tagid = pTag
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return self.metaiNum
    end
    if self.metatableView == nil then
        self.metatableView = cc.TableView:create(cc.size(655, tableheight))
        self.metatableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.metatableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.metatableView:setPosition(24, 5)
        self.metatableView:setDelegate()
        me.assignWidget(self, "bg_left_0"):addChild(self.metatableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        self.metatableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.metatableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.metatableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.metatableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.metatableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.metatableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.metatableView:reloadData()
    if self.metaselectImg == nil then
        self.metaselectImg = ccui.ImageView:create()
        self.metaselectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
        self.metaselectImg:setPosition(cc.p(self:getCellPoint(1, self.metaiNum)))
        self.metaselectImg:setLocalZOrder(10)
        self.metatableView:addChild(self.metaselectImg)
    end
    if #self.metapTable > 0 then
        self:setmetaRightUI(1)
        -- 判断背包是否为空
        self.metaselectImg:setVisible(true)
    else
        self.metaselectImg:setVisible(false)
        self:setmetaRightUI(nil)
    end
end
-- 判断是否点击在节点中
function warShipBagView:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end
-- 返回选中格子的坐标，参数：第几个格子，table的个数
function warShipBagView:getCellPoint(pTag, TableNum)
    pTag = me.toNum(pTag)
    self.pCellId = pTag
    local pRow = math.floor((pTag - 1) / 4)
    -- 行数
    local pLine = pTag % 4
    -- 列数
    if pLine == 0 then
        pLine = 4
    end
    local pPointX = pLine * 165 - 89
    local pPointY =(TableNum - pRow) * 166 - 90
    return pPointX, pPointY
end
function warShipBagView:setRightUI(pTag)
    if pTag ~= nil then
        self.pTagNum = me.toNum(pTag)
        local pData = self.pTable[me.toNum(pTag)]
        self.mData = pData

        local pCfgid = pData["defid"]
        -- 道具的配置Id
        local pCfgData = cfg[CfgType.SHIP_REFIX_SKILL][pCfgid]
        local pName = me.assignWidget(self, "article_name")
        pName:setVisible(true)
        pName:setString(pCfgData["name"])
        local pIntroduce = me.assignWidget(self, "article_Introduction")
        -- 道具介绍
        pIntroduce:setVisible(true)
        pIntroduce:setString(pCfgData.desc)
        local pIcon = me.assignWidget(self, "Goods_Icon1")
        -- 图标
        pIcon:loadTexture(getRefitIcon(pCfgid), me.localType)
        pIcon:setVisible(true)
        local pIsUse = tonumber(pData["location"])
        self.Button_dec = me.registGuiClickEventByName(self, "Button_dec", function(node)
            local bk = warshipBreakView:create("shipBreakView.csb")
            bk:initWithData(pData)
            me.popLayer(bk)
        end )
        self.Button_auto_dec = me.registGuiClickEventByName(self, "Button_auto_dec", function(node)
            local abk = warshipAutoBreakView:create("shipBreakAutoView.csb")
            abk:initWithData()
            me.popLayer(abk)
        end )
        me.setButtonDisable(self.Button_dec, pIsUse == 0)
        me.setButtonDisable(self.Button_auto_dec, pIsUse == 0)
        self.Button_auto_dec:setVisible(true)
        self.Button_dec:setVisible(true)
    else
        me.assignWidget(self, "article_name"):setVisible(false)
        me.assignWidget(self, "article_Introduction"):setVisible(false)
        me.assignWidget(self, "Goods_Icon1"):setVisible(false)
        me.assignWidget(self, "Button_dec"):setVisible(false)
        me.assignWidget(self, "Button_auto_dec"):setVisible(false)
    end
end
function warShipBagView:setmetaRightUI(pTag)
    if pTag ~= nil then
        self.metapTagNum = me.toNum(pTag)
        local pData = self.metapTable[me.toNum(pTag)]
        self.metaData = pData

        local pCfgid = pData["defid"]
        -- 道具的配置Id
        local pCfgData = cfg[CfgType.ETC][pCfgid]
        local pName = me.assignWidget(self, "article_name")
        pName:setVisible(true)
        pName:setString(pCfgData["name"])
        local pIntroduce = me.assignWidget(self, "article_Introduction")
        -- 道具介绍
        pIntroduce:setVisible(true)
        pIntroduce:setString(pCfgData["describe"])
        local pIcon = me.assignWidget(self, "Goods_Icon1")
        -- 图标
        pIcon:loadTexture("item_" .. pCfgData["icon"] .. ".png", me.localType)
        pIcon:setVisible(true) 
        me.assignWidget(self, "Button_dec"):setVisible(false)
        me.assignWidget(self, "Button_auto_dec"):setVisible(false)
        me.assignWidget(self, "Button_equip"):setVisible(false)
    else
        me.assignWidget(self, "article_name"):setVisible(false)
        me.assignWidget(self, "article_Introduction"):setVisible(false)
        me.assignWidget(self, "Goods_Icon1"):setVisible(false)
        me.assignWidget(self, "Button_dec"):setVisible(false)
        me.assignWidget(self, "Button_auto_dec"):setVisible(false)
    end
end
function warShipBagView:onEnter()
    print("warShipBagView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_BAG) then
            if msg.c.t == 0 and msg.c.i == 0 then
                self:bagUpdata()
            else
                local choose = warShipSelectView:create("shipBagView.csb")
                choose:initChoose(msg.c.t, msg.c.i)
                me.popLayer(choose)
            end

        end
    end )
end
function warShipBagView:onEnterTransitionDidFinish()
    print("warShipBagView onEnterTransitionDidFinish")
end
function warShipBagView:onExit()
    print("warShipBagView onExit")
    UserModel:removeLisener(self.modelkey)
end
function warShipBagView:close()
    self:removeFromParent()
end
