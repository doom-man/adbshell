rechargeSubcell = class("rechargeSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
rechargeSubcell.__index = rechargeSubcell
--充值返利
function rechargeSubcell:create(...)
    local layer = rechargeSubcell.new(...)
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

function rechargeSubcell:ctor()
    print("rechargeSubcell:ctor()")
    self.itemDatas = {}
    self.tableView = nil
    self.statusText = {}
    self.statusText[1] = {normalPng = "huodong_anniu_ingqu_zhengchang.png", pressPng = "huodong_anniu_ingqu_anxia.png", text = ACTIVITY_TEXT_1}
    self.statusText[2] = {normalPng = "huodong_anniu_weilingqu_zhengchang.png", pressPng = "huodong_anniu_weilingqu_zhengchang.png", text = ACTIVITY_TEXT_2}
    self.statusText[3] = {normalPng = "huodong_anniu_weikaifang_zhengchang.png", pressPng = "huodong_anniu_weikaifang_anxia.png", text = ACTIVITY_TEXT_6}
end
function rechargeSubcell:init()
    print("rechargeSubcell:init()")
    self.Panel_scroll = me.assignWidget(self,"Panel_scroll")
    self.Text_time = me.assignWidget(self,"Text_time")
    self.Node_richDetail = me.assignWidget(self,"Node_richDetail")
    return true
end
function rechargeSubcell:initTableData()
    self.itemDatas = user.activityDetail.list
--    dump(self.itemDatas)
    local function numberOfCellsInTableView(table)
        return #self.itemDatas
    end

    local function cellSizeForTable(table, idx)
        return 750, 80
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "table_cell"):clone()
            cell:addChild(node)
            node:setPosition(cc.p(0,0))
            node:setVisible(true)
        else
            node =me.assignWidget(cell, "table_cell")
        end

        local tmp = self.itemDatas[me.toNum(idx+1)]
        if tmp then
            me.assignWidget(node,"Text_recharge_1"):setString("累计充值:"..tmp.price) --累计
            me.assignWidget(node,"Text_recharge_2"):setString("还需:"..tmp.money) --还需
            me.assignWidget(node,"Button_get"):loadTextureNormal(self.statusText[me.toNum(tmp.status)].normalPng,me.localType)
            me.assignWidget(node,"Button_get"):loadTexturePressed(self.statusText[me.toNum(tmp.status)].pressPng,me.localType)
            me.assignWidget(node,"Button_get"):setTag(tmp.defId)
            me.assignWidget(node,"Button_get"):setEnabled(tmp.status==ACTIVITY_STATUS_1 or tmp.status==ACTIVITY_STATUS_3)
            me.registGuiClickEventByName(node, "Button_get", function(node)             
                local tmpDefId = me.toNum(node:getTag())
                local tmpStatus = nil
                for key, var in pairs(self.itemDatas) do
                    if me.toNum(var.defId) == tmpDefId then
                        tmpStatus = var.status
                        dump(var)
                    end
                end
                if tmpStatus == ACTIVITY_STATUS_3 then
                    if mainCity.promotionView then
                        mainCity.promotionView:close()
                    end
                    TaskHelper.jumToPay()
                elseif tmpStatus == ACTIVITY_STATUS_1 then
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,tmpDefId))
                end
            end )
            me.assignWidget(node,"Image_cellBg"):setVisible(tmp.status == ACTIVITY_STATUS_1)
            me.assignWidget(node,"Text_BtnGet"):setString(self.statusText[me.toNum(tmp.status)].text)
            me.assignWidget(node,"Panel_2"):removeAllChildren()
            for key, var in pairs(tmp.items) do
                local itemCell = me.assignWidget(node,"Button_item"):clone()               
                itemCell:setVisible(true)
                itemCell:setName(idx+1)
                itemCell:setTag(key)
                itemCell:setPosition(cc.p(160+80*me.toNum(key-1),40))
                local cfg = cfg[CfgType.ETC][var[1]]
                me.assignWidget(itemCell, "label_num"):setString(var[2])
                me.assignWidget(itemCell, "Goods_Icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
                me.assignWidget(itemCell, "Image_quality"):loadTexture(getQuality(cfg.quality),me.localType)              
                me.registGuiClickEvent(itemCell, function(node)          
                    local pTag = me.toNum(node:getTag())
                    local pIdx = me.toNum(node:getName())  
                    local pTmp = self.itemDatas[pIdx]
                    local pData = pTmp.items[pTag]                         
                    local defId =pData[1]
                    local pNum = pData[2]
                    showPromotion(defId,pNum)
                end )
                 itemCell:setSwallowTouches(false)
                me.assignWidget(node,"Panel_2"):addChild(itemCell)
            end
        end
        return cell
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(750,305))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(0, 0)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        self.Panel_scroll:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()    
end
function rechargeSubcell:onEnter()
    print("rechargeSubcell:onEnter()")
    me.doLayout(self,me.winSize)  
    self.Text_time:setString(user.activityDetail.startTime.." - "..user.activityDetail.closeTime)
    self:initTableData()

    local cfg = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if cfg and cfg.desc then
        local rt = mRichText:create(cfg.desc,640)
        rt:setPosition(0,0)
        rt:setAnchorPoint(cc.p(0,1))
        self.Node_richDetail:addChild(rt)
    end


    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_RECHARGE then --充值返利
                self:initTableData()
            end
        end
    end)
end
function rechargeSubcell:onExit()
    print("rechargeSubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
