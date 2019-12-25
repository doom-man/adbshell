--[[
	文件名：SevenLoginCell.lua
	描述：七日登录内容节点
	创建人：libowen
	创建时间：2019.12.5
--]]
SevenLoginCell = class("SevenLoginCell", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
SevenLoginCell.__index = SevenLoginCell

function SevenLoginCell:create(...)
    local layer = SevenLoginCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
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

-- 构造器
function SevenLoginCell:ctor()
    print("SevenLoginCell ctor")
    self.lisener = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_SEVEN_LOGIN then
                self.info = msg.c
                self:refreshView()
            end
        end
    end)
end

-- 初始化
function SevenLoginCell:init()
    print("SevenLoginCell init")
    -- 节点
    for i = 1, 7 do
        local key = "img_"..i
        self[key] = me.assignWidget(self, key)
    end
    -- 领取按钮
    self.btn_get = me.assignWidget(self, "btn_get")
    -- 时间节点
    self.node_time = me.assignWidget(self, "node_time")
    self.text_time = me.assignWidget(self, "text_time")
    -- 奖励模板
    self.layout_item = me.assignWidget(self, "layout_item")
    self.layout_item:setVisible(false)

    return true
end

-- 数据初始化
function SevenLoginCell:setData(info)
    self.info = info
    self:refreshView()
end

-- 刷新页面
function SevenLoginCell:refreshView()
    table.sort(self.info.items or {}, function(a, b)
        return a.id < b.id
    end)
    -- 是否有可领取的，是否全部领完
    local canDraw, allGot = false, true
    for idx, item in ipairs(self.info.items or {}) do
        local key = "img_"..idx
        -- 奖励列表
        local listView = me.assignWidget(self[key], "listView")
        listView:setScrollBarEnabled(false)
        listView:removeAllItems()
        if idx < 7 then
            for i, v in ipairs(item.reward or {}) do
                local layout_item = self:createCustomItem(v, item.status)
                listView:pushBackCustomItem(layout_item)
            end
        else
            -- 战舰展示节点，第7天专属
            local layout_ship = me.assignWidget(self[key], "layout_ship")
            layout_ship:removeAllChildren()
            local tempMap = {[631] = 101, [632] = 201, [633] = 301}
            local id = item.reward and item.reward[1] and item.reward[1][1]
            local shipId = tempMap[id]
            if shipId then
                local cfg_ship = cfg[CfgType.SHIP_DATA][shipId]
                listView:setVisible(false)
                layout_ship:setVisible(true)
                me.registGuiClickEvent(layout_ship, function()
                    if item.status == 1 then
                        NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_SEVEN_LOGIN))
                    else
                        local view = WarShipShowView:create("WarShipShowView.csb")
                        view:setData(cfg_ship)
                        me.runningScene():addChild(view, me.MAXZORDER)
                        me.showLayer(view, "img_bg")
                    end
                end)
                local sk = sp.SkeletonAnimation:create("animation/anim_zhanjian_0" .. cfg_ship.type .. ".json", "animation/anim_zhanjian_0" .. cfg_ship.type .. ".atlas", 1)
                sk:setPosition(cc.p(140, 60))
                sk:setScale(0.6)
                layout_ship:addChild(sk)
                sk:setAnimation(0, "animation1", true)
            else
                layout_ship:setVisible(false)
                listView:setVisible(true)
                for i, v in ipairs(item.reward or {}) do
                    local layout_item = self:createCustomItem(v, item.status)
                    listView:pushBackCustomItem(layout_item)
                end
            end
        end
        -- 已领取标识   0:不可领取,1:可领取，2:已领取
        local node_got = me.assignWidget(self[key], "node_got")
        node_got:setVisible(item.status == 2)
        -- 光效
        local text_day = me.assignWidget(self[key], "text_day")
        text_day:removeAllChildren()
        if idx < 7 then
            if item.status == 1 then
                local aniNode = createArmature("huodong_donghua-1")
                aniNode:getAnimation():play("huodong_donghua")
                aniNode:setAnchorPoint(cc.p(0.5, 0.5))
                aniNode:setScale(0.7)
                aniNode:setPosition(cc.p(25, idx <= 4 and -56 or -76))
                text_day:addChild(aniNode)
            end
        else
            local aniNode = mAnimation.new("item_ani")
            aniNode:fishPaly("idle")
            aniNode:setPosition(cc.p(60, -150))
            text_day:addChild(aniNode)
        end
        if item.status == 1 then
            canDraw = true
        end
        if item.status ~= 2 then
            allGot = false
        end
    end
    -- 能否领取
    local text_title_btn = me.assignWidget(self.btn_get, "text_title_btn")
    self.node_time:stopAllActions()
    if allGot then
        self.node_time:setVisible(false)
        text_title_btn:setString("已领取")
        self.btn_get:setEnabled(false)
        -- 移除红点
        removeRedpoint(ACTIVITY_ID_SEVEN_LOGIN)
    else
        me.registGuiClickEvent(self.btn_get, function(sender)
            NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_SEVEN_LOGIN))
        end)
        if canDraw then
            self.node_time:setVisible(false)
            text_title_btn:setString("领取道具")
            self.btn_get:setEnabled(true)
        else
            self.node_time:setVisible(true)
            text_title_btn:setString("领取道具")
            self.btn_get:setEnabled(false)
            local leftTime = self.info.countdown
            local function countdown()
                if leftTime >= 0 then
                    local timeStr = me.formartSecTimeHour(leftTime)
                    self.text_time:setString(timeStr)
                    leftTime = leftTime - 1
                else
                    self.node_time:stopAllActions()
                    self.node_time:setVisible(false)
                    self.btn_get:setEnabled(true)
                end
            end
            countdown()
            self.node_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.DelayTime:create(1.0),
                cc.CallFunc:create(function()
                    countdown()
                end)
            )))
            -- 移除红点
            removeRedpoint(ACTIVITY_ID_SEVEN_LOGIN)
        end
    end
end

-- 创建单个cell
function SevenLoginCell:createCustomItem(v, status)
    local cfg_item = cfg[CfgType.ETC][v[1]]
    local layout_item = self.layout_item:clone()
    layout_item:setVisible(true)
    me.registGuiClickEvent(layout_item, function()
        if status == 1 then
            NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_SEVEN_LOGIN))
        else
            showPromotion(v[1], v[2])
        end
    end)
    -- 底框
    local img_quality = me.assignWidget(layout_item, "img_quality")
    img_quality:loadTexture(getQuality(cfg_item.quality))
    -- icon
    local img_icon = me.assignWidget(layout_item, "img_icon")
    img_icon:loadTexture(getItemIcon(cfg_item.id))
    -- 描述
    local img_desc_bg = me.assignWidget(layout_item, "img_desc_bg")
    local text_desc = me.assignWidget(layout_item, "text_desc")
    if cfg_item.showtxt and cfg_item.showtxt ~= "" then
        img_desc_bg:setVisible(true)
        text_desc:setVisible(true)
        text_desc:setString(cfg_item.showtxt)
    else
        img_desc_bg:setVisible(false)
        text_desc:setVisible(false)
    end
    -- 数量
    local text_num = me.assignWidget(layout_item, "text_num")
    text_num:setString(Scientific(v[2]))
    return layout_item
end

function SevenLoginCell:onEnter()
    print("SevenLoginCell onEnter")
end

function SevenLoginCell:onEnterTransitionDidFinish()
    print("SevenLoginCell onEnterTransitionDidFinish")
end

function SevenLoginCell:onExit()
    print("SevenLoginCell onExit")
    UserModel:removeLisener(self.lisener)
end
