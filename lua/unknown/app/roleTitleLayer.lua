-- [Comment]
-- jnmo
roleTitleLayer = class("roleTitleLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
roleTitleLayer.__index = roleTitleLayer
function roleTitleLayer:create(...)
    local layer = roleTitleLayer.new(...)
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
ROLE_TILE_LIST_ALL = 0
ROLE_TILE_LIST_GET = 1
ROLE_TILE_LIST_NOGET = 2
ROLE_TILE_LIST_SP = 3
function roleTitleLayer:ctor()
    print("roleTitleLayer ctor")
    self.chooseIndex = 0
end
function roleTitleLayer:init()
    print("roleTitleLayer init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    -- table父节点
    self.layout_table = me.assignWidget(self, "layout_table")
    -- 模板节点
    self.img_item = me.assignWidget(self, "img_item")
    self.img_item:setVisible(false)
    self.Image_Right = me.assignWidget(self, "Image_Right")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_TITLE_LIST) then
            self:initTaskTable()
        elseif checkMsg(msg.t, MsgCode.UPDATE_ROLE_TITLE) then
            self:initTaskTable()
        end
    end )
    self.Button_All = me.registGuiClickEventByName(self, "Button_All", function(node)
        self:setButton(self.Button_All, false)
        self:setButton(self.Button_Get, true)
        self:setButton(self.Button_NoGet, true)
        self:setButton(self.Button_sp, true)
        self.chooseIndex = ROLE_TILE_LIST_ALL
        self:initTaskTable()
    end )
    self.Button_sp = me.registGuiClickEventByName(self, "Button_sp", function(node)
        self:setButton(self.Button_All, true)
        self:setButton(self.Button_Get, true)
        self:setButton(self.Button_NoGet, true)
        self:setButton(self.Button_sp, false)
        self.chooseIndex = ROLE_TILE_LIST_SP
        self:initTaskTable()
    end )
    self.Button_Get = me.registGuiClickEventByName(self, "Button_Get", function(node)
        self:setButton(self.Button_All, true)
        self:setButton(self.Button_Get, false)
        self:setButton(self.Button_NoGet, true)
        self:setButton(self.Button_sp, true)
        self.chooseIndex = ROLE_TILE_LIST_GET
        self:initTaskTable()
    end )
    self.Button_NoGet = me.registGuiClickEventByName(self, "Button_NoGet", function(node)
        self:setButton(self.Button_All, true)
        self:setButton(self.Button_Get, true)
        self:setButton(self.Button_NoGet, false)
        self:setButton(self.Button_sp, true)
        self.chooseIndex = ROLE_TILE_LIST_NOGET
        self:initTaskTable()
    end )
    self.chooseIndex = ROLE_TILE_LIST_ALL
    self:setButton(self.Button_All, false)
    self:setButton(self.Button_Get, true)
    self:setButton(self.Button_NoGet, true)
    self.Image_Right:setVisible(false)
    return true
end
function roleTitleLayer:setButton(button, b)
    button:setEnabled(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c3b(0xc9, 0x77, 0x53))
    else
        title:setTextColor(cc.c3b(0xf4, 0xe4, 0xc6))
    end
end

function roleTitleLayer:initTaskTable()
    self.Image_Right:setVisible(false)
    local pTaskTab = { }
    self.pPitchId = 1
    if self.chooseIndex == ROLE_TILE_LIST_ALL then
        for key, var in pairs(cfg[CfgType.ROLE_TITLE]) do
            if var.type == 1 then
                var.duration = -1
                for k, v in pairs(user.title_list) do
                    if var.id == v.id then
                        var.duration = v.duration
                    end
                end
                table.insert(pTaskTab, var)
            end
        end
    elseif ROLE_TILE_LIST_SP == self.chooseIndex then
        for key, var in pairs(cfg[CfgType.ROLE_TITLE]) do
            if var.type == 2 then
                var.duration = -1
                for k, v in pairs(user.title_list) do
                    if var.id == v.id then
                        var.duration = v.duration
                    end
                end
                table.insert(pTaskTab, var)
            end
        end
    elseif self.chooseIndex == ROLE_TILE_LIST_GET then
        pTaskTab = user.title_list
    elseif self.chooseIndex == ROLE_TILE_LIST_NOGET then
        for key, var in pairs(cfg[CfgType.ROLE_TITLE]) do
            local have = false
            for k, v in pairs(user.title_list) do
                if var.id == v.id then
                    have = true
                end
            end
            if have == false then
                table.insert(pTaskTab, var)
            end
        end
    end

    local colNum = 3
    local tempNum = math.ceil(#pTaskTab / colNum)
    function numberOfCellsInTableView(tableView)
        return tempNum
    end

    local function cellSizeForTable(tableView, idx)
        return 453, 162
    end

    local function tableCellAtIndex(tableView, idx)
        local cell = tableView:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:create()
        end
        cell:removeAllChildren()
        for j = 1, colNum do
            local index = idx * colNum + j
            if not pTaskTab[index] then
                break
            end
            local cfg_item = cfg[CfgType.ROLE_TITLE][tonumber(pTaskTab[index].id)]
            -- 复制模板
            local x, y = 75.5 + (j - 1) * 151, 81
            local img_item = self.img_item:clone()
            img_item:setVisible(true)
            img_item:setPosition(cc.p(x, y))
            cell:addChild(img_item)
            me.registGuiClickEvent(img_item, function()
                self.pPitchId = index
                local offest = tableView:getContentOffset()
                tableView:reloadData()
                tableView:setContentOffset(offest)
            end)
            img_item:setSwallowTouches(false)
            -- 图标
            local img_icon = me.assignWidget(img_item, "img_icon")
            img_icon:loadTexture("role_title_" .. cfg_item.icon .. ".png", me.localType)
            img_icon:ignoreContentAdaptWithSize(true)
            img_icon:setScale(0.6)
            -- 名字
            local text_name = me.assignWidget(img_item, "text_name")
            text_name:setString(cfg_item.name)
            -- 是否装备
            local img_equiped = me.assignWidget(img_item, "img_equiped")
            img_equiped:setVisible(user.title == tonumber(pTaskTab[index].id))
            -- 是否选择
            local img_select = me.assignWidget(img_item, "img_select")
            if index == self.pPitchId then
                img_select:setVisible(true)
                self:initTitleInfo(cfg_item.id, cfg_item.duration)
            else
                img_select:setVisible(false)
            end
        end

        return cell
    end
    self.layout_table:removeAllChildren()
    local tableView = cc.TableView:create(self.layout_table:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    self.layout_table:addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function roleTitleLayer:initTitleInfo(id, time)
    self.Image_Right:setVisible(true)
    local def = cfg[CfgType.ROLE_TITLE][tonumber(id)]
    local Text_Title_Name = me.assignWidget(self, "Text_Title_Name")
    local Text_Time = me.assignWidget(self, "Text_Time")
    local Text_if = me.assignWidget(self, "Text_if")
    local Text_effect = me.assignWidget(self, "Text_effect")
    local Image_Icon = me.assignWidget(self, "Image_Icon")
    Image_Icon:loadTexture("role_title_" .. def.icon .. ".png", me.localType)
    Image_Icon:ignoreContentAdaptWithSize(true)
    Image_Icon:setScale(0.7)
    Text_Title_Name:setString(def.name)
    local c, _ = me.getColorByQuality(def.quality)
    Text_Title_Name:setTextColor(c)
    Text_if:setString(def.desc)
    me.clearTimer(self.timer)
    if time == 0 then
        Text_Time:setString("永久")
    elseif time == -1 then
        Text_Time:setString("未获得")
    else
        Text_Time:setString(me.formartSecTime(time / 1000))
        self.timer = me.registTimer(time / 1000, function(dt)
            Text_Time:setString(me.formartSecTime(time / 1000 - dt))
        end , 1)
    end
    local str = ""
    local pps = me.split(def.property, ",")
    for var = 1, 3 do
        me.assignWidget(self,"Text_effect"..var):setVisible(false)
    end    
    for key, var in pairs(pps) do
        local ps = me.split(var, ":")
        local pdef = cfg[CfgType.LORD_INFO][ps[1]]
        if tonumber(pdef.isPercent) == 1 then
            str =  pdef.name .. "+" .. ps[2] * 100 .. "%"
        else
            str = pdef.name .. "+" .. ps[2]
        end
        if key <= 3 then
            local effect = me.assignWidget(self,"Text_effect"..key)
            effect:setVisible(true)
            effect:setString(str)
        end
    end
   
    local Button_Show = me.registGuiClickEventByName(self, "Button_Show", function(node)
        NetMan:send(_MSG.updateUserTitle(id))
    end )
    local have = false
    for key, var in pairs(user.title_list) do
        if var.id == id then
            have = true
        end
    end
    if user.title == id then
        me.setButtonDisable(Button_Show, false)
        me.assignWidget(Button_Show, "text_title_btn"):setString("已装备")
    else
        if have then
            me.setButtonDisable(Button_Show, true)
            me.assignWidget(Button_Show, "text_title_btn"):setString("装备称号")
        else
            me.setButtonDisable(Button_Show, false)
            me.assignWidget(Button_Show, "text_title_btn"):setString("未获得")
        end
    end
end

function roleTitleLayer:onEnter()
    print("roleTitleLayer onEnter")
    me.doLayout(self, me.winSize)
end

function roleTitleLayer:onEnterTransitionDidFinish()
    print("roleTitleLayer onEnterTransitionDidFinish")
end

function roleTitleLayer:onExit()
    print("roleTitleLayer onExit")
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.timer)
    -- 删除消息通知
end

function roleTitleLayer:close()
    self:removeFromParent()
end
