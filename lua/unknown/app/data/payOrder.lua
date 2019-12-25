--[Comment]
--jnmo 订单
payOrder = class("payOrder")
payOrder.__index = payOrder
function payOrder:ctor(oid,payMode,itemid,id)
    print("payOrder:ctor()")   
    self.orderId = oid   -- 订单号
    self.itemId = itemid
    self.otoken = nil  --apple返回给我的结果 
    self.id = id
    --充值平台
    self.payMode = payMode or ORDER_SOURCE_APPLE
end


