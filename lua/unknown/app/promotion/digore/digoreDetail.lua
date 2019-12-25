-- [Comment]
-- jnmo
digoreDetail = class("digoreDetail", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
digoreDetail.__index = digoreDetail
function digoreDetail:create(...)
    local layer = digoreDetail.new(...)
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
function digoreDetail:ctor()
    print("digoreDetail ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_DETAIL) then
            disWaitLayer()
            self:initData(msg.c)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_TURNOVER_CAPTAIN) then
            disWaitLayer()
            local tmp = self.data.list[msg.c.leaderIndex+1]
            self.data.list[msg.c.leaderIndex+1]=self.data.list[1]
            self.data.list[1]=tmp
            self.teamId=tmp.roleUid
            self._tableView:reloadData()
        end      
    end )
end


function digoreDetail:initData(data)
    self.optBtn:setEnabled(true)
    self.optBtn:setBright(true)

    self.data = data
    local base = cfg[CfgType.ORE_RES][data.defId]
    local p = math.floor(((base.totalTreasure-data.num)/base.totalTreasure)*100)
    me.assignWidget(self, "posTxt"):setString("第"..data.page.."页"..(data.index%5+1).."号秘宝（"..p.."%）")
    me.assignWidget(self, "stoneNum"):setString(base.yield.."/小时")
    if data.server~="" then
        me.assignWidget(self, "serverTxt"):setString("当前占领："..data.server)
    else
        me.assignWidget(self, "serverTxt"):setString("当前占领：-")
    end
    me.assignWidget(self, "orePepole"):setString("挖掘人数："..data.size.."/"..base.numLimit)

    
    if data.status==1 then
        if data.size==base.numLimit then
            self.optBtn:setBright(false)
        end
        me.assignWidget(self.optBtn, "image_title"):setString("加入挖掘")
        self.optBtn:loadTextureNormal("ui_ty_button_lv_266x79.png",me.localType)
        self.optBtn:loadTexturePressed("ui_ty_button_lv_266x79.png",me.localType)
    elseif data.status==2 then
        if data.protectTime>0 then
            self.optBtn:setBright(false)
        end
        me.assignWidget(self.optBtn, "image_title"):setString("掠 夺")
        self.optBtn:loadTextureNormal("ui_ty_button_hong_266x79_.png",me.localType)
        self.optBtn:loadTexturePressed("ui_ty_button_hong_266x79_.png",me.localType)
    elseif data.status==3 then
        me.assignWidget(self.optBtn, "image_title"):setString("撤 回")
        self.optBtn:loadTextureNormal("ui_ty_button_cheng_266x79.png",me.localType)
        self.optBtn:loadTexturePressed("ui_ty_button_cheng_266x79.png",me.localType)
    end

    self._dataList={}
    for _,v in ipairs(data.list) do
        v.isOpen=0
        table.insert(self._dataList, v)
    end
    if #data.list>0 then
        self.teamId=self._dataList[1].roleUid
    else
        self.teamId=0
        table.insert(self._dataList, -1)
    end

    self._tableView:reloadData()
end


function digoreDetail:init()
    print("digoreDetail init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    
    self.optBtn = me.assignWidget(self, "optBtn")
    self.optBtn:setEnabled(false)
    self.optBtn:setBright(false)
    me.registGuiClickEvent(self.optBtn, handler(self, self.optAction))
    self.cell = me.assignWidget(self, "cell")
    self.cell_1 = me.assignWidget(self, "cell1")
    self.armyCell = me.assignWidget(self, "armyCell")

    self._tableHeight=396
    self._openIndex = -1

    self._dataList={}--{{isOpen=0}, {isOpen=0},{isOpen=0}}
    self:initList()

    self._tableView:reloadData()

    return true
end

function digoreDetail:optAction()
    local base = cfg[CfgType.ORE_RES][self.data.defId]
    
    if self.data.status==1 then
        if self.data.size==base.numLimit then
            showTips("当前矿挖掘位置已满")
            return
        end
        self:showExped()
    elseif self.data.status==2 then
        if self.data.protectTime>0 then
            showTips("该宝藏处于免战状态")
            return
        end

        self:showExped()
    elseif self.data.status==3 then
        NetMan:send(_MSG.digoreCallback(self.data.armyId))
        self:close()
    end
end

function digoreDetail:showExped()

    local exped = expedLayer:create("expeditionLayer.csb")
    exped:setExpedState(EXPED_STATE_DIGORE)
    exped:setBoosType("digore")
    exped:setDigoreData({groupId=self.data.id,index=self.data.index})
    
    --exped:setQueueNum(self.queueNum)
    exped:setPaths({ori=cc.p(0,0), tag=cc.p(0,50)})
    --exped:setNpc(msg.c.npc,msg.c.show)
    exped:setStar(user.soldierData)
    me.runningScene():addChild(exped, me.MAXZORDER)

    me.DelayRun(function()
        self:close()
    end, 0.3)
end

-- tableViews数据填充
function digoreDetail:initList()
    
    local function tableCellTouched(table, cell)
        local idx = cell:getIdx() + 1
        local data = self._dataList[idx]
        if data==-1 then
            self:showExped()
        elseif self.data.status~=2 then
            self:extendCell(cell:getChildByName("cell"):getChildByName("openBtn"))
        end
    end

    local function numberOfCellsInTableView(table)
        return #self._dataList
    end

    local function cellSizeForTable(table, idx)
        local data = self._dataList[idx+1]
        if data~=-1 and data.isOpen==1 then
            return 1166, data.h
        else
            return 1166, 125
        end
    
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = self._dataList[idx+1]

        if nil == cell then
            cell = cc.TableViewCell:new()
            if data then
                if data==-1 then
                    local cellItem = self.cell_1:clone():setVisible(true)
                    --cellItem:ignoreContentAdaptWithSize(false)
                    --cellItem:setContentSize(1132.46, 107)

                    cellItem:setPosition(5, 0)
                    cellItem:setTag(111)
                    cell:addChild(cellItem)
                else
                    local cellItem = self.cell:clone():setVisible(true)
                    cellItem:setPosition(5, 0)
                    cellItem:setTag(111)
                    cell:addChild(cellItem)

                    self:fillData(cellItem, data, idx)

                    
                    local openBtn = me.assignWidget(cellItem, "openBtn")
                    openBtn.idx=idx
                    --[[
                    me.registGuiClickEvent(openBtn, handler(self, self.extendCell))
                    openBtn:setSwallowTouches(false)
                    ]]

                    local turnoverCaptain = me.assignWidget(cellItem, "turnoverCaptain")
                    turnoverCaptain.posIndex=idx
                    me.registGuiClickEvent(turnoverCaptain, handler(self, self.turnoverCaptain))
                    --turnoverCaptain:setSwallowTouches(false)
                end
            end
        else
            if data~=-1 then

                local cellItem = cell:getChildByTag(111)
                local turnoverCaptain = me.assignWidget(cellItem, "turnoverCaptain")
                turnoverCaptain.posIndex=idx

                local openBtn = me.assignWidget(cellItem, "openBtn")
                openBtn.idx=idx
                self:fillData(cellItem, data, idx)
            end
        end
        return cell
    end

    self._tableView = cc.TableView:create(cc.size(1166, self._tableHeight))
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setPosition(10, 0)
    self._tableView:setAnchorPoint(cc.p(0, 0))
    self._tableView:setDelegate()
    me.assignWidget(self, "tbl"):addChild(self._tableView)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
end

----
--转让队长
--
function digoreDetail:turnoverCaptain(node)
    showWaitLayer()
    NetMan:send(_MSG.digoreTurnoverCaptain(self.data.id, self.data.index, node.posIndex))
end

function digoreDetail:extendCell(node)
    if self.data.status==2 then --不能查看敌对服务器的详情
        return
    end
    if self._openIndex>-1 and self._openIndex~=node.idx then
        local data = self._dataList[self._openIndex+1]
        if data then
            data.isOpen=0
        end
    end
    local data = self._dataList[node.idx+1]
    if data.isOpen==0 then
        data.isOpen=1
        self._openIndex=node.idx
        local h=self:fillArmy(me.assignWidget(node:getParent(), "extendPanel"), data.list, data.shipId)
        data.h=h+120
    else
        data.isOpen=0
        self._openIndex=-1
    end

    local offset=self._tableView:getContentOffset()
    local size=self._tableView:getContentSize()
    local offsetY=size.height-(-offset.y)-self._tableHeight
    self._tableView:reloadData()
    size=self._tableView:getContentSize()
        
    if data.isOpen==1 and offset.y==0 then
        offset.y=self._tableHeight-size.height+offsetY+100
    else
        offset.y=self._tableHeight-size.height+offsetY
    end
        
    if size.height<self._tableHeight then
       offset.y=self._tableHeight-size.height
    elseif offset.y>0 then
       offset.y=0
    end
    self._tableView:setContentOffset(offset)
end

function digoreDetail:fillData(cellItem, data, idx)
    local nameStr=data.server
    if data.famliy then
        nameStr = nameStr.."["..data.famliy.."]"
    end
    local nameTxt=me.assignWidget(cellItem,"nameTxt")
    local turnoverCaptain = me.assignWidget(cellItem,"turnoverCaptain")
    turnoverCaptain:ignoreContentAdaptWithSize(false)
    turnoverCaptain:setContentSize(131, 46)

    turnoverCaptain:setVisible(false)
    nameStr=nameStr..data.name
    if idx==0 then  --队长
        nameStr=nameStr.." (队长)"
        nameTxt:setString(nameStr)
    elseif user.uid==self.teamId then
        turnoverCaptain:setVisible(true)
        nameTxt:setString(nameStr)
        turnoverCaptain:setPositionX(nameTxt:getPositionX()+nameTxt:getContentSize().width+5)
    else
        nameTxt:setString(nameStr)
    end
   
    me.assignWidget(cellItem,"openBtn"):setVisible(true)
    if self.data.status==2 then
        nameTxt:setTextColor(cc.c3b(255, 0, 0))
        me.assignWidget(cellItem,"openBtn"):setVisible(false)
    elseif user.uid==self.teamId then
        nameTxt:setTextColor(cc.c3b(103, 255, 2))
    else
        nameTxt:setTextColor(cc.c3b(30, 144, 255))
    end
    local base = cfg[CfgType.ORE_RES][self.data.defId]
    local iconItem = me.assignWidget(cellItem,"iconItem")
    iconItem:ignoreContentAdaptWithSize(true)
    if base.resource==4 then
        iconItem:loadTexture(ICON_RES_GOLD, me.localType)
    elseif base.resource==3 then
        iconItem:loadTexture(ICON_RES_STONE, me.localType)
    elseif base.resource==2 then
        iconItem:loadTexture(ICON_RES_FOOD, me.localType)
    elseif base.resource==1 then
        iconItem:loadTexture(ICON_RES_LUMBER, me.localType)
    end

    me.assignWidget(cellItem,"capacityTxt"):setString("负重："..data.carray.."/"..data.totalCarray)
    me.assignWidget(cellItem,"armyNums"):setString("部队："..data.soliderNum)
    if data.evil>0 then
        me.assignWidget(cellItem,"Text_21_0_0"):setVisible(true)
        me.assignWidget(cellItem,"evilTxt"):setVisible(true)
    else
        me.assignWidget(cellItem,"Text_21_0_0"):setVisible(false)
        me.assignWidget(cellItem,"evilTxt"):setVisible(false)
    end
    if data.evilReduc>0 then
        me.assignWidget(cellItem,"evilTxt"):setString(data.evil.."(被掠夺比例+"..data.evilReduc.."%)")
    else
        me.assignWidget(cellItem,"evilTxt"):setString(data.evil)
    end
    me.assignWidget(cellItem,"goldNum"):setString(data.data)
    me.assignWidget(cellItem,"stoneNum"):setString(data.itemNum)

    local extendPanel = me.assignWidget(cellItem, "extendPanel")

    local s = extendPanel:getContentSize()
    if data.isOpen==1 then
        me.assignWidget(cellItem, "openBtn"):setRotation(90)
        extendPanel:setVisible(true)
        extendPanel:setPositionY(-s.height)
        cellItem:setPositionY(s.height)
    else
        cellItem:setPositionY(0)
        me.assignWidget(cellItem, "openBtn"):setRotation(0)
        extendPanel:setVisible(false)
    end
end

function digoreDetail:fillArmy(extendPanel, data, shipId)
    local armyPanel = me.assignWidget(extendPanel, "armyPanel")
    armyPanel:removeAllChildren()
    local h = math.ceil(#data/3)*106+50
    extendPanel:setContentSize(cc.size(1136, h))
    me.assignWidget(extendPanel, "optBtn2"):setPositionY(0)
    local i=0
    if shipId>0 then
        local armyCell = self.armyCell:clone():setVisible(true)
        armyPanel:addChild(armyCell)
        armyCell:setPosition(0, h)
        local pConfig = cfg[CfgType.SHIP_DATA][shipId]
        me.assignWidget(armyCell, "army_icon"):setVisible(false)
        local warShipIco = me.assignWidget(armyCell, "warship_icon")
        warShipIco:setVisible(true)
        warShipIco:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png", me.localType)
        warShipIco:setScale(0.55)
        me.assignWidget(armyCell, "army_num"):setString('')
        me.assignWidget(armyCell, "army_name"):setString(pConfig.name)
        i=1
    end
    for k, v in ipairs(data) do
        local armyCell = self.armyCell:clone():setVisible(true)
        armyPanel:addChild(armyCell)
        armyCell:setPosition(((k+i-1)%3)*379.6, h-math.floor((k+i-1)/3)*106)
        local soldierData =  cfg[CfgType.CFG_SOLDIER][v.n]
        local icon = me.assignWidget(armyCell, "army_icon")
        icon:setVisible(true)
        me.assignWidget(armyCell, "warship_icon"):setVisible(false)
        icon:loadTexture(soldierIcon(soldierData), me.plistType)
        icon:setScale(1.8)
        me.assignWidget(armyCell, "army_num"):setString(v.v)
        me.assignWidget(armyCell, "army_name"):setString(soldierData.name)
    end
    return h
end

function digoreDetail:onEnter()
    print("digoreDetail onEnter")
    me.doLayout(self, me.winSize)
end
function digoreDetail:onEnterTransitionDidFinish()
    print("digoreDetail onEnterTransitionDidFinish")
end
function digoreDetail:onExit()
    print("digoreDetail onExit")

    me.coroClear(self.schid)
    me.clearTimer(self.timeId)
    UserModel:removeLisener(self.modelkey)
end
function digoreDetail:close()
    self:removeFromParent()
end


