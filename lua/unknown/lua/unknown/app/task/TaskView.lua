TaskView = class("TaskView", function(...)
    local arg = { ...}
    if table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    else
        return cc.CSLoader:createNode(arg[1])
    end
end )
TaskView.__index = TaskView
function TaskView:create(...)
    local layer = TaskView.new(...)
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
function TaskView:ctor(...)
    _, _, self.taskId = ...
    self.Button_cancel = me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.pTime = nil
end
function TaskView:close()
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.taskview = nil
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        pWorldMap.taskview = nil
    end
    self:removeFromParentAndCleanup(true)
end
function TaskView:init()
    self.TableView = nil
    self:setData()
    self.Button_get_goods = me.assignWidget(self, "Button_get_goods")
    return true
end
local listheight = 556
function TaskView:setData()
    local pData = user.taskList
    self.mTabData = { }
    for key, var in pairs(pData) do
        table.insert(self.mTabData, 1, var)
    end


    local flag = false
    if self.pPitchId == nil then
        self.pPitchId = 1
    else
        self.pPitchId = self.pPitchId
        if self.pPitchId > #self.mTabData then
            self.pPitchId = #self.mTabData
        end
        flag = true
    end

    local function TaskSort(pa, pb)
        if pa["sortIndex"] > pb["sortIndex"] then
            return true
        else
            return false
        end
    end
    table.sort(self.mTabData, TaskSort)
    if self.taskId then
        for key, var in ipairs(self.mTabData) do
            if var.id == self.taskId then
                self.pPitchId = key
                break
            end
        end
    end

    if table.maxn(self.mTabData) ~= 0 then
        local pOffset = cc.p(0, 0)
        if self.TableView ~= nil then
            pOffset = self.TableView:getContentOffset()
        end
        me.assignWidget(self, "tableview_node"):removeAllChildren()
        self:initTaskTable(self.mTabData)
        self:taskInfor(self.mTabData[self.pPitchId])

        if self.taskId then
            pOffset = tableView:getContentOffset()
            local size = tableView:getContentSize()
            pOffset.y = listheight -(#self.mTabData - self.pPitchId + 1) * 84 - 40
            if size.height < listheight then
                pOffset.y = listheight - size.height
            elseif pOffset.y > 0 then
                pOffset.y = 0
            end
            tableView:setContentOffset(pOffset)
        elseif flag == true then
            -- 完成一个任务后，保持左则列表不变

            local size = tableView:getContentSize()
            if self.pPitchId < 6 then
                pOffset.y = listheight -(#self.mTabData - self.pPitchId + 1) * 84
            else
                pOffset.y = pOffset.y + 84
            end

            if size.height < listheight then
                pOffset.y = listheight - size.height
            elseif pOffset.y > 0 then
                pOffset.y = 0
            end
            tableView:setContentOffset(pOffset)
        end

    else
        me.assignWidget(self, "tableview_node"):removeAllChildren()
        self.TableView = nil
        self:taskInfor(nil)
    end
end
function TaskView:taskInfor(pData)
    if pData then
        me.assignWidget(self, "Node_left"):setVisible(true)
        self.mData = pData
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity:setTaskData(self.mData)
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pWorldMap:setTaskData(self.mData)
        end
        local pConfig = pData:getDef()
        -- dump(pConfig)
        SharedDataStorageHelper():setNewTask(pConfig.id, 2)

        local task_Title_label = me.assignWidget(self, "task_Title_label")
        task_Title_label:setString(pConfig["name"])

        --   dump(pData["item"])
        local In_tilte_label = me.assignWidget(self, "In_tilte_label")
        In_tilte_label:setString(pConfig["gole"])
        In_tilte_label:setVisible(false)
        -- In_tilte_label:setPosition(cc.p(In_tilte_label:getPositionX(),In_tilte_label:getPositionY()+40))

        me.assignWidget(self, "In_tilte_label_Node"):removeAllChildren()
        local rt_Title_label = mRichText:create(pConfig["gole"])
        rt_Title_label:setAnchorPoint(cc.p(0, 0.5))
        me.assignWidget(self, "In_tilte_label_Node"):addChild(rt_Title_label)

        --         local pLayer = cc.LayerColor:create(cc.c3b(144,144,100))
        --    pLayer:setAnchorPoint(cc.p(0,0.5))
        --    pLayer:setContentSize(cc.size(rt_Title_label:getContentSize().width,40))
        --    pLayer:setPosition(cc.p(0,0))
        --    me.assignWidget(self,"In_tilte_label_Node"):addChild(pLayer)

        local task_num = me.assignWidget(self, "task_num")

        --     task_num:setPosition(cc.p(In_tilte_label:getPositionX()+rt_Title_label:getContentSize().width +10,In_tilte_label:getPositionY()))
        if rt_Title_label:getContentSize().width > 350 then
            task_num:setPosition(cc.p(me.assignWidget(self, "In_tilte_label_Node"):getPositionX(), In_tilte_label:getPositionY() -30))
        else
            task_num:setPosition(cc.p(me.assignWidget(self, "In_tilte_label_Node"):getPositionX() + rt_Title_label:getContentSize().width + 20, In_tilte_label:getPositionY()))
        end
        -- print("fffffffffffffffff"..rt_Title_label:getContentSize().width)

        --   dump(pData["item"])
        local pNumStr = ""
        --       dump(pData)
        if #pData["item"] == 1 then
            local pStr = pData["item"][1][2] .. "/" .. pData["item"][1][3]
            pNumStr = pStr
        else
            for key, var in pairs(pData["item"]) do
                local pStr = ""
                --  print("ffffffffff"..var[1])

                local pName = cfg[CfgType.ETC][var[1]]["name"]
                pStr = pName .. ":" .. var[2] .. "/" .. var[3]
                pNumStr = pNumStr .. pStr
            end
        end
        task_num:setString(pNumStr)
        --  local task_infor_concent = me.assignWidget(self,"task_infor_concent"):setVisible(false)
        --    task_infor_concent:setString("")

        me.assignWidget(self, "task_infor_concent_Node"):removeAllChildren()
        local rt_infor_concent = mRichText:create(pConfig["desc"], 740)
        rt_infor_concent:setAnchorPoint(cc.p(0, 1))
        me.assignWidget(self, "task_infor_concent_Node"):addChild(rt_infor_concent)

        me.assignWidget(self, "Button_immediately_complete"):setVisible(false)
        if pData["progress"] == 2 or pData["progress"] == 1 then
            if self.mData["id"] == 489 then
                me.assignWidget(self, "Button_GoTo_task"):setVisible(false)
                me.assignWidget(self, "Button_get_goods"):setVisible(false)
            else               
                me.assignWidget(self, "Button_GoTo_task"):setVisible(true)                
                me.assignWidget(self, "Button_get_goods"):setVisible(false)
            end
            --task_num:setTextColor(cc.c3b(168, 63, 63))
        elseif pData["progress"] == 3 then
            me.assignWidget(self, "Button_GoTo_task"):setVisible(false)
            me.assignWidget(self, "Button_get_goods"):setVisible(true)
            --task_num:setTextColor(cc.c3b(0, 225, 42))
        end
        if pData.quick > 0 then
            me.assignWidget(self, "Button_immediately_complete"):setVisible(true)
            me.assignWidget(self, "ndiamond"):setString(pData.quick)
        end
        me.registGuiClickEventByName(self, "Button_get_goods", function(node)
            NetMan:send(_MSG.completedTask(self.mData["id"]))
        end )

        local Button_GoTo_task = me.registGuiClickEventByName(self, "Button_GoTo_task", function(node)
            TaskHelper.taskJump(pData)
            self:close()
        end )
        
        me.registGuiClickEventByName(self, "Button_immediately_complete", function(node)
            NetMan:send(_MSG.completedTask(self.mData["id"], self.mData.quick))
        end )
        --   dump(pData)

        local pGoodsData = cfg[CfgType.TASK_LIST][pData["defid"]]["awardProps"]
        --  local pGoodsData = pData["awards"]
        --  dump(pGoodsData)
        --   dump(pGoodsData1)
        me.assignWidget(self, "Node_Goods"):removeAllChildren()
        if pGoodsData ~= nil then
            local i = 1
            local space = 130
            for key, var in pairs(pGoodsData) do
                local pGoodsIcon = me.assignWidget(self, "In_goods_icon"):clone()
                pGoodsIcon:loadTexture(self:getGoodsIcon(var[1]), me.plistType)
                pGoodsIcon:ignoreContentAdaptWithSize(false)
                me.resizeImage(pGoodsIcon,36,36)
                pGoodsIcon:setPosition(cc.p(space *(i - 1) * pGoodsIcon:getScale(), 0))
                pGoodsIcon:setVisible(true)
                me.assignWidget(self, "Node_Goods"):addChild(pGoodsIcon)
                local pGoodsNum = me.assignWidget(self, "In_goods_num"):clone()
                pGoodsNum:setString("×" .. Scientific(var[2]))
                pGoodsNum:setPosition(cc.p((25 + space *(i - 1)) * pGoodsIcon:getScale(), 0))
                pGoodsNum:setVisible(true)
                me.assignWidget(self, "Node_Goods"):addChild(pGoodsNum)
                i = i + 1
            end

        end
    else
        me.assignWidget(self, "Node_left"):setVisible(false)
    end

end
function TaskView:getGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end

function TaskView:RewardsTask()
    local pGoodsData = cfg[CfgType.TASK_LIST][self.mData["defid"]]["awardProps"]
    if pGoodsData ~= nil then
        if self.pTime ~= nil then
            me.clearTimer(self.pTime)
        end

        self.pReardsNum = table.maxn(pGoodsData)
        self.mGoodsData = { }
        for key, var in pairs(pGoodsData) do
            table.insert(self.mGoodsData, 1, var)
        end
        self.pIndx = 1
        self:RewardsAnimation(self.mGoodsData, self.pIndx)
        self.pIndx = self.pIndx + 1
        if self.pReardsNum > 1 then
            self.pTime = me.registTimer(-1, function(dt)
                self:RewardsAnimation(self.mGoodsData, self.pIndx)
                if self.pIndx == self.pReardsNum then
                    me.clearTimer(self.pTime)
                    self.pTime = nil
                end
                self.pIndx = self.pIndx + 1
            end , 0.5)
        end
    end
end
function TaskView:RewardsAnimation(pData, pIndx)

    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    local var = pData[pIndx]

    local pRewards = me.assignWidget(self, "rewards_bg"):clone():setVisible(true)
    me.assignWidget(self, "bg_under_In"):addChild(pRewards)


    local pRewardsIcon = me.assignWidget(pRewards, "rewards_icon")
    pRewardsIcon:loadTexture(self:getGoodsIcon(var[1]), me.plistType)
    local pRewardsNum = me.assignWidget(pRewards, "rewards_num")
    pRewardsNum:setString("×" .. Scientific(var[2]))


    local pMoveBy = cc.MoveBy:create(0.8, cc.p(0, 90))
    local pFadeOut = cc.FadeOut:create(0.8)
    local pFadeOut1 = cc.FadeOut:create(0.8)
    local pFadeOut2 = cc.FadeOut:create(0.8)
    local pSpawn = cc.Spawn:create(pMoveBy, pFadeOut)

    local callback = cc.CallFunc:create(arrive)
    pRewardsIcon:runAction(pFadeOut1)
    pRewardsNum:runAction(pFadeOut2)
    pRewards:runAction(cc.Sequence:create(pSpawn, callback))
end
-- 任务列表
function TaskView:initTaskTable(pTaskTab)
    local iNum = #pTaskTab

    local function scrollViewDidScroll(view)
        -- print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        -- print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        if self.pPitchId ~=(cell:getIdx() + 1) then
            self.pPitchId = cell:getIdx() + 1
            local pOffest = tableView:getContentOffset()
            tableView:reloadData()
            tableView:setContentOffset(pOffest)
            self:taskInfor(pTaskTab[self.pPitchId])
        end
    end

    local function cellSizeForTable(table, idx)
        return 335, 84
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local pBool = false
        -- 选中
        if (idx + 1) == self.pPitchId then
            pBool = true
        end
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pTaskCell = TaskCell:create(self, "task_cell")
            pTaskCell:setTag(23)
            pTaskCell:setTaskData(pTaskTab[idx + 1], pBool)
            cell:addChild(pTaskCell)
        else
            local pTaskCell = cell:getChildByTag(23)
            pTaskCell:setTaskData(pTaskTab[idx + 1], pBool)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end
    tableView = cc.TableView:create(cc.size(335, listheight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(0, 3)
    tableView:setDelegate()
    me.assignWidget(self, "tableview_node"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.TableView = tableView
end
function TaskView:onEnter()
    print("TaskView:onEnter() ")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:updata(msg)
    end )
    guideHelper.nextStepByOpt(false, self.Button_get_goods)
end
function TaskView:updata(msg)
    if checkMsg(msg.t, MsgCode.TASK_COMPLETE) then
        -- 完成任务
        self:setData()
    end
end
function TaskView:onExit()
    print("TaskView:onExit() ")
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity.taskview = nil
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        pWorldMap.taskview = nil
    end
    me.clearTimer(self.pTime)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end

