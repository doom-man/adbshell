-- [Comment]
-- jnmo
allianceshop = class("allianceshop", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
allianceshop.__index = allianceshop
function allianceshop:create(...)
    local layer = allianceshop.new(...)
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

allianceshop.ALLIANCE = 1 -- 联盟商店
allianceshop.MARKET = 2 -- 市场商店
allianceshop.VIPSHOP = 3 -- VIP商店
function allianceshop:ctor()
    print("allianceshop ctor")
end
function allianceshop:init()
    print("allianceshop init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.saleNum = me.assignWidget(self, "saleNum")
    self.LairbType = allianceshop.VIPSHOP
    self.Image_alliance = me.assignWidget(self, "Image_alliance")
    self.Image_vip = me.assignWidget(self, "Image_vip")
    -- 联盟商店
    self.alliance_shop = me.registGuiClickEventByName(self, "Button_alliance_shop", function(node)
        self:setButton(self.alliance_shop, false)
        self:setButton(self.market_shop, true)
        self.LairbType = allianceshop.ALLIANCE
        self.Image_alliance:setVisible(true)
        self.Image_vip:setVisible(false)
        NetMan:send(_MSG.initShop(ALLIANCESHOP_TYPE))
    end )
    -- 市场商店
    self.market_shop = me.registGuiClickEventByName(self, "Button_VIPshop", function(node)
        self:setButton(self.alliance_shop, true)
        self:setButton(self.market_shop, false)
        NetMan:send(_MSG.initShop(VIPLEVELSHOP))
        self.LairbType = allianceshop.VIPSHOP
        self.Image_alliance:setVisible(false)
        self.Image_vip:setVisible(true)
        self.Text_vipLevel:setString("VIP" .. user.vip)
        NetMan:send(_MSG.initShop(VIPLEVELSHOP))
    end )
    self.Text_vipLevel = me.assignWidget(self, "Text_vipLevel")
    self.Text_vipLevel:setString("VIP" .. user.vip)
    me.assignWidget(self, "tipsTxt"):setVisible(true)
    me.registGuiClickEventByName(self, "Image_1", function(node)
        local wd = node:convertToWorldSpace(cc.p(0, 0))
        local stips = mTips:create("simpleTipsLayer.csb")
        stips:initWithStr("通过捐献联盟科技获得联盟徽章", wd, "left")
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end )
    me.registGuiClickEventByName(self, "Button_GetPoint", function(node)
        local vipShop = vipShopView:create("vipShopView.csb")
        vipShop:initVipShop(1)
        me.popLayer(vipShop, "bg")
    end )
    me.registGuiClickEventByName(self, "sale", function(node)
        local wd = node:convertToWorldSpace(cc.p(0, 0))
        local stips = mTips:create("simpleTipsLayer.csb")
        stips:initWithStr("升级市场享受更大折扣", wd, "left")
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end )
    self.globalItems = me.createNode("Node_Shop_Cell.csb")
    self.globalItems:retain()
    self:setButton(self.alliance_shop, true)
    self:setButton(self.market_shop, false)
    me.assignWidget(self, "Text_1"):setString(user.allianceGivenData.gongxian or "0")
    NetMan:send(_MSG.initShop(VIPLEVELSHOP))
    self.Image_alliance:setVisible(false)
    self.Image_vip:setVisible(true)
    return true
end

function allianceshop:initShopInfo(def)
    local tb = me.split(def.ext, ",")
    _, _, self.discount = string.find(tb[3], ":(.+)")
    self.discount = me.toNum(self.discount)
    if self.discount then
        self.saleNum:setString(self.discount / 10 .. "折")
    end
    me.assignWidget(self, "Text_1"):setString(user.allianceGivenData.gongxian or "0")
end

function allianceshop:update(msg)
    if checkMsg(msg.t, MsgCode.SHOP_INIT) then
        if msg.c.shopId == ALLIANCESHOP_TYPE then
            if user.shopList[ALLIANCESHOP_TYPE] and #user.shopList[ALLIANCESHOP_TYPE] > 0 then
                self:initList(user.shopList[ALLIANCESHOP_TYPE])
            end
        elseif msg.c.shopId == VIPLEVELSHOP then
            self.Text_vipLevel:setString("VIP" .. user.vip)
            self:initVipList()
        end
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY) then
        if msg.c.shopId == ALLIANCESHOP_TYPE then
            if msg.c.defId and msg.c.amount then
                NetMan:send(_MSG.initShop(ALLIANCESHOP_TYPE))
            end
        elseif msg.c.shopId == VIPLEVELSHOP then
            self.shopdata = { }
            for key, var in pairs(user.shopList[VIPLEVELSHOP]) do
                table.insert(self.shopdata, var)
            end
            table.sort(self.shopdata, function(a, b)
                return a.itemtype < b.itemtype
            end )
            self.pNum = #self.shopdata

            local tableOffSet = self.tableViewVip:getContentOffset()
            self.tableViewVip:reloadData()
            self.tableViewVip:setContentOffset(tableOffSet)
        end
    end
end

function allianceshop:setButton(button, b)
    button:setTouchEnabled(b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if title ~= nil then
        if b then
            title:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
            title:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
        else
            title:setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
            title:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
        end
    end
end
function allianceshop:setShopType()
    if self.LairbType == allianceshop.ALLIANCE then

    elseif self.LairbType == allianceshop.VIPSHOP then

    end
end

-- 判断是否点击在节点中
function allianceshop:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end
function allianceshop:initList(dataTb)
    me.assignWidget(self, "Text_1"):setString(user.allianceGivenData.gongxian or "0")
    local tb = { }
    for key, var in pairs(dataTb) do
        table.insert(tb, var)
    end
    local pNum = #tb
    local pCellNum = pNum / 2 + pNum % 2

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
        return 1170, 181
    end

    local function tableCellAtIndex(table, idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 2 do
                local pTag = idx * 2 + var
                local data = tb[pTag]
                local pShopCell = allianceshopCell:create(self, "a_shop_cell_bg")
                local buildBtn = me.assignWidget(pShopCell, "Button_buy")
                if data then
                    pShopCell:initCellInfo(data, self.discount)
                    local specialPrice = math.ceil(data.price * self.discount / 100)
                    me.registGuiClickEvent(buildBtn, function(node)
                        local pTouch = node:getTouchBeganPosition()
                        local pPoint = self:contains(me.assignWidget(self, "In_bg"), pTouch.x, pTouch.y)
                        if pPoint then
                            if specialPrice > user.allianceGivenData.gongxian then
                                showTips("联盟徽章不足", "ffffff")
                            else
                                local mBackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                                me.runningScene():addChild(mBackpackBuy, me.MAXZORDER)
                                mBackpackBuy:setShopType(ALLIANCESHOP_TYPE)
                                mBackpackBuy:setData(data, specialPrice)
                                me.showLayer(mBackpackBuy, "bg")
                            end
                        end
                    end )
                end
                pShopCell:setTag(var)
                buildBtn:setTag(pTag)
                pShopCell:setPosition(cc.p((var - 1) * 582, 0))
                if pTag <(pNum + 1) then
                    pShopCell:setVisible(true)
                else
                    pShopCell:setVisible(false)
                end
                buildBtn:setSwallowTouches(false)
                cell:addChild(pShopCell)
            end
        else
            for var = 1, 2 do
                local pTag = idx * 2 + var
                local pShopCell = cell:getChildByTag(var)
                local buildBtn = me.assignWidget(pShopCell, "Button_buy")
                local data = tb[pTag]
                if data then
                    pShopCell:initCellInfo(data, self.discount)
                    local specialPrice = math.ceil(data.price * self.discount / 100)
                    me.registGuiClickEvent(buildBtn, function(node)
                        local pTouch = node:getTouchBeganPosition()
                        local pPoint = self:contains(me.assignWidget(self, "In_bg"), pTouch.x, pTouch.y)
                        if pPoint then
                            if specialPrice > user.allianceGivenData.gongxian then
                                showTips("联盟徽章不足", "ffffff")
                            else
                                local mBackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                                me.runningScene():addChild(mBackpackBuy, me.MAXZORDER)
                                mBackpackBuy:setShopType(ALLIANCESHOP_TYPE)
                                mBackpackBuy:setData(data, specialPrice)
                                me.showLayer(mBackpackBuy, "bg")
                            end
                        end
                    end )
                end
                buildBtn:setTag(pTag)
                if pTag <(pNum + 1) then
                    pShopCell:setVisible(true)
                else
                    pShopCell:setVisible(false)
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pCellNum
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(1170, 509))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(1, 0)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        me.assignWidget(self, "Node_tab"):addChild(self.tableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function allianceshop:setCellInfo(cellNode, data)
    if data then
        local def = cfg[CfgType.ETC][data.defid]
        if def == nil then
            __G__TRACKBACK__("def is nil !!! id =  " .. data.defid)
            return
        end
        me.assignWidget(cellNode, "a_s_goods_name"):setString(def.name)
        me.assignWidget(cellNode, "a_s_goods_name"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))
        me.assignWidget(cellNode, "a_s_goods_details"):setString(def.describe)
        me.assignWidget(cellNode, "buy_num"):setString(data.price)
        if user.vip >= data.itemtype then
            me.assignWidget(cellNode, "a_s_goods_limit"):setString("限购：" ..(data.limit - data.buyed) .. "/" .. data.limit)
        else
            me.assignWidget(cellNode, "a_s_goods_limit"):setString("VIP" .. data.itemtype .. "可购买")
        end
        me.assignWidget(cellNode, "a_s_goods_limit"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))
        me.assignWidget(cellNode, "Image_Limit"):setVisible(false)
        me.assignWidget(cellNode, "a_s_goods_quailty"):loadTexture(getQuality(def.quality), me.localType)
        me.assignWidget(cellNode, "a_s_goods_icon"):loadTexture(getItemIcon(def.id), me.localType)
        local icon1 = me.assignWidget(cellNode, "currenty_icon2")
        icon1:loadTexture(data:getCurrencyIcon(), me.plistType)
        icon1:ignoreContentAdaptWithSize(true)
        local icon2 = me.assignWidget(cellNode, "currenty_icon1")
        icon2:loadTexture(data:getCurrencyIcon(), me.plistType)
        icon2:ignoreContentAdaptWithSize(true)
        if me.toNum(data.price) < tonumber(data.agioBefore) then
            me.assignWidget(cellNode, "Text_sale"):setString(10 * data.agio .. "折")
            me.assignWidget(cellNode, "Image_limit_bg"):setVisible(true)
            me.assignWidget(cellNode, "buy_before"):setVisible(true)
            me.assignWidget(cellNode, "buy_before"):setString(data.agioBefore)
            me.assignWidget(cellNode, "Text_sale"):setVisible(true)
            me.assignWidget(cellNode, "Image_redLine"):setContentSize(me.assignWidget(cellNode, "buy_before"):getContentSize().width + 10, 3)
            me.assignWidget(cellNode, "Image_redLine"):setPositionX(me.assignWidget(cellNode, "buy_before"):getContentSize().width / 2)
        else
            me.assignWidget(cellNode, "buy_before"):setVisible(false)
            me.assignWidget(cellNode, "Image_limit_bg"):setVisible(false)
            me.assignWidget(cellNode, "Text_sale"):setVisible(false)
        end
        if me.toNum(data.limit - data.buyed) <= 0 or me.toNum(data.limit) <= 0 or user.vip < data.itemtype then
            me.buttonState(me.assignWidget(cellNode, "Button_buy"), false)
        else
            me.buttonState(me.assignWidget(cellNode, "Button_buy"), true)
            me.registGuiClickEventByName(cellNode, "Button_buy", function(node)
                if data:checkHaveEnough() then
                    local mBackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                    mBackpackBuy:isBuyItem(data.id)
                    local parent = me.runningScene()
                    parent:addChild(mBackpackBuy, me.MAXZORDER);
                    mBackpackBuy:adjustForVipShop(VIPLEVELSHOP)
                    mBackpackBuy:setData(data)
                    me.showLayer(mBackpackBuy, "bg")
                    -- NetMan:send(_MSG.shopBuy(VIPLEVELSHOP,data.id,1,0))
                    me.setWidgetCanTouchDelay(node, 1)
                end
            end )
        end
    end
end

function allianceshop:initVipList()
    self.shopdata = { }
    for key, var in pairs(user.shopList[VIPLEVELSHOP]) do
        table.insert(self.shopdata, var)
    end
    table.sort(self.shopdata, function(a, b)
        return a.itemtype < b.itemtype
    end )
    self.pNum = #self.shopdata
    local function cellSizeForTable(table, idx)
        return 1170, 181
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 2 do
                local pTag = idx * 2 + var
                local data = self.shopdata[pTag]
                local pShopCell = me.assignWidget(self.globalItems, "a_shop_cell_bg"):clone()
                self:setCellInfo(pShopCell, data)
                pShopCell:setTag(var)
                pShopCell:setPosition(cc.p((var - 1) * 582, 0))
                if pTag <(self.pNum + 1) then
                    pShopCell:setVisible(true)
                else
                    pShopCell:setVisible(false)
                end
                me.assignWidget(pShopCell, "Button_buy"):setSwallowTouches(false)
                cell:addChild(pShopCell)
            end
        else
            for var = 1, 2 do
                local pTag = idx * 2 + var
                local data = self.shopdata[pTag]
                local pShopCell = cell:getChildByTag(var)
                self:setCellInfo(pShopCell, data)
                if pTag <(self.pNum + 1) then
                    pShopCell:setVisible(true)
                else
                    pShopCell:setVisible(false)
                end
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        local pCellNum = self.pNum / 2 + self.pNum % 2
        return pCellNum
    end

    if self.tableViewVip == nil then
        self.tableViewVip = cc.TableView:create(cc.size(1170, 509))
        self.tableViewVip:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableViewVip:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableViewVip:setPosition(0, 1)
        self.tableViewVip:setAnchorPoint(cc.p(0, 5))
        self.tableViewVip:setDelegate()
        me.assignWidget(self, "Node_tab_vip"):addChild(self.tableViewVip)
        self.tableViewVip:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableViewVip:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableViewVip:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    else
        self.tableOffSet = self.tableViewVip:getContentOffset()
    end
    self.tableViewVip:reloadData()
    if self.tableOffSet then
        self.tableViewVip:setContentOffset(self.tableOffSet)
        me.DelayRun( function()
            self.canTouch = true
        end , 0.2)
    end
end

function allianceshop:onEnter()
    print("allianceshop onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
end
function allianceshop:onEnterTransitionDidFinish()
    print("allianceshop onEnterTransitionDidFinish")
end
function allianceshop:onExit()
    print("allianceshop onExit")
    UserModel:removeLisener(self.modelkey)
end
function allianceshop:close()
    self:removeFromParentAndCleanup(true)
end

