-- [Comment]
-- jnmo
payMgr = class("payMgr")
payMgr.__index = payMgr
payMgr.orderPrefix = "diamond"
function payMgr:ctor(data)
    print("payMgr:ctor()")
    self.data = data
    curOrderData = nil
    self.appleStoreInquireSucess = false
end
m_payMgr = nil
function payMgr.getInstance()
    if nil == m_payMgr then
        m_payMgr = payMgr.new()
    end
    return m_payMgr
end
function payMgr:checkChooseIap(data)
    self.data = data
--  if CC_NOT_GENUINE then
    NetMan:send(_MSG.rechargeCheck(data.id))   
--    else
--        if user.newBtnIDs[me.toStr(OpenButtonID_Iap)] ~= nil then
--            self.payview = payView:create("payView.csb")
--            self.payview:initWithData(self.data)
--            local parent = mainCity or pWorldMap
--            if parent.bshopBox then
--                parent.bshopBox:addChild(self.payview)
--            else
--                parent:addChild(self.payview, me.MAXZORDER)
--            end
--            me.showLayer(self.payview, "bg")
--        else
--            self:getOrderId(ORDER_SOURCE_APPLE)
--        end
--    end
end
function payMgr:closeChooseIap()
    if self.payview and self.payview.initWithData then
        self.payview:removeFromParentAndCleanup(true)
        self.payview = nil
    end
end
-- 获取订单号
function payMgr:getOrderId(storeId)
    local pay_http = getIAPUrl(storeId, self.data)
    if ( storeId == ORDER_SOURCE_ALIPY or storeId == ORDER_SOURCE_WEIXIN )  then
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
            local args = { url = pay_http }
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "AppController"
            local ok, ret = luaoc.callStaticMethod(className, "openAppstore", args)
            if not ok then              
            else                   
                cc.Director:getInstance():resume() 
                print("The ret is:", ret)
            end
        else
            print("仅支持IOS")
        end
    else        
        showWaitLayer(true)
        me.getHttpString(pay_http, function(rev)
            local jsondata = me.cjson.decode(rev)
            curOrderData = payOrder.new(jsondata.orderId, jsondata.payMode, jsondata.itemId, jsondata.id)
            curOrderData.jjdata = rev
            if me.toNum(curOrderData.payMode) == ORDER_SOURCE_APPLE then
                if self.appleStoreInquireSucess then
                    self:sendPayIAP()
                else
                    showTips("获取商品信息...")
                    local iap = IOSiAP_Bridge:getInstance()
                    showWaitLayer(true)
                    iap:requestProducts(curOrderData.itemId, function(tb, code)
                        disWaitLayer(true)
                        if me.toNum(code) == 1000 then
                            self:sendPayIAP()
                        else
                            showTips("获取商品信息失败，请稍后再试。")
                        end
                    end )
                end
            else
                disWaitLayer(true)
                self:sendPayIAP()
            end
        end , function(err)
            disWaitLayer(true)
        end )
    end
    -- payMgr:getInstance():checkIapOrder()
end
function payMgr:inquireAllItem()
    local iap = IOSiAP_Bridge:getInstance()
    local qitems = { }
    local tr = { }
    for key, var in pairs(user.recharge) do
        tr[var.gid] = 1
    end
    for key, var in pairs(tr) do
        table.insert(qitems, key)
    end
    iap:requestMoreProducts(qitems, function(tb, code)
        dump(tb)
        if me.toNum(code) == 1000 then
            -- self.bcanApple = true
            self.appleStoreInquireSucess = true
        else
            -- self.bcanApple = false
            self:inquireAllItem()
        end
    end )
end
function payMgr:checkIapOrder()
    local orderUrl = SharedDataStorageHelper():getPayOrderLog()
    if me.isValidStr(orderUrl) then
        me.getHttpString(orderUrl, function(rev)
            local jsonsdata = me.cjson.decode(rev)
            if jsondata then
                if jsondata.rs == 1 then
                    SharedDataStorageHelper():setPayOrderLog(nil)
                elseif jsondata.rs == 0 then
                    -- me.showMessageDialog(TID_IAP_FAILED)
                    SharedDataStorageHelper():setPayOrderLog(nil)
                end
            end
        end , function(err)

        end )
    else
        print("没有订单")
    end
end
function payMgr:getProductId()
    return payMgr.orderPrefix .. self.data.id
end
function payMgr:inquireItem(callfunc)
    local iap = IOSiAP_Bridge:getInstance()
    showWaitLayer(true)
    iap:requestProducts(curOrderData.itemId, function(tb, code)
        disWaitLayer(true)
        if me.toNum(code) == 1000 then
            if callfunc then
                callfunc()
            end
        else
            showTips("获取商品信息失败，请稍后再试。")
        end
    end )
end
function payMgr:sendPayIAP()
    if me.toNum(curOrderData.payMode) == ORDER_SOURCE_APPLE then
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
            local iap = IOSiAP_Bridge:getInstance()
            showWaitLayer(true)
            iap:requestPayment(curOrderData.itemId, 1, function(sucess, idr, num, recstr)
                disWaitLayer(true)
                if sucess then
                    -- 购买成功
                    curOrderData.otoken = recstr
                    local iapurl = conIAPUrl(curOrderData.payMode, curOrderData)
                    me.getHttpString(iapurl, function(rev)
                        local jsonsdata = me.cjson.decode(rev)
                        if jsondata then
                            if jsondata.rs == 1 then
                                showTips("购买成功")
                                SharedDataStorageHelper():setPayOrderLog(nil)
                                -- self:close()
                            elseif jsondata.rs == 0 then
                                me.showMessageDialog(TID_IAP_FAILED)
                                SharedDataStorageHelper():setPayOrderLog(nil)
                            end
                        end
                    end , function(err)
                        disWaitLayer(true)
                    end )
                else
                    -- 购买失败
                    showTips("购买失败")
                end
            end )
        else
            print("仅支持IOS")
        end
        -- end)
    elseif me.toNum(curOrderData.payMode) == ORDER_SOURCE_ALIPY then
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
            local args = { url = getAlipayOrderDataUrl(curOrderData.orderId) }
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "AppController"
            local ok, ret = luaoc.callStaticMethod(className, "alipayOrder", args)
            if not ok then
                cc.Director:getInstance():resume()
            else
                print("The ret is:", ret)
            end
            --            local function callback(param)
            --                if "success" == param then
            --                    print("object c call back success")
            --                end
            --            end
            --            luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
            --            luaoc.callStaticMethod(className,"callbackScriptHandler")
        else
            print("仅支持IOS")
        end
    elseif me.toNum(curOrderData.payMode) == ORDER_SOURCE_WEIXIN then
        if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
            local args = { url = getWxpayOrderDataUrl(curOrderData.orderId, wxAppID) }
            local luaoc = require "cocos.cocos2d.luaoc"
            local className = "AppController"
            local ok, ret = luaoc.callStaticMethod(className, "wxpayOrder", args)
            if not ok then
                cc.Director:getInstance():resume()
            else
                print("The ret is:", ret)
            end
            --            local function callback(param)
            --                if "success" == param then
            --                    print("object c call back success")
            --                end
            --            end
            --            luaoc.callStaticMethod(className,"registerScriptHandler", {scriptHandler = callback } )
            --            luaoc.callStaticMethod(className,"callbackScriptHandler")
        else
            print("仅支持IOS")
        end
    elseif me.toNum(curOrderData.payMode) == ORDER_SOURCE_JJ then
        --uid
          local js = me.cjson.decode(curOrderData.jjdata)
          local msg = {}
          msg.GoodsID = js.goodsID
          msg.GoodsAmount = js.goodsAmount
          msg.AppReqTime = js.appReqTime
          msg.AppOrder = js.appOrder
          msg.AppOrderSign = js.appOrderSign
          msg.AppExtendData = js.appExtendData
          msg.PayChannelPattern = js.payChannelPattern
          msg.NotifyUrl  = js.notifyUrl
          jjGameSdk.pay(me.cjson.encode(msg),function (ret)      
                if tonumber(ret) == 20000 or tonumber(ret) == 10201 then
                      NetMan:send(_MSG.rechargeCancel())
                      me.showMessageDialog("支付取消",function (evt) end,1)
                end    
          end)
    end
end