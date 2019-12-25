--训练界面士兵ITEM
wonderChangeItem = class("wonderChangeItem",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end
end)
wonderChangeItem.__index = wonderChangeItem 
function wonderChangeItem:create(...)
    local layer = wonderChangeItem.new(...)
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
function wonderChangeItem:ctor()   
end
function wonderChangeItem:init()   
    print("wonderChangeItem init")   
    self.name = me.assignWidget(self,"item_name") 
    self.icon = me.assignWidget(self,"item_icon")
    self.item_mask = me.assignWidget(self,"item_mask")
    self.item_mask:setVisible(false)
    return true
end
function wonderChangeItem:initWithData(data,oldWonderDef)
   self.icon:loadTexture(buildIcon(data),me.plistType)
   self.icon:ignoreContentAdaptWithSize(true)
   local cw = 240
   local ch = 150
   local sw = cw / self.icon:getContentSize().width
   local sh = ch / self.icon:getContentSize().height
   local fix = math.min(sw, sh) 
   self.icon:ignoreContentAdaptWithSize(false)
   self.icon:setContentSize(cc.size(self.icon:getContentSize().width * fix, self.icon:getContentSize().height * fix))

   self.name:setString(data.name)
   self.buildData = data
   
   if me.toNum(oldWonderDef.id) ~= me.toNum(data.id) then 
        self.item_mask:setVisible(false)
        me.Helper:normalImageView(self.icon)
        me.Helper:normalImageView(self)
        self:loadTexture("ui_jz_build_bg_03.png",me.localType)
        self.name:setTextColor(me.convert3Color_("d4c5a2"))
   else
        --self:loadTexture("qiji_fangzi_beijing_hui.png",me.localType)
        me.Helper:grayImageView(self)
        me.Helper:grayImageView(self.icon)
        self.item_mask:setVisible(true) 
        self.name:setTextColor(cc.c3b(113,113,113))
   end

   me.registGuiClickEventByName(self,"btn_desc",function(node)
           local info = buildingInfoLayer:create("buildingInfoLayer.csb")
           info:setBuidData(self.buildData)
           buildChangeView:addChild(info, me.MAXZORDER)   
           me.showLayer(info, "bg_frame")
  end)
end
function wonderChangeItem:onEnter()
end
function wonderChangeItem:onExit()
end
