--道具使用    2015-12-03
runeMaterialUse = class("runeMaterialUse",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
runeMaterialUse.__index = runeMaterialUse
function runeMaterialUse:create(...)
    local layer = runeMaterialUse.new(...)
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

function runeMaterialUse:ctor()  
    me.registGuiClickEventByName(self,"fixLayout",function (node)
            local pTouch = node:getTouchBeganPosition()                  
            local pNode = me.assignWidget(self, "Node_size")    
            pNode:setContentSize(cc.size(700,386))
            pNode:setAnchorPoint(cc.p(0.5,0.5))              
            local pPoint = self:contains(pNode,pTouch.x,pTouch.y)
            if pPoint then
            -- 点击在节点中                                       
            else 
             -- 点击在节点外
             self:close()
            end      
    end) 
end

-- 判断是否点击在节点中
function runeMaterialUse:contains(node, x, y)    
        local point = cc.p(x,y)
        local pRect = cc.rect(0,0,node:getContentSize().width,node:getContentSize().height)  
        local locationInNode = node:convertToNodeSpace(point)     -- 世界坐标转换成节点坐标
        return cc.rectContainsPoint(pRect, locationInNode)      
end
function runeMaterialUse:close()
    self:removeFromParentAndCleanup(true)  
end

function runeMaterialUse:init()   
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    me.registGuiClickEventByName(self,"btn_ok",function (node)
        if self.callback~=nil then
            self.callback(nil, self.pUseNum)
        end
        self:close()
    end)  
    return true 
end


-- 点击的物品数据
function runeMaterialUse:setData(count, callback)
    self.callback=callback

    self.pHaveNum = count                    -- 拥有的道具数量
    self.pUseNum = 1                         -- 要使用的道具数量
    if self.pUseNum>self.pHaveNum then
        self.pUseNum = 0    
    end

    local pMaxLabel = me.assignWidget(self,"max_label")
    pMaxLabel:setString("/"..self.pHaveNum)

    local function sliderEvent(sender, eventType)
         if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100
            local pUseNum = math.floor(percent*self.pHaveNum)
            self:setUI(pUseNum)
         end
    end
    local function sliderTouchEvent(sender,eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended and self.pHaveNum > 0 then
             if self.pUseNum == 0 then
                self.pSliber:setPercent(1/self.pHaveNum*100)
                self:setUI(1)
              end
        end
    end
  
    self.pSliber = me.assignWidget(self,"Slider_worker")
    self.pSliber:setPercent(1/self.pHaveNum*100)
    self.pSliber:addEventListener(sliderEvent) 
    self.pSliber:addTouchEventListener(sliderTouchEvent)         
    
     self:setUI(self.pUseNum)

    -- 增加
    local pButtonAdd = me.assignWidget(self,"btn_add")
          me.registGuiClickEvent(pButtonAdd,function (node)
         
              if self.pUseNum < self.pHaveNum then
                   self.pUseNum = self.pUseNum+1
                   local pPercent = (self.pUseNum/self.pHaveNum)*100      
                   self.pSliber:setPercent(pPercent)
                   self:setUI(self.pUseNum)  
              end          
         end)
         -- 减少
    local pButtonAdd = me.assignWidget(self,"btn_reduce")
          me.registGuiClickEvent(pButtonAdd,function (node)
              if self.pUseNum > 1 then
                self.pUseNum = self.pUseNum-1
                local pPercent = (self.pUseNum/self.pHaveNum)*100      
                self.pSliber:setPercent(pPercent)
                self:setUI(self.pUseNum)  
              end          
         end) 
end

-- 参数：要使用的数量
function runeMaterialUse:setUI(pUseNum)
      self.pUseNum = me.toNum(pUseNum)
      self.editBox:setText(me.toStr(pUseNum))
end

function runeMaterialUse:onEnter()   
    print("runeMaterialUse:onEnter()")
	me.doLayout(self,me.winSize)  
end
function runeMaterialUse:onExit()  
    print("runeMaterialUse:onExit()")
end
function runeMaterialUse:createEditBox()
    local function editFiledCallBack(strEventName,pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return 
            end

            if me.isPureNumber(text) then
                if me.toNum(text) <= self.pHaveNum then
                    if me.toNum(text) >= 1 then
                        self.pUseNum = me.toNum(text)
                    end
                else    
                    showTips("超出上限")
                end
            else
                showTips("请输入有效数字")
            end

            local pPercent = (self.pUseNum/self.pHaveNum)*100      
            self.pSliber:setPercent(pPercent)
            self:setUI(self.pUseNum)  
        end
    end
    local eb = me.addInputBox(100,40,24,"gongyong_beijing_shuzi_hui.png",editFiledCallBack,cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.Node_EditBox:addChild(eb)
    return eb
end