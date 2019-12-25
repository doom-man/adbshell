kingdomView_policy = class("kingdomView_policy", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
kingdomView_policy.__index = kingdomView_policy
function kingdomView_policy:create(...)
    local layer = kingdomView_policy.new(...)
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
function kingdomView_policy:ctor()
    print("kingdomView_policy:ctor()")
end
function kingdomView_policy:init()
    self.policyData = nil
    self.dTimePolicyData = {}
    self.policyCfg = {}
    self.timerTop = {}
    self.timerBottom = {}
    self.Panel_table = me.assignWidget(self,"Panel_table")
    self.Text_nonePolicy = me.assignWidget(self,"Text_nonePolicy")
    self.Text_policyTotal = me.assignWidget(self,"Text_policyTotal")
    self.Panel_table_up = me.assignWidget(self,"Panel_table_up")
    self.Node_cell = me.assignWidget(self,"Node_cell")
    return true
end
function kingdomView_policy:update(msg)
    if checkMsg(msg.t, MsgCode.KINGDOM_NATIONAL_POLICY_PUBLISH) then -- 国政刷新
        print("kingdomView_policy:update(msg)!!")
        if table.nums(self.timerTop) > 0 then
            for key, var in pairs(self.timerTop) do
                me.clearTimer(var)
            end
        end
    
        if table.nums(self.timerBottom) > 0 then
            for key, var in pairs(self.timerBottom) do
                me.clearTimer(var)
            end
        end 
        self.timerTop = {}
        self.timerBottom = {}
        self:setTypeData(kingdomMainView.type_nationalPolicy)
        self:setInfoData()
        self:setTableView_Top()
        self:setTableView_Bottom()        
    end
end
function kingdomView_policy:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_policy")
    self:setInfoData()
    self:setTableView_Top()
    self:setTableView_Bottom()
end
function kingdomView_policy:setInfoData()
    if self.policyData.list then
        self.Text_policyTotal:setString(self.policyData.crystal)
    end

    me.tableClear(self.dTimePolicyData)
    self.dTimePolicyData = {}
    for key, var in pairs(self.policyData.list) do
        if var.dTime > 0 then
            self.dTimePolicyData[#self.dTimePolicyData+1] = var
        end
    end
    self.Text_nonePolicy:setVisible(#self.dTimePolicyData <= 0)
    self.Panel_table_up:setVisible(#self.dTimePolicyData>0)
end
function kingdomView_policy:setTypeData(type)
    me.tableClear(self.policyCfg)
    self.policyCfg = {}
    if type == kingdomMainView.type_nationalPolicy then --国政
        self.policyData = user.kingdom_policyData_national
        for key, var in pairs(cfg[CfgType.KINGDOM_POLICY]) do
            if var.type == 1 then 
                self.policyCfg[#self.policyCfg+1] = var
            end
        end
    elseif type == kingdomMainView.type_militaryPolicy then --军政
        self.policyData = user.kingdom_policyData_military
        for key, var in pairs(cfg[CfgType.KINGDOM_POLICY]) do
            if var.type == 2 then 
                self.policyCfg[#self.policyCfg+1] = var
            end
        end
    end 
end
function kingdomView_policy:onEnterTransitionDidFinish()
end
function kingdomView_policy:onExit()
    if table.nums(self.timerTop) > 0 then
        for key, var in pairs(self.timerTop) do
            me.clearTimer(var)
        end
    end
    
    if table.nums(self.timerBottom) > 0 then
        for key, var in pairs(self.timerBottom) do
            me.clearTimer(var)
        end
    end
    UserModel:removeLisener(self.modelkey)
    print("kingdomView_policy:onExit()")
end

function kingdomView_policy:getCDTime(defid)
    for key, var in pairs(self.policyData.list) do
        if me.toNum(var.defId) == me.toNum(defid) then
            local offTime = var.countdown-(me.sysTime()-self.policyData.sysTime)/1000
            if offTime <= 0 then
                offTime = 0
            end
            return offTime
        end
    end
    return nil
end

function kingdomView_policy:popupDetail(def)
    if self.detail == nil then
        self.detail =  me.createNode("kingdomView_policy_detail.csb")
        pWorldMap:addChild(self.detail,me.MAXZORDER)    
    end
    me.doLayout(me.assignWidget(self.detail,"fixLayout"),me.winSize)  
    local iconStr = "guoce_tb_"..def.icon..".png"
    me.assignWidget(self.detail,"Image_icon"):loadTexture(iconStr)
    me.assignWidget(self.detail,"Text_Title"):setString(def.name)
    me.assignWidget(self.detail,"Text_desc"):setString(def.desc)
    me.assignWidget(self.detail,"Text_desc_cd"):setString(me.formartSecTime(def.coldtime))
    local buffData = cfg[CfgType.CITY_BUFF][def.buffId]
    if buffData and me.isValidStr(buffData.duration) and me.toNum(buffData.duration) > 0 then
        me.assignWidget(self.detail,"Text_desc_ud"):setString(me.formartSecTime(buffData.duration))
    else    
        me.assignWidget(self.detail,"Text_desc_ud"):setString("即时")
    end
    me.registGuiClickEvent(me.assignWidget(self.detail,"close"),function ()
        self.detail:removeFromParent()
        self.detail = nil
    end)
    local officers = me.split(def.office,",")
    local tmpOfficers = ""
    for key, var in pairs(officers) do
        local officerDef = cfg[CfgType.KINGDOM_OFFICER][me.toNum(var)]
        if key < #officers then
            tmpOfficers = tmpOfficers..officerDef.name..","
        else
            tmpOfficers = tmpOfficers..officerDef.name
        end
    end
    me.assignWidget(self.detail,"Text_desc_officer"):setString(tmpOfficers)
end

function kingdomView_policy:setTableView_Bottom()
    local function tableCellTouched(table, cell)
        local idx = cell:getIdx()
        local def = self.policyCfg[#self.policyCfg-idx]
        self:popupDetail(def)
    end

    local function cellSizeForTable(table, idx)
        return 960, 110
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local item =  me.createNode("Layer_KingdomPolicy_Item.csb")
        local def = self.policyCfg[#self.policyCfg-idx]
        local iconStr = "guoce_tb_"..def.icon..".png"
        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:setTag(idx)
            local layer = me.assignWidget(item, "Panel_base"):clone()
            cell:addChild(layer)
            local spr = ccui.ImageView:create(iconStr)
            cell:addChild(spr)
            spr:setTag(5555)
            spr:setAnchorPoint(cc.p(0,0.5))
            spr:setPosition(cc.p(me.assignWidget(layer,"Panel_policy_cell"):getPositionX()+5, me.assignWidget(layer,"Panel_policy_cell"):getPositionY()))
            local btn = me.assignWidget(cell,"Button_publish")
            btn:setTag(idx)
            me.registGuiClickEvent(btn,function (node)
                local index = node:getTag()
                local def = self.policyCfg[#self.policyCfg-index]
                local officers = me.split(def.office,",")
                local canPublich = false
                local tips = "需要官职："
                for key, var in pairs(officers) do
                    tips = tips..cfg[CfgType.KINGDOM_OFFICER][me.toNum(var)].name.." "
                    if user.kingdom_OfficerData.myDegree == me.toNum(var) then
                        canPublich = true
                        break
                    end
                end
                if canPublich == false then
                    showTips(tips)
                else
                    --[[
                    me.showMessageDialog("确定要发布<<"..def.name..">>政策吗？", function(args)
                        if args == "ok" then
                            if def.id == 10 then
                                local tmp = kingdomView_policy_sendname:create("kingdomView_policy_sendname.csb")
                                tmp:setDefData(def.id)
                                pWorldMap.kmv:addChild(tmp)
                                me.showLayer(tmp,"fixLayout")
                            else
                                NetMan:send(_MSG.kingdom_policy_publish(def.id))    
                            end
                        end
                    end)
                    ]]
                    local tmp = kingdomView_policy_publish:create("kingdomView_policy_publish.csb")
                    tmp:setDefData(def)
                    pWorldMap.kmv:addChild(tmp)
                    me.showLayer(tmp,"bg")
                end
            end)
        else
            cell:setTag(idx)
            local btn = me.assignWidget(cell,"Button_publish")
            local spr = cell:getChildByTag(5555)
            spr:loadTexture(iconStr)
            btn:setTag(idx)
        end

        me.assignWidget(cell, "Image_1"):setOpacity(50)

        local officers = me.split(def.office,",")
        local tmpOfficers = def.name.."(需要:"
        for key, var in pairs(officers) do
            local officerDef = cfg[CfgType.KINGDOM_OFFICER][me.toNum(var)]
            if key < #officers then
                tmpOfficers = tmpOfficers..officerDef.name..","
            else
                tmpOfficers = tmpOfficers..officerDef.name
            end
        end
        tmpOfficers = tmpOfficers..")"
        local tmpText_title = me.assignWidget(cell,"Text_title")
        tmpText_title:setString(tmpOfficers)
        me.assignWidget(cell,"Text_decs"):setString(def.desc)
        me.assignWidget(cell,"Text_policy_name"):setString(def.name)
        
        local cdTime = self:getCDTime(def.id)
        if cdTime > 0 then
            me.assignWidget(cell,"Text_cd_time"):setPositionX(tmpText_title:getContentSize().width+35)
            me.assignWidget(cell,"Text_cd_time"):setString(me.formartSecTime(cdTime))
            me.clearTimer(self.timerBottom["timerBottom_index_"..cell:getTag()])
            self.timerBottom["timerBottom_index_"..cell:getTag()] = nil
            if self.timerBottom["timerBottom_index_"..cell:getTag()] == nil then
                self.timerBottom["timerBottom_index_"..cell:getTag()] = me.registTimer(-1,function ()
                    local tmpdef = self.policyCfg[#self.policyCfg-cell:getTag()]
                    local tmpTime = self:getCDTime(tmpdef.id)
                    if tmpTime > 0 then
                        me.assignWidget(cell,"Text_cd_time"):setString(me.formartSecTime(tmpTime))
                    else
                        local spr = cell:getChildByTag(5555)
                        me.Helper:normalImageView(spr)                        
                        print(" tmpdef.name = "..tmpdef.name)
                        me.clearTimer(self.timerBottom["timerBottom_index_"..cell:getTag()])
                        self.timerBottom["timerBottom_index_"..cell:getTag()] = nil
                        me.assignWidget(cell,"Text_cd_time"):setVisible(false)
                        me.buttonState(me.assignWidget(cell,"Button_publish"), true)
                    end
                end,1,"timerBottom_index_"..cell:getTag())
            end
            me.assignWidget(cell,"Text_cd_time"):setVisible(true)
            me.buttonState(me.assignWidget(cell,"Button_publish"), false)
            local spr = cell:getChildByTag(5555)
            me.Helper:grayImageView(spr)
        else
            local spr = cell:getChildByTag(5555)
            me.Helper:normalImageView(spr)    
            me.assignWidget(cell,"Text_cd_time"):setVisible(false)
            me.buttonState(me.assignWidget(cell,"Button_publish"), true)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.policyCfg
    end

    if self.tableView_bottom == nil then
        self.tableView_bottom = cc.TableView:create(cc.size(self.Panel_table:getContentSize().width,self.Panel_table:getContentSize().height))
        self.tableView_bottom:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_bottom:setPosition(0, 0)
        self.tableView_bottom:setDelegate()
        self.Panel_table:addChild( self.tableView_bottom)
        self.tableView_bottom:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_bottom:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView_bottom:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_bottom:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_bottom:reloadData()    
end

function kingdomView_policy:setTableView_Top()
    local function tableCellTouched(table, cell)
    end

    local function cellSizeForTable(table, idx)
        return 125, 145
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local item =  me.createNode("Layer_KingdomPolicy_Icon.csb")
        local tmpData = self.dTimePolicyData[idx+1]
        local tmpDef = cfg[CfgType.KINGDOM_POLICY][tmpData.defId]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local layer = me.assignWidget(item, "Panel_policy_cell"):clone()
            layer:setSwallowTouches(false)
            cell:addChild(layer)
        end
        cell:setTag(idx)
        if tmpData.dTime > 0 then
            local tmpTime = self.dTimePolicyData[cell:getTag()+1].dTime-(me.sysTime()-self.policyData.sysTime)/1000
            me.assignWidget(cell,"Text_policy_time"):setString(me.formartSecTime(tmpTime))
            me.clearTimer(self.timerTop["timerTop_index_"..cell:getTag()])
            self.timerTop["timerTop_index_"..cell:getTag()] = nil
            if self.timerTop["timerTop_index_"..cell:getTag()] == nil then
                self.timerTop["timerTop_index_"..cell:getTag()] = me.registTimer(-1,function ()
                    local offTime = self.dTimePolicyData[cell:getTag()+1].dTime-(me.sysTime()-self.policyData.sysTime)/1000
                    if offTime > 0 then
                        me.assignWidget(cell,"Text_policy_time"):setVisible(true)
                        me.assignWidget(cell,"Text_policy_time"):setString(me.formartSecTime(offTime))
                    else
                        me.clearTimer(self.timerTop["timerTop_index_"..cell:getTag()])
                        self.timerTop["timerTop_index_"..cell:getTag()] = nil
                        self.tableView_top:reloadData()
                    end
                end,1,"timerTop_index_"..cell:getTag())
            end
        else
            me.assignWidget(cell,"Text_policy_time"):setString(me.formartSecTime(0))
        end
        me.assignWidget(cell,"Text_policy_name"):setString(tmpDef.name)
        local iconStr = "guoce_tb_"..tmpDef.icon..".png"
        me.assignWidget(cell,"Image_icon"):loadTexture(iconStr)
        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.dTimePolicyData
    end

    if self.tableView_top == nil then
        self.tableView_top = cc.TableView:create(cc.size(self.Panel_table_up:getContentSize().width,self.Panel_table_up:getContentSize().height))
        self.tableView_top:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView_top:setPosition(0, 0)
        self.tableView_top:setDelegate()
        self.Panel_table_up:addChild( self.tableView_top)
        self.tableView_top:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_top:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView_top:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_top:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_top:reloadData()
end