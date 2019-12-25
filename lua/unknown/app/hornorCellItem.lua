--[Comment]
--jnmo
hornorCellItem = class("hornorCellItem",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return me.assignWidget(arg[1],arg[2])
    end
end)
hornorCellItem.__index = hornorCellItem
function hornorCellItem:create(...)
    local layer = hornorCellItem.new(...)
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
function hornorCellItem:ctor()   
    print("hornorCellItem ctor") 
end
function hornorCellItem:init()   
    print("hornorCellItem init")
    self.num = me.assignWidget(self,"Text_Item_num")
    self. icon = me.assignWidget(self,"icon") 
    self.item_select = me.assignWidget(self,"item_select")      
    self.evt = me.RegistCustomEvent("hornorCellItem_Choose",function (evt)
          local c  =  evt._userData          
          self.item_select:setVisible(self.chooseIdx == tonumber( c ))
    end)   
    self.lock = me.assignWidget(self,"lock")
    self.circle = me.assignWidget(self,"Image_1")
    
    return true
end
function hornorCellItem:initWithData(data,b)
      self.data = data
      self.need = b
      self.num:setString(data.lv.."/"..data.maxLv)  
      self.icon:loadTexture("icon_tech_".. cfg[CfgType.HORNOR_TECH][ data.defId ].icon..".png",me.localType)      
      self.icon:ignoreContentAdaptWithSize(false)  
      self.defid = data.defId
      self.lock:setVisible(not b)
      if b  then
           me.Helper:normalImageView(self)
           me.Helper:normalImageView(self.icon)
           me.Helper:normalImageView(self.circle)
           self.num:setTextColor(cc.c3b(214, 204, 173))
      else
           me.Helper:grayImageView(self)
           self.num:setTextColor(cc.c3b(127, 127, 127))
           me.Helper:grayImageView(self.lock)
           me.Helper:grayImageView(self.icon) 
           me.Helper:grayImageView(self.circle)               
      end
end
function hornorCellItem:onEnter()
    print("hornorCellItem onEnter") 
	 
end
function hornorCellItem:onEnterTransitionDidFinish()
	print("hornorCellItem onEnterTransitionDidFinish") 
end
function hornorCellItem:onExit()
    print("hornorCellItem onExit")   
    me.RemoveCustomEvent(self.evt) 
end
function hornorCellItem:close()
    self:removeFromParent()  
end
