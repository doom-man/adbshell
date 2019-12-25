-- [Comment]
-- jnmo
warshipPVPMailInfo = class("warshipPVPMailInfo", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipPVPMailInfo.__index = warshipPVPMailInfo
function warshipPVPMailInfo:create(...)
    local layer = warshipPVPMailInfo.new(...)
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
function warshipPVPMailInfo:ctor()
    print("warshipPVPMailInfo ctor")
end
local boxnum = 3 
function warshipPVPMailInfo:init()
    print("warshipPVPMailInfo init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.pCheckBox = { }
    self.mailKind = 1
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            if self.mailKind ~= sender.id then
                self.mailKind = sender.id
                self:updateInfo()
                for var = 1, boxnum do
                    if var == sender.id then
                        self.pCheckBox[var]:setSelected(true)
                        self.pCheckBox[var]:setTouchEnabled(false)
                    else
                        self.pCheckBox[var]:setSelected(false)
                        self.pCheckBox[var]:setTouchEnabled(true)
                    end
                end
            end
        end
    end
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        if self.mailKind == self.pCheckBox[var].id then
            self.pCheckBox[var]:setSelected(true)
            self.pCheckBox[var]:setTouchEnabled(false)
        else
            self.pCheckBox[var]:setSelected(false)
            self.pCheckBox[var]:setTouchEnabled(true)
        end
    end
    self.list = me.assignWidget(self, "list")
    self.Image_mid = me.assignWidget(self, "Image_mid")
    self.Image_left = me.assignWidget(self, "Image_left")
    self.Image_info = me.assignWidget(self, "Image_info")

    return true
end
function warshipPVPMailInfo:initWithData(data)
    self.data = data
    self:updateInfo()
end
local text_color_normal = "ffffff"
local text_color_name_mine = "9BF434"
local text_color_name_other = "E74120"
local text_color_skill = "F4F128"
local text_color_buff_name = "2D90D4"
local text_color_buff_val = "12f120"
function warshipPVPMailInfo:updateInfo()
    self.list:removeAllChildren()
    local items = me.assignWidget(self, "Image_ship")
    if self.mailKind == 1 then
        self.Image_mid:setVisible(true)
        self.Image_left:setVisible(true)
        self.Image_info:setVisible(false)
        self:updateList(self.data.atkRpt)
        if self.tableView then
            self.tableView:setVisible(true)
        end
        if self.tableViewInfo then
            self.tableViewInfo:setVisible(false)
        end
        for key, var in pairs(self.data.atkShips) do
            local cell = items:clone()
            local Text_ship_Name = me.assignWidget(cell, "Text_ship_Name")
            local ship_icon = me.assignWidget(cell, "ship_icon")
            local hp_bar = me.assignWidget(cell, "hp_bar")
            local def = cfg[CfgType.SHIP_DATA][var.shipId]
            Text_ship_Name:setString(def.name)
            ship_icon:loadTexture(getWarshipImageTexture(def.type), me.localType)
            me.resizeImage(ship_icon, 150, 100)
            hp_bar:setPercent(var.endure * 100 / var.maxEndure)
            self.list:pushBackCustomItem(cell)
        end
    elseif self.mailKind == 2 then
        self.Image_mid:setVisible(true)
        self.Image_left:setVisible(true)
        self.Image_info:setVisible(false)
        self:updateList(self.data.defRpt)
        if self.tableView then
            self.tableView:setVisible(true)
        end
        if self.tableViewInfo then
            self.tableViewInfo:setVisible(false)
        end
        for key, var in pairs(self.data.defShips) do
            local cell = items:clone()
            local Text_ship_Name = me.assignWidget(cell, "Text_ship_Name")
            local ship_icon = me.assignWidget(cell, "ship_icon")
            local hp_bar = me.assignWidget(cell, "hp_bar")
            local def = cfg[CfgType.SHIP_DATA][var.shipId]
            Text_ship_Name:setString(def.name)
            ship_icon:loadTexture(getWarshipImageTexture(def.type), me.localType)
            me.resizeImage(ship_icon, 150, 100)
            hp_bar:setPercent(var.endure * 100 / var.maxEndure)
            self.list:pushBackCustomItem(cell)
        end
    elseif self.mailKind == 3 then
        self.Image_mid:setVisible(false)
        self.Image_left:setVisible(false)
        self.Image_info:setVisible(true)
        self.battleDetails = { }
        -- = self.data.battleDetails
        for key, var in pairs(self.data.battleDetails) do
            local str = self:parStr(var)
            table.insert(self.battleDetails, str)
        end
        --        if self.tableViewInfo then
        --            self.tableViewInfo:setVisible(true)
        --        end
        if self.tableView then
            self.tableView:setVisible(false)
        end
        self:updateInfoList1()
    end
end
function warshipPVPMailInfo:updateInfoList1()
    if self.infolist == nil then
        self.infolist = me.assignWidget(self, "listinfo")
        for key, var in pairs(self.battleDetails) do
            local rt = mRichText:create(var, 1160, "", 3)
            self.infolist:pushBackCustomItem(rt)
        end
    end
end
function warshipPVPMailInfo:parStr(data)
    if data.tag then
        if data.tag == "btlStart" then
            return self:constr("战斗开始", text_color_normal)
        elseif data.tag == "round" then
            return self:constr("第" .. data.round .. "回合", text_color_normal)
        elseif data.tag == "startAction" then
            return self:conPreNormalAtt(data.ship, data.isSelf)
        elseif data.tag == "normalAtk" then
            return self:conNormalAtt(data)
        elseif data.tag == "skillMove" then
            return self:conSkill(data)
        elseif data.tag == "buffEnd" then      
            return  self:conNameStr(data.initiator, data.isSelf) .. self:conBuffstr(data,true)
        elseif data.tag == "shipBattleEnd" then
            return self:constr("战斗结束", text_color_normal)
        elseif data.tag == "shipDead" then
            return  self:conNameStr(data.shipId, data.isSelf) ..self:constr("被击毁了。", text_color_normal)
        end
    else
    end
end
function warshipPVPMailInfo:conSkill(data)
    local str = self:conNameStr(data.initiator, data.isSelf) .. self:conSkillStr(data.skillId) .. self:conLine()
    if data.damageTake then
        str = str .. self:conSpace(1) .. self:conNameStr(data.target,  data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">损失" .. data.damageTake .. "生命(剩余" ..data.targetHp..")&" .. self:conLine()
    end
    if data.ammoTake then
        str = str .. self:conSpace(1) .. self:conNameStr(data.target,  data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">损失" .. data.ammoTake .. "弹药(剩余" ..data.targetEndure..")&" .. self:conLine()
    end
    if data.ammoConsume then
        str = str .. self:conSpace(1) .. self:conNameStr(data.initiator, data.isSelf) .. "<txt0012," .. text_color_normal .. ">消耗" .. data.ammoConsume .. "弹药(剩余" ..data.initiatorEndure..")&" .. self:conLine()
    end
    if data.hpRecover then
        str = str .. self:conSpace(1) .. self:conNameStr(data.target, data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">回复" .. data.hpRecover .. "生命(剩余" ..data.targetHp..")&" .. self:conLine()
    end
    if data.ammoRecover then
        str = str .. self:conSpace(1) .. self:conNameStr(data.target, data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">回复" .. data.ammoRecover .. "弹药(剩余" ..data.targetEndure..")&" .. self:conLine()
    end
    str = str .. self:conBuffs(data.buffs, false)
    return str
end
function warshipPVPMailInfo:conSpace(kind)
    if kind == 1 then
        return "<txt0012," .. text_color_name_mine .. ">        &"
    elseif kind == 2 then
        return "<txt0012," .. text_color_name_mine .. ">        &"
    end
end
function warshipPVPMailInfo:conLine()
    return "<txt0012," .. text_color_name_mine .. ">#n&"
end
function warshipPVPMailInfo:conBuffs(buffs, bdis)
    local str = ""
    for key, var in pairs(buffs) do
        str = str.. self:conSpace(1) .. self:conNameStr(var.target, var.isSelf) .. self:conBuffstr(var,bdis) .. self:conLine()
    end
    return str
end
function warshipPVPMailInfo:conPreNormalAtt(id, isSelf)
    if isSelf then
        return "<txt0012," .. text_color_name_mine .. ">" .. cfg[CfgType.SHIP_DATA][tonumber(id)].name .. "&<txt0012," .. text_color_normal .. ">准备发动普通攻击&"
    else
        return "<txt0012," .. text_color_name_other .. ">" .. cfg[CfgType.SHIP_DATA][tonumber(id)].name .. "&<txt0012," .. text_color_normal .. ">准备发动普通攻击&"
    end
end
function warshipPVPMailInfo:conNormalAtt(data)
    local str = self:conNameStr(data.initiator, data.isSelf) .. "<txt0012," .. text_color_normal .. ">发动普通攻击&" .. self:conLine() ..
    self:conSpace(1) .. self:conNameStr(data.target,  data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">损失" .. data.damageTake .. "生命(剩余" ..data.targetHp..")&" .. self:conLine() ..
    self:conSpace(1) .. self:conNameStr(data.target,  data.targetIsSelf) .. "<txt0012," .. text_color_normal .. ">损失" .. data.ammoTake .. "弹药(剩余" ..data.targetEndure..")&" .. self:conLine() ..
    self:conSpace(1) .. self:conNameStr(data.initiator, data.isSelf) .. "<txt0012," .. text_color_normal .. ">消耗" .. data.ammoConsume .. "弹药(剩余" ..data.initiatorEndure..")&" .. self:conLine()
    return str
end
function warshipPVPMailInfo:constr(str, c)
    return "<txt0012," .. c .. ">" .. str .. "&"
end
-- buffid 值  是否是消失
function warshipPVPMailInfo:conBuffstr(data, bdis)
    if bdis then
        return "<txt0012," .. text_color_buff_name .. ">" .. cfg[CfgType.BUFF_NAME][data.buffType].desc .. "&<txt0012," .. text_color_buff_val .. ">" .. data.buffValue .. "%&<txt0012," .. text_color_normal .. ">效果消失了&"
    else
        if data.round == 10000 then
            return "<txt0012," .. text_color_buff_name .. ">" .. cfg[CfgType.BUFF_NAME][data.buffType].desc .. "&<txt0012," .. text_color_buff_val .. ">" .. data.buffValue .. "%,持续整场&"
        else 
            return "<txt0012," .. text_color_buff_name .. ">" .. cfg[CfgType.BUFF_NAME][data.buffType].desc .. "&<txt0012," .. text_color_buff_val .. ">" .. data.buffValue .. "%,持续"..data.round.. "回合&"
        end
    end
end
function warshipPVPMailInfo:conNameStr(id, isSelf)
    if isSelf then
        return "<txt0012," .. text_color_name_mine .. ">" .. cfg[CfgType.SHIP_DATA][tonumber(id)].name .. "&"
    else
        return "<txt0012," .. text_color_name_other .. ">" .. cfg[CfgType.SHIP_DATA][tonumber(id)].name .. "&"
    end
end
function warshipPVPMailInfo:conSkillStr(sid)
    return "<txt0012," .. text_color_normal .. ">触发&<txt0012," .. text_color_skill .. ">" .. cfg[CfgType.SHIP_REFIX_SKILL][tonumber(sid)].name .. "&<txt0012," .. text_color_normal .. ">效果&"
end
function warshipPVPMailInfo:updateInfoList()
    local cells = me.assignWidget(self, "Image_Info_cell")
    print(#self.battleDetails)
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        --    table:onTouchBegan()

    end

    local function cellSizeForTable(table, idx)
        return 1170, 60
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local def = self.battleDetails[idx + 1]
        dump(def)
        if nil == cell then
            cell = cc.TableViewCell:new()
            local cellsClone = cells:clone()
            local Text_desc = me.assignWidget(cellsClone, "Text_desc")
            local Image_bg = me.assignWidget(cellsClone, "Image_bg")
            cellsClone:setTag(0xff1111)
            Image_bg:setVisible(idx % 2 == 0)
            Text_desc:setString(def)
            cellsClone:setPosition(585, 30)
            cell:addChild(cellsClone)
        else
            local cellsClone = cell:getChildByTag(0xff1111)
            local Image_bg = me.assignWidget(cellsClone, "Image_bg")
            local Text_desc = me.assignWidget(cellsClone, "Text_desc")
            Text_desc:setString(def)
            Image_bg:setVisible(idx % 2 == 0)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.battleDetails
    end
    if self.tableViewInfo == nil then
        self.tableViewInfo = cc.TableView:create(cc.size(1170, 440))
        self.tableViewInfo:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableViewInfo:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableViewInfo:setPosition(5, 5)
        --  tableView:setAnchorPoint(cc.p(0,0))
        self.tableViewInfo:setDelegate()
        self.Image_info:addChild(self.tableViewInfo)
        -- registerScriptHandler functions must be before the reloadData funtion
        self.tableViewInfo:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableViewInfo:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableViewInfo:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableViewInfo:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableViewInfo:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableViewInfo:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableViewInfo:reloadData()
end
function warshipPVPMailInfo:updateList(data)
    self.listdata = data
    local cells = me.assignWidget(self, "Image_Cell")
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        --    table:onTouchBegan()

    end

    local function cellSizeForTable(table, idx)
        return 906, 60
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local def = self.listdata[idx + 1]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local cellsClone = cells:clone()
            local Text_turns = me.assignWidget(cellsClone, "Text_turns")
            local bullet1 = me.assignWidget(cellsClone, "bullet1")
            local Image_bg = me.assignWidget(cellsClone, "Image_bg")
            local attnum = me.assignWidget(cellsClone, "attnum")
            local skillnum = me.assignWidget(cellsClone, "skillnum")
            local skilltimes = me.assignWidget(cellsClone, "skilltimes")
            local bullet2 = me.assignWidget(cellsClone, "bullet2")
            Text_turns:setString(def.round + 1)
            attnum:setString(math.floor(def.normalDamage))
            skillnum:setString(math.floor(def.skillDamage))
            skilltimes:setString(def.useSkillTimes)
            bullet2:setString(math.floor(def.ammoConsume))
            bullet1:setString(math.floor(def.ammoRecover))
            Image_bg:setVisible(idx % 2 == 0)
            cell:addChild(cellsClone)
            cellsClone:setPosition(453, 30)
            cellsClone:setTag(0xff1111)
        else
            local cellsClone = cell:getChildByTag(0xff1111)
            local Text_turns = me.assignWidget(cellsClone, "Text_turns")
            local bullet1 = me.assignWidget(cellsClone, "bullet1")
            local Image_bg = me.assignWidget(cellsClone, "Image_bg")
            local attnum = me.assignWidget(cellsClone, "attnum")
            local skillnum = me.assignWidget(cellsClone, "skillnum")
            local skilltimes = me.assignWidget(cellsClone, "skilltimes")
            local bullet2 = me.assignWidget(cellsClone, "bullet2")
            Text_turns:setString(def.round + 1)
            attnum:setString(math.floor(def.normalDamage))
            skillnum:setString(math.floor(def.skillDamage))
            skilltimes:setString(def.useSkillTimes)
            bullet2:setString(math.floor(def.ammoConsume))
            bullet1:setString(math.floor(def.ammoRecover))
            Image_bg:setVisible(idx % 2 == 0)
            cell:addChild(cellsClone)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.listdata
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(915, 400))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(24, 5)
        --  tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        self.Image_mid:addChild(self.tableView)
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
function warshipPVPMailInfo:onEnter()
    print("warshipPVPMailInfo onEnter")
    me.doLayout(self, me.winSize)
end
function warshipPVPMailInfo:onEnterTransitionDidFinish()
    print("warshipPVPMailInfo onEnterTransitionDidFinish")
end
function warshipPVPMailInfo:onExit()
    print("warshipPVPMailInfo onExit")
end
function warshipPVPMailInfo:close()
    self:removeFromParent()
end
