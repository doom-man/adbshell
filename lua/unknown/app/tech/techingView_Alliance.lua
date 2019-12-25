techingView_Alliance = class("techingView_Alliance ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techingView_Alliance._index = techingView_Alliance
function techingView_Alliance:create(csb)
    local layer = techingView_Alliance.new(csb)
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

function techingView_Alliance:ctor()
    self.dataId = nil
    self.time = nil
    self.def = nil
    self.totalTime = nil
end

function techingView_Alliance:init()
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    self.Button_immediately = me.registGuiClickEventByName(self, "Button_immediately", function(node)
        self:btnImmediatilyOnClicked()
    end )
    local pMyDegree = user.familyMember["degree"]
    -- 我的职位
    me.setButtonDisable(self.Button_immediately, pMyDegree == 1 or pMyDegree == 2)
    self.Text_toolsName = me.assignWidget(self, "Text_toolsName")
    self.Text_toolsDesc = me.assignWidget(self, "Text_toolsDesc")
    self.Text_title_cur = me.assignWidget(self, "Text_title_cur")
    self.Text_title_next = me.assignWidget(self, "Text_title_next")
    self.Text_Time = me.assignWidget(self, "Text_Time")
    self.Image_Loading = me.assignWidget(self, "Image_Loading")
    self.Image_Loading:setVisible(false)
    self.Text_toolsNum = me.assignWidget(self, "Text_toolsNum")
    self.Image_Icon = me.assignWidget(self, "Image_Icon")
    self.Text_Gem = me.assignWidget(self, "Text_Gem")

    -- 加速
    self.btn_speedUp = me.registGuiClickEventByName(self, "btn_speedUp", function(node)
        self:btnSpeedUpOnClicked()
    end)
    self.text_times_left = me.assignWidget(self.btn_speedUp, "text_times_left")
    self.text_times_left:setString("")
    self.img_res_need = me.assignWidget(self.btn_speedUp, "img_res_need")
    self.img_res_need:setVisible(false)
    self.text_num_need = me.assignWidget(self.btn_speedUp, "text_num_need")
    self.text_num_need:setString("")
    self.text_num_out1 = me.assignWidget(self.btn_speedUp, "text_num_out1")
    self.text_num_out1:setString("")
    self.text_num_out2 = me.assignWidget(self.btn_speedUp, "text_num_out2")
    self.text_num_out2:setString("")

    return true
end

function techingView_Alliance:onEnter()
    print("techingView_Alliance:onEnter")
    me.doLayout(self, me.winSize)
    self.listener = UserModel:registerLisener( function(msg)
        self:updateData(msg)
    end)
end

function techingView_Alliance:updateData(msg)
    if checkMsg(msg.t, MsgCode.FAMILY_FINISH_UPDATING) then
        local msgTechid = cfg[CfgType.TECH_FAMILY][me.toNum(msg.c.id)].techid
        local dataTechid = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)].techid
        if msgTechid == dataTechid then
            self:removeFromParentAndCleanup(true)
        end
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_TECH_SPEED_UP) then
        showTips("+"..msg.c.gongxian.."徽章 ".."研究加速"..msg.c.timeshort.."秒", "FFFFFF")
    elseif checkMsg(msg.t, MsgCode.ALLIANCE_TECH_SPEED_UP_TIMES_LEFT) then
        -- 联盟科技加速剩余次数
        self.text_times_left:setString(string.format("今日可资源加速：%s次", user.allTechTimesLeft))
    elseif checkMsg(msg.t, MsgCode.FAMILY_TECH_UPDATING) then
        local def = cfg[CfgType.TECH_FAMILY][self.dataId]
        local tmpData = user.familyTechDatas[def.techid]
        local leftTime = tmpData:getUpdateTime() - (me.sysTime() - tmpData:getStartTime())
        self.time = me.getIntNum(leftTime / 1000)
    end
end

function techingView_Alliance:onExit()
    print("techingView_Alliance:onExit")
    UserModel:removeLisener(self.listener)
    self.totalTime = nil
    me.clearTimer(self.cellTimer)
end

function techingView_Alliance:setItemData(dataId, leftTime)
    self.time = leftTime
    -- 服务器里有dataId，则说明是刚解锁的科技，预览dataId即可，如果没有则是需要预览下一个科技id
    self.dataId = dataId
    self.def = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)]
    if user.familyTechServerDatas[me.toNum(self.def.techid)] then
        local tmpData = user.familyTechServerDatas[me.toNum(self.def.techid)]
        if tmpData:getLockStatus() == techData.lockStatus.TECH_TECHING then
            local tmpdef = cfg[CfgType.TECH_FAMILY][me.toNum(dataId)]
            self.dataId = tmpdef.nextid
        end
    end
    -- 修正dataId
    local def = cfg[CfgType.TECH_FAMILY][me.toNum(dataId)]
    local obj = user.familyTechDatas[def.techid]
    if obj and obj:getDef() then
        self.dataId = obj:getDef().id
    end

    self.def = cfg[CfgType.TECH_FAMILY][me.toNum(self.dataId)]
    self.totalTime = self.def.time
    if self.def == nil then
        __G__TRACKBACK__("self.dataId= " .. self.dataId .. " is nil ！！")
        return
    end
    print("下一级   id:", self.dataId, ",等级:", self.def.level, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    self.Text_toolsName:setString(self.def.name)
    self.Text_toolsDesc:setString(self.def.desc)
    self.Text_title_cur:setString(TID_TECH_CUR_LEVEL .. "+" .. self.def.beforetxt)
    self.Text_title_next:setString(TID_TECH_NEXT_LEVEL .. "+" .. self.def.successtxt)
    self.Image_Icon:loadTexture(techIcon(self.def.icon), me.plistType)
    -- 设置时间和进度条
    self.Text_Time:setString(me.formartSecTime(self.time))
    if self.totalTime - self.time >= 0 then
        self.Image_Loading:setPercent(((self.totalTime - self.time) * 100 / self.totalTime))
        
    else
        self.Image_Loading:setPercent(0)
    end
    self.Image_Loading:setVisible(true)
    
    self.cellTimer = me.registTimer(self.time, function(dt, b)
        self.time = self.time - dt
        self.Text_Time:setString(me.formartSecTime(self.time))
        if self.totalTime - self.time >= 0 then
            self.Image_Loading:setPercent(((self.totalTime - self.time) * 100 / self.totalTime))
            
        else
            self.Image_Loading:setPercent(0)
        end
        if b then
            self:removeFromParentAndCleanup(true)
        end
    end , 1)

    --[[
    local tmpLv = 0
    -- 需要特殊判断下，是0级未解锁升级到1级，还是1级升级到2级,因为界面表现是一样的
    if user.familyTechServerDatas[self.def.techid] then
        local data = user.familyTechServerDatas[self.def.techid]
        if data:getLockStatus() == allianceTechData.lockStatus.TECH_USED then
            tmpLv = self.def.level
        end
    end
    ]]
    local tmpLv = 0
    local maxLv = techDataMgr.getMaxFamilyTechLevelByTechId(self.def.techid)
    local tmpData = user.familyTechDatas[self.def.techid]
    local tmpStatus = tmpData:getLockStatus()
    local tmpDef = tmpData:getDef()
    if tmpStatus == allianceTechData.lockStatus.TECH_TECHING_UNSED  then
        tmpLv = tmpDef.level - 1
    elseif tmpStatus == allianceTechData.lockStatus.TECH_TECHING then
        tmpLv = tmpDef.level
    end
    self.Text_toolsNum:setString(tmpLv .. "/" .. maxLv)

    -- 钻石的消耗
    local price = { }
    price.food = 0
    price.wood = 0
    price.stone = 0
    price.gold = 0
    price.time = self.time
    price.index = 3
    local allCost = getGemCost(price)
    self.Text_Gem:setString(math.ceil(allCost))

    -- 研究加速
    self.text_times_left:setString(string.format("今日可资源加速：%s次", user.allTechTimesLeft))
    local min = (me.sysTime() / 1000 / 60) % 60
    local typeStr, typeImg, typeId
    if min >= 0 and min < 15 then           -- food
        typeStr = "food"
        typeImg = ICON_RES_FOOD
        typeId = 9001
    elseif min >= 15 and min < 30 then      -- stone
        typeStr = "stone"
        typeImg = ICON_RES_STONE
        typeId = 9003
    elseif min >= 30 and min < 45 then      -- wood
        typeStr = "wood"
        typeImg = ICON_RES_LUMBER
        typeId = 9002
    else                                    -- gold
        typeStr = "gold"
        typeImg = ICON_RES_GOLD
        typeId = 9004
    end
    self.img_res_need:loadTexture(typeImg, me.localType)
    self.img_res_need:setVisible(true)
    self.text_num_need:setString(self.def[typeStr])
    self.text_num_out1:setString(math.floor(self.def.getgongxian * (1 + user.propertyValue["LianMengMetalAdd"])))
    self.text_num_out2:setString(self.def.timeshort.."秒")
    --
    self.needResId = typeId
    self.needResNum = self.def[typeStr]
end

function techingView_Alliance:btnImmediatilyOnClicked()
    local function diamondUse()
        NetMan:send(_MSG.speedUpAllianceTech(self.def.techid))
        self:removeFromParentAndCleanup(true)
    end

    local needDiamond = tonumber(self.Text_Gem:getString())
    if user.diamond<needDiamond then
        diamondNotenough(needDiamond, diamondUse)  
    else
        diamondUse()
    end
end

-- 加速按钮点击事件
function techingView_Alliance:btnSpeedUpOnClicked()
    if user.allTechTimesLeft <= 0 then
        showTips("今日资源加速次数已用完")
        return
    end
    NetMan:send(_MSG.alliance_tech_speed_up(self.def.techid, self.needResId, self.needResNum))
end