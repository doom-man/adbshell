 --[Comment]
--jnmo
allianceshopCell = class("allianceshopCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        local pCell = me.assignWidget(arg[1],(arg[2]))
        return pCell:clone():setVisible(true)
    end
end)
allianceshopCell.__index = allianceshopCell
function allianceshopCell:create(...)
    local layer = allianceshopCell.new(...)
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
function allianceshopCell:ctor()   
    print("allianceshopCell ctor") 
end
function allianceshopCell:init()   
    print("allianceshopCell init")
	
    return true
end
function allianceshopCell:onEnter()
    print("allianceshopCell onEnter") 
	--me.doLayout(self,me.winSize)  
end
function allianceshopCell:onEnterTransitionDidFinish()
	print("allianceshopCell onEnterTransitionDidFinish") 
end
function allianceshopCell:onExit()
    print("allianceshopCell onExit")    
end
function allianceshopCell:close()
    self:removeFromParentAndCleanup(true)  
end
function allianceshopCell:initCellInfo(data,discount)
    if data and discount then 
       self.price = math.ceil(data.price * discount / 100)
       self.def = cfg[CfgType.ETC][data.defid]
       me.assignWidget(self,"a_s_goods_name"):setString(self.def.name)
       me.assignWidget(self,"a_s_goods_name"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))
       me.assignWidget(self,"a_s_goods_details"):setString(self.def.describe)
       me.assignWidget(self,"buy_num"):setString(self.price)
       me.assignWidget(self,"Image_shadow_top"):setVisible(true)
       me.assignWidget(self,"Upper_num"):setString(self.def.showtxt)
       if self.def.showtxt == nil then 
          me.assignWidget(self,"Image_shadow_top"):setVisible(false)
       end
       local lnum =  me.assignWidget(self,"Text_limitNum")
       local limg = me.assignWidget(self,"Image_limit")
       if data.limit and data.buyed  and data.limit>0  then
          lnum:setVisible(true)
          limg:setVisible(true)
          lnum:setString("剩余数量:"..me.toStr(data.limit - data.buyed))
       else
          lnum:setVisible(false)
          limg:setVisible(false)
       end
       me.assignWidget(self,"a_s_goods_quailty"):loadTexture(getQuality(self.def.quality),me.localType)
       me.assignWidget(self,"a_s_goods_icon"):loadTexture(getItemIcon(self.def.id),me.localType)
    end
end