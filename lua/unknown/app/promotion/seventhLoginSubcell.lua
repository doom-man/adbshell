seventhLoginSubcell = class("seventhLoginSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
seventhLoginSubcell.__index = seventhLoginSubcell
function seventhLoginSubcell:create(...)
    local layer = seventhLoginSubcell.new(...)
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

function seventhLoginSubcell:ctor()
    print("seventhLoginSubcell:ctor()")
    self.itemDatas = {}
    self.tableView = nil
    self.statusText = {}
    self.statusText[1] = {normalPng = "huodong_anniu_ingqu_zhengchang.png", pressPng = "huodong_anniu_ingqu_anxia.png", text = ACTIVITY_TEXT_1}
    self.statusText[2] = {normalPng = "huodong_anniu_weilingqu_zhengchang.png", pressPng = "huodong_anniu_weilingqu_zhengchang.png", text = ACTIVITY_TEXT_2}
    self.statusText[3] = {normalPng = "huodong_anniu_weilingqu_zhengchang.png", pressPng = "huodong_anniu_weilingqu_zhengchang.png", text = ACTIVITY_TEXT_3}
    self.statusText[4] = {normalPng = "huodong_anniu_weikaifang_zhengchang.png", pressPng = "huodong_anniu_weikaifang_anxia.png", text = ACTIVITY_TEXT_4}
end
function seventhLoginSubcell:init()
    print("seventhLoginSubcell:init()")
    self.Panel_scroll = me.assignWidget(self,"Panel_scroll")
    self.Node_richDetail = me.assignWidget(self,"Node_richDetail")
    return true
end
function seventhLoginSubcell:initTableData()
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
            me.assignWidget(node,"Text_date"):setString("第"..me.toNum(idx+1).."天")
            me.assignWidget(node,"Button_get"):loadTextureNormal(self.statusText[me.toNum(tmp.status)].normalPng,me.localType)
            me.assignWidget(node,"Button_get"):loadTexturePressed(self.statusText[me.toNum(tmp.status)].pressPng,me.localType)
            me.assignWidget(node,"Button_get"):setEnabled(tmp.status==ACTIVITY_STATUS_1)
            me.assignWidget(node,"Button_get"):setTag(tmp.defId)
            me.registGuiClickEventByName(self, "Button_get", function(node)
                NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,me.toNum(node:getTag())))
            end )
            me.assignWidget(node,"Text_BtnGet"):setString(self.statusText[me.toNum(tmp.status)].text)
            me.assignWidget(node,"Image_cellBg"):setVisible(me.toNum(tmp.status)==ACTIVITY_STATUS_1)
            for key, var in pairs(tmp.items) do
                local itemCell = me.assignWidget(node,"Button_item"):clone()
                me.assignWidget(node,"Panel_item"):addChild(itemCell)
                itemCell:setVisible(true)
                itemCell:setPosition(cc.p(130+80*me.toNum(key-1),40))
                local cfg = cfg[CfgType.ETC][var[1]]
                me.assignWidget(itemCell, "label_num"):setString(var[2])
                me.assignWidget(itemCell, "Goods_Icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
                me.assignWidget(itemCell, "Image_quality"):loadTexture(getQuality(cfg.quality),me.localType)
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
function seventhLoginSubcell:onEnter()
    print("seventhLoginSubcell:onEnter()")
    self.itemDatas = user.activityDetail.list
    self:initTableData()
    me.doLayout(self,me.winSize)  
    local cfg = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if cfg and cfg.desc then
        local rt = mRichText:create(cfg.desc,640)
        rt:setPosition(0,0)
        rt:setAnchorPoint(cc.p(0,1))
        self.Node_richDetail:addChild(rt)
    end

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_SEVENTHLOGIN then --7日登录
                self:initTableData()
            end
        end
    end)
end
function seventhLoginSubcell:onExit()
    print("seventhLoginSubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
