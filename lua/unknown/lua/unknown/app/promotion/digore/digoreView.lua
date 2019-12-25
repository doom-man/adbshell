-- [Comment]
-- jnmo
digoreView = class("digoreView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
digoreView.__index = digoreView
function digoreView:create(...)
    local layer = digoreView.new(...)
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
function digoreView:ctor()
    print("digoreView ctor")
    self.modelkey = UserModel:registerLisener( function(msg)
        if checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_SHOW) then
            self:initPageData(msg.c)
            if self.jumpPageNode~=nil then
                self:jumpPageFromServer(self.jumpPageNode)
                self.jumpPageNode=nil
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_ARMY_LIST) then
            self:initArmyList(msg.c, 0)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_ARMY_UPDATE) then
            self:updateArmyItem(msg.c, 1)
        elseif checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT) or checkMsg(msg.t, MsgCode.ROLE_BE_ATTACK_ALERT_REMOVE) then
            user.warningListNum = #user.warningList
            self.warningBtn:setVisible(#user.warningList > 0)
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_MAIL_NEW) then
            if user.activity_mail_new[20] and user.activity_mail_new[20]>0 then
                me.assignWidget(self.reportBtn, "redpoint"):setVisible(true)
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_DIGORE_ARMY_CALLBACK_QUICK) then
            if self.soldierAni[msg.c.id] then
                local snode = self.soldierAni[msg.c.id]
                snode:setVisible(false)
                table.insert(self.soldierAniCache, snode)
                self.soldierAni[msg.c.id]=nil
                self:removePath(snode)
            end
        end      
    end )
end


function digoreView:initArmyList(data, from)
    for _, v in ipairs(data.list) do
        self:updateArmyItem(v, from)
    end
end

function digoreView:updateArmyItem(data, from)
    local armyIndex=0
    local item=nil
    for k, v in ipairs(self.armyList) do   --查找队列中是否有军队
        if v.data and v.data.id==data.id then
            armyIndex=k
            item=v
            break
        end
    end
    if armyIndex==0 then    --查找空闲队列
        armyIndex=1
        item = self.armyList[armyIndex]
        if item.empty==false then
            armyIndex=2
            item = self.armyList[armyIndex]
            if item.empty==false then
                return
            end
        end
    end

    item.empty=false
    item.data=data
    me.assignWidget(item, "posTxt"):setString("第"..data.page.."页"..(data.index%5+1).."号秘宝")
    me.assignWidget(item, "Button_Farter"):setVisible(false)
    me.assignWidget(item, "armyNums"):setString(data.alive.."/"..data.total)
    me.assignWidget(item, "clickPanel").data=nil
    local pIcon = me.assignWidget(item, "troopline_icon")
    if data.status == 2000 or data.status == 2003 then
        pIcon:loadTexture("troop_state_33.png", me.localType)
        if data.status==2000 and from==1 then
            self:march(data.id, data.countdown, self.oreList[data.index%5+1], 0)
        end
    elseif data.status == 2001 then
        pIcon:loadTexture("troop_state_28.png", me.localType)

        me.assignWidget(item, "Button_Farter"):setVisible(true)
        me.assignWidget(item, "Button_Farter").data=data
        me.assignWidget(item, "Button_Farter"):loadTextureNormal("troop_quickBtn.png", me.localType)
        if  from==1 then
            self:march(data.id, data.countdown, self.oreList[data.index%5+1], 1)
        end
    elseif data.status == 2002 then
        pIcon:loadTexture("troop_state_27.png", me.localType)
        me.assignWidget(item, "Button_Farter"):setVisible(true)
        me.assignWidget(item, "Button_Farter"):loadTextureNormal("troop_backBtn.png", me.localType)
        me.assignWidget(item, "Button_Farter").data=data
        me.assignWidget(item, "clickPanel").data=data
    end

    if self.armyTimerList[data.id]~=nil then
        me.clearTimer(self.armyTimerList[data.id])
        self.armyTimerList[data.id]=nil
    end
    local trooplineTime = me.assignWidget(item, "troopline_time")
    local trooplineBar = me.assignWidget(item, "LoadingBar_Time")

    local totalTime=data.countdown
    local countdown=data.countdown

    trooplineTime:setString(me.formartSecTime(countdown))
    trooplineBar:setPercent(0)

    local timer = me.registTimer(-1,function ()
        countdown=countdown-1
        local p = (countdown/totalTime)*100
        trooplineBar:setPercent(100-p)
        trooplineTime:setString(me.formartSecTime(countdown))
        if countdown<=0 then
            item.empty=true
            me.clearTimer(self.armyTimerList[data.id])
            self.armyTimerList[data.id]=nil
            self:clearArmyItem(armyIndex)
        end
    end,1)
    self.armyTimerList[data.id]=timer
end
function digoreView:clearArmyItem(index)
    local item = self.armyList[index]
    item.empty=true
    item.data=nil
    me.assignWidget(item, "posTxt"):setString("")
    me.assignWidget(item, "troopline_time"):setString("空闲中")
    me.assignWidget(item, "LoadingBar_Time"):setPercent(0)
    me.assignWidget(item, "Button_Farter"):setVisible(false)
    me.assignWidget(item, "armyNums"):setString("0/0")
    local pIcon = me.assignWidget(item, "troopline_icon")
    pIcon:ignoreContentAdaptWithSize(true)
    pIcon:loadTexture("troop_empty.png", me.localType)
end

function digoreView:init()
    print("digoreView init")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.rankBtn = me.assignWidget(self, "rankBtn")
    me.registGuiClickEvent(self.rankBtn, handler(self, self.gotoRank))

    self.reportBtn = me.registGuiClickEventByName(self, "reportBtn", function(node)
        local mailview = mailview:create("mailview.csb",mailview.MAILDIGORE,1)
        me.runningScene():addChild(mailview, me.MAXZORDER);
        me.showLayer(mailview, "bg_frame")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            mainCity.mailview = mailview
        else
            pWorldMap.mailview = mailview
        end
        me.assignWidget(self.reportBtn, "redpoint"):setVisible(false)
        user.activity_mail_new[20]=0
    end)

    if user.activity_mail_new[20] and user.activity_mail_new[20]>0 then
        me.assignWidget(self.reportBtn, "redpoint"):setVisible(true)
    end

    self.rankBtn = me.registGuiClickEventByName(self, "rankBtn", function(node)
        local pRank = rankView:create("rank/rankview.csb")
        pRank:setRankRype(rankView.DIGORE_SCORE_RANK)
        pRank:ParentNode(self)
        me.runningScene():addChild(pRank, me.MAXZORDER)
        me.showLayer(pRank, "bg_frame")
        self.mRankView = pRank
        NetMan:send(_MSG.digoreRank(1, 103))
    end)

    self.foeBtn = me.registGuiClickEventByName(self, "foeBtn", function(node)
        local pRank = rankView:create("rank/rankview.csb")
        pRank:setRankRype(rankView.DIGORE_ENEMY_RANK)
        pRank:digoreGroud(self.groupId)
        pRank:ParentNode(self)
        me.runningScene():addChild(pRank, me.MAXZORDER)
        me.showLayer(pRank, "bg_frame")
        self.mRankView = pRank
        NetMan:send(_MSG.digoreRank(self.groupId, 105))
    end)

    self.awardBtn = me.registGuiClickEventByName(self, "awardBtn", function(node)
        local pAward = digoreRewards:create("digore/digore_rewards.csb")
        me.runningScene():addChild(pAward, me.MAXZORDER)
        me.showLayer(pAward, "bg")
        NetMan:send(_MSG.CheckActivity_Limit_Reward(17))
    end)

    self.shopBtn = me.registGuiClickEventByName(self, "shopBtn", function(node)
        local pShop = digoreShop:create("digore/digoreShop.csb")
        me.runningScene():addChild(pShop, me.MAXZORDER)
        me.showLayer(pShop, "bg_frame")
        NetMan:send(_MSG.initShop(17))
    end)

    self.warningBtn = me.registGuiClickEventByName(self, "Button_warning", function(node)
        local warning = warningView:create("warningView.csb")
        if CUR_GAME_STATE == GAME_STATE_CITY then
            warning:setInCityStatus(true)
        else
            warning:setInCityStatus(false)
        end
        self:addChild(warning, me.MAXZORDER)
        me.showLayer(warning, "bg")
    end)
    self.warningBtn:setVisible(#user.warningList > 0)

    me.registGuiClickEventByName(self, "Button_Help", function(node)
        local help = digoreHelp:create("digore/digoreHelp.csb")
        me.popLayer(help)
    end )

    self.troopLineItem = me.assignWidget(self, "troopLineItem")
    self.armyList = {}
    self.armyTimerList={}
    for i=1, 2 do
        self.armyList[i]=self.troopLineItem:clone():setVisible(true)
        me.assignWidget(self, "next_bg"):addChild(self.armyList[i])
        me.assignWidget(self.armyList[i], "Queuetag"):setString(i)

        me.registGuiClickEventByName(self.armyList[i], "clickPanel", handler(self, self.openToPage))
        me.registGuiClickEventByName(self.armyList[i], "Button_Farter", handler(self, self.openFarter))
        self.armyList[i]:setPosition(56, 600-(i-1)*80)
        self:clearArmyItem(i)
    end

    self.pageNode = me.assignWidget(self, "pageNode")
    self.pageBtnCon = me.assignWidget(self.pageNode, "pageBtnCon")
    self.pageBox = me.assignWidget(self.pageNode, "pageBox")
    self.paddingPanel = me.assignWidget(self.pageNode, "paddingPanel")
    self.pageBox:setScrollBarEnabled(false)

    me.registGuiClickEventByName(self.pageNode, "prevPageBtn", handler(self, self.jumpPrevPage))
    me.registGuiClickEventByName(self.pageNode, "nextPageBtn", handler(self, self.jumpNextPage))
    self.curPage=1
    self.maxPage=0
    
    self.timerList={}
    self.protectTimerList={}
    self.oreList = {}
    for i=1, 5 do
        self.oreList[i]=me.assignWidget(self, "ore"..i)
        self.oreList[i]:setVisible(false)
        me.registGuiClickEvent(self.oreList[i], handler(self, self.openDetail))
    end

    self.nongminPos = me.assignWidget(self, "nongminPos")
    self.minerFarmerCache = {}  --挖矿农民池

    self.soldierAniCache = {}
    self.soldierAni = {}
    self.soldierAniNode=me.assignWidget(self, "soldierAniNode")
	
	self.chatPanel = require("app/promotion/digore/digoreChatBox"):create(self, "chatNode")

    return true
end

function digoreView:gotoRank(node)
    local pRank = rankView:create("rank/rankview.csb")
    pRank:setRankRype(rankView.HERO_LEVEL_RANK)
    pRank:ParentNode(self)
    me.runningScene():addChild(pRank, me.MAXZORDER)
    me.showLayer(pRank, "bg_frame")
    self.mRankView = pRank
    NetMan:send(_MSG.rankList(17))
end


function digoreView:setTitleIndex(j)
    for i=1, 3 do
        if i==j then
            me.assignWidget(self, "title"..i):setVisible(true)
        else
            me.assignWidget(self, "title"..i):setVisible(false)
        end
    end
end

function digoreView:initPageData(data)
    if data.pageSize~=self.maxPage then
        self.maxPage=data.pageSize
        self:makePage()
    end
    local tmp = {}
    for _, v in ipairs(data.list) do
        local index = v.index%5+1
        tmp[index]=v
    end

    if self.timer~=nil then
        me.clearTimer(self.timer)
        self.timer=nil
    end
    self.groupId=data.id
    self.updateTime = data.updateTime
    local updateTimeTxt = me.assignWidget(self, "updateTimeTxt")
    updateTimeTxt:setString(me.formartSecTime(self.updateTime))
    self.timer = me.registTimer(-1,function ()
        self.updateTime = self.updateTime - 1
        if self.updateTime <= 0 then
            self.updateTime = 0

            NetMan:send(_MSG.digoreShow(self.groupId, self.curPage))
            me.clearTimer(self.timer)
            self.timer = nil
        end
        updateTimeTxt:setString(me.formartSecTime(self.updateTime))
    end,1)

    for _, v in pairs(self.timerList) do
        me.clearTimer(v)
    end
    self.timerList={}
    for _, v in pairs(self.protectTimerList) do
        me.clearTimer(v)
    end
    self.protectTimerList={}
    

    for i=1, 5 do
        self.oreList[i]:setVisible(true)
        self:fillOreData(self.oreList[i], tmp[i])
    end
end

function digoreView:fillOreData(node, data)
    local nongmin = me.assignWidget(node, "nongmin")
    for _, v in ipairs(nongmin:getChildren()) do
        v:retain()
        table.insert(self.minerFarmerCache, v)
    end
    nongmin:removeAllChildren()

    if data==nil then
        node.data=nil
        me.assignWidget(node, "Image"):setVisible(false)
        me.assignWidget(node, "Image_3"):setVisible(false)
        me.assignWidget(node, "protectImg"):setVisible(false)
        me.Helper:grayImageView(node) 
    else
        node.data=data
        me.assignWidget(node, "Image"):setVisible(true)
        me.assignWidget(node, "Image_3"):setVisible(true)
        me.Helper:normalImageView(node)
        local base = cfg[CfgType.ORE_RES][data.id]
        local oreAttr = me.assignWidget(node, "oreAttr")
        local oreId = me.assignWidget(node, "oreId")
        oreAttr:setString(base.name)
        local color,_ = me.getColorByQuality(base.level)
        oreAttr:setTextColor(color)
        if data.server=="" then
            oreId:setString("")
        else
            oreId:setString("("..data.server..")")
        end

        me.assignWidget(node, "orePeopleNums"):setString("人数:"..data.player.."/"..base.numLimit)
        oreAttr:setPositionX(oreId:getPositionX()+oreId:getContentSize().width)

        local myself = me.assignWidget(node, "myself")
        if data.player==0 then
            myself:setVisible(false)
        else
            myself:setVisible(true)
            if data.mine==1 then
                myself:loadTexture("shijian_zhanling_ziji.png", me.localType)
            else
                if data.mineServer==false then
                    myself:loadTexture("shijian_zhanling_dieren.png", me.localType)
                else
                    myself:loadTexture("shijian_zhanling_mengyou.png", me.localType)
                end    
            end
        end

        --添加农民动画
        local pos0 = me.assignWidget(self.nongminPos, "pos0")
        local posTarget = cc.p(pos0:getPosition())
        for i=1, data.player do
            local farmer=nil
            local flag=false
            if #self.minerFarmerCache>0 then
                farmer=table.remove(self.minerFarmerCache, 1)
                flag=true
            else
                farmer = mAnimation.new("nongminAni")
            end
            local pos1 = me.assignWidget(self.nongminPos, "pos"..i)
            local posStart = cc.p(pos1:getPosition())
            farmer:setPosition(posStart)
            local dir = farmer:getDirPTP(posStart, posTarget)
            farmer:doAction(MANI_STATE_MINING, dir)
            me.assignWidget(node, "nongmin"):addChild(farmer)
            if flag==true then
                farmer:release()
            end
        end

        local oreLadingbar = me.assignWidget(node, "oreLadingbar")
        local oreProgress = me.assignWidget(node, "oreProgress")
        local p = math.floor(((base.totalTreasure-data.num)/base.totalTreasure)*100) --没有减data.player，初始化先不用计算采矿
        if p<0 then
            p=0
        end
        oreLadingbar:setPercent(p)
        oreProgress:setString(p.."%")

        local lastUpdate = data.lastUpdate
        local timer = me.registTimer(-1,function ()
            lastUpdate=lastUpdate-1
            if lastUpdate<=0 then
                lastUpdate=300
                local p = math.floor(((base.totalTreasure-data.num-data.player)/base.totalTreasure)*100)
                if p<0 then
                    p=0
                end
                oreLadingbar:setPercent(p)
                oreProgress:setString(p.."%")
            end
        end,1)
        self.timerList[data.index]=timer

        local protectTime = data.protectTime
        if protectTime>0 then
            me.assignWidget(node, "protectImg"):setVisible(true)
            local protectTimeTxt = me.assignWidget(node, "protectTimeTxt") 
            protectTimeTxt:setString(me.formartSecTime(protectTime).."后结束免战状态")
            if self.protectTimerList[data.index] then
                me.clearTimer(self.protectTimerList[data.index])
                self.protectTimerList[data.index]=nil
            end
            local timer1 = me.registTimer(-1,function ()
                protectTime=protectTime-1
                protectTimeTxt:setString(me.formartSecTime(protectTime).."后结束免战状态")
                if protectTime<=0 then  
                    me.assignWidget(node, "protectImg"):setVisible(false)
                    if self.protectTimerList[data.index] then
                        me.clearTimer(self.protectTimerList[data.index])
                        self.protectTimerList[data.index]=nil
                    end
                end
            end,1)
            self.protectTimerList[data.index]=timer1
        else
            me.assignWidget(node, "protectImg"):setVisible(false)
        end
    end
end


function digoreView:openFarter(node)
    if node.data~=nil then
        if node.data.status == 2002 then
            me.showMessageDialog("确定要召回这只部队吗", function(args)
                if args == "ok" then                                   
                    NetMan:send(_MSG.digoreCallback(node.data.id))
                end 
            end)
        else
            local date = os.date("%Y-%m-%d")
            local saveDiamondNotenoughTime = cc.UserDefault:getInstance():getStringForKey("armycallback_MessageDialog", "")
            if saveDiamondNotenoughTime == date  then
                GMan():send(_MSG.digoreCallbackQuick(node.data.id, true))
                return
            end
            local av = armyCallBackView:create("ArmyCallBackView.csb")                       
            local function cb(userDiamond)                
                GMan():send(_MSG.digoreCallbackQuick(node.data.id, userDiamond))
            end
            av:setCurrentData(0, 72, cb)
            me.runningScene():addChild(av, me.MAXZORDER)
        end
    end
end

function digoreView:openDetail(node)
    if node.data~=nil then
        local tmpView = digoreDetail:create("digore/digoreDetail.csb")
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "fixLayout")

        NetMan:send(_MSG.digoreDetail(self.groupId, node.data.index))
    end
end

function digoreView:makePage()
    
    self.pageBox:removeAllItems()

    local len = self.maxPage

    if 14>=len then
        local paddingLeft = (1140-len*80)/2
        local p = self.paddingPanel:clone():setVisible(true)
        p:setContentSize(cc.size(paddingLeft, 67))
        self.pageBox:addChild(p)
    end
    self.pageBox:setInnerContainerSize(cc.size(self.maxPage*80, 67))

    for i=1, len do
        local btn1 = self.pageBtnCon:clone()
        btn1:setVisible(true)
        self.pageBox:addChild(btn1)

        local btn = me.assignWidget(btn1, "pageBtn")
        btn.page=i
        me.registGuiClickEvent(btn,handler(self, self.jumpPage))  
        btn:setSwallowTouches(false)

        local pageImg = me.assignWidget(btn, "pageImg")
        pageImg:setString(i)
        if self.curPage==i then
            me.assignWidget(btn, "select"):setVisible(true)
        else
            me.assignWidget(btn, "select"):setVisible(false)
        end
    end
    if self.curPage>14 then
        local btn = self.pageBox:getItem(self.curPage-1)
        self:jumpPage(btn)
    end
end

function digoreView:jumpPage(node)
    
    local clickPage = node.page

    local function cloudOpen()
        local cloudLayer = me.assignWidget(self, "Panel_Cloud")
        cloudLayer:setVisible(true)
        local cloud_left = me.assignWidget(cloudLayer, "cloud_left")
        local cloud_right = me.assignWidget(cloudLayer, "cloud_right")
        cloud_left:setPosition(cc.p(cloud_left:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
        cloud_right:setPosition(cc.p(cloud_right:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
        local t = 0.5
        local a1 = cc.MoveTo:create(t, cc.p(- cloud_left:getContentSize().width / 2, - cloud_left:getContentSize().height / 2))
        local a2 = cc.MoveTo:create(t, cc.p(cloud_right:getContentSize().width * 3 / 2, cloud_right:getContentSize().height * 3 / 2))
        local function call(node)
            cloudLayer:setVisible(false)
        end
        local a3 = cc.CallFunc:create(call)
        cloud_left:runAction(cc.Sequence:create(a1, a3))
        cloud_right:runAction(a2)

    end

    local function cloudClose()
        local cloudLayer = me.assignWidget(self, "Panel_Cloud")
        cloudLayer:setVisible(true)
        local cloud_left = me.assignWidget(cloudLayer, "cloud_left")
        local cloud_right = me.assignWidget(cloudLayer, "cloud_right")
        cloud_left:setPosition(cc.p(- cloud_left:getContentSize().width / 2, - cloud_left:getContentSize().height / 2))
        cloud_right:setPosition(cc.p(cloud_right:getContentSize().width * 3 / 2, cloud_left:getContentSize().height * 3 / 2))
        local t = 0.5
        local a1 = cc.MoveTo:create(t, cc.p(cloud_left:getContentSize().width / 2, cloud_left:getContentSize().height / 2))
        local a2 = cc.MoveTo:create(t, cc.p(cloud_right:getContentSize().width / 2, cloud_right:getContentSize().height / 2))
        local function call(node1)
            cloudOpen()
            NetMan:send(_MSG.digoreShow(self.groupId, clickPage))
            self.jumpPageNode = node
        end
        local a3 = cc.CallFunc:create(call)
        local a4 = cc.DelayTime:create(0.2)
        cloud_left:runAction(cc.Sequence:create(a1, a4, a3))
        cloud_right:runAction(a2)
    end

    

    if self.curPage~=clickPage then
        cloudClose()

        for _, v in pairs(self.soldierAni) do
            v:stopAllActions()
            v:setPosition(610.03, 1.91)
            v:setVisible(false)
            self:removePath(v)
            table.insert(self.soldierAniCache, v)
        end
        self.soldierAni={}
    end
end



function digoreView:jumpPageFromServer(node)

    local clickPage = node.page

    local btn1
    if 14>=self.maxPage then
        btn1 = self.pageBox:getItem(self.curPage)
    else
        btn1 = self.pageBox:getItem(self.curPage-1)
    end
    local btn = me.assignWidget(btn1, "pageBtn")
    --btn:loadTextureNormal("digore20.png", me.localType)
    me.assignWidget(btn, "select"):setVisible(false)
    self.curPage=clickPage

    me.assignWidget(node, "select"):setVisible(true)
    --node:loadTextureNormal("digore24.png", me.localType)

    local clickIndex = self.pageBox:getIndex(node)


    --[[
    if self.maxPage>=14 then
        local s = self.pageBox:getInnerContainerSize()
        local pp = self.pageBox:getInnerContainerPosition()
        local p = node:getPositionX()
        if (self.curPage==self.maxPage-3 and -pp.x<=s.width-530) then
            self.pageBox:scrollToPercentHorizontal((p+270)/s.width*100, 0.3, true)
        elseif ((self.curPage==3 and pp.x<0) or p>270) and p+531/2<s.width+55 then
            p=p-270
            local call = cc.CallFunc:create(function()
                self.pageBox:setInnerContainerPosition(cc.p(-p, 0))
            end)    
            self.pageBox:getInnerContainer():stopAllActions()
            self.pageBox:getInnerContainer():runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(-p, 0)), call)) 
        end
    end
    ]]
end

function digoreView:jumpPrevPage(node)
    local clickPage = self.curPage-1
    if clickPage<1 then
        return
    end

    local btn
    if 14>=self.maxPage then
        btn = self.pageBox:getItem(clickPage)
    else
        btn = self.pageBox:getItem(clickPage-1)
    end
    self:jumpPage(btn)
end

function digoreView:jumpNextPage(node)
    local clickPage = self.curPage+1
    if clickPage>self.maxPage then
        return
    end

    local btn
    if 14>=self.maxPage then
        btn = self.pageBox:getItem(clickPage)
    else
        btn = self.pageBox:getItem(clickPage-1)
    end
    self:jumpPage(btn)

end

function digoreView:openToPage(node)
    if node.data~=nil then
        local clickPage = node.data.page
        if self.curPage==clickPage then
            return
        end
        local btn
        if 14>=self.maxPage then
            btn = self.pageBox:getItem(clickPage)
        else
            btn = self.pageBox:getItem(clickPage-1)
        end
        self:jumpPage(btn)
    end
end


function digoreView:removePath(soldierAniNode)
    for key, var in pairs(soldierAniNode.pathNodes) do
        if var then
            var:removeFromParentAndCleanup(true)
        end
    end
    soldierAniNode.pathNodes={}
end

function digoreView:createPath(soldierAniNode, path_)
    local op = path_[1]
    local tp = path_[2]
    local dis = cc.pGetDistance(op, tp)
    local w = 50
    local num = math.floor(dis / 50)
    local a = me.getAngle(op, tp)
    soldierAniNode.pathNodes = { }
    for var = 1, num do
        soldierAniNode.pathNodes[var] = me.createSprite("waicheng_tubiao_xingjun.png")
        soldierAniNode.pathNodes[var]:setScale(0.5)
        local p = me.circular(op, dis - var * w, a)
        soldierAniNode.pathNodes[var]:setPosition(p)
        soldierAniNode.pathNodes[var]:setRotation(360 - a)
        me.assignWidget(self, "nodePathUI"):addChild(soldierAniNode.pathNodes[var])
    end
end

---
-- 行军
-- mType 0出发 1返回
--
function digoreView:march(tagId, t, targetNode, mType)
    if self.soldierAni[tagId] then
        local snode = self.soldierAni[tagId]
        snode:setVisible(false)
        table.insert(self.soldierAniCache, snode)
        self.soldierAni[tagId]=nil
        self:removePath(snode)
    end

    local soldierAniNode=nil
    local soldierAni=nil
    if #self.soldierAniCache>0 then
        soldierAniNode=table.remove(self.soldierAniCache, 1)
        soldierAni=soldierAniNode:getChildByName("soldierAni")
    else
        soldierAniNode=cc.Node:create()
        soldierAni = mAnimation.new("lord")
        soldierAni:setName("soldierAni")
        soldierAniNode:addChild(soldierAni)
        me.assignWidget(self, "next_bg"):addChild(soldierAniNode)
    end

    soldierAniNode:setVisible(true)
    soldierAniNode:setPosition(610.03, 1.91)
    soldierAniNode:setTag(tagId)
    self.soldierAni[tagId]=soldierAniNode

    local startPos = nil
    local targetpos = nil
    if mType==0 then
        startPos = cc.p(self.soldierAniNode:getPosition())
        targetpos = cc.p(targetNode:getPosition())
    else
        targetpos = cc.p(self.soldierAniNode:getPosition())
        startPos = cc.p(targetNode:getPosition())
    end

    local dir = soldierAni:getDirPTP(startPos, targetpos)
    soldierAniNode:setPosition(startPos.x, startPos.y)
    soldierAni:doAction(MANI_STATE_MOVE, dir)

    soldierAniNode:stopAllActions()
    local a1 = cc.MoveTo:create(t, targetpos)
    local callc = cc.CallFunc:create(function() 
        soldierAniNode:setVisible(false)
        table.insert(self.soldierAniCache, soldierAniNode)
        self.soldierAni[tagId]=nil
        self:removePath(soldierAniNode)
    end)
    local seq = cc.Sequence:create(a1, callc)
    soldierAniNode:runAction(seq)
    self:createPath(soldierAniNode, {startPos, targetpos})
end


function digoreView:onEnter()
    print("digoreView onEnter")
    me.doLayout(self, me.winSize)
end
function digoreView:onEnterTransitionDidFinish()
    print("digoreView onEnterTransitionDidFinish")
end
function digoreView:onExit()
    print("digoreView onExit")

    for _, v in pairs(self.soldierAni) do
        v:stopAllActions()
        self:removePath(v)
    end
    self.soldierAni={}

    for _, v in pairs(self.timerList) do
        me.clearTimer(v)
    end
    self.timerList={}

    for _, v in pairs(self.protectTimerList) do
        me.clearTimer(v)
    end
    self.protectTimerList={}
    

    for _, v in pairs(self.armyTimerList) do
        me.clearTimer(v)
    end
    self.armyTimerList={}

    for _, v in pairs(self.minerFarmerCache) do
        v:release()
    end
    self.minerFarmerCache={}
    
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
end
function digoreView:close()
    self:removeFromParent()
end


