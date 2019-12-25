expedLayer = class("expedLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
expedLayer.__index = expedLayer

local timeNum = { }
timeNum[0] = 0
timeNum[#timeNum + 1] = 1
timeNum[#timeNum + 1] = 20
timeNum[#timeNum + 1] = 50
timeNum[#timeNum + 1] = 100
timeNum[#timeNum + 1] = 200

expedLayer.SHIP_CHOOSE = 1 -- 可选
expedLayer.SHIP_NOT_CHOOSE = 2 -- 不可选
expedLayer.SHIP_NOT_BUILD = 3 -- 没有建造

function expedLayer:create(...)
    local layer = expedLayer.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
expedLayer.selectSoldierNum = { }
function getCurSelectSoldierNum()
    local num = 0
    for key, var in pairs(expedLayer.selectSoldierNum) do
        num = num + var
    end
    return num
end
function getCurSelectSoldierSpeed(pAmry)
    local speed = 999999
    for key, var in pairs(expedLayer.selectSoldierNum) do
        if var > 0 then
            local data = pAmry[key]
            local def = data:getDef()
            if def.speed < speed then
                speed = def.speed
            end
        end
    end
    return speed
end
function getTotalCarry(pAmry, shipCarry)
    local carry = 0
    for key, var in pairs(expedLayer.selectSoldierNum) do
        local data = pAmry[key]
        local def = data:getDef()
        carry = carry + var * def.carry
    end
    carry = math.floor(carry *(1 + user.propertyValue["Carry"] + shipCarry))
    -- 科技加成
    return carry
end
function expedLayer:getMarchTime()
    local v = getCurSelectSoldierSpeed(self.mArmy)

    local sholdSpeed = 0
    if v == -1 then
        return 0
    else
        if self.m_ExpedState == EXPED_STATE_MOBILIZE or self.m_ExpedState == STRONG_ARMY_RETURN then
            -- 据点数据加成
            if self.mStronghold ~= nil and self.mOtherStrongHold ~= nil then
                local pAddNum = math.max(self.mStronghold:getDef().speed, self.mOtherStrongHold:getDef().speed)
                sholdSpeed =(pAddNum / 100)
            elseif self.mStronghold ~= nil then
                local pAddNum = self.mStronghold:getDef().speed
                sholdSpeed =(pAddNum / 100)
            end
        end
        local scale = 240
        local tag = self.m_Paths.tag
        local take_speed = 0
        local id = me.getIdByCoord(tag)
        local celldata = gameMap.mapCellDatas[id]
        if celldata then
            if celldata.pointType == POINT_CITY and celldata.occState == OCC_STATE_HOSTILE then
                take_speed = user.propertyValue["AtkCitySpeed"] or 0
            end
        end
        local pSpeed = user.propertyValue["Speed"] + sholdSpeed + self.WarshipSpeed + take_speed
        print("pSpeed = " .. pSpeed)
        if self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == TEAM_WAIT or self.m_ExpedState == THRONE_TEAM_JOIN or self.m_ExpedState == THRONE_TEAM_WAIT then
            pSpeed = pSpeed +(user.propertyValue["JiHuoSpeed"] or 0)
        elseif self.m_ExpedState == TEAM_ARMY_DEFENS then
            pSpeed = pSpeed +(user.propertyValue["YuanZhuSpeed"] or 0)
        end
        if celldata then
            local bossdata = celldata:getBossData()
            if bossdata then
                local bossDef = bossdata:getDef()
                if bossDef.type == 4 or bossDef.type == 1 then
                    pSpeed = pSpeed + 6
                end
            end
        end

        return math.floor(self.m_Distence_cell * scale /((v * 5) *(1 + pSpeed)))
    end
end
function expedLayer:ctor()
    print("expedLayer ctor")
    self.m_Paths = nil
    self.m_Distence_cell = 0
    self.m_Distence_road = 0
    self.m_ExpedState = nil
    self.pets = { }
    self.currentPetId = nil
    self.archBtn = { }
    self.curQueueNum = 0
    self.targetIndex = 0
    self.npc = 0
    self.mStronghold = nil
    -- 据点数据
    self.mOtherStrongHold = nil
    -- 据点数据(出发点)
    self.mStartType = 0
    self.waitTime = 0
    -- 集结时间
    self.teamId = 0
    -- 加入集结的ID
    self.surplusTime = 0
    -- 集火加入剩余时间
    self.mStrongMaxArmy = 0
    self.shipType = 0
    self.mChoosepData = nil
    self.WarshipSpeed = 0
    self.WarshipArmy = 0
    self.WarshipCarry = 0
end
function expedLayer:init()
    print("expedLayer init")
    self.globalItems = me.createNode("Node_expedItem.csb")
    self.globalItems:retain()
    me.registGuiClickEventByName(self, "close", function()
        self:close()
    end )
    self.border = me.assignWidget(self, "border")
    self.Text_TroopsNum = me.assignWidget(self, "Text_TroopsNum"):setString(0)
    self.Text_Troopsdem = me.assignWidget(self, "Text_Troopsdem")
    self.Text_MarchTime = me.assignWidget(self, "Text_MarchTime")
    self.petBtn = me.assignWidget(self, "petBtn")
    self.petDescription = me.assignWidget(self, "petDescription")
    self.petCheckBox = me.assignWidget(self, "petCheckBox")
    self.Text_MarchTime:setString("00:00:00")
    self.Text_Weight = me.assignWidget(self, "Text_Weight")
    self.textQueueNum = me.assignWidget(self, "Text_Queue_Num")
    self.Node_archaeology = me.assignWidget(self, "Node_archaeology")
    self.Node_expdition = me.assignWidget(self, "Node_expdition"):setVisible(true)
    self.Node_stronghold = me.assignWidget(self, "Node_Stronghold"):setVisible(false)
    mWarshipHint = SharedDataStorageHelper():getWarshipHint()
    print("mWarshipHint" .. mWarshipHint)
    self.title = me.assignWidget(self, "title"):setString("出征")
    self:setArmydem(0)
    me.assignWidget(self, "Text_costShrength_boos"):setVisible(false)
    -- 体力是否足够
    self.isVitEnough = true

    me.registGuiClickEventByName(self, "Button_addStrength", function(node)
        local powerShop = vipShopView:create("vipShopView.csb")
        powerShop:initCost()
        self:addChild(powerShop)
        me.showLayer(powerShop, "bg")
    end )
    me.registGuiClickEventByName(self, "Button_addStrength_boos", function(node)
        local powerShop = vipShopView:create("vipShopView.csb")
        powerShop:initCost()
        self:addChild(powerShop)
        me.showLayer(powerShop, "bg")
    end )
    me.registGuiClickEventByName(self, "Button_add_army", function(node)
        NetMan:send(_MSG.initShop(ARMY_ADD_TYPE))

    end )
    self.Button_Battle = me.registGuiClickEventByName(self, "Button_Battle", function(node)
        local army = { }
        for key, var in pairs(expedLayer.selectSoldierNum) do
            if var > 0 then
                local temp = { }
                temp.id = key
                temp.num = var
                if var > 0 then
                    table.insert(army, temp)
                end
            end
        end
        if #army > 0 then

            if self.npc then
                local id = me.getIdByCoord(self:getTagPoint())
                local celldata = gameMap.mapCellDatas[id]

                if self.npc > self.mcurTotalNum and self.m_ExpedState == EXPED_STATE_OCC and not celldata then
                    self:showConfirmView(army)
                else
                    self:goToBattle(army)
                end
                --                  if self.bshow then
                --                      self:showConfirmView(army)
                --                  else
                --                     self:goToBattle(army)
                --                  end
            else
                self:goToBattle(army)
            end
        else
            showTips(TID_PLEASE_SELECT_TROOP)
        end
        node:setSwallowTouches(true)
    end )
    self:resetSelectSoldierNum()

    -- 左下角出征携带宠物
    --    for i=1,4 do
    --        local etcItem = EtcItemData.new(i, 1270+i, i)
    --        self.pets[etcItem.defid] = etcItem
    --    end
    for key, var in pairs(user.bookPkg) do
        if var:getDef().useType == 119 then
            self.pets[var.defid] = var
        end
    end
    self.petCell = petCell:create("petCell.csb")
    local petCellBtn = me.assignWidget(self.petCell, "petBtn")
    if next(self.pets) then
        local str = SharedDataStorageHelper():getUserPet()
        if str and str ~= "" then
            local tb = me.split(str, "|")
            local defid = me.toNum(tb[1])
            local isSlct = me.toNum(tb[2])
            if self.pets[defid] == nil then
                for key, var in pairs(self.pets) do
                    defid = var.defid
                    break
                end
            end
            self:setCurrentPet(defid)
            --            if isSlct == 1 then
            --                self.petCheckBox:setSelected(true)
            --            else
            self.petCheckBox:setSelected(false)
            -- end
        else
            self.petDescription:setVisible(false)
            self.petCheckBox:setVisible(false)
            self.add = me.assignWidget(self.petCell, "add"):setVisible(true)
            local a1 = cc.TintBy:create(0.6, -180, -180, -180)
            local a2 = a1:reverse()
            local a3 = cc.Sequence:create(a1, a2)
            local a4 = cc.RepeatForever:create(a3)
            self.add:runAction(a4)
            me.assignWidget(self.petCell, "numBg"):setVisible(false)
            me.assignWidget(self.petCell, "petIcon"):setVisible(false)
        end
        me.registGuiClickEvent(petCellBtn, function()
            local petView = petView:create("petView.csb")
            -- petView.bg:setPosition(cc.p(self.petBtn:getPositionX(),self.petBtn:getPositionY()+self.petBtn:getContentSize().height))
            petView:setParpet(self)
            self:addChild(petView)
        end )
    else
        self.petDescription:setVisible(false)
        self.petCheckBox:setVisible(false)
        me.assignWidget(self.petCell, "numBg"):setVisible(false)
        me.assignWidget(self.petCell, "petIcon"):setVisible(false)
        me.registGuiClickEvent(petCellBtn, function()
            showTips("还没有宠物")
        end )
    end
    self.petBtn:addChild(self.petCell)
    self.cur_choose = 1
    local txts = {
        [1] = "战力优先",
        [2] = "速度优先",
        [3] = "负重优先",
        [4] = "均衡配置"
    }
    -- 5被考古占用，另起一组索引
    local txts2 = {
        [11] = "步兵优先",
        [21] = "骑兵优先",
        [31] = "弓兵优先",
        [41] = "清空选中",
    }
    self.Text_Rec = me.assignWidget(self, "Text_Rec")
    self.Panel_Rec = me.registGuiClickEventByName(self, "Panel_Rec", function(args)
        self.Panel_Rec:setVisible(false)
    end )
    self.Panel_Rec:setSwallowTouches(false)
    for var = 1, 4 do
        me.registGuiClickEventByName(self.Panel_Rec, "item_" .. var, function(node)
            self.cur_choose = var
            self.Panel_Rec:setVisible(false)
            self.Text_Rec:setString(txts[self.cur_choose])
            self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)
            self:initList(self.mArmy)
        end )
    end
    for k, v in pairs(txts2) do
        me.registGuiClickEventByName(self.Panel_Rec, "item_" .. k, function(node)
            self.cur_choose = k
            self.Panel_Rec:setVisible(false)
            self.Text_Rec:setString(txts2[self.cur_choose])
            self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)
            self:initList(self.mArmy)
        end )
    end
    self.Image_Rec = me.registGuiClickEventByName(self, "Image_Rec", function(node)
        for var = 1, 4 do
            local item = me.assignWidget(self.Panel_Rec, "item_" .. var)
            me.assignWidget(item, "select"):setVisible(self.cur_choose == var)
        end
        for k, v in pairs(txts2) do
            local item = me.assignWidget(self.Panel_Rec, "item_" .. k)
            me.assignWidget(item, "select"):setVisible(self.cur_choose == k)
        end
        self.Panel_Rec:setVisible(true)
    end )
    self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)

    return true
end
function expedLayer:autoSet()
    if self.cur_choose == 1 then
    elseif self.cur_choose == 2 then
    elseif self.cur_choose == 3 then
    elseif self.cur_choose == 4 then
    end
end
-- 设置当前出征宠物
function expedLayer:setCurrentPet(defid)
    self.currentPetId = defid
    local currentPet = self.pets[defid]
    local currentPetDef = currentPet:getDef()
    if not self.petCheckBox:isVisible() then
        self.petCheckBox:setVisible(true)
    end
    self.petDescription:setString(currentPetDef.describe)
    self.petDescription:setVisible(true)
    self.petCell:initWithData(currentPetDef, currentPet.count)
    self.petCheckBox:setSelected(true)
end
-- 据点数据(出发点/目标点)
function expedLayer:setStrongholdData(pData, otherData)
    self.mStronghold = pData
    self.mOtherStrongHold = otherData
end

-- 英雄试炼数据
function expedLayer:setHerolevelData(herolevelData)
    self.herolevelData = herolevelData
end

-- 挖矿入驻数据
function expedLayer:setDigoreData(digoreData)
    self.digoreData = digoreData
end

-- [Comment]
-- 出征状态
function expedLayer:getExpedState()
    return self.m_ExpedState
end
function expedLayer:setExpedState(m_ExpedState_)
    if m_ExpedState_ == EXPED_STATE_HEROLEVEL then
        me.assignWidget(self, "Text_Queue_Num"):setVisible(false)
        me.assignWidget(self, "Text_Weight_Label"):setVisible(false)
        me.assignWidget(self, "Image_3"):setVisible(false)
        me.assignWidget(self, "Text_distance"):setVisible(false)
    elseif m_ExpedState_ == EXPED_STATE_DIGORE then
        me.assignWidget(self, "Text_costShrength_boos"):setVisible(false)
        self.textQueueNum:setString("可用行军队列:2/2")
        me.assignWidget(self, "petBtn"):setVisible(false)
        me.assignWidget(self, "petText"):setVisible(false)
        me.assignWidget(self, "petCheckBox"):setVisible(false)
        me.assignWidget(self, "petDescription"):setVisible(false)
    else
        me.assignWidget(self, "Text_Queue_Num"):setVisible(true)
        me.assignWidget(self, "Text_Weight_Label"):setVisible(true)
        me.assignWidget(self, "Image_3"):setVisible(true)
        me.assignWidget(self, "Text_distance"):setVisible(true)
    end
    self.m_ExpedState = m_ExpedState_
    self:setWarshipData()
end
-- [Comment]
-- 路径 m_Paths = { oir,tag,list}
function expedLayer:getPaths()
    return self.m_Paths
end
function expedLayer:setPaths(m_Paths_)
    self.m_Paths = m_Paths_
    self.m_Distence_cell, self.m_Distence_road = getMarchDis(m_Paths_)
end

-- [Comment]
-- 普通距离
function expedLayer:getDistence()
    return self.m_Distence_cell
end
function expedLayer:setDistence(m_Distence_)
    self.m_Distence_cell = m_Distence_
end
-- [Comment]
-- 道路距离
function expedLayer:getDistence_road()
    return self.m_Distence_road
end
function expedLayer:setDistence_road(m_Distence_)
    self.m_Distence_road = m_Distence_
end

function expedLayer:resetSelectSoldierNum()
    expedLayer.selectSoldierNum = nil
    expedLayer.selectSoldierNum = { }
end
function expedLayer:close()
    -- me.hideLayer(self,true,"shopbg")
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end
function expedLayer:initList(pData)
    self:resetSelectSoldierNum()
    self.sData = { }
    local snum = 0
    local iNum = 0
    local carry = 0
    if self.cur_choose == 1 then
        for key, var in pairs(pData) do
            if var:getDef().bigType ~= 99 then
                table.insert(self.sData, var)
            end
        end
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().traintime < b:getDef().traintime
        end )
        -- 自动最大出兵
        iNum = #self.sData
        --  for key, var in pairs(sData) do
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.mStartMaxArmy then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
                carry = carry + var.num * var:getDef().carry
            else
                expedLayer.selectSoldierNum[var.defId] = self.mStartMaxArmy - snum
                snum = self.mStartMaxArmy
                carry = carry + expedLayer.selectSoldierNum[var.defId] * var:getDef().carry
                break
            end
        end
    elseif self.cur_choose == 2 then
        for key, var in pairs(pData) do
            if var:getDef().bigType ~= 99 then
                table.insert(self.sData, var)
            end
        end
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().speed < b:getDef().speed
        end )

        iNum = #self.sData
        --  for key, var in pairs(sData) do
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.mStartMaxArmy then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
                carry = carry + var.num * var:getDef().carry
            else
                expedLayer.selectSoldierNum[var.defId] = self.mStartMaxArmy - snum
                snum = self.mStartMaxArmy
                carry = carry + expedLayer.selectSoldierNum[var.defId] * var:getDef().carry
                break
            end
        end
    elseif self.cur_choose == 3 then
        for key, var in pairs(pData) do
            if var:getDef().bigType ~= 99 then
                table.insert(self.sData, var)
            end
        end
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().carry < b:getDef().carry
        end )
        -- 自动最大出兵
        iNum = #self.sData
        --  for key, var in pairs(sData) do

        -- 探索 普通车队、豪华车队，负重优先，计算最优兵力
        if self.expectWeight and self.expectWeight > 0 then
            -- 加成
            local upRatio = 1 + user.propertyValue["Carry"] + self.WarshipCarry
            for i = iNum, 1, -1 do
                local var = self.sData[i]
                expedLayer.selectSoldierNum[var.defId] = 0
                for j = 1, var.num do
                    if carry * upRatio >= self.expectWeight or snum >= self.mStartMaxArmy then
                        break
                    end
                    expedLayer.selectSoldierNum[var.defId] = expedLayer.selectSoldierNum[var.defId] + 1
                    snum = snum + 1
                    carry = carry + var:getDef().carry
                end
            end
        else
            for i = iNum, 1, -1 do
                local var = self.sData[i]
                if snum + var.num <= self.mStartMaxArmy then
                    expedLayer.selectSoldierNum[var.defId] = var.num
                    snum = snum + var.num
                    carry = carry + var.num * var:getDef().carry
                else
                    expedLayer.selectSoldierNum[var.defId] = self.mStartMaxArmy - snum
                    snum = self.mStartMaxArmy
                    carry = carry + expedLayer.selectSoldierNum[var.defId] * var:getDef().carry
                    break
                end
            end
        end
    elseif self.cur_choose == 4 then
        local cur_nums = 0
        for key, var in pairs(pData) do
            if var:getDef().bigType ~= 99 then
                cur_nums = cur_nums + var.num
                table.insert(self.sData, var)
            end
        end
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().traintime < b:getDef().traintime
        end )
        -- 兵种数量
        local max_nums = #self.sData
        -- 自动最大出兵

        iNum = #self.sData
        --  for key, var in pairs(sData) do

        local idx = nil
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if cur_nums >= self.mStartMaxArmy then
                expedLayer.selectSoldierNum[var.defId] = math.floor(var.num * self.mStartMaxArmy / cur_nums)
                snum = snum + expedLayer.selectSoldierNum[var.defId]
                carry = carry + expedLayer.selectSoldierNum[var.defId] * var:getDef().carry
                if expedLayer.selectSoldierNum[var.defId] + max_nums < var.num then
                    idx = i
                end
                if i == 1 and idx then
                    expedLayer.selectSoldierNum[self.sData[idx].defId] = expedLayer.selectSoldierNum[self.sData[idx].defId] + self.mStartMaxArmy - snum
                    carry = carry +(self.mStartMaxArmy - snum) * self.sData[idx]:getDef().carry
                    snum = self.mStartMaxArmy
                end
            else
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
                carry = carry + var.num * var:getDef().carry
            end
        end
    elseif self.cur_choose == 5 then
        for key, var in pairs(pData) do
            if var:getDef().bigType ~= 99 then
                table.insert(self.sData, var)
            end
        end
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().carry < b:getDef().carry
        end )
        -- 自动最大出兵
        iNum = #self.sData
        local sum_carry = self:getWeightSingle() * timeNum[self.targetIndex]
        sum_carry = math.ceil(sum_carry /(1 + user.propertyValue["Carry"] + self.WarshipCarry))
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if var.num * var:getDef().carry <= sum_carry - carry then
                expedLayer.selectSoldierNum[var.defId] = var.num
                cur_carry = var.num * var:getDef().carry
                snum = snum + var.num
                carry = carry + var.num * var:getDef().carry
            else
                expedLayer.selectSoldierNum[var.defId] = math.ceil((sum_carry - carry) / var:getDef().carry) + 1
                snum = snum + expedLayer.selectSoldierNum[var.defId]
                carry = carry + expedLayer.selectSoldierNum[var.defId] * var:getDef().carry
                break
            end
        end
        -- 兵种优先
    elseif self.cur_choose == 11 or self.cur_choose == 21 or self.cur_choose == 31 then
        for k, v in pairs(pData) do
            -- 除去陷阱
            if v:getDef().bigType ~= 99 then
                table.insert(self.sData, v)
            end
        end
        -- 索引-兵种映射表
        local map = { [11] = 1, [21] = 2, [31] = 3 }
        local currType = map[self.cur_choose]
        -- 本兵种优先 > 战力优先
        table.sort(self.sData, function(a, b)
            local defA = a:getDef()
            local defB = b:getDef()
            local priorityA = defA.bigType == currType and 1 or 2
            local priorityB = defB.bigType == currType and 1 or 2
            if priorityA ~= priorityB then
                return priorityA > priorityB
            else
                return defA.fight < defB.fight
            end
        end )
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            expedLayer.selectSoldierNum[var.defId] = 0
            for j = 1, var.num do
                if snum >= self.mStartMaxArmy then
                    break
                end
                expedLayer.selectSoldierNum[var.defId] = expedLayer.selectSoldierNum[var.defId] + 1
                snum = snum + 1
                carry = carry + var:getDef().carry
            end
        end
        -- 清空选中
    elseif self.cur_choose == 41 then
        for k, v in pairs(pData) do
            if v:getDef().bigType ~= 99 then
                table.insert(self.sData, v)
            end
        end
        table.sort(self.sData, function(a, b)
            return a:getDef().fight < b:getDef().fight
        end )
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            expedLayer.selectSoldierNum[var.defId] = 0
        end
        snum = 0
        carry = 0
    end
    self:setArmydem(snum)
    carry = math.floor(carry *(1 + user.propertyValue["Carry"] + self.WarshipCarry))
    -- 科技加成
    self.Text_Weight:setString(carry)
    self.Text_MarchTime:setString(me.formartSecTime(self:getMarchTime()))
    
    local pHeight = 385
    local isMobilize = false
    if table.nums(self.mWarshipData) > 0 and self.m_ExpedState ~= EXPED_STATE_MOBILIZE then
        pHeight = 392
        isMobilize = true
    end
    local scr_w = 1216
    if isMobilize then
        scr_w = 955
    end

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end
    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end
    local function tableCellTouched(table, cell)


    end
    local function cellSizeForTable(table, idx)
        if isMobilize then
            return 928, 122
        end
        return 1181.5, 122
    end
    local function tableCellAtIndex(table, idx)
        print(idx)
        local cell = table:dequeueCell()
        local soldierdata = self.sData[idx + 1]
        local label = nil
        local item = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = expedCell:create(self.globalItems, "expedItem")
            if isMobilize then
                item:setContentSize(cc.size(928, 122))
                me.assignWidget(item, "Image_48"):setContentSize(cc.size(894.00, 104))
                me.assignWidget(item, "Image_152"):setContentSize(cc.size(900, 115.5))
            else
                item:setContentSize(cc.size(1181.5, 122))
                me.assignWidget(item, "Image_48"):setContentSize(cc.size(1124.00, 104))
                me.assignWidget(item, "Image_152"):setContentSize(cc.size(1130, 115.5))
            end
            item:setPosition(scr_w / 2, item:getContentSize().height / 2)
            item:setMaxTroopsNums(user.maxTroopsNum)
            item:initWithData(soldierdata, self.mStartMaxArmy, self.mStrongMaxArmy, self.m_ExpedState)
            item:setVisitor(self)
            cell:addChild(item)
        else
            item = me.assignWidget(cell, "expedItem")
            item:setMaxTroopsNums(user.maxTroopsNum)
            item:initWithData(soldierdata, self.mStartMaxArmy, self.mStrongMaxArmy, self.m_ExpedState)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end
    
    -- self.border:removeAllChildren()
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(scr_w, pHeight))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(8, 4)
        self.tableView:setDelegate()
        self.border:addChild(self.tableView)
        -- registerScriptHandler functions must be before the reloadData funtion
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function expedLayer:setWarshipData()
    self.mWarshipData = { }
    local pData = user.warshipData
    local pConFig = { }
    for k, v in pairs(cfg[CfgType.SHIP_DATA]) do
        pConFig[v.type] = v
    end
    for key, var in pairs(pConFig) do
        local pHave = pData[var.type]
        if pHave then
            if pHave.status == 2 or pHave.status == 3 then
                pHave.choose = 2
                pHave.Have = expedLayer.SHIP_CHOOSE
                -- 可选
            else
                pHave.Have = expedLayer.SHIP_NOT_CHOOSE
                -- 不可选
            end
            table.insert(self.mWarshipData, pHave)
        else
            var.Have = expedLayer.SHIP_NOT_BUILD
            -- 没有建造
            table.insert(self.mWarshipData, var)
        end
    end
    function shipSort(pa, pd)
        if pa.Have < pd.Have then
            return true
        end
    end
    table.sort(self.mWarshipData, shipSort)

    if #self.mWarshipData > 0 and self.m_ExpedState ~= EXPED_STATE_MOBILIZE then
        me.assignWidget(self, "warship"):setVisible(true)
        self:initWarshipList(self.mWarshipData)
    else
        me.assignWidget(self, "warship"):setVisible(false)
        me.assignWidget(self, "border1"):setContentSize(cc.size(1179, 392))
    end
end
function expedLayer:WarshipTech()
    if self.mChoosepData then
        self.mStartMaxArmy = self.mStartMaxArmy - self.WarshipArmy
        local pShipConfig = self.mChoosepData.baseShipCfg
        local pData = user.Warship_Tech[self.shipType]
        dump(self.mChoosepData)
        if self.mChoosepData and self.mChoosepData.nowFire <= 0 then
            me.showMessageDialog("战舰弹药不足，请补充弹药", function(args)
                if args == "ok" then


                end
            end , 1)
        end

        if self.WarshipSpeed > 0 then
            self.WarshipSpeed = 0
        end
        if self.WarshipArmy > 0 then
            self.WarshipArmy = 0
        end
        if self.WarshipCarry > 0 then
            self.WarshipCarry = 0
        end

        if pData then
            for key, var in pairs(pData) do
                local pConfig = var.Config
                local pTechStr = cfg[CfgType.LORD_INFO][pConfig.exttype]
                if pConfig.exttype == "Speed" then
                    self.WarshipSpeed = self.WarshipSpeed + me.toNum(pConfig.ext)
                end
                if pConfig.exttype == "BingliAdd" then
                    self.WarshipArmy = self.WarshipArmy + me.toNum(pConfig.ext)
                end
                if pConfig.exttype == "Carry" then
                    self.WarshipCarry = self.WarshipCarry + me.toNum(pConfig.ext)
                end
            end
        end
        self.mStartMaxArmy = self.mStartMaxArmy + self.WarshipArmy
        --   self.border:removeAllChildren()
        --    self:initList(self.mArmy)
        if self.WarshipCarry > 0 then
            self.Text_Weight:setString(getTotalCarry(self.mArmy, self.WarshipCarry))
            -- 更新负重
        end
        if self.WarshipSpeed > 0 then
            self.Text_MarchTime:setString(me.formartSecTime(self:getMarchTime()))
            -- 更新时间
        end
        if self.WarshipArmy > 0 then
            -- self.border:removeAllChildren()
            self:initList(self.mArmy)
        end
    end
end
function expedLayer:WarshipCancel()
    self.mStartMaxArmy = self.mStartMaxArmy - self.WarshipArmy
    if self.WarshipCarry > 0 then
        self.WarshipCarry = 0
        self.Text_Weight:setString(getTotalCarry(self.mArmy, self.WarshipCarry))
        -- 更新负重
    end
    if self.WarshipSpeed > 0 then
        self.WarshipSpeed = 0
        self.Text_MarchTime:setString(me.formartSecTime(self:getMarchTime()))
        -- 更新时间
    end
    if self.WarshipArmy > 0 then
        self.WarshipArmy = 0
        -- self.border:removeAllChildren()
        self:initList(self.mArmy)

    end
end
function expedLayer:initWarshipList(pData)
    me.assignWidget(self, "Panel_table"):removeAllChildren()
    local iNum = #pData
    self.WarshiptableView = nil
    if self.mChoosepData then
        for key, var in pairs(self.mWarshipData) do
            if self.mChoosepData.type == var.type then
                var.choose = self.mChoosepData.choose
            end
        end
    end
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end
    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end
    local function tableCellTouched(table, cell)

        self.mChoosepData = self.mWarshipData[cell:getIdx() + 1]
        if self.mChoosepData.Have == expedLayer.SHIP_CHOOSE then
            if self.mChoosepData.status == 2 then
                if self.mChoosepData.choose == 1 then
                    self.mChoosepData.choose = 2
                    self.shipType = 0
                    self:WarshipCancel()
                else
                    if mWarshipHint == 0 then
                        local box = warship_hint:create("warship_hint.csb")
                        box:register( function(node)
                            for key, var in pairs(self.mWarshipData) do
                                var.choose = 2
                            end
                            self.mChoosepData.choose = 1
                            self.shipType = self.mChoosepData.baseShipCfg.type
                            self:WarshipTech()
                            local pOffest = self.WarshiptableView:getContentOffset()
                            self.WarshiptableView:reloadData()
                            self.WarshiptableView:setContentOffset(pOffest)
                        end )
                        self:addChild(box)
                    else
                        for key, var in pairs(self.mWarshipData) do
                            var.choose = 2
                        end
                        self.mChoosepData.choose = 1
                        self.shipType = self.mChoosepData.baseShipCfg.type
                        self:WarshipTech()
                    end
                end
            else
                if self.mChoosepData.choose == 1 then
                    self.mChoosepData.choose = 2
                    self.shipType = 0
                    self:WarshipCancel()
                else
                    for key, var in pairs(self.mWarshipData) do
                        var.choose = 2
                    end
                    self.mChoosepData.choose = 1
                    self.shipType = self.mChoosepData.baseShipCfg.type
                    self:WarshipTech()
                end
            end

            local pOffest = self.WarshiptableView:getContentOffset()
            self.WarshiptableView:reloadData()
            self.WarshiptableView:setContentOffset(pOffest)
        end
    end
    local function cellSizeForTable(table, idx)
        return 228, 138
    end
    local function tableCellAtIndex(table, idx)
        --  print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pData = self.mWarshipData[idx + 1]
            local Panel_cell = me.assignWidget(self, "Panel_warship_cell"):clone():setVisible(true)
            self:setWarshipCell(Panel_cell, pData, idx + 1)
            cell:addChild(Panel_cell)
        else
            local Panel_cell = me.assignWidget(cell, "Panel_warship_cell")
            local pData = self.mWarshipData[idx + 1]
            self:setWarshipCell(Panel_cell, pData, idx + 1)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end

    local tableView = cc.TableView:create(cc.size(228, 358))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setPosition(0, 1)
    tableView:setDelegate()
    me.assignWidget(self, "Panel_table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.WarshiptableView = tableView
end
function expedLayer:setWarshipCell(node, pData, idx)
    if node then
        local Panel_icon = me.assignWidget(node, "Panel_icon")
        local pIconStr = ""
        if pData.Have == expedLayer.SHIP_CHOOSE or pData.Have == expedLayer.SHIP_NOT_CHOOSE then
            pIconStr = pData.baseShipCfg.icon
        else
            pIconStr = pData.icon
        end
        local pIcon = me.createSprite("zhanjian_tupian_zhanjian_" .. pIconStr .. ".png")
        pIcon:setScale(0.3)
        Panel_icon:addChild(pIcon)
        local Image_5 = me.assignWidget(node, "Image_5")
        if pData.Have == expedLayer.SHIP_CHOOSE or pData.Have == expedLayer.SHIP_NOT_CHOOSE then
            local pConfig = pData.baseShipCfg
            Image_5:setVisible(false)
            local warshipchoose = me.assignWidget(node, "warshipchoose")
            local Image_8 = me.assignWidget(node, "Image_8"):setVisible(false)
            me.assignWidget(node, "Image_6"):setVisible(true)
            me.assignWidget(node, "Image_4"):setVisible(true)
            if pData.Have == expedLayer.SHIP_CHOOSE then
                Image_8:setVisible(false)
                if pData.choose == 1 then
                    warshipchoose:setVisible(true)
                else
                    warshipchoose:setVisible(false)
                end
            else
                warshipchoose:setVisible(false)
                Image_8:setVisible(true)
            end
            local bar_danyao = me.assignWidget(node, "bar_danyao")
            local pLevel = me.assignWidget(node, "warshiplevel")
            bar_danyao:setPercent(pData.nowFire * 100 / pConfig.endure)
            pLevel:setString(pConfig.lv)
            local Button_Danyao = me.registGuiClickEventByName(node, "Button_Danyao", function(args)
                NetMan:send(_MSG.ship_bl(pData.type))
            end )
            me.setButtonDisable(Button_Danyao, true)
            --  warship_icon:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png")
            me.revokeSprite(pIcon)
            local barDanyao= bar_danyao:getVirtualRenderer():getSprite()
            me.revokeSprite(barDanyao)

            local warship_status = me.assignWidget(node, "warship_status"):setVisible(true)
            local pStatusStr = "空闲"
            if pData.status == 2 then
                -- 城市中
                pStatusStr = "守城中"
            elseif pData.status == 3 then
                -- 空闲中
                pStatusStr = "空闲"
            elseif pData.status == 1 then
                pStatusStr = "行军中"
            elseif pData.status == 4 then
                pStatusStr = "航海中"
            end
            warship_status:setString(pStatusStr)
        else
            me.graySprite(pIcon)
            me.graySprite(me.assignWidget(node, "Image_1"))
            Image_5:setVisible(true)
            local warship_status = me.assignWidget(node, "warship_status"):setVisible(false)
            me.assignWidget(node, "warshipchoose"):setVisible(false)
            me.assignWidget(node, "Image_8"):setVisible(false)
            me.assignWidget(node, "Image_6"):setVisible(false)
            me.assignWidget(node, "Image_4"):setVisible(false)
            me.setButtonDisable(me.assignWidget(node, "Button_Danyao"), false)
            local bar_danyao = me.assignWidget(node, "bar_danyao")
            bar_danyao:setPercent(100)
            local barDanyao= bar_danyao:getVirtualRenderer():getSprite()
            me.graySprite(barDanyao)
        end
    end
end
function expedLayer:onEnter()
    print("expedLayer:onEnter()")
    me.doLayout(self, me.winSize)
    me.doLayout(me.assignWidget(self, "fixLayout"), me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:updata(msg)
    end )
end
function expedLayer:updata(msg)
    if checkMsg(msg.t, MsgCode.SHOP_INIT) then
        -- 完成任务
        local powerShop = vipShopView:create("vipShopView.csb")
        powerShop:expendMax()
        self:addChild(powerShop)
        me.showLayer(powerShop, "bg")
    elseif checkMsg(msg.t, MsgCode.ROLE_BUFF_UPDATE) then
        -- self.border:removeAllChildren()
        self:setMaxArmy()
        self:initList(self.mArmy)
        self:setArmyShop()
    elseif checkMsg(msg.t, MsgCode.MSG_SHIP_BL) then
        if msg.c.needNum > 0 then
            me.showMessageDialog("是否花费" .. msg.c.needNum .. cfg[CfgType.ETC][tonumber(msg.c.sourceId)].name .. "补满弹药?", function(rev)
                if rev == "ok" then
                    NetMan:send(_MSG.Ship_restore(msg.c.type, msg.c.addEndure, true))
                end
            end )
        else
            showTips("弹药已满")
        end

    elseif checkMsg(msg.t, MsgCode.MSG_WARSHIP_UPDATE) then
        self:setWarshipData()
    elseif checkMsg(msg.t, MsgCode.ROLE_POWER_UPDATE) then
        if self.mbossType == BOOS_RUNEALTAR or self.mbossType == "bigdragon" or self.mbossType == "smalldragon" or self.mbossType == "randevent" or self.mbossType == "herolevel" or self.mbossType == BOSS_OCCUPATION then
            local cost = me.assignWidget(self, "Text_costShrength_num_total")
            if self.mbossType == "randevent" then
                tili = tonumber(cfg[CfgType.CFG_CONST][36].data)
            elseif self.mbossType == "herolevel" then
                tili = tonumber(cfg[CfgType.CFG_CONST][20].data)
            elseif self.mbossType == "bigdragon" then
                tili = tonumber(cfg[CfgType.CFG_CONST][44].data)
            elseif self.mbossType == "smalldragon" then
                tili = tonumber(cfg[CfgType.CFG_CONST][34].data)
            else
                tili = tonumber(cfg[CfgType.CFG_CONST][34].data)
            end
            if tili > user.currentPower then
                cost:setTextColor(cc.c4b(255, 0, 0, 255))
                self.isVitEnough = false
            else
                cost:setTextColor(cc.c4b(65, 229, 33, 255))
                self.isVitEnough = true
            end
            cost:setString(Scientific(user.currentPower))
            local cost1 = me.assignWidget(self, "Text_costShrength_num_boos")
            cost1:setPositionX(cost:getPositionX() + cost:getContentSize().width + 1)
            me.assignWidget(self, "Button_addStrength_boos"):setPositionX(cost1:getPositionX() + cost1:getContentSize().width + 2)
        else
            self:computeCostStrength()
        end
    end
end
function expedLayer:setBoosType(bossType)
    print("setBoosType" .. bossType)
    self.mbossType = bossType
    self:BoosType()
end
function expedLayer:BoosType()
    print("BoosType" .. self.mbossType)
    if self.mbossType == BOOS_RUNEALTAR or self.mbossType == "bigdragon" or self.mbossType == "smalldragon" or self.mbossType == "randevent" or self.mbossType == BOSS_OCCUPATION or self.mbossType == "herolevel" then
        local Text_costShrength = me.assignWidget(self, "Text_costShrength_boos"):setVisible(true)
        Text_costShrength:setPosition(cc.p(735, 108))
        local cost1 = me.assignWidget(self, "Text_costShrength_num_boos")
        local tili
        if self.mbossType == "randevent" then
            tili = tonumber(cfg[CfgType.CFG_CONST][36].data)
        elseif self.mbossType == "herolevel" then
            tili = tonumber(cfg[CfgType.CFG_CONST][20].data)
        elseif self.mbossType == "bigdragon" then
            tili = tonumber(cfg[CfgType.CFG_CONST][44].data)
        elseif self.mbossType == "smalldragon" then
            tili = tonumber(cfg[CfgType.CFG_CONST][34].data)
        else
            tili = tonumber(cfg[CfgType.CFG_CONST][34].data)
        end
        cost1:setString("/" .. tili)
        local cost = me.assignWidget(self, "Text_costShrength_num_total")
        if tili > user.currentPower then
            cost:setTextColor(cc.c4b(255, 0, 0, 255))
            self.isVitEnough = false
        else
            cost:setTextColor(cc.c4b(65, 229, 33, 255))
            self.isVitEnough = true
        end
        cost:setString(Scientific(user.currentPower))
        local cost1 = me.assignWidget(self, "Text_costShrength_num_boos")
        cost1:setPositionX(cost:getPositionX() + cost:getContentSize().width + 1)
        me.assignWidget(self, "Button_addStrength_boos"):setPositionX(cost1:getPositionX() + cost1:getContentSize().width + 2)
    end
end
function expedLayer:setArmyShop()
    self.mTimeLabel = me.assignWidget(self, "add_army_time")
    if self.ArmyTime then
        me.clearTimer(self.ArmyTime)
        self.ArmyTime = nil
    end
    --[[  --不用显示buffer时间
    if user.Role_Buff["BingliAddPct"] and user.Role_Buff["BingliAddPct"][1] then
        self.mTimeLabel:setVisible(true)
        self.mTime =(user.Role_Buff["BingliAddPct"][1].countDown - me.sysTime()) / 1000
        self.ArmyTime = me.registTimer(-1, function(dt)
            if self.mTime > 0 then
                self.mTime = self.mTime - 1
                self.mTimeLabel:setString(me.formartSecTime(self.mTime))
            else
                me.clearTimer(self.ArmyTime)
                self.ArmyTime = nil
            end
        end , 1)
    else
        self.mTimeLabel:setVisible(false)
    end
    ]]
    self.mTimeLabel:setVisible(false)
end
function expedLayer:setArmydem(snum)
    self.mcurTotalNum = snum
    local pSnum = snum
    local pMaxnum = user.maxTroopsNum
    self.Text_TroopsNum:setString(math.floor(snum) .. "/")
    self.Text_Troopsdem:setString(pMaxnum)
    if user.Role_Buff["BingliAddPct"] then
        self.Text_Troopsdem:setTextColor(cc.c4b(111, 209, 32, 255))
    else
        self.Text_Troopsdem:setTextColor(cc.c4b(255, 255, 255, 255))
    end
    self.Text_Troopsdem:setPosition(cc.p((self.Text_TroopsNum:getContentSize().width +self.Text_TroopsNum:getPositionX()), self.Text_TroopsNum:getPositionY()))
end
function expedLayer:setStrongData()

    self.Node_stronghold:setVisible(true)
    local def = self.mStronghold:getDef()
    local pStrongArmyNum = self.mStronghold:getArmyNum()
    local Strong_defense_left = me.assignWidget(self, "Strong_defense_left")
    local Strong_defense_right = me.assignWidget(self, "Strong_defense_right")
    local Strong_army_left = me.assignWidget(self, "Strong_army_left")
    local Strong_army_right = me.assignWidget(self, "Strong_army_right")
    local Strong_name_left = me.assignWidget(self, "Strong_name_left")
    local Strong_name_right = me.assignWidget(self, "Strong_name_right")
    me.assignWidget(self, "Strong_distance"):setString("行军距离:" .. " " .. string.format("%.1f", self.m_Distence_cell))
    local lordData = getUserLordData()
    if self.m_ExpedState == EXPED_STATE_MOBILIZE then
        local pStringArmyNum_left = nil
        local pDef_num = ""
        local pStringDefense_left = nil
        local pStringName_before = nil
        local pStringLv = nil
        if self.mOtherStrongHold == nil then
            -- 主城调迁到据点
            pStringDefense_left = lordData.cityDefense
            pStringArmyNum_left = getCityArmyNum()
            pStringName_before = user.name
            pStringLv = user.lv
        else
            local def_before = self.mOtherStrongHold:getDef()
            pDef_num = "/" .. def_before.num
            pStringArmyNum_left = self.mOtherStrongHold:getArmyNum()
            pStringDefense_left = self.mOtherStrongHold.defense
            pStringName_before = self.mOtherStrongHold.name
            pStringLv = self.mOtherStrongHold.lv
        end
        Strong_defense_right:setString(self.mStronghold.defense)
        Strong_defense_left:setString(pStringDefense_left)
        Strong_army_right:setString(getCurSelectSoldierNum() + pStrongArmyNum .. "/" .. def.num)
        Strong_army_left:setString(pStringArmyNum_left - getCurSelectSoldierNum() .. pDef_num)
        if me.toNum(getCurSelectSoldierNum() + pStrongArmyNum) > me.toNum(def.num) then
            Strong_army_right:setColor(COLOR_RED)
            me.setButtonDisable(self.Button_Battle, false)
            self.Button_Battle:setColor(cc.c3b(114, 114, 114))
        else
            Strong_army_right:setColor(COLOR_WHITE)
            me.setButtonDisable(self.Button_Battle, true)
            self.Button_Battle:setColor(COLOR_WHITE)
        end
        Strong_name_right:setString(self.mStronghold.name .. " Lv." .. self.mStronghold.lv)
        Strong_name_left:setString(pStringName_before .. " Lv." .. pStringLv)
    elseif self.m_ExpedState == STRONG_ARMY_RETURN then
        Strong_army_left:setString((pStrongArmyNum - getCurSelectSoldierNum()) .. "/" .. def.num)
        Strong_army_right:setString((getCityArmyNum() + getCurSelectSoldierNum()))
        Strong_defense_left:setString(self.mStronghold.defense)
        Strong_defense_right:setString(lordData.cityDefense)
        Strong_name_left:setString(self.mStronghold.name .. " Lv." .. self.mStronghold.lv)
        Strong_name_right:setString(user.name .. " Lv." .. user.lv)
    end
end
function expedLayer:setMaxArmy()
    if self.m_ExpedState == EXPED_STATE_MOBILIZE then
        local def = self.mStronghold:getDef()
        local pStrongArmyNum = self.mStronghold:getArmyNum()
        self.mStartMaxArmy = math.min((def.num - pStrongArmyNum), user.maxTroopsNum)
        self.mStrongMaxArmy =(def.num - pStrongArmyNum)
    elseif self.m_ExpedState == STRONG_ARMY_RETURN then
        me.assignWidget(self.Button_Battle,"image_title"):setString("撤回")
        local pStrongArmyNum = self.mStronghold:getArmyNum()
        self.mStartMaxArmy = math.min(pStrongArmyNum, user.maxTroopsNum)
        self.mStrongMaxArmy = pStrongArmyNum
    else
        self.mStartMaxArmy = user.maxTroopsNum
    end
    print(self.mStartMaxArmy)
end
function expedLayer:setConvergeArmy(pMaxArmy)
    self.mStrongMaxArmy = pMaxArmy
    self.mStartMaxArmy = math.min(pMaxArmy, user.maxTroopsNum)
end
function expedLayer:setStar(pData)
    print("expedLayer onEnter")
    me.assignWidget(self, "Text_distance"):setVisible(true)
    local addValue = string.format("%.1f", self.m_Distence_cell * me.toNum(cfg[CfgType.CFG_CONST][17].data) * 100)
    me.assignWidget(self, "Text_distance"):setString("行军距离:" .. string.format("%.1f", self.m_Distence_cell) .. "(土地守军+" .. addValue .. "%)")
    if self.m_ExpedState == EXPED_STATE_OCC then
        me.assignWidget(self, "distance_ani"):setVisible(tonumber(addValue) >= 50)
        local id = me.getIdByCoord(self.m_Paths.tag)
        local celldata = gameMap.mapCellDatas[id]
        if celldata then
            if celldata.pointType ~= POINT_NORMAL then
                me.assignWidget(self, "Text_distance"):setString("行军距离:" .. string.format("%.1f", self.m_Distence_cell))
            end       
        end
    else
        me.assignWidget(self, "distance_ani"):setVisible(false)        
        me.assignWidget(self, "Text_distance"):setString("行军距离:" .. string.format("%.1f", self.m_Distence_cell))
    end
    self.Node_archaeology:setVisible(self.m_ExpedState == EXPED_STATE_ARCH)
    if self.m_ExpedState == EXPED_STATE_ARCH or self.m_ExpedState == EXPED_STATE_MOBILIZE or self.m_ExpedState == STRONG_ARMY_RETURN then
        self.Node_expdition:setVisible(false)
    end
    if self.m_ExpedState ~= TEAM_ARMY_JOIN and self.m_ExpedState ~= TEAM_ARMY_DEFENS and self.m_ExpedState ~= THRONE_TEAM_JOIN then
        self:setMaxArmy()
    end
    if self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == TEAM_WAIT or self.m_ExpedState == THRONE_TEAM_JOIN or self.m_ExpedState == THRONE_TEAM_WAIT then
        self.title:setString("集火")
    end
    self.mArmy = pData
    self:initList(pData)
    if self.m_ExpedState == EXPED_STATE_MOBILIZE or self.m_ExpedState == STRONG_ARMY_RETURN then
        self:setStrongData()
    end
    if self.m_ExpedState == EXPED_STATE_ARCH then
        self.Image_Rec:setVisible(false)
        self:setArchInfo()
        self.cur_choose = 5
        self:initList(self.mArmy)
        self:computeCostTime()
        -- 探索 普通车队、豪华车队，负重优先
    elseif EXPED_STATE_PILLAGE == self.m_ExpedState then
        local id = me.getIdByCoord(self.m_Paths.tag)
        local celldata = gameMap.mapCellDatas[id]
        if celldata and celldata:bHaveEvent() then
            local defData = celldata:getEventDef()
            if defData and defData.type ~= 5 and defData.type ~= 6 and(celldata.eventWagon == 0 or celldata.eventWagon == 1) then
                self.expectWeight = celldata.eventData
                self.cur_choose = 3
                self.Panel_Rec:setVisible(false)
                self.Text_Rec:setString("负重优先")
                self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)
                self:initList(self.mArmy)
            end
        end
    end
    self:setArmyShop()
    if guideHelper.getGuideIndex() >= guideHelper.guideGoToArch then
        -- 考古单独处理
        local cell = self:getCellForGuide()
        if cell == nil then
            __G__TRACKBACK__("cell = nil ,引导出错，强制关闭引导")
            guideHelper.forceCloseGuideHelper()
            return
        end
        local timeBtn = me.assignWidget(cell, "Button_time")
        if timeBtn == nil then
            __G__TRACKBACK__("timeBtn = nil ,引导出错，强制关闭引导")
            guideHelper.forceCloseGuideHelper()
            return
        end
        me.DelayRun( function()
            print(guideHelper.guideIndex)
            if guideHelper.guideIndex == guideHelper.guideGoToArch + 3 then
                guideHelper.nextStepByOpt(false, timeBtn, false)
            end
        end )
    else
        -- 探索和出征
        me.DelayRun( function()
            print(guideHelper.guideIndex)
            if guideHelper.guideIndex == guideHelper.guideConquest + 4 or guideHelper.guideIndex == guideHelper.guideExplore + 3 then
                guideHelper.nextStepByOpt(false, self.Button_Battle, false)
            end
        end )
    end
end
function expedLayer:getCellForGuide()
    return self.archBtn[1]
end
function expedLayer:getWeightSingle()
    local weightSingle = 50
    -- cfg[CfgType.CFG_CONST][21].data
    if user.maxTroopsNum <= 5000 then
        weightSingle = 50
    else
        weightSingle = math.floor(((user.maxTroopsNum - 5000) / 1500 + 50) * math.pow(math.max(getCenterBuildingLevel() -5, 1), 1.1))
    end
    return weightSingle
end
function expedLayer:setArchInfo()
    local weightSingle = self:getWeightSingle()
    -- 单位负重
    self.Panel_archNums = me.assignWidget(self, "Panel_archNums")
    self.Text_costShrength = me.assignWidget(self, "Text_costShrength")

    local totalItemNum = 5
    for index = 1, totalItemNum do
        if #self.archBtn < totalItemNum then
            local btn = me.assignWidget(self, "Panel_Num"):clone()
            self.Panel_archNums:addChild(btn)
            btn:setPosition(cc.p((index - 1) * btn:getContentSize().width, 45))
            btn:setVisible(true)
            self.archBtn[#self.archBtn + 1] = btn
        end
        local totalWeight = timeNum[index] * weightSingle
        local btnTime = me.assignWidget(self.archBtn[index], "Button_time")
        local textOver = me.assignWidget(self.archBtn[index], "Text_overLoad")
        local textNum = me.assignWidget(self.archBtn[index], "Text_num")
        if me.toNum(self.Text_Weight:getString()) < totalWeight then
            textOver:setString("负重>" .. totalWeight)
            textOver:setVisible(true)
            textNum:setTextColor(COLOR_EXPED_GRAY)
            btnTime:setEnabled(false)
        else
            textNum:setTextColor(cc.c3b(230,201, 137))
            textOver:setVisible(false)
            btnTime:setEnabled(true)
            local s = cfg[CfgType.CFG_CONST][20].data
            -- 单位消耗体力
            if user.currentPower >= timeNum[index] * s then
                self.targetIndex = index
            end
        end
        me.registGuiClickEvent(btnTime, function(node)
            self:resetArch(node:getTag())
            self:initList(self.mArmy)
            if guideHelper.getGuideIndex() == guideHelper.guideGoToArch + 4 then
                me.DelayRun( function()
                    guideHelper.nextStepByOpt(false, self.Button_Battle, false)
                end )
            end
        end )
        textNum:setString(timeNum[index] .. "次")
        me.assignWidget(self.archBtn[index], "Image_light"):setVisible(false)
        btnTime:setTag(index)
    end

    if self.targetIndex == 0 then
        self.targetIndex = 1
    end
    -- 城镇中心6级以下默认选1次
    local centerLv = user.centerBuild:getDef().level
    if centerLv <= 6 then
        self.targetIndex = 1
    end
    self:computeCostStrength()
    me.assignWidget(self.archBtn[self.targetIndex], "Image_light"):setVisible(true)
end
-- 考古消耗的体力
function expedLayer:computeCostStrength()
    local strenghtSingle = cfg[CfgType.CFG_CONST][20].data
    -- 单位消耗体力
    local cost = me.assignWidget(self.Node_archaeology, "Text_costShrength_num_total_1")
    self.targetIndex = self.targetIndex or 1

    if timeNum[self.targetIndex] * strenghtSingle > user.currentPower then
        cost:setTextColor(cc.c4b(255, 0, 0, 255))
        self.isVitEnough = false
    else
        cost:setTextColor(cc.c4b(127, 206, 109, 255))
        self.isVitEnough = true
    end
    cost:setString(Scientific(user.currentPower))

    local cost1 = me.assignWidget(self, "Text_costShrength_num")
    cost1:setString("/" .. timeNum[self.targetIndex] * strenghtSingle)

    cost1:setPositionX(cost:getPositionX() + cost:getContentSize().width + 1)
    me.assignWidget(self, "Button_addStrength"):setPositionX(cost1:getPositionX() + cost1:getContentSize().width + 2)


end
-- 考古消耗的时间
function expedLayer:computeCostTime()
    self.Text_costTime = me.assignWidget(self, "Text_costTime")
    local dis = self:getDistence()
    local tarT = nil
    for key, var in pairs(cfg[CfgType.BOOK_SPEED]) do
        if me.toNum(dis) >= var.dist1 and me.toNum(dis) < var.dist2 then
            tarT = var.time
            break
        end
    end
    self.Text_costTime:setString("消耗时间：" .. me.formartSecTime(tarT * timeNum[self.targetIndex]))
end
function expedLayer:canGoForArch()
    local weightSingle = cfg[CfgType.CFG_CONST][21].data
    -- 单位负重
    if timeNum[self.targetIndex] * weightSingle > me.toNum(self.Text_Weight:getString()) then
        showTips("负重不够")
        return false
    end

    local strenghtSingle = cfg[CfgType.CFG_CONST][20].data
    -- 单位消耗体力
    if timeNum[self.targetIndex] * strenghtSingle > user.currentPower then
        showTips("体力不够")
        return false
    end

    return true
end
-- 重新计算考古相关信息 
function expedLayer:resetArch(index_)
    for key, var in pairs(self.archBtn) do
        me.assignWidget(var, "Image_light"):setVisible(key == index_)
    end
    self.targetIndex = index_
    self:computeCostStrength()
    self:computeCostTime()
end
function expedLayer:updateMaxTroops()
    self:setArmydem(getCurSelectSoldierNum())
    self.Text_Weight:setString(getTotalCarry(self.mArmy, self.WarshipCarry))
    self.Text_MarchTime:setString(me.formartSecTime(self:getMarchTime()))
    if self.m_ExpedState == EXPED_STATE_ARCH then
        self:setArchInfo()
    elseif self.m_ExpedState == EXPED_STATE_MOBILIZE then
        local def = self.mStronghold:getDef()
        local lordData = getUserLordData()
        local def_left_num = ""
        local pStrongArmyNum = self.mStronghold:getArmyNum()
        local pStringArmyNum_left = getCityArmyNum()
        if self.mOtherStrongHold ~= nil then
            pStringArmyNum_left = self.mOtherStrongHold:getArmyNum()
            def_left_num = "/" .. self.mOtherStrongHold:getDef().num
        end
        local Strong_army_right = me.assignWidget(self, "Strong_army_right")
        local Strong_army_left = me.assignWidget(self, "Strong_army_left")
        Strong_army_right:setString(getCurSelectSoldierNum() + pStrongArmyNum .. "/" .. def.num)
        Strong_army_left:setString(pStringArmyNum_left - getCurSelectSoldierNum() .. def_left_num)
        if me.toNum(getCurSelectSoldierNum() + pStrongArmyNum) > me.toNum(def.num) then
            Strong_army_right:setColor(COLOR_RED)
            me.setButtonDisable(self.Button_Battle, false)
            self.Button_Battle:setColor(cc.c3b(114, 114, 114))
        else
            Strong_army_right:setColor(COLOR_WHITE)
            me.setButtonDisable(self.Button_Battle, true)
            self.Button_Battle:setColor(COLOR_WHITE)
        end
    elseif self.m_ExpedState == STRONG_ARMY_RETURN then
        local def = self.mStronghold:getDef()
        local pStrongArmyNum = self.mStronghold:getArmyNum()
        local cityArmy = getCityArmyNum()
        local Strong_army_left = me.assignWidget(self, "Strong_army_left")
        local Strong_army_right = me.assignWidget(self, "Strong_army_right")
        Strong_army_right:setString(cityArmy + getCurSelectSoldierNum())
        Strong_army_left:setString(pStrongArmyNum - getCurSelectSoldierNum() .. "/" .. def.num)
    end
end
function expedLayer:setQueueNum(num)
    self.curQueueNum = num
    armyData.toops = user.propertyValue["TroopsAdd"] - num
    self.textQueueNum:setString("可用行军队列:" .. armyData.toops .. "/" .. user.propertyValue["TroopsAdd"])
end
function expedLayer:onExit()
    print("expedLayer onExit")
    if self.globalItems then self.globalItems:release() end
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        if pWorldMap.exped then
            pWorldMap.exped = nil
        end
    end

    me.clearTimer(self.ArmyTime)
    self.ArmyTime = nil
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end

function expedLayer:setNpc(num, show)
    self.npc = num
    self.bshow = show
end
function expedLayer:setConver(waitTime, teamId, surplusTime)
    dump(waitTime)
    self.waitTime = waitTime
    -- 集结时间
    self.teamId = teamId
    -- 加入集结的ID
    self.surplusTime = surplusTime
    -- 加入集火剩余时间
end
function expedLayer:showConfirmView(army, str)
    self.confirmView = cc.CSLoader:createNode("MessageBox.csb")
    me.doLayout(self.confirmView, me.winSize)
    me.assignWidget(self.confirmView, "msg"):setString(str or "敌军强势，领主大人小心，是否确定出征？")
    me.registGuiClickEventByName(self.confirmView, "btn_ok", function(node)
        self:goToBattle(army)
        self.confirmView:removeFromParent()
        self.confirmView = nil
    end )
    me.registGuiClickEventByName(self.confirmView, "btn_cancel", function(node)
        self.confirmView:removeFromParent()
        self.confirmView = nil
    end )
    self:addChild(self.confirmView)
end
function expedLayer:getTagPoint()
    return cc.p(self.m_Paths.tag.x, self.m_Paths.tag.y)
end
function expedLayer:setStartType(pType)
    self.mStartType = pType
end
function expedLayer:goToBattle(army)
    -- if self.curQueueNum < user.propertyValue["TroopsAdd"] then
    local function xbattle()
        if self.isVitEnough == false then
            showTips("体力不够")
            local powerShop = vipShopView:create("vipShopView.csb")
            powerShop:initCost()
            self:addChild(powerShop)
            me.showLayer(powerShop, "bg")
            return
        end
        if self.m_ExpedState == EXPED_STATE_ARCH then
            -- 考古出征
            if self:canGoForArch() then
                --            print("timeNum[self.targetIndex] = "..timeNum[self.targetIndex])
                --            print("self.targetIndex = "..self.targetIndex)
                GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, self:getExpedState(), army, self.shipType, timeNum[self.targetIndex], 0))
            end
        elseif self.m_ExpedState == EXPED_STATE_DIGORE then
            NetMan:send(_MSG.digoreExped(self.digoreData.groupId, self.digoreData.index, army, self.shipType))
        elseif self.m_ExpedState == TEAM_WAIT or self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == TEAM_ARMY_DEFENS or self.m_ExpedState == THRONE_TEAM_WAIT or self.m_ExpedState == THRONE_TEAM_JOIN then
            local petId = nil
            if self.petCheckBox:isSelected() then
                if self.currentPetId then
                    petId = self.currentPetId
                end
            end
            if self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == THRONE_TEAM_JOIN then
                if self.surplusTime < self:getMarchTime() then
                    local pStr = "你的行军时间大于集火的集结时间，你的部队可能不能参与本次集火"
                    me.showMessageDialog(pStr, function(args)
                        if args == "ok" then
                            if (self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == THRONE_TEAM_JOIN) and CUR_GAME_STATE == GAME_STATE_CITY then
                                showWaitLayer()
                            end
                            GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, self:getExpedState(), army, self.shipType, 0, petId, self.waitTime, self.teamId))
                            self:close()
                        else
                            self:close()
                        end
                    end )
                else
                    if (self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == THRONE_TEAM_JOIN) and CUR_GAME_STATE == GAME_STATE_CITY then
                        showWaitLayer()
                    end
                    GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, self:getExpedState(), army, self.shipType, 0, petId, self.waitTime, self.teamId))
                end
            else
                GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, self:getExpedState(), army, self.shipType, 0, petId, self.waitTime, self.teamId))
            end
            -- 出征时保存出征宠物ID
            if self.currentPetId then
                local isSelected = 0
                if self.petCheckBox:isSelected() then
                    isSelected = 1
                end
                local str = me.toStr(self.currentPetId .. "|" .. isSelected)
                SharedDataStorageHelper():setUserPet(str)
            end
        else
            local petId = nil
            if self.petCheckBox:isSelected() then
                if self.currentPetId then
                    petId = self.currentPetId
                end
            end
            -- user.dressPetId = petId
            if self.m_ExpedState == STRONG_ARMY_RETURN then
                -- 召回
                GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, EXPED_STATE_MOBILIZE, army, self.shipType, 0, petId))
            else
                GMan():send(_MSG.worldMapArmyDp(self.m_Paths.ori.x, self.m_Paths.ori.y, self.m_Paths.tag.x, self.m_Paths.tag.y, self:getExpedState(), army, self.shipType, 0, petId))
            end

            -- 出征时保存出征宠物ID
            if self.currentPetId then
                local isSelected = 0
                if self.petCheckBox:isSelected() then
                    isSelected = 1
                end
                local str = me.toStr(self.currentPetId .. "|" .. isSelected)
                SharedDataStorageHelper():setUserPet(str)
            end
            if self:getExpedState() == EXPED_STATE_FORT then
                self:close()
            end
            -- else
            -- showTips("出征队列已满")
            -- end
        end
        if (self.m_ExpedState == TEAM_ARMY_JOIN or self.m_ExpedState == THRONE_TEAM_JOIN) and self.surplusTime < self:getMarchTime() then
            if self.surplusTime == 0 then
                self:close()
            end
        else
            self:close()
        end
    end
    if self.m_ExpedState ~= EXPED_STATE_BACKHOME and
        self.m_ExpedState ~= EXPED_STATE_STATION and
        self.m_ExpedState ~= EXPED_STATE_ARCH and
        self.m_ExpedState ~= STRONG_ARMY_RETURN and
        self.m_ExpedState ~= EXPED_STATE_HEROLEVEL and
        self.m_ExpedState ~= EXPED_STATE_DIGORE and
        self.m_ExpedState ~= EXPED_STATE_MOBILIZE
    then
        local date = os.date("%Y-%m-%d")
        local saveDiamondNotenoughTime = cc.UserDefault:getInstance():getStringForKey("askBattle_MessageDialog", "")
        if saveDiamondNotenoughTime == date or user.needaskBattle == false then
            xbattle()
            return
        end
        local confirmView = cc.CSLoader:createNode("MessageBox_AskBattle.csb")
        me.doLayout(confirmView, me.winSize)
        local checkBox = me.assignWidget(confirmView, "checkBox")

        me.registGuiClickEventByName(confirmView, "btn_ok", function(node)
            if checkBox:isSelected() then
                cc.UserDefault:getInstance():setStringForKey("askBattle_MessageDialog", date)
                cc.UserDefault:getInstance():flush()
            end
            xbattle()
            confirmView:removeFromParent()
        end )
        me.registGuiClickEventByName(confirmView, "btn_cancel", function(node)
            confirmView:removeFromParent()
        end )
        me.registGuiClickEventByName(confirmView, "tips3", function(node)
            if checkBox:isSelected() then
                checkBox:setSelected(false)
            else
                checkBox:setSelected(true)
            end
        end )
        cc.Director:getInstance():getRunningScene():addChild(confirmView, MESSAGE_ORDER)
        me.showLayer(confirmView, "msgBox")
    else
        if self.m_ExpedState == EXPED_STATE_HEROLEVEL then
            local function continue(str)
                if str == "ok" then
                    xbattle()
                end
            end
            if self.herolevelData.isWin == false then
                if self.herolevelData.revert == 0 then
                    me.showMessageDialog("已达复活次数上限，无法再闯关", nil, 1)
                elseif self.herolevelData.revert > 0 and self.herolevelData.revertGem == 0 then
                    me.showMessageDialog("消耗复活次数继续闯关吗？", continue)
                elseif self.herolevelData.revert > 0 and self.herolevelData.revertGem > 0 then
                    me.showMessageDialog("是否花费" .. self.herolevelData.revertGem .. "钻石复活并闯关？", continue)
                end
                return
            else
                xbattle()
            end
        else
            xbattle()
        end
    end
end