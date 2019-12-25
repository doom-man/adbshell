techingView = class("techingView ", function(csb)
    return cc.CSLoader:createNode(csb)
end )

techingView._index = techingView
function techingView:create(csb)
    local layer = techingView.new(csb)
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

function techingView:ctor()
    self.dataId = nil
    self.time = nil
    self.def = nil
    self.totalTime = nil
end

function techingView:init()
    self.Button_useTools = me.assignWidget(self, "Button_useTools")
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    me.registGuiClickEventByName(self, "Button_immediately", function(node)
        self:btnImmediatilyOnClicked()
    end )
    me.registGuiClickEventByName(self, "Button_useTools", function(node)
        self:btnUseToolsOnClicked()
    end )
    
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
    self.Text_Time_bar = me.assignWidget(self,"Text_Time_bar")
    me.setButtonDisable(self.Button_useTools, table.nums(user.pkg) > 0)
    return true
end

function techingView:onEnter()
    print("techingView:onEnter")
    me.doLayout(self,me.winSize)  
end

function techingView:onExit()
    print("techingView:onExit")
    me.clearTimer(self.cellTimer)
    self.totalTime = nil
end

function techingView:setItemData(dataId,leftTime)
    self.time = leftTime
    --服务器里有dataId，则说明是刚解锁的科技，预览dataId即可，如果没有则是需要预览下一个科技id
    if user.techServerDatas[me.toNum(dataId)] then
        local tmpData = user.techServerDatas[me.toNum(dataId)]
        if tmpData:getLockStatus() == techData.lockStatus.TECH_TECHING then
            self.dataId = dataId
        else
            local tmpdef = cfg[CfgType.TECH_UPDATE][me.toNum(dataId)]
            self.dataId = tmpdef.nextid
        end
    end

    self.def = cfg[CfgType.TECH_UPDATE][me.toNum(self.dataId)]
    if self.def == nil then
        __G__TRACKBACK__("self.dataId= "..self.dataId.." is nil ！！")
        return 
    end

    self.Text_toolsName:setString(self.def.name)
    self.Text_toolsDesc:setString(self.def.desc)
    self.Text_title_cur:setString(TID_TECH_CUR_LEVEL..self.def.beforetxt)
    self.Text_title_next:setString(TID_TECH_NEXT_LEVEL..self.def.successtxt)
    self.Image_Icon:loadTexture(techIcon(self.def.icon), me.plistType)

    local tofid = techDataMgr.getCurToftid()
    self.totalTime = getTechTime(self.def,user.building[tofid].worker)

    --设置时间和进度条
    self.Text_Time:setString(me.formartSecTime(self.time))
    if self.totalTime-self.time >= 0 then
        self.Image_Loading:setPercent (((self.totalTime-self.time)*100/self.totalTime))
        self.Text_Time_bar:setString("研究中.."..math.floor ((self.totalTime-self.time)*100/self.totalTime).."%")
    else
        self.Image_Loading:setPercent(0)
    end
    self.Image_Loading:setVisible(true)
    self.cellTimer = me.registTimer(self.time ,function (dt,b)
        self.time = self.time - dt
        self.Text_Time:setString(me.formartSecTime(self.time))
        if self.totalTime-self.time >= 0 then
            self.Image_Loading:setPercent(((self.totalTime-self.time)*100/self.totalTime))
            self.Text_Time_bar:setString("研究中.."..math.floor ((self.totalTime-self.time)*100/self.totalTime).."%")
        else
            self.Image_Loading:setPercent(0)
        end        
        if b then
            self:removeFromParentAndCleanup(true)
        end
    end,1)
    local tmpLv = 0
    if self.def.level > 1 then
        tmpLv = self.def.level-1
    else
        --需要特殊判断下，是0级未解锁升级到1级，还是1级升级到2级,因为界面表现是一样的
        local tmpId = techDataMgr.getTechIDByTypeAndLV(self.def.techid, self.def.level+1)
        if user.techServerDatas[tmpId] then
            tmpLv = self.def.level
        end
    end
    local maxLv = techDataMgr.getMaxLevelByTechId(self.def.techid)
    self.Text_toolsNum:setString(tmpLv.."/"..maxLv)

    --钻石的消耗
    local price = {}
--    price.food = self.def.food
--    price.wood = self.def.wood
--    price.stone = self.def.stone
--    price.gold = self.def.gold
    price.food = 0
    price.wood = 0
    price.stone = 0
    price.gold = 0
    price.time = self.time --self.def.time2
    price.index = 3
    local allCost = getGemCost(price)
    self.Text_Gem:setString(math.ceil(allCost))

end

function techingView:btnImmediatilyOnClicked()
    local function diamondUse()
        NetMan:send(_MSG.buildQuickGem(techDataMgr.getCurToftid()))
        self:removeFromParentAndCleanup(true)
    end

    local needDiamond = tonumber(self.Text_Gem:getString())
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

function techingView:btnUseToolsOnClicked()
    local tarTools = getBackpackDatasByType(BUILDINGSTATE_WORK_STUDY.key)
    if table.nums(tarTools) > 0 then --判断是否加速道具
        local tmpView = useToolsView:create("useToolsView.csb")
        tmpView:setToolsType(BUILDINGSTATE_WORK_STUDY.key,techDataMgr.getCurToftid())
		tmpView:setRelatedObj(self.relatedObj)
        tmpView:setTime(self.totalTime-self.time,self.totalTime)
        mainCity:addChild(tmpView, 100)
        me.showLayer(tmpView, "bg")
        self:removeFromParentAndCleanup(true)
    else
        showTips("道具数量不足")
    end
end

function techingView:setRelatedObj(obj)
    self.relatedObj = obj
end
