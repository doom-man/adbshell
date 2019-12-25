-- [Comment]
-- jnmo
limitExchangeCell = class("limitExchangeCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
limitExchangeCell.__index = limitExchangeCell
function limitExchangeCell:create(...)
    local layer = limitExchangeCell.new(...)
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
function limitExchangeCell:ctor()
    print("limitExchangeCell ctor")
end
function limitExchangeCell:init()
    print("limitExchangeCell init")
    me.registGuiClickEventByName(self, "Button_Shop", function(args)
        if tonumber(user.activityDetail.open) == 1 then
        NetMan:send(_MSG.initShop(LIMIT_EXCHANGE_SHOP))
        local shop = limitExchangeShop:create("citySkinShop.csb")
        me.popLayer(shop)
        else
            showTips("活动未开启")
        end
    end )
    self:initTopBar()
    
    --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_LIMITED_REDEMPTION)] == 1 then
        -- 移除红点
    removeRedpoint(ACTIVITY_ID_LIMITED_REDEMPTION)
    --end

    return true
end
function limitExchangeCell:initTopBar()
    local Panel_richText = me.assignWidget(self, "Panel_richText")
    local rich = mRichText:create(user.activityDetail.desc or activity.desc, Panel_richText:getContentSize().width)
    rich:setPosition(0, Panel_richText:getContentSize().height)
    rich:setAnchorPoint(cc.p(0, 1))
    Panel_richText:addChild(rich)
    local Text_countDown = me.assignWidget(self, "Text_countDown")
    if tonumber(user.activityDetail.open) == 1 then
        local leftT = user.activityDetail.countDown
        Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动结束")
            end
            Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
        self:setTableView()
        me.assignWidget(self,"Panel_NoOpen"):setVisible(false)
    else
        local leftT = user.activityDetail.countDown
        Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动开启")
            end
            Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
        me.assignWidget(self,"Panel_NoOpen"):setVisible(true)
    end
end
function limitExchangeCell:setTableView()
    self.listData = user.activityDetail.list
    local function comp(a, b)
        return a.id < b.id
    end
    table.sort(self.listData, comp)
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 832, 126
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Image_Item"):clone():setVisible(true)
            cell:addChild(node)
            node:setPosition(0, 0)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Image_Item")
            node:setVisible(true)
        end
        me.assignWidget(node, "Image_bg"):setVisible(idx%2==0)
        local tmp = self.listData[me.toNum(idx + 1)]
        local exchageData = cfg[CfgType.LIMIT_EXCHANGE][tmp.id]
        if tmp then
            local Image_icon = me.assignWidget(node, "Image_icon")
            local Text_Name = me.assignWidget(node, "Text_Name")
            local Text_Score = me.assignWidget(node, "Text_Score")
            local Text_comlete = me.assignWidget(node, "Text_comlete")
            local Button_Go = me.assignWidget(node, "Button_Go")
            local Image_Score_icon= me.assignWidget(node, "Image_Score_icon")
            Text_Name:setString(exchageData.desc)
            Image_Score_icon:loadTexture("item_9018.png", me.localType)
            Text_Score:setString("x" .. exchageData.score)
            Image_icon:loadTexture("exchange_icon_" .. exchageData.type .. ".png", me.localType)
            Image_icon:ignoreContentAdaptWithSize(true)
            Button_Go.goType = exchageData.type
            me.registGuiClickEvent(Button_Go, function(node)
                local gotype = node.goType
                self:close()
                me.dispatchCustomEvent("promotionViewclose")
                if gotype == 1 then
                    -- 考古
                    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                        local guide = guideView:getInstance()
                        if guide.anim ~= nil then
                            guide:close()
                            guide = guideView:getInstance()
                        end
                        guide:showGuideView(mainCity.battleBtn, false, false)
                        mainCity:addChild(guide, me.GUIDEZODER)
                    end
                elseif gotype == 2 then
                    -- 训练士兵
                    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                        local function callBack(node)
                            NetMan:send(_MSG.prodSoldierView(self.bTarget:getToftId()))
                        end
                        local types = { }
                        types[#types + 1] = "barrack"
                        types[#types + 1] = "range"
                        types[#types + 1] = "horse"
                        types[#types + 1] = "siege"
                        types[#types + 1] = "wonder"
                        self.bTarget = jumpToAnyArmyBuildingByTypes(types, callBack)
                    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                        pWorldMap:backCity()
                    end
                elseif gotype == 3 then
                    -- 治疗
                    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                        jumpToTargetExt("abbey", true, function()
                            NetMan:send(_MSG.revertSoldierInit())
                        end )
                    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                        pWorldMap:backCity()
                    end
                elseif gotype == 4 or gotype == 5 or gotype == 6 then
                    -- 圣地试炼
                    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                        local guide = guideView:getInstance()
                        if guide.anim ~= nil then
                            guide:close()
                            guide = guideView:getInstance()
                        end
                        guide:showGuideView(mainCity.battleBtn, false, false)
                        mainCity:addChild(guide, me.GUIDEZODER)
                    end
                elseif gotype == 7 then
                    if user.familyUid > 0 then
                        jumpToAlliancecreateView()
                    else
                        showTips("请先加入联盟")
                    end
                elseif gotype == 8 then
                    local pParect = mainCity
                    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                        pParect = pWorldMap
                    end
                    if user.newBtnIDs[tostring(OpenButtonID_RELIC)] ~= nil then
                        pParect.runeSearch = runeSearch:create("rune/runeSearch.csb")
                        pParect:addChild(pParect.runeSearch, me.MAXZORDER)
                        me.showLayer(pParect.runeSearch, "bg")
                    else
                        showTips("请先建造圣殿")
                    end
                elseif gotype == 9 then
                    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                        mainCity:jumpToPromotion(ACTIVITY_ID_TURNPLATE)
                    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP and pWorldMap then
                        pWorldMap:jumpToPromotion(ACTIVITY_ID_TURNPLATE)
                    end
                end
            end )
            Text_comlete:setString(tmp.times ..  "/" .. tmp.total)
            me.setButtonDisable(Button_Go, tmp.total > tmp.times)
            if tmp.total <= tmp.times then
                me.assignWidget(Button_Go, "image_title"):setString("已完成")
            else
                me.assignWidget(Button_Go, "image_title"):setString("前往")
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(832, 376))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(0, 0))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end
function limitExchangeCell:onEnter()
    print("limitExchangeCell onEnter")
end
function limitExchangeCell:onEnterTransitionDidFinish()
    print("limitExchangeCell onEnterTransitionDidFinish")
end
function limitExchangeCell:onExit()
    print("limitExchangeCell onExit")
    me.clearTimer(self.timer)
end
function limitExchangeCell:close()
    self:removeFromParent()
end

