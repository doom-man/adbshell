--[[
	文件名：CumulativeLoginCell.lua
	描述：累计登录内容节点
	创建人：libowen
	创建时间：2019.9.24
--]]

CumulativeLoginCell = class("CumulativeLoginCell", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
CumulativeLoginCell.__index = CumulativeLoginCell

function CumulativeLoginCell:create(...)
    local layer = CumulativeLoginCell.new(...)
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
function CumulativeLoginCell:ctor()
    print("CumulativeLoginCell ctor")
    self.lisener = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
	        self.info = msg.c
	    	self:showRewardView()
	    	-- 没有可领取的
	    	local canDraw = false
	    	for k, v in pairs(msg.c.list) do
	    		if v.status == 1 then
	    			canDraw = true
	    			break
	    		end
	    	end
	    	if not canDraw then
	    		removeRedpoint(ACTIVITY_ID_CUMULATIVE_LOGIN)
	    	end
        end
    end)
end

-- 初始化
function CumulativeLoginCell:init()
    print("CumulativeLoginCell init")
    self.img_up = me.assignWidget(self, "img_up")
    -- 活动描述
    self.node_rich_desc = me.assignWidget(self.img_up, "node_rich_desc")
    -- 活动时间
    self.text_time = me.assignWidget(self.img_up, "text_time")
    self.text_time:setString("")
    -- tableview父节点
    self.img_bottom = me.assignWidget(self, "img_bottom")
    self.layout_table = me.assignWidget(self.img_bottom, "layout_table")
    self.table_size = self.layout_table:getContentSize()
    -- 模板
    self.template_cell = me.assignWidget(self, "template_cell")
    self.template_cell:setVisible(false)
    self.template_goods = me.assignWidget(self, "template_goods")
    self.template_goods:setVisible(false)

    return true
end

-- 数据初始化
function CumulativeLoginCell:initActivity(info)
	self.info = info
	-- 活动描述
	self.node_rich_desc:removeAllChildren()
	local richText = mRichText:create(self.info.desc, 680)
   	richText:setAnchorPoint(cc.p(0, 1))
 	self.node_rich_desc:addChild(richText)
 	-- 起止时间
 	if me.sysTime() < self.info.openDate then
 		local function countdown()
 			local timeLeft = (self.info.openDate - me.sysTime()) / 1000
            if timeLeft <= 0 then
                me.clearTimer(self.timer)
                self.timer = nil
              	self.text_time:setString("活动结束")
            end
            self.text_time:setString("活动开启倒计时：" .. me.formartSecTime(timeLeft))
 		end
 		countdown()
 		self.timer = me.registTimer(-1, countdown, 1)
 	elseif me.sysTime() < self.info.endDate then
 		local function countdown()
 			local timeLeft = (self.info.endDate - me.sysTime()) / 1000
            if timeLeft <= 0 then
                me.clearTimer(self.timer)
                self.timer = nil
              	self.text_time:setString("活动结束")
            end
            self.text_time:setString("活动结束倒计时：" .. me.formartSecTime(timeLeft))
 		end
 		countdown()
 		self.timer = me.registTimer(-1, countdown, 1)
 	else
 		self.text_time:setString("活动结束")
 	end
 	-- 展示奖励
 	self:showRewardView()
 end

-- 展示奖品分页
function CumulativeLoginCell:showRewardView()
	-- 排序
	table.sort(self.info.list, function(a, b)
		local priorityA = a.status == 1 and 1 or (a.status == 0 and 2 or 3)
        local priorityB = b.status == 1 and 1 or (b.status == 0 and 2 or 3)
        if priorityA ~= priorityB then
            return priorityA < priorityB
        else
            return a.num < b.num
        end
	end)

    local function numberOfCellsInTableView(table)
        return #self.info.list
    end

    local function cellSizeForTable(table, idx)
        return self.table_size.width, 120 + 6
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        -- 创建模板
        local itemInfo = self.info.list[idx + 1]
        local template_cell = self.template_cell:clone()
        template_cell:setVisible(true)
        template_cell:setPosition(cc.p(0, 0 + 6))
        cell:addChild(template_cell)
        	
        -- 登录xx天
        local text_title = me.assignWidget(template_cell, "text_title")
        text_title:setString("累计登录"..itemInfo.num.."天")

        -- 奖品
       	local index = 1
        for k, v in pairs(itemInfo.item) do
            local template_goods = self.template_goods:clone()
            template_goods:setVisible(true)
            template_goods:setPosition(cc.p(320 + (index - 1) * 120, 60))
            template_cell:addChild(template_goods)
            template_goods:setSwallowTouches(false)
            me.registGuiClickEvent(template_goods, function()
	            showPromotion(v[1], v[2])
	        end)

       		local etc = cfg[CfgType.ETC][v[1]]
            -- 底框
            local img_goods_bg = me.assignWidget(template_goods, "img_goods_bg")
            img_goods_bg:loadTexture(getQuality(etc.quality), me.localType)
            -- 图标
            local img_goods = me.assignWidget(template_goods, "img_goods")
            img_goods:loadTexture(getItemIcon(etc.id), me.localType)
            -- 描述
            local img_desc_bg = me.assignWidget(template_goods, "img_desc_bg")
            local text_desc = me.assignWidget(template_goods, "text_desc")
            if etc.showtxt and etc.showtxt ~= "" then
                img_desc_bg:setVisible(true)
                text_desc:setVisible(true)
                text_desc:setString(etc.showtxt)
            else
                img_desc_bg:setVisible(false)
                text_desc:setVisible(false)
            end
            -- 数量
            local text_num = me.assignWidget(template_goods, "text_num")
            text_num:setString(tostring(v[2]))
            index = index + 1
        end

        -- 已领取
        local img_drawn = me.assignWidget(template_cell, "img_drawn")
        img_drawn:setVisible(itemInfo.status == 2)
        local btn_get = me.assignWidget(template_cell, "btn_get")
        btn_get:setSwallowTouches(false)
        btn_get:setVisible(itemInfo.status ~= 2)
        if itemInfo.status == 1 then
        	me.setButtonDisable(btn_get, true)
        	me.registGuiClickEvent(btn_get, function(sender)
		    	NetMan:send(_MSG.updateActivityDetail(self.info.activityId, itemInfo.index))
		    end)
        elseif itemInfo.status == 0 then
        	me.setButtonDisable(btn_get, false)
        end
        
        return cell
    end
    -- 创建tableview
    self.layout_table:removeAllChildren()
    local tableView = cc.TableView:create(self.table_size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.layout_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function CumulativeLoginCell:onEnter()
    print("CumulativeLoginCell onEnter")
end

function CumulativeLoginCell:onEnterTransitionDidFinish()
    print("CumulativeLoginCell onEnterTransitionDidFinish")
end

function CumulativeLoginCell:onExit()
    print("CumulativeLoginCell onExit")
    me.clearTimer(self.timer)
    -- 删除消息通知
    UserModel:removeLisener(self.lisener)
end
