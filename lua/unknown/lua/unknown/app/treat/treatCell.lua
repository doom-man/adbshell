treatCell = class("treatCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
treatCell.__index = treatCell
function treatCell:create(...)
    local layer = treatCell.new(...)
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

function treatCell:ctor()
    print("treatCell ctor")
    self.sid = nil 
    self.curSelectSoldierNum = 0
end

function treatCell:setParent(p)
    self.mParent = p
end

function treatCell:init()
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Text_Num = me.assignWidget(self, "Text_Num")
    self.Slider_Soldier = me.assignWidget(self,"Slider_Soldier")

    local function buttonTouchEnd(num)
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
        if self.mParent:getTreatState() ~= BUILDINGSTATE_WORK_TREAT.key then
        if self.curSelectSoldierNum == 0 then
            self.curSelectSoldierNum = self.sdata.num
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
                self.curSelectSoldierNum = cur
                self.Text_Num:setString(self.curSelectSoldierNum.."/"..self.sdata.num)
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
               if self.curSelectSoldierNum > user.maxTroopsNum then
                   showTips(TID_THAN_MAX_SOLDIER)
                   local xNum = self.curSelectSoldierNum - user.maxTroopsNum
                   self.Text_Num:setString(self.curSelectSoldierNum.."/"..self.sdata.num)
                   local haveNum = self.sdata.num
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
function treatCell:onEnter()
end
function treatCell:initWithData(sdata)
    self.sdata = sdata
    local def = sdata:getDef()
    self.Image_Icon:loadTexture(soldierIcon(def), me.plistType)
    me.resizeImage(self.Image_Icon, 96, 96)

    self.Text_Name:setString(def.name)
    self.Text_Num:setString(sdata.curNum.."/"..sdata.num)   
    self.Slider_Soldier:setPercent(math.floor(sdata.curNum/sdata.num*100))
    self.curSelectSoldierNum = sdata.curNum 
end

function treatCell:onEnterTransitionDidFinish()
end
function treatCell:onExit()
end

function treatCell:close()
end

