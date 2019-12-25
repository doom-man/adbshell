-- [Comment]
-- jnmo
archManualTechLevel = class("archManualTechLevel", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
archManualTechLevel.__index = archManualTechLevel
function archManualTechLevel:create(...)
    local layer = archManualTechLevel.new(...)
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
function archManualTechLevel:ctor()
    print("archManualTechLevel ctor")
end
function archManualTechLevel:init()
    print("archManualTechLevel init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_ChooseAll", function(node)
        for key, var in pairs(self.tmp) do
            var.choose = false
            var.choose_num = 0
        end   
        local addexp = 0
        local techdata = cfg[CfgType.BOOK_TECH][self.data.techId]
        for key, var in pairs(self.tmp) do
             var.choose_num =  math.max( 0, math.min(techdata.exp -  self.data.exp - addexp , var.count ))
             if var.choose_num > 0 then
                  var.choose = true
                  addexp = addexp + var.choose_num
             end
             if techdata.exp <= self.data.exp + addexp then
                 break
             end
        end
        self:upateUI()
        self.tableView:reloadData()        
    end )
    me.registGuiClickEventByName(self, "Button_LevelUp", function(node)
        me.showMessageDialog("是否确认消耗考古材料来获取进度？",function (evt)
           if evt == "ok" then
                    local blist = {}
                    for key, var in pairs(self.tmp) do
                        if var.choose == true and var.choose_num > 0  then
                              local m = {}
                              m.bid = var.defid
                              m.num = var.choose_num
                              table.insert(blist,m)
                        end
                    end      
                    self.Text_Num:setString("选择数量:0")  
                    NetMan:send(_MSG.book_tech_levelup(self.data.techId,blist))
           end
        end)
    end )    
    self.evt = me.RegistCustomEvent("archManualTechLevel_update_choose", function(evt)
        self:upateUI()
    end )
    self.Text_Num = me.assignWidget(self,"Text_Num")
    return true
end
function archManualTechLevel:upateUI()
    local bookdata = cfg[CfgType.BOOK_TECH_MENU][self.data.id]
    local techdata = cfg[CfgType.BOOK_TECH][self.data.techId]
    local Text_process = me.assignWidget(self, "Text_process")
    local tech_loadbar = me.assignWidget(self, "tech_loadbar")
    local tech_loadbar_add = me.assignWidget(self, "tech_loadbar_add")    
    local addexp = 0
    for key, var in pairs(self.tmp) do
        if var.choose == true then
            addexp = addexp + var.choose_num
        end
    end
    Text_process:setString(self.data.exp + addexp .. "/" .. techdata.exp)
    tech_loadbar_add:setPercent(100 * (self.data.exp  + addexp) / techdata.exp)
    self.Text_Num:setString("选择数量:"..addexp)
end
function archManualTechLevel:initWithData(data)
    self.data = data
    local bookdata = cfg[CfgType.BOOK_TECH_MENU][data.id]
    local techdata = cfg[CfgType.BOOK_TECH][data.techId]
    local Text_Title = me.assignWidget(self, "Text_Title")
    local Image_tech_icon = me.assignWidget(self, "Image_tech_icon")
    local Text_tech_name = me.assignWidget(self, "Text_tech_name")
    local Text_tech_pro = me.assignWidget(self, "Text_tech_pro")
    local tech_loadbar = me.assignWidget(self, "tech_loadbar")
    local Text_process = me.assignWidget(self, "Text_process")
    local Text_tech_pro_next = me.assignWidget(self, "Text_tech_pro_next")
    local tech_loadbar_add = me.assignWidget(self, "tech_loadbar_add") 
    tech_loadbar_add:setPercent(0)
    Text_Title:setString(techdata.name.."Lv."..techdata.level)
    Text_tech_name:setString(techdata.desc)
    Image_tech_icon:loadTexture(techIcon(techdata.icon), me.localType)
    Text_tech_pro:setString("当前等级效果：" ..(techdata.beforetxt or ""))
    Text_tech_pro_next:setString("下一等级效果：" ..(techdata.successtxt or ""))
    Text_process:setString(data.exp .. "/" .. techdata.exp)
    tech_loadbar:setPercent(100 * data.exp / techdata.exp)
    self.tmp = { }
    for key, var in pairs(user.bookPkg) do
        local def = var:getDef()
        print(techdata.useType)
        local _, q = string.find(techdata.useType, tostring(def.bookskillType) or "0")
        if q and q > 0 then
            var.choose = false
            var.choose_num = 0
            table.insert(self.tmp, var)
        end
    end
    table.sort(self.tmp, function(a, b)
        return a:getDef().quality < b:getDef().quality
    end )
    local width_list = 768
    local height_list = 250
    local m = 6
    self.iNum = math.floor((#self.tmp) / m)
    if #self.tmp % m ~= 0 then
        self.iNum = self.iNum + 1
    end
    local function scrollViewDidScroll(view)

    end
    local function scrollViewDidZoom(view)

    end
    local function tableCellTouched(table, cell)

    end
    local function cellSizeForTable(table, idx)
        return width_list, 130
    end
    local function tableCellAtIndex(table, idx)
        local pDataNum = #self.tmp
        local pCellNum = #self.tmp
        pCellNum = math.max(pCellNum, 18)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, m do
                local pTag = idx * m + var
                local roleitem = archDebris:create("archDebris.csb")
                roleitem:setTag(var)
                local iSize = roleitem:getContentSize()
                --local spw = math.floor((width_list - iSize.width * m) /(m + 1))
                roleitem:setAnchorPoint(cc.p(0.5, 0.5))
                roleitem:setPosition(67 + (var - 1) * 125, 65)
                if pTag <(pCellNum + 1) then
                    if pTag <(pDataNum + 1) then
                        roleitem:setVisible(true)
                        roleitem:setManualLevelUpData(self.tmp[pTag], data, self.tmp)
                    else
                        roleitem:setVisible(false)
                    end
                else
                    roleitem:setVisible(false)
                end
                cell:addChild(roleitem)
                roleitem:setScale(0.81)
            end
        else
            for var = 1, m do
                local pTag = idx * m + var
                local roleitem = cell:getChildByTag(var)
                if pTag <(pCellNum + 1) then
                    if pTag <(pDataNum + 1) then
                        roleitem:setVisible(true)
                        roleitem:setManualLevelUpData(self.tmp[pTag], data, self.tmp)
                    else
                        roleitem:setVisible(false)
                    end
                else
                    roleitem:setVisible(false)
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return self.iNum
    end
    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(width_list, height_list))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(cc.p(0, 0))
        self.tableView:setAnchorPoint(cc.p(0, 0))
        self.tableView:setDelegate()
        me.assignWidget(self, "list"):addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
        self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end
function archManualTechLevel:onEnter()
    print("archManualTechLevel onEnter")
    me.doLayout(self, me.winSize)
     self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_BOOK_TECH_UP_LEVL) then
              self:initWithData(self.data)
            if msg.c.upLevel then
                local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
                pCityCommon:CommonSpecific(ALL_COMMON_LEVELUP_COMPLETE)
                pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2+50))
                me.runningScene():addChild(pCityCommon, me.ANIMATION)
            end
        end
    end )
end
function archManualTechLevel:onEnterTransitionDidFinish()
    print("archManualTechLevel onEnterTransitionDidFinish")
end
function archManualTechLevel:onExit()
    print("archManualTechLevel onExit")
    me.RemoveCustomEvent(self.evt)
    UserModel:removeLisener(self.modelkey) 
end
function archManualTechLevel:close()
    self:removeFromParent()
end
