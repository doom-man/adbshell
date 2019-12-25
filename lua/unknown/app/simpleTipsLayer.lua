--[Comment]
--jnmo
simpleTipsLayer = class("simpleTipsLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
simpleTipsLayer.__index = simpleTipsLayer
function simpleTipsLayer:create(...)
    local layer = simpleTipsLayer.new(...)
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
function simpleTipsLayer:ctor()   
    --print("simpleTipsLayer ctor") 
end
function simpleTipsLayer:init()   
    --print("simpleTipsLayer init")
    local fixLayout =
  me.registGuiTouchEventByName(self,"fixLayout",function (node,event)
        if event == ccui.TouchEventType.began then
            self:close() 
        end    
    end)    
    fixLayout:setSwallowTouches(false)
    self.bg = me.assignWidget(self,"bg")
    self.Text_Desc = me.assignWidget(self,"Text_Desc")
    return true
end
function simpleTipsLayer:initWithStr(str,wd,time)
  local w = 320  
  self.Text_Desc:setString(str)
  if self.Text_Desc:getContentSize().width > w then    
     self.Text_Desc:setTextAreaSize(cc.size(w,0))  
     self.Text_Desc:ignoreContentAdaptWithSize(false);
  end
  self.Text_Desc:setColor(cc.c3b(255,255,255))
  -- 新版UI统一用18号字
  self.Text_Desc:setFontSize(18)
  self.Text_Desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  self.Text_Desc:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
  local labelContentSize = self.Text_Desc:getContentSize();
  local msgBoxHeight = labelContentSize.height + 20
  self.bg:setContentSize(cc.size(labelContentSize.width+20,msgBoxHeight))
  self.bg:setPosition(cc.pAdd(wd,cc.p(100,50))) 
  local tw = self.Text_Desc:getContentSize().width
  local th = self.Text_Desc:getContentSize().height 
  if wd.x + tw+10 >= me.winSize.width then     
     self.bg:setPositionX(wd.x - tw/2 )
  else
     self.bg:setPositionX(wd.x + tw/2 )
  end
  if wd.y + th +10 >= me.winSize.height then     
     self.bg:setPositionY(wd.y - th/2 )
  else
     self.bg:setPositionY(wd.y + th/2 )
  end
  if time then
   self.closeTimer =  me.registTimer(time,function (dt,b)
        if b then
            self:close()
        end
     end)
  end
end
function simpleTipsLayer:initWithRichStr(str,wd,width,distance)
  local w = width or 320  
  local dis  = distance or 20
  self.Text_Desc:setVisible(false)
  local rt = mRichText:create(str,w)
  rt:setPosition(10,10)
  self.bg:addChild(rt)
  local labelContentSize = rt:getContentSize();
  local msgBoxHeight = labelContentSize.height + 20
  self.bg:setContentSize(cc.size(labelContentSize.width + dis,msgBoxHeight))

  local tw = rt:getContentSize().width
  local th = rt:getContentSize().height 
  if wd.x + tw+10 >= me.winSize.width then     
     self.bg:setPositionX(wd.x - tw/2 )
  else
     self.bg:setPositionX(wd.x + tw/2 )
  end
  if wd.y + th +10 >= me.winSize.height then     
     self.bg:setPositionY(wd.y - th/2 )
  else
     self.bg:setPositionY(wd.y + th/2 )
  end
end
function simpleTipsLayer:onEnter()

    --print("simpleTipsLayer onEnter") 
  me.doLayout(self,me.winSize)  
end
function simpleTipsLayer:onEnterTransitionDidFinish()
  --print("simpleTipsLayer onEnterTransitionDidFinish") 
end
function simpleTipsLayer:onExit()
    --print("simpleTipsLayer onExit")    
end
function simpleTipsLayer:close()
    me.clearTimer(self.closeTimer)
    self:removeFromParentAndCleanup(true)  
end

