--[[
	文件名：PvpRecordView.lua
	描述：跨服争霸海选记录页面
	创建人：libowen
	创建时间：2019.10.23
--]]

PvpRecordView = class("PvpRecordView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpRecordView.__index = PvpRecordView

function PvpRecordView:create(...)
    local layer = PvpRecordView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
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

-- 构造器
function PvpRecordView:ctor()
    print("PvpRecordView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_PRESELECTION_RECORD) then
            self.info = msg.c
            -- 刷新列表
            self:refreshTableView()
        end
    end)
    -- 获取海选记录
    NetMan:send(_MSG.get_pvp_preselection_record())
end

-- 初始化
function PvpRecordView:init()
    print("PvpRecordView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    self.img_center = me.assignWidget(self.img_bg, "img_center")
    --  空提示
    self.text_empty = me.assignWidget(self.img_center, "text_empty")
    self.text_empty:setVisible(false)
    self.layout_table = me.assignWidget(self.img_center, "layout_table")
    -- 模板节点
    self.layout_item = me.assignWidget(self.img_center, "layout_item")
    self.layout_item:setVisible(false)
    -- 详情模板
    self.layout_item_detail = me.assignWidget(self.img_center, "layout_item_detail")
    self.layout_item_detail:setVisible(false)

    return true
end

-- 刷新table
function PvpRecordView:refreshTableView()
    if self.info.record and #self.info.record > 0 then
        self.text_empty:setVisible(false)
    else
        self.text_empty:setVisible(true)
    end
    local tableSize = self.layout_table:getContentSize()
    -- cell高度
    local cell_record_height = 115
    local cell_detail_height = 350
    -- cell间距
    local cell_space = 5
    local function numberOfCellsInTableView(tableview)
        return #self.info.record
    end
    local function cellSizeForTable(tableview, idx)
        local tempList = self.info.record[idx + 1]
        if not tempList.isDetail then
            return tableSize.width, cell_record_height + cell_space
        else
            return tableSize.width, cell_detail_height + cell_space
        end
    end
    local function tableCellAtIndex(tableview, idx)
        local cell = tableview:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        local tempList = self.info.record[idx + 1]
        if not tempList.isDetail then
            -- 创建模板
            local node = self.layout_item:clone()
            node:setVisible(true)
            node:setPosition(cc.p(0, cell_space))
            cell:addChild(node)
            cell.node = node
            -- 时间
            local text_time = me.assignWidget(cell.node, "text_time")
            text_time:setString(me.GetSecTime(tempList.time))
            -- 描述
            local panel_rich = me.assignWidget(cell.node, "panel_rich")
            panel_rich:removeAllChildren()
            local tempStr = string.format("<txt0018,D4CDB9>%s海选第%s场，&", tempList.groupName, tempList.round)
            -- empty 1:轮空，0:未轮空
            if tempList.empty == 0 then
                tempStr = string.format("%s<txt0018,D4CDB9>对阵&<txt0018,FF0202>%s&<txt0018,D4CDB9>，&", tempStr, tempList.enemyName)
            else
                tempStr = string.format("%s<txt0018,FF0202>本轮轮空&<txt0018,D4CDB9>，&", tempStr)
            end
            if tempList.winRst then
                -- 0:进入下一轮 1:进入32强
                if tempList.st == 0 then
                    tempStr = string.format("%s<txt0018,D4CDB9>战斗结果&<txt0018,67FF02>%s:%s胜&<txt0018,D4CDB9>，进入下一轮海选&", tempStr, tempList.winTimes, 3 - tempList.winTimes)
                elseif tempList.st == 1 then
                    tempStr = string.format("%s<txt0018,D4CDB9>战斗结果&<txt0018,67FF02>%s:%s胜&<txt0018,D4CDB9>，进入32强&", tempStr, tempList.winTimes, 3 - tempList.winTimes)
                end
            else
                tempStr = string.format("%s<txt0018,D4CDB9>战斗结果&<txt0018,FF0202>%s:%s负&<txt0018,D4CDB9>，淘汰出局&", tempStr, tempList.winTimes, 3 - tempList.winTimes)
            end
            local richText = mRichText:create(tempStr, 1100)
            richText:setAnchorPoint(cc.p(0, 0.5))
            richText:setPosition(cc.p(0, 20))
            panel_rich:addChild(richText)
            -- 详情
            local btn_arrow = me.assignWidget(cell.node, "btn_arrow")
            btn_arrow:setVisible(tempList.empty == 0)
            if self.info.record[idx + 2] and self.info.record[idx + 2].isDetail then
                if tempList.empty == 0 then
                    btn_arrow:setRotation(90)
                    me.registGuiClickEvent(cell.node, function(sender)
                        sender:setTouchEnabled(false)
                        table.remove(self.info.record, idx + 2)
                        local offset = self.tableView:getContentOffset()
                        self.tableView:reloadData()
                        self.tableView:setContentOffset(cc.p(offset.x, offset.y + (cell_detail_height + cell_space)))
                    end)
                else
                    print("轮空，无数据")
                end
            else
                btn_arrow:setRotation(0)
                me.registGuiClickEvent(cell.node, function(sender)
                    if tempList.empty == 0 then
                        sender:setTouchEnabled(false)
                        local list = clone(tempList)
                        list.isDetail = true
                        table.insert(self.info.record, idx + 2, list)
                        local offset = self.tableView:getContentOffset()
                        self.tableView:reloadData()
                        self.tableView:setContentOffset(cc.p(offset.x, offset.y - (cell_detail_height + cell_space)))
                    else
                        print("轮空，无数据")
                    end
                end)
            end
            cell.node:setSwallowTouches(false)
        else
            -- 创建模板
            local node = self.layout_item_detail:clone()
            node:setVisible(true)
            node:setPosition(cc.p(0, 5))
            cell:addChild(node)
            cell.node = node

            -- 进攻方
            local text_attacker_name = me.assignWidget(cell.node, "text_attacker_name")
            text_attacker_name:setString(tempList.myName)
            -- 防守方
            local text_defender_name = me.assignWidget(cell.node, "text_defender_name")
            text_defender_name:setString(tempList.enemyName)
            -- 上路
            local layout_shang = me.assignWidget(cell.node, "layout_shang")
            -- 中路
            local layout_zhong = me.assignWidget(cell.node, "layout_zhong")
            -- 下路
            local layout_xia = me.assignWidget(cell.node, "layout_xia")
            for i, v in ipairs({layout_shang, layout_zhong, layout_xia}) do
                local data = tempList.data[i]
                -- 攻击方
                local text_attacker_1 = me.assignWidget(v, "text_attacker_1")
                text_attacker_1:setString(data[2])
                local text_attacker_2 = me.assignWidget(v, "text_attacker_2")
                text_attacker_2:setString(data[3])
                local text_attacker_3 = me.assignWidget(v, "text_attacker_3")
                text_attacker_3:setString(data[4])
                local text_attacker_4 = me.assignWidget(v, "text_attacker_4")
                text_attacker_4:setString(data[1] == 1 and "胜" or "负")
                text_attacker_4:setTextColor(data[1] == 1 and cc.c3b(0x67, 0xff, 0x02) or cc.c3b(0xff, 0x02, 0x02))
                -- 防守方
                local text_defender_1 = me.assignWidget(v, "text_defender_1")
                text_defender_1:setString(data[5])
                local text_defender_2 = me.assignWidget(v, "text_defender_2")
                text_defender_2:setString(data[6])
                local text_defender_3 = me.assignWidget(v, "text_defender_3")
                text_defender_3:setString(data[7])
                local text_defender_4 = me.assignWidget(v, "text_defender_4")
                text_defender_4:setString(data[1] == 1 and "负" or "胜")
                text_defender_4:setTextColor(data[1] == 1 and cc.c3b(0xff, 0x02, 0x02) or cc.c3b(0x67, 0xff, 0x02))
            end
        end

        return cell
    end
    self.layout_table:removeAllChildren()
    local tableView = cc.TableView:create(tableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.layout_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView = tableView
end

function PvpRecordView:onEnter()
    print("PvpRecordView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpRecordView:onEnterTransitionDidFinish()
    print("PvpRecordView onEnterTransitionDidFinish")
end

function PvpRecordView:onExit()
    print("PvpRecordView onExit")
    UserModel:removeLisener(self.lisener)
end
