-- 邮件 2015-12-7

runeComposeView = class("runeComposeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
runeComposeView.__index = runeComposeView
function runeComposeView:create(...)
    local layer = runeComposeView.new(...)
    
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
        else
        print("---------------------->>>>")
    end
    return nil
end

runeComposeView.RUNE_TYPE_1 = 1         -- 符文类型1
runeComposeView.RUNE_TYPE_2 = 2         -- 符文类型2   
runeComposeView.RUNE_TYPE_3 = 3         -- 符文类型3 
runeComposeView.RUNE_TYPE_4 = 4         -- 符文类型4
runeComposeView.RUNE_TYPE_5 = 5         -- 符文类型5
function runeComposeView:ctor()
    --print("runeComposeView:ctor() ")
    --dump(user.building)
end
function runeComposeView:SeverType()
    --self.SeverNetMan = NetMan  
--   if user.Cross_Sever_Status == mCross_Sever then
--      self.SeverNetMan = netBattleMan 
--      self.CurrentSever = runeComposeView.NetBattleManSever   
--      self.SeverButton:setVisible(true) 
--      self.SeverButton:setTitleText("跨服") 
--   else
--      self.SeverNetMan = NetMan  
--      self.CurrentSever = runeComposeView.NetManSever
--      self.SeverButton:setVisible(false)   
--      if mMailCross == runeComposeView.NetBattleManSever then
--         me.tableClear(user.mailList)
--      end  
--   end 

--   if mMailCross == runeComposeView.NetManSever then
--      self.SeverButton:setTitleText("本服")
--   elseif mMailCross == runeComposeView.NetBattleManSever then -- 跨服服务器
--      self.SeverButton:setTitleText("跨服")
--   end 
end
function runeComposeView:close()
    mMailCross = self.CurrentSever
    local pview = nil
    if CUR_GAME_STATE == GAME_STATE_CITY then
        pview = mainCity 
    else
        pview = pWorldMap
    end
    if pview and pview.runeComposeView then
        pview.runeComposeView = nil
    end
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
    guideHelper.nextStepByOpt()
end
function runeComposeView:init()
    print("runeComposeView:init() ")
    
    self.runeType = 1

    --self.SeverButton = me.assignWidget(self,"Button_Cross_sever")
    --self:SeverType() -- 选择链接的服务器
--    self.RoleAllButton = me.assignWidget(self,"Button_goods_All"):setVisible(false)
--     me.registGuiClickEvent(self.RoleAllButton,function (node)
--         self.SeverNetMan:send(_MSG.getAllMailItem())
--     end)
    -- 信息
    self.table_button_rune_types = {}

    

    --符文类型1按钮
    self.button_rune_type1 = me.registGuiClickEventByName(self, "Button_rune_type1", function(node)
        self:setAllButtonState(runeComposeView.RUNE_TYPE_1)
        self:setRuneTable()
    end )
    self.button_rune_type1.r_type = runeComposeView.RUNE_TYPE_1
    table.insert(self.table_button_rune_types, self.button_rune_type1)
    local text_title1 = me.assignWidget(self.button_rune_type1, "Text_title")
    local new_str = self:getRuneTypeNameByType(runeComposeView.RUNE_TYPE_1)
    text_title1:setString(new_str)

    --符文类型2按钮
    self.button_rune_type2 = me.registGuiClickEventByName(self, "Button_rune_type2", function(node)
        self:setAllButtonState(runeComposeView.RUNE_TYPE_2)
        self:setRuneTable()
    end )
    self.button_rune_type2.r_type = runeComposeView.RUNE_TYPE_2
    table.insert(self.table_button_rune_types, self.button_rune_type2)
    local text_title2 = me.assignWidget(self.button_rune_type2, "Text_title")
    local new_str = self:getRuneTypeNameByType(runeComposeView.RUNE_TYPE_2)
    text_title2:setString(new_str)

    --符文类型3按钮
    self.button_rune_type3 = me.registGuiClickEventByName(self, "Button_rune_type3", function(node)
        print("button_rune_type_click")
        self:setAllButtonState(runeComposeView.RUNE_TYPE_3)
        self:setRuneTable()
    end )
    self.button_rune_type3.r_type = runeComposeView.RUNE_TYPE_3
    table.insert(self.table_button_rune_types, self.button_rune_type3)
    local text_title3 = me.assignWidget(self.button_rune_type3, "Text_title")
    local new_str = self:getRuneTypeNameByType(runeComposeView.RUNE_TYPE_3)
    text_title3:setString(new_str)

    --符文类型4按钮
    self.button_rune_type4 = me.registGuiClickEventByName(self, "Button_rune_type4", function(node)
        self:setAllButtonState(runeComposeView.RUNE_TYPE_4)
        self:setRuneTable()
    end )
    self.button_rune_type4.r_type = runeComposeView.RUNE_TYPE_4
    table.insert(self.table_button_rune_types, self.button_rune_type4)
    local text_title4 = me.assignWidget(self.button_rune_type4, "Text_title")
    local new_str = self:getRuneTypeNameByType(runeComposeView.RUNE_TYPE_4)
    text_title4:setString(new_str)

    --符文类型5按钮
    self.button_rune_type5 = me.registGuiClickEventByName(self, "Button_rune_type5", function(node)
        self:setAllButtonState(runeComposeView.RUNE_TYPE_5)
        self:setRuneTable()
    end )
    self.button_rune_type5.r_type = runeComposeView.RUNE_TYPE_5
    table.insert(self.table_button_rune_types, self.button_rune_type5)
    local text_title5 = me.assignWidget(self.button_rune_type5, "Text_title")
    local new_str = self:getRuneTypeNameByType(runeComposeView.RUNE_TYPE_5)
    text_title5:setString(new_str)
    
    --初始化设置按钮状态
    self:setAllButtonState(self.runeType)
    
    self:setInitRuneTable()

    self.closeBtn = me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    return true
end

--设置所有切换按钮的状态
function runeComposeView:setAllButtonState(runeType)
    for key, var in pairs(self.table_button_rune_types) do
        if var.r_type == runeType then
            self.runeType = runeType
            self:setButton(var, false)
        else
            self:setButton(var, true)
        end
    end
end

function runeComposeView:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "Text_title")
    if b then
        title:setTextColor(cc.c4b(212, 197, 180, 255))
    else
        title:setTextColor(cc.c4b(235, 228, 198, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end

function runeComposeView:getRuneTypeNameByType(r_type)
    local rune_data_name = self:getRuneDatasByType(r_type)[1].name
    --print("rune_data_name =", rune_data_name)
    --local index_start = string.find(rune_data_name, "之") + 3
    --print("index_start =", index_start)
    local new_str = string.sub(rune_data_name, 5, string.len(rune_data_name))

    --print("new_str =", new_str)
    return new_str
end

function runeComposeView:getRuneDatasByType(rune_type)
    --所有符文数据--测试
    local runeDatasAll = cfg[CfgType.RUNE_DATA]
    local rune_table = {}
    for key, var in pairs(runeDatasAll) do
        --print("-----------------table_insert")
        if var.type == rune_type then
            --print("table_insert")
            table.insert(rune_table, var)
        else
            
        end
    end
     --dump(rune_table)
    --rune_table = table.values(rune_table)
    table.sort(rune_table, function(a, b)
--        print("a.level = "..a.level)
--        print("b.level = "..b.level)
        if tonumber(a.level) == tonumber(b.level) then
            return false
        else
            return tonumber(a.level) < tonumber(b.level)
        end
    end)
    --dump(rune_table)
    return rune_table
end

function runeComposeView:setInitRuneTable()
    --print("self.runeType = "..self.runeType)
    self.runeDatas = self:getRuneDatasByType(self.runeType)
    self:initRuneTable()
end

function runeComposeView:setRuneTable()
    --print("self.runeType = "..self.runeType)
    self.runeDatas = self:getRuneDatasByType(self.runeType)
    --print("self.runeTableView ="..self.runeTableView)
--    if self.runeTableView ~= nil then
--        --print("self.runeTableView:reloadData()")
--        self.runeTableView:removeFromParent()
--        self:initRuneTable()
--    end
    self.runeTableView:reloadData()
end

function runeComposeView:initRuneTable()
    local iNum = #self.runeDatas
    print("iNum = "..iNum)
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local runeData = self.runeDatas[cell:getIdx() + 1]
        if runeData ~= nil then
            
        end
    end

    local function cellSizeForTable(table, idx)
        return 1240, 180
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local rc_cell = runeComposecell:create("runeComposecell.csb")
            rc_cell:setTag(1)
            rc_cell:setData(self.runeDatas[idx + 1])
            cell:addChild(rc_cell)
            rc_cell:setParentView(self)
        else
            local rc_cell = cell:getChildByTag(1)
            rc_cell:setData(self.runeDatas[idx + 1])
        end
        print("---------------------------> idx = ", idx)
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(1230, 536))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(5, 2)
    tableView:setDelegate()
    me.assignWidget(self, "next_bg"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.runeTableView = tableView
end

function runeComposeView:onEnter()
--    self.netListener = UserModel:registerLisener( function(msg)
--        self:onRevMsg(msg)
--    end )
    self.close_event = me.RegistCustomEvent("runeComposeView",function (evt)
        self:close()
    end)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        --self:update(msg)
    end )
    me.doLayout(self, me.winSize)
end
function runeComposeView:onExit()
    --print("runeComposeView:onExit")
    --UserModel:removeLisener(self.netListener)
    me.RemoveCustomEvent(self.close_event)
end

--function runeComposeView:onRevMsg(msg)
--    if checkMsg(msg.t, MsgCode.RUNE_COMPOUND) then
--        print("runeComposeView:onRevMsg")
--        self:setRuneTable()
--    end
--end
    