--[[
	文件名：PvpMainView.lua
	描述：跨服争霸主页面
	创建人：libowen
	创建时间：2019.10.19
--]]

PvpMainView = class("PvpMainView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpMainView.__index = PvpMainView

-- 战场分组
PvpMainView.GroupType = {
    TIAN = 1,   -- 天阶
    REN = 2,    -- 人阶
    DI = 3,     -- 地阶
}
-- 战场名
PvpMainView.GroupName = {
    [PvpMainView.GroupType.TIAN] = "天阶战场",
    [PvpMainView.GroupType.REN] = "人阶战场",
    [PvpMainView.GroupType.DI] = "地阶战场",
}
-- 比赛阶段
PvpMainView.PvpStage = {
    SIGN_UP = 1,        -- 报名
    PRESELECTION = 2,   -- 海选
    MATCH_32_16 = 3,    -- 32进16
    MATCH_16_8 = 4,     -- 16进8
    MATCH_8_4 = 5,      -- 8进4
    MATCH_4_2 = 6,      -- 半决赛
    MATCH_2_1 = 7,      -- 决赛
}
-- 独立阶段
PvpMainView.STAGE_SHOWING = 8 -- 展示阶段
-- 阶段名
PvpMainView.StageName = {
    [PvpMainView.PvpStage.SIGN_UP] = "报名",
    [PvpMainView.PvpStage.PRESELECTION] = "海选",
    [PvpMainView.PvpStage.MATCH_32_16] = "32进16",
    [PvpMainView.PvpStage.MATCH_16_8] = "16进8",
    [PvpMainView.PvpStage.MATCH_8_4] = "8进4",
    [PvpMainView.PvpStage.MATCH_4_2] = "半决赛",
    [PvpMainView.PvpStage.MATCH_2_1] = "决赛",
}
-- 是否处于报名阶段
PvpMainView.inSignUp = false
-- 是否为历史状态，活动结束进入页面显示的为历史数据，活动开启进入页面显示的是当前数据
PvpMainView.isHistory = false

function PvpMainView:create(...)
    local layer = PvpMainView.new(...)
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
function PvpMainView:ctor()
    print("PvpMainView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_INFO) then
            self.pvpInfo = msg.c
            PvpMainView.inSignUp = msg.c.status == PvpMainView.PvpStage.SIGN_UP
            -- 定时器，检测是否需要重新拉取数据
            self:countdown()
            -- 刷新阶段节点
            self:refreshStageNodes()
            -- 刷新内容节点
            self:refreshContentNode()
        elseif checkMsg(msg.t, MsgCode.PVP_SIGN_UP) then
            self.pvpInfo.list = msg.c.list
            self.pvpInfo.inReg = msg.c.inReg
        end
    end)
    -- 获取活动信息
    NetMan:send(_MSG.get_pvp_info(0))
end

-- 初始化
function PvpMainView:init()
    print("PvpMainView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 内容节点
    self.node_content = me.assignWidget(self, "node_content")
    -- 标题
    self.img_title = me.assignWidget(self, "img_title")
    -- 规则
    self.btn_rule = me.assignWidget(self, "btn_rule")
    me.registGuiClickEvent(self.btn_rule, function(sender)
        local ruleList = {
            "<txt0018,D4CDB9>1.阵容设置：在报名前需要先设置比赛所用的上中下三路跨服阵容，所有数据均为镜像数据，本玩法不会出现伤亡与损失，并且阵容只能在报名阶段内修改，报名结束后仅能调整队伍分路。注意：比赛用的士兵、英雄、战舰、圣物、属性加成和buff效果以报名时各分路配置的效果为准，本服当前激活的圣物和英雄属性在活动中不生效；&",
            "<txt0018,D4CDB9>2.胜负判定：所有赛程均为单淘汰赛制，对决时双方上中下三路同时进行战斗，上路VS上路，中路VS中路，下路VS下路，在2路以上战胜对手即为本场获胜，败者淘汰；&",
            "<txt0018,D4CDB9>3.报名：需要在报名阶段选择与自己等级匹配的争霸赛场进行报名，未在报名阶段进行报名的将不能参与后续的比赛，可在报名期间取消再重新报名以更新属性效果；注意：某组如果报名的人数不足32人，该组将取消比赛；&",
            "<txt0018,D4CDB9>4.海选：系统将各赛场报名的玩家自动匹配对手进行对决，胜者继续进行匹配，败者淘汰，直到选出32个玩家，晋级下一轮比赛；&",
            "<txt0018,D4CDB9>5.32进16：系统将海选产生的32强自动匹配分组，分为16组比赛，每组胜者进入下一轮，败者淘汰；&",
            "<txt0018,D4CDB9>6.16进8：系统将上一轮胜出的16个玩家自动匹配分组，分为8组比赛，每组胜者进入下一轮，败者淘汰；&",
            "<txt0018,D4CDB9>7.8进4：系统将上一轮胜出的8个玩家自动匹配分组，分为8组比赛，分布在对阵图的左右两侧，每组胜者进入下一轮，败者淘汰；&",
            "<txt0018,D4CDB9>8.半决赛：对阵图左右两侧进入半决赛的两个玩家进行对决，胜者进入决赛，败者淘汰；&",
            "<txt0018,D4CDB9>9.决赛：对阵图左侧半决赛胜者与右侧半决赛胜者进行最终对决，胜者为本次比赛冠军，败者为本次比赛亚军；&",
            "<txt0018,D4CDB9>10.竞猜：从8进4开始，所有玩家可进行竞猜，如果竞猜的选手进入下一轮，将根据选手最终的奖金获得奖励；&",
            "<txt0018,D4CDB9>11.竞猜限制：不能竞猜自己或者自己当前的对手，每轮竞猜次数有限制，竞猜次数达到上限将不能再竞猜；&",
            "<txt0018,D4CDB9>12.赛事奖励：自己所有比赛都结束时，根据自己所获得的最高名次获得赛事奖励；&",
        }
        local view = PvpRuleView:create("pvp/PvpRuleView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
        view:setRuleList(ruleList)
    end)
    -- 详细赛程
    self.btn_race = me.assignWidget(self.img_bg, "btn_race")
    self.btn_race:setVisible(false)
    me.registGuiClickEvent(self.btn_race, function(sender)
        local view = PvpDetailScheduleView:create("pvp/PvpDetailScheduleView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
    end)
    -- 奖励
    self.btn_reward = me.assignWidget(self.img_bg, "btn_reward")
    self.btn_reward:setVisible(false)
    me.registGuiClickEvent(self.btn_reward, function(sender)
        local view = PvpRewardView:create("pvp/PvpRewardView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
    end)
    -- 个人战报
    self.btn_report = me.assignWidget(self, "btn_report")
    self.btn_report:setVisible(false)
    me.registGuiClickEvent(self.btn_report, function(sender)
        local view = PvpFightReportView:create("pvp/PvpFightReportView.csb")
        self:addChild(view)
        me.showLayer(view, "img_bg")
        view:setReportType(1)
    end)
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
        self:removeFromParent()
    end)
    -- 阶段节点
    for _, v in pairs(PvpMainView.PvpStage) do
        local key = "node_stage"..v
        self[key] = me.assignWidget(self.img_bg, key)
        self[key]:setVisible(false)
    end
    -- 跨服阵容
    self.btn_formation = me.assignWidget(self.img_bg, "btn_formation")
    me.registGuiClickEvent(self.btn_formation, function(sender)
        if self.pvpInfo.status == PvpMainView.PvpStage.SIGN_UP then
            local view = PvpFormationSettingView:create("pvp/PvpFormationSettingView.csb")
            self:addChild(view)
            me.showLayer(view, "img_bg")
            view:setFinishCallback(function()
                -- 三路都设置完毕
                if self.pvpInfo.status == PvpMainView.PvpStage.SIGN_UP then
                    self.pvpInfo.line = true
                    self.btn_formation:removeAllChildren()
                end
            end)
            view:setSignUpStatus(self.pvpInfo.inReg)
        elseif self.pvpInfo.status == PvpMainView.STAGE_SHOWING then
            showTips("比赛已结束，不能设置跨服阵容")
        else
            if not self.pvpInfo.inReg then
                showTips("您未报名，不能设置跨服阵容")
            elseif self.pvpInfo.faild then
                showTips("您已被淘汰，不能设置跨服阵容")
            else
                me.DelayRun(function()
                    showTips("当前阶段只能更换分路，不能调整阵容配置")
                end, 0.5)
                local view = PvpFormationSettingView:create("pvp/PvpFormationSettingView.csb")
                self:addChild(view)
                me.showLayer(view, "img_bg")
                view:setSignUpStatus(self.pvpInfo.inReg)
            end
        end
    end)
    
    return true
end

-- 定时器，检测是否需要重新拉取数据
function PvpMainView:countdown()
    me.clearTimer(self.timer)
    -- 查看历史 or 展示阶段
    if self.pvpInfo.history or self.pvpInfo.status == PvpMainView.STAGE_SHOWING then
        return
    end
    -- 每个阶段都有开始前、进行中、已结束3种状态，状态间切换需要重新拉取数据，以实时刷新
    local function getStatusString()
        local tmpStr = ""
        for i, v in ipairs(self.pvpInfo.stages) do
            if me.sysTime() < v.start then
                tmpStr = v.status.."_not_begin"
                break
            elseif me.sysTime() <= v.close then
                tmpStr = v.status.."_on_going"
                break
            end
        end
        return tmpStr
    end
    local oldStr = getStatusString()
    self.timer = me.registTimer(-1, function()
        local newStr = getStatusString()
        if newStr ~= oldStr then
            -- 重新获取活动信息
            NetMan:send(_MSG.get_pvp_info(0))
        end
    end, 1.0)
end

-- 刷新阶段节点
function PvpMainView:refreshStageNodes()
    -- 查看历史
    if self.pvpInfo.history then
        for _, v in pairs(PvpMainView.PvpStage) do
            local key = "node_stage"..v
            local stageNode = self[key]
            stageNode:setVisible(false)
        end
        self.btn_formation:setVisible(false)
        return
    end
    local week = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
    for _, v in pairs(PvpMainView.PvpStage) do
        local key = "node_stage"..v
        local stageNode = self[key]
        stageNode:setVisible(true)
        local info = self.pvpInfo.stages[v]
        -- 按钮展示
        local btn_show = me.assignWidget(stageNode, "btn_show")
        -- 阶段名
        local text_name = me.assignWidget(stageNode, "text_name")
        -- 时间段
        local text_time = me.assignWidget(stageNode, "text_time")
        local tempStr = string.format("%s%s~%s", week[info.date], me.formartServerTime2(info.start / 1000), me.formartServerTime2(info.close / 1000))
        text_time:setString(tempStr)
        -- 状态
        local text_status = me.assignWidget(stageNode, "text_status")
        if info.status < self.pvpInfo.status then
            --btn_show:loadTextures("kuafuzhengba_16.png", "kuafuzhengba_16.png", "kuafuzhengba_16.png", me.localType)
            text_status:setString("已结束")
            --text_name:setTextColor(cc.c3b(0x88, 0x86, 0x86))
            --text_time:setTextColor(cc.c3b(0x88, 0x86, 0x86))
            text_status:setTextColor(cc.c3b(0x88, 0x86, 0x86))
        elseif info.status == self.pvpInfo.status then
            if me.sysTime() < info.start then
                --btn_show:loadTextures("kuafuzhengba_7.png", "kuafuzhengba_7.png", "kuafuzhengba_7.png", me.localType)
                text_status:setString("即将开始")
                --text_name:setTextColor(cc.c3b(0xa2, 0x8d, 0x74))
                --text_time:setTextColor(cc.c3b(0xa2, 0x8d, 0x74))
                text_status:setTextColor(cc.c3b(0x57, 0xd0, 0x3b))
            elseif me.sysTime() <= info.close then
                --btn_show:loadTextures("kuafuzhengba_8.png", "kuafuzhengba_8.png", "kuafuzhengba_8.png", me.localType)
                text_status:setString("进行中")
                --text_name:setTextColor(cc.c3b(0xa2, 0x8d, 0x74))
                --text_time:setTextColor(cc.c3b(0xa2, 0x8d, 0x74))
                text_status:setTextColor(cc.c3b(0xa2, 0x8d, 0x74))
            else
                --btn_show:loadTextures("kuafuzhengba_16.png", "kuafuzhengba_16.png", "kuafuzhengba_16.png", me.localType)
                text_status:setString("已结束")
                --text_name:setTextColor(cc.c3b(0x88, 0x86, 0x86))
                --text_time:setTextColor(cc.c3b(0x88, 0x86, 0x86))
                text_status:setTextColor(cc.c3b(0x88, 0x86, 0x86))
            end
        else
            --btn_show:loadTextures("kuafuzhengba_16.png", "kuafuzhengba_16.png", "kuafuzhengba_16.png", me.localType)
            text_status:setString("未开始")
            --text_name:setTextColor(cc.c3b(0xd4, 0xcd, 0xb9))
            --text_time:setTextColor(cc.c3b(0xd4, 0xcd, 0xb9))
            text_status:setTextColor(cc.c3b(0xff, 0x02, 0x02))
        end
    end
    -- 队伍尚未设置完毕
    if self.pvpInfo.status == PvpMainView.PvpStage.SIGN_UP and not self.pvpInfo.line then
        self.btn_formation:removeAllChildren()
        -- 等级是否达到某一组的要求
        local reach = false
        for k, v in pairs(self.pvpInfo.list) do
            if v.levelAchieve == 1 then
                reach = true
                break
            end
        end
        if reach then
            local tempSize = self.btn_formation:getContentSize()
            local ani = createArmature("circle_ani")
            ani:setPosition(cc.p(tempSize.width / 2 - 3, tempSize.height / 2 + 4))
            self.btn_formation:addChild(ani)
            ani:setScale(1.32)
            ani:getAnimation():playWithIndex(0)
        else
            me.registGuiClickEvent(self.btn_formation, function(sender)
                showTips("不满足任何组的报名条件，不能设置跨服阵容")
            end)
        end
    end
end

-- 刷新内容节点
function PvpMainView:refreshContentNode()
    self.node_content:removeAllChildren()
    if self.pvpInfo.status == PvpMainView.PvpStage.SIGN_UP then
        self.btn_race:setVisible(false)
        self.btn_reward:setVisible(true)
        self.btn_report:setVisible(false)
        local node = PvpSignUpNode:create("pvp/PvpSignUpNode.csb")
        node:setData(self.pvpInfo.list)
        self.node_content:addChild(node)
    elseif self.pvpInfo.status == PvpMainView.PvpStage.PRESELECTION then
        self.btn_race:setVisible(false)
        self.btn_reward:setVisible(true)
        -- 海选记录
        self.btn_report:setVisible(true)
        self.btn_report:loadTextures("kuafuzhengba_39.png", "", "", me.localType)
        me.registGuiClickEvent(self.btn_report, function(sender)
            if not self.pvpInfo.election.join then
                showTips("尚未参赛")
                return
            end
            local view = PvpRecordView:create("pvp/PvpRecordView.csb")
            self:addChild(view)
            me.showLayer(view, "img_bg")
        end)
        local node = PvpPreselectionNode:create("pvp/PvpPreselectionNode.csb")
        node:setData(self.pvpInfo)
        self.node_content:addChild(node)
    elseif self.pvpInfo.status == PvpMainView.PvpStage.MATCH_32_16 or self.pvpInfo.status == PvpMainView.PvpStage.MATCH_16_8 then
        self.btn_race:setVisible(true)
        self.btn_reward:setVisible(true)
        self.btn_report:setVisible(true)
        local node = PvpMatchNode:create("pvp/PvpMatchNode.csb")
        node:setData(self.pvpInfo)
        self.node_content:addChild(node)
    elseif self.pvpInfo.status == PvpMainView.PvpStage.MATCH_8_4 or self.pvpInfo.status == PvpMainView.PvpStage.MATCH_4_2
        or self.pvpInfo.status == PvpMainView.PvpStage.MATCH_2_1 or self.pvpInfo.status == PvpMainView.STAGE_SHOWING then
        self.btn_race:setVisible(true)
        self.btn_reward:setVisible(true)
        self.btn_report:setVisible(true)
        local node = PvpResultNode:create("pvp/PvpResultNode.csb")
        node:setData(self.pvpInfo)
        self.node_content:addChild(node)
    end
end

function PvpMainView:onEnter()
    print("PvpMainView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpMainView:onEnterTransitionDidFinish()
    print("PvpMainView onEnterTransitionDidFinish")
end

function PvpMainView:onExit()
    print("PvpMainView onExit")
    UserModel:removeLisener(self.lisener)
    me.clearTimer(self.timer) 
end
