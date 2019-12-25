achievementView = class("achievementView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )

achievementView.__index = achievementView
function achievementView:create(...)
    local layer = achievementView.new(...)
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
ECHIEVEMENT_FIGHT = 1
ECHIEVEMENT_BUILD = 2
ECHIEVEMENT_COMPREHENSIVE = 3 
ECHIEVEMENT_ALLIANCE = 4
function achievementView:ctor()
end
function achievementView:init()
    print("achievementView init")
    -- 注册点击事件
    self.Panel_table = me.assignWidget(self,"Panel_table")
    self.Text_finish = me.assignWidget(self,"Text_finish")
    self.Panel_detail = me.assignWidget(self,"Panel_detail")
    self.Button_score = me.assignWidget(self,"Button_score")
    me.registGuiClickEvent(self.Button_score,function (node)
        NetMan:send(_MSG.rankList(13))           
    end)
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end)
    me.registGuiClickEvent(self.Panel_detail,function (node)
        self.Panel_detail:setVisible(false)
    end)
       
        if self.btns == nil then
        self.btns = {}
        for var = 1, 4 do
        self.btns[var] = me.assignWidget(self,"bs_type"..var)
        self.btns[var]:setTag(var)
        end        
        self.zOrder = self.btns[#self.btns]:getLocalZOrder() 
    end
    for key, var in pairs(self.btns) do
        me.registGuiClickEvent(var, function (node)
            self:setBtnClicked(node)
        end)
    end    
    self:setBtnClicked(self.btns[1])
    return true
end
function achievementView:setBtnClicked(node)
    for key, var in pairs(self.btns) do
        if me.toNum(node:getTag()) == me.toNum(var:getTag()) then
            me.setButtonDisable(var,false)
            var:setLocalZOrder(self.zOrder+100)          
        else
            me.setButtonDisable(var,true)
            var:setLocalZOrder(self.zOrder)
        end
    end
    self.echievementType = node:getTag()
    self:setTableView()
end
function achievementView:sortTableData()
    -- status:0（已领取） 1（未达成） 2（已达成可领取）
    me.tableClear(self.alist)
    self.alist = {}
    local tableCom = {}
    local tableUnCom = {}
    local tableFinish = {}
    for key, var in pairs(user.AchievementData.list) do
        if tonumber( cfg[CfgType.ACHIEVEMENT][var.id].type ) == tonumber( self.echievementType ) then
            if var.status == 0 then
                table.insert(tableFinish,var)
            elseif var.status == 1 then
                table.insert(tableUnCom,var)
            elseif var.status == 2 then
                table.insert(tableCom,var)
            end
        end
    end
    local function tableSortById(a,b)
        if me.toNum(a.id) < me.toNum(b.id) then
            return true
        end
        return false
    end
    table.sort(tableCom,tableSortById)
    table.sort(tableUnCom,tableSortById)
    table.sort(tableFinish,tableSortById)

    for key, var in pairs(tableCom) do
        table.insert(self.alist,var)
    end
    for key, var in pairs(tableUnCom) do
        table.insert(self.alist,var)
    end
    for key, var in pairs(tableFinish) do
        table.insert(self.alist,var)
    end
end
function achievementView:setTableView()
    self:sortTableData()
    self.Text_finish:setString(user.AchievementData.com.."/"..user.AchievementData.total)
    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        local av = nil
--        local spImage = nil 
        local icon = nil
        local tmp = self.alist[idx+1]
        local tmpcfg = cfg[CfgType.ACHIEVEMENT][tmp.id]
        if nil == cell then
            cell = cc.TableViewCell:new()
            av = cc.CSLoader:createNode("globalItems/Layer_Achievement_Item.csb")
            av:setTag(6699)
            av:setPosition(cc.p(0, 0 + 5))
            cell:addChild(av)
--            spImage = me.createSprite(getAchievementIcon(tmpcfg.icon))
--            spImage:setAnchorPoint(cc.p(0.5,0.5))
--            spImage:setPosition(cc.p(0,0))
--            spImage:setContentSize(cc.size(96,96))
--            me.assignWidget(av,"Node_sp"):addChild(spImage)
            icon = me.assignWidget(cell,"icon")
            icon:loadTexture(getAchievementIcon(tmpcfg.icon),me.localType)
        else
              av = cell:getChildByTag(6699)
--            local c = me.assignWidget(av,"Node_sp"):getChildren()
--            spImage = c[1]
--            me.setSpriteTexture(spImage, getAchievementIcon(tmpcfg.icon))
--            spImage:setContentSize(cc.size(96,96))
            icon = me.assignWidget(av,"icon")
            icon:loadTexture(getAchievementIcon(tmpcfg.icon),me.localType)
        end   
        local Button_get = me.assignWidget(av,"Button_get")
        Button_get:setTag(idx+1)
        Button_get:setVisible(me.toNum(tmp.status) ~= 0)
        local image_title = me.assignWidget(Button_get, "image_title")
        image_title:ignoreContentAdaptWithSize(true)
        me.assignWidget(av,"img_drawn"):setVisible(me.toNum(tmp.status) == 0)
        me.assignWidget(av,"Text_title"):setString(tmpcfg.name)
        me.assignWidget(av,"Text_describe"):setString(tmpcfg.descr)
        me.assignWidget(av,"Text_progress"):setVisible(me.toNum(tmp.status) ~= 0)
        me.assignWidget(av,"Text_progress"):setString(tmp.value.."/"..Scientific(tmp.gole))
        me.assignWidget(av,"icon_num"):setString(Scientific(tmp.gole))
        if me.toNum(tmp.status) == 0 then --已领取
            me.Helper:grayImageView(icon)
        elseif me.toNum(tmp.status) == 2 then --已达成
            me.Helper:normalImageView(icon)
            Button_get:setEnabled(true)
            image_title:loadTexture("button_title_lingqu.png", me.localType)
        elseif me.toNum(tmp.status) == 1 then --未达成
            me.Helper:normalImageView(icon)
            Button_get:setEnabled(false)
            image_title:loadTexture("button_title_weidacheng.png", me.localType)
        end
        me.registGuiClickEvent(me.assignWidget(av,"Button_get"),function (node)
            local tmp = self.alist[node:getTag()]
            NetMan:send(_MSG.achievenment_get(tmp.id))
        end)
        me.assignWidget(av,"Node_rewards"):removeAllChildren()
        local arward = me.split(tmpcfg.awards, ",")
        local width_rewards = 0
        local spw = 10
        for key, var in pairs(arward) do            
            local iconSize = cc.size(30, 30)
            local s = me.split(var,":")
            local image = ccui.ImageView:create()
            image:setTag(tmp.id+key*100000)
            image:setAnchorPoint(cc.p(0,0.5))
            image:loadTexture(getItemIcon(s[1]), me.localType)   
            image:ignoreContentAdaptWithSize(false)
            image:setContentSize(iconSize)
            image:setPosition(cc.p(width_rewards ,0))
            width_rewards = width_rewards + iconSize.width 
            local txt = ccui.Text:create("x"..s[2], "", 24)
            me.assignWidget(av,"Node_rewards"):addChild(image)
            txt:setAnchorPoint(cc.p(0,0.5))
            txt:setFontSize(18)
            txt:setTextColor(cc.c3b(0xf0, 0xc0, 0x2e))
            txt:setPosition(cc.p(width_rewards, 0))
            width_rewards = width_rewards + txt:getContentSize().width + spw
            me.assignWidget(av,"Node_rewards"):addChild(txt)
            me.registGuiClickEvent(image, function (node)
                local idx = node:getTag()  
                local id = idx%100000
                local tKey = math.floor(idx/100000)
                local tCfg = cfg[CfgType.ACHIEVEMENT][id]
                local tW = me.split(tCfg.awards,",")
                local tmp1 = tW[tKey]
                local tmp2 = me.split(tmp1,":")
                showPromotion(me.toNum(tmp2[1]), me.toNum(tmp2[2]))
            end)
        end
        return cell
    end

    function cellSizeForTable(table, idx)
        return 843, 143 + 5
    end

    function numberOfCellsInTableView(table)
        return #self.alist
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(self.Panel_table:getContentSize().width,self.Panel_table:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(0, 0)
        self.tableView:setDelegate()
        self.Panel_table:addChild( self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end

function achievementView:updateMsg(msg)
    if checkMsg(msg.t, MsgCode.MSG_ACHIEVENMENT_INIT)then
        self:setTableView()
    end
end

function achievementView:close()
    self:removeFromParentAndCleanup(true)
end

function achievementView:onEnter()
    print("achievementView onEnter")
    me.doLayout(self, me.winSize)
    -- 成就UI红点显示
    self.cjRedPointListener = me.RegistCustomEvent("Achievenment_Redpoint", handler(self, self.updateAchievenmentRedPoint))
    self:updateAchievenmentRedPoint()

    self.modelkey = UserModel:registerLisener( function(msg)
        self:updateMsg(msg)
    end )
end

-- 成就UI红点显示
function achievementView:updateAchievenmentRedPoint(evt)
    for var = 1, 4 do
        me.assignWidget(self.btns[var], "redpoint"):setVisible(false)
    end   
    for id, v in pairs(user.Achievenment_Redpoint) do
        me.assignWidget(self.btns[id], "redpoint"):setVisible(true)
    end
end

function achievementView:onExit()
    me.RemoveCustomEvent(self.cjRedPointListener)
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    if mainCity and mainCity.av then
         mainCity.av = nil
    end
    if pWorldMap and pWorldMap.av then
        pWorldMap.av = nil
    end
    print("achievementView onExit")    
end
