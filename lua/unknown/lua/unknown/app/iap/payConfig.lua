-- 平台 
ORDER_SOURCE_APPLE = 1-- 苹果
ORDER_SOURCE_ALIPY = 2-- 支付宝
ORDER_SOURCE_WEIXIN = 3-- 微信
ORDER_SOURCE_JJ = 9 --JJ
wxAppID = "wxec4fb106ea72b09e"
-- 获取 不同平台的地址
function getIAPUrl(store, data)
    if store == ORDER_SOURCE_APPLE then
        local fstr = IAP_URL.."/mgame-pay/appstore?source=%s&sid=%s&uid=%s&itemId=%s&id=%s&bid=%s"
        return string.format(fstr, user.source, user.sid, user.uid, data.gid,data.id,store)
    elseif store == ORDER_SOURCE_ALIPY then
        local fstr = nil     
        fstr = IAP_URL.."/mgame-pay/alipay?source=%s&sid=%s&uid=%s&itemId=%s&id=%s"
        return string.format(fstr, user.source, user.sid, user.uid, data.gid,data.id)       
    elseif store == ORDER_SOURCE_WEIXIN then
        local fstr = nil          
        fstr = IAP_URL.."/mgame-pay/weixin/unifiedorder?source=%s&sid=%s&uid=%s&itemId=%s&id=%s"
        return string.format(fstr, user.source, user.sid, user.uid, data.gid,data.id)
       
    elseif store == ORDER_SOURCE_JJ then
        local fstr = IAP_URL.."/mgame-pay/jjCommonorder?source=%s&sid=%s&uid=%s&itemId=%s&id=%s&mode=%s"
        return string.format(fstr, user.source, user.sid, user.uid, data.gid,data.id,store)
    end
end
function getAlipayOrderDataUrl(oid)
   local fstr = IAP_URL.."/mgame-pay/alipayto?orderId=%s" 
   return string.format(fstr, oid)
end
function getWxpayOrderDataUrl(oid,wxappid)
   local fstr = IAP_URL.."/mgame-pay/weixin/pay?orderId=%s&appid=%s" 
   return string.format(fstr, oid,wxappid)
end
-- 组合验证地址
function conIAPUrl(store, orderdata)
    if store == ORDER_SOURCE_APPLE then
        local fstr = IAP_URL.."/mgame-pay/apple/buyverify?orderId=%s&receipt=%s"
        local rstr = string.format(fstr, orderdata.orderId, me.Helper:base64EncodeLua(orderdata.otoken))
        SharedDataStorageHelper():setPayOrderLog(rstr)
        return rstr
    elseif store == ORDER_SOURCE_ALIPY then
       
    elseif store == ORDER_SOURCE_WEIXIN then
    end
end
