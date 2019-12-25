--[[
    文件名：growWayNode.lua
    描述：成长之路内容节点
    创建人：libowen
    创建时间：2019.8.19
--]]

growWayNode = class("growWayNode", function(...)
    return cc.CSLoader:createNode("growWayNode.csb")
end)
growWayNode.__index = growWayNode

function growWayNode:create(...)
    local node = growWayNode.new(...)
    if node then
        if node:init() then
            node:registerScriptHandler(function(tag)
                if "enter" == tag then
                    node:onEnter()
                elseif "exit" == tag then
                    node:onExit()
                end
            end )
            return node
        end
    end
    return nil
end

-- 构造器
--[[
    params
    {
        data                -- 宝箱列表
    }
--]]
function growWayNode:ctor(params)
    print("growWayNode ctor")
    params = params or {}
    self.data = params.data
    -- 列数
    self.colNum = 5
    -- 行数
    self.rowNum = math.ceil(#self.data / self.colNum) 
end

-- 初始化
function growWayNode:init()
    print("growWayNode init")
    -- 宝箱模板节点
    self.item_box = me.assignWidget(self, "item_box")
    self.item_box:setVisible(false)
    -- tableview父节点
    self.panel_table = me.assignWidget(self, "panel_table")
    self.viewSize = self.panel_table:getContentSize()
    self:createTableView()
    return true
end

-- 创建tableview
function growWayNode:createTableView()
    self.tableView = cc.TableView:create(self.viewSize)
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:ignoreAnchorPointForPosition(false)
    self.tableView:setAnchorPoint(cc.p(0, 0))
    self.tableView:setPosition(cc.p(0, 0))
    self.tableView:setDelegate()
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.panel_table:addChild(self.tableView)
    -- 注册回调
    self.tableView:registerScriptHandler(handler(self, self.numberOfCellsInTableView), cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(handler(self, self.cellSizeForTable), cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(handler(self, self.tableCellAtIndex), cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
end

------------------ TableView回调 ----------------
function growWayNode:numberOfCellsInTableView(tableView)
    return self.rowNum
end

function growWayNode:cellSizeForTable(tableView, idx)
    return self.viewSize.width, 160
end

function growWayNode:tableCellAtIndex(tableView, idx)
    local cell = tableView:dequeueCell()
    if not cell then
        cell = cc.TableViewCell:create()
    end
    cell:removeAllChildren()
    for i = 1, self.colNum do
        local index = idx * self.colNum + i
        local boxInfo = self.data[index]
        if not boxInfo then
            break
        end
        local pos_x = idx % 2 == 0 and 95 + (i - 1) * 185 or self.viewSize.width - 110 - (i - 1) * 185
        local pos_y = 85
        local item_box = self.item_box:clone()
        item_box:setPosition(cc.p(pos_x, pos_y))
        cell:addChild(item_box)
        item_box:setVisible(true)
        -- 宝箱图片
        local img_box = me.assignWidget(item_box, "img_box")
        local boxSize = img_box:getContentSize()
        img_box:loadTexture(boxInfo.icon..".png", me.localType)
        img_box:ignoreContentAdaptWithSize(true)
        img_box:setSwallowTouches(false)
        -- 宝箱状态: 0 不可领取, 1 可领取, 2 已领取
        if boxInfo.status == 1 then
            local ani = createArmature("keji_jiesuo")
            ani:setPosition(cc.p(boxSize.width / 2, boxSize.height / 2))
            img_box:addChild(ani)
            ani:getAnimation():play("donghua")
        elseif boxInfo.status == 2 then
            me.Helper:grayImageView(img_box)
        end
        me.registGuiClickEvent(img_box, function(sender)
            if boxInfo.status == 0 then
                local gdLayer = giftDetailCell:create("giftDetailCell.csb")
                gdLayer:setItemData_Limit(boxInfo.reward)
                me.popLayer(gdLayer)
            elseif boxInfo.status == 1 then
                NetMan:send(_MSG.grow_way_get(boxInfo.id))
            elseif boxInfo.status == 2 then
                showTips("已领取")
            end
        end)
        -- 城镇中心等级
        local centerLv = user.centerBuild:getDef().level
        -- 等级
        local text_lv = me.assignWidget(item_box, "text_lv")
        text_lv:setString("等级"..boxInfo.id)
        -- 选中框
        local img_select = me.assignWidget(item_box, "img_select")
        if boxInfo.id == centerLv + 1 then
            img_select:setVisible(true)
            img_select:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.FadeIn:create(1.5),
                cc.FadeOut:create(1.5)
            )))
        else
            img_select:setVisible(false)
        end
        -- 点
        local img_point = me.assignWidget(item_box, "img_point")
        img_point:setVisible(index ~= #self.data)
        if idx % 2 == 0 then
            if i % self.colNum == 0 then
                img_point:setPosition(cc.p(55, -80))
                img_point:setRotation(90)
                img_point:setScaleY(-1)
            else
                if i % 2 ~= 0 then
                    img_point:setPosition(cc.p(95, -13))
                else
                    img_point:setPosition(cc.p(95, 13))
                    img_point:setScaleY(-1)
                end
            end
        else
            if i % self.colNum == 0 then
                img_point:setPosition(cc.p(-55, -80))
                img_point:setRotation(90)
            else
                if i % 2 ~= 0 then
                    img_point:setPosition(cc.p(-95, 13))
                    img_point:setScaleY(-1)
                else
                    img_point:setPosition(cc.p(-95, -13))
                end
            end
        end
        local img_light = me.assignWidget(img_point, "img_light")
        if index < centerLv then
            img_light:setOpacity(255)
        elseif index == centerLv then
            img_light:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.FadeIn:create(1.5),
                cc.FadeOut:create(1.5)
            )))
        else
            img_light:setOpacity(0)
        end
    end
    return cell
end

function growWayNode:onEnter()
    print("growWayNode onEnter")
end

function growWayNode:onExit()
    print("growWayNode onExit")
end
