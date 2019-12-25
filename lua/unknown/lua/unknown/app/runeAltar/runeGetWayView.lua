runeGetWayView = class("runeGetWayView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
function runeGetWayView:create(...)
    local layer = runeGetWayView.new(...)
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

function runeGetWayView:ctor()
end

function runeGetWayView:onEnter()
    self.listener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.SHOP_INIT) then
            disWaitLayer()
            if self.open == "stonewin" then
                self:stonewin()

            end
        end
    end )
end

function runeGetWayView:onExit()
    UserModel:removeLisener(self.listener)
end

function runeGetWayView:init()
    print("runeGetWayView init")
    self.IS_RUNE_MATER = false
    -- 如果是符文材料，只显示两种获取方式，如果是强化石则有三种

    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        if self.callback then
            self.callback()
        end
        self:removeFromParentAndCleanup(true)

    end )

    self.textRuneNum = me.assignWidget(self, "Text_rune_num")

    -- 图标
    self.rune_icon = me.assignWidget(self, "rune_icon")

    -- 名称
    self.text_rune_name = me.assignWidget(self, "Text_rune_name")

    self.text_getway = me.assignWidget(self, "text_getway")

    self:initRuneTable()
    return true
end

function runeGetWayView:initRuneTable()
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
        return 754, 76
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self.listData[idx + 1]
        if nil == cell then
            cell = cc.TableViewCell:new()

            local leftCell = me.assignWidget(self, "cell_bg"):clone():setVisible(true)
            me.assignWidget(leftCell, "btn_puton"):setTag(tonumber(data))
            cell:addChild(leftCell)
            me.registGuiClickEvent(me.assignWidget(leftCell, "btn_puton"), handler(self, self.onClickTarget))
            me.assignWidget(leftCell, "btn_puton"):setSwallowTouches(false)

            self:fillData(leftCell, data, idx)
        else
            local leftCell = cell:getChildByTag(idx + 1)
            if leftCell == nil then
                leftCell = me.assignWidget(self, "cell_bg"):clone():setVisible(true)
                cell:addChild(leftCell)
                me.registGuiClickEvent(me.assignWidget(leftCell, "btn_puton"), handler(self, self.onClickTarget))
                me.assignWidget(leftCell, "btn_puton"):setSwallowTouches(false)
            end
            me.assignWidget(leftCell, "btn_puton"):setTag(tonumber(data))
            self:fillData(leftCell, data, idx)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.listData
    end

    local tableView = cc.TableView:create(cc.size(754, 297))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView

end

function runeGetWayView:fillData(leftCell, id,idx)
    me.assignWidget(leftCell, "bb"):setOpacity(60)
    local data = cfg[CfgType.ITEM_FROM][id]
    me.assignWidget(leftCell, "Text_get"):setString(data.desc)
    if data.isShow==1 then
        me.assignWidget(leftCell, "btn_puton"):setVisible(true)
    else
        me.assignWidget(leftCell, "btn_puton"):setVisible(false)
    end
end

function runeGetWayView:onClickTarget(node)
    local data = cfg[CfgType.ITEM_FROM][tostring(node:getTag())]
    if data.class == "relicsearch" then
        self:relicsearch()
    elseif data.class == "relicstore" then
        self:relicstore()
    elseif data.class == "relicstore1" then
        self:relicstore1()
    elseif data.class == "stonewin" then
        showWaitLayer()
        self.open = "stonewin"
        NetMan:send(_MSG.initShop(10))
        -- self:stonewin()
    elseif data.class == "sailwin" then
        self:sailwin()
    elseif data.class == "giftwin" then
        self:giftwin()
    elseif data.class == "materialwin" then
        self:materialwin()
    elseif data.class == "boatwin" then
        showWaitLayer()
        self.open = "boatwin"
        NetMan:send(_MSG.initShop(SHIPDEBRISSHOP))
    elseif data.class == "wonderwin" then
        self:wonderwin()
    elseif data.class == "vipshopwin" then
        self:vipshopwin()
    elseif data.class == "xunluowin" then
        self:xunluowin()
    elseif data.class == "citywin" then
        self:cityskinwin()
    elseif data.class == "yuanzhenwin" then
        self:netBattle()
    elseif data.class == "backpack" then
        self:backpackwin()
    elseif data.class == "relicactivitywin" then
        self:relicactivitywin()
    elseif data.class == "dailytranswin" then
        self:dailytranswin()
    elseif data.class == "shipshopwin" then
        self:shipshopwin()
    elseif data.class == "clanshopwin" then
        if user.familyUid and user.familyUid ~= 0 then
            local building = user.building[4005]
            if building == nil then
                showTips("尚未修建市场")
                return
            end
            showWaitLayer()
            self:clanshopwin()
        else
            showTips("尚未加入联盟")
        end
        -- self:clanshopwin()
    end
end



function runeGetWayView:backpackwin()


end

function runeGetWayView:relicactivitywin()
    if user.activity_buttons_show[57]==nil then
        showTips("活动未开启")
        return
    end
    local pShop = digoreShop:create("digore/digoreShop.csb")
    me.runningScene():addChild(pShop, me.MAXZORDER)
    me.showLayer(pShop, "bg_frame")
    NetMan:send(_MSG.initShop(17))

end

function runeGetWayView:dailytranswin()
    if user.activity_buttons_show[58]==nil then
        showTips("活动未开启")
        return
    end

    NetMan:send(_MSG.initShop(LIMIT_EXCHANGE_SHOP))
    local shop = limitExchangeShop:create("citySkinShop.csb")
    me.popLayer(shop)

end

function runeGetWayView:shipshopwin()
    if user.activity_buttons_show[18]==nil then
        showTips("活动未开启")
        return
    end
    self.promotionView = promotionView:create("promotionView.csb")
    self.promotionView:setViewTypeID(1)
    self.promotionView:setTaskGuideIndex(18)
    me.runningScene():addChild(self.promotionView, me.MAXZORDER)
    me.showLayer(self.promotionView, "bg_frame")
end

-- -
-- 挑战级圣地遗迹
function runeGetWayView:relicsearch()
    if user.Cross_Sever_Status == mCross_Sever then 
        showTips("跨服中，无法操作")
        return 
    end
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity:cloudClose( function(node)
            local loadlayer = loadWorldMap:create("loadScene.csb")
            loadlayer:setOpenOpt(1)
            me.runScene(loadlayer)
        end )
        me.DelayRun( function()
            self:removeFromParentAndCleanup(true)
        end )
    else
        --  pWorldMap:FindRuneCreate(8)        
        pWorldMap:cloudClose( function(node)
            local loadlayer = loadWorldMap:create("loadScene.csb")
            loadlayer:setOpenOpt(1)
            me.runScene(loadlayer)
        end )
        me.DelayRun( function()
            self:removeFromParentAndCleanup(true)
        end )
    end
end

-- -
-- 分解圣物获得
function runeGetWayView:relicstore()
    local runeAltar = runeAltarView:create("rune/runeAltarView.csb", 1, 2)
    me.runningScene():addChild(runeAltar, me.MAXZORDER)
    me.showLayer(runeAltar, "bg")
end
-- -
-- 跳转到圣物窗口
function runeGetWayView:relicstore1()
    me.dispatchCustomEvent("jumpToRuneStore", 2)
    me.DelayRun( function()
        self:removeFromParentAndCleanup(true)
    end )
end

-- -
-- 圣物材料获得
function runeGetWayView:materialwin()
    local runeAltar = runeAltarView:create("rune/runeAltarView.csb", 1, 3)
    me.runningScene():addChild(runeAltar, me.MAXZORDER)
    me.showLayer(runeAltar, "bg")
end

-- -
-- 购买强化石头获得
function runeGetWayView:stonewin()
    if me.runningScene():getChildByName("hornShopView") then return end

    local tmpView = hornShopView:create("hornShopView.csb")
    tmpView:setName("hornShopView")
    tmpView:initWithType(10)
    me.runningScene():addChild(tmpView, me.MAXZORDER)
    me.showLayer(tmpView, "bg")
end

-- -
-- 战舰航海
function runeGetWayView:sailwin()
    NetMan:send(_MSG.ship_expedition_init())
    local shipSail = shipSailView:create("warning/shipSailView.csb")
    me.runningScene():addChild(shipSail, me.MAXZORDER)
    me.showLayer(shipSail, "bg")
end
-- -
-- 超值好礼购买
function runeGetWayView:giftwin()
    self.promotionView = promotionView:create("promotionView.csb")
    self.promotionView:setViewTypeID(1)
    self:addChild(self.promotionView, me.MAXZORDER)
    me.showLayer(self.promotionView, "bg_frame")
end

-- -
-- 流浪军团活动
function runeGetWayView:wonderwin()
    self.promotionView = promotionView:create("promotionView.csb")
    self.promotionView:setViewTypeID(1)
    self.promotionView:setTaskGuideIndex(15)
    self:addChild(self.promotionView, me.MAXZORDER)
    me.showLayer(self.promotionView, "bg_frame")
end

-- -
-- 禁卫军
function runeGetWayView:xunluowin()
    local patrol = defSoldierPatrol:create("defSoldierPatrol.csb")
    me.popLayer(patrol)
    NetMan:send(_MSG.guard_patrol_init())
end

-- -
-- 城池皮肤商店
function runeGetWayView:cityskinwin()
    NetMan:send(_MSG.initShop(SKINSHOP))
    local shop = citySkinShop:create("citySkinShop.csb")
    me.popLayer(shop)
end
-- \英雄殿远征
function runeGetWayView:netBattle()
         NetMan:send(_MSG.Cross_Promotion_List())
         local netBattleEnterLayer = netBattleEnterLayer:create("netBattleEnterLayer.csb")
         me.popLayer(netBattleEnterLayer)
end
-- -
-- vip商店
function runeGetWayView:vipshopwin()
    local vshop = vipLevelShop:create("vipLevelShopView.csb")
    me.runningScene():addChild(vshop, me.MAXZORDER)
    me.showLayer(vshop, "bg_frame")
end
-- -
-- 联盟商城兑换
function runeGetWayView:clanshopwin()
    NetMan:send(_MSG.initShop(ALLIANCESHOP_TYPE))
    local shop = allianceshop:create("allianceshop.csb")
    local building = user.building[4005]
    if building then
        shop:initShopInfo(building:getDef())
    end
    me.runningScene():addChild(shop, me.MAXZORDER)
    me.showLayer(shop, "bg_frame")
end

function runeGetWayView:setData(id)
    self.id = tonumber(id)
    print(id)
    local cfgData = cfg[CfgType.ETC][self.id]

    if cfgData.gainType then
        self.listData = string.split(cfgData.gainType, ",")
        self.rune_icon:setVisible(true)
    else
        self.listData = { }
        self.rune_icon:setVisible(false)
        return
    end
    self.runeTableView:reloadData()

    local dataTbl = nil
    if cfgData.useType == 124 or cfgData.useType == 125 then
        dataTbl = user.materBackpack
    else
        dataTbl = user.pkg
    end

    local count = 0
    for key, var in pairs(dataTbl) do
        if tonumber(var.defid) == self.id then
            count = count + var.count
        end
    end

    self.textRuneNum:setString(count)
    self.rune_icon:loadTexture(getItemIcon(id))
    self.text_rune_name:setString(cfgData.name)
end

function runeGetWayView:setCloseCallback(callback)
    self.callback = callback
end