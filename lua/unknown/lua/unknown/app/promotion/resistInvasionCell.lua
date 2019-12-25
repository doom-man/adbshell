resistInvasionCell = class("resistInvasionCell",function(...)
    return cc.CSLoader:createNode(...)
end)
resistInvasionCell.__index = resistInvasionCell
function resistInvasionCell:create(...)
    local layer = resistInvasionCell.new(...)
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

function resistInvasionCell:ctor()
    print("resistInvasionCell:ctor()")
end
function resistInvasionCell:init()
    
    self.startPanel = me.assignWidget(self, "startPanel")
    self.closePanel = me.assignWidget(self, "closePanel")
    self.tipsTxt = me.assignWidget(self.closePanel, "tipsTxt")
    self.ItemPanel = me.assignWidget(self.closePanel, "ItemPanel")

    self.timer = nil

    me.registGuiClickEventByName(self,"boxclose",function (args)
       self.scoreBoxLayer :setVisible(false)
    end)


    local function openAward()
        local award = resistInvasionCellRewards:create("resistInvasionCell_rewards.csb")
        me.popLayer(award)
        NetMan:send(_MSG.CheckActivity_ResistInvasion_Reward(resistInvasionCellRewards.diyuRewardType))
    end
    me.registGuiClickEventByName(self,"Button_award",openAward)
    me.registGuiClickEventByName(self,"Button_award_0",openAward)

    me.registGuiClickEventByName(self,"Button_setting",function (args)
        if user.guard_patrol_status==1 then
            showTips("部队正巡逻中")
            return
        end
        NetMan:send(_MSG.guard_init())
        local choose = defSoldierChoose:create("defSoldierChoose.csb")
        me.popLayer(choose)
    end)

    local function openRank()
        local pRank = rankView:create("rank/rankview.csb")
        pRank:setRankRype(rankView.RESIST_INVASION_RANK)
        pRank:ParentNode(self)
        me.runningScene():addChild(pRank, me.MAXZORDER)
        me.showLayer(pRank, "bg_frame")
        self.mRankView = pRank
        NetMan:send(_MSG.rankList(19))
    end
    me.registGuiClickEventByName(self,"Button_rank",openRank)
    me.registGuiClickEventByName(self,"Button_rank_0",openRank)

    local function openReport()

        local mailview = mailview:create("mailview.csb",9,1)
        me.runningScene():addChild(mailview, me.MAXZORDER);
        me.showLayer(mailview, "bg_frame")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.mailview = mailview
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            pWorldMap.mailview = mailview
        end
    end
    me.registGuiClickEventByName(self,"Button_report",openReport)
    me.registGuiClickEventByName(self,"Button_report_1",openReport)
    me.registGuiClickEventByName(self,"enemyDetailBtn",function (args)
        local detail = resistEnemyDetail:create("resistEnemyDetail.csb")
        me.runningScene():addChild(detail, me.MAXZORDER);
        me.showLayer(detail, "bg")
        NetMan:send(_MSG.activityResistEnemyDetail())
    end)
    me.registGuiClickEventByName(self.closePanel,"Button_oset",function (args)
        local set = allotTimesSet:create("allotTimes.csb")
        set:setCur(self.wave)
        me.popLayer(set)
    end)
    me.registGuiClickEventByName(self.startPanel,"Button_oset",function (args)
        local set = allotTimesSet:create("allotTimes.csb")
        set:setCur(self.wave)
        me.popLayer(set)
    end)
    self.joinBtn = me.assignWidget(self, "joinBtn")
    me.registGuiClickEvent(self.joinBtn,handler(self, self.joinActivity))
    return true
end
function resistInvasionCell:onEnter()  
    print("resistInvasionCell:onEnter()") 
    self.rt = mRichText:create('',662)
    local Panel_richText = me.assignWidget(self,"Panel_richText")
    self.rt:setPosition(0,Panel_richText:getContentSize().height)
    self.rt:setAnchorPoint(cc.p(0,1))
    Panel_richText:addChild(self.rt)

    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_RESIST_INVASION or msg.c.activityId == ACTIVITY_ID_RESIST_INVASION_NEW then
                self:setViewData()
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_RESIST_UPDATE) then
            self:updateFightProgress(msg.c)
        elseif checkMsg(msg.t, MsgCode.MSG_SET_WAVE) then
            self.wave = msg.c.maxW
        end      
    end ) 

    self:setViewData()
    me.doLayout(self,me.winSize)  
end

function resistInvasionCell:setViewData()
    self.rt:setString(user.activityDetail.desc)
    if user.activityDetail.status == 2 then
        self:initOpenViewData()
    else
        self:initCloseViewData()
    end
end

function resistInvasionCell:onExit()
    print("resistInvasionCell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    me.clearTimer(self.timer)
end

function resistInvasionCell:initCloseViewData()
    self.rewardData = user.activityDetail.award
    self.countdown = user.activityDetail.countdown
    self.startPanel:setVisible(false)
    self.closePanel:setVisible(true)

    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end
    if user.activityDetail.status == 4 or user.activityDetail.status == 3 or user.activityDetail.status == 1 then
        self.joinBtn:setBright(false)
    else
        self.joinBtn:setBright(true)
    end

    me.assignWidget(self, "enemyPower"):setString("Lv"..user.activityDetail.level)

    local imageTitle = me.assignWidget(self.joinBtn, "image_title")

    local timeStr = "后开启报名"
    if user.activityDetail.status == 1 then
        if user.activityDetail.signup==1 then
            imageTitle:loadTexture("huodong_manzu_w1.png", me.localType)  --已报名
            self.tipsTxt:setString("报名结束，活动即将开始")
        else
            imageTitle:loadTexture("huodong_manzu_w5.png", me.localType)  --报 名
            self.tipsTxt:setString("报名结束，无法继续报名")
        end
        timeStr = "后蛮族开始进攻"
    elseif user.activityDetail.status == 3 then
        imageTitle:loadTexture("huodong_manzu_w5.png", me.localType)  --报 名
        self.tipsTxt:setString("活动未开启")
    elseif user.activityDetail.status == 4 then
        timeStr = "后结束"
        imageTitle:loadTexture("huodong_manzu_w4.png", me.localType)  --报名结束
        self.tipsTxt:setString("报名结束，无法继续报名")
    elseif user.activityDetail.status == 0 then
        if user.activityDetail.signup==1 then
            imageTitle:loadTexture("huodong_manzu_w3.png", me.localType)  --取消报名
            self.tipsTxt:setString("报名阶段结束前可取消并重新报名，阶段结束后将不能更改报名状态")
        else
            imageTitle:loadTexture("huodong_manzu_w2.png", me.localType)  --报 名
            self.tipsTxt:setString("报名后，活动期间蛮族部队将会攻击您的主城")
        end
        timeStr = "后结束报名"
    end
    
    imageTitle:ignoreContentAdaptWithSize(true)

    me.assignWidget(self,"activityTime_close"):setString(me.formartSecTime(self.countdown)..timeStr)
    self.timer = me.registTimer(-1,function ()
        self.countdown = self.countdown - 1
        if self.countdown <= 0 then
            self.countdown = 0
        end
        me.assignWidget(self,"activityTime_close"):setString(me.formartSecTime(self.countdown)..timeStr)
    end,1)

    local listView1 = me.assignWidget(self.closePanel, "ListView_1")
    
    listView1:removeAllItems()
    for key, var in ipairs(self.rewardData) do
        local item = BackpackCell:create("backpack/backpackcell.csb")
        var.defid=var[1]
        var.count=var[2]
        item:setUI(var)  
        iPanel = self.ItemPanel:clone():setVisible(true)
        item:setScale(0.6)
        iPanel:addChild(item)
        listView1:pushBackCustomItem(iPanel)
        me.assignWidget(item, "num_bg"):setVisible(false)
        local btnBg = me.assignWidget(item,"Button_bg")
        btnBg:setSwallowTouches(false)
        me.registGuiClickEvent(btnBg,function ()
            showPromotion(var.defid)
        end)  
    end
    if #self.rewardData<5 then
        listView1:setBounceEnabled(false)
        listView1:setPositionX(318+(97*(5-#self.rewardData))/2)
        listView1:setContentSize(cc.size(97*#self.rewardData, 117.42))
    end
end

function resistInvasionCell:joinActivity()
    if user.activityDetail.status == 3 then
        showTips("活动未开启")
    elseif user.activityDetail.status == 1 then
        showTips("活动处于准备阶段")
    elseif user.activityDetail.status == 4 then
        showTips("报名已结束")
    else
        if user.activityDetail.signup==1 then
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
        else
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
        end
    end
end

function resistInvasionCell:initOpenViewData()
    self.countdown = user.activityDetail.countdown
    self.startPanel:setVisible(true)
    self.closePanel:setVisible(false)

    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end

    local str = "<txt0016,ec8d1e>当前第&<txt0016,e2d29c>"..user.activityDetail.wave.."&<txt0016,ec8d1e>/"..user.activityDetail.maxWave.."波&"
    if self.openRichTxt==nil then
        self.openRichTxt = mRichText:create(str)
        self.openRichTxt:setPosition(337, 111.15)
        self.startPanel:addChild(self.openRichTxt)
    else
        self.openRichTxt:setString(str)
    end
    if #user.activityDetail.fail>=3 then
        str = "<txt0016,EC8D1E>已抵御失败三次，结束进攻&"
        self.openRichTxt:setString(str)
        self.openRichTxt:setPosition(257, 111.15)
        me.assignWidget(self.startPanel, "Text_18"):setVisible(false)
    end
    if user.activityDetail.wave > self.wave then
        str = "<txt0016,EC8D1E>已达到设定的抵御波数，结束进攻&"
        self.openRichTxt:setString(str)
        self.openRichTxt:setPosition(257, 111.15)
        me.assignWidget(self.startPanel, "Text_18"):setVisible(false)
    end
    me.assignWidget(self,"activityTime_open"):setString(me.formartSecTime(self.countdown).."后结束")
    self.timer = me.registTimer(-1,function ()
        self.countdown = self.countdown - 1
        if self.countdown <= 0 then
            self.countdown = 0
        end
        me.assignWidget(self,"activityTime_open"):setString(me.formartSecTime(self.countdown).."后结束")
    end,1)
    for i=1, 3 do
        if user.activityDetail.fail[i]==nil then
            break
        end
        me.assignWidget(self.startPanel,"LoadingBar_process_"..i):setVisible(true)
        me.assignWidget(self.startPanel,"Text_process_"..i):setVisible(true)
        me.assignWidget(self.startPanel,"Text_process_"..i):setString("战斗第"..user.activityDetail.fail[i].."波失败")
    end
    
    self:fillData(user.activityDetail.rank)
    --self:initProgressTable()
    --self:initRewardTable()
end

function resistInvasionCell:updateFightProgress(data)
    for i=1, 3 do
        if data.fail[i]==nil then
            break
        end
        me.assignWidget(self.startPanel,"LoadingBar_process_"..i):setVisible(true)
        me.assignWidget(self.startPanel,"Text_process_"..i):setVisible(true)
        me.assignWidget(self.startPanel,"Text_process_"..i):setString("战斗第"..data.fail[i].."波失败")
    end

    local str = "<txt0016,ec8d1e>当前第&<txt0016,e2d29c>"..data.wave.."&<txt0016,ec8d1e>/"..user.activityDetail.maxWave.."波&"
    if #data.fail>=3 then
        str = "<txt0016,EC8D1E>已抵御失败三次，结束进攻&"
        self.openRichTxt:setString(str)
        self.openRichTxt:setPosition(257, 111.15)
        me.assignWidget(self.startPanel, "Text_18"):setVisible(false)
    else
        self.openRichTxt:setString(str)
    end
end

function resistInvasionCell:fillData(data)
    local table_cell = me.assignWidget(self.startPanel, "table_cell")
    local listNode = me.assignWidget(self.startPanel, "listNode")
    listNode:removeAllChildren()

    for i, v in ipairs(data) do
        local node = table_cell:clone():setVisible(true)
        node:setPosition(0, 174-i*43-3)
        listNode:addChild(node)
        me.assignWidget(node, "cellBg"):setVisible(i%2==0)
        local txt = me.assignWidget(node, "noTxt")
        if v.index == 1 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_diyiming.png", me.localType)
            txt:setVisible(false)
        elseif v.index == 2 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_dierming.png", me.localType)
            txt:setVisible(false)
        elseif v.index == 3 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_disanming.png", me.localType)
            txt:setVisible(false)
        end
        me.assignWidget(node, "nameTxt"):setString(v.name)
        me.assignWidget(node, "lvTxt"):setString(v.value)
    end
    local node = table_cell:clone():setVisible(true)
    me.assignWidget(node, "icon"):setVisible(false)
    node:setPosition(0,-2)
    me.assignWidget(self.startPanel, "myRank"):addChild(node)
    local txt = me.assignWidget(node, "noTxt")
    if user.activityDetail.myRank==0 then
        txt:setString("未上榜")
    else    
        txt:setString(user.activityDetail.myRank)
    end
    me.assignWidget(node, "nameTxt"):setString(user.name)
    me.assignWidget(node, "lvTxt"):setString(user.activityDetail.myRankValue)
end

function resistInvasionCell:initRewardTable()
    table.sort(self.rewardData,function(a,b)
        return a.integeral < b.integeral    
    end)

    local function numberOfCellsInTableView(table)
        return #self.rewardData
    end

    local function cellSizeForTable(table, idx)
        return 700,75
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil

        if nil == cell then
            cell = cc.TableViewCell:new()
            node = cc.CSLoader:createNode("highVeryDayRewardItem.csb")

            cell:addChild(node)
            node:setTag(5555)
            if idx%2 == 0 then
                me.assignWidget(node,"Panel_reward"):loadTexture("default.png")
            else
                me.assignWidget(node,"Panel_reward"):loadTexture("alliance_cell_bg.png")
            end
        else
            node = cell:getChildByTag(5555)
        end
        local tmp = self.rewardData[me.toNum(idx+1)]
        if tmp then
            local Panel_items = me.assignWidget(node,"Panel_items")
            Panel_items:removeAllChildren()
            me.assignWidget(node,"Text_current_score"):setString(tmp.integeral.."积分")
            for key, var in pairs(tmp.Items) do
                local itemDef = cfg[CfgType.ETC][var.defId]
                local tmpButtonItem = me.assignWidget(node,"Button_item"):clone()
                tmpButtonItem:setSwallowTouches(false)
                tmpButtonItem:setVisible(true)
                Panel_items:addChild(tmpButtonItem)
                tmpButtonItem:setPosition(cc.p(me.toNum(key*80), Panel_items:getContentSize().height/2))
                me.assignWidget(tmpButtonItem,"Image_quality"):loadTexture(getQuality(itemDef.quality),me.localType)
                me.assignWidget(tmpButtonItem,"Goods_Icon"):loadTexture("item_"..itemDef.icon..".png",me.localType)
                me.assignWidget(tmpButtonItem,"label_num"):setString(var.defNum)
                me.registGuiClickEvent(tmpButtonItem,function (node)
                    showPromotion(var.defId,var.defNum)
                end) 
            end
        end
        return cell
    end
    if self.tableView_Reward == nil then
        local Panel_item = me.assignWidget(self, "Panel_items")
        self.tableView_Reward = cc.TableView:create(cc.size(700,384))
        self.tableView_Reward:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView_Reward:setDelegate()
        self.tableView_Reward:setPosition(cc.p(0,0))
        Panel_item:addChild(self.tableView_Reward)
        self.tableView_Reward:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView_Reward:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView_Reward:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView_Reward:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView_Reward:reloadData()
end