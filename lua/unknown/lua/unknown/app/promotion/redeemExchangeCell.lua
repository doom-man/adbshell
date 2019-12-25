redeemExchangeCell = class("redeemExchangeCell",function(...)
    return cc.CSLoader:createNode(...)
end)
redeemExchangeCell.__index = redeemExchangeCell
function redeemExchangeCell:create(...)
    local layer = redeemExchangeCell.new(...)
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

function redeemExchangeCell:ctor()
    print("redeemExchangeCell:ctor()")
end
function redeemExchangeCell:init()
    self.Panel_touch = me.assignWidget(self,"Panel_touch")
    self.Panel_touch:setVisible(false)
    print("redeemExchangeCell:init()")
    return true
end
function redeemExchangeCell:onEnter()
    me.assignWidget(self, "Panel_item"):setVisible(false)
    self.Panel_table = me.assignWidget(self,"Panel_table")

    local Panel_richText = me.assignWidget(self,"Panel_richText")
    local rich = mRichText:create(user.activityDetail.desc,Panel_richText:getContentSize().width)
    rich:setPosition(Panel_richText:getContentSize().width/2,Panel_richText:getContentSize().height/2)
    rich:setAnchorPoint(cc.p(0.5,0.5))
    Panel_richText:addChild(rich)

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            self:setInfo()
            self:setTableView()
        end
    end)
    self:setTableView()
    self:setInfo()
end

function redeemExchangeCell:setInfo()
    me.assignWidget(self,"Text_MedelNum"):setString("我的积分 "..user.activityDetail.wuXunNm)
end

function redeemExchangeCell:setTableView()
    self.listData = user.activityDetail.list
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 782,138
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
        end
        local cfgId = cfg[CfgType.DRAGON_BOAT][self.listData[me.toNum(idx+1)].defId].itemId
        local priceData = self.listData[me.toNum(idx+1)].price
        local def = cfg[CfgType.ETC][cfgId]
        if self.listData[me.toNum(idx+1)] and def then
            me.registGuiClickEventByName(node,"Button_detail",function ()
                showPromotion(priceData[1][1],1)
            end)
            me.registGuiClickEventByName(node,"Button_detail_0",function ()
                showPromotion(def.id,1)
            end)

            me.assignWidget(node,"Image_item"):loadTexture(getQuality(def.quality),me.plistType)
            me.assignWidget(node,"Image_icon"):loadTexture(getItemIcon(priceData[1][1]),me.plistType)
            me.assignWidget(node,"Image_item_0"):loadTexture(getQuality(def.quality),me.plistType)
            me.assignWidget(node,"Image_icon_0"):loadTexture(getItemIcon(def.id),me.plistType)
            me.assignWidget(node,"Limit_num"):setString(tostring(priceData[1][2]))
            me.assignWidget(node,"text_limited"):setString("限购次数:" .. self.listData[me.toNum(idx+1)].limit)

            me.registGuiClickEventByName(node,"Button_get",function ()
                local function confirmCallback(selectNum)
                    print ("selectNum = " .. selectNum)
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, self.listData[me.toNum(idx+1)].defId, nil, selectNum))
                end
                local integralTimes = math.floor (user.activityDetail.wuXunNm / priceData[1][2])
                local leftTimes = self.listData[me.toNum(idx+1)].limit

                local minTimes = integralTimes
                if leftTimes < integralTimes then
                    minTimes = leftTimes
                end
                if integralTimes <= 0 then
                    showTips ("当前积分不足")
                    return
                end
                if leftTimes <= 0 then
                    showTips ("限购次数为0")
                    return
                end
                local selectView = selectNumberView:create("selectNumberView.csb")
                mainCity:addChild(selectView, me.MAXZORDER)
                selectView:setSliderMaxNum(math.floor(minTimes))
                local titleData = {
                    {
                        strTitle = "请选择兑换数量",
                        font = "Arail",
                        fontSize = 30,
                        hAlignment = cc.TEXT_ALIGNMENT_LEFT,
                        textColor = cc.c4b(255, 255, 255, 255)
                    },
                }
                selectView:setTitleData(titleData, 10)
                local btnTextData = {text = "确定"}
                selectView:setBtnConfirmText(btnTextData)
                selectView:registerConfirmCallback(confirmCallback)
                me.showLayer(selectView, "bg")
            end)
            self.tableOffPos = self.tableView:getContentOffset()

            -- if self.listData[me.toNum(idx+1)].limit <= 0 or priceData[1][2] > user.activityDetail.wuXunNm then --已完毕
            --     -- me.assignWidget(node,"Button_get"):setBright (false)
            --     -- me.assignWidget(node,"Button_get"):setEnabled (false)
            --     me.registGuiClickEventByName(node,"Button_get",function ()
            --         self.tableOffPos = self.tableView:getContentOffset()
            --         NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, self.listData[me.toNum(idx+1)].defId))
            --     end)
            -- elseif self.listData[me.toNum(idx+1)].limit > 0 and user.activityDetail.wuXunNm >= priceData[1][2] then --可兑换
            --     -- me.assignWidget(node,"Button_get"):setBright (true)
            --     -- me.assignWidget(node,"Button_get"):setEnabled (true)
            --     me.registGuiClickEventByName(node,"Button_get",function ()
            --         self.tableOffPos = self.tableView:getContentOffset()
            --         NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, self.listData[me.toNum(idx+1)].defId))
            --     end)
            -- end
            me.assignWidget(node,"num_bg"):setVisible(self.listData[me.toNum(idx+1)].limit ~= -1)
        end
        return cell
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(self.Panel_table:getContentSize().width,self.Panel_table:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setAnchorPoint(cc.p(0.5,0.5))
        self.tableView:setPosition(cc.p(0,0))
        self.Panel_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
    if self.tableOffPos ~= nil then
        self.Panel_touch:setVisible(true)
        self.tableView:setContentOffset(self.tableOffPos)
        me.DelayRun(function ()
            self.Panel_touch:setVisible(false)
        end,1)
    end
end

function redeemExchangeCell:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
