vipShopView = class("vipShopView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
vipShopView.__index = vipShopView
function vipShopView:create(...)
    local layer = vipShopView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function vipShopView:ctor()
    print("vipShopView ctor")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end)
    self.isLoaded = {}
    self.shopType = 2
end
vipShopView.VIP_ITEMTYPE = {
   ["time"] = 107,
   ["point"] = 106,
   ["power"] = 120,
   ["buff"] = 122,
}
function vipShopView:close()
    self:removeFromParentAndCleanup(true)
end
function vipShopView:init()
    print("vipShopView init")
    disWaitLayer ()

     self.lisener = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_USE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD)
        or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE)
        or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
             self:initWithType(self.pViewType)
        end
    end)
    return true
end
--分 VIP时间和VIP点数两个页卡
function vipShopView:initVipShop(viptype)
    local vip_time = me.assignWidget(self,"page_button_1")
    vip_time:setVisible(true)
    me.assignWidget(vip_time,"Text_title"):setString("VIP时间")
    local vip_point = me.assignWidget(self,"page_button_2")    
    vip_point:setVisible(false)
    me.assignWidget(vip_point,"Text_title"):setString("VIP点数")
    me.registGuiClickEvent(vip_time,function (node)
        me.setButtonDisable(vip_time,false)
        me.setButtonDisable(vip_point,true)
        self:initWithType(1)
    end)
    me.registGuiClickEvent(vip_point,function (node)
        me.setButtonDisable(vip_time,true)
        me.setButtonDisable(vip_point,false)
        self:initWithType(2)
    end)    
    me.setButtonDisable(vip_time,viptype == 2)
    me.setButtonDisable(vip_point,viptype == 1)
    self:initWithType(viptype)
end 
--体力消耗
function vipShopView:initCost()
    local vip_time = me.assignWidget(self,"page_button_1")
    vip_time:setVisible(true)
    me.assignWidget(vip_time,"Text_title"):setString("体力")
    self:initWithType(3)
end
--积分商店 14
function vipShopView:initScoreShop()
    local vip_time = me.assignWidget(self,"page_button_1")
    vip_time:setVisible(true)
    me.assignWidget(vip_time,"Text_title"):setString("积分商店")
    self:initWithType(14)
end
--出征上限
function vipShopView:expendMax()
    local vip_time = me.assignWidget(self,"page_button_1")
    vip_time:setVisible(true)
    me.assignWidget(vip_time,"Text_title"):setString("出征上限")
    self:initWithType(5)
end
--战舰碎片  战舰经验
function vipShopView:boatShop(viptype)
    local vip_time = me.assignWidget(self,"page_button_1")
    vip_time:setVisible(true)
    if viptype == SHIPEXPERICESHOP then
        me.assignWidget(vip_time,"Text_title"):setString("战舰经验")
    else
        me.assignWidget(vip_time,"Text_title"):setString("战舰碎片")
    end

    self:initWithType(viptype)
end
function vipShopView:initWithType(viewType)
    self.pViewType = viewType
    if viewType then
       if viewType == 1 then
          self.typeNum = vipShopView.VIP_ITEMTYPE["time"]
          me.assignWidget(self,"title"):setString("VIP商店")      
          --self:setTimeIconAni(1)
          self.typeDatas = getResourceDataByType(self.typeNum)
          self:initShopTable()
       elseif viewType == 2 then
          me.assignWidget(self,"title"):setString("VIP商店")       
          self.typeNum = vipShopView.VIP_ITEMTYPE["point"]
          --self:setTimeIconAni(2)
          self.typeDatas = getResourceDataByType(self.typeNum)
          self:initShopTable()
       elseif viewType == 3 then
          me.assignWidget(self,"title"):setString("体力商店")         
          self.typeNum = vipShopView.VIP_ITEMTYPE["power"]
          self.typeDatas = getResourceDataByType(self.typeNum)
          self.shopType = 3
          self:initShopTable()
       elseif viewType == 5 then
          me.assignWidget(self,"title"):setString("出征上限")       
          self.typeNum = vipShopView.VIP_ITEMTYPE["buff"]
          self.typeDatas = getResourceDataByType(self.typeNum)
          self.shopType = 5
          self:initShopTable()
       elseif viewType == 11 then
          me.assignWidget(self,"title"):setString("战舰商店")    
          self.typeNum = vipShopView.VIP_ITEMTYPE["debris"]
          self.typeDatas = {}
          self.typeDatas[ITEM_ETC_TYPE] = {}
          self.typeDatas[ITEM_SHOP_TYPE] = table.values (user.shopList[viewType])
          table.sort(self.typeDatas[ITEM_SHOP_TYPE], function(a, b)
            return a.defid < b.defid
          end )
          self.shopType = 11
          self:initShopTable()
          dump (self.typeDatas)
       elseif viewType == 14 then
          me.assignWidget(self,"title"):setString("积分商店")    
          self.typeNum = vipShopView.VIP_ITEMTYPE["debris"]
          self.typeDatas = {}
          self.typeDatas[ITEM_ETC_TYPE] = {}
          self.typeDatas[ITEM_SHOP_TYPE] = table.values (user.shopList[viewType])
          table.sort(self.typeDatas[ITEM_SHOP_TYPE], function(a, b)
            return a.defid < b.defid
          end )
          self.shopType = 14
          self:initShopTable()
          dump (self.typeDatas)
       elseif viewType == 12 then
          local shipData = user.warshipData [user.curSelectShipType]
          --local strTitle = shipData.baseShipCfg.name .. "战商店"     
          me.assignWidget(self,"title"):setString("战舰商店")       
          local textShopLimit = me.assignWidget(self,"text_shop_limit")
          textShopLimit:setVisible (true)
          local buyed = user.shopLimit[viewType].buyed
          local limit = user.shopLimit[viewType].limit
          local curStr = "每日限购：".. (limit-buyed) .. "/" .. limit
          textShopLimit:setString (curStr)

          self.typeDatas = {}
          self.typeDatas[ITEM_ETC_TYPE] = {}
          for key, var in pairs(user.pkg) do
             local def = var:getDef()
             if me.toNum(def.useType) == 126 then
                table.insert(self.typeDatas[ITEM_ETC_TYPE], var)
             end
          end
          table.sort(self.typeDatas[ITEM_ETC_TYPE], function(a, b)
              return a.defid < b.defid
          end )

          
          self.typeDatas[ITEM_SHOP_TYPE] = table.values (user.shopList[viewType])
          table.sort(self.typeDatas[ITEM_SHOP_TYPE], function(a, b)
            return a.defid < b.defid
          end )
          self.shopType = 12
          self:initShopTable()         
       end
    end
end


function vipShopView:onEnter()
    print("vipShopView onEnter")
    me.doLayout(self, me.winSize)
   
    -- TODO:商城为战舰经验商城时
    if self.shopType == 12  then
      self.customListener = me.RegistCustomEvent ("shopBuyAmount", function (event)
        local buyed = event._userData.buyed
        local textShopLimit = me.assignWidget(self,"text_shop_limit")
        textShopLimit:setVisible (true)
        local limit = user.shopLimit[self.shopType].limit
        user.shopLimit[self.shopType].buyed = buyed
        local curStr = "每日限购：".. (limit-buyed) .. "/" .. limit
        textShopLimit:setString (curStr)
      end)
    end
end
function vipShopView:enterTransitionFinish()

end
function vipShopView:onExit()
    print("vipShopView onExit")
     UserModel:removeLisener(self.lisener) -- 删除消息通知
    if self.customListener then
      me.RemoveCustomEvent (self.customListener)
    end
end

function vipShopView:initShopTable()
    if self.shopTable then
       self.shopTable:removeFromParent()
       self.shopTable = nil
    end
    local itemNum = #self.typeDatas[ITEM_ETC_TYPE] + #self.typeDatas[ITEM_SHOP_TYPE]
    local cellNum = math.ceil(itemNum / 2)
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 569, 170
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local
        -- cell = table:dequeueCell()
       -- if nil == cell then
          cell = cc.TableViewCell:new()
          local shopCell_1 = recourceItem:create("rescourceItem.csb")
          local shopCell_2
          if self.typeDatas[ITEM_ETC_TYPE][idx*2+1] then
             local cellData = self.typeDatas[ITEM_ETC_TYPE][idx*2+1]
             local cellType = ITEM_ETC_TYPE
             shopCell_1:initWithData(cellData,cellType,function(node)
               self:close()
             end)
             shopCell_1:adjustForVipShop(self.shopType)
          else
             local cellData = self.typeDatas[ITEM_SHOP_TYPE][idx*2+1-#self.typeDatas[ITEM_ETC_TYPE]]
             local cellType = ITEM_SHOP_TYPE
             shopCell_1:initWithData(cellData,ITEM_SHOP_TYPE,function(node)
               self:close()
             end)
             shopCell_1:adjustForVipShop(self.shopType)
          end
           if self.typeDatas[ITEM_ETC_TYPE][idx*2+2] then
             local cellData = self.typeDatas[ITEM_ETC_TYPE][idx*2+2]
             local cellType = ITEM_ETC_TYPE
             shopCell_2 = recourceItem:create("rescourceItem.csb")
             shopCell_2:initWithData(cellData,cellType,function(node)
               self:close()
             end)
             shopCell_2:adjustForVipShop(self.shopType)
           elseif self.typeDatas[ITEM_SHOP_TYPE][idx*2+2-#self.typeDatas[ITEM_ETC_TYPE]] then
              print ("cell2 = rescourceItem")
             local cellData = self.typeDatas[ITEM_SHOP_TYPE][idx*2+2-#self.typeDatas[ITEM_ETC_TYPE]]
             local cellType = ITEM_SHOP_TYPE
             shopCell_2 = recourceItem:create("rescourceItem.csb")
             shopCell_2:initWithData(cellData,cellType,function(node)
               self:close()
             end)
             shopCell_2:adjustForVipShop(self.shopType)
           end
           shopCell_1:setAnchorPoint(0,0)
           shopCell_1:setPositionX(6)
           shopCell_1:setTag(123)
           cell:addChild(shopCell_1)
           if shopCell_2 then
              print ("cell2 set tag 124")
              shopCell_2:setTag(124)
              shopCell_2:setAnchorPoint(0,0)
              shopCell_2:setPositionX(shopCell_1:getContentSize().width + 16)
              cell:addChild(shopCell_2)
           end
        return cell
    end

    local function numberOfCellsInTableView(table)
        return cellNum
    end
    self.shopTable = cc.TableView:create(cc.size(1170,510))
    self.shopTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.shopTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.shopTable:setPosition(cc.p(5,5))
    self.shopTable:setDelegate()
    me.assignWidget(self,"Image_tableView"):addChild(self.shopTable)
    self.shopTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.shopTable:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.shopTable:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.shopTable:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.shopTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.shopTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.shopTable:reloadData()
end

function vipShopView:setTimeIconAni(viewType)
   if user.vipTime and user.vipTime > 0 then
       self.vipTime = math.floor(user.vipTime / 1000) - ( os.time() - user.vipLastUpdateTime)
       if self.vipTime > 0 then
              local icon
              if viewType == 1 then
                 icon = me.assignWidget(self,"Image_Time")
              elseif viewType == 2 then
                 icon = me.assignWidget(self,"Image_Point")
              else
                return
              end
            icon:loadTexture("vip_tubiao_shijian_liang.png",me.localType)
            local timeAni = createArmature("i_button_activit_1")
            timeAni:setScale(0.43)
            timeAni:setPosition(cc.p(icon:getContentSize().width / 2+2, icon:getContentSize().height / 2))
            icon:addChild(timeAni)
            timeAni:getAnimation():play("i_button_activity")
       end
   end
end