
techDetailView = class("techDetailView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techDetailView._index = techDetailView

techDetailView.itemType = {
    Tech = 1,
    Building = 2,
    Res = 3,
}

techDetailView.DescStatus = {
    EMPTY = 1,
    RED = 2,
    GREEN = 3,
}

function techDetailView:create(csb)
    local layer = techDetailView.new(csb)
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

function techDetailView:ctor()
    self.dataId=nil
    self.curtData = nil
    self.curtDef= nil
    self.listener = nil
end

function techDetailView:init()

    self.Text_TitleName = me.assignWidget(self, "Text_TitleName")
    self.Image_Tech_Icon = me.assignWidget(self, "Image_Tech_Icon")

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_study", function(node)
        self:btnStudyOnClick()
    end )
    me.registGuiClickEventByName(self, "Button_now", function(node)
        self:btnNowOnClick()
    end )

    self.Text_Destribe = me.assignWidget(self, "Text_Destribe")
    self.Text_CurPer = me.assignWidget(self, "Text_CurPer")
    self.Text_NextPer = me.assignWidget(self, "Text_NextPer")

    self.Button_study = me.assignWidget(self, "Button_study")
    self.Button_now = me.assignWidget(self, "Button_now")

    self.Text_money = me.assignWidget(self, "Text_money")
    self.Text_time = me.assignWidget(self, "Text_time")
    self.ListView_Left = me.assignWidget(self, "ListView_Left")
    self.ListView_Right = me.assignWidget(self, "ListView_Right")

    return true
end

function techDetailView:setTechDataID(dataId_)
    self.dataId = dataId_
end

function techDetailView:getTechDataID()
    return self.dataId
end

--设置每条List的item数据
function techDetailView:setSingleItems(list, desc, status, resPNG,resType,itemType, targetBid)
    if status == techDetailView.DescStatus.EMPTY then
        return 
    end
    local tItem = me.createNode("techUpgradeItem.csb")
    local bItem = me.assignWidget(tItem,"bg"):clone()
    local ticon = me.assignWidget(bItem,"icon")
    local tdesc = me.assignWidget(bItem,"desc")
    local tcomplete = me.assignWidget(bItem,"complete")
    local toptBtn = me.assignWidget(bItem,"optBtn")
    toptBtn:setScaleX(0.7)
    toptBtn:getTitleRenderer():setScaleX(1.35)
    me.registGuiClickEventByName(bItem, "optBtn", function(node)
        if itemType == techDetailView.itemType.Building and targetBid then
            local ndata = cfg[CfgType.BUILDING][me.toNum(targetBid)]
            jumpToTarget(ndata)
            techView:getInstance():close()
            self:close()
        elseif itemType == techDetailView.itemType.Res then    
            local tmpView = recourceView:create("rescourceView.csb")
            local typeKey_ = nil
            if resPNG == ICON_RES_FOOD then
                typeKey_ = "food"
            elseif resPNG == ICON_RES_LUMBER then
                typeKey_ = "wood"
            elseif resPNG == ICON_RES_GOLD then
                typeKey_ = "gold"
            elseif resPNG == ICON_RES_STONE then
                typeKey_ = "stone"
            end
            tmpView:setRescourceType(typeKey_)
			tmpView:setRescourceNeedNums(tonumber(desc))
            me.popLayer(tmpView)
            me.showLayer(tmpView, "bg")
        end
    end )

    ticon:loadTexture(resPNG, resType)
    if status == techDetailView.DescStatus.RED then
        tdesc:setColor(COLOR_RED)
        tcomplete:loadTexture("shengji_tubiao_buzu.png",me.localType)
        if itemType == techDetailView.itemType.Tech then
            toptBtn:setVisible(false)
        elseif itemType == techDetailView.itemType.Building then
            toptBtn:setVisible(true)
            toptBtn:setTitleText(TID_BUTTON_JUMPTO)
        elseif itemType == techDetailView.itemType.Res then    
            toptBtn:setVisible(true)
            toptBtn:setTitleText(TID_BUTTON_GETMORE)
        end
        me.setButtonDisable(self.Button_study, false)
    elseif status == techDetailView.DescStatus.GREEN then
        tcomplete:loadTexture("shengji_tubiao_manzhu.png",me.localType)
        toptBtn:setVisible(false)
        tdesc:setColor(COLOR_GREEN_FLAG)
    end
    tdesc:setString(desc)
    list:pushBackCustomItem(bItem)
    return true
end

function techDetailView:getRightItemStatus(key,def)
    local tmpStatus = nil
    if def[key] <= 0 then
        tmpStatus = techDetailView.DescStatus.EMPTY
    elseif user[key] >= def[key] then
        tmpStatus = techDetailView.DescStatus.GREEN
    elseif user[key] < def[key] then
        tmpStatus = techDetailView.DescStatus.RED
    end
    return tmpStatus
end

--设置List里的子控件（金币，木材，矿石，建筑物等级，科技等级等条件）
function techDetailView:setListItems(techId,buildId)
    if techId then
        def = cfg[CfgType.TECH_UPDATE][techId]
        local status = techDetailView.DescStatus.GREEN
        if techDataMgr.getUseStatusByTypeAndLv(def.techid,def.level) == false then
              status = techDetailView.DescStatus.RED
              me.setButtonDisable(self.Button_now, false)
              me.setButtonDisable(self.Button_study, false)
        end
        self:setSingleItems(self.ListView_Left, def.name.." "..TID_LEVEL..def.level, status, techIcon(def.icon),me.plistType, techDetailView.itemType.Tech)
    elseif buildId then
        local finded = false    
        local buildDef = cfg[CfgType.BUILDING][me.toNum(buildId)]  
        local info = {}
        info.name = buildDef.name
        info.lv = buildDef.level
        info.id= buildDef.id
        info.icon = buildDef.icon
        info.type = buildDef.type
        for key, var in pairs(user.building) do
            if buildDef.type == var.def.type and me.toNum(buildDef.level) <= me.toNum(var.def.level)then
                info.sts = techDetailView.DescStatus.GREEN
                finded = true
            end
        end
        if finded == false then
            info.name = buildDef.name
            info.lv = buildDef.level
            info.sts = techDetailView.DescStatus.RED
            info.id= buildDef.id
            info.icon = buildDef.icon
            info.type = buildDef.type
            me.setButtonDisable(self.Button_now, false)
            me.setButtonDisable(self.Button_study, false)
        end      
        if info then
            self:setSingleItems(self.ListView_Left, info.name.." "..TID_LEVEL..info.lv, info.sts, buildSmallIcon(info),me.plistType,techDetailView.itemType.Building,buildId)
        end
    end
end

function techDetailView:initData()
    local tmpStatus = self.curtData:getLockStatus()
    if nil == self.curtDef then
        __G__TRACKBACK__("cellData is nil !!!!")
        return
    end   

    me.setButtonDisable(self.Button_now, true)
    me.setButtonDisable(self.Button_study, true)

    --当前科技已经满级(需要判断当前服务器有此数据，因为当未开启状态且最高级为1级的时候，会有bug)
    if user.techServerDatas[me.toNum(self.curtDef.id)] and me.toNum(self.curtDef.level) == techDataMgr.getMaxLevelByTechId(self.curtDef.techid) then
        self:clearAllList()
        self.Text_NextPer:setVisible(false)
    
        self.Text_TitleName:setString(self.curtDef.name)
        self.Image_Tech_Icon:loadTexture(techIcon(self.curtDef.icon), me.plistType)
        self.Text_Destribe:setString(self.curtDef.desc)
        self.Text_CurPer:setString(TID_TECH_CUR_LEVEL..self.curtDef.successtxt)

        self.Text_money:setString("0")
        self.Text_time:setString("0")

        me.setButtonDisable(self.Button_now, false)
        self.Button_now:setVisible(false)
        me.setButtonDisable(self.Button_study, false)
        self.Button_study:setVisible(false)
        return 
    end

    --当最高级状态,未开启状态,已解锁状态才预览本id数据，否则预览下一个id的数据
    if me.toNum(tmpStatus) ~= techData.lockStatus.TECH_UNLOCKED and 
        me.toNum(tmpStatus) ~= techData.lockStatus.TECH_UNUSED then
        --若已经升级完成了，就展示下一级科技数据
        if cfg[CfgType.TECH_UPDATE][self.curtData:getDef().nextid] then
            self.curtDef = cfg[CfgType.TECH_UPDATE][self.curtData:getDef().nextid]
        end       
    end

    self.Text_TitleName:setString(self.curtDef.name)
    self.Image_Tech_Icon:loadTexture(techIcon(self.curtDef.icon), me.plistType)
    self.Text_Destribe:setString(self.curtDef.desc)
    self.Text_CurPer:setString(TID_TECH_CUR_LEVEL..self.curtDef.beforetxt)

    self:clearAllList()
    self.Text_NextPer:setString(TID_TECH_NEXT_LEVEL..self.curtDef.successtxt)

    --添加需要金币，木材，石头，食物
    self:setSingleItems(self.ListView_Right, self.curtDef.gold, self:getRightItemStatus("gold",self.curtDef),ICON_RES_GOLD, me.localType,techDetailView.itemType.Res) 
    self:setSingleItems(self.ListView_Right, self.curtDef.wood, self:getRightItemStatus("wood",self.curtDef), ICON_RES_LUMBER,me.localType,techDetailView.itemType.Res)
    self:setSingleItems(self.ListView_Right, self.curtDef.stone, self:getRightItemStatus("stone",self.curtDef),ICON_RES_STONE,me.localType,techDetailView.itemType.Res)
    self:setSingleItems(self.ListView_Right, self.curtDef.food, self:getRightItemStatus("food",self.curtDef),ICON_RES_FOOD,me.localType,techDetailView.itemType.Res)

    --添加一条研究需要其他建筑等级ListItem
    local builds = me.split(self.curtDef.buildLevel,",")
    for key, var in pairs(builds) do
        self:setListItems(nil,var)
    end
    
    --添加一条研究解锁需要科技ListItem
    local tmpTables = techDataMgr.splitTechOps(self.curtDef.needtekId)
    if tmpTables then
        for key, var in pairs(tmpTables) do
            local id = techDataMgr.getTechIDByTypeAndLV(key, var)
            self:setListItems(id, nil)
        end
    end

    if tmpStatus == techData.lockStatus.TECH_TECHING then
        me.setButtonDisable(self.Button_study, false)
    end

    local upTime = techDataMgr.getTechUpgradeTime(self.curtDef)
    --获得当前科技所在建筑的入驻工人
    if upTime then
        self.Text_time:setString(me.formartSecTime(upTime))
    else
        __G__TRACKBACK__("upTime = nil !")
    end

    --钻石的消耗
    local price = {}
    price.food = self.curtDef.food
    price.wood = self.curtDef.wood
    price.stone = self.curtDef.stone
    price.gold = self.curtDef.gold
    price.time = upTime --self.curtDef.time2
    price.index = 3
    local allCost = getGemCost(price)
    self.Text_money:setString(math.ceil(allCost))    
end

function techDetailView:updateData(msg)
    if nil == msg then
        return
    end

    if checkMsg(msg.t, MsgCode.CITY_TECH_VIEW) then

    elseif checkMsg(msg.t, MsgCode.CITY_TECH_INIT) then

    elseif checkMsg(msg.t, MsgCode.CITY_TECH_UPLEVEL) then
        me.setButtonDisable(self.Button_study, false)
    elseif checkMsg(msg.t, MsgCode.CITY_TECH_FINISH) then
        me.setButtonDisable(self.Button_study, true)
        self.curtData = user.techTypeDatas[msg.c.defId]
        self.curtDef = self.curtData:getDef()
        self:initData()
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
    checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
    checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or 
    checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE)  then
        self:initData()
    end
end

function techDetailView:onEnter()
    print("techDetailView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.curtData = user.techTypeDatas[self.dataId]
    self.curtDef = self.curtData:getDef()
    self:initData()
    self.listener = UserModel:registerLisener(function (msg)
        self:updateData(msg)
    end)
end

function techDetailView:clearAllList()
    self.ListView_Left:removeAllChildren()
    self.ListView_Right:removeAllChildren()
end

function techDetailView:onExit()
    print("techDetailView:onExit()")
    UserModel:removeLisener(self.listener)
end

function techDetailView:btnStudyOnClick()
    NetMan:send(_MSG.techUpLevel(self.curtDef.techid, self.curtDef.level, techDataMgr.getCurToftid(),0))
    self:removeFromParentAndCleanup(true)
end

function techDetailView:btnNowOnClick()
    
    local function diamondUse()
        NetMan:send(_MSG.techUpLevel(self.curtDef.techid, self.curtDef.level, techDataMgr.getCurToftid(),1))
        self:removeFromParentAndCleanup(true)
    end

    local needDiamond = tonumber(self.Text_money:getString())
    if user.diamond<needDiamond then
        diamondNotenough(needDiamond, diamondUse)  
    else
        if needDiamond > 0 then
            -- 确认弹窗
            diamondCostMsgBox(needDiamond, function()
                diamondUse()
            end)
        else
            diamondUse()
        end
    end
end

function techDetailView:btnGotoOnClick()
    
end

function techDetailView:close()
    -- me.hideLayer(self,true,"shopbg")
    self:removeFromParentAndCleanup(true)
end
