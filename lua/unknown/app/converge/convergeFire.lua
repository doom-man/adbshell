-- [Comment]
-- jnmo
convergeFire = class("convergeFire", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
convergeFire.__index = convergeFire
function convergeFire:create(...)
    local layer = convergeFire.new(...)
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
convergeFire.TABLEHEIGHT = 118 + 5
function convergeFire:ctor()
    print("convergeFire ctor")
    self.pTime = nil
end
function convergeFire:init()
    print("convergeFire init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    --    for var = 1 ,3 do
    --        local p = 100
    --        if var == 2 then
    --            p = 100
    --        elseif var == 3 then
    --            p = 100
    --        end
    --        p = p  + 80
    --        table.insert(self.TableHeight,p)
    --    end

    return true
end
function convergeFire:setData(pParent, attackId, warType)
    me.clearTimer(self.pTime)
    self.mData = user.teamArmyQueueData
    self.mParent = pParent
    me.clearTimer(self.pTime)
    self.attackId = attackId or 0
    self.warType = warType or 1
    dump(self.mData)
    local pFamilyName = me.assignWidget(self, "up_team_name")
    local pPeopleNum = me.assignWidget(self, "up_pople_num")
    local pCityIconbg = me.assignWidget(self, "Image_11")
    local pNameStr =self.mData.camp.."(" .. self.mData.family .. ")" .. self.mData.leader
    local pPeopleStr = self.mData.playerNum .. "/" .. self.mData.maxPlayerNum
    local pCityIconbgStr = "jihuo_xiangqing_zheijing_zuo.png"

    if self.mData.status == TEAM_WAIT or self.mData.status == TEAM_RUN then
        pCityIconbgStr = "jihuo_xiangqing_zheijing_zuo.png"
    else
        pCityIconbgStr = "jihuo_xiangqing_zheijing_lan.png"
    end
    pFamilyName:setString(pNameStr)
    pPeopleNum:setString(pPeopleStr)
    local pArmyLabel = "部队 ："
    if self.warType == 0 then
        pArmyLabel = "援助部队 ："
    end
    local pArmyNum = me.assignWidget(self, "up_army_num")
    pArmyNum:setString(pArmyLabel .. self.mData.soliderNum .. "/" .. self.mData.maxSoliderNum)
  
    local pCenter = me.assignWidget(self, "n_l_city_icon")
    if self.mData.ConergeType == 0 then
       local pCenterIcon = cfg[CfgType.BUILDING][self.mData.centerId].icon
       pCenter:loadTexture("m" .. pCenterIcon .. ".png", me.plistType)
       pCenter:setScale(1.0)
    elseif self.mData.ConergeType == 2 then
       pCenter:setScale(1.0)
       pCenter:ignoreContentAdaptWithSize(true)
       pCenter:loadTexture("dragon.png", me.plistType)
    else
       pCenter:loadTexture("wz.png", me.plistType)
       pCenter:setScale(0.5)
    end
    local pGoalName = me.assignWidget(self, "n_l_name")
    pGoalName:setString(self.mData.CaptainName)

    local pGoalPoint = me.assignWidget(self, "u_l_point")
    pGoalPoint:setString("(" .. self.mData.x .. "," .. self.mData.y .. ")")
    me.registGuiClickEventByName(self,"u_l_point",function (node)
        LookMap(cc.p(self.mData.x,self.mData.y),"convergeFire","convergeView","allianceview")
    end)

    local pButtonDismiss = me.registGuiClickEventByName(self, "Button_5", function(node)
        GMan():send(_MSG.worldTeamArmyRelease(self.mData.teamId))
    end )
    local pButtonaid = me.registGuiClickEventByName(self, "Button_aid", function(node)
        self.convergeAid = convergeAid:create("Node_convergeAid.csb")
        self.convergeAid:setPoint(cc.p(self.mData.x, self.mData.y), self.mData.soliderNum, self.mData.maxSoliderNum)
        self.convergeAid:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pWorldMap:addChild(self.convergeAid, me.MAXZORDER)
        else
            mainCity:addChild(self.convergeAid, me.MAXZORDER)
        end
    end )
    self.LeaderBool = false
    if self.mData.status == TEAM_RUN or self.mData.status == TEAM_DEFENS then
        -- 新军状态
        self.LeaderBool = false
        self:setButton(pButtonDismiss, false)
    else
        if user.name == self.mData.leader then
            self.LeaderBool = true
            self:setButton(pButtonDismiss, true)
        else
            self.LeaderBool = false
            self:setButton(pButtonDismiss, false)
        end
    end

    self.mLeaderName = self.mData.leader
    self.TableHeight = { }
    self.LaunchTab = { }
    self.mArmyData = { }
    local pAddBool = true
    local pOpenBool = true
    self.pPeopleNum = 0
    for key, var in pairs(user.teamArmyInfoData) do
        local pArmyNum = math.ceil((#var.army) / 2)
        local pHeight = 80 + pArmyNum * 105
        var.Open = 0      
        if self.mData.leader == var.name then
           table.insert(self.mArmyData,1,var) 
           table.insert(self.TableHeight, 1,pHeight)
        else
           table.insert(self.mArmyData, var)
           table.insert(self.TableHeight,pHeight)
        end       
        table.insert(self.LaunchTab, 1)
        if user.name == var.name then
            pAddBool = false
        end
        self.pPeopleNum = self.pPeopleNum + 1
    end
    if self.mData.status == TEAM_DEFENS then
        if self.mData.CaptainName == user.name then
            pAddBool = false
        end
    end

    if self.warType == 1 then         
        if pAddBool then
            local p = { }
            p.Open = 1
            table.insert(self.TableHeight, 1, 80)
            table.insert(self.mArmyData, 1, p)
        end
        if pOpenBool then
            local p = { }
            p.Open = 2
            table.insert(self.TableHeight, 80)
            table.insert(self.mArmyData, p)
        end
    end

    local pMarchStr = "集结中"
    local pMassStr = "已集结"
    self.Teamrun = false
    local pTitle = me.assignWidget(self,"title")
    if self.warType == 1 then
         pButtonDismiss:setVisible(true)
         pButtonaid:setVisible(false)
        if self.mData.status == TEAM_RUN then
            pMarchStr = "行军中"
            pMassStr = "已集结"
            self.Teamrun = true
        elseif self.mData.status == TEAM_WAIT then
            pMarchStr = "集结中"
            pMassStr = "已集结"
        elseif self.mData.status == THRONE_TEAM_RUN then
            pMarchStr = "行军中"
            pMassStr = "驻扎中"
        elseif self.mData.status == THRONE_DEFEND then
            pMarchStr = "驻扎中"
            pMassStr = "驻扎中"
        end
        pTitle:setString("集火")
    else
         pButtonDismiss:setVisible(false)
         pButtonaid:setVisible(true)
         pTitle:setString("防御")
        if self.mData.leader == user.name then
            self:setButton(pButtonaid,false)
        else
            if self.mData.maxSoliderNum > self.mData.soliderNum then             
              if pAddBool then                 
                  self:setButton(pButtonaid,true)
              else
                  self:setButton(pButtonaid,false)
              end
            else
                self:setButton(pButtonaid,true)
            end
        end
        if self.mData.status == TEAM_RUN then
            pMarchStr = "敌军逼近中"
            self.Teamrun = true
        elseif self.mData.status == TEAM_WAIT then
            pMarchStr = "敌军集结中"
            pMassStr = "敌军已集结"
        end
        pPeopleNum:setString(self.mData.playerNum)
    end

    self.totalTime = me.toNum(self.mData.totalTime)
    self.mTime = me.toNum(self.mData.countTime)
    self.LoadingBar = me.assignWidget(self, "up_mass_LoadingBar")
    self.mTimeLabel = me.assignWidget(self, "up_mass_count")
    self.pTimeBool = false
    if self.mTime > 0 then
        self.pTimeBool = true
        self.mTimeLabel:setString(pMarchStr .. me.formartSecTime(self.mTime))
    else
        self.mTimeLabel:setString(pMassStr)
    end
    self.LoadingBar:setPercent(100 -(self.mTime / self.totalTime * 100))
    self.pTime = me.registTimer(-1, function(dt)
        for key, var in pairs(self.mArmyData) do
            if var.Open == 0 then
                if var.counttime > 0 then
                    var.counttime = var.counttime - 1
                end
            end
        end
        if self.mTime > 0 then
            self.mTime = self.mTime - 1
            self.LoadingBar:setPercent(100 -(self.mTime / self.totalTime * 100))
            self.mTimeLabel:setString(pMarchStr .. me.formartSecTime(self.mTime))
        else
            self.mTimeLabel:setString(pMassStr)
            if self.Teamrun then
                self:close()
            end
            if self.pTimeBool and self.mData ~= nil then
                self:setServer()
                self.pTimeBool = false
            end
        end
    end , 1)
   
    me.assignWidget(self, "Node_10"):removeAllChildren()
    self:initInfoTab()
end
function convergeFire:setButton(button, b)
    button:setBright(b)
    button:setSwallowTouches(b)
    button:setTouchEnabled(b)
    if b then
        button:setTitleColor(me.convert3Color_("#ffffff"))
    else
        button:setTitleColor(me.convert3Color_("#767676"))
    end
end
function convergeFire:initInfoTab()
    self.tableView = nil
    local pNum = #self.mArmyData
    local pHeight = 510
    local pTableHeight = 0
    if self.warType == 0 then
        pHeight = 355
        pTableHeight = 70
    end
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pPitch = self.mArmyData[cell:getIdx() + 1]
        if pPitch.Open == 0 then
            local pIndex = cell:getIdx() + 1
            local pLaunch = self.LaunchTab[pIndex]
            local pOffset = self.tableView:getContentOffset()
            local pOffsetNew = cc.p(0, 0)

            if pLaunch == 1 then
                for var = 1, self.pPeopleNum do
                    self.LaunchTab[var] = 1
                end
                self.LaunchTab[pIndex] = 2
                local pOffsetY =(- pNum +(pIndex - 1)) * convergeFire.TABLEHEIGHT + pHeight - self.TableHeight[pIndex]
                if pNum * convergeFire.TABLEHEIGHT + self.TableHeight[pIndex] < pHeight then
                    pOffsetY = pHeight -(pNum * convergeFire.TABLEHEIGHT + self.TableHeight[pIndex])
                else
                    pOffsetY = math.min(pOffsetY, 0)
                end
                pOffsetNew = cc.p(0, pOffsetY)
            else
                self.LaunchTab[pIndex] = 1
                if pNum * convergeFire.TABLEHEIGHT < pHeight then
                    pOffsetNew = cc.p(0,(pHeight - pNum * convergeFire.TABLEHEIGHT))
                else
                    pOffsetNew = cc.p(0, math.min(0, pOffset.y + self.TableHeight[pIndex]))
                end
            end
            self.tableView:reloadData()
            self.tableView:setContentOffset(pOffsetNew)
        else
            if self.warType == 1 then
                if pPitch.Open == 1 then
                    if self.mData["status"] == TEAM_RUN then
                        showTips("集火部队已出发")
                    else
                        local pMaxArmy = self.mData.maxSoliderNum - self.mData.soliderNum
                        if pMaxArmy > 0 then
                           if self.mData.playerNum == self.mData.maxPlayerNum then
                              showTips("集火的成员数量已达到上限")
                           else
                              if self.mData.ConergeType == 1 then
                                 dump(self.mData)
                                 ConvergeStrong(cc.p(self.mData.leaderX, self.mData.leaderY), THRONE_TEAM_JOIN, pMaxArmy, self.mData.teamId,self.mTime)
                              else
                                 ConvergeStrong(cc.p(self.mData.leaderX, self.mData.leaderY), TEAM_ARMY_JOIN, pMaxArmy, self.mData.teamId,self.mTime, self.mData.ConergeType)
                              end
                              
                           end                           
                        else
                           showTips("集火部队兵力已达到上限")
                        end 
                    end                   
                end
            end
        end
    end

    local function cellSizeForTable(table, idx)
        local pX = convergeFire.TABLEHEIGHT
        local pLaunch = self.LaunchTab[idx + 1]
        if pLaunch == 2 then
            pX = pX + self.TableHeight[idx + 1]
        end
        return 832, pX
    end 

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pconvergeFireCell = convergeFireCell:create(self, "n_r_cell")
            local pLaunch = self.LaunchTab[idx + 1]
            local pHeight = convergeFire.TABLEHEIGHT
            local pArmyHeight = 0
            if pLaunch == 2 then
                pArmyHeight = self.TableHeight[idx + 1]
                pHeight = pHeight + self.TableHeight[idx + 1]
            end
            pconvergeFireCell:setDate(self.mArmyData[idx + 1], pArmyHeight, self.mData.teamId, self.LeaderBool, self.mLeaderName, self.mData,self.warType)
            pconvergeFireCell:setPosition(cc.p(0, pHeight))
            pconvergeFireCell:setAnchorPoint(cc.p(0, 1))
            local pLaunchButton = me.assignWidget(pconvergeFireCell, "Button_launch")
            pLaunchButton:setTag(idx + 1)
            me.registGuiClickEvent(pLaunchButton, function(node)
                local pIndex = node:getTag()
                print("pIndex" .. pIndex)
--                                local pLaunch = self.LaunchTab[pIndex]
--                                local pOffset = self.tableView:getContentOffset()
--                                local pOffsetNew = cc.p(0, 0)
--                                if pLaunch == 1 then
--                                    for var = 1, self.pPeopleNum do
--                                        self.LaunchTab[var] = 1
--                                    end
--                                    self.LaunchTab[pIndex] = 2
--                                    local pOffsetY =(- pNum +(pIndex - 1)) * convergeFire.TABLEHEIGHT + pHeight - self.TableHeight[pIndex]
--                                    if pNum * convergeFire.TABLEHEIGHT + self.TableHeight[pIndex] < pHeight then
--                                        pOffsetY = pHeight -(pNum * convergeFire.TABLEHEIGHT + self.TableHeight[pIndex])
--                                    else
--                                        pOffsetY = math.min(pOffsetY, 0)
--                                    end

--                                    pOffsetNew = cc.p(0, pOffsetY)
--                                else
--                                    self.LaunchTab[pIndex] = 1
--                                    if pNum * convergeFire.TABLEHEIGHT < pHeight then
--                                        pOffsetNew = cc.p(0,(pHeight - pNum * convergeFire.TABLEHEIGHT))
--                                    else
--                                        pOffsetNew = cc.p(0, math.min(0, pOffset.y + self.TableHeight[pIndex]))
--                                    end
--                                end
--                                self.tableView:reloadData()
--                                self.tableView:setContentOffset(pOffsetNew)
            end )
            pLaunchButton:setSwallowTouches(false)
            cell:addChild(pconvergeFireCell)
        else
            local pconvergeFireCell = me.assignWidget(cell, "n_r_cell")
            local pLaunch = self.LaunchTab[idx + 1]
            local pHeight = convergeFire.TABLEHEIGHT
            local pArmyHeight = 0
            if pLaunch == 2 then
                pArmyHeight = self.TableHeight[idx + 1]
                pHeight = pHeight + self.TableHeight[idx + 1]
            end
            pconvergeFireCell:setDate(self.mArmyData[idx + 1], pArmyHeight, self.mData.teamId, self.LeaderBool, self.mLeaderName, self.mData,self.warType)
            pconvergeFireCell:setPosition(cc.p(0, pHeight))
            pconvergeFireCell:setAnchorPoint(cc.p(0, 1))
            local pLaunchButton = me.assignWidget(pconvergeFireCell, "Button_launch")
            pLaunchButton:setTag(idx + 1)
            --          me.registGuiClickEvent(pLaunchButton,function (node)
            --                self.tableView:reloadData()
            --                local pOffset = self.tableView:getContentOffset()
            --                self.tableView:setContentOffset(pOffset)
            --          end)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end

    tableView = cc.TableView:create(cc.size(832, pHeight))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, pTableHeight))
    tableView:setDelegate()
    me.assignWidget(self, "Node_10"):addChild(tableView)
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
function convergeFire:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_TEAM_ADD) then
        --  NetMan:send(_MSG.worldTeamArmyInfo(self.mData["teamId"],self.attackId))     
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
           GMan():send(_MSG.worldTeamInfo())
           self:setServer()
        else
           disWaitLayer()
           ConvergeLook(cc.p(self.mData.leaderX, self.mData.leaderY))  
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_REJECT_ARMY) then
        -- NetMan:send(_MSG.worldTeamArmyInfo(self.mData["teamId"],self.attackId))
        self:setServer()
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_ARMY_WAIT) then
        self:setServer()
        -- NetMan:send(_MSG.worldTeamArmyInfo(self.mData["teamId"],self.attackId))
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_RELEASE) then
        if self.mParent == nil then
            self:close()
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_TEAM_DETAIL) then
        self:setData(self.mParent, self.attackId, self.warType)    
    end
end
function convergeFire:setServer()
    if self.warType == 0 then
        -- 防御
        GMan():send(_MSG.worldTeamArmyInfo(self.mData["teamId"], self.attackId))
    else
        GMan():send(_MSG.worldTeamArmyInfo(self.mData["teamId"], 0))
    end
end
function convergeFire:onEnter()
    print("convergeFire onEnter")
    me.doLayout(self, me.winSize)
    self.close_event = me.RegistCustomEvent("convergeFire",function (evt)
        self:close()
    end)
    self.cEvent = me.RegistCustomEvent("rev_event_convergeFire",function (evt)
       self:setServer()
    end)

    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function convergeFire:onEnterTransitionDidFinish()
    print("convergeFire onEnterTransitionDidFinish")
end
function convergeFire:onExit()
    print("convergeFire onExit")
    me.clearTimer(self.pTime)
    if self.mParent then
        self.mParent.pconvergeFire = nil
    end
    me.RemoveCustomEvent(self.close_event)
    me.RemoveCustomEvent(self.cEvent)
    UserModel:removeLisener(self.modelkey)
end
function convergeFire:close()
    self:removeFromParentAndCleanup(true)
    
end

