herolevelRight = class("herolevelRight",function(...)
    return cc.CSLoader:createNode(...)
end)

function herolevelRight:create(...)
    local layer = herolevelRight.new(...)
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

function herolevelRight:ctor()
    print("herolevelRight:ctor()")
    --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)
    end)
end
function herolevelRight:init()
    print("herolevelRight:init()")

    self.area1Btn = me.assignWidget(self, "area1Btn")
    me.registGuiClickEvent(self.area1Btn, handler(self, self.onClickArea1))
    self.area2Btn = me.assignWidget(self, "area2Btn")
    me.registGuiClickEvent(self.area2Btn, handler(self, self.onClickArea2))
    return true
end
function herolevelRight:onEnter()
    me.doLayout(self,me.winSize)  

    self.table_cell = me.assignWidget(self, "table_cell")

    self.gotoBtn = me.assignWidget(self, "gotoBtn")
    me.registGuiClickEvent(self.gotoBtn, handler(self, self.gotoZhengfu))

    self.rankBtn = me.assignWidget(self, "rankBtn")
    me.registGuiClickEvent(self.rankBtn, handler(self, self.gotoRank))
end

function herolevelRight:setButton(button,b)
	button:setEnabled(b)
	local title = me.assignWidget(button,"Text_title")
	if b then
		title:setTextColor(cc.c4b(0x84, 0x7b, 0x6c, 0xff))        
	else
		title:setTextColor(cc.c4b(0xe9, 0xdc, 0xaf, 0xff))
	end
end

function herolevelRight:onClickArea1(node)
    self:setButton(self.area1Btn,false)
    self:setButton(self.area2Btn,true)
    self:fillData(self.data.rank.list, 1)
end

function herolevelRight:onClickArea2(node)
    self:setButton(self.area1Btn,true)
    self:setButton(self.area2Btn,false)
    self:fillData(self.data.worldRank.list, 2)
end 

function herolevelRight:setData(data)
    self.data = data
    local nowTxt = me.assignWidget(self, "nowTxt")
    nowTxt:setString(self.data.currentLv)
    me.assignWidget(self, "now2Txt"):setPositionX(nowTxt:getPositionX()+nowTxt:getContentSize().width+3)

    local maxTxt = me.assignWidget(self, "maxTxt")
    maxTxt:setString(self.data.max)
    me.assignWidget(self, "max2Txt"):setPositionX(maxTxt:getPositionX()+maxTxt:getContentSize().width+3)

    if data.rank.rank==-1 then
        me.assignWidget(self, "topTxt1"):setString("未上榜")
        me.assignWidget(self, "topTxt1"):setTextColor(cc.c4b(0xf2, 0x4f, 0x4a, 0xff))
    else
        me.assignWidget(self, "topTxt1"):setString("第"..data.rank.rank.."名")
        me.assignWidget(self, "topTxt1"):setTextColor(cc.c4b(0xf9, 0xe4, 0xc2, 0xff))
    end

    if data.worldRank.rank==-1 then
        me.assignWidget(self, "topTxt2"):setString("未上榜")
        me.assignWidget(self, "topTxt2"):setTextColor(cc.c4b(0xf2, 0x4f, 0x4a, 0xff))
    else
        me.assignWidget(self, "topTxt2"):setString("第"..data.worldRank.rank.."名")
        me.assignWidget(self, "topTxt2"):setTextColor(cc.c4b(0xf9, 0xe4, 0xc2, 0xff))
    end

    self:fillData(self.data.rank.list, 1)
    self:setButton(self.area1Btn,false)
    self:setButton(self.area2Btn,true)
end

function herolevelRight:fillData(data, tabId)
    local listNode = me.assignWidget(self, "listNode")
    listNode:removeAllChildren()
    local tempHeight = listNode:getContentSize().height
    for i, v in ipairs(data) do
        local node = self.table_cell:clone():setVisible(true)
        node:setPosition(cc.p(0, tempHeight - i * 52))
        listNode:addChild(node)
        local txt = me.assignWidget(node, "noTxt")
        local areaTxt = me.assignWidget(node, "areaTxt")
        areaTxt:setVisible(tabId == 2)
        if i == 1 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_diyiming.png", me.localType)
            if v.item[5] then
                areaTxt:setVisible(true)
                areaTxt:setString("("..v.item[5].."区)")
            end
            txt:setVisible(false)
        elseif i == 2 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_dierming.png", me.localType)
            if v.item[5] then
                areaTxt:setVisible(true)
                areaTxt:setString("("..v.item[5].."区)")
            end
            txt:setVisible(false)
        elseif i == 3 then
            me.assignWidget(node, "icon"):setVisible(true)
            me.assignWidget(node, "icon"):loadTexture("paihang_disanming.png", me.localType)
            if v.item[5] then
                areaTxt:setVisible(true)
                areaTxt:setString("("..v.item[5].."区)")
            end
            txt:setVisible(false)
        else
            me.assignWidget(node, "icon"):setVisible(false)
            txt:setString(i)
            if v.item[5] then
                areaTxt:setString("("..v.item[5].."区)")
                areaTxt:setVisible(true)
            else
                areaTxt:setVisible(false)
            end
        end
        me.assignWidget(node, "panel"):setVisible(i % 2 == 0)
        me.assignWidget(node, "nameTxt"):setString(v.item[3])
        me.assignWidget(node, "lvTxt"):setString("Lv."..v.item[4])
        me.assignWidget(node, "numsTxt"):setString(v.item[2].."关")
    end
end


function herolevelRight:gotoZhengfu(node)
    showWaitLayer()
    NetMan:send(_MSG.HeroLevel_conquer())
end

function herolevelRight:gotoRank(node)
    local pRank = rankView:create("rank/rankview.csb")
    pRank:setRankRype(rankView.HERO_LEVEL_RANK)
    pRank:ParentNode(self)
    me.runningScene():addChild(pRank, me.MAXZORDER)
    me.showLayer(pRank, "bg_frame")
    self.mRankView = pRank
    NetMan:send(_MSG.rankList(17))
end

function herolevelRight:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_HEROLEVEL_CONQUER) then
        local conquerObj = mainCity:getChildByTag(7777)
        if conquerObj and not tolua.isnull(conquerObj) then
            -- 当前已经有conquer界面
        else
            disWaitLayer()
            local conquerPanel = conquer:create("herolevel/conquer.csb")
            conquerPanel:setData(msg.c)
            conquerPanel:setTag(7777)
            mainCity:addChild(conquerPanel, me.MAXZORDER)        
            me.showLayer(conquerPanel,"bg")
        end
    end
end

function herolevelRight:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
    me.clearTimer(self.freeTimeId)
    me.clearTimer(self.pTime)

end
