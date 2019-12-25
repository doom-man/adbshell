-- [Comment]
-- jnmo
citySkinShop = class("citySkinShop", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
citySkinShop.__index = citySkinShop
function citySkinShop:create(...)
    local layer = citySkinShop.new(...)
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

function citySkinShop:ctor()
    print("citySkinShop ctor")
    self.discount = 100
end
function citySkinShop:init()
    print("citySkinShop init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        me.DelayRun( function(args)
            self:close()
        end )
    end )
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Image_Icon:loadTexture("item_274.png", me.localType)
    me.registGuiClickEventByName(self, "Image_Icon", function(node)        
        showPromotion(274,getItemNum(274))
    end )

    me.registGuiClickEventByName(self, "getMoreBtn", function(node)        
        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
        me.runningScene():addChild(getWayView, me.MAXZORDER)
        me.showLayer(getWayView, "bg")
        getWayView:setData(274)
    end )

    self.Text_1 = me.assignWidget(self, "Text_1")
    return true
end

function citySkinShop:update(msg)
    if checkMsg(msg.t, MsgCode.SHOP_INIT) then
        if msg.c.shopId == SKINSHOP  then
            self:initList(user.shopList[SKINSHOP])
        elseif msg.c.shopId == LIMIT_EXCHANGE_SHOP  then
            self:initList(user.shopList[LIMIT_EXCHANGE_SHOP])
        end
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY) then
        if msg.c.defId and msg.c.amount then
            me.assignWidget(self, "Node_tab"):removeAllChildren()
            NetMan:send(_MSG.initShop(SKINSHOP))
        end
    elseif checkMsg(msg.t, MsgCode.SHOP_BUY_AMOUNT) then
        user.turnplateScore = msg.c.score
        self.Text_1:setString(user.turnplateScore)
    end
end

function citySkinShop:setButton(button, b)
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
-- 判断是否点击在节点中
function citySkinShop:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end

function citySkinShop:initList(dataTb)
    self.Text_1:setString(getItemNum(274))
    local tb = { }
    for key, var in pairs(dataTb) do
        table.insert(tb, var)
    end
    local pNum = #tb
    table.sort(tb, function(a, b)
        return a.id < b.id
    end )

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
                local pShopCell = citySkinShopItem:create(self, "a_shop_cell_bg")
                local buildBtn = me.assignWidget(pShopCell, "Button_buy")
                if data then
                    pShopCell:initCellInfo(data, self.discount)
                    local specialPrice = math.ceil(data.price[2] * self.discount / 100)
                    me.registGuiClickEvent(buildBtn, function(node)
                        local pTouch = node:getTouchBeganPosition()
                        local pPoint = self:contains(me.assignWidget(self, "In_bg"), pTouch.x, pTouch.y)
                        if pPoint then
                            if data.limit - data.buyed  > 0 then
                                if specialPrice > getItemNum(data.price[1]) then
                                    showTips("道具不足", "ffffff")
                                else
                                    self.BackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                                    me.runningScene():addChild(self.BackpackBuy, me.MAXZORDER)
                                    self.BackpackBuy:setShopType(SKINSHOP)
                                    self.BackpackBuy:setData(data, specialPrice)
                                    me.showLayer(self.BackpackBuy, "bg")
                                end
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
                    local specialPrice = math.ceil(data.price[2] * self.discount / 100)
                    me.registGuiClickEvent(buildBtn, function(node)
                        local pTouch = node:getTouchBeganPosition()
                        local pPoint = self:contains(me.assignWidget(self, "In_bg"), pTouch.x, pTouch.y)
                        if pPoint then
                            if data.limit - data.buyed  > 0 then
                                if specialPrice > getItemNum(data.price[1]) then
                                    showTips("道具不足", "ffffff")
                                else
                                    self.BackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                                    me.runningScene():addChild(self.BackpackBuy, me.MAXZORDER)
                                    self.BackpackBuy:setShopType(SKINSHOP)
                                    self.BackpackBuy:setData(data, specialPrice)
                                    me.showLayer(self.BackpackBuy, "bg")
                                end
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
    self.tableView = cc.TableView:create(cc.size(1170, 509))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
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
    self.tableView:reloadData()
end
function citySkinShop:onEnter()
    print("citySkinShop onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
end
function citySkinShop:onEnterTransitionDidFinish()
    print("citySkinShop onEnterTransitionDidFinish")
end
function citySkinShop:onExit()
    print("citySkinShop onExit")
    UserModel:removeLisener(self.modelkey)
end
function citySkinShop:close()
    self:removeFromParentAndCleanup(true)
end

