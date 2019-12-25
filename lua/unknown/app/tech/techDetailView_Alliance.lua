
techDetailView_Alliance = class("techDetailView_Alliance ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techDetailView_Alliance._index = techDetailView_Alliance

techDetailView_Alliance.DescStatus = {
    EMPTY = 1,
    RED = 2,
    GREEN = 3,
}

function techDetailView_Alliance:create(csb)
    local layer = techDetailView_Alliance.new(csb)
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

function techDetailView_Alliance:ctor()
    print("techDetailView_Alliance:ctor()")
    self.dataId=nil
    self.curtData = nil
    self.curtDef= nil
    self.listener = nil
    self.givenType = nil --当钱捐赠类型
    self.givenTypeID = 0
    self.timer = nil --计时器
    self.coolDownTime = 0 -- 冷却剩余时间
    self.timeLimit = 3600*4 --四小时
end

function techDetailView_Alliance:init()
    self.Text_TitleName = me.assignWidget(self, "Text_TitleName")
    self.Image_Tech_Icon = me.assignWidget(self, "Image_Tech_Icon")

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.Button_study = me.registGuiClickEventByName(self, "Button_study", function(node)
        self:btnStudyOnClick()
    end )
    self.Button_now = me.registGuiClickEventByName(self, "Button_now", function(node)
        self:btnNowOnClick()
    end )
    self.Button_given = me.registGuiClickEventByName(self,"Button_given_1",function (node)
        if self.coolDownTime and self.coolDownTime-(me.sysTime()/1000-user.allianceGivenData.starTime) < self.timeLimit then
            NetMan:send(_MSG.giveTech_Alliance(self.curtDef.techid,self.givenTypeID,self.curtDef[self.givenType]))
        else
            me.removeAllianceTechCoolDownDialog("你的捐赠过于热情(冷却时间超过4小时)，你可以花费一些钻石直接清除冷却时间哟",function (arge)
                if arge == "ok" then
                    NetMan:send(_MSG.clearCoolDownTime())
                end
            end)
        end
    end)

    self.Text_Destribe = me.assignWidget(self, "Text_Destribe")
    self.Text_CurPer = me.assignWidget(self, "Text_CurPer")
    self.Text_NextPer = me.assignWidget(self, "Text_NextPer")
    self.Text_cooldowntime = me.assignWidget(self, "Text_cooldowntime")
    self.ListView_Left = me.assignWidget(self, "ListView_Left")
    self.ListView_Right = me.assignWidget(self, "ListView_Right")

    self.Node_process = me.assignWidget(self,"Node_process")
    self.Node_process:setVisible(false)
    self.Node_Achieve = me.assignWidget(self,"Node_Achieve")
    self.Node_Achieve:setVisible(false)
    self.Node_NoOpen = me.assignWidget(self,"Node_NoOpen")
    self.Node_NoOpen:setVisible(false)
    self.Text_totalProcess = me.assignWidget(self,"Text_totalProcess")
    self.Text_totalProcess_Done = me.assignWidget(self,"Text_totalProcess_Done")
    self.Text_resouce_num = me.assignWidget(self,"Text_resouce_num")
    self.Image_resouce = me.assignWidget(self,"Image_resouce")
    self.Image_cooldown = me.assignWidget(self,"Image_cooldown")
    self.Image_cooldown:setVisible(false)
    self.Text_resouce_1 = me.assignWidget(self,"Text_resouce_1")
    self.Text_resouce_2 = me.assignWidget(self,"Text_resouce_2")
    self.Panel_anim = me.assignWidget(self,"Panel_anim") 
    me.registGuiTouchEventByName(self, "Panel_anim", function(node, event)
        if event == ccui.TouchEventType.ended then
            node:stopAllActions()
            node:removeAllChildren()
            node:setVisible(false)
        end
    end )
    self.Panel_anim:setTouchEnabled(true)
    self.Panel_anim:setSwallowTouches(true)
    self.Panel_anim:setVisible(false)
    return true
end

function techDetailView_Alliance:setTechDataID(dataId_)
    self.dataId = dataId_
end

function techDetailView_Alliance:getTechDataID()
    return self.dataId
end

--设置每条List的item数据
function techDetailView_Alliance:setSingleItems(desc, status, resPNG,resType,index)
    if status == techDetailView_Alliance.DescStatus.EMPTY then
        return 
    end
    local tItem = me.createNode("techUpgradeItem.csb")
    local bItem = me.assignWidget(tItem,"bg"):clone()
    local ticon = me.assignWidget(bItem,"icon")
    local tdesc = me.assignWidget(bItem,"desc")
    local tcomplete = me.assignWidget(bItem,"complete")
    me.assignWidget(bItem,"optBtn"):setVisible(false)
    ticon:loadTexture(resPNG, resType)
    if status == techDetailView_Alliance.DescStatus.RED then
        tdesc:setColor(COLOR_RED)
        tcomplete:loadTexture("shengji_tubiao_buzu.png",me.localType)
    elseif status == techDetailView_Alliance.DescStatus.GREEN then
        tcomplete:loadTexture("shengji_tubiao_manzhu.png",me.localType)
        tdesc:setColor(COLOR_GREEN)
    end
    tdesc:setString(desc)
    if index%2 ~= 0 then
        self.ListView_Left:pushBackCustomItem(bItem)
    else
        self.ListView_Right:pushBackCustomItem(bItem)
    end
    return true
end

--设置List里的子控件（科技等级条件）
function techDetailView_Alliance:setListItems(techId,index)
    if techId then
        def = cfg[CfgType.TECH_FAMILY][techId]
        local status = techDetailView_Alliance.DescStatus.GREEN
        if techDataMgr.getUseStatusByTypeAndLv_Alliance(def.techid,def.level) == false then
            status = techDetailView_Alliance.DescStatus.RED
        end
        self:setSingleItems(def.name.." "..TID_LEVEL..def.level, status, techIcon(def.icon),me.plistType,index)
    end
end

function techDetailView_Alliance:initData()
    print("self.dataId = "..self.dataId)
    local def = cfg[CfgType.TECH_FAMILY][self.dataId]
    self.curtData = user.familyTechDatas[def.techid]
--    dump(self.curtData)
    self.curtDef = self.curtData:getDef()
    if nil == self.curtDef then
        __G__TRACKBACK__("cellData is nil !!!!")
        return
    end   
    self:clearAllList()

    --根据当前时间随机要捐赠的资源类型
    local function setCurrentGivenData()
        local min = me.sysTime()/1000/60%60
        local resPng = nil
        if min >= 0 and min <15 then -- food
            self.givenType = "food"
            resPng = ICON_RES_FOOD
            self.givenTypeID = 9001
        elseif min >=15 and min < 30 then --stone
            self.givenType = "stone"
            resPng = ICON_RES_STONE
            self.givenTypeID = 9003
        elseif min >=30 and min < 45 then --wood
            self.givenType = "wood"
            resPng = ICON_RES_LUMBER
            self.givenTypeID = 9002
        else --gold
            self.givenType = "gold"
            resPng = ICON_RES_GOLD
            self.givenTypeID = 9004
        end
        self.Text_resouce_num:setString(self.curtDef[self.givenType])
        self.Image_resouce:loadTexture(resPng, me.localType)
    end

    local function setCoolDownTime()
        self.coolDownTime = me.toNum(user.allianceGivenData.countDown)
        if self.coolDownTime and self.coolDownTime> 0 then
            self.Image_cooldown:setVisible(true)
            self.Text_cooldowntime:setString(me.formartSecTime(self.coolDownTime-(me.sysTime()/1000-user.allianceGivenData.starTime)))
            if self.timer == nil then
                self.timer = me.registTimer(self.coolDownTime,function ()
                    if self.coolDownTime-(me.sysTime()/1000-user.allianceGivenData.starTime) <= 0 then
                        me.clearTimer(self.timer)
                        self.timer = nil
                        self.Image_cooldown:setVisible(false)
                    end
                    self.Text_cooldowntime:setString(me.formartSecTime(self.coolDownTime-(me.sysTime()/1000-user.allianceGivenData.starTime)))
                end,1)
            end
        else
            me.clearTimer(self.timer)
            self.timer = nil
            self.Image_cooldown:setVisible(false)      
        end
    end
    
    if self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_UNLOCKED then --已解锁
        self.Node_process:setVisible(true)
        self.Text_totalProcess:setString("0".."/"..self.curtDef.point)
        self.Text_resouce_1:setString(self.curtDef.getpoint)
        self.Text_resouce_2:setString(math.floor(self.curtDef.getgongxian*(1+user.propertyValue["LianMengMetalAdd"])))
        setCoolDownTime()
        setCurrentGivenData()
    elseif self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_UNUSED then --未开启条件不足
        --添加一条研究解锁需要科技ListItem        
        local index_alliance = 1
        local tmpTables = techDataMgr.splitTechOps(self.curtDef.needtekId)
        for key, var in pairs(tmpTables) do
            local id = techDataMgr.getTechIDByTypeAndLV_Alliance(key, var)
            self:setListItems(id,index_alliance)
            index_alliance=index_alliance+1
        end   
        self.Node_NoOpen:setVisible(true)         
    elseif  self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_USED and 
    me.toNum(self.curtDef.level) == techDataMgr.getMaxFamilyTechLevelByTechId(self.curtDef.techid) then -- 已开启且达到最高等级
        self:clearAllList()
        self.Text_NextPer:setVisible(false)
        self.Text_TitleName:setString(self.curtDef.name)
        self.Image_Tech_Icon:loadTexture(techIcon(self.curtDef.icon), me.plistType)
        self.Text_Destribe:setString(self.curtDef.desc)
        self.Text_CurPer:setString(TID_TECH_CUR_LEVEL.."+"..self.curtDef.successtxt)
        return
    elseif self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_USED or 
    self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_GIVEN then --正在捐赠中(有已开启和未开启两种)
        if self.curtData:getLockStatus() == allianceTechData.lockStatus.TECH_USED then --已经升级过，则显示下一级的属性            
            self.curtDef = cfg[CfgType.TECH_FAMILY][self.curtDef.nextid] 
        end
        if self.curtData:getPoint() >= self.curtDef.point then --捐赠达到研究积分
            me.clearTimer(self.timer)
            self.timer = nil
            self.Image_cooldown:setVisible(false)   
            self.Node_Achieve:setVisible(true)
            self.Node_process:setVisible(false)
            me.assignWidget(self,"LoadingBar_time"):setPercent(100)
            self.Text_totalProcess_Done:setString(self.curtDef.point.."/"..self.curtDef.point)
            local pMyDegree = user.familyMember["degree"]   -- 我的职位
            me.setButtonDisable(self.Button_now, pMyDegree == 1 or pMyDegree == 2)
            me.setButtonDisable(self.Button_study, pMyDegree == 1 or pMyDegree == 2)
            me.assignWidget(self,"Text_studyTime"):setString(me.formartSecTime(math.ceil(self.curtDef.time*(1-user.propertyValue["GuildTechTime"]))))
            local price = {}
            price.food = 0
            price.wood = 0
            price.stone = 0
            price.gold = 0
            price.time = self.curtDef.time
            price.index = 3
            local diamondNum = math.ceil(getGemCost(price))
            me.assignWidget(self,"Text_diamond"):setString(diamondNum)
        else --没达到研究积分
            self.Node_Achieve:setVisible(false)
            self.Node_process:setVisible(true)
            me.assignWidget(self,"LoadingBar_time"):setPercent(self.curtData:getPoint()/self.curtDef.point*100)
            self.Text_totalProcess:setString(self.curtData:getPoint().."/"..self.curtDef.point)
            self.Text_resouce_1:setString(self.curtDef.getpoint)
            self.Text_resouce_2:setString(math.floor(self.curtDef.getgongxian*(1+user.propertyValue["LianMengMetalAdd"])))
            setCoolDownTime()
            setCurrentGivenData()
        end
    end
    self.Text_TitleName:setString(self.curtDef.name)
    self.Image_Tech_Icon:loadTexture(techIcon(self.curtDef.icon), me.plistType)
    self.Text_Destribe:setString(self.curtDef.desc)
    self.Text_CurPer:setString(TID_TECH_CUR_LEVEL.."+"..self.curtDef.beforetxt)
    self.Text_NextPer:setString(TID_TECH_NEXT_LEVEL.."+"..self.curtDef.successtxt)
end

function techDetailView_Alliance:updateData(msg)
    if nil == msg then
        return
    end
    if checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN) then
        self:initData()
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_GIVEN_BET) then
        self:getAllianceTechBet(msg)
    elseif checkMsg(msg.t, MsgCode.UPDATE_FAMILY_TECH) then
        local msgTechid = cfg[CfgType.TECH_FAMILY][me.toNum(msg.c.id)].techid
        local dataTechid = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)].techid
        if msgTechid == dataTechid then
            self:initData() 
        end
    end
end

function techDetailView_Alliance:getAllianceTechBet(msg)
    local function getAnim()
        local pAnim = mAnimation.new("item_ani")
        pAnim:fishPaly("idle") 
        pAnim:setPosition(cc.p(self.Panel_anim:getContentSize().width/2,self.Panel_anim:getContentSize().height/2))
        self.Panel_anim:addChild(pAnim)        
        self.Panel_anim:setVisible(true)
        me.DelayRun(function()
            if self.Panel_anim ~= nil then
                self.Panel_anim:stopAllActions()     
                self.Panel_anim:removeAllChildren()
                self.Panel_anim:setVisible(false)    
            end
        end,1.5)
    end
    local nums = math.floor(self.curtDef.getgongxian*(1+user.propertyValue["LianMengMetalAdd"]))
    if msg.c.bet and me.toNum(msg.c.bet)>1 then --出现暴击
        showTips("+"..math.ceil(msg.c.point/msg.c.bet).."进度".." x "..msg.c.bet.."   +"..nums.."徽章","FFA500")        
        getAnim()
    else
        showTips("+"..msg.c.point.."进度   +"..nums.."徽章","FFFFFF")        
    end
end

function techDetailView_Alliance:onEnter()
    print("techDetailView_Alliance:onEnter()")
    me.doLayout(self,me.winSize)  
    self:initData()
    self.listener = UserModel:registerLisener(function (msg)
        self:updateData(msg)
    end)
end

function techDetailView_Alliance:clearAllList()
    self.ListView_Left:removeAllChildren()
    self.ListView_Right:removeAllChildren()
end

function techDetailView_Alliance:onExit()
    print("techDetailView_Alliance:onExit()")
    UserModel:removeLisener(self.listener)
end

function techDetailView_Alliance:btnStudyOnClick()
    NetMan:send(_MSG.upgradeAllianceTech(self.curtDef.techid,0))
    self:removeFromParentAndCleanup(true)
end

function techDetailView_Alliance:btnNowOnClick()
    local function diamondUse()
        NetMan:send(_MSG.upgradeAllianceTech(self.curtDef.techid,1))
        self:removeFromParentAndCleanup(true)
    end

    local needDiamond = tonumber(me.assignWidget(self,"Text_diamond"):getString())
    if user.diamond<needDiamond then
        diamondNotenough(needDiamond, diamondUse)  
    else
        diamondUse()
    end
end

function techDetailView_Alliance:close()
    me.clearTimer(self.timer)
    self.timer = nil
    self:removeFromParentAndCleanup(true)
end
