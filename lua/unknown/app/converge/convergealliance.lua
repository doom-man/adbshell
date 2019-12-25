-- [Comment]
-- jnmo
convergealliance = class("convergealliance", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
convergealliance.__index = convergealliance
function convergealliance:create(...)
    local layer = convergealliance.new(...)
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
function convergealliance:ctor()
    print("convergealliance ctor")
    self.mData = nil
    self.pconvergeFire = nil
    -- 军队详情
    self.pTime = nil
end
function convergealliance:init()
    print("convergealliance init")
    me.registGuiClickEventByName(self, "fixLayout", function(node)

    end )

    me.registGuiClickEventByName(self, "Button_record", function(node)
        GMan():send(_MSG.worldTeamHistory())
    end )
    return true
end
function convergealliance:setData()
    me.clearTimer(self.pTime)
    self.teamData = { }
    me.assignWidget(self, "Node_table"):removeAllChildren()
    for key, var in pairs(user.teamArmyData) do
        var.CountTime = 0
        if var.countTime > 0 then
            var.CountTime = 1
        end
        table.insert(self.teamData, var)
    end
    table.sort(self.teamData,function (a,b)
      return a.teamId > b.teamId
end)
    if table.nums(self.teamData) > 0 then
        self.pTime = me.registTimer(-1, function(dt)
            for key, var in pairs(self.teamData) do
                if var.CountTime == 1 then
                    local pTime = var.countTime
                    if pTime > 0 then
                        var.countTime = var.countTime - 1
                    else
                        dump(var)
                        var.CountTime = 0
                        GMan():send(_MSG.worldTeamInfo())
                    end
                end
            end
        end , 1)
    end   
    self:initInfoTab()
end
function convergealliance:initInfoTab()
    self.tableView = nil
    local pNum = #self.teamData
    if pNum > 0 then
        me.assignWidget(self,"converge_hint"):setVisible(false)
        me.assignWidget(self,"img_balck"):setVisible(false)
    else
       me.assignWidget(self,"converge_hint"):setVisible(true)
       me.assignWidget(self,"img_balck"):setVisible(true)
    end
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pData = self.teamData[cell:getIdx() + 1]
        self.mData = pData
        if self.mData["warType"] == 0 then -- 防御
           GMan():send(_MSG.worldTeamArmyInfo(pData["teamId"],pData["attacker"]["attackId"]))
        else
           GMan():send(_MSG.worldTeamArmyInfo(pData["teamId"],0))
        end        
    end

    local function cellSizeForTable(table, idx)
        return 1158, 205 + 5
    end

    local function tableCellAtIndex(table, idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pconvergeallianceCell = convergeallianceCell:create(self, "converge_cell")
            pconvergeallianceCell:setAnchorPoint(cc.p(0.5, 0))
            pconvergeallianceCell:setPosition(cc.p(579, 5))
            pconvergeallianceCell:setData(self.teamData[idx + 1])
            cell:addChild(pconvergeallianceCell)
        else
            local pconvergeallianceCell = me.assignWidget(cell, "converge_cell")
            pconvergeallianceCell:setData(self.teamData[idx + 1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(1158, 510))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(0, 0)
    tableView:setDelegate()
    me.assignWidget(self, "Node_table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView = tableView
end
function convergealliance:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_TEAM_DETAIL) then
        if self.pconvergeFire == nil then
            self.pconvergeFire = convergeFire:create("convergeFire.csb")
            self.pconvergeFire:setData(self,self.mData["attacker"]["attackId"],self.mData["warType"])
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:addChild(self.pconvergeFire, me.MAXZORDER)
            else
                mainCity:addChild(self.pconvergeFire, me.MAXZORDER)
            end          
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_ARMY_WAIT) then
        GMan():send(_MSG.worldTeamInfo())
        
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_ADD) then

        -- NetMan:send(_MSG.worldTeamArmyInfo(self.mData["teamId"]))
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_REJECT_ARMY) then
        -- NetMan:send(_MSG.worldTeamArmyInfo(self.mData["teamId"]))
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_RELEASE) then
        if self.pconvergeFire ~= nil then
            self.pconvergeFire:removeFromParentAndCleanup(true)
        end
        GMan():send(_MSG.worldTeamInfo())
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_HISTORY) then
        local convergeCombatRecord = convergeCombatRecord:create("convergeCombatRecord.csb")
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pWorldMap:addChild(convergeCombatRecord, me.MAXZORDER)
        else
            mainCity:addChild(convergeCombatRecord, me.MAXZORDER)
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_CREATE) then
        GMan():send(_MSG.worldTeamInfo())
    end
end
function convergealliance:onEnter()
    print("convergealliance onEnter")
    -- me.doLayout(self,me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function convergealliance:onEnterTransitionDidFinish()
    print("convergealliance onEnterTransitionDidFinish")
end
function convergealliance:onExit()
    print("convergealliance onExit")
    me.clearTimer(self.pTime)
    UserModel:removeLisener(self.modelkey)
end
function convergealliance:close()
    self:removeFromParentAndCleanup(true)
end

