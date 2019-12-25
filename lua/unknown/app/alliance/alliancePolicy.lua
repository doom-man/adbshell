alliancePolicy = class("alliancePolicy", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
alliancePolicy.__index = alliancePolicy
function alliancePolicy:create(...)
    local layer = alliancePolicy.new(...)
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
function alliancePolicy:ctor()
    print("alliancePolicy:ctor()")
end
function alliancePolicy:init()
    me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    


    self.policyData = {}
    self.dTimePolicyData = {}
    self.policyCfg = {}
    self.timerBottom = {}
    
    self.Panel_base = me.assignWidget(self,"Panel_base")
    self.Panel_table = me.assignWidget(self,"body1")
    self.tipsBtn = me.assignWidget(self,"tipsBtn")
    self.policyNumsTxt = me.assignWidget(self, "policyNumsTxt")
    me.registGuiClickEvent(self.tipsBtn, function(node)    
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        local wd = node:convertToWorldSpace(cc.p(48, -65))
        stips:initWithStr("联盟令牌通过击杀远古之龙活动BOSS获得，令牌数量上限随联盟等级提升而提升，超过上限将不再获得令牌", wd)
        me.popLayer(stips)                     
    end)

    return true
end
function alliancePolicy:update(msg)
    if checkMsg(msg.t, MsgCode.ALLIANCE_POLICY_PUBLISH) then 
        print("alliancePolicy:update(msg)!!")
        for k, v in pairs(self.timerBottom) do
            me.clearTimer(v)    
        end
        self.timerBottom = {}
        self.policyData=msg.c
        self.famliyLevel = msg.c.level
        self.famliyDegree = msg.c.degree
        local unionCfg = cfg[CfgType.FAMILY_BASE][self.famliyLevel]
        self.policyNumsTxt:setString(self.policyData.policy.."/"..unionCfg.maxPolicy)
        --self.tipsBtn:setPositionX(self.policyNumsTxt:getPositionX()+self.policyNumsTxt:getContentSize().width+30)
        self.policyData.sysTime = me.sysTime()   
        self:setTableView()     
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_POLICY_LIST) then
        self:setData(msg.c)
    end
end
function alliancePolicy:onEnter()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"alliancePolicy")
    
    
end

function alliancePolicy:setData(data)
    self.famliyLevel = data.level
    self.famliyDegree = data.degree
    local unionCfg = cfg[CfgType.FAMILY_BASE][data.level]
    self.policyNumsTxt:setString(data.policy.."/"..unionCfg.maxPolicy)
    --self.tipsBtn:setPositionX(self.policyNumsTxt:getPositionX()+self.policyNumsTxt:getContentSize().width+30)
    self:setTypeData()
    self.policyData=data
    self.policyData.sysTime = me.sysTime()
    self:setTableView()
end

function alliancePolicy:setTypeData()
    me.tableClear(self.policyCfg)
    self.policyCfg = {}
    for key, var in pairs(cfg[CfgType.FAMILY_POLICY]) do
        self.policyCfg[#self.policyCfg+1] = var
    end
end
function alliancePolicy:onEnterTransitionDidFinish()
end
function alliancePolicy:onExit()
    
    if table.nums(self.timerBottom) > 0 then
        for key, var in pairs(self.timerBottom) do
            me.clearTimer(var)
        end
    end
    UserModel:removeLisener(self.modelkey)
    print("alliancePolicy:onExit()")
end

function alliancePolicy:getCDTime(defid)
    for key, var in pairs(self.policyData.list) do
        if me.toNum(var.defId) == me.toNum(defid) then
            local offTime = var.countdown-(me.sysTime()-self.policyData.sysTime)/1000
            if offTime <= 0 then
                offTime = 0
            end
            local keepTime = var.dTime-(me.sysTime()-self.policyData.sysTime)/1000
            if keepTime <= 0 then
                keepTime = 0
            end
            return offTime, keepTime
        end
    end
    return 0
end


function alliancePolicy:setTableView()
    local function tableCellTouched(table, cell)
        local idx = cell:getIdx()
        local def = self.policyCfg[#self.policyCfg-idx]
        --self:popupDetail(def)
    end

    local function cellSizeForTable(table, idx)
        return 1146, 101 + 5
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local def = self.policyCfg[#self.policyCfg-idx]
        local iconStr = "city_buff_"..def.icon..".png"
        local btn
        if nil == cell then
            cell = cc.TableViewCell:new()
            cell:setTag(idx)
            local layer = self.Panel_base:clone():setVisible(true)
            layer:setAnchorPoint(cc.p(0, 0))
            layer:setPosition(cc.p(0, 5))
            cell:addChild(layer)
            local spr = ccui.ImageView:create(iconStr)
            cell:addChild(spr)
            spr:setTag(5555)
            spr:setAnchorPoint(cc.p(0,0.5))
            spr:setPosition(cc.p(me.assignWidget(layer,"Panel_policy_cell"):getPositionX(), me.assignWidget(layer,"Panel_policy_cell"):getPositionY()))
            btn = me.assignWidget(cell,"Button_publish")
            btn:setTag(idx)
            me.registGuiClickEvent(btn,function (node)
            
                local index = node:getTag()
                local def = self.policyCfg[#self.policyCfg-index]
                if self.famliyDegree >2 then
                    showTips("需要盟主或副盟主才能发布")
                elseif self.policyData.policy<def.cost then
                    showTips("联盟令牌不足")
                else
                    me.showMessageDialog("确定要发布<<"..def.name..">>政策吗？", function(args)
                        if args == "ok" then
                            NetMan:send(_MSG.alliancePolicyPublish(def.id))    
                        end
                    end)
                   
                end
            end)
        else
            me.clearTimer(self.timerBottom["timerBottom_index_"..cell:getTag()])
            self.timerBottom["timerBottom_index_"..cell:getTag()] = nil
            me.clearTimer(self.timerBottom["timerBottom_keep_"..cell:getTag()])
            self.timerBottom["timerBottom_keep_"..cell:getTag()] = nil

            cell:setTag(idx)
            btn = me.assignWidget(cell,"Button_publish")
            local spr = cell:getChildByTag(5555)
            spr:loadTexture(iconStr)
            btn:setTag(idx)
        end

        local tmpText_title = me.assignWidget(cell,"Text_title")
        tmpText_title:setString(def.name)
        me.assignWidget(cell,"Text_decs"):setString(def.desc)
        --me.assignWidget(cell,"Text_policy_name"):setString(def.name)
        me.assignWidget(cell, "costTxt"):setString(def.cost)

        local cdTime, keepTime = self:getCDTime(def.id)

        me.clearTimer(self.timerBottom["timerBottom_index_"..cell:getTag()])
        self.timerBottom["timerBottom_index_"..cell:getTag()] = nil
        local function showCDTime()
            if cdTime > 0 then
                me.assignWidget(cell,"Text_cd_time"):setVisible(true)
                me.assignWidget(cell,"Text_cd_time"):setString(me.formartSecTime(cdTime))
           
                if self.timerBottom["timerBottom_index_"..cell:getTag()] == nil then
                    self.timerBottom["timerBottom_index_"..cell:getTag()] = me.registTimer(-1,function ()
                        local tmpdef = self.policyCfg[#self.policyCfg-cell:getTag()]
                        local tmpTime, kTime = self:getCDTime(tmpdef.id)
                        if tmpTime > 0 then
                            me.assignWidget(cell,"Text_cd_time"):setString(me.formartSecTime(tmpTime))
                        else
                            local spr = cell:getChildByTag(5555)
                            me.Helper:normalImageView(spr)                        
                            print(" tmpdef.name = "..tmpdef.name)
                            me.clearTimer(self.timerBottom["timerBottom_index_"..cell:getTag()])
                            self.timerBottom["timerBottom_index_"..cell:getTag()] = nil
                            me.assignWidget(cell,"Text_cd_time"):setVisible(false)
                            if self.famliyLevel>=tmpdef.familyLv then
                                me.buttonState(me.assignWidget(cell,"Button_publish"), true)
                            end
                        end
                    end,1,"timerBottom_index_"..cell:getTag())
                end

                me.buttonState(me.assignWidget(cell,"Button_publish"), false)
                if self.famliyLevel<def.familyLv then
                    me.assignWidget(cell,"Text_cd_time"):setVisible(false)
                    me.assignWidget(cell,"text_title_btn"):setString("发布")
                else
                    me.assignWidget(cell,"Text_cd_time"):setVisible(true)
                    me.assignWidget(cell,"text_title_btn"):setString("已发布")
                end
                local spr = cell:getChildByTag(5555)
                --me.Helper:grayImageView(spr)
            else
                if self.policyData.policy<def.cost then
                    me.assignWidget(cell, "costTxt"):setTextColor(cc.c3b(255, 0, 0))
                else
                    me.assignWidget(cell, "costTxt"):setTextColor(cc.c3b(212, 205, 185))
                end

                local spr = cell:getChildByTag(5555)
                --me.Helper:normalImageView(spr)    
                me.assignWidget(cell,"Text_cd_time"):setVisible(false)
                me.buttonState(me.assignWidget(cell,"Button_publish"), true)
                me.assignWidget(cell,"text_title_btn"):setString("发布")
            end
        end

        me.assignWidget(cell,"Text_cd_time"):setVisible(false)
        me.assignWidget(cell,"Text_keep_time"):setVisible(false)
        me.clearTimer(self.timerBottom["timerBottom_keep_"..cell:getTag()])
        self.timerBottom["timerBottom_keep_"..cell:getTag()] = nil
        if keepTime > 0 then
            me.assignWidget(cell,"Text_keep_time"):setString('持续时间：'..me.formartSecTime(keepTime))
            if self.timerBottom["timerBottom_keep_"..cell:getTag()] == nil then
                self.timerBottom["timerBottom_keep_"..cell:getTag()] = me.registTimer(-1,function ()
                    local tmpdef = self.policyCfg[#self.policyCfg-cell:getTag()]
                    local tmpTime, kTime = self:getCDTime(tmpdef.id)
                    if kTime > 0 then
                        me.assignWidget(cell,"Text_keep_time"):setString('持续时间：'..me.formartSecTime(kTime))
                    else
                        local spr = cell:getChildByTag(5555)
                        me.Helper:normalImageView(spr)                        
                        print(" tmpdef.name = "..tmpdef.name)
                        me.clearTimer(self.timerBottom["timerBottom_keep_"..cell:getTag()])
                        self.timerBottom["timerBottom_keep_"..cell:getTag()] = nil
                        me.assignWidget(cell,"Text_keep_time"):setVisible(false)

                        if cdTime > 0 then
                            showCDTime()
                        end
                    end
                end,1,"timerBottom_keep_"..cell:getTag())
            end
            me.assignWidget(cell,"Text_keep_time"):setVisible(true)
            me.buttonState(me.assignWidget(cell,"Button_publish"), false)
        elseif cdTime > 0 then
            showCDTime()
        else
            me.buttonState(me.assignWidget(cell,"Button_publish"), true)
        end

        if self.famliyLevel<def.familyLv then
            me.buttonState(me.assignWidget(cell,"Button_publish"), false)
            me.assignWidget(cell,"text_title_btn"):setString("发布")
            me.assignWidget(cell,"Text_start_time"):setVisible(true)
            me.assignWidget(cell,"Text_start_time"):setString("(联盟"..def.familyLv.."级开启)")
        else
            me.assignWidget(cell,"Text_start_time"):setVisible(false)
        end

        return cell
    end

    function numberOfCellsInTableView(table)
        return #self.policyCfg
    end

    if self.tableView_bottom == nil then
        self.tableView_bottom = cc.TableView:create(self.Panel_table:getContentSize())
        self.tableView_bottom:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_bottom:ignoreAnchorPointForPosition(false)
        self.tableView_bottom:setAnchorPoint(cc.p(0, 0))
        self.tableView_bottom:setPosition(cc.p(0, 0))
        self.tableView_bottom:setDelegate()
        self.Panel_table:addChild( self.tableView_bottom)
        self.tableView_bottom:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_bottom:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView_bottom:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_bottom:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView_bottom:reloadData()    
end

function alliancePolicy:close()
    self:removeFromParentAndCleanup(true)  
end