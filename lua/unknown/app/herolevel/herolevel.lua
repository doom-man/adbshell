herolevel = class("herolevel", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
herolevel.__index = herolevel

function herolevel:create(...)
    local layer = herolevel.new(...)
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

function herolevel:ctor()
    print("herolevel:ctor()")
    self.tableView = nil
    self.listData = {}
    self.selCellId = nil --当前所在什么子界面
    self.turnplateNode = nil --大转盘的子界面
    self.taskGuideIndex = nil --跳转到固定id
end
function herolevel:init()
    self.Image_left = me.assignWidget(self, "Image_left")
    self.Panel_right = me.assignWidget(self, "Panel_right")
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)
    self.evetn_guide = me.RegistCustomEvent("run_search_guide",function (evt)
        guideHelper.nextStepByOpt(false,self.closeBtn)
    end)
    return true
end

function herolevel:revInitList(msg)
    me.tableClear(self.listData)
    self.listData= msg.c.list

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 272, 80
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "table_cell"):clone()
            node:setPosition(cc.p(0, 0))
            cell:addChild(node)
        else
            node =me.assignWidget(cell, "table_cell")
        end
        node:setVisible(true)

        local tmp = self.listData[me.toNum(idx+1)]
        if tmp then
            local ImageView_cell_select = me.assignWidget(node, "ImageView_cell_select")
            local pIcon = me.assignWidget(node,"icon")
            pIcon:loadTexture("herolevel_left_icon1.png", me.localType)
            pIcon:ignoreContentAdaptWithSize(true)
            pIcon:setScale(0.7)
            local ImageView_new = me.assignWidget(node, "ImageView_new")
            local nameTxt = me.assignWidget(node,"nameTxt")
            nameTxt:setString(tmp.name)
            nameTxt:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  

            if self.selCellId == me.toNum(tmp.id) then
                ImageView_cell_select:setVisible(true)
                nameTxt:setTextColor(cc.c3b(0xff, 0xff, 0xff))
            else
                ImageView_cell_select:setVisible(false)
                nameTxt:setTextColor(cc.c3b(0xd7, 0xd2, 0xc8))
            end        
        else
            node:setVisible(false)
        end
        return cell
    end

    local function tableCellTouched(table, cell)
        local data = self.listData[cell:getIdx()+1]
        if self.selCellId == data.id then
            return
        end
        self:setSelectTableCell(data.id)

        --NetMan:send(_MSG.Rune_search_right_data(me.toNum(data.id)))
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(272, 592))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setPosition(cc.p(0 + 5, 0))
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        self.Image_left:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function herolevel:setSelectTableCell(msgId_)
    local function getCellByid(id_)
        for key, var in pairs(self.listData) do
            if me.toNum(var.id) == me.toNum(id_) then
                local cell = self.tableView:cellAtIndex(me.toNum(key)-1)
                return cell
            end
        end
    end

    if self.selCellId ~= nil and self.selCellId ~= msgId_ then
       local lastCell = getCellByid(self.selCellId)
       if lastCell then
           local ImageView = me.assignWidget(lastCell, "ImageView_cell_select")
           ImageView:setVisible(false)
           local nameTxt = me.assignWidget(lastCell,"nameTxt")
           nameTxt:setTextColor(cc.c3b(0xd7, 0xd2, 0xc8))
       end
    end

    self.selCellId = msgId_
    local lastCell = getCellByid(self.selCellId)
    if lastCell then
        local ImageView =me.assignWidget(lastCell, "ImageView_cell_select")
        ImageView:setVisible(true)
        local nameTxt = me.assignWidget(lastCell,"nameTxt")
        nameTxt:setTextColor(cc.c3b(0xff, 0xff, 0xff))
    end
end

function herolevel:removePanel_right()
    for key, var in pairs(self.Panel_right:getChildren()) do
        var:removeFromParentAndCleanup(true)
    end
end

function herolevel:revInitDetail(msg)
    if msg.c.id == nil then
        print("msg.c.activityId == nil !!!")
        return
    end
    self:setSelectTableCell(msg.c.id)

    if self.rightNode==nil then
        self.Panel_right:removeAllChildren()
        self.rightNode = herolevelRight:create("herolevel/herolevelRight_1.csb")
        self.Panel_right:addChild(self.rightNode)
    end
    self.recvDetailData = msg.c
    --self.rightNode:setData(msg.c, self:getItem(78), self:getItem(79))
end


function herolevel:onEnter()
    print("herolevel:onEnter()")

    --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)
    end)
    
    me.DelayRun(function ()
        NetMan:send(_MSG.HeroLevel_indexdata())
    end)
    self:revInitList({c={list={{name='征服之旅',id=1}}}})
    self:revInitDetail({c={id=1}})
    self.close_event = me.RegistCustomEvent("herolevel",function (evt)
        self:close()
    end)

    if user.herolevelCfg==nil then   --解析配置
        local cfgLib = cfg[CfgType.HEROLEVEL_BASE]
        local parseSave = {}
        local function parseHeroLevelCFG()
            local i=0
            for k, v in pairs(cfgLib) do
                if parseSave[v.level]==nil then
                    parseSave[v.level]={}
                end
                parseSave[v.level][v.posi]=v
                i=i+1
                if i%200==0 then
                    coroutine.yield() 
                end
            end
            user.herolevelCfg=parseSave
            me.Scheduler:unscheduleScriptEntry(self.schid)    
            self.schid = nil
        end
        self.cthread = coroutine.create(parseHeroLevelCFG)
        if self.schid then
            me.Scheduler:unscheduleScriptEntry(self.schid)    
            self.schid = nil
        end
        self.schid = me.coroStart(self.cthread)
    end

    me.doLayout(self,me.winSize)
end

function herolevel:update(msg)
    if checkMsg(msg.t, MsgCode.RUNE_SEARCH_LEFT_LIST) then
        self:revInitList(msg)
    elseif checkMsg(msg.t, MsgCode.RUNE_SEARCH_RIGHT_INIT) then
        self:revInitDetail(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_HEROLEVEL_INDEXDATA) then
        disWaitLayer()
        self.rightNode:setData(msg.c)
    end
end
function herolevel:onExit()
    me.RemoveCustomEvent(self.close_event)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
    print("herolevel:onExit()")
end
function herolevel:close()
    print("herolevel:close()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    self:removeFromParentAndCleanup(true)
    
end

