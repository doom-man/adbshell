expedCell = class("expedCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
expedCell.__index = expedCell
function expedCell:create(...)
    local layer = expedCell.new(...)
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

function expedCell:ctor()
    print("expedCell ctor")
    self.sid = nil
    self.curSelectSoldierNum = 0
    -- 变量visitor
    self.visitor = nil
end
function expedCell:init()
    print("expedCell init")
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Text_Name:enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(2, -2))   
    self.Text_Num = me.assignWidget(self, "Text_Num")
    self.Button_Reduce = me.assignWidget(self, "Button_Reduce")
    self.Button_Add = me.assignWidget(self, "Button_Add")
    self.Button_icon = me.assignWidget(self, "Button_icon")
    self.Button_icon:setSwallowTouches(false)
    self.Slider_Soldier = me.assignWidget(self, "Slider_Soldier")

    local lastScelectNum = -1
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local haveNum = self:getSoldierData()
            local cur = math.floor(slider:getPercent() / 100 * haveNum)
            if lastScelectNum ~= cur then
                expedLayer.selectSoldierNum[self.sdefid] = cur
                self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
                if self.visitor then
                    self.visitor:updateMaxTroops()
                end
            end
        end
    end
    local function sliderTouchEvent(sender, eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended then
            self:beyondMaxArmy(sender)
        end
    end
    self.Slider_Soldier:addEventListener(sliderEvent)
    self.Slider_Soldier:addTouchEventListener(sliderTouchEvent)

    me.registGuiClickEvent(self.Button_Reduce, function(node)
        if expedLayer.selectSoldierNum[self.sdefid] -1 < 0 then
            expedLayer.selectSoldierNum[self.sdefid] = 0
        else
            expedLayer.selectSoldierNum[self.sdefid] = expedLayer.selectSoldierNum[self.sdefid] -1
        end
        self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
        local per = math.floor(expedLayer.selectSoldierNum[self.sdefid] / self:getSoldierData() * 100)
        self.Slider_Soldier:setPercent(per)
        if self.visitor then
            self.visitor:updateMaxTroops()
        end
    end )
    me.registGuiClickEvent(self.Button_Add, function(node)
        local haveNum = self:getSoldierData()
        if expedLayer.selectSoldierNum[self.sdefid] + 1 > haveNum then
            expedLayer.selectSoldierNum[self.sdefid] = haveNum
        else
            expedLayer.selectSoldierNum[self.sdefid] = expedLayer.selectSoldierNum[self.sdefid] + 1
        end
        if self:beyondMaxArmy(self.Slider_Soldier) == false then
            self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
            local per = math.floor(expedLayer.selectSoldierNum[self.sdefid] / self:getSoldierData() * 100)
            self.Slider_Soldier:setPercent(per)
            if self.visitor then
                self.visitor:updateMaxTroops()
            end
        end
    end )

    me.registGuiClickEvent(self.Button_icon, function()
        local haveNum = self:getSoldierData()
        local allNum = getCurSelectSoldierNum()
        if expedLayer.selectSoldierNum[self.sdefid] > 0 then
            expedLayer.selectSoldierNum[self.sdefid] = 0
        else
            local xNum = allNum - self.mStartArmy
            local tmpMax = math.min(expedLayer.selectSoldierNum[self.sdefid] - xNum, haveNum)
            expedLayer.selectSoldierNum[self.sdefid] = tmpMax
        end
        if self:beyondMaxArmy(self.Slider_Soldier) == false then
            self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
            local per = math.floor(expedLayer.selectSoldierNum[self.sdefid] / self:getSoldierData() * 100)
            self.Slider_Soldier:setPercent(per)
            if self.visitor then
                self.visitor:updateMaxTroops()
            end
        end
    end )

    self.Slider_Soldier:setPercent(0)
    return true
end
function expedCell:setMaxTroopsNums(nums)
    self.maxTroopsNum = nums
end

function expedCell:onEnter()
    print("expedCell onEnter")
end
function expedCell:getVisitor()
    return self.visitor
end
function expedCell:setVisitor(visitor_)
    self.visitor = visitor_
end
function expedCell:setShowTips()
     if self.mStrongNum ~= 0  then         
        if self.mStrongNum > self.maxTroopsNum then
            showTips(TID_THAN_MAX_SOLDIER)
        else
            if self.mState == EXPED_STATE_MOBILIZE then
                showTips("调动不可超过据点兵力上限")
            elseif self.mState == TEAM_ARMY_JOIN or self.mState == THRONE_TEAM_JOIN  then
                showTips("已达到集火军队上限")
            elseif self.mState == TEAM_ARMY_DEFENS then
                showTips("已达到援助军队上限")
            else
                showTips(TID_THAN_MAX_SOLDIER)
            end
        end
    else
        showTips(TID_THAN_MAX_SOLDIER)
    end
end
function expedCell:initWithData(sdata, pArmyNum, pStrongNum, pState)
    self.sdefid = sdata.defId
    self.mData = sdata
    local def = sdata:getDef()
    print(def.name)
    self.mStartArmy = pArmyNum
    self.mStrongNum = pStrongNum
    self.mState = pState
    self.Image_Icon:loadTexture(soldierIcon(def), me.plistType)
    me.resizeImage(self.Image_Icon,86,86)
    self.Text_Name:setString(def.name)
    if expedLayer.selectSoldierNum[self.sdefid] == nil then
        expedLayer.selectSoldierNum[self.sdefid] = 0
    end
    self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
    local haveNum = self:getSoldierData()
    self.Slider_Soldier:setPercent(expedLayer.selectSoldierNum[self.sdefid] * 100 / haveNum)
end
-- 超出出征上限
function expedCell:beyondMaxArmy(slider)
    local allNum = getCurSelectSoldierNum()
    if allNum > self.mStartArmy then
        self:setShowTips()
        local xNum = allNum - self.mStartArmy
        expedLayer.selectSoldierNum[self.sdefid] = expedLayer.selectSoldierNum[self.sdefid] - xNum
        self.Text_Num:setString(expedLayer.selectSoldierNum[self.sdefid])
        local haveNum = self:getSoldierData()
        if slider then
            slider:setPercent(expedLayer.selectSoldierNum[self.sdefid] * 100 / haveNum)
        end
        if self.visitor then
            self.visitor:updateMaxTroops()
        end
        return true
    end
    return false
end
function expedCell:getSoldierData()
    return self.mData.num
end
function expedCell:onEnterTransitionDidFinish()
    print("expedCell onEnterTransitionDidFinish")
end
function expedCell:onExit()
    print("expedCell onExit")
end
function expedCell:close()
    self:removeFromParentAndCleanup(true)
end

