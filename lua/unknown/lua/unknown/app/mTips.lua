--[Comment]
--jnmo
mTips = class("mTips",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
mTips.__index = mTips
function mTips:create(...)
    local layer = mTips.new(...)
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
function mTips:ctor()   
    print("mTips ctor") 
end
function mTips:init()   
    print("mTips init")
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
function mTips:initWithStr(str,wd,side)
  local w = 320  
  self.Text_Desc:setString(str)
  if self.Text_Desc:getContentSize().width > w then    
     self.Text_Desc:setTextAreaSize(cc.size(w,0))  
  end
  self.Text_Desc:setColor(cc.c3b(255,255,255))
  self.Text_Desc:setFontSize(20)
  self.Text_Desc:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
  self.Text_Desc:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
  local labelContentSize = self.Text_Desc:getContentSize();
  local msgBoxHeight = labelContentSize.height + 20
  self.bg:setContentSize(cc.size(labelContentSize.width+20,msgBoxHeight))
  if side == "left" then
        self.bg:setPosition(cc.pAdd(wd,cc.p((-labelContentSize.width-20)/2,msgBoxHeight/2)))  
  elseif side == "right" then
        self.bg:setPosition(cc.pAdd(wd,cc.p((labelContentSize.width+20)/2,msgBoxHeight/2)))  
  elseif side == "top" then
       self.bg:setPosition(cc.pAdd(wd,cc.p(0,msgBoxHeight)))
  elseif side == "bottom" then
       self.bg:setPosition(cc.pAdd(wd,cc.p(0,-msgBoxHeight)))
  end
end
function mTips:onEnter()
    print("mTips onEnter") 
	me.doLayout(self,me.winSize)  
end
function mTips:onEnterTransitionDidFinish()
	print("mTips onEnterTransitionDidFinish") 
end
function mTips:onExit()
    print("mTips onExit")    
end
function mTips:close()
    self:removeFromParentAndCleanup(true)  
end

