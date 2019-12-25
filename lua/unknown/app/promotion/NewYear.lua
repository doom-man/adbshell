-- [Comment]
-- jnmo
NewYear = class("NewYear", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
NewYear.__index = NewYear
function NewYear:create(...)
    local layer = NewYear.new(...)
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
NewYear.GOODLUCK = 1 -- 福卷
NewYear.INTEGR = 2 -- 积分
function NewYear:ctor()
    print("NewYear ctor")
    self.state = 1
end

function NewYear:setButtonDisable(button, b)   
    if  button.setBright then
         button:setTouchEnabled(b)
         button:setBright(b)  
         if b==true then
            me.assignWidget(button, "btn_txt_1"):setVisible(true)
         else
            me.assignWidget(button, "btn_txt_2"):setVisible(true)
         end         
    end
end
function NewYear:init()
    print("NewYear init")
    me.registGuiClickEventByName(self, "Button_RankGift", function(node)
        NetMan:send(_MSG.CheckActivity_Limit_Reward(NewYearReawrd.singleNewYearRewardType))
        me.assignWidget(self, "New_Year__Info_bg"):setVisible(false)
    end )
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        me.assignWidget(self, "New_Year__Info_bg"):setVisible(false)
    end )
    me.registGuiClickEventByName(self, "Intergr_num", function(node)
        me.assignWidget(self, "New_Year__Info_bg"):setVisible(true)
    end )
    self.Button_ScoreBox = me.registGuiClickEventByName(self, "Button_ScoreBox", function(node)
        self:setButtonDisable(node, false)  
        self:setButtonDisable(self.Button_DragonBox, true)
        self:setButtonDisable(self.Button_Rank, true)
        self:setButtonDisable(self.Button_AllRank, true)
        self.state = 1
        self:initScoreBox()
    end )
    self.Button_DragonBox = me.registGuiClickEventByName(self, "Button_DragonBox", function(node)
        self:setButtonDisable(node, false)
        self:setButtonDisable(self.Button_ScoreBox, true)
        self:setButtonDisable(self.Button_Rank, true)
        self:setButtonDisable(self.Button_AllRank, true)
        self.state = 2
        self:dragonBox()
    end )
    self.Button_Rank = me.registGuiClickEventByName(self, "Button_Rank", function(node)
        self:setButtonDisable(node, false)
        self:setButtonDisable(self.Button_ScoreBox, true)
        self:setButtonDisable(self.Button_DragonBox, true)
        self:setButtonDisable(self.Button_AllRank, true)
        self.state = 3
        self:initRank()
        NetMan:send(_MSG.rankList(rankView.PROMITION_NEWYEAR))

    end )
    self.Button_AllRank = me.registGuiClickEventByName(self, "Button_AllRank", function(node)
        self:setButtonDisable(node, false)
        self:setButtonDisable(self.Button_ScoreBox, true)
        self:setButtonDisable(self.Button_DragonBox, true)
        self:setButtonDisable(self.Button_Rank, true)
        self.state = 4
        self:initAllRank()
        NetMan:send(_MSG.rankList(rankView.PROMITION_NEWYEARTOTAL))
    end )
    self.myRank = me.registGuiClickEventByName(self, "Button_myRank", function(node)
        if self.Blink_Bool then
            if self.rank_num ~= 0 then
                self:setTableOffset(self.rank_num)
                self:pitchcellhint()
                self.Blink_Bool = false
            end
        end
    end )
    self:setButtonDisable(self.Button_ScoreBox, false)
    self:setButtonDisable(self.Button_DragonBox, true)
    self:setButtonDisable(self.Button_Rank, true)
    self:setButtonDisable(self.Button_AllRank, true)
    self.Panel_Integra = me.assignWidget(self, "Panel_Integra")
    self.Panel_Rank = me.assignWidget(self, "Panel_Rank")
    self.Panel_reward = me.assignWidget(self, "Panel_reward")
    self.Image_Open = me.assignWidget(self, "Image_Open")
    self.state = 1
    self:initActivity()
    return true
end
function NewYear:initActivity()
    if tonumber(user.activityDetail.open) == 1 then
        self:initTopBar()
        self:initScoreBox()
        self.Image_Open:setVisible(true)
    else
        self:initTopBar()
        self.Image_Open:setVisible(false)
        me.assignWidget(self,"Text_Close"):setVisible(true)
        me.assignWidget(self, "Text_25"):setVisible(false)
        me.assignWidget(self, "new_year_num_bg"):setVisible(false)
    end
    self.Button_AllRank:setVisible(user.activityDetail.show)

end
function NewYear:initRank()
    self.Panel_Integra:setVisible(false)
    self.Panel_Rank:setVisible(true)
    self.Panel_reward:setVisible(false)
    me.assignWidget(self, "rewardx_num"):setVisible(false)
    me.assignWidget(self, "reward_txt_bg"):setVisible(false)
    me.assignWidget(self, "rewardx_bg"):setVisible(false)
end
function NewYear:initAllRank()
    self.Panel_Integra:setVisible(false)
    self.Panel_Rank:setVisible(true)
    self.Panel_reward:setVisible(false)
    me.assignWidget(self, "rewardx_num"):setVisible(false)
    me.assignWidget(self, "rewardx_bg"):setVisible(false)
    me.assignWidget(self, "reward_txt_bg"):setVisible(false)
end
function NewYear:dragonBox()
    self.Panel_Integra:setVisible(false)
    self.Panel_reward:setVisible(true)
    self.Panel_Rank:setVisible(false)
    local pData = user.activityDetail
    -- 福卷
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    self.Panel_reward:removeAllChildren()
    local pGoodLuck = me.assignWidget(self, "new_year_num")
    pGoodLuck:setString(pData["GoogLuckNum"])
    me.assignWidget(self, "rewardx_num"):setVisible(true)
    me.assignWidget(self, "reward_txt_bg"):setVisible(true)
    me.assignWidget(self, "rewardx_bg"):setVisible(true)
    me.assignWidget(self, "rewardx_num"):setString(user.activityDetail.exg)
    local pGoodTabId = 0
    for key, var in pairs(pData["GoogLuckTab"]) do
        local pPanel_reward_cell = me.assignWidget(self, "Panel_reward_cell"):clone():setVisible(true)
        
        local Button_change = me.assignWidget(pPanel_reward_cell, "Button_change")
        local reward_num = me.assignWidget(pPanel_reward_cell, "reward_num")
        reward_num:setString(var["num"])
        local pDef = cfg[CfgType.ETC][var.id]
        if pData["GoogLuckNum"] >= var["num"] then
            reward_num:setTextColor(me.convert3Color_("#FFF47E"))
            self:setButton(Button_change, true)
        else
            reward_num:setTextColor(me.convert3Color_("#DA3E3E"))
            self:setButton(Button_change, false)
        end
        Button_change:setContentSize(cc.size(153, 51))
        Button_change:setTag(key)
        me.registGuiClickEvent(Button_change, function(node)
            print("Button_change" .. node:getTag())
            me.assignWidget(self, "New_Year__Info_bg"):setVisible(false)
            local pId = node:getTag()
            local pOneData = pData["GoogLuckTab"][pId]
            if pData["GoogLuckNum"] >= pOneData["num"] then
                NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, pOneData["id"], NewYear.GOODLUCK))
            end
        end )
        pPanel_reward_cell:setTag(key)
        me.assignWidget(pPanel_reward_cell,"Text_Gift_Name"):setString(pDef.name)
        me.registGuiClickEvent(pPanel_reward_cell, function(node)
            me.assignWidget(self, "New_Year__Info_bg"):setVisible(false)
            local pId = node:getTag()
            local pOneData = pData["GoogLuckTab"][pId]
            local def = cfg[CfgType.ETC][pOneData.id]
            local gdc = giftDetailCell:create("giftDetailCell.csb")
            gdc:setItemData(def.useEffect)
            me.runningScene():addChild(gdc, me.MAXZORDER)
        end )
        pGoodTabId = pGoodTabId + 1
        self.Panel_reward:pushBackCustomItem(pPanel_reward_cell)
    end
end
function NewYear:initScoreBox()
    self.Panel_Integra:setVisible(true)
    me.assignWidget(self, "rewardx_num"):setVisible(false)
    me.assignWidget(self, "reward_txt_bg"):setVisible(false)
    me.assignWidget(self, "rewardx_bg"):setVisible(false)
    self.Panel_Rank:setVisible(false)
    local pData = user.activityDetail
    -- 福卷
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    local pGoodLuck = me.assignWidget(self, "new_year_num")
    pGoodLuck:setString(pData["GoogLuckNum"])
    -- 积分
    local Intergr_num = me.assignWidget(self, "Intergr_num")
    Intergr_num:setString(pData["IntegrNum"])
    local LoadingBar_Integ = me.assignWidget(self, "LoadingBar_Integ")
    local Panel_Integr_tab = me.assignWidget(self, "Panel_Integr_tab")
    Panel_Integr_tab:removeAllChildren()
    self.Panel_reward:removeAllChildren()
    local width = LoadingBar_Integ:getContentSize().width
    local pInregId = 1
    local sum = 0
    for key, var in pairs(pData["IntegrTab"]) do
        local pPanel_Integr_cell = me.assignWidget(self, "Panel_Integr_cell"):clone():setVisible(true)
        pPanel_Integr_cell:setPositionX(width / table.nums(pData["IntegrTab"]) * pInregId - 20)

        local pDef = cfg[CfgType.ETC][var["id"]]
        local pGoodLuackIcon = me.assignWidget(pPanel_Integr_cell, "Integr_icon")

        pGoodLuackIcon:loadTexture(getItemIcon(pDef.id), me.plistType)

        local pNum = me.assignWidget(pPanel_Integr_cell, "Integr_cell_num")
        pNum:setString(var["num"])
        if var["num"] > sum then
             sum =  var["num"]
        end
        local function itemIsGot(pEctId)
            for key, var in pairs(pData["IntegrReward"]) do
                if me.toNum(pEctId) == me.toNum(key) then
                    return true
                end
            end
            return false
        end
        if pData["IntegrNum"] >= var["num"] then
            if itemIsGot(var["id"]) then
                me.assignWidget(pPanel_Integr_cell, "Integr_recive_icon"):setVisible(true)
                me.assignWidget(pPanel_Integr_cell, "Panel_animation"):setVisible(false)
            else
                me.assignWidget(pPanel_Integr_cell, "Integr_recive_icon"):setVisible(false)
                me.assignWidget(pPanel_Integr_cell, "Panel_animation"):setVisible(true)
                local anim = createArmature("i_button_activit_1")
                anim:getAnimation():play("i_button_activity")
                anim:setAnchorPoint(cc.p(0.5, 0.5))
                anim:setScale(0.5)
                anim:setPosition(cc.p(47, 0))
                me.assignWidget(pPanel_Integr_cell, "Panel_animation"):addChild(anim)
            end
        else
            me.assignWidget(pPanel_Integr_cell, "Panel_animation"):setVisible(false)
            me.assignWidget(pPanel_Integr_cell, "Integr_recive_icon"):setVisible(false)
        end
        local pNum = me.assignWidget(pPanel_Integr_cell, "Integr_cell_num")
        pNum:setString(var["num"])
        local Integr_icon = me.assignWidget(pPanel_Integr_cell, "Integr_icon")
        Integr_icon:setTag(key)

        me.registGuiClickEvent(Integr_icon, function(node)
            print("Integr_icon" .. node:getTag())
            me.assignWidget(self, "New_Year__Info_bg"):setVisible(false)
            local pId = node:getTag()
            local pCheckBool = true
            local pOneData = pData["IntegrTab"][pId]
            if pData["IntegrNum"] >= var["num"] then
                if not itemIsGot(pOneData["id"]) then
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId, pOneData["id"], NewYear.INTEGR))
                    pCheckBool = false
                end
            end
            if pCheckBool then
                local def = cfg[CfgType.ETC][pOneData["id"]]
                local gdc = giftDetailCell:create("giftDetailCell.csb")
                gdc:setItemData(def.useEffect)
                me.runningScene():addChild(gdc, me.MAXZORDER)
            end
        end )
        if pInregId == table.nums(pData["IntegrTab"]) then
            me.assignWidget(pPanel_Integr_cell, "Image_line"):setVisible(false)
        end
        pInregId = pInregId + 1

        me.assignWidget(self, "Panel_Integr_tab"):addChild(pPanel_Integr_cell)
    end

    local pLoadingBar_Integ = me.assignWidget(self, "LoadingBar_Integ")
    pLoadingBar_Integ:setPercent(pData["IntegrNum"] / sum * 100)

end
function NewYear:setTableView(msg)
    self.listData = msg.c.list
    self.mNum = #self.listData

    local function numberOfCellsInTableView(table)
        return #self.listData
    end
    local function cellSizeForTable(table, idx)
        return 831, 60
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "activity_cell"):clone()
            cell:addChild(node)
            --node:setPosition(440, 30)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "activity_cell")
            node:setVisible(true)
        end
        local tmp = self.listData[me.toNum(idx + 1)]
        if tmp then
            dump(tmp)
            local bg_cell = me.assignWidget(node, "cell_rank_bg")
            local R_cell_rank_icon = me.assignWidget(node, "R_cell_rank_icon")
            local R_cell_rank = me.assignWidget(node, "R_cell_rank")
            local R_cell_name = me.assignWidget(node, "R_cell_name")
            local R_cell_level = me.assignWidget(node, "R_cell_level")
            local R_cell_unit = me.assignWidget(node, "R_cell_unit")
            local R_cell_num = me.assignWidget(node, "R_cell_num")

            R_cell_rank_icon:setVisible(true)
            R_cell_rank:setVisible(false)
            if idx + 1 == 1 then
                R_cell_rank_icon:loadTexture("paihang_diyiming.png", me.localType)
            elseif idx + 1 == 2 then
                R_cell_rank_icon:loadTexture("paihang_dierming.png", me.localType)
            elseif idx + 1 == 3 then
                R_cell_rank_icon:loadTexture("paihang_disanming.png", me.localType)
            else
                R_cell_rank:setString(me.toStr(idx + 1))
                R_cell_rank_icon:setVisible(false)
                R_cell_rank:setVisible(true)
            end
            R_cell_name:setString(tmp.item[3])
            R_cell_level:setString(tmp.item[4])
            R_cell_unit:setString(tmp.item[5])
            R_cell_num:setString(tmp.item[2])
            if idx % 2 == 0 then
                bg_cell:setVisible(false)
            else
                bg_cell:setVisible(true)
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self.Panel_Rank, "Image_table")
        self.tableView = cc.TableView:create(cc.size(831, 279))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(1, 1))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
    self.rank_num = 0
    local idx = 1
    for key, var in ipairs(self.listData) do
        print(var.item[1], user.uid)
        if tonumber(var.item[1]) == tonumber(user.uid) then
            self.rank_num = idx
            break
        end
        idx = idx + 1
    end
    if self.rank_num > 0 then
        self:setPointpitch(self.rank_num, self.mNum)
        me.assignWidget(self.myRank, "rankNum"):setVisible(true)
        me.assignWidget(self.myRank, "Text_85"):setString("我的排名")
    else
        me.assignWidget(self.myRank, "Text_85"):setString("未上榜")
        me.assignWidget(self.myRank, "rankNum"):setVisible(false)
    end
    me.assignWidget(self.myRank, "rankNum"):setString(self.rank_num)
end
function NewYear:setPointpitch(pTag, pTabNum)
    pTag = me.toNum(pTag)
    local pPointX = 580
    local pPointY =(pTabNum - pTag + 1) * 60 - 35
    if self.pPitchHint then
        self.pPitchHint:setPosition(cc.p(pPointX, pPointY))
    else
        self.pPitchHint = me.assignWidget(self, "rank_pitch_hint"):clone()
        self.tableView:addChild(self.pPitchHint)
        self.pPitchHint:setVisible(true)
        self.pPitchHint:setScale9Enabled(true)
        self.pPitchHint:ignoreContentAdaptWithSize(false)
        self.pPitchHint:setCapInsets(cc.rect(29, 29, 31, 31))
        self.pPitchHint:setContentSize(cc.size(1150, 70))
        self.pPitchHint:setPosition(cc.p(pPointX, pPointY))
        self.pPitchHint:setLocalZOrder(10)
    end
end

function NewYear:pitchcellhint()
    self.pPitchHint:stopAllActions()
    local a5 = cc.Blink:create(0.9, 2)
    self.pPitchHint:runAction(a5)
    self.BlinkTime = me.registTimer(2, function(dt)
        self.Blink_Bool = true
    end , 1.2)
end

function NewYear:setButton(button, b)
    button:setBright(b)
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function NewYear:update(msg)
    if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
        if self.state == 1 then
            self:initScoreBox()
        elseif self.state == 2 then
            self:dragonBox()
        end
    elseif checkMsg(msg.t, MsgCode.WORLD_RANK_LIST) then
        if msg.c.typeId == rankView.PROMITION_NEWYEAR or msg.c.typeId == rankView.PROMITION_NEWYEARTOTAL then
            self:setTableView(msg)
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_LIMIT_REWARDS) then
        if self.rewardView  == nil then
            self.rewardView = NewYearReawrd:create("NewYearReawrd.csb")
            self.rewardView:setRewardType(msg.c.type, msg.c.award, function()
                self.rewardView = nil
            end )
            self.rewardView:setRewardInfos()
            me.popLayer(self.rewardView)
        else
            self.rewardView:setRewardType(msg.c.type, msg.c.award, function()
                self.rewardView = nil
            end )
            self.rewardView:setRewardInfos()
        end
    end
end
function NewYear:initTopBar()
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(user.activityDetail.desc or activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end
    local Text_countDown = me.assignWidget(self, "Text_countDown")
    if tonumber(user.activityDetail.open) == 1 then
            local leftT = user.activityDetail.cd
            Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
            self.timer = me.registTimer(leftT, function()
                if me.toNum(leftT) <= 0 then
                     me.clearTimer(self.timer)
                    Text_countDown:setString("活动结束")
                end
                Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
                leftT = leftT - 1
            end , 1)      
    else
        local leftT = user.activityDetail.cd
        Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动开启")
            end
            Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)

    end
end
function NewYear:onEnter()
    print("NewYear onEnter")

    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)

    --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW)] == 1 then
        -- 移除红点
        removeRedpoint(ACTIVITY_ID_GIFT_NEWYEAR_CHIANA_NEW)
    --end
end
function NewYear:onEnterTransitionDidFinish()
    print("NewYear onEnterTransitionDidFinish")
end
function NewYear:onExit()
    print("NewYear onExit")
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.timer)
    -- 删除消息通知
end
function NewYear:close()
    self:removeFromParentAndCleanup(true)
end
