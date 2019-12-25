-- 背包主界面 2015-12-1 

BackpackView = class("BackpackView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
BackpackView.__index = BackpackView
function BackpackView:create(...)
    local layer = BackpackView.new(...)
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


function BackpackView:ctor()
    self.mUseNum = 1
    self.useBool = false
    self.mUseDefid = 0
end
function BackpackView:init()

    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.pTable = { }
    local pUse = user.pkg
    for key, var in pairs(pUse) do
        table.insert(self.pTable, var)
    end

    local function comp(a, b)
        return cfg[CfgType.ETC][tonumber(a.defid)].isUse > cfg[CfgType.ETC][tonumber(b.defid)].isUse
    end
    table.sort(self.pTable, comp)
    self.materTable = { }
    for key, var in pairs(user.materBackpack) do
        table.insert(self.materTable, var)
    end
    self.pTagNum = 0
    -- 当前选中的格子id
    me.registGuiClickEventByName(self, "Button_user", function(node)
        local pData = self.pTable[self.pTagNum]
        --需要展示选择其中一个物品
        local def = pData:getDef()
        if   def.useType == 132 then
                self.mUseDefid = def.id
                self.useBool = true
                local BackpackUse = BackpackUse_Choose:create("backpack/BackpackUse_Choose.csb")
                me.runningScene():addChild(BackpackUse, me.MAXZORDER);
                BackpackUse:setData(pData,function (num)
                     self.mUseNum = num
                end)       
                me.showLayer(BackpackUse, "bg")
        else
            if pData["count"] > 1 then
                self.BackpackUse = BackpackUse:create("backpack/BackpackUse.csb")
                self:addChild(self.BackpackUse, me.MAXZORDER);
                self.BackpackUse:setData(pData)
                self.BackpackUse:setParent(self)
                me.showLayer(self.BackpackUse, "bg")
            else
                self.useBool = true
                self.mUseNum = 1
                NetMan:send(_MSG.itemUse(pData["uid"], 1))
                self.mUseDefid = pData["defid"]
            end
        end
    end )
    self.iNum = math.floor((#self.pTable) / 4)
    if #self.pTable % 4 ~= 0 then
        self.iNum = self.iNum + 1
    end
    self.iNum = math.max(self.iNum, 4)
    self:initList()
    self:SpecifyCell(getBackpackId(), 1)
    self.pCellId = 1


    me.registGuiClickEventByName(self, "Button_Break", function(node)
        local pData = self.pTable[self.pTagNum]
        local breakView = BackpackBreak:create("backpack/backpackBreak.csb")    
        me.runningScene():addChild(breakView, me.MAXZORDER)   
        breakView:setItemData(pData)
        me.showLayer(breakView, "bg")
    end )

    me.registGuiClickEventByName(self, "moreBtn", function(node)
        local pData = self.pTable[self.pTagNum]
        showPromotion(pData["defid"], pData["count"])
    end )

    return true
end
function BackpackView:close()
    local i = 1
    for key, var in pairs(self.pTable) do
        if i == self.pCellId then
            local pUid = var["uid"]
            setBackpackId(pUid)
            break
        end
        i = i + 1
    end
    TaskHelper.setItemID(nil)
    self:removeFromParentAndCleanup(true)
end

function BackpackView:getQuality(pQuality)
      local pQualityStr = ""
      if pQuality == 1 then
       pQualityStr = "beibao_kuang_hui.png"        -- 白色
      elseif pQuality == 2 then
       pQualityStr = "beibao_kuang_lv.png"         -- 绿色
      elseif pQuality == 3 then
       pQualityStr = "beibao_kuang_lan.png"        -- 蓝色
      elseif pQuality == 4 then
       pQualityStr = "beibao_kuang_zi.png"         -- 紫色
      elseif pQuality == 5 then
       pQualityStr = "beibao_kuang_cheng.png"      -- 橙色
      elseif pQuality == 6 then
       pQualityStr = "beibao_kuang_hong.png"       -- 红色
      end
      return pQualityStr
end
function BackpackView:setRightUI(pTag)
    if pTag ~= nil then
        self.pTagNum = me.toNum(pTag)
        local pData = self.pTable[me.toNum(pTag)]
        self.mData = pData

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
        local pIsUse = pCfgData["isUse"]
        if pIsUse == 0 then
            -- 不可使用
            me.assignWidget(self, "Button_user"):setVisible(false)
        else
            me.assignWidget(self, "Button_user"):setVisible(true)
        end

        local pQuality = me.assignWidget(self,"Image_quality1")
        pQuality:loadTexture(self:getQuality(pCfgData["quality"]), me.localType)

        if pCfgData.showtype==0 then
            me.assignWidget(self, "moreBtn"):setVisible(false)
        else
            me.assignWidget(self, "moreBtn"):setVisible(true)
        end

        if pCfgData.isBreak==1 then
            me.assignWidget(self, "Button_Break"):setVisible(true)
        else
            me.assignWidget(self, "Button_Break"):setVisible(false)
        end
    else
        me.assignWidget(self, "article_name"):setVisible(false)
        me.assignWidget(self, "article_Introduction"):setVisible(false)
        me.assignWidget(self, "Goods_Icon1"):setVisible(false)
        me.assignWidget(self, "Button_user"):setVisible(false)
        me.assignWidget(self, "Button_Break"):setVisible(false)
    end
end
-- 判断是否点击在节点中
function BackpackView:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end
-- 返回选中格子的坐标，参数：第几个格子，table的个数
function BackpackView:getCellPoint(pTag, TableNum)
    pTag = me.toNum(pTag)
    self.pCellId = pTag
    local pRow = math.floor((pTag - 1) / 4)
    -- 行数
    local pLine = pTag % 4
    -- 列数
    if pLine == 0 then
        pLine = 4
    end
    local pPointX = pLine * 168 - 87+5
    local pPointY =(TableNum - pRow) * 170 - 93
    return pPointX, pPointY
end
function BackpackView:setUseNum(pNum)
    self.mUseNum = pNum
    self.useBool = true
end
function BackpackView:getDataCell(pTag)
    local pData = nil
    for key, var in pairs(self.pTable) do
        if key == pTag then
            pData = var
            break
        end
    end
    return pData
end
-- tableViews数据填充
function BackpackView:initList()

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
        return 640, 170
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
                local pBackpackCell = BackpackCell:create("backpack/backpackcell.csb")
                pBackpackCell:setTag(var)
                local buildBtn = me.assignWidget(pBackpackCell, "Button_bg")
                buildBtn:setName(pTag)
                buildBtn:setTag(123)
                pBackpackCell:setPosition(cc.p((var - 1) * 168+10, 0))
                me.registGuiClickEvent(buildBtn, function(node)
                    local pTouch = node:getTouchBeganPosition()
                    local pNode = me.assignWidget(self, "box_left")
                    local pTag = me.toNum(node:getName())
                    local pPoint = self:contains(pNode, pTouch.x, pTouch.y)
                    if pPoint then
                        -- 点击在tableview中
                        local pDataCount = #self.pTable
                        if pTag <(pDataCount + 1) then
                            self.selectImg:setPosition(cc.p(self:getCellPoint(node:getName(), self.iNum)))
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
                        pBackpackCell:setUI(self.pTable[pTag], pTag)
                    else
                        pBackpackCell:setUI(nil, pTag)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                buildBtn:setSwallowTouches(false)
                cell:addChild(pBackpackCell)
            end
        else
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local pBackpackCell = cell:getChildByTag(var)
                if pTag <(pCellNum + 1) then
                    pBackpackCell:setVisible(true)
                    if pTag <(pDataNum + 1) then
                        pBackpackCell:setUI(self.pTable[pTag], pTag)
                    else
                        pBackpackCell:setUI(nil, pTag)
                    end
                else
                    pBackpackCell:setVisible(false)
                end
                local p1 = pBackpackCell:getChildByTag(123)
                p1:setName(pTag)
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return self.iNum
    end

    self.tableView = cc.TableView:create(cc.size(675, 572))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 1)
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
    self.tableView:reloadData()

    self.selectImg = ccui.ImageView:create()
    self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setPosition(cc.p(self:getCellPoint(1, self.iNum)))
    self.selectImg:setScale9Enabled(true)
    self.selectImg:ignoreContentAdaptWithSize(false)
    self.selectImg:setCapInsets(cc.rect(17, 17, 8, 8))
    self.selectImg:setContentSize(cc.size(172, 172))
    self.tableView:addChild(self.selectImg)
    if #self.pTable > 0 then
        self:setRightUI(1)
        -- 判断背包是否为空
        self.selectImg:setVisible(true)
    else
        self.selectImg:setVisible(false)
        self:setRightUI(nil)
    end
end
function BackpackView:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_USE) then
        self:BackpackUpdata()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
        self:getGoodsAnimation(msg, 2)
        self:BackpackUpdata()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM) then
        self:BackpackUpdata()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE) then
        self:getGoodsAnimation(msg, 0)
        self:BackpackUpdata()
    elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        self:getGoodsAnimation(msg, 1)
        self:BackpackUpdata()
    end
end
function BackpackView:getGoodsAnimation(msg, pType)
    -- local pData = self.pTable[BackpackView.useid]
    local pData = cfg[CfgType.ETC][self.mUseDefid]
    --     dump(pData)
    print("self.pTagNum = " .. self.mUseDefid)
    if pData and self.useBool then
        local pConfigData = pData
        -- cfg[CfgType.ETC][pData["defid"]]
        if pConfigData then
            if me.toNum(pConfigData["useType"]) == 100  then
                self.useBool = false
                local i = { }
                local pDataTab = me.split(pConfigData["useEffect"], ",")
                for key, var in pairs(pDataTab) do
                    local pDataTabSingle = me.split(var, ":")
                    --      dump(pDataTabSingle)
                    if table.maxn(pDataTabSingle) > 1 then
                        local pSingle = cfg[CfgType.ETC][me.toNum(pDataTabSingle[1])]
                        local pNum = me.toNum(pDataTabSingle[2])
                        i[#i + 1] = { }
                        i[#i]["defId"] = pSingle["id"]
                        i[#i]["itemNum"] = pNum * self.mUseNum
                        i[#i]["needColorLayer"] = true
                    end
                end
                --  dump(i)
                getItemAnim(i)
            elseif me.toNum(pConfigData["useType"]) == 132  then
                    if msg.c.processValue ~= 11 and  ( pType == 1 or pType == 2 ) and tonumber( msg.c.iteminfo["defId"] ) ~= tonumber( self.mUseDefid ) then
                        self.useBool = false
                        local i = { }
                        local pDataTab = me.split(pConfigData["useEffect"], ",")
                        for key, var in pairs(pDataTab) do
                            local pDataTabSingle = me.split(var, ":")
                            --      dump(pDataTabSingle)
                            if table.maxn(pDataTabSingle) > 1 then
                                local pSingle = cfg[CfgType.ETC][me.toNum(pDataTabSingle[1])]
                                local pNum = me.toNum(pDataTabSingle[2])
                                if msg.c.iteminfo["defId"] == pSingle["id"] then
                                    i[#i + 1] = { }
                                    i[#i]["defId"] = pSingle["id"]
                                    i[#i]["itemNum"] = pNum * self.mUseNum
                                    i[#i]["needColorLayer"] = true
                                end
                            end
                        end
                        --  dump(i)
                        getItemAnim(i)
                    end
            else
                if pType == 1 then
                    local pNum = 0
                    local pSingle = cfg[CfgType.ETC][msg.c.iteminfo["defId"]]
                    if pSingle.useType == 124 or pSingle.useType == 125 then
                        for key, var in pairs(self.materTable) do
                            if var["defid"] == msg.c.iteminfo["defId"] then
                                pNum = msg.c.iteminfo["count"] - var.count
                                break
                            end
                        end
                    else
                        for key, var in pairs(self.pTable) do
                            if var["defid"] == msg.c.iteminfo["defId"] then
                                pNum = msg.c.iteminfo["count"] - var.count
                                break
                            end
                        end
                    end
                    if pNum > 0 then
                        local i = { }
                        i[#i + 1] = { }
                        i[#i]["defId"] = msg.c.iteminfo["defId"]
                        i[#i]["itemNum"] = pNum
                        i[#i]["needColorLayer"] = true
                        getItemAnim(i)
                    end
                elseif pType == 2 then
                    local i = { }
                    i[#i + 1] = { }
                    i[#i]["defId"] = msg.c.iteminfo["defId"]
                    i[#i]["itemNum"] = msg.c.iteminfo["count"]
                    i[#i]["needColorLayer"] = true
                    getItemAnim(i)
                end
            end
        end
    end
end
function BackpackView:BackpackUpdata()
    me.tableClear(self.pTable)
    self.pTable = { }
    local pUse = user.pkg

    for key, var in pairs(pUse) do
        table.insert(self.pTable, var)
    end
    local function comp(a, b)
        return cfg[CfgType.ETC][tonumber(a.defid)].isUse > cfg[CfgType.ETC][tonumber(b.defid)].isUse
    end
    table.sort(self.pTable, comp)
    me.tableClear(self.materTable)
    for key, var in pairs(user.materBackpack) do
        table.insert(self.materTable, var)
    end

    self.iNum = math.floor((#self.pTable) / 4)
    if #self.pTable % 4 ~= 0 then
        self.iNum = self.iNum + 1
    end
    self.iNum = math.max(self.iNum, 4)
    local pOffest = self.tableView:getContentOffset()
    self.tableView:reloadData()

    -- 判断是否还有选中的道具
    if self.mData ~= nil and #self.pTable > 1 then
        local pHaveBool = false
        for key, var in ipairs(self.pTable) do
            if self.mData["uid"] == var["uid"] then
                self.pTagNum=key
                pHaveBool = true
                break
            else
                pHaveBool = false
            end
        end
        if pHaveBool == true then
            local size = self.tableView:getContentSize()
            if size.height<566 then
                pOffest.y=566-size.height
            elseif pOffest.y>0 then
                pOffest.y=0
            end
            self.tableView:setContentOffset(pOffest)
            self.selectImg:setVisible(true)
            local pos = cc.p(self:getCellPoint(self.pTagNum, self.iNum))
            self.selectImg:setPosition(pos)
        else
            local ptag=-1
            if self.pTagNum then
                local pt = self.pTagNum
                if self.pTable[pt]==nil then
                    pt = self.pTagNum-1
                    if self.pTable[pt]~=nil then
                        ptag=pt
                    end
                else
                    ptag=pt
                end
            end
            if ptag~=-1 then
                self:setRightUI(ptag)
                -- 判断背包是否为空
                local pos = cc.p(self:getCellPoint(ptag, self.iNum))
                self.selectImg:setPosition(pos)

                local size = self.tableView:getContentSize()
                if pOffest.y + pos.y < 170 or pos.y + pOffest.y >size.height then
                    local curRow = math.ceil(ptag / 4)
                    if curRow<4 then
                        pOffest.y=566-size.height
                    else
                        pOffest.y=pOffest.y+170
                    end
                end

                if size.height<566 then
                    pOffest.y=566-size.height
                elseif pOffest.y>0 then
                    pOffest.y=0
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
-- Tabview 指定
-- @param id_:uid号
-- @param type_:1、记录上次使用位置的跳转，   2、是引导跳转
function BackpackView:SpecifyCell(id_, type_)
    local pId = id_
    if pId == nil then
        return
    end

    local pKey = 1
    local pBool = false
    for key, var in pairs(self.pTable) do
        if pId == var["uid"] then
            pBool = true
            break
        end
        pKey = pKey + 1
    end

    if pBool == false then
        return
    end

    local pCellNum = math.floor(pKey / 4)
    if pKey % 4 ~= 0 then
        pCellNum = pCellNum + 1
    end
    if pCellNum <(self.iNum - 2) then
        if pCellNum == 1 then

        else
            local pOffestY =(self.iNum - 2 - pCellNum) * 157
            self.tableView:reloadData()
            self.tableView:setContentOffset(cc.p(0, - pOffestY), type_ == 2)
        end
    else
        local pOffest = self.tableView:getContentOffset()
        self.tableView:reloadData()
        local size = self.tableView:getContentSize()
        if size.height<566 then
            pOffest.y=566-size.height
        elseif pOffest.y>0 then
            pOffest.y=0
        end
        self.tableView:setContentOffset(pOffest)
    end
    if type_ == 1 then
        -- 记录上次位置，标记选中状态
        self:setRightUI(pKey)
        self.selectImg:setPosition(cc.p(self:getCellPoint(pKey, self.iNum)))
    elseif type_ == 2 then
        -- 引导到对应的位置,并显示引导之手
        me.DelayRun( function()
            local pLine = pKey % 4
            if pLine == 0 then
                pLine = 4
            end
            local tcell = self.tableView:cellAtIndex(pCellNum - 1):getChildByTag(pLine)
            if tcell then
                local guide = guideView:getInstance()
                guide:showGuideViewForTableCell(tcell, false, false, self.selectImg:getContentSize())
                mainCity:addChild(guide, me.GUIDEZODER)
            else
                showTips("没有找到所需的道具")
            end
        end , 0.1)
    end
end

function BackpackView:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )

    -- 任务或者新人引导的跳转
    if TaskHelper.getItemID() ~= nil then
        me.DelayRun(self:setGuideView(), 0.01)
    end
end
function BackpackView:setGuideView()
    local itemID = TaskHelper.getItemID()
    local itemUID = nil
    for key, var in pairs(self.pTable) do
        if me.toNum(var.defid) == me.toNum(itemID) then
            itemUID = var.uid
            break
        end
    end
    if itemUID then
        self:SpecifyCell(itemUID, 2)
    else
        showTips("没有找到所需的道具!")
    end
end
function BackpackView:onExit()
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
