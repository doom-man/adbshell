--[Comment]
--jnmo
bastionDialog = class("bastionDialog",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
bastionDialog.__index = bastionDialog
function bastionDialog:create(...)
    local layer = bastionDialog.new(...)
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
function bastionDialog:ctor()   
    print("bastionDialog ctor") 
    self.tagPoint = nil
end
function bastionDialog:init()   
    print("bastionDialog init")
	me.registGuiClickEventByName(self,"fixLayout",function (node)
        self:close()     
    end) 
    me.registGuiClickEventByName(self,"cancelBtn",function (node)
       self:close()  
    end)  
    me.registGuiClickEventByName(self,"close",function (node)
       self:close()  
    end) 
    me.registGuiClickEventByName(self,"okBtn",function (node)
       local name = self.msgEb:getText() 
       if not me.isValidStr(name) then
            name = "据点("..self.tagPoint.x..","..self.tagPoint.y..")"
       end
       GMan():send(_MSG.buildBastion(self.tagPoint,name))
       if pWorldMap.buildTrade then
            pWorldMap.buildTrade:close()
       end
       self:close()  
    end)  
    local function msgEbCallFunc(eventType,sender)
       if eventType == "began" then
          
       elseif eventType == "return" then 
         
       end
    end
    self.msgEb = me.addInputBox(160, 30, 24, nil, msgEbCallFunc, cc.EDITBOX_INPUT_MODE_ANY, "名字上限6个字")
    self.msgEb:setMaxLength(6)
    self.msgEb:setAnchorPoint(0.5, 0.5)
    self.msgEb:setPosition(cc.p(191.5, 27))
    self.msgEb:setPlaceholderFontColor(cc.c3b(0x5a, 0x5a, 0x5a))
    self.msgEb:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    me.assignWidget(self,"Image_Input"):addChild(self.msgEb)
    self.Panel_Ask = me.assignWidget(self,"Panel_Ask")
    return true
end
function bastionDialog:initWithPoint(c)
    self.tagPoint = c
    if self.Panel_Ask then
        local str =  "<txt0018,bfb8a5>".."是否在土地".."&<txt0018,8fbf52>".."("..me.toStr(self.tagPoint.x)..","..me.toStr(self.tagPoint.y)..")".."&<txt0018,bd8652>".."建造据点".."&"
        local richTxt = mRichText:create(str)
        self.Panel_Ask:addChild(richTxt)
        richTxt:setPosition(cc.p(self.Panel_Ask:getContentSize().width / 2, self.Panel_Ask:getContentSize().height / 2))
        richTxt:setAnchorPoint(cc.p(0.5, 0.5))
    end
end
function bastionDialog:onEnter()
    print("bastionDialog onEnter") 
	me.doLayout(self,me.winSize)  
end
function bastionDialog:onEnterTransitionDidFinish()
	print("bastionDialog onEnterTransitionDidFinish") 
end
function bastionDialog:onExit()
    print("bastionDialog onExit")    
end
function bastionDialog:close()
    self:removeFromParent()  
end
