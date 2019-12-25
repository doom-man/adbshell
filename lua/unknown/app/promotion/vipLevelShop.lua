vipLevelShop = class("vipLevelShop", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
vipLevelShop.__index = vipLevelShop
function vipLevelShop:create(...)
    local layer = vipLevelShop.new(...)
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
function vipLevelShop:ctor()
    print("vipLevelShop ctor")
end

function vipLevelShop:init()
    print("vipLevelShop init")
    self.In_bg = me.assignWidget(self, "In_bg")
    self.Text_leftTime = me.assignWidget(self,"Text_leftTime")
    self.Panel_touch = me.assignWidget(self,"Panel_touch")
    self.Panel_touch:setVisible(false)
    self.canTouch = true
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    
    me.assignWidget(self, "tipsTxt"):setVisible(true)

    self.Text_vipLevel = me.assignWidget(self,"Text_vipLevel")
    self.Text_vipLevel:setString("VIP"..user.vip)
    me.registGuiClickEventByName(self,"Button_GetPoint",function (node)
        local vipShop = vipShopView:create("vipShopView.csb")
        vipShop:initVipShop(1)
        me.popLayer(vipShop,"bg")
    end)
    self.modelkey = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.SHOP_INIT) then
            self:setVip()
            self:initList()
        elseif checkMsg(msg.t,MsgCode.SHOP_BUY) then
            self.shopdata = {}
            for key, var in pairs(user.shopList[VIPLEVELSHOP]) do
                table.insert(self.shopdata,var)
            end    
            table.sort(self.shopdata,function (a,b)
              return a.itemtype < b.itemtype
            end)
            self.pNum = #self.shopdata

            local tableOffSet = self.tableView:getContentOffset()
            self.tableView:reloadData()
            self.tableView:setContentOffset(tableOffSet)

        end
    end )
    NetMan:send(_MSG.initShop(VIPLEVELSHOP))

    self. globalItems = me.createNode("Node_Shop_Cell.csb")
    self. globalItems:retain()
    return true
end

function vipLevelShop:onEnter()
    print("vipLevelShop onEnter")
    me.doLayout(self, me.winSize)
    self:setVip()    
end

function vipLevelShop:onEnterTransitionDidFinish()
    print("vipLevelShop onEnterTransitionDidFinish")
end

function vipLevelShop:onExit()
    print("vipLevelShop onExit")
    self.globalItems:release()
    UserModel:removeLisener(self.modelkey)
end

function vipLevelShop:close()
    self:removeFromParentAndCleanup(true)
end

function vipLevelShop:setVip()
     self.Text_vipLevel:setString("VIP"..user.vip)
end

function vipLevelShop:setCellInfo(cellNode,data)
    if data then
        local def = cfg[CfgType.ETC][data.defid]
        if def == nil then
            __G__TRACKBACK__("def is nil !!! id =  "..data.defid)
            return
        end
        me.assignWidget(cellNode, "a_s_goods_name"):setString(def.name)
        me.assignWidget(cellNode, "a_s_goods_name"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2)) 
        me.assignWidget(cellNode, "a_s_goods_details"):setString(def.describe)
        me.assignWidget(cellNode, "buy_num"):setString(data.price)
        if user.vip >= data.itemtype then
            me.assignWidget(cellNode,"a_s_goods_limit"):setString("限购："..(data.limit-data.buyed).."/"..data.limit)
        else
            me.assignWidget(cellNode,"a_s_goods_limit"):setString("VIP"..data.itemtype.."可购买")
        end
        me.assignWidget(cellNode,"Image_Limit"):setVisible(false)
        me.assignWidget(cellNode, "a_s_goods_quailty"):loadTexture(getQuality(def.quality), me.localType)
        me.assignWidget(cellNode, "a_s_goods_icon"):loadTexture(getItemIcon(def.id), me.localType)
        local icon1 =  me.assignWidget(cellNode,"currenty_icon2")
        icon1:loadTexture(data:getCurrencyIcon(),me.plistType)
        icon1:ignoreContentAdaptWithSize(true)
        local icon2 =  me.assignWidget(cellNode,"currenty_icon1")
        icon2:loadTexture(data:getCurrencyIcon(),me.plistType)
        icon2:ignoreContentAdaptWithSize(true)
        if me.toNum(data.price) < tonumber(data.agioBefore) then
            me.assignWidget(cellNode, "Text_sale"):setString(10*data.agio.."折")
            me.assignWidget(cellNode,"Image_limit_bg"):setVisible(true)
            me.assignWidget(cellNode,"buy_before"):setVisible(true)
            me.assignWidget(cellNode,"buy_before"):setString(data.agioBefore)
            me.assignWidget(cellNode, "Text_sale"):setVisible(true) 
            me.assignWidget(cellNode,"Image_redLine"):setContentSize(me.assignWidget(cellNode,"buy_before"):getContentSize().width+10,3)
            me.assignWidget(cellNode,"Image_redLine"):setPositionX(me.assignWidget(cellNode,"buy_before"):getContentSize().width/2)
        else            
            me.assignWidget(cellNode,"buy_before"):setVisible(false)
            me.assignWidget(cellNode,"Image_limit_bg"):setVisible(false)
            me.assignWidget(cellNode, "Text_sale"):setVisible(false) 
        end      
        if me.toNum(data.limit-data.buyed) <= 0 or me.toNum(data.limit) <= 0 or user.vip < data.itemtype then
            me.buttonState(me.assignWidget(cellNode,"Button_buy"),false)
        else
            me.buttonState(me.assignWidget(cellNode,"Button_buy"),true)
            me.registGuiClickEventByName(cellNode,"Button_buy", function(node)
                if data:checkHaveEnough() then
                    self.BackpackBuy = BackpackBuy:create("BackpackBuy.csb")                   
                    self.BackpackBuy:isBuyItem(data.id)                    
                    local parent = me.runningScene()
                    parent:addChild(self.BackpackBuy, me.MAXZORDER);
                    self.BackpackBuy:adjustForVipShop(VIPLEVELSHOP)  
                    self.BackpackBuy:setData(data)
                    me.showLayer(self.BackpackBuy, "bg")    
                    --NetMan:send(_MSG.shopBuy(VIPLEVELSHOP,data.id,1,0))
                    me.setWidgetCanTouchDelay(node,1)                     
                end
            end )
        end
    end
end

function vipLevelShop:initList()    
    self.shopdata = {}
    for key, var in pairs(user.shopList[VIPLEVELSHOP]) do
        table.insert(self.shopdata,var)
    end    
    table.sort(self.shopdata,function (a,b)
      return a.itemtype < b.itemtype
    end)
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

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(1170, 509))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(0, 1)
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        me.assignWidget(self, "Node_tab"):addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    else
        self.tableOffSet = self.tableView:getContentOffset()
    end
    self.tableView:reloadData()
    if self.tableOffSet then
        self.tableView:setContentOffset(self.tableOffSet)
        me.DelayRun(function ()
            self.canTouch = true
        end,0.2)
    end
   
end