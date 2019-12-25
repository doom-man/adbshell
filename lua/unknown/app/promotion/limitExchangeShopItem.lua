 --[Comment]
--jnmo
limitExchangeShopItem = class("limitExchangeShopItem",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        local pCell = me.assignWidget(arg[1],(arg[2]))
        return pCell:clone():setVisible(true)
    end
end)
limitExchangeShopItem.__index = limitExchangeShopItem
function limitExchangeShopItem:create(...)
    local layer = limitExchangeShopItem.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function limitExchangeShopItem:ctor()   
    print("limitExchangeShopItem ctor") 
end
function limitExchangeShopItem:init()   
    print("limitExchangeShopItem init")
	
    return true
end
function limitExchangeShopItem:onEnter()
    print("limitExchangeShopItem onEnter") 
	--me.doLayout(self,me.winSize)  
end
function limitExchangeShopItem:onEnterTransitionDidFinish()
	print("limitExchangeShopItem onEnterTransitionDidFinish") 
end
function limitExchangeShopItem:onExit()
    print("limitExchangeShopItem onExit")    
end
function limitExchangeShopItem:close()
    self:removeFromParentAndCleanup(true)  
end
function limitExchangeShopItem:initCellInfo(data,discount)
    if data and discount then 
       self.price = math.ceil(data.price[2] * discount / 100)
       self.def = cfg[CfgType.ETC][data.defid]
       me.assignWidget(self,"a_s_goods_name"):setString(self.def.name)
       me.assignWidget(self,"a_s_goods_name"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))
       me.assignWidget(self,"a_s_goods_details"):setString("")
       me.assignWidget(self,"buy_num"):setString(self.price)
       me.assignWidget(self,"Image_shadow_top"):setVisible(true)
       me.assignWidget(self,"Upper_num"):setString(self.def.showtxt)
       me.assignWidget(self,"Image_icon"):loadTexture(getItemIcon(data.price[1]),me.localType)       
       local a_s_goods_icon =  me.registGuiClickEventByName(self,"a_s_goods_icon",function (args)
          showPromotion(self.def.id,1)
       end)
       a_s_goods_icon:setSwallowTouches(false)
       if self.def.showtxt == nil then 
          me.assignWidget(self,"Image_shadow_top"):setVisible(false)
       end
       local lnum =  me.assignWidget(self,"Text_limitNum")
       local limg = me.assignWidget(self,"Image_limit")
       if data.limit and data.buyed  and data.limit>0  then
          lnum:setVisible(true)
          limg:setVisible(true)
          lnum:setString("剩余数量:"..me.toStr(data.limit - data.buyed))
          me.setButtonDisable(me.assignWidget(self,"Button_buy"),data.limit - data.buyed > 0)
       else
          lnum:setVisible(false)
          limg:setVisible(false)           
       end
       me.assignWidget(self,"a_s_goods_quailty"):loadTexture(getQuality(self.def.quality),me.localType)
       me.assignWidget(self,"a_s_goods_icon"):loadTexture(getItemIcon(self.def.id),me.localType)
    end
end
