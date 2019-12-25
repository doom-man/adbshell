fuhuoCell = class("fuhuoCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
fuhuoCell.__index = fuhuoCell
function fuhuoCell:create(...)
    local layer = fuhuoCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end

function fuhuoCell:ctor()
    print("fuhuoCell ctor")
    self.sid = nil 
    self.curSelectSoldierNum = 0
end

function fuhuoCell:setParent(p)
    self.mParent = p
end

function fuhuoCell:init()
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Text_Num = me.assignWidget(self, "Text_Num")
    self.Slider_Soldier = me.assignWidget(self,"Slider_Soldier")

    local function buttonTouchEnd(num)
    
        if self.mParent.selectNums+num>self.mParent.spareReliveNums then
            return
        end
        self.curSelectSoldierNum = self.curSelectSoldierNum +num
        if self.curSelectSoldierNum > self.sdata.num then
            self.curSelectSoldierNum = self.sdata.num
        elseif self.curSelectSoldierNum < 0 then
            self.curSelectSoldierNum = 0
        end
        local per = math.floor(self.curSelectSoldierNum/self.sdata.num*100)
        self.Slider_Soldier:setPercent(per)
        self.Text_Num:setString(self.curSelectSoldierNum.."/"..self.sdata.num)
        self.sdata.curNum = self.curSelectSoldierNum
        if self.mParent then
            self.mParent:updateRes()
        end
    end
    
    me.registGuiClickEventByName(self,"Button_icon",function ()
        if self.curSelectSoldierNum == 0 then
            local nums = self.mParent.spareReliveNums-self.mParent.selectNums
            local t = self.sdata.num
            if nums<self.sdata.num then
                t=nums
            end

            self.curSelectSoldierNum = t
            self.sdata.curNum = self.curSelectSoldierNum
            self.Text_Num:setString(self.curSelectSoldierNum.."/"..self.sdata.num)
            self.Slider_Soldier:setPercent(self.curSelectSoldierNum*100/self.sdata.num)
        else
            self.curSelectSoldierNum = 0
            self.Text_Num:setString("0/"..self.sdata.num)
            self.sdata.curNum = self.curSelectSoldierNum
            self.Slider_Soldier:setPercent(0)
        end
        if self.mParent then
            self.mParent:updateRes()
        end
    end)

    me.registGuiClickEventByName(self, "Button_Reduce", function(node)
        buttonTouchEnd(-1)
    end )
    
    me.registGuiClickEventByName(self, "Button_Add", function(node)
        buttonTouchEnd(1)
    end )

    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local haveNum = self.sdata.num
            local cur =  math.floor(slider:getPercent() / 100 * haveNum) 
            if self.curSelectSoldierNum ~= cur then   
                local totalNum = 0
                for key, var in pairs(self.mParent.allData) do
                    if var.defId~=self.sdata.defId then
                        totalNum = totalNum+var.curNum
                    end
                end
                local nums = self.mParent.spareReliveNums-totalNum
                local t = cur
                if nums<cur then
                    --showTips("不能超过今日死兵复活数")
                    t=nums
                end
                self.curSelectSoldierNum = t
                self.Text_Num:setString(self.curSelectSoldierNum.."/"..self.sdata.num)
                slider:setPercent(self.curSelectSoldierNum*100/self.sdata.num)
                self.sdata.curNum = self.curSelectSoldierNum
                if self.mParent then
                    self.mParent:updateRes()
                end
            end
        end
    end

    local function sliderTouchEvent(sender, eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended then
               local totalNum = 0
               for key, var in pairs(self.mParent.allData) do
                   if var.defId~=self.sdata.defId then
                       totalNum = totalNum+var.curNum
                   end
               end
               local nums = self.mParent.spareReliveNums-totalNum
               if self.curSelectSoldierNum > nums then
                   self.curSelectSoldierNum = nums
                   local haveNum = self.sdata.num
                   self.Text_Num:setString(self.curSelectSoldierNum.."/"..haveNum)
                   slider:setPercent(self.curSelectSoldierNum*100/haveNum)
                   self.sdata.curNum = self.curSelectSoldierNum
                    if self.mParent then
                        self.mParent:updateRes()
                    end
               end               
        end
    end
    self.Slider_Soldier:addEventListener(sliderEvent)
    self.Slider_Soldier:addTouchEventListener(sliderTouchEvent)
    return true
end
function fuhuoCell:onEnter()
end
function fuhuoCell:initWithData(sdata, assistData)
    self.assistData = assistData
    self.sdata = sdata
    local def = sdata:getDef()
    self.Image_Icon:loadTexture(soldierIcon(def), me.plistType)
    me.resizeImage(self.Image_Icon, 96, 96)

    self.Text_Name:setString(def.name)
    self.Text_Num:setString(sdata.curNum.."/"..sdata.num)   
    self.Slider_Soldier:setPercent(math.floor(sdata.curNum/sdata.num*100))
    self.curSelectSoldierNum = sdata.curNum 
end

function fuhuoCell:onEnterTransitionDidFinish()
end
function fuhuoCell:onExit()
end

function fuhuoCell:close()
end

