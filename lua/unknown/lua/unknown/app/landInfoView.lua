-- 联盟要塞 
landInfoView = class("landInfoView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1], arg[2])
        return pCell:clone():setVisible(true)
    end
end )
landInfoView.__index = landInfoView
function landInfoView:create(...)
    local layer = landInfoView.new(...)
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
function landInfoView:ctor()
    self.keyTb = { }
    self.myLand = { }
    self.updatedTb = nil
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
end
function landInfoView:close()
    self:removeFromParentAndCleanup(true)
end
function landInfoView:init()
    print("landInfoView init")
    self.selectAllBtn = me.assignWidget(self, "selectAllBtn")
    self.cancelAllBtn = me.assignWidget(self, "cancelAllBtn")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_MAP_DROP_POINT) then
            for key, var in pairs(self.myLand) do
                for k, v in pairs(var) do
                    if v.x == msg.c.x and v.y == msg.c.y then
                        v.pstatus = msg.c.pstatus
                        v.time = msg.c.time
                        break
                    end
                end
            end
            if self.listData then
                for key, var in pairs(self.listData) do
                    if var.x == msg.c.x and var.y == msg.c.y then
                        var.pstatus = msg.c.pstatus
                        var.time = msg.c.time
                        break

                    end
                end
            end
            local ofp = self.landTableView:getContentOffset()
            self.landTableView:reloadData()
            self.landTableView:setContentOffset(ofp)
        end
    end )
    return true
end
function landInfoView:initWithData(data)
    for key, var in pairs(data) do
        local landData = { }
        landData = clone(getMapConfigData(var))
        landData.x, landData.y = var.x, var.y
        landData.plandType = landData.landlv
        if var.pstatus then
            landData.pstatus = var.pstatus
            landData.time = var.time
        end
        local landTypeName, _ = string.gsub(landData.name, "★", "")
        local landType = landData.landlv
        if var.type == 1 then
            landData.plandType = 0
            landType = 0
            landData.name = var.name    
            if  #self.keyTb <1 then                
                table.insert(self.keyTb, 1, 0)
            elseif self.keyTb[1] ~= 0 then
                table.insert(self.keyTb, 1, 0)
            end       
        else
            landType = landData.landlv
        end
        if self.myLand[landType] == nil then
            self.myLand[landType] = { }
            if var.type ~= 1 then
                table.insert(self.keyTb, landType)
            end
        end
        table.insert(self.myLand[landType], landData)
    end
    local function comp(a, b)
        return a < b
    end
    table.sort(self.keyTb, comp)
    self.updatedTb = clone(self.myLand)
    self.listData = { }
    for key, var in pairs(self.updatedTb) do
        for key1, var1 in pairs(var) do
            table.insert(self.listData, var1)
        end
    end
    self:initMyLandTable()
    self:initTotalTable(true)
end
function landInfoView:initMyLandTable(tb)
    me.clearTimersBygName("pceell")

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
    end

    local function cellSizeForTable(table, idx)
        return 813, 49
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        -- local cell = table:dequeueCell()
        local landCell
        local cell
        if nil == cell then
            cell = cc.TableViewCell:new()
            landCell = me.assignWidget(self, "landCell"):clone()
            self:setCellData(landCell, self.listData[idx + 1], 1)
            landCell:setPosition(cc.p(0, 0))
            landCell:setTag(666)
            cell.coX, cell.coY = self.listData[idx + 1].x, self.listData[idx + 1].y
            local pButtonPoint = me.assignWidget(landCell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
            me.registGuiClickEvent(pButtonPoint, function(node)
                local pIndx = me.toNum(node:getTag())
                local pData = self.listData[pIndx]
                local pX = pData["x"]
                local pY = pData["y"]
                self:setLookMap(cc.p(pX, pY))
            end )
            pButtonPoint:setSwallowTouches(true)
            cell:addChild(landCell)
        else
            landCell = me.assignWidget(cell, "landCell")
            self:setCellData(landCell, self.listData[idx + 1], 1)
            cell.coX, cell.coY = self.listData[idx + 1].x, self.listData[idx + 1].y
            local pButtonPoint = me.assignWidget(landCell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
        end
        local land_distance = me.assignWidget(landCell,"land_distance")
        local pData = self.listData[idx + 1]
        land_distance:setString( math.floor(cc.pGetDistance( cc.p(pData.x,pData.y), user.majorCityCrood )) )
        local Button_X = me.registGuiClickEventByName(landCell, "Button_X", function(node)
            if pData.pstatus == nil then
                if pData.plandType and pData.plandType == 0 then
                    me.showMessageDialog("该土地上有据点，放弃土地会将据点也拆除，是否确认放弃土地？", function(evt)
                        if evt == "ok" then
                            GMan():send(_MSG.dropPoint(pData.x, pData.y))
                        end
                    end )
                else
                    GMan():send(_MSG.dropPoint(pData.x, pData.y))
                end
            end
        end )
        local Button_Cancel = me.registGuiClickEventByName(landCell, "Button_Cancel", function(node)
            local pData = self.listData[idx + 1]

            GMan():send(_MSG.cancelDropPoint(pData.x, pData.y))
        end )
        local pData = self.listData[idx + 1]
        Button_Cancel:setVisible(false)
        me.clearTimer(landCell.timer)
        if pData.pstatus then
            -- 1 fangqi 2 baohu
            Button_X:setVisible(false)
            if pData.pstatus == 1 then
                Button_Cancel:setVisible(true)
            end
            local time_txt = me.assignWidget(Button_Cancel, "Text_XTime")

            time_txt:setString(me.formartSecTime(pData.time))
            landCell.timer = me.registTimer(pData.time, function(dt, b)
                if pData.time == nil then
                    me.clearTimer(landCell.timer)
                else
                    pData.time = pData.time - 1
                    time_txt:setString(me.formartSecTime(pData.time))
                    if b then
                        time_txt:setString("0:00:00")
                    end
                end
            end , 1, "pceell")
        else
            Button_X:setVisible(true)
        end
        me.assignWidget(landCell, "img_mask"):setVisible(idx % 2 == 0)

        return cell
    end

    local function numberOfCellsInTableView(table)
        return #self.listData
    end
    if self.landTableView == nil then
        self.landTableView = cc.TableView:create(cc.size(813, 538))
        self.landTableView:setTag(1)
        self.landTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.landTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.landTableView:setPosition(cc.p(0, 0))
        self.landTableView:setDelegate()
        me.assignWidget(self, "Node_lands"):addChild(self.landTableView)
        self.landTableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.landTableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.landTableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.landTableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.landTableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.landTableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.landTableView:reloadData()
end
function landInfoView:setParent(pParent)
    self.mParent = pParent
end
function landInfoView:setLookMap(pos)
    local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
    me.showMessageDialog(pStr, function(args)
        if args == "ok" then
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:RankSkipPoint(pos)
                if self.mParent and self.mParent.close then
                    self.mParent:close()
                elseif self.mParent then
                    self.mParent:removeFromParentAndCleanup(true)
                end
            elseif canJumpWorldMap() then
                mainCity:cloudClose( function(node)
                    print("跳转外城")
                   local loadlayer = loadWorldMap:create("loadScene.csb")
                    if user.Cross_Sever_Status == mCross_Sever_Out then
                        loadlayer = loadWorldMap:create("loadScene.csb")
                    elseif user.Cross_Sever_Status == mCross_Sever then
                        loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
                    end
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                end )
                me.DelayRun( function()
                    -- self:close()
                    self.mParent:removeFromParentAndCleanup(true)
                end )
            end
        end
    end )
end
function landInfoView:initTotalTable(selectBool)
    local num = #self.keyTb
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 350, 65
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        local totalCell
        if nil == cell then
            cell = cc.TableViewCell:new()
            totalCell = me.assignWidget(self, "totalCell"):clone()
            self:setCellData(totalCell, self.keyTb[idx + 1], 2, selectBool)
            totalCell:setTag(123)
            totalCell:setPosition(cc.p(0, 0))
            cell:addChild(totalCell)
        else
            totalCell = me.assignWidget(cell, "totalCell")
            self:setCellData(totalCell, self.keyTb[idx + 1], 2, selectBool)
        end
        me.assignWidget(totalCell, "img_mask"):setVisible(idx % 2 == 0)

        return cell
    end

    local function numberOfCellsInTableView(table)
        return num
    end
    self.totalTable = cc.TableView:create(cc.size(350, 460))
    self.totalTable:setTag(2)
    self.totalTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.totalTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.totalTable:setPosition(cc.p(0, 0))
    self.totalTable:setDelegate()
    me.assignWidget(self, "node_table"):addChild(self.totalTable)

    self.totalTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.totalTable:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.totalTable:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.totalTable:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.totalTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.totalTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.totalTable:reloadData()

    self.selectAllBtn:setVisible(false)
    self.cancelAllBtn:setVisible(true)

    me.registGuiClickEvent(self.selectAllBtn, function(node)
        me.assignWidget(self, "node_table"):removeChildByTag(2)
        self.totalTable = nil
        self:initTotalTable(true)
        self.updatedTb = clone(self.myLand)
        self.listData = { }
        for key, var in pairs(self.updatedTb) do
            for key1, var1 in pairs(var) do
                table.insert(self.listData, var1)
            end
        end
        self.landTableView:reloadData()
        self.selectAllBtn:setVisible(false)
        self.cancelAllBtn:setVisible(true)
    end )

    me.registGuiClickEvent(self.cancelAllBtn, function(node)
        me.assignWidget(self, "node_table"):removeChildByTag(2)
        self.totalTable = nil
        self:initTotalTable(false)
        self.updatedTb = { }
        self.listData = { }
        self.landTableView:reloadData()
        self.selectAllBtn:setVisible(true)
        self.cancelAllBtn:setVisible(false)
    end )
end

function landInfoView:onEnter()
    me.doLayout(self, me.winSize)
end
function landInfoView:onExit()
    me.clearTimersBygName("pceell")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end

function landInfoView:setCellData(cellWidget, data, tbType, selectBool)
    if tbType == 1 then
        cellWidget.coX, cellWidget.coY = data.x, data.y
        me.assignWidget(cellWidget, "landName"):setString(data.name)
        me.assignWidget(cellWidget, "landLv"):setString("LV" .. data.landlv)
        me.assignWidget(cellWidget, "landCo"):setString("(" .. data.x .. "," .. data.y .. ")")
    elseif tbType == 2 then
        if data == 0 then
            me.assignWidget(cellWidget, "totalName"):setString("据点")
        else
            me.assignWidget(cellWidget, "totalName"):setString("领地LV" .. data)
        end
        me.assignWidget(cellWidget, "num"):setString(#self.myLand[data])
        local checkBox = me.assignWidget(cellWidget, "checkBox"):setSelected(selectBool)
        me.registGuiClickEvent(checkBox, function(node)
            if not checkBox:isSelected() then
                self.updatedTb[data] = nil

                self.listData = { }
                for key, var in pairs(self.updatedTb) do
                    for key1, var1 in pairs(var) do
                        table.insert(self.listData, var1)
                    end
                end
                self.landTableView:reloadData()
            else
                self.updatedTb[data] = clone(self.myLand[data])

                self.listData = { }
                for key, var in pairs(self.updatedTb) do
                    for key1, var1 in pairs(var) do
                        table.insert(self.listData, var1)
                    end
                end
                self.landTableView:reloadData()
            end
        end )
    end
    cellWidget:setSwallowTouches(false)
    cellWidget:setVisible(true)
end

