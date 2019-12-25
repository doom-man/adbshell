--[[
	文件名：PvpPreselectionNode.lua
	描述：跨服争霸海选节点
	创建人：libowen
	创建时间：2019.10.23
--]]

PvpPreselectionNode = class("PvpPreselectionNode", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpPreselectionNode.__index = PvpPreselectionNode

function PvpPreselectionNode:create(...)
    local layer = PvpPreselectionNode.new(...)
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
function PvpPreselectionNode:ctor()
    print("PvpPreselectionNode ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_PRESELECTION_DATA_UPDATE) then
        	if msg.c.group == self.info.group then
        		self.info.stp = msg.c.stp
        		self.info.election.curUser = msg.c.curUser
        		self.info.election.curRound = msg.c.curRound
        		self.info.election.countdown = msg.c.countdown
        		if msg.c.win ~= nil then
        			self.info.election.winTimes = msg.c.win
        		end
        		if msg.c.faild ~= nil then
        			self.info.election.faild = msg.c.faild
        		end
        		self:refreshView()
        	end
        end
    end)
end

-- 初始化
function PvpPreselectionNode:init()
    print("PvpPreselectionNode init")
    self.img_top = me.assignWidget(self, "img_top")
    -- xx后进行第xx场
    self.node_rich = me.assignWidget(self.img_top, "node_rich")
	self.node_rich:removeAllChildren()
    local richText = mRichText:create("", 770)
	richText:setAnchorPoint(cc.p(0, 0.5))
	self.node_rich:addChild(richText)
	self.richText = richText

    -- 我的战场
    self.img_center = me.assignWidget(self, "img_center")
    self.text_group = me.assignWidget(self.img_center, "text_group")
    -- 报名人数
    self.text_total_num = me.assignWidget(self.img_center, "text_total_num")
    -- 剩余人数
    self.text_left_num = me.assignWidget(self.img_center, "text_left_num")
    -- 我的状态
    self.text_status = me.assignWidget(self.img_center, "text_status")
    -- 我的战绩
    self.text_result = me.assignWidget(self.img_center, "text_result")

    return true
end

-- 设置节点数据
function PvpPreselectionNode:setData(data)
	self.info = data
	-- 刷新内容
	self:refreshView()
end

-- 刷新内容
function PvpPreselectionNode:refreshView()
	-- 海选状态：0：未开始，1：进行中，2：已结束
	self.node_rich:stopAllActions()
	if self.info.stp == 0 then
		local tempSecond = self.info.election.countdown
		local function countdown()
			if tempSecond > 0 then
				local timeStr = me.formartSecTimeHour(tempSecond)
				local tempStr = string.format("<txt0026,67FF02>%s&<txt0026,D4CDB9>后开启海选&", timeStr)
				self.richText:setString(tempStr)
				tempSecond = tempSecond - 1
			else
				self.node_rich:stopAllActions()
				local tempStr = string.format("<txt0026,D4CDB9>即将进行海选&")
				self.richText:setString(tempStr)
			end
		end
		countdown()
		self.node_rich:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.DelayTime:create(1.0),
			cc.CallFunc:create(function()
				countdown()
			end)
		)))
	elseif self.info.stp == 1 then
		local tempSecond = self.info.election.countdown
		local function countdown()
			if tempSecond > 0 then
				local timeStr = me.formartSecTimeHour(tempSecond)
				local tempStr = string.format("<txt0020,D4CDB9>正在进行海选&<txt0020,A99379>第%s场&<txt0020,D4CDB9>，共&<txt0020,A99379>%s&<txt0020,D4CDB9>场，&<txt0020,67FF02>%s&<txt0020,D4CDB9>后进行下一场&",
					self.info.election.curRound, self.info.election.round, timeStr)
				self.richText:setString(tempStr)
				tempSecond = tempSecond - 1
			else
				self.node_rich:stopAllActions()
				local tempStr = string.format("<txt0020,D4CDB9>正在进行海选&<txt0020,A99379>第%s场&<txt0020,D4CDB9>，共&<txt0020,A99379>%s&<txt0020,D4CDB9>场，&<txt0020,67FF02>00:00:00&<txt0020,D4CDB9>后进行下一场&",
					self.info.election.curRound, self.info.election.round)
				self.richText:setString(tempStr)
			end
		end
		countdown()
		self.node_rich:runAction(cc.RepeatForever:create(cc.Sequence:create(
			cc.DelayTime:create(1.0),
			cc.CallFunc:create(function()
				countdown()
			end)
		)))
	else
		local tempStr = string.format("<txt0026,D4CDB9>海选已结束，即将进入下一阶段&")
		self.richText:setString(tempStr)
	end
	-- 是否参加
	if self.info.election.join then
		self.text_group:setString(self.info.name)
		self.text_total_num:setString(self.info.election.totalUser)
		self.text_left_num:setString(self.info.election.curUser)
		self.text_status:setString(self.info.stp == 0 and "暂无" or (self.info.election.faild and "已淘汰" or "海选中"))
		local tempStr = ""
		if self.info.election.winTimes > 0 then
			tempStr = tempStr..self.info.election.winTimes.."胜"
		end
		if self.info.election.faild then
			tempStr = tempStr.."1败"
		end
		self.text_result:setString(tempStr == "" and "暂无" or tempStr)
	else
		self.text_group:setString("未报名")
		self.text_total_num:setString(self.info.election.totalUser)
		self.text_left_num:setString(self.info.election.curUser)
		self.text_status:setString("尚未参赛")
		self.text_result:setString("暂无")
	end
end

function PvpPreselectionNode:onEnter()
    print("PvpPreselectionNode onEnter")
end

function PvpPreselectionNode:onEnterTransitionDidFinish()
    print("PvpPreselectionNode onEnterTransitionDidFinish")
end

function PvpPreselectionNode:onExit()
    print("PvpPreselectionNode onExit")
    UserModel:removeLisener(self.lisener)
end
