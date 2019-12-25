-- [Comment]
-- jnmo
sumPayCell = class("sumPayCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
sumPayCell.__index = sumPayCell
function sumPayCell:create(...)
    local layer = sumPayCell.new(...)
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
function sumPayCell:ctor()
    print("sumPayCell ctor")
end
function sumPayCell:init()
    print("sumPayCell init")
    self.Text_time = me.assignWidget(self, "Text_Time")
    return true
end
function sumPayCell:initActivity(id)
    self.activity_id = id
    local data = user.activityPayData[self.activity_id]
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(data.activityId)]
    self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_SUMPAY or msg.c.activityId == ACTIVITY_ID_RUNE then
                self:setTableView()
            end
        end
    end )
    if self.activity_id == ACTIVITY_ID_RUNE then
        me.assignWidget(self, "Image_up_frame"):loadTexture("huodong_bg_shouxun.png", me.localType)
    end
    self:setTableView()
end
function sumPayCell:setTableView()
    self.listData = user.activityPayData[self.activity_id].list
    local function comp(a, b)
        return a.id < b.id
    end
    table.sort(self.listData, comp)
    local px  ={}
    for key, var in pairs(self.listData) do
        if var.status ~= 2 then 
            table.insert(px,var)
        end
    end
    for key, var in pairs(self.listData) do
        if var.status == 2 then 
            table.insert(px,var)
        end
    end
    self.listData = px
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 832,116
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_item"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_item")
            node:setVisible(true)
        end
        local tmp = self.listData[me.toNum(idx + 1)]
        local Text_plunderNum = me.assignWidget(node, "Text_plunderNum")
        if tmp then
            if tmp.status == 0 then
                -- 不能领取
                Text_plunderNum:setTextColor(me.convert3Color_("d4cdb9"))
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(false)
                local btn = me.assignWidget(node, "Button_get")
                btn:setVisible(true)
                if self.activity_id == ACTIVITY_ID_SUMPAY then
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id)
                    me.assignWidget(btn, "image_title"):setString("前往充值")
                elseif self.activity_id == ACTIVITY_ID_RUNE then
                    me.assignWidget(node, "Image_txt_Label"):loadTexture("huodong_souxun.png", me.localType)
                    me.assignWidget(btn, "image_title"):setString("前往搜寻")
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id .. "次")
                end
                me.setButtonDisable(btn, true)
                me.registGuiClickEventByName(node, "Button_get", function(node)
                    if self.activity_id == ACTIVITY_ID_SUMPAY then
                        TaskHelper.jumToPay()
                    elseif self.activity_id == ACTIVITY_ID_RUNE then
                        if user.newBtnIDs[tostring(OpenButtonID_RELIC)] ~= nil then
                            local  runeSearch = runeSearch:create("rune/runeSearch.csb")
                            me.runningScene():addChild(runeSearch, me.MAXZORDER)
                            me.showLayer(runeSearch, "bg")                            
                        else
                            showTips("建造圣殿后开启搜寻功能")
                        end
                    end
                    me.dispatchCustomEvent("promotionViewclose")
                end )
            elseif tmp.status == 2 then
                -- 已经领取过
                Text_plunderNum:setTextColor(me.convert3Color_("d4cdb9"))
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_guoqi.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(true)
                me.assignWidget(node, "Button_get"):setVisible(false)
                if self.activity_id == ACTIVITY_ID_SUMPAY then                   
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id)
                elseif self.activity_id == ACTIVITY_ID_RUNE then
                    me.assignWidget(node, "Image_txt_Label"):loadTexture("huodong_souxun.png", me.localType)           
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id .. "次")
                end
            elseif tmp.status == 1 then
                -- 能领取                
                if self.activity_id == ACTIVITY_ID_SUMPAY then                   
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id)
                elseif self.activity_id == ACTIVITY_ID_RUNE then
                    me.assignWidget(node, "Image_txt_Label"):loadTexture("huodong_souxun.png", me.localType)           
                    Text_plunderNum:setString(user.activityPayData[self.activity_id].value .. "/" .. tmp.id .. "次")
                end
                Text_plunderNum:setTextColor(me.convert3Color_("67ff02"))
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(false)
                local btn = me.assignWidget(node, "Button_get")
                me.registGuiClickEventByName(node, "Button_get", function()
                    NetMan:send(_MSG.updateActivityDetail(self.activity_id, tmp.id))
                end )
                btn:setVisible(true)
                me.assignWidget(btn, "image_title"):setString("领取")
                me.setButtonDisable(btn, true)
            end

            local itemPanel = me.assignWidget(node, "Panel_itemIcon")
            itemPanel:removeAllChildren()
            local indexX = 0
            for key, var in pairs(tmp.items) do
                local item = me.assignWidget(self, "Image_itemBg"):clone()
                item:setVisible(true)
                local etc = cfg[CfgType.ETC][me.toNum(var[1])]
                me.assignWidget(item, "Image_itemBg"):loadTexture(getQuality(etc.quality))
                me.assignWidget(item, "Image_item"):loadTexture(getItemIcon(etc.id))
                me.assignWidget(item, "Text_Num"):setString(var[2])
                me.assignWidget(item, "Button_item"):setSwallowTouches(false)
                me.registGuiClickEventByName(item, "Button_item", function()
                    showPromotion(var[1], var[2])
                end )
                itemPanel:addChild(item)
                item:setAnchorPoint(cc.p(0, 0.5))
                item:setPosition(indexX * 135, itemPanel:getContentSize().height / 2)
                indexX = indexX + 1
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(834,422))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(3, 1))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function sumPayCell:onEnter()
    print("sumPayCell onEnter")

--    if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_SUMPAY)] == 1 then
--        -- 移除红点
--        removeRedpoint(ACTIVITY_ID_SUMPAY)
--    end
--    if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_RUNE)] == 1 then
--        -- 移除红点
--        removeRedpoint(ACTIVITY_ID_RUNE)
--    end
    removeRedpoint(self.activity_id)
    me.doLayout(self, me.winSize)
end
function sumPayCell:onEnterTransitionDidFinish()
    print("sumPayCell onEnterTransitionDidFinish")
end
function sumPayCell:onExit()
    print("sumPayCell onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function sumPayCell:close()
    self:removeFromParent()
end

