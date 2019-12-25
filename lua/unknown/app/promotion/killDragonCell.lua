-- [Comment]
-- jnmo
killDragonCell = class("killDragonCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
killDragonCell.__index = killDragonCell
function killDragonCell:create(...)
    local layer = killDragonCell.new(...)
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
function killDragonCell:ctor()
    print("killDragonCell ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_DRAGON  or msg.c.activityId == ACTIVITY_ID_DRAGON_NEW then
                user.activityDetail = msg.c
                if msg.c.defid == 0 then
                    showTips("召唤暴龙成功")
                end
                if self.showType == 1 then
                    self:setTableView()
                else
                    self:setCallDragonView()
                end
            end
        end
    end )
end
function killDragonCell:init()
    print("killDragonCell init")
    self.callDragonPanel = me.assignWidget(self, "callDragonPanel")
    self.killDragonPanel = me.assignWidget(self, "killDragonPanel")

    self.btn_killdragon = me.registGuiClickEventByName(self, "Button_kill_dragon", function(node)
        self:setButton(self.btn_killdragon, false)
        self:setButton(self.btn_calldragon, true)
        self.showType = 1
        self:setViewData()
    end )

    self.btn_calldragon = me.registGuiClickEventByName(self, "Button_call_dragon", function(node)
        self:setButton(self.btn_killdragon, true)
        self:setButton(self.btn_calldragon, false)
        self.showType = 2
        self:setViewData()
    end )

    self.joinBtn = me.registGuiClickEventByName(self, "joinBtn", function(node)
        NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, 0))
    end )

    self.gotoFightBtn = me.registGuiClickEventByName(self, "gotoFightBtn", function(node)
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity:cloudClose( function(node)
                local loadlayer = loadWorldMap:create("loadScene.csb")
                loadlayer:setWarningPoint(cc.p(user.activityDetail.x, user.activityDetail.y))
                me.runScene(loadlayer)
            end )
            self.parent:close()
        else
            pWorldMap:lookMapAt(user.activityDetail.x, user.activityDetail.y)
            self.parent:close()
        end
    end )

    return true
end

function killDragonCell:setParent(p)
    self.parent = p
end

function killDragonCell:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(212, 197, 180, 255))
    else
        title:setTextColor(cc.c4b(181, 161, 138, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end

function killDragonCell:setTableView()
    self.listData = user.activityDetail.list

    local function comp(a, b)
        return a.index < b.index
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
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 831, 123
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_item"):clone():setVisible(true)
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
                if user.activityDetail.score >= tmp.need then
                    Text_plunderNum:setString(tmp.need .. "/" .. tmp.need)
                else
                    Text_plunderNum:setString(user.activityDetail.score .. "/" .. tmp.need)
                end
                me.assignWidget(btn, "image_title"):setString("未完成")

                btn:setTitleColor(COLOR_WHITE)
                me.setButtonDisable(btn, false)

            elseif tmp.status == 2 then
                -- 已经领取过
                Text_plunderNum:setTextColor(me.convert3Color_("d4cdb9"))
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_guoqi.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(true)
                me.assignWidget(node, "Button_get"):setVisible(false)
                Text_plunderNum:setString(tmp.need .. "/" .. tmp.need)
            elseif tmp.status == 1 then
                if user.activityDetail.score >= tmp.need then
                    Text_plunderNum:setString(tmp.need .. "/" .. tmp.need)
                else
                    Text_plunderNum:setString(user.activityDetail.score .. "/" .. tmp.need)
                end
                Text_plunderNum:setTextColor(me.convert3Color_("67ff02"))
                --me.assignWidget(node, "Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png", me.localType)
                me.assignWidget(node, "Image_got"):setVisible(false)
                local btn = me.assignWidget(node, "Button_get")
                me.registGuiClickEventByName(node, "Button_get", function()
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, tmp.index))
                end )
                btn:setVisible(true)
                me.assignWidget(btn, "image_title"):setString("领取")
                btn:setTitleColor(COLOR_WHITE)
                me.setButtonDisable(btn, true)
            end

            if idx%2==0 then
                me.assignWidget(node, "Image_panel"):loadTexture("ui_ty_cell_bg.png", me.localType)
            else
                me.assignWidget(node, "Image_panel"):loadTexture("alliance_alpha_bg.png", me.localType)
            end

            local itemPanel = me.assignWidget(node, "Panel_itemIcon")
            itemPanel:removeAllChildren()
            local indexX = 0
            for key, var in pairs(tmp.item) do
                local item = me.assignWidget(self, "Image_itemBg"):clone():setVisible(true)
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
                item:setScale(0.85)
                item:setPosition(indexX * 115, itemPanel:getContentSize().height / 2-5)
                indexX = indexX + 1
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(831, 329))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(1, 1))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end


function killDragonCell:setCallDragonView()
    local listView1 = me.assignWidget(self.callDragonPanel, "ListView_1")
    me.assignWidget(self,"Node_CallMax"):removeAllChildren()
    if user.activityDetail.curNum == user.activityDetail.max then
        local str = "<txt0016,B3DF05>召唤暴龙次数已达上限,当前存活暴龙数：&<txt0016,ffffff>"..user.activityDetail.alive.."   &<txt0016,B3DF05>寻龙探宝已开启&"
        local rt = mRichText:create(str)
        rt:setPositionX(-rt:getContentSize().width/2)
        me.assignWidget(self,"Node_CallMax"):addChild(rt)        
        self.joinBtn:loadTextureNormal("ui_ty_button_cheng_266x79.png",me.localType)
        me.assignWidget(self.joinBtn,"image_title"):setString("寻龙探宝")
    else
        local str = "<txt0016,B3DF05>本服今日剩余召唤次数：&<txt0016,ffffff>"..(user.activityDetail.max - user.activityDetail.curNum).."  &<txt0016,B3DF05>当前存活暴龙数：&<txt0016,ffffff>"..user.activityDetail.alive.."&"
        local rt = mRichText:create(str)
        rt:setPositionX(-rt:getContentSize().width/2)
        me.assignWidget(self,"Node_CallMax"):addChild(rt)        
        self.joinBtn:loadTextureNormal("ui_ty_button_hong_266x79_.png",me.localType)
        me.assignWidget(self.joinBtn,"image_title"):setString("召唤暴龙")
    end
    listView1:removeAllItems()
    for key, var in ipairs(user.activityDetail.view) do
        local item = BackpackCell:create("backpack/backpackcell.csb")
        item:setUI( { defid = var, count = 0 })
        iPanel = me.assignWidget(self.callDragonPanel, "ItemPanel"):clone():setVisible(true)
        item:setScale(0.6)
        iPanel:addChild(item)
        listView1:pushBackCustomItem(iPanel)
        me.assignWidget(item, "num_bg"):setVisible(false)
        local btnBg = me.assignWidget(item, "Button_bg")
        btnBg:setSwallowTouches(false)
        me.registGuiClickEvent(btnBg, function()
            showPromotion(var)
        end )
    end
    if #user.activityDetail.view < 5 then
        listView1:setBounceEnabled(false)
        listView1:setPositionX(330 +(97 *(5 - #user.activityDetail.view)) / 2)
        listView1:setContentSize(cc.size(97 * #user.activityDetail.view, 117.42))
    end
    me.assignWidget(self.callDragonPanel, "tipsTxt"):setString("本次BOSS强度：Lv." .. user.activityDetail.lv)
    if user.activityDetail.x > 0 or user.activityDetail.y > 0 then
        me.assignWidget(self.callDragonPanel, "closePanel"):setVisible(false)
        me.assignWidget(self.callDragonPanel, "startPanel"):setVisible(true)
    else
        me.assignWidget(self.callDragonPanel, "closePanel"):setVisible(true)
        me.assignWidget(self.callDragonPanel, "startPanel"):setVisible(false)
        me.assignWidget(self.callDragonPanel, "powerTxt"):setString(user.activityDetail.zhbl .. "/1")
    end

end

function killDragonCell:setViewData()
    if self.showType == 1 then
        self.callDragonPanel:setVisible(false)
        self.killDragonPanel:setVisible(true)

        self:setTableView()
    else
        self.callDragonPanel:setVisible(true)
        self.killDragonPanel:setVisible(false)
        self:setCallDragonView()
    end
end

function killDragonCell:onEnter()
    print("killDragonCell onEnter")
    self.showType = 1
    self:setButton(self.btn_killdragon, false)
    self:setViewData()
    self:initTopBar()
    me.doLayout(self, me.winSize)
end
function killDragonCell:initTopBar()
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    local Panel_richText = me.assignWidget(self, "Panel_richText")
    local rich = mRichText:create(user.activityDetail.desc or activity.desc, Panel_richText:getContentSize().width)
    rich:setPosition(0, Panel_richText:getContentSize().height)
    rich:setAnchorPoint(cc.p(0, 1))
    Panel_richText:addChild(rich)
    local Text_countDown = me.assignWidget(self, "activityTime_open")
    if tonumber(user.activityDetail.open) == 1 then
        local leftT = user.activityDetail.countdown
        Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动结束")
            end
            Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
        self.btn_killdragon:setVisible(true)
        self.btn_calldragon:setVisible(true)
    else
        local leftT = user.activityDetail.countdown
        Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动开启")
            end
            Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
        self.btn_killdragon:setVisible(false)
        self.btn_calldragon:setVisible(false)
        self:initGift()
    end
end
function killDragonCell:initGift(args)
    me.assignWidget(self.killDragonPanel, "gift"):setVisible(true)
    local listView1 = me.assignWidget(me.assignWidget(self.killDragonPanel, "gift"),"ListView_1")
    listView1:removeAllItems()
    for key, var in ipairs(user.activityDetail.view) do
        local item = BackpackCell:create("backpack/backpackcell.csb")
        item:setUI( { defid = var, count = 0 })
        iPanel = me.assignWidget(self.callDragonPanel, "ItemPanel"):clone():setVisible(true)
        item:setScale(0.6)
        iPanel:addChild(item)
        listView1:pushBackCustomItem(iPanel)
        me.assignWidget(item, "num_bg"):setVisible(false)
        local btnBg = me.assignWidget(item, "Button_bg")
        btnBg:setSwallowTouches(false)
        me.registGuiClickEvent(btnBg, function()
            showPromotion(var)
        end )
    end
    if #user.activityDetail.view < 5 then
        listView1:setBounceEnabled(false)
        listView1:setPositionX(338 +(97 *(5 - #user.activityDetail.view)) / 2)
        listView1:setContentSize(cc.size(97 * #user.activityDetail.view, 117.42))
    end
end
function killDragonCell:onEnterTransitionDidFinish()
    print("killDragonCell onEnterTransitionDidFinish")
end
function killDragonCell:onExit()
    print("killDragonCell onExit")
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function killDragonCell:close()
    self:removeFromParent()
end

