lordChangeName = class("lordChangeName",function (...)   
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end    
end)
lordChangeName.__index = lordChangeName
function lordChangeName:create(...)
    local layer = lordChangeName.new(...)
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
function lordChangeName:ctor()   
    print("lordChangeName ctor")
--     me.registGuiClickEventByName(self,"fixLayout",function(node)
--      self:close()
--    end)
    me.registGuiClickEventByName(self,"close",function(node)
      self:close()
    end)
    self.changeType = 0 --0免费改名,1付费改名

end

function lordChangeName:close()  
    self:removeFromParentAndCleanup(true)                   
end

function lordChangeName:init()   
    print("lordChangeName init")

    if user.updateName == nil or user.updateName == 1 then 
      self.changeType = 0
      me.assignWidget(self,"price"):setString("免费")
      me.assignWidget(self,"cost"):setVisible(true)
    else  
       self.price = me.toNum(cfg[CfgType.CFG_CONST][28].data)
       self.changeType = 1
       me.assignWidget(self,"price"):setString(self.price)
      me.assignWidget(self,"cost"):setVisible(true) 
    end
    
    self.eb = me.addInputBox(260, 30, 20, nil, nil, cc.EDITBOX_INPUT_MODE_ANY, "在此输入昵称")
    self.eb:setMaxLength(12)
    self.eb:setAnchorPoint(0.5, 0.5)
    self.eb:setPosition(cc.p(0, 0))
    self.eb:setPlaceholderFontColor(cc.c3b(0x5a, 0x5a, 0x5a))
    self.eb:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    me.assignWidget(self,"Node_1"):addChild(self.eb)
    me.registGuiClickEventByName(self,"doBtn",function(node)
       if self.eb:getText() and self.eb:getText() ~= "" then 
          local len = getStringLength(self.eb:getText())
          if len < 4 then 
            showTips("领主昵称不能少于4个字符","ff0000")
            return
          elseif len > 12 then 
            showTips("领主昵称不能多于12个字符","ff0000")
            return
          end
          if self.changeType == 1 then 
             if user.diamond < self.price then 
                showTips("钻石不足","ff0000")
                return
             end
          end
          NetMan:send(_MSG.lordRename(self.eb:getText()))
          self.changeName = self.eb:getText()
       else
          showTips("请输入修改的昵称","ff0000")
       end
    end)
    return true
end

function lordChangeName:update(msg)
   if checkMsg(msg.t,MsgCode.LORD_RENAME) then 
     if msg.c.name == true then 
        user.updateName = msg.c.updateName
        showTips("昵称修改成功")
        user.name = self.changeName 
        self:close()
        if mainCity then 
           if mainCity.lordView then 
             mainCity.lordView:removeFromParent()
           end
           mainCity:updateLordName()
           mainCity.lordView = overlordView:create("overlordView.csb")
           mainCity:addChild(mainCity.lordView, me.MAXZORDER)
        elseif pWorldMap then 
           if pWorldMap.lordView then 
              pWorldMap.lordView:removeFromParent()
           end
           pWorldMap:updateLordName()
           pWorldMap.lordView = overlordView:create("overlordView.csb")
           pWorldMap:addChild(pWorldMap.lordView, me.MAXZORDER)
        end          
     elseif msg.c.alertId then 
         if msg.c.alertId == 463 then -- CHANGENAME_ERROR
            showTips("含非法字符","ff0000")
         elseif msg.c.alertId == 202 then  -- CHANGENAME_LENGTH
            showTips("名字长度不正确","ff0000")
         elseif msg.c.alertId == 408 then  -- CHANGENAME_DIAMOND
            showTips("钻石不足","ff0000")
        elseif msg.c.alertId == 407 then   -- CHANGENAME_EXIST
            showTips("名字已经存在","ff0000")
         end
     end
   end
end
function lordChangeName:onEnter()
  print("lordChangeName onEnter")
   self.modelkey = UserModel:registerLisener(function(msg)
        self:update(msg)
    end)
    me.doLayout(self,me.winSize)
end

function lordChangeName:enterTransitionFinish()
end
function lordChangeName:onExit()   
    print("lordChangeName onExit")
    UserModel:removeLisener(self.modelkey) 
end