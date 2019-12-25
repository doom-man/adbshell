bRechargeItem = class("bRechargeItem",function (...)   
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end    
end)
bRechargeItem.__index = bRechargeItem
function bRechargeItem:create(...)
    local layer = bRechargeItem.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then 
                    layer:enterTransitionFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function bRechargeItem:ctor()   
    print("bRechargeItem ctor")
    self.itemData = nil 
end
function bRechargeItem:init()   
    print("bRechargeItem init")
  
    return true
end
function bRechargeItem:getBuildData()
    return self.itemData
end
function bRechargeItem:initWithData(itemData, guideType,force)
   print("itemData.diamond",itemData)
   self.itemData = itemData
   self.guideType = guideType
   if force then
        self.force = force
   end
   local name = me.assignWidget(self,"name")
   local xg = me.assignWidget(self,"xiangou")   
   local giveBg = me.assignWidget(self,"giveBg")
   local give = me.assignWidget(self,"give")
   local icon = me.assignWidget(self,"icon")   
   local rmbNum = me.assignWidget(self,"rmbNum")  
   icon:ignoreContentAdaptWithSize(true)
   icon:loadTexture("shangcheng_tubi_zuanshi_"..itemData.icon..".png",me.localType)
   name:setString(itemData.jjgold)
   local title = me.assignWidget(self,"rechargeTitle")
   title:setContentSize(cc.size(32 + name:getContentSize().width, 35))
   title:setAnchorPoint(0.5,0.5)
   title:setPositionX(me.assignWidget(self,"bHall"):getContentSize().width / 2 - 5)
   xg:setVisible(false) 
   if me.toNum(itemData.limit) > 0 then 
        xg:setVisible(true)
        give:setString("额外赠送"..(itemData.limitgivegold or 0).."(限购"..itemData.limit.."次)")
   elseif me.toNum(itemData.jjgive) > 0 then
        give:setString("额外赠送"..itemData.jjgive)
   else
        giveBg:setVisible(false)
        give:setVisible(false)
   end
   self.id = itemData.id
   me.registGuiClickEvent(self,function(node)      
      payMgr:getInstance():checkChooseIap(self.itemData) 
      me.setWidgetCanTouchDelay(node,1)   
   end)
   rmbNum:setString("￥"..itemData.rmb)
end
function bRechargeItem:setGuideView()
end
function bRechargeItem:onEnter()
end
function bRechargeItem:enterTransitionFinish()
end
function bRechargeItem:onExit()
    print("bShopItem onExit")    
    if self.guideLayer then
        self.guideLayer:removeFromParentAndCleanup(true)
    end
end

