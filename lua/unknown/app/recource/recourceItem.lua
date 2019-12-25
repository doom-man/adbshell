recourceItem = class("recourceItem", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
recourceItem.__index = recourceItem
function recourceItem:create(...)
    local layer = recourceItem.new(...)
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
function recourceItem:ctor()
    self.itemData = nil
    self.itemDef = nil
    self.itemType = nil
    self.callBack = nil
    self.shopType = 1
    print("recourceItem ctor")
end
function recourceItem:init()
    self.Text_itemNum = me.assignWidget(self, "Text_itemNum")
    self.Text_title = me.assignWidget(self, "Text_title")
    self.Text_title:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2)) 
    self.Text_desc = me.assignWidget(self, "Text_desc")
    self.Image_itemQulity = me.assignWidget(self, "Image_itemQulity")
    self.Image_itemIcon = me.assignWidget(self, "Image_itemIcon")
    self.Image_shadow_down = me.assignWidget(self, "Image_shadow_down")
    self.Upper_num = me.assignWidget(self, "Upper_num")
    self.Button_use = me.assignWidget(self, "Button_use")
    self.Text_btnTitle = me.assignWidget(self, "Text_btnTitle")
    self.Image_diamond = me.assignWidget(self, "Image_diamond")
    self.Text_diamondNum = me.assignWidget(self, "Text_diamondNum")
    self.Image_shadow_top = me.assignWidget(self, "Image_shadow_top")
    self.text_purchase = me.assignWidget(self, "text_purchase")
    self.text_purchase:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2)) 
    self.text_purchase:setVisible(false)
    me.registGuiClickEvent(self.Button_use, function(node, event)
        if ITEM_ETC_TYPE == self.itemType then      
            if self.shopType ~= 5 then
                self.BackpackUse = BackpackUse:create("BackpackUse.csb")
                me.runningScene():addChild(self.BackpackUse, me.MAXZORDER);
                self.BackpackUse:setData(self.itemData)            
                me.showLayer(self.BackpackUse, "bg")
            else
                local curbuffdata = cfg[CfgType.CITY_BUFF][tonumber( self.itemDef.useEffect)]
                local have = false
                for key, var in pairs(user.Role_Buff) do
					for k1, v1 in pairs(var) do
						if curbuffdata.type==k1 and curbuffdata.stype == v1.stype and v1.countDown > 0 then
							have = true
						end
					end
                end

                if have then
                    me.showMessageDialog("使用该道具会覆盖当前效果，是否确认？", function(evt)
                        if evt == "ok" then
                            NetMan:send(_MSG.userCityBuffItem(self.itemDef.id))
                        end
                    end )
                else
                    NetMan:send(_MSG.userCityBuffItem(self.itemDef.id))
                    if user.diamond >= tonumber(self.itemData.diamondPrice or 0) then
                        NetMan:send(_MSG.userCityBuffItem(self.itemData.id))
                    else
                        askToRechage(0)
                    end
                end
            end
        else

            if self.itemData:checkHaveEnough() then
                if self.shopType ~= 5 then
                    self.BackpackBuy = BackpackBuy:create("BackpackBuy.csb")
                    if self.shopType == 2 or self.shopType == 11 or self.shopType == 12  or self.shopType == 14 then
                        self.BackpackBuy:adjustForVipShop(self.shopType)
                        if self.shopType == 12 then
                            self.BackpackBuy:isBuyItem(node.isBuyItem)
                        end
                    end
                    local parent = me.runningScene()
                    parent:addChild(self.BackpackBuy, me.MAXZORDER);
                    self.BackpackBuy:setData(self.itemData)
                    me.showLayer(self.BackpackBuy, "bg")
                else
                    local curbuffdata = cfg[CfgType.CITY_BUFF][tonumber( self.itemDef.useEffect)]
                    local have = false
                    for key, var in pairs(user.Role_Buff) do
						for k1, v1 in pairs(var) do
							if curbuffdata.type==k1 and curbuffdata.stype == v1.stype and v1.countDown > 0 then
								have = true
							end
						end
                    end

                    if have then
                        me.showMessageDialog("使用该道具会覆盖当前效果，是否确认？", function(evt)
                            if evt == "ok" then
                               NetMan:send(_MSG.userCityBuffItem(self.itemDef.id))
                            end
                        end )
                    else
                        me.showMessageDialog("确定花费"..self.itemData.price..  "钻石购买当前道具？", function(e)
                             if e == "ok" then
                                NetMan:send(_MSG.userCityBuffItem(self.itemDef.id))
                             end
                        end)
                    end
                end
            else
                showTips("道具不足")
            end
        end
    end )

    return true
end
function recourceItem:initWithData(data_, type_, cb_)
    self.itemData = data_
    self.itemDef = data_:getDef()
    self.itemType = type_
    self.callBack = cb_
    print("self.itemData.defid = "..self.itemData.defid)
end
function recourceItem:flushData()
    self.Text_title:setString(self.itemDef.name)
    self.Text_desc:setString(self.itemDef.describe)
    if self.itemDef.showtxt then
        self.Image_shadow_top:setVisible(true)
        self.Upper_num:setString(self.itemDef.showtxt)
    else
        self.Image_shadow_top:setVisible(false)
        self.Upper_num:setVisible(false)
    end

    self.Image_itemIcon:loadTexture("item_" .. self.itemDef.icon .. ".png")
    self.Image_itemQulity:loadTexture(getQuality(self.itemDef["quality"]), me.localType)
    if self.itemData.sellType then
        self.Image_diamond:loadTexture(self.itemData:getCurrencyIcon(), me.localType)
    end
    me.resizeImage(self.Image_diamond, 33, 33)
    local isHaved = false
    if ITEM_ETC_TYPE == self.itemType then        
        isHaved = true
    end
    self.Image_diamond:setVisible(not isHaved)
    if isHaved then
        -- 背包里的
        self.Button_use:loadTextureNormal("ui_ty_button_cheng_213x63.png", me.localType)
        self.Text_btnTitle:setString("使用")
        self.Text_itemNum:setString(self.itemData.count)
    else
        -- 商城里
        self.Button_use:loadTextureNormal("ui_ty_button_lv_213x63.png", me.localType)
        if self.itemDef.isUse == 0 then
            self.Text_btnTitle:setString("购买")
        else
            self.Text_btnTitle:setString("购买并使用")
        end
        if me.toNum(self.itemData.amount) > 0 then
            self.Text_itemNum:setString(self.itemData.amount)
        end
        self.Image_shadow_down:setVisible(me.toNum(self.itemData.amount) > 0)
        if self.itemData.price then
            self.Text_diamondNum:setString(self.itemData.price)
        end
    end
    if self.shopType == SHIPDEBRISSHOP then
        self.Text_btnTitle:setString("购买")
        self.text_purchase:setVisible(true)
        if self.itemData.buyed and self.itemData.limit then
            local leftAmount = self.itemData.limit - self.itemData.buyed
            self.text_purchase:setString("每日限购:" .. leftAmount .. "/" .. self.itemData.limit)
            if leftAmount <= 0 then
                self.Button_use:setEnabled(false)
                self.Button_use:setBright(false)
            end
        end
    elseif self.shopType == 14 then
        self.text_purchase:setVisible(true)
        if self.itemData.buyed and self.itemData.limit then
            local leftAmount = self.itemData.limit - self.itemData.buyed
            self.text_purchase:setString("每日限购:" .. leftAmount .. "/" .. self.itemData.limit)
            if leftAmount <= 0 then
                self.Button_use:setEnabled(false)
                self.Button_use:setBright(false)
            end
        end
    elseif self.shopType == SHIPEXPERICESHOP then
        local isBuyItem = true
        local strBtnTitle = "购买"
        self.Text_desc:setFontSize(18)
        -- self.Button_use:loadTextureNormal ("ziyuan_anniu_lv.png")
        self.text_purchase:setVisible(false)
        self.Image_shadow_down:setVisible(false)
        self.Text_diamondNum:setVisible(true)
        self.Image_diamond:setVisible(true)
        for k, v in pairs(user.pkg) do
            local def = v:getDef()
            if self.itemData.defid == v.defid and (def.isUse and tonumber(def.isUse) == 1 or (me.toNum(def.useType) == 126 and isHaved))  then  ---126 背包里的战舰经验在这儿可便用
                isBuyItem = false
                strBtnTitle = "使用"
                self.text_purchase:setVisible(false)
                self.Image_shadow_down:setVisible(true)
                self.Text_itemNum:setString(tostring(v.count))
                self.Text_diamondNum:setVisible(false)
                self.Image_diamond:setVisible(false)
                -- self.Button_use:loadTextureNormal ("ziyuan_anniu_huang.png")
                break
            end
        end
        self.Text_btnTitle:setString(strBtnTitle)
        self.Button_use.isBuyItem = isBuyItem

        -- 购买次数为0
        if isBuyItem == true and user.shopLimit[self.shopType].limit - user.shopLimit[self.shopType].buyed <= 0 then
            self.Button_use:setEnabled(false)
            self.Button_use:setBright(false)
        end
        -- if self.itemData.buyed and self.itemData.limit then
        --     local leftAmount = self.itemData.limit-self.itemData.buyed
        --     self.text_purchase:setString ("每日限购:" .. leftAmount .. "/" .. self.itemData.limit)
        --     if leftAmount <= 0 and isBuyItem == true then
        --         self.Button_use:setEnabled (false)
        --         self.Button_use:setBright (false)
        --     end
        -- end
    end
end
function recourceItem:onEnter()
    self:flushData()
    if self.shopType == 11 or self.shopType == 12 then
        if not self.msgListener1 then
            self.msgListener1 = me.RegistCustomEvent("shopBuyAmount", function(event)
                local itemId = event._userData.itemId
                local buyed = event._userData.buyed
                if self.shopType == 11 and itemId == self.itemData.uid then
                    self.itemData.buyed = buyed
                    self:flushData()
                end
            end )
        end
        
 --       me.RemoveCustomEvent(self.msgListener2)        
--        if not self.msgListener2 then
--            print(" -----------------  "..self.itemData.defid)
--            self.msgListener2 = me.RegistCustomEvent("shopBuy"..self.itemData.defid, function(event)
--                local shopDefId = event._userData.shopDefId
--                local shopAmount = event._userData.shopAmount
--                if self.shopType == 12 and shopDefId == self.itemData.defid then
--                    print("msg shop buy 3922 -----------------")
--                    NetMan:send(_MSG.Ship_exp_buy(user.curSelectShipType, shopDefId, shopAmount))
--                end
--            end )
--        end
        if not self.msgListener3 then
            self.msgListener3 = me.RegistCustomEvent("shopUserExp", function(event)
                self:flushData()
            end )
        end
    end
end
function recourceItem:onEnterTransitionDidFinish()
end
function recourceItem:onExit()
    print("recourceItem:onExit()")
    if self.msgListener1 then
        me.RemoveCustomEvent(self.msgListener1)
    end
    if self.msgListener2 then
        me.RemoveCustomEvent(self.msgListener2)
    end
    if self.msgListener3 then
        me.RemoveCustomEvent(self.msgListener3)
    end
end
function recourceItem:close()
    self:removeFromParentAndCleanup(true)
end

function recourceItem:adjustForVipShop(shopType)
    if self.itemData.itemtype == vipShopView.VIP_ITEMTYPE["time"] then
        self.itemDef.showtxt = string.gsub(self.itemDef.showtxt, "天", "d")
    end
    self.Image_itemIcon:setContentSize(cc.size(115, 115))
    self.Image_itemIcon:setPositionY(self.Image_itemIcon:getPositionY() -2)
    self.shopType = shopType
end