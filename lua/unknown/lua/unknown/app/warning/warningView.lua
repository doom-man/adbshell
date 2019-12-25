warningView = class("warningView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
warningView.__index = warningView
function warningView:create(...)
    local layer = warningView.new(...)
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

function warningView:ctor()
    print("warningView:ctor()")
    self.listener = nil
    self.tableView = nil
    self.isIncity = false
    self.timers = { }
end
function warningView:init()
    print("warningView:init()")
    self.Image_frame = me.assignWidget(self, "Image_frame")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end
function warningView:setInCityStatus(isIn)
    self.isIncity = isIn
end
function warningView:jumpToAttacker(pos_)
    print("jumpToAttacker : posx = " .. pos_.x .. "  posy = " .. pos_.y)
    if self.isIncity and canJumpWorldMap() then
        mainCity:cloudClose( function(node)
            print("跳转外城")

            local loadlayer = loadWorldMap:create("loadScene.csb")
            if user.Cross_Sever_Status == mCross_Sever_Out then
                loadlayer = loadWorldMap:create("loadScene.csb")
            elseif user.Cross_Sever_Status == mCross_Sever then
                loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
            end
            loadlayer:setWarningPoint(pos_)
            me.runScene(loadlayer)
        end )
        me.DelayRun( function()
            self:close()
        end )
    else
        print("跳转所在目标")
        if pWorldMap then
            pWorldMap:lookMapAt(pos_.x, pos_.y, 0)
        end
        me.DelayRun( function()
            self:close()
        end )
    end
end

--[[
    local alertUid=msg.c.uid --警示的uid
    local name=msg.c.name --攻击者名字
    local family=msg.c.family --攻击者帮会 有可能为空
    local time=msg.c.time --发起时间
    local ox=msg.c.ox --源x
    local oy=msg.c.oy --源y
    local x=msg.c.x --目标x
    local y=msg.c.y --目标y
    local status=msg.c.status --状态 50为侦察 88为被集火 其它为进攻
    local city=msg.c.city --不是城市时为空
    local countTime=msg.c.countTime --到达时间
]]
function warningView:initList()
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
        self.timers = { }
    end

    local function setItemInfo(item_, data_)
        local title = TID_WARNING_YOU
        local desc = ""
        local titlePng = nil
        local familyName = ""
        local titleCol = nil
        if data_.city ~= nil then
            title = title .. TID_WARNING_CASTLE
            desc = TID_WARNING_CASTLE
        else
            title = title .. TID_WARNING_GROUND .. "(" .. data_.x .. "," .. data_.y .. ")"

            desc = TID_WARNING_GROUND
        end
        if me.toNum(data_.status) == 50 then
            -- 侦查
            titleCol = COLOR_WHITE
            titlePng = "zhanbao_icon_zhencha.png"
            title = title .. TID_WARNING_BE .. TID_WARNING_DETECT
            desc = TID_WARNING_DETECT .. TID_WARNING_YOU .. desc
        elseif me.toNum(data_.status) == 88 then
            -- 被集火
            titlePng = "jihuo_tubiao_jilv_jingong.png"
            title = title .. TID_WARNING_BE .. TID_WARNING_TEAM_ATTACK
            desc = TID_WARNING_TEAM_ATTACK .. TID_WARNING_YOU .. desc
            titleCol = me.convert3Color_("972a11")
        elseif me.toNum(data_.status) == 2000 then
            -- 挖矿被攻击
            titlePng = "zhanbao_icon_jinggong.png"
            title = "你的秘宝被攻击"
            desc = "攻击你的遗迹秘宝(第"..data_.x.."页"..data_.y.."号)"
            titleCol = me.convert3Color_("ff0000")
        else
            -- 进攻
            titlePng = "zhanbao_icon_jinggong.png"
            title = title .. TID_WARNING_BE .. TID_WARNING_ATTACK
            desc = TID_WARNING_ATTACK .. TID_WARNING_YOU .. desc
            titleCol = me.convert3Color_("972a11")
        end

        me.assignWidget(item_, "Image_state"):loadTexture(titlePng, me.localType)
        me.assignWidget(item_, "Text_state"):setString(title)
        me.registGuiClickEventByName(item_, "Text_state", function(args)
            dump(data_)
            if me.toNum(data_.status) ~= 2000 then
                self:jumpToAttacker(cc.p(data_.x, data_.y))
            else
                local tmpView = digoreDetail:create("digore/digoreDetail.csb")
                me.runningScene():addChild(tmpView, me.MAXZORDER)
                me.showLayer(tmpView, "fixLayout")
                NetMan:send(_MSG.digoreDetail(data_.ox,(data_.x-1)*5+data_.y-1))
            end
        end )
        me.assignWidget(item_, "Text_state"):setTextColor(titleCol)
        me.assignWidget(item_, "Text_star_time"):setString(me.GetSecTime(data_.time))
        if data_.family then
            familyName = "(" .. data_.family .. ")"
        end
        if me.toNum(data_.status) == 2000 then
            me.assignWidget(item_, "Text_name"):setString(data_.shorName ..familyName..data_.name)
            me.assignWidget(item_, "Text_location"):setString("")
        else
            me.assignWidget(item_, "Text_name"):setString(familyName .. data_.name)
            me.assignWidget(item_, "Text_location"):setString("(" .. data_.ox .. "," .. data_.oy .. ")")
        end
        me.assignWidget(item_, "Text_desc"):setString(desc)

        local t =(data_.countTime -(me.sysTime() - data_.curTimeIndex)) / 1000
        me.assignWidget(item_, "Text_arrive_time"):setString(TID_WARNING_ARRIVE .. me.formartSecTime(t))
        self.timers[#self.timers + 1] = me.registTimer(-1, function()
            t =(data_.countTime -(me.sysTime() - data_.curTimeIndex)) / 1000
            if math.floor(t) >= 0 and item_ and me.assignWidget(item_, "Text_arrive_time") then
                me.assignWidget(item_, "Text_arrive_time"):setString(TID_WARNING_ARRIVE .. me.formartSecTime(t))
            end
        end , 1)
    end

    local function tableCellTouched(table, cell)
        local index = cell:getIdx() + 1
        local tmp = user.warningList[index]
        if tmp then
            if me.toNum(tmp.status) ~= 2000 then
                self:jumpToAttacker(cc.p(tmp.ox, tmp.oy))
            else
                local tmpView = digoreDetail:create("digore/digoreDetail.csb")
                me.runningScene():addChild(tmpView, me.MAXZORDER)
                me.showLayer(tmpView, "fixLayout")
                NetMan:send(_MSG.digoreDetail(tmp.ox,(tmp.x-1)*5+tmp.y-1))
            end
        end
    end

    local function cellSizeForTable(table, idx)
        return 1146, 180
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = user.warningList[idx + 1]
        if data then
            if nil == cell then
                cell = cc.TableViewCell:new()
                local item = cc.CSLoader:createNode("warningItem.csb")
                cell:addChild(item)
                setItemInfo(item, data)
            else
                local item = cc.CSLoader:createNode("warningItem.csb")
                setItemInfo(item, data)
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return #user.warningList
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(1146, 550))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(15, 20)
        self.tableView:setDelegate()
        self.Image_frame:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    else
        self.tableView:setContentSize(cc.size(1146, 550))
        self.tableView:setPosition(15, 20)
    end
    self.tableView:reloadData()
end
function warningView:onEnter()
    print("warningView:onEnter()")
    me.doLayout(self, me.winSize)
    self.listener = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) or checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
            self:initList()
        end
    end )
    self:initList()
end
function warningView:onEnterTransitionDidFinish()
    print("warningView:onEnterTransitionDidFinish()")
end
function warningView:onExit()
    print("warningView:onExit()")
end
function warningView:close()
    if self.isIncity then
        if mainCity then
            me.assignWidget(mainCity.Button_warning, "ArmatureNode_Jishi"):setVisible(false)
        end
    elseif pWorldMap then
        me.assignWidget(pWorldMap.Button_warning, "ArmatureNode_Jishi"):setVisible(false)
    end
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end
    self.timers = nil
    print("warningView:close()")
    UserModel:removeLisener(self.listener)
    self:removeFromParentAndCleanup(true)
end
