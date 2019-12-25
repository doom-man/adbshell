-- [Comment]
-- jnmo
rechageShopLayer = class("rechageShopLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
rechageShopLayer.__index = rechageShopLayer
function rechageShopLayer:create(...)
    local layer = rechageShopLayer.new(...)
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
function rechageShopLayer:ctor()
    print("rechageShopLayer ctor")
end
function rechageShopLayer:init()
    print("rechageShopLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.wlist = me.assignWidget(self,"listRecharge")
    self:initList()
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.RECHARGE) then
            self:initList()      
        end
    end)
    return true
end
function rechageShopLayer:initList()
    self.wlist:removeAllChildren()
    local width_list = 900
    local height_list = 490
    local spw = 10
    local sph = 0
    local index = 0
    local h = 0
    local m = 3    
    local temp = {}
    for key, var in pairs(user.recharge) do
        if var.type < 3 then
             table.insert(temp,var)
        end
    end
    local titem = me.createNode("shopItem/rechargeItem.csb")
    local num = table.nums(temp)
    for key, var in pairs(temp) do        
            local item = bRechargeItem:create(titem,"bHall")
            item:initWithData(var)
            item:setVisible(true)
            local iSize = item:getContentSize()
            dump(iSize)
            local i = 0
            if num % m ~= 0 then
                i = 1
            end
            local height =(math.floor(num / m) + i) *(iSize.height + sph)
            if height < height_list then
                height = height_list
            end
            item:setPosition((iSize.width + spw) *(index % m + 1) - iSize.width / 2,
            height - math.floor(index / m) *(iSize.height + sph) - iSize.height / 2 - sph)
            index = index + 1           
            self.wlist:addChild(item)
            self.wlist:setInnerContainerSize(cc.size(width_list, height))      
    end

end
function rechageShopLayer:onEnter()
    print("rechageShopLayer onEnter")
    me.doLayout(self, me.winSize)
end
function rechageShopLayer:onEnterTransitionDidFinish()
    print("rechageShopLayer onEnterTransitionDidFinish")
end
function rechageShopLayer:onExit()
    print("rechageShopLayer onExit")
    UserModel:removeLisener(self.modelkey)
end
function rechageShopLayer:close()
    self:removeFromParent()
end
