--[[
	文件名：HolyLandTrainCell.lua
	描述：圣地试炼内容节点
	创建人：libowen
	创建时间：2019.12.6
--]]
HolyLandTrainCell = class("HolyLandTrainCell", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
HolyLandTrainCell.__index = HolyLandTrainCell

function HolyLandTrainCell:create(...)
    local layer = HolyLandTrainCell.new(...)
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
function HolyLandTrainCell:ctor()
    print("HolyLandTrainCell ctor")
    self.lisener = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_HOLY_TRAIN then
                self.info = msg.c
                self:refreshView()
            end
        end
    end)
end

-- 初始化
function HolyLandTrainCell:init()
    print("HolyLandTrainCell init")
    -- 活动描述
    self.panel_desc_rich = me.assignWidget(self, "panel_desc_rich")
    -- 阶段时间
    self.text_time_1 = me.assignWidget(self, "text_time_1")
    self.text_time_2 = me.assignWidget(self, "text_time_2")
    -- 阶段积分
    self.text_score = me.assignWidget(self, "text_score")
    -- 积分进度
    self.loadingBar = me.assignWidget(self, "loadingBar")
    -- 终极奖励
    self.img_final = me.assignWidget(self, "img_final")
    -- 阶段节点
    for i = 1, 3 do
        local key = "node_"..i
        self[key] = me.assignWidget(self, key)
    end
    -- 奖励模板
    self.layout_item = me.assignWidget(self, "layout_item")
    self.layout_item:setVisible(false)

    return true
end

-- 数据初始化
function HolyLandTrainCell:setData(info)
    self.info = info
    self:refreshView()
end

-- 刷新页面
function HolyLandTrainCell:refreshView()
	-- 活动描述
	local tempSize = self.panel_desc_rich:getContentSize()
	self.panel_desc_rich:removeAllChildren()
	local richText = mRichText:create(self.info.desc, tempSize.width, "fzlsjt.ttf")
	richText:setPosition(cc.p(0, tempSize.height))
    richText:setAnchorPoint(cc.p(0, 1))
    self.panel_desc_rich:addChild(richText)
    -- 阶段剩余时间
    local tempList = {[1] = "一", [2] = "二", [3] = "三"}
    self.text_time_1:setString(string.format("第%s阶段剩余时间：", tempList[self.info.curSt]))
    local leftTime = self.info.leftTm
    local function countdown()
        if leftTime >= 0 then
            local timeStr = me.formartSecTimeHour(leftTime)
            self.text_time_2:setString(timeStr)
            leftTime = leftTime - 1
        else
            self.text_time_2:stopAllActions()
            if HOLY_TRAIN_STAGE_ID_LAST_PULL_DATA ~= self.info.curSt then
            	HOLY_TRAIN_STAGE_ID_LAST_PULL_DATA = self.info.curSt
            	NetMan:send(_MSG.activityDetail(ACTIVITY_ID_HOLY_TRAIN))
            end
        end
    end
    countdown()
    self.text_time_2:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function()
            countdown()
        end)
    )))
    -- 积分
    self.text_score:setString(string.format("%s/%s", self.info.sc, self.info.scLmt))
    self.loadingBar:setPercent(self.info.sc * 100 / self.info.scLmt)
    -- 终极奖励
    self:showFinalReward()
    -- 阶段奖励
    self:showStageReward()
end

-- 展示终极奖励
function HolyLandTrainCell:showFinalReward()
	self.img_final:removeAllChildren()
    me.registGuiClickEvent(self.img_final, function()
        showPromotion(self.info.fRwd[1], self.info.fRwd[2])
    end)
	-- 光效
	local aniNode = mAnimation.new("item_ani")
    aniNode:fishPaly("idle")
    aniNode:setPosition(cc.p(148.5, 88))
    self.img_final:addChild(aniNode, -1)
    
end

-- 展示阶段奖励
function HolyLandTrainCell:showStageReward()
	for i = 1, 3 do
		local key = "node_"..i
		-- 旗子
		local img_flag_normal = me.assignWidget(self[key], "img_flag_normal")
		local img_flag_gray = me.assignWidget(self[key], "img_flag_gray")
		-- 名字
		local img_name_normal = me.assignWidget(self[key], "img_name_normal")
		local img_name_gray = me.assignWidget(self[key], "img_name_gray")
		-- 已完成
		local img_completed = me.assignWidget(self[key], "img_completed")
		-- 未完成
		local text_uncompleted = me.assignWidget(self[key], "text_uncompleted")
		-- 未开始
		local img_not_start = me.assignWidget(self[key], "img_not_start")
		-- 选中框
		local img_select = me.assignWidget(self[key], "img_select")
		if i < self.info.curSt then
			img_flag_normal:setVisible(false)
			img_flag_gray:setVisible(true)
			img_name_normal:setVisible(false)
			img_name_gray:setVisible(true)
			img_completed:setVisible(self.info.doneMap[tostring(i)] == 1)
			text_uncompleted:setVisible(self.info.doneMap[tostring(i)] == 0)
			img_not_start:setVisible(false)
			img_select:setVisible(false)
		elseif i == self.info.curSt then
			img_flag_normal:setVisible(true)
			img_flag_gray:setVisible(false)
			img_name_normal:setVisible(true)
			img_name_gray:setVisible(false)
			img_completed:setVisible(false)
			text_uncompleted:setVisible(false)
			img_not_start:setVisible(false)
			img_select:setVisible(true)
		else
			img_flag_normal:setVisible(true)
			img_flag_gray:setVisible(false)
			img_name_normal:setVisible(true)
			img_name_gray:setVisible(false)
			img_completed:setVisible(false)
			text_uncompleted:setVisible(false)
			img_not_start:setVisible(true)
			img_select:setVisible(false)
		end
		-- 奖励列表
		local listView = me.assignWidget(self[key], "listView")
		listView:setScrollBarEnabled(false)
		listView:removeAllItems()
		for j, v in ipairs(self.info.rwd[tostring(i)] or {}) do
			local cfg_item = cfg[CfgType.ETC][v[1]]
			local layout_item = self.layout_item:clone()
			layout_item:setVisible(true)
			listView:pushBackCustomItem(layout_item)
			-- 黑底
			local img_black = me.assignWidget(layout_item, "img_black")
			img_black:setVisible(j % 2 ~= 0)
			-- 底框
		    local img_quality = me.assignWidget(layout_item, "img_quality")
		    img_quality:loadTexture(getQuality(cfg_item.quality))
		    me.registGuiClickEvent(img_quality, function()
		        showPromotion(v[1], v[2])
		    end)
		    -- icon
		    local img_icon = me.assignWidget(layout_item, "img_icon")
		    img_icon:loadTexture(getItemIcon(cfg_item.id))
		    -- 名字
		    local text_name = me.assignWidget(layout_item, "text_name")
		    text_name:setString(cfg_item.name)
		    -- 数量
		    local text_num = me.assignWidget(layout_item, "text_num")
		    text_num:setString("x"..Scientific(v[2]))
		    if i < self.info.curSt then
				me.Helper:grayImageView(img_quality)
				me.Helper:grayImageView(img_icon)
				text_name:setTextColor(cc.c3b(0x7f, 0x7f, 0x7f))
				text_num:setTextColor(cc.c3b(0x7f, 0x7f, 0x7f))
			end
		end
	end
end

function HolyLandTrainCell:onEnter()
    print("HolyLandTrainCell onEnter")
end

function HolyLandTrainCell:onEnterTransitionDidFinish()
    print("HolyLandTrainCell onEnterTransitionDidFinish")
end

function HolyLandTrainCell:onExit()
    print("HolyLandTrainCell onExit")
    UserModel:removeLisener(self.lisener)
end
