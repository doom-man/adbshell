--训练界面士兵ITEM
trainSoldierItem = class("trainSoldierItem",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2]):clone()
    end
end)
trainSoldierItem.__index = trainSoldierItem 
function trainSoldierItem:create(...)
    local layer = trainSoldierItem.new(...)
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
function trainSoldierItem:ctor()   
end
function trainSoldierItem:init()   
    print("trainSoldierItem init")   
    self.name = me.assignWidget(self,"item_name") 
    self.icon = me.assignWidget(self,"item_icon")
    self.item_mask = me.assignWidget(self,"item_mask")
    self.item_num = me.assignWidget(self,"item_num")
    self.lockStr = me.assignWidget(self,"lock")
    self.lock_bg = me.assignWidget(self,"lock_bg")
    self.lock_icon = me.assignWidget(self,"lock_icon")
    self.Button_Up = me.registGuiClickEventByName(self,"Button_Up",function (node)
        dump(user.soldierData)
        NetMan:send(_MSG.getSoldierLevelUpData(self.bdata.index,self.data.id))
    end)
    return true
end
function trainSoldierItem:initWithData(data,filter,bdata)
   self.data = data
   self.filter = filter
   self.bdata = bdata
   self.icon:ignoreContentAdaptWithSize(true)
   if data.bigType  == 99 then
        self.icon:loadTexture(soldierIcon(data),me.plistType)
   else 
        self.icon:loadTexture(soldierIcon(data),me.plistType)
        --self:removeChildByTag(0xff2321)
        --self.icon:setVisible(false)
--        local sani =  soldierMoudle:createSoldierById(data.id)
--        sani:doAction(MANI_STATE_IDLE,DIR_LEFT_BOTTOM)
--        self:addChild(sani)
--        sani:setTag(0xff2321)
--        sani:setScale(1.3)
--        sani:setPosition(115,130)      
   end
   self.name:setString(data.name)
   local def = bdata:getDef()
   self.item_mask:setVisible(false)
   if me.toNum(filter.level) <= 0 then 
        self.item_mask:setVisible(false)
        self.lockStr:setVisible(false)
        self.lock_bg:setVisible(false)
        if  tonumber(filter["num"]) <= 0 or self:isMaxSoldierId() then
            self.Button_Up:setVisible(false)
        else
            self.Button_Up:setVisible(true)
        end
        self:loadTexture("ui_xl_box_01.png",me.localType)
        me.assignWidget(self,"item_num"):setString(filter["num"])
   else
        self:loadTexture("ui_xl_box_02.png",me.localType)
        self.lockStr:setString(def.name..filter.level.."级解锁")
        me.assignWidget(self,"item_num"):setString(filter["num"])
        self.item_mask:setVisible(true) 
        self.lockStr:setVisible(true)
        self.lock_bg:setVisible(true)
        self.lockStr:setPositionX(100)
        self.lock_icon:setPositionX(self.lockStr:getPositionX()-self.lockStr:getContentSize().width/2-12)
        self.Button_Up:setVisible(false)
   end
   me.registGuiClickEventByName(self,"btn_desc",function (node)                    
                local info = soldierInfoLayer:create("soldlierInfoLayer.csb")
                info:initWithData(data,filter)
                mainCity:addChild(info,me.MAXZORDER)
                me.showLayer(info,"bg")  
   end)
end
function trainSoldierItem:isMaxSoldierId()    
    for key, var in pairs(self.traindata) do
          if ( tonumber( var.sid )  >  self.data.id ) and tonumber( var.level ) == 0  then
             return false
          end
    end   
    return true 
end
function trainSoldierItem:onEnter()
end
function trainSoldierItem:onExit()
end
