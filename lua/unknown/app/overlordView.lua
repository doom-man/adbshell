overlordView = class("overlordView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

overlordView._index = overlordView

overlordView.TypeName = {
    Type_1 = TID_OVERLORD_1,
    Type_2 = TID_OVERLORD_2,
    Type_3 = TID_OVERLORD_3,
    Type_4 = TID_OVERLORD_4,
    Type_5 = TID_OVERLORD_5,
}

overlordView.Time = {
    TIME_0 = { icon = "lingzhu_icon_1.png", name = TID_LORDTIME_1, sicon = "icon_mapopt_9_1.png" },
    TIME_1 = { icon = "lingzhu_icon_2.png", name = TID_LORDTIME_2, sicon = "icon_mapopt_9_2.png" },
    TIME_2 = { icon = "lingzhu_icon_3.png", name = TID_LORDTIME_3, sicon = "icon_mapopt_9_3.png" },
    TIME_3 = { icon = "lingzhu_icon_4.png", name = TID_LORDTIME_4, sicon = "icon_mapopt_9_4.png" },
}

-- 左侧页签
local LeftTabType = {
    EQUIP = 1,  -- 装备
    HERO = 2,   -- 副将
}

-- 右侧页签
local RightTabType = {
    SUMMARY = 1,    -- 概览
    DETAIL = 2,     -- 明细
}

function overlordView:create(csb)
    local layer = overlordView.new(csb)
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

function overlordView:ctor()
    self.propertyData = nil
end
function overlordView:close()
    self:removeFromParentAndCleanup(true)
end
function overlordView:init()
    print("overlordView init")
    self.bg = me.assignWidget(self, "bg")
    self.text_user_name = me.assignWidget(self, "text_user_name")
    self.text_times = me.assignWidget(self, "text_times")
    self.probar_exp = me.assignWidget(self, "probar_exp")
    self.text_fap = me.assignWidget(self, "text_fap")
    self.text_pro_exp = me.assignWidget(self, "text_pro_exp")
    self.Text_CoquerNum = me.assignWidget(self, "Text_CoquerNum")
    self.Image_food = me.assignWidget(self, "Image_food")
    self.Image_stone = me.assignWidget(self, "Image_stone")
    self.Image_wood = me.assignWidget(self, "Image_wood")
    self.Text_strengthNum = me.assignWidget(self, "Text_strengthNum")
    self.text_user_title = me.assignWidget(self, "text_user_title")
    self.probar_vit = me.assignWidget(self, "probar_vit")
    self.text_pro_vit = me.assignWidget(self, "text_pro_vit")
    -- table父节点
    self.panel_table = me.assignWidget(self, "panel_table")
    -- 模板
    self.img_item = me.assignWidget(self, "img_item")
    self.img_item:setVisible(false)

    -- 更换相关
    self.panel_change = me.assignWidget(self, "panel_change")
    self.panel_change:setVisible(false)
    me.registGuiClickEvent(self.panel_change, function(sender)
        sender:setVisible(false)
    end)
    -- 更换形象
    me.registGuiClickEventByName(self.panel_change, "btn_changeImage", function(node)
        self.panel_change:setVisible(false)
        local view = LordImageChangeView:create("LordImageChangeView.csb")
        self:addChild(view, me.MAXZORDER)
        me.showLayer(view, "img_bg")
    end)
    -- 更换头像
    me.registGuiClickEventByName(self.panel_change, "btn_changeHeader", function(node)
        self.panel_change:setVisible(false)
        local view = HeaderChangeView:create("HeaderChangeView.csb")
        self:addChild(view, me.MAXZORDER)
        me.showLayer(view, "img_bg")
    end)
    -- 更换名字
    me.registGuiClickEventByName(self.panel_change, "btn_changeName", function(node)
        self.panel_change:setVisible(false)
        local view = lordChangeName:create("lordChangeName.csb")
        self:addChild(view, me.MAXZORDER)
        me.showLayer(view, "bg")
    end)
    -- 形象
    local cfg_image = cfg[CfgType.ROLE_IMAGE]
    self.img_lord_image = me.assignWidget(self, "img_lord_image")
    self.img_lord_image:ignoreContentAdaptWithSize(true)
    self.img_lord_image:loadTexture(cfg_image[user.image].icon..".png", me.localType)
    -- 头像
    local cfg_head = cfg[CfgType.ROLE_HEAD]
    self.img_header = me.assignWidget(self, "img_header")
    self.img_header:ignoreContentAdaptWithSize(true)
    self.img_header:loadTexture(cfg_head[user.head].icon..".png", me.localType)

    me.registGuiClickEventByName(self, "Button_setting", function(node)
        local setting = settingView:create("settingView.csb")
        self:addChild(setting, me.MAXZORDER)
        me.showLayer(setting, "bg")
    end )
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_Cell_Tips", function(node)
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        local wd = node:convertToWorldSpace(cc.p(-10, 45))
        stips:initWithStr("可通过提升角色等级、研究禁卫军科技、解锁[开拓者]称号增加领地上限", wd)
        me.popLayer(stips)
    end)    
    me.registGuiClickEventByName(self, "btn_rename", function(node)
        self.panel_change:setVisible(true)
    end )
    me.registGuiClickEventByName(self, "Button_land", function(node)
        GMan():send(_MSG.roleLandInfo())
    end )
    me.registGuiClickEventByName(self, "Button_Look", function(node)
        local rtl = roleTitleLayer:create("roleTitleVIew.csb")
        me.popLayer(rtl, "bg_frame")
        NetMan:send(_MSG.roleTitleList())
    end )
    me.registGuiClickEventByName(self, "noticeBtn", function(node)
         checkHaveNotice(true)
    end ) 

    -- 选中框
    self.img_select = me.assignWidget(self, "img_select")
    -- 装备
    self.node_equip = me.assignWidget(self, "node_equip")
    self.btn_equip = me.assignWidget(self, "btn_equip")
    self.btn_equip.tag = LeftTabType.EQUIP
    -- 副将
    self.node_hero = me.assignWidget(self, "node_hero")
    self.btn_hero = me.assignWidget(self, "btn_hero")
    self.btn_hero.tag = LeftTabType.HERO
    for i, btn in ipairs({self.btn_equip, self.btn_hero}) do
        me.registGuiClickEvent(btn, function(sender)
            self:selectLeftTab(sender.tag)
        end)
    end
    -- 小红点
    self:refreshRedDot()
    -- 默认选中装备
    self:selectLeftTab(LeftTabType.EQUIP)

    -- 刷新装备节点
    self:refreshEquipNode()
    -- 刷新副将节点
    self:refreshHeroNode()

    -- 概览
    self.node_summary = me.assignWidget(self, "node_summary")
    self.btn_summary = me.assignWidget(self, "btn_summary")
    self.btn_summary.tag = RightTabType.SUMMARY
    -- 详细属性
    self.node_detail = me.assignWidget(self, "node_detail")
    self.btn_detail = me.assignWidget(self, "btn_detail")
    self.btn_detail.tag = RightTabType.DETAIL
    for i, btn in ipairs({self.btn_summary, self.btn_detail}) do
        me.registGuiClickEvent(btn, function(sender)
            self:selectRightTab(sender.tag)
        end)
    end
    -- 默认选中概览
    self:selectRightTab(RightTabType.SUMMARY)

    return true
end

-- 刷新装备节点
function overlordView:refreshEquipNode()
    -- 位置序号与配置id映射表
    local tempMap = {
        [1] = 6,      -- 头盔
        [2] = 7,      -- 衣服
        [3] = 8,      -- 盾牌
        [4] = 5,      -- 武器
        [5] = 9,      -- 戒指
    }
    local equipList = {}
    -- 找出已穿戴的装备
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 6 or tonumber(cfg_item.useType) == 7 or tonumber(cfg_item.useType) == 8
            or tonumber(cfg_item.useType) == 5 or tonumber(cfg_item.useType) == 9 then
            equipList[tonumber(cfg_item.useType)] = clone(v)
        end
    end
    for i, v in ipairs(tempMap) do
        local node = me.assignWidget(self.node_equip, "img_"..i)
        local img_quality = me.assignWidget(node, "img_quality")
        local img_icon = me.assignWidget(node, "img_icon")
        local img_add = me.assignWidget(node, "img_add")
        img_add:stopAllActions()
        local img_red_dot = me.assignWidget(node, "img_red_dot")
        img_red_dot:setVisible(false)
        local info = equipList[v]
        if not info then
            img_quality:setVisible(false)
            img_add:setVisible(true)
            img_add:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(1.0, 1.2),
                cc.ScaleTo:create(1.0, 1.0)
            )))
            me.registGuiClickEvent(node, function()
                local view = EquipSelectView:create("world/EquipSelectView.csb")
                self:addChild(view)
                me.showLayer(view, "img_bg")
                view:setData({
                    slotType = v,
                    slotItemInfo = info,
                    posId = i,
                })
            end)
            -- 红点
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    img_red_dot:setVisible(true)
                    break
                end
            end
        else
            local cfg_item = cfg[CfgType.ETC][info.defid]
            img_quality:setVisible(true)
            img_quality:loadTexture(getArchQuility(cfg_item.id), me.localType)
            img_icon:setVisible(true)
            img_icon:loadTexture(getItemIcon(cfg_item.id), me.plistType)
            img_add:setVisible(false)
            me.registGuiClickEvent(node, function()
                local view = EquipSelectView:create("world/EquipSelectView.csb")
                self:addChild(view)
                me.showLayer(view, "img_bg")
                view:setData({
                    slotType = v,
                    slotItemInfo = info,
                    posId = i,
                })
            end)
        end
    end
end

-- 刷新副将节点
function overlordView:refreshHeroNode()
    -- 位置序号与配置id映射表
    local tempMap = {
        [1] = 10,      -- 英雄
        [2] = 10,      -- 英雄
        [3] = 10,      -- 英雄
        [4] = 10,      -- 英雄
        [5] = 10,      -- 英雄
    }
    local heroList = {}
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 10 and v.equipLoc > 0 then
            heroList[v.equipLoc] = clone(v)
        end
    end
    for i, v in ipairs(tempMap) do
        local node = me.assignWidget(self.node_hero, "img_"..i)
        local img_quality = me.assignWidget(node, "img_quality")
        local img_icon = me.assignWidget(node, "img_icon")
        local panel_star = me.assignWidget(node, "panel_star")
        local img_add = me.assignWidget(node, "img_add")
        img_add:stopAllActions()
        local img_red_dot = me.assignWidget(node, "img_red_dot")
        img_red_dot:setVisible(false)
        local info = heroList[i]
        if not info then
            img_quality:setVisible(false)
            img_add:setVisible(true)
            img_add:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.ScaleTo:create(1.0, 1.2),
                cc.ScaleTo:create(1.0, 1.0)
            )))
            me.registGuiClickEvent(node, function()
                local view = EquipSelectView:create("world/EquipSelectView.csb")
                self:addChild(view)
                me.showLayer(view, "img_bg")
                view:setData({
                    slotType = v,
                    slotItemInfo = info,
                    posId = i,
                })
            end)
            -- 红点
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    img_red_dot:setVisible(true)
                    break
                end
            end
        else
            local cfg_item = cfg[CfgType.ETC][info.defid]
            img_quality:setVisible(true)
            img_quality:loadTexture(getArchQuility(cfg_item.id), me.localType)
            img_icon:setVisible(true)
            img_icon:loadTexture(getItemIcon(cfg_item.id), me.plistType)
            img_add:setVisible(false)
            me.registGuiClickEvent(node, function()
                local view = EquipSelectView:create("world/EquipSelectView.csb")
                self:addChild(view)
                me.showLayer(view, "img_bg")
                view:setData({
                    slotType = v,
                    slotItemInfo = info,
                    posId = i,
                })
            end)
            -- 星级
            local starLv = info.level
            panel_star:removeAllChildren()
            local starWidth = 18
            local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
            for i = 1, starLv do
                local img_star = ccui.ImageView:create()
                img_star:loadTexture("yaosai_15.png", me.localType)
                local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
                local y = 12
                img_star:setPosition(cc.p(x, y))
                img_star:setScale(1.0)
                panel_star:addChild(img_star)
            end
        end
    end
end

-- 选中左侧页签
function overlordView:selectLeftTab(tag)
    self.selLeftTab = tag
    for i, btn in ipairs({self.btn_equip, self.btn_hero}) do
        if btn.tag == self.selLeftTab then
            btn:setEnabled(false)
            self.img_select:setPositionY(btn:getPositionY() - 3)
            self.node_equip:setVisible(LeftTabType.EQUIP == self.selLeftTab)
            self.node_hero:setVisible(LeftTabType.HERO == self.selLeftTab)
        else
            btn:setEnabled(true)
        end
    end
end

-- 选中右侧页签
function overlordView:selectRightTab(tag)
    self.selRightTab = tag
    for i, btn in ipairs({self.btn_summary, self.btn_detail}) do
        local text_title_btn = me.assignWidget(btn, "text_title_btn")
        if btn.tag == self.selRightTab then
            btn:setEnabled(false)
            text_title_btn:setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
            text_title_btn:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
            self.node_summary:setVisible(RightTabType.SUMMARY == self.selRightTab)
            self.node_detail:setVisible(RightTabType.DETAIL == self.selRightTab)
        else
            btn:setEnabled(true)
            text_title_btn:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
            text_title_btn:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
        end
    end
end

function overlordView:onEnter()
    print("overlordView:onEnter()")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:update(msg)
    end )
    NetMan:send(_MSG.msg_statistics())
end

function overlordView:onExit()
    print("overlordView:onExit()")
    UserModel:removeLisener(self.modelkey)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)
        self.schid = nil
    end
    if self.recoverTimer then
        me.clearTimer(self.recoverTimer)
        self.recoverTimer = nil
    end
end

-- 穿戴考古道具频繁刷新，效率低，改用tableview
--[[
function overlordView:setCellsView()
    self.listView:removeAllItems()
    local index = 1
    for key, var in pairs(self.viewData) do
        -- 添加标题
        local bItem = self.img_item:clone()
        bItem:setVisible(true)
        local panel_title = me.assignWidget(bItem, "panel_title")
        panel_title:setVisible(true)
        local panel_bg = me.assignWidget(bItem, "panel_bg")
        panel_bg:setVisible(false)
        me.assignWidget(bItem, "Text_title"):setString(overlordView.TypeName["Type_" .. key]):setVisible(true)
        self.listView:pushBackCustomItem(bItem)
       
        -- 添加内容条
        for inKey, inVar in pairs(var) do
            if me.toNum(inVar.show) == 1 then
                local tmpValue = 0
                local tmpValue_Server = nil
                if user.propertyValue[inVar.key] then
                    tmpValue = user.propertyValue[inVar.key] - (user.propertyValue_temp[inVar.key] or 0)
                    tmpValue_Server = (user.propertyValue_Server[inVar.key] or 0) + (user.propertyValue_temp[inVar.key] or 0)
                else
                    tmpValue = self.statisticsMsg[inVar.key]
                    tmpValue_Server = 0
                end
                local cItem = self.img_item:clone()
                cItem:setVisible(true)
                local panel_title = me.assignWidget(cItem, "panel_title")
                panel_title:setVisible(false)
                local panel_bg = me.assignWidget(cItem, "panel_bg")
                panel_bg:setVisible(index % 2 == 0)
                me.assignWidget(cItem, "Text_itemName"):setString(inVar.name):setVisible(true)
                me.assignWidget(cItem, "Text_itemNum_server"):setVisible(tmpValue_Server > 0)
                me.assignWidget(cItem, "Text_itemNum"):setVisible(true)
                if me.toNum(inVar.isPercent) == 1 then
                    tmpValue = tmpValue * 100
                    me.assignWidget(cItem, "Text_itemNum"):setString(tmpValue .. "%")
                    if tmpValue_Server > 0 then
                        tmpValue_Server = tmpValue_Server * 100
                        me.assignWidget(cItem, "Text_itemNum_server"):setString("+ " .. tmpValue_Server .. "%")
                    end
                else
                    me.assignWidget(cItem, "Text_itemNum"):setString(tmpValue)
                    if tmpValue_Server ~= nil then
                        me.assignWidget(cItem, "Text_itemNum_server"):setString("+ " .. tmpValue_Server)
                    end
                    if self:isSpecialPer(inVar.key) then
                        me.assignWidget(cItem, "Text_itemNum"):setString(tmpValue)
                    end
                end
                index = index + 1
                self.listView:pushBackCustomItem(cItem)
            end
        end
    end
end
--]]

-- 刷新table
function overlordView:refreshTableView()
    local function numberOfCellsInTableView(tableview)
        return #self.viewData
    end
    local function cellSizeForTable(tableview, idx)
        return 479, 42
    end
    local function tableCellAtIndex(tableview, idx)
        local cell = tableview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            local img_item = self.img_item:clone()
            img_item:setVisible(true)
            img_item:setAnchorPoint(cc.p(0, 0))
            img_item:setPosition(cc.p(0, 0))
            cell:addChild(img_item)
            cell.node = img_item
        end
        -- 刷新
        self:refreshCellItem(cell.node, idx)

        return cell
    end
    self.panel_table:removeAllChildren()
    local tableView = cc.TableView:create(self.panel_table:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.panel_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView = tableView
end

-- 刷新单个属性
--[[
    node        -- 节点
    idx         -- 序号，从0起
--]]
function overlordView:refreshCellItem(node, idx)
    local info = self.viewData[idx + 1]
    if info.isHeader then
        me.assignWidget(node, "panel_bg"):setVisible(false)
        me.assignWidget(node, "panel_title"):setVisible(true)
        me.assignWidget(node, "Text_title"):setString(overlordView.TypeName["Type_" .. info.groupId])
        --
        me.assignWidget(node, "Text_itemName"):setVisible(false)
        me.assignWidget(node, "Text_itemNum_server"):setVisible(false)
        me.assignWidget(node, "Text_itemNum"):setVisible(false)
    else
        me.assignWidget(node, "panel_title"):setVisible(false)
        me.assignWidget(node, "panel_bg"):setVisible(info.innerId % 2 == 0)
        --
        local tmpValue = 0
        local tmpValue_Server = nil
        if user.propertyValue[info.key] then
            tmpValue = user.propertyValue[info.key] - (user.propertyValue_temp[info.key] or 0)
            tmpValue_Server = (user.propertyValue_Server[info.key] or 0) + (user.propertyValue_temp[info.key] or 0)
        else
            tmpValue = self.statisticsMsg[info.key]
            tmpValue_Server = 0
        end
        me.assignWidget(node, "Text_itemName"):setString(info.name):setVisible(true)
        me.assignWidget(node, "Text_itemNum_server"):setVisible(tmpValue_Server > 0)
        me.assignWidget(node, "Text_itemNum"):setVisible(true)
        if me.toNum(info.isPercent) == 1 then
            tmpValue = tmpValue * 100
            me.assignWidget(node, "Text_itemNum"):setString(tmpValue .. "%")
            if tmpValue_Server > 0 then
                tmpValue_Server = tmpValue_Server * 100
                me.assignWidget(node, "Text_itemNum_server"):setString("+ " .. tmpValue_Server .. "%")
            end
        else
            me.assignWidget(node, "Text_itemNum"):setString(tmpValue)
            if tmpValue_Server ~= nil then
                me.assignWidget(node, "Text_itemNum_server"):setString("+ " .. tmpValue_Server)
            end
            if self:isSpecialPer(info.key) then
                me.assignWidget(node, "Text_itemNum"):setString(tmpValue)
            end
        end
    end
end

function overlordView:isSpecialPer(key_)
    if key_ == "OutType3Value" or key_ == "OutType2Value" or key_ == "OutType1Value" then
        return true
    end
    return false
end
function getNextExp(curLv)
        local nextExp = cfg[CfgType.LEVEL][curLv].exp
        for key, var in pairs(cfg[CfgType.LEVEL]) do
            if me.toNum(key) == me.toNum(curLv + 1) then
                nextExp = cfg[CfgType.LEVEL][curLv + 1].exp
                return nextExp
            end
        end 
        return nextExp
    end
function overlordView:initView()
    
    self.text_user_name:setString(getLvStrByPlatform() .. "." .. user.lv .. " " .. user.name)
    self.probar_exp:setPercent(user.exp / getNextExp(user.lv) * 100)
    -- 战斗力
    self.text_fap:setString(user.grade)
    self.text_pro_exp:setString(user.exp .. "/" .. getNextExp(user.lv))
    local curTime = overlordView.Time["TIME_" .. getCenterBuildingTime()]
    self.text_times:setString(curTime.name)
    self.Text_CoquerNum:setString(user.lansize .. "/" .. user.propertyValue["LandNumAdd"])
    if user.Cross_Sever_Status == mCross_Sever then
        self.Text_CoquerNum:setString(user.lansize .. "/" .. user.Maxlansize)
    else
        self.Text_CoquerNum:setString(user.lansize .. "/" .. user.propertyValue["LandNumAdd"])
    end

    self.probar_vit:setPercent(user.currentPower * 100 / getUserMaxPower())
    self.text_pro_vit:setString(user.currentPower .. "/" .. getUserMaxPower())

    self.Text_strengthNum:setString(user.currentPower .. "/" .. getUserMaxPower())
    if user.title == 0 then
        self.text_user_title:setString("无")
    else
        self.text_user_title:setString(cfg[CfgType.ROLE_TITLE][tonumber(user.title)].name)
    end
    me.assignWidget(self.Image_food, "Text_FoodPer"):setString(user.foodPer .. "/小时")
    me.assignWidget(self.Image_stone, "Text_StonePer"):setString(user.stonePer .. "/小时")
    me.assignWidget(self.Image_wood, "Text_WoodPer"):setString(user.woodPer .. "/小时")

    -- 数据处理
    self.viewData = {}
    local groupList = {}
    for k, v in pairs(cfg[CfgType.LORD_INFO]) do
        local groupId = tonumber(v.typeId)
        groupList[groupId] = groupList[groupId] or {}
        if tonumber(v.show) == 1 then
            table.insert(groupList[groupId], clone(v))
        end
    end
    for groupId, group in pairs(groupList) do
        table.sort(group, function(a, b)
            return tonumber(a.id) < tonumber(b.id)
        end )
    end
    local groupIdList = table.keys(groupList)
    table.sort(groupIdList, function(a, b)
        return a < b
    end)
    for _, groupId in ipairs(groupIdList) do
        table.insert(self.viewData, {groupId = groupId, isHeader = true})
        for i, v in ipairs(groupList[groupId]) do
            v.innerId = i
            table.insert(self.viewData, v)
        end
    end
    -- 刷新属性列表
    self:refreshTableView()
    self:setRecoverTimer()
end

function overlordView:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_MAP_LAND_INFO) then
        local landInfo = landInfoView:create("landInfoView.csb")
        landInfo:initWithData(msg.c.list)
        landInfo:setParent(self)
        self:addChild(landInfo)
        me.showLayer(landInfo, "bg_frame")
    elseif checkMsg(msg.t, MsgCode.UPDATE_ROLE_TITLE) then
        if user.title == 0 then
            self.text_user_title:setString("无")
        else
            self.text_user_title:setString(cfg[CfgType.ROLE_TITLE][tonumber(user.title)].name)
        end
    elseif checkMsg(msg.t, MsgCode.MSG_STATISTICS) then
        self.statisticsMsg = msg.c
        self:initView()
    elseif checkMsg(msg.t, MsgCode.CHANGE_LORD_IMAGE) then
        local cfg_image = cfg[CfgType.ROLE_IMAGE]
        self.img_lord_image:loadTexture(cfg_image[user.image].icon..".png", me.localType)
    elseif checkMsg(msg.t, MsgCode.CHANGE_HEAD) then
        local cfg_head = cfg[CfgType.ROLE_HEAD]
        self.img_header:loadTexture(cfg_head[user.head].icon..".png", me.localType)
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_CHANGE) then
        if msg.c.processValue == 53 then
            if msg.c.iteminfo.locValue == 2 then
                showTips("装备成功")
            else
                --showTips("卸下成功")
            end
            -- 配置信息
            local cfg_item = cfg[CfgType.ETC][msg.c.iteminfo.defId]
            local useType = tonumber(cfg_item.useType)
            if useType == 10 then
                -- 刷新副将节点
                self:refreshHeroNode()
            else
                -- 刷新装备节点
                self:refreshEquipNode()
            end
            -- 小红点
            self:refreshRedDot()
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_PROPERTY_UPDATE) then
        local offest = self.tableView:getContentOffset()
        self.tableView:reloadData()
        self.tableView:setContentOffset(offest)
    elseif checkMsg(msg.t, MsgCode.ROLE_FIGHT_UPDATE) then
        self:updateFightPower(msg)
    end
end

function overlordView:setRecoverTimer()
    self.recoverTime = me.assignWidget(self, "recoverTime"):setString("--:--")
    if user.recover.restTime and user.recover.recvTime and user.recover.restTime > 0 then
        local restTime = user.recover.restTime -(os.time() - user.recover.recvTime)
        if restTime > 0 then
            self.recoverTime:setString(os.date("%M:%S", restTime))
            self.recoverTimer = me.registTimer(-1, function(dt)
                restTime = restTime - dt
                self.recoverTime:setString(os.date("%M:%S", restTime))
                if restTime <= 0 then
                    me.clearTimer(self.recoverTimer)
                    self.recoverTimer = nil
                end
            end , 1)
        end
    end
end

function overlordView:updateFightPower(msg)
    -- 战斗力
    self.text_fap:setString(UserGrade())
end

-- 刷新页签小红点
function overlordView:refreshRedDot()
    local map_equip = {
        [1] = 6,      -- 头盔
        [2] = 7,      -- 衣服
        [3] = 8,      -- 盾牌
        [4] = 5,      -- 武器
        [5] = 9,      -- 戒指
    }
    -- 找出已穿戴的装备
    local equipList = {}
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 6 or tonumber(cfg_item.useType) == 7 or tonumber(cfg_item.useType) == 8
            or tonumber(cfg_item.useType) == 5 or tonumber(cfg_item.useType) == 9 then
            equipList[tonumber(cfg_item.useType)] = true
        end
    end
    local show_equip = false
    for i, v in ipairs(map_equip) do
        -- 空位
        if not equipList[v] then
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    show_equip = true
                    break
                end
            end
        end
        if show_equip then
            break
        end
    end
    local img_red_dot_equip = me.assignWidget(self.btn_equip, "img_red_dot")
    img_red_dot_equip:setVisible(show_equip)


    --=========================================
    local map_hero = {
        [1] = 10,      -- 英雄
        [2] = 10,      -- 英雄
        [3] = 10,      -- 英雄
        [4] = 10,      -- 英雄
        [5] = 10,      -- 英雄
    }
    local heroList = {}
    for k, v in pairs(user.bookEquip) do
        local cfg_item = cfg[CfgType.ETC][v.defid]
        if tonumber(cfg_item.useType) == 10 and v.equipLoc > 0 then
            heroList[tonumber(v.equipLoc)] = true
        end
    end
    local show_hero = false
    for i, v in ipairs(map_hero) do
        -- 空位
        if not heroList[i] then
            for k_, v_ in pairs(user.bookPkg) do
                local cfg_item = cfg[CfgType.ETC][v_.defid]
                if tonumber(cfg_item.useType) == v then
                    show_hero = true
                    break
                end
            end
        end
        if show_hero then
            break
        end
    end
    local img_red_dot_hero = me.assignWidget(self.btn_hero, "img_red_dot")
    img_red_dot_hero:setVisible(show_hero)
end