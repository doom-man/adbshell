--道具使用    2015-12-03
BackpackBuy = class("BackpackBuy",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
BackpackBuy.__index = BackpackBuy
function BackpackBuy:create(...)
    local layer = BackpackBuy.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end
function BackpackBuy:ctor()
    self.Text_ItemName = me.assignWidget(self, "Text_ItemName")
    self.Image_quility = me.assignWidget(self, "Image_quility")
    self.Image_itemPng = me.assignWidget(self, "Image_itemPng")
    self.Text_desc = me.assignWidget(self, "Text_desc")
    self.Text_confirm = me.assignWidget(self, "Text_confirm")
    self.Text_diamondNum = me.assignWidget(self, "Text_diamondNum")
    self.work_num = me.assignWidget(self, "work_num")
    self.imageDiamand = me.assignWidget(self, "Image_8")
    self.shopType = 1 -- 1 资源商店   2 VIP商店   3 体力商店 4 联盟商店
    self.maxDiamond = 0
    self.price = 0
    self.pUseNum = 0
end
-- 判断是否点击在节点中
function BackpackBuy:contains(node, x, y)
        local point = cc.p(x,y)
        local pRect = cc.rect(0,0,node:getContentSize().width,node:getContentSize().height)
        local locationInNode = node:convertToNodeSpace(point)     -- 世界坐标转换成节点坐标
        return cc.rectContainsPoint(pRect, locationInNode)
end
function BackpackBuy:close()
    self:removeFromParentAndCleanup(true)
end
function BackpackBuy:init()
    me.registGuiClickEventByName(self,"btn_ok",function (node)
--        if self.shopType == 3 then
--           if user.currentPower == user.maxPower then
--              showTips("体力已满,不能购买")
--              return
--           elseif user.currentPower + self.pCfgData.useEffect > user.maxPower then
--              local getNum = user.maxPower - user.currentPower
--              self.confirmView = cc.CSLoader:createNode("MessageBox.csb")
--              me.assignWidget(self.confirmView,"msg"):setString("领主大人,由于体力值将会超出上限,所以本次购买只能获得"..getNum.."点体力,您确定购买吗?")
--              me.registGuiClickEventByName(self.confirmView,"btn_ok",function(node)
--                  self:GoodsUse()
--                  self.confirmView:removeFromParentAndCleanup(true)
--                  self.confirmView = nil
--                  self:close()
--              end)
--              me.registGuiClickEventByName(self.confirmView,"btn_cancel",function(node)
--                  self.confirmView:removeFromParentAndCleanup(true)
--                  self.confirmView = nil
--              end)
--              self:addChild(self.confirmView)
--              me.showLayer(self.confirmView,"msgBox")
--              return
--            end
--        end
        self:GoodsUse()
        self:close()
    end)

    me.registGuiClickEventByName(self,"fixLayout",function (node)
        local pTouch = node:getTouchBeganPosition()
        local pNode = me.assignWidget(self, "Node_size")
        pNode:setContentSize(cc.size(700,386))
        pNode:setAnchorPoint(cc.p(0.5,0.5))
        local pPoint = self:contains(pNode,pTouch.x,pTouch.y)
        if pPoint then
        -- 点击在节点中
        else
         -- 点击在节点外
         self:close()
        end
    end)

    me.registGuiClickEventByName(self, "maxBtn", function(node)
        self.pUseNum = self.maxDiamond
        local pPercent = (self.pUseNum/self.maxDiamond)*100
        self.pSliber:setPercent(pPercent)
        self:setUI(self.pUseNum)
    end)

    return true
end
function BackpackBuy:GoodsUse()
    if self.shopType == ALLIANCESHOP_TYPE then
        print("联盟商店购买")
        NetMan:send(_MSG.shopBuy(self.shopType,self.pUid,self.pUseNum,0))
    elseif self.shopType == SHIPDEBRISSHOP then
        print("碎片商店")
        NetMan:send(_MSG.shopBuy(self.shopType,self.pUid,self.pUseNum,0))

    elseif self.shopType == SHIPEXPERICESHOP then
        if self.isBuyItem == true then
            NetMan:send(_MSG.shopBuy(self.shopType,self.pUid,self.pUseNum,0))
        else
            NetMan:send(_MSG.Ship_exp_buy(user.curSelectShipType, self.defid, self.pUseNum))
        end
    elseif self.shopType == PLURNTALESCORESHOP or self.shopType == SKINSHOP or self.shopType == ELEVENSHOP or self.shopType == DIGORE_SHOP  then
        NetMan:send(_MSG.shopBuy(self.shopType,self.pUid,self.pUseNum,0))
    else         
        NetMan:send(_MSG.shopBuy(self.shopType,self.pUid,self.pUseNum,self.pCfgData.isUse))
    end
end
-- 点击的物品数据
function BackpackBuy:setData(pData,specialPrice)
    self.pData=pData
     if pData~=nil then
        self.defid = pData.defid
        self.pCfgData = cfg[CfgType.ETC][pData["defid"]]         -- 道具的配置数据
        self.pUid = pData["uid"]
        if self.shopType == ALLIANCESHOP_TYPE and specialPrice then
           self.price = specialPrice
           self.maxDiamond = math.min( math.floor(user.allianceGivenData.gongxian/self.price) ,(pData.limit - pData.buyed))
           me.assignWidget(self,"Image_8"):loadTexture("ziyuan_anniu_gongxianzhi.png",me.localType)
        elseif self.shopType == SHIPDEBRISSHOP then
           self.price = pData.price
           self.maxDiamond = math.min( math.floor(user.diamond/self.price) ,(pData.limit - pData.buyed))
        elseif self.shopType == VIPLEVELSHOP then
           self.price = pData.price
           self.maxDiamond = math.min( math.floor(user.paygem /self.price) ,(pData.limit - pData.buyed)) 
           local icon =  me.assignWidget(self,"Image_8")
           icon:loadTexture("yuanbao.png",me.localType)
           me.resizeImage(icon,34,34)
        elseif self.shopType ==  PLURNTALESCORESHOP then
           self.price = pData.price
           self.maxDiamond = math.min( math.floor(user.turnplateScore /self.price) ,(pData.limit - pData.buyed)) 
           local icon =  me.assignWidget(self,"Image_8")
           icon:loadTexture("turnplateScore.png",me.localType)
           me.resizeImage(icon,34,34) 
        elseif self.shopType ==  DIGORE_SHOP then
           self.price = pData.price[2]
           self.maxDiamond = math.min( math.floor(user.digoreScore /self.price) ,(pData.limit - pData.buyed)) 
           local icon =  me.assignWidget(self,"Image_8")
           icon:loadTexture("digore8.png",me.localType)
           me.resizeImage(icon,34,34) 
        elseif self.shopType == SHIPEXPERICESHOP then
           self.price = pData.price
           if self.isBuyItem == true then -- 购买道具限制条件为钻石和购买次数
                self.maxDiamond = math.min( math.floor(user.diamond/self.price) ,(user.shopLimit[self.shopType].limit - user.shopLimit[self.shopType].buyed))
            else -- 如果是使用 限制条件是拥有数量和最大刚好超出经验满
                self.Text_diamondNum:setVisible (false)
                self.imageDiamand:setVisible (false)
                local count = 0
                for k, v in pairs (user.pkg) do
                    if self.defid == v.defid then
                        count = count + v.count
                    end
                end
                self.maxDiamond = count
            end
        elseif self.shopType == VIPSHOP_TYPE  then
            me.assignWidget(self,"Image_8"):loadTexture(pData:getCurrencyIcon(),me.localType)
            me.assignWidget(self,"Image_8"):ignoreContentAdaptWithSize(false)
            self.price = pData.price
            self.maxDiamond = math.floor(pData:getCurrencyNum()/self.price)
        elseif self.shopType == ELEVENSHOP then
            me.assignWidget(self,"Image_8"):loadTexture(pData:getCurrencyIcon(),me.localType)
            me.assignWidget(self,"Image_8"):ignoreContentAdaptWithSize(false)
            self.price = pData.price
            self.maxDiamond =math.min( math.floor(pData:getCurrencyNum()/self.price), math.min( (pData.limit - pData.buyed) ,pData.tote))
        elseif self.shopType== SKINSHOP  then
           self.price = pData.price[2]          
           self.maxDiamond = math.min( math.floor(getItemNum(pData.price[1]) /self.price) ,(pData.limit - pData.buyed)) 
           me.assignWidget(self,"Image_8"):loadTexture(pData:getCurrencyIcon(),me.localType)
           me.assignWidget(self,"Image_8"):ignoreContentAdaptWithSize(false)
        elseif self.shopType == LIMIT_EXCHANGE_SHOP then
           self.price = pData.price[2]          
           self.maxDiamond = math.min( math.floor( user.limitScore /self.price ) ,(pData.limit - pData.buyed)) 
           me.assignWidget(self,"Image_8"):loadTexture(pData:getCurrencyIcon(),me.localType)
           me.assignWidget(self,"Image_8"):ignoreContentAdaptWithSize(false)
       else
           self.price = pData.price
           self.maxDiamond = math.floor(user.diamond/self.price)
        end
        self.Text_ItemName:setString(self.pCfgData.name)
        self.Text_desc:setString(self.pCfgData.describe)
        if self.isBuyItem == true then
            self.Text_confirm:setString(TID_BACKPACK_BUY)
        else
            self.Text_confirm:setString("领主大人，你确定要购买或使用此物品吗？")
        end
        self.Image_quility:loadTexture(getQuality(self.pCfgData.quality))
        self.Image_itemPng:loadTexture("item_"..self.pCfgData.icon..".png",me.localType)
        self.pUseNum = 1
        self:setUI(self.pUseNum)
        --self.work_num:setString(self.pUseNum)
        --self.Text_diamondNum:setString(self.pUseNum*self.price)
        local function sliderEvent(sender, eventType)
            if eventType == ccui.SliderEventType.percentChanged then
                local percent = sender:getPercent() / 100
                local pUseNum = math.floor(percent*self.maxDiamond)
                self:setUI(pUseNum)
            end
        end
        local function sliderTouchEvent(sender,eventType)
            if eventType == ccui.TouchEventType.ended and self.maxDiamond > 0 then
                if self.pUseNum <= 0 then
                   sender:setPercent(1/self.maxDiamond*100)
                   self:setUI(1)
                end
                if self.pUseNum >= self.maxDiamond then
                    sender:setPercent(100)
                    tmpNum = self.maxDiamond
                    self:setUI(self.maxDiamond)
                end
            end
        end
        self.pSliber = me.assignWidget(self,"Slider_worker")
        self.pSliber:setPercent(1/self.maxDiamond*100)
        self.pSliber:addEventListener(sliderEvent)
        self.pSliber:addTouchEventListener(sliderTouchEvent)
        -- 增加
        local pButtonAdd = me.assignWidget(self,"btn_add")
        me.registGuiClickEvent(pButtonAdd,function (node)
            if self.pUseNum < self.maxDiamond then
                local pUseNum = self.pUseNum+1
                local pPercent = (pUseNum/self.maxDiamond)*100
                self.pSliber:setPercent(pPercent)
                self:setUI(pUseNum)
            end
        end)
        -- 减少
        local pButtonAdd = me.assignWidget(self,"btn_reduce")
        me.registGuiClickEvent(pButtonAdd,function (node)
            if self.pUseNum > 1 then
                local pUseNum = self.pUseNum-1
                local pPercent = (pUseNum/self.maxDiamond)*100
                self.pSliber:setPercent(pPercent)
                self:setUI(pUseNum)
            end
        end)
    end
end
function BackpackBuy:setUI(num_)
    self.pUseNum = num_
    self.work_num:setString(self.pUseNum)

    if self.shopType==ELEVENSHOP then
        local tempComsume = user.elevenShopInfos.comsume
        local needPriceValue=0
        for i=1, num_ do
            local comsumeAgio = tonumber(string.format("%.3f", 2 / math.pow(tempComsume * 5 + 18200, 0.1) + 0.25))
            local oncePrice = math.ceil(self.pData.agioBefore*self.pData.agio* comsumeAgio)
            needPriceValue=needPriceValue+oncePrice
            tempComsume = tempComsume+oncePrice
        end
        self.Text_diamondNum:setString(needPriceValue)
    else
        self.Text_diamondNum:setString(self.price*self.pUseNum)
    end
end

function BackpackBuy:isBuyItem( isBuy )
    self.isBuyItem = isBuy
end

function BackpackBuy:onEnter()
    me.doLayout(self, me.winSize)
    print("BackpackBuy:onEnter()")
end
function BackpackBuy:onExit()
    print("BackpackBuy:onExit()")
end
function BackpackBuy:adjustForVipShop(shopType)
   self.Image_itemPng:setContentSize(cc.size(159,159))
   self.shopType = shopType
   --self.Image_itemPng:setPositionY(self.Image_itemPng:getPositionY())
end

function BackpackBuy:setShopType(shopType)
   self.shopType = shopType
end