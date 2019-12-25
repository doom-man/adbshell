--[[
	文件名：LandExpandCell.lua
	描述：领地扩张内容节点
	创建人：libowen
	创建时间：2019.12.7
--]]
LandExpandCell = class("LandExpandCell", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
LandExpandCell.__index = LandExpandCell

function LandExpandCell:create(...)
    local layer = LandExpandCell.new(...)
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
function LandExpandCell:ctor()
    print("LandExpandCell ctor")
    self.lisener = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_LAND_EXPAND then
                self.info = msg.c
			    -- 数据处理
			    self:dealData()
			    self:refreshView()
            end
        end
    end)
end

-- 初始化
function LandExpandCell:init()
    print("LandExpandCell init")
    -- 活动描述
    self.panel_desc_rich = me.assignWidget(self, "panel_desc_rich")
    -- 剩余时间
    self.text_time = me.assignWidget(self, "text_time")
    -- 地块总等级
    self.text_total = me.assignWidget(self, "text_total")
    -- 等级进度
    self.loadingBar = me.assignWidget(self, "loadingBar")
    -- 宝箱积分
    for i = 1, 5 do
    	local key1 = "text_lv_"..i
    	local key2 = "btn_box_"..i
    	self[key1] = me.assignWidget(self, key1)
    	self[key2] = me.assignWidget(self, key2)
    end
    -- table父节点
    self.panel_table = me.assignWidget(self, "panel_table")
    -- cell模板
    self.layout_cell = me.assignWidget(self, "layout_cell")
    self.layout_cell:setVisible(false)
    -- 单个道具模板
    self.layout_goods = me.assignWidget(self, "layout_goods")
    self.layout_goods:setVisible(false)

    return true
end

-- 数据初始化
function LandExpandCell:setData(info)
    self.info = info
    -- 数据处理
    self:dealData()
    self:refreshView()
end

-- 数据处理
function LandExpandCell:dealData()
	-- 能领取的 > 不能领取的 > 已领取的
	table.sort(self.info.tasks, function(a, b)
		local priorityA = a[2] == -1 and 3 or (a[2] < a[3] and 2 or 1)
		local priorityB = b[2] == -1 and 3 or (b[2] < b[3] and 2 or 1)
		if priorityA ~= priorityB then
			return priorityA < priorityB
		else
			return a[1] < b[1]
		end
	end)
end

-- 刷新页面
function LandExpandCell:refreshView()
	-- 活动描述
	local tempSize = self.panel_desc_rich:getContentSize()
	self.panel_desc_rich:removeAllChildren()
	local richText = mRichText:create(self.info.desc, tempSize.width, "fzlsjt.ttf")
	richText:setPosition(cc.p(0, tempSize.height))
    richText:setAnchorPoint(cc.p(0, 1))
    self.panel_desc_rich:addChild(richText)
    -- 活动剩余时间
    local leftTime = self.info.leftTm
    local function countdown()
        if leftTime >= 0 then
            local timeStr = me.formartSecTimeHour(leftTime)
            self.text_time:setString(timeStr)
            leftTime = leftTime - 1
        else
        	self.text_time:setString("00:00:00  活动已结束")
            self.text_time:stopAllActions()
        end
    end
    countdown()
    self.text_time:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1.0),
        cc.CallFunc:create(function()
            countdown()
        end)
    )))
    -- 地块总等级
    self.text_total:setString(self.info.landLv)
    -- 展示宝箱奖励
    self:showBoxsReward()
    -- 刷新任务奖励
    self:refreshTaskReward()
end

-- 展示宝箱奖励
function LandExpandCell:showBoxsReward()
	-- 进度
    local tempList = self.info.landLvSts
    self.loadingBar:setPercent(self.info.landLv * 100 / tempList["5"].totlaLandLv)
    -- 宝箱、等级
    for k, v in pairs(tempList) do
    	local key1 = "text_lv_"..k
    	local key2 = "btn_box_"..k
    	self[key1]:setString(v.totlaLandLv)
   		self[key2]:removeAllChildren()
    	-- 是否已领
    	if v.status == 1 then
    		me.registGuiClickEvent(self[key2], function()
    			showTips("已领取")
    		end)
    	else
    		-- 能否领取
    		if self.info.landLv < v.totlaLandLv then
    			me.registGuiClickEvent(self[key2], function()
	    			showPromotion(v.rewards[1][1], v.rewards[1][2])
	    		end)
    		else
				-- 光效
				local aniNode = mAnimation.new("item_ani")
			    aniNode:fishPaly("idle")
			    aniNode:setPosition(cc.p(51.5, 38.5))
			    self[key2]:addChild(aniNode, -1)
			    aniNode:setScale(0.6)
    			me.registGuiClickEvent(self[key2], function()
	    			NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_LAND_EXPAND, 0, 1, tonumber(k)))
	    		end)
    		end
    	end
    end
end

-- 刷新任务奖励
function LandExpandCell:refreshTaskReward()
	local function numberOfCellsInTableView(table)
        return #self.info.tasks
    end

    local function cellSizeForTable(table, idx)
        return 835, 104 + 6
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        local info = self.info.tasks[idx + 1]
        local cfg_item_task = cfg[CfgType.LAND_EXPAND][info[1]]
        -- 创建模板
        local layout_cell = self.layout_cell:clone()
        layout_cell:setVisible(true)
        layout_cell:setPosition(cc.p(0, 0 + 6))
        cell:addChild(layout_cell)

        -- 奖品
        local panel_reward = me.assignWidget(layout_cell, "panel_reward")
        panel_reward:removeAllChildren()
        local listView = ccui.ListView:create()
	    listView:setDirection(ccui.ListViewDirection.horizontal)
	    listView:setBounceEnabled(false)
		listView:setScrollBarEnabled(false)
	    listView:setContentSize(panel_reward:getContentSize())
	    listView:setGravity(ccui.ListViewGravity.centerVertical)
	    listView:setAnchorPoint(cc.p(0, 0))
	    listView:setPosition(cc.p(0, 0))
	    listView:setItemsMargin(10)
	    panel_reward:addChild(listView)
	    listView:setSwallowTouches(false)
	    local rewardList = string.split(cfg_item_task.reward, ",")
	    for i, str in ipairs(rewardList) do
	    	-- 配置
	    	local tempList = string.split(str, ":")
	    	local goodsId = tonumber(tempList[1])
	    	local goodsNum = tonumber(tempList[2])
	    	local cfg_item_goods = cfg[CfgType.ETC][goodsId]
	    	--
	    	local layout_goods = self.layout_goods:clone()
	    	layout_goods:setVisible(true)
	    	listView:pushBackCustomItem(layout_goods)
	    	me.registGuiClickEvent(layout_goods, function()
		        showPromotion(goodsId, goodsNum)
		    end)
		    layout_goods:setSwallowTouches(false)
		    -- 底框
		    local img_quality = me.assignWidget(layout_goods, "img_quality")
		    img_quality:loadTexture(getQuality(cfg_item_goods.quality))
		    -- icon
		    local img_icon = me.assignWidget(layout_goods, "img_icon")
		    img_icon:loadTexture(getItemIcon(cfg_item_goods.id))
		    -- 描述
		    local img_desc_bg = me.assignWidget(layout_goods, "img_desc_bg")
		    local text_desc = me.assignWidget(layout_goods, "text_desc")
		    if cfg_item_goods.showtxt and cfg_item_goods.showtxt ~= "" then
		        img_desc_bg:setVisible(true)
		        text_desc:setVisible(true)
		        text_desc:setString(cfg_item_goods.showtxt)
		    else
		        img_desc_bg:setVisible(false)
		        text_desc:setVisible(false)
		    end
		    -- 数量
		    local text_num_goods = me.assignWidget(layout_goods, "text_num_goods")
		    text_num_goods:setString(Scientific(goodsNum))
	    end

      	-- 条件
      	local text_condition = me.assignWidget(layout_cell, "text_condition")
      	text_condition:setString(cfg_item_task.desc)
      	-- 进度
        local img_num_task = me.assignWidget(layout_cell, "img_num_task")
        local text_num_task = me.assignWidget(img_num_task, "text_num_task")
        -- 领取
        local btn_get = me.assignWidget(layout_cell, "btn_get")
      	-- 是否领取
      	local img_got = me.assignWidget(layout_cell, "img_got")
      	if info[2] == -1 then
      		img_num_task:setVisible(false)
      		btn_get:setVisible(false)
      		img_got:setVisible(true)
      	else
      		img_got:setVisible(false)
      		img_num_task:setVisible(true)
      		text_num_task:setString(string.format("%s/%s", info[2], info[3]))
      		btn_get:setVisible(true)
      		-- 能否领取
      		if info[2] < info[3] then
      			text_num_task:setTextColor(cc.c3b(0xE3, 0x24, 0x24))
      			btn_get:setEnabled(false)
      		else
      			text_num_task:setTextColor(cc.c3b(0x7A, 0xCA, 0x3B))
      			btn_get:setEnabled(true)
      			me.registGuiClickEvent(btn_get, function()
      				NetMan:send(_MSG.updateActivityDetail(ACTIVITY_ID_LAND_EXPAND, tonumber(info[1]), 0))
      			end)
      		end
      	end
        return cell
    end
    -- 创建tableview
    self.panel_table:removeAllChildren()
    local tableView = cc.TableView:create(self.panel_table:getContentSize())
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.panel_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function LandExpandCell:onEnter()
    print("LandExpandCell onEnter")
end

function LandExpandCell:onEnterTransitionDidFinish()
    print("LandExpandCell onEnterTransitionDidFinish")
end

function LandExpandCell:onExit()
    print("LandExpandCell onExit")
    UserModel:removeLisener(self.lisener)
end
