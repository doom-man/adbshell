-- [Comment]
-- jnmo
defSoldierChoose = class("defSoldierChoose", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
defSoldierChoose.__index = defSoldierChoose
function defSoldierChoose:create(...)
    local layer = defSoldierChoose.new(...)
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

function getCurSelectSoldierNum()
    local num = 0
    for key, var in pairs(expedLayer.selectSoldierNum) do
        num = num + var
    end
    return num
end
function defSoldierChoose:ctor()
    print("defSoldierChoose ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.SHOP_INIT) then
            local powerShop = vipShopView:create("vipShopView.csb")
            powerShop:expendMax()
            self:addChild(powerShop)
            me.showLayer(powerShop, "bg")
        elseif checkMsg(msg.t, MsgCode.ROLE_BUFF_UPDATE) then
        --self.border:removeAllChildren()
            self:initList()
            self.Text_Troopsdem:setString(self.maxTroopsNum)
        elseif checkMsg(msg.t, MsgCode.MSG_GUARD_ARMY_INIT) then
            self:setMaxTroopsNums(msg.c.max)
            self:setData(msg.c)
            if msg.c.army then
                user.guardSoldier = {}
                for key, var in pairs(msg.c.army) do
                    local sdata = soldierData.new(tonumber(var[1]),tonumber(var[2]))
                    user.guardSoldier[tonumber(var[1])] = sdata
                end                
                self:initList()
            end
        end
    end )
end
function defSoldierChoose:init()
    print("defSoldierChoose init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.border = me.assignWidget(self,"border")
    self.Text_TroopsNum = me.assignWidget(self,"Text_TroopsNum")
    self.Text_Troopsdem = me.assignWidget(self,"Text_Troopsdem")
    self.petCheckBox = me.assignWidget(self,"petCheckBox")
    me.registGuiClickEventByName(self, "Button_Battle", function(node)
           
           if table.nums(expedLayer.selectSoldierNum )  > 0 then
                    local msg = {}
                    for key, var in pairs(expedLayer.selectSoldierNum) do
                             local i = {}
                             i.id = key
                             i.num = var
                             table.insert(msg,i)
                    end
                    NetMan:send(_MSG.guard_set(self.petCheckBox:isSelected(),msg))
                    self:close()
           else
                   showTips("没有选择任何部队")
           end

    end )

    me.registGuiClickEventByName(self, "Button_add_army", function(node)
           
           NetMan:send(_MSG.initShop(ARMY_ADD_TYPE))

    end )

    me.registGuiClickEventByName(self, "recordBtn", function(node)
           local record = defSoldierAutoFillRecord:create("defSoldierAutoFillRecord.csb")
           me.popLayer(record)
           NetMan:send(_MSG.guard_patrol_autofill_record()) 
    end )

    
    me.registGuiClickEventByName(self, "Button_Cancel", function(node)
        local function continue(str)
            if str=="ok" then
                NetMan:send(_MSG.guard_set(self.petCheckBox:isSelected(),nil))
                self:close()
            end
        end
        me.showMessageDialog("是否全部撤回?", continue)

    end )
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
    self.Text_Rec = me.assignWidget(self,"Text_Rec")
    if txts[self.cur_choose] then
        self.Text_Rec:setString(txts[self.cur_choose])
    else
        self.Text_Rec:setString(txts2[self.cur_choose])
    end
    self.Panel_Rec = me.registGuiClickEventByName(self,"Panel_Rec",function (args)
        self.Panel_Rec:setVisible(false)
    end)
    self.Panel_Rec:setSwallowTouches(false)
    for var = 1, 4 do
        me.registGuiClickEventByName(self.Panel_Rec, "item_" .. var, function(node)
            self.cur_choose = var
            self.Panel_Rec:setVisible(false)
            self.Text_Rec:setString(txts[self.cur_choose])
            self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)
            self:initList(var)
        end )
    end
    for k, v in pairs(txts2) do
        me.registGuiClickEventByName(self.Panel_Rec, "item_" .. k, function(node)
            self.cur_choose = k
            self.Panel_Rec:setVisible(false)
            self.Text_Rec:setString(txts2[self.cur_choose])
            self.Image_Rec:loadTexture("expend_state_" .. self.cur_choose .. ".png", me.localType)
            self:initList(k)
        end)
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
function defSoldierChoose:setMaxTroopsNums(nums)
    self.maxTroopsNum = nums
end
function defSoldierChoose:resetSelectSoldierNum()
    expedLayer.selectSoldierNum = nil
    expedLayer.selectSoldierNum = { }
end
function defSoldierChoose:setArmydem(snum)
    self.mcurTotalNum = snum
    local pSnum = snum
    local pMaxnum = self.maxTroopsNum
    self.Text_TroopsNum:setString(math.floor( snum ) .. "/")
    self.Text_Troopsdem:setString(pMaxnum)
    if user.Role_Buff["BingliAddPct"] then
        self.Text_Troopsdem:setTextColor(cc.c4b(111, 209, 32, 255))
    else
        self.Text_Troopsdem:setTextColor(cc.c4b(212, 197, 180, 255))
    end
    self.Text_Troopsdem:setPosition(cc.p((me.assignWidget(self, "Text_Troops_Label"):getContentSize().width + self.Text_TroopsNum:getContentSize().width), self.Text_TroopsNum:getPositionY()))
end

function defSoldierChoose:setData(data)

    if data.auto==true then
        self.petCheckBox:setSelected(true)
    else
        self.petCheckBox:setSelected(false)
    end
end

function defSoldierChoose:initList( cur  )
    self:resetSelectSoldierNum()
    self.sData = { }
    local snum = 0
    local iNum = 0
    local carry = 0
    local tempdatas = {}
    if cur == nil and  user.guardSoldier and  table.nums( user.guardSoldier ) > 0 then
        self.cur_choose = 99
    end
    if self.cur_choose == 1 then
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end                              
        end    
        for key, var in pairs(tempdatas) do
            table.insert(self.sData, var)
        end        
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().traintime < b:getDef().traintime
        end)
        -- 自动最大出兵     
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.maxTroopsNum then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
            else
                expedLayer.selectSoldierNum[var.defId] = self.maxTroopsNum - snum
                snum = self.maxTroopsNum
                break
            end
        end
    elseif self.cur_choose == 2 then
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end                              
        end    
        for key, var in pairs(tempdatas) do
            table.insert(self.sData,var)
        end        
        table.sort(self.sData, function(a, b)
            return a:getDef().speed < b:getDef().speed
        end)
        -- 自动最大出兵     
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.maxTroopsNum then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
            else
                expedLayer.selectSoldierNum[var.defId] = self.maxTroopsNum - snum
                snum = self.maxTroopsNum
                break
            end
        end
    elseif self.cur_choose == 3 then
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end                              
        end           
        for key, var in pairs(tempdatas) do
            table.insert(self.sData, var)
        end        
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().carry < b:getDef().carry
        end)
        -- 自动最大出兵     
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.maxTroopsNum then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
            else
                expedLayer.selectSoldierNum[var.defId] = self.maxTroopsNum - snum
                snum = self.maxTroopsNum
                break
            end
        end
    elseif self.cur_choose == 4 then  
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end                              
        end
        local cur_nums = 0           
        for key, var in pairs(tempdatas) do
            cur_nums = cur_nums + var.num
            table.insert(self.sData, var)
        end        
        -- 排序 让ID 大的兵种在前面
        table.sort(self.sData, function(a, b)
            return a:getDef().traintime < b:getDef().traintime
        end)
        -- 兵种数量
        local max_nums = #self.sData
        -- 自动最大出兵     
        iNum = #self.sData
        local idx = nil
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if cur_nums >= self.maxTroopsNum then
                expedLayer.selectSoldierNum[var.defId] = math.floor(var.num * self.maxTroopsNum / cur_nums)
                snum = snum + expedLayer.selectSoldierNum[var.defId]
                if expedLayer.selectSoldierNum[var.defId] + max_nums < var.num then
                    idx = i
                end
                if i == 1 and idx then
                    expedLayer.selectSoldierNum[self.sData[idx].defId] = expedLayer.selectSoldierNum[self.sData[idx].defId] + self.maxTroopsNum - snum
                    snum = self.maxTroopsNum
                end
            else
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
            end
        end
    -- 兵种优先
    elseif self.cur_choose == 11 or self.cur_choose == 21 or self.cur_choose == 31 then
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end                              
        end           
        for key, var in pairs(tempdatas) do
            table.insert(self.sData, var)
        end        
        -- 索引-兵种映射表
        local map = {[11] = 1, [21] = 2, [31] = 3}
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
        end)
        -- 自动最大出兵     
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            if snum + var.num <= self.maxTroopsNum then
                expedLayer.selectSoldierNum[var.defId] = var.num
                snum = snum + var.num
            else
                expedLayer.selectSoldierNum[var.defId] = self.maxTroopsNum - snum
                snum = self.maxTroopsNum
                break
            end
        end
    -- 清空选中
    elseif self.cur_choose == 41 then
        for key, var in pairs(user.soldierData) do      
            if var:getDef().bigType ~= 99 then            
                tempdatas[var.defId] = soldierData.new(var.defId, var.num) 
            end
        end
        for key, var in pairs(user.guardSoldier) do       
            if tempdatas[var.defId] then
                tempdatas[var.defId].num = tempdatas[var.defId].num + var.num
            else
                tempdatas[var.defId] = soldierData.new(var.defId,var.num) 
            end                              
        end           
        for key, var in pairs(tempdatas) do
            table.insert(self.sData, var)
        end        
        table.sort(self.sData, function(a, b)
            return a:getDef().fight < b:getDef().fight
        end)
        iNum = #self.sData
        for i = iNum, 1, -1 do
            local var = self.sData[i]
            expedLayer.selectSoldierNum[var.defId] = 0
        end
        snum = 0
         carry = 0
    elseif self.cur_choose == 99 then         
            for key, var in pairs(user.soldierData) do      
                if var:getDef().bigType ~= 99 then            
                    tempdatas[var.defId] =  soldierData.new(var.defId,var.num) 
                end
            end
            for key, var in pairs(user.guardSoldier) do         
                    if tempdatas[var.defId] then
                         tempdatas[var.defId].num  = tempdatas[var.defId].num + var.num
                    else
                         tempdatas[var.defId] = soldierData.new(var.defId,var.num) 
                    end
                    expedLayer.selectSoldierNum[var.defId] = var.num
            end    
            for key, var in pairs(tempdatas) do
                if var.num > 0 then
                    table.insert(self.sData,1,var)
                else
                    table.insert(self.sData,var)
                end
            end            
    end 
    iNum = #self.sData
    self:setArmydem(snum)   
    local pHeight = 384
    self.globalItems = me.createNode("Node_expedItem.csb")
    self.globalItems:retain()
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
            return 938, 122
        end
        return 1160, 122
    end
    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        local soldierdata = self.sData[idx + 1]    
        local label = nil
        local item = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            item = expedCell:create(self.globalItems, "expedItem")    
			item:setMaxTroopsNums(self.maxTroopsNum)
            item:setContentSize(cc.size(1160, 120))            
            item:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
            item:initWithData(soldierdata, self.maxTroopsNum, 0, EXPEND_STATE_GUARD)
            item:setVisitor(self)
            cell:addChild(item)
        else
            item = me.assignWidget(cell, "expedItem")
			item:setMaxTroopsNums(self.maxTroopsNum)
            item:initWithData(soldierdata, self.maxTroopsNum, 0,EXPEND_STATE_GUARD)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end
    local scr_w = 1160 
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
function defSoldierChoose:updateMaxTroops()
    self:setArmydem(getCurSelectSoldierNum())   
end
function defSoldierChoose:onEnter()
    print("defSoldierChoose onEnter")
    me.doLayout(self, me.winSize)
end
function defSoldierChoose:onEnterTransitionDidFinish()
    print("defSoldierChoose onEnterTransitionDidFinish")
end
function defSoldierChoose:onExit()
    print("defSoldierChoose onExit")
    UserModel:removeLisener(self.modelkey)
end
function defSoldierChoose:close()
    self:removeFromParent()
end

