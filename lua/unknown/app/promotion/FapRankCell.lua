--[[
	文件名：FapRankCell.lua
	描述：战力比拼内容节点
	创建人：libowen
	创建时间：2019.8.26
--]]

FapRankCell = class("FapRankCell", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
FapRankCell.__index = FapRankCell

function FapRankCell:create(...)
    local layer = FapRankCell.new(...)
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
function FapRankCell:ctor()
    print("FapRankCell ctor")
    self.lisener = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then
        	if msg.c and msg.c.type == 20 then
	        	self.rewardInfo = msg.c
	            self:showRewardView()
	        end
        end
    end)
end

function FapRankCell:setButtonDisable(button, b)   
    if  button.setBright then
         button:setTouchEnabled(b)
         button:setBright(b)  
     
    end
end


-- 初始化
function FapRankCell:init()
    print("FapRankCell init")
    self.img_up = me.assignWidget(self, "img_up")
    -- 活动描述
    self.panel_activity_desc = me.assignWidget(self.img_up, "panel_activity_desc")
    -- 活动起止时间
    self.text_activity_time = me.assignWidget(self.img_up, "text_activity_time")

    -- 战力节点
    self.node_fap = me.assignWidget(self, "node_fap")
    -- 我的排名
    self.img_myRank = me.assignWidget(self.node_fap, "img_myRank")
    self.text_myRank = me.assignWidget(self.img_myRank, "text_myRank")
    self.text_myRankNum = me.assignWidget(self.img_myRank, "text_myRankNum")
    self.img_fap_table = me.assignWidget(self.node_fap, "img_fap_table")
    self.fap_table_size = self.img_fap_table:getContentSize() 
    self.node_desc1 = me.assignWidget(self.node_fap, "node_desc1")
    self.text_desc2 = me.assignWidget(self.node_fap, "text_desc2")
    -- 奖励节点
    self.node_reward = me.assignWidget(self, "node_reward")
    self.img_reward_table = me.assignWidget(self.node_reward, "img_reward_table")
    self.reward_table_size = self.img_reward_table:getContentSize()
     -- 模板
    self.item_fap = me.assignWidget(self, "item_fap")
    self.item_fap:setVisible(false)
    self.item_reward = me.assignWidget(self, "item_reward")
    self.item_reward:setVisible(false)
    self.item_goods = me.assignWidget(self, "item_goods")
    self.item_goods:setVisible(false)

    -- 战力排名
    self.btn_fap = me.assignWidget(self, "btn_fap")
    me.registGuiClickEvent(self.btn_fap, function(sender)
    	self:setButtonDisable(sender, false)
        self:setButtonDisable(self.btn_reward, true)
        self.node_fap:setVisible(true)
        self.node_reward:setVisible(false)
    end)
    -- 排名奖励
    self.btn_reward = me.assignWidget(self, "btn_reward")
    me.registGuiClickEvent(self.btn_reward, function(sender)
    	self:setButtonDisable(sender, false)
        self:setButtonDisable(self.btn_fap, true)
        self.node_fap:setVisible(false)
        self.node_reward:setVisible(true)
        -- 只请求一次
        if not self.rewardInfo then
        	NetMan:send(_MSG.Cross_Sever_Reward(20))
        end
    end)

    self:setButtonDisable(self.btn_fap, false)
    self:setButtonDisable(self.btn_reward, true)

    return true
end

-- 数据初始化
function FapRankCell:initActivity(info)
	self.fapInfo = info
	-- 活动描述
	self.panel_activity_desc:removeAllChildren()
	local tempSize = self.panel_activity_desc:getContentSize()
	local richText = mRichText:create(self.fapInfo.desc, tempSize.width)
   	richText:setPosition(0, tempSize.height)
   	richText:setAnchorPoint(cc.p(0, 1))
 	self.panel_activity_desc:addChild(richText)
 	-- 起止时间
 	self.text_activity_time:setString(self.fapInfo.startDate.."-"..self.fapInfo.closeDate)
 	-- 默认展示战力排行
 	self:showFapView()
end

-- 展示战力排行分页
function FapRankCell:showFapView()
	self:setButtonDisable(self.btn_fap, false)
    self:setButtonDisable(self.btn_reward, true)
    self.node_fap:setVisible(true)
    self.node_reward:setVisible(false)

    local function numberOfCellsInTableView(table)
        return #self.fapInfo.list
    end

    local function cellSizeForTable(table, idx)
        return self.fap_table_size.width, 60
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        -- 创建模板
        local itemInfo = self.fapInfo.list[idx + 1]
        local node = self.item_fap:clone()
        node:setVisible(true)
        node:setPosition(cc.p(0, 0))
        cell:addChild(node)
        local img_bg = me.assignWidget(node, "img_bg")
        img_bg:setVisible(idx % 2 ~= 0)
        -- 排名
        local text_rank = me.assignWidget(node, "text_rank")
		local img_rank_icon = me.assignWidget(node, "img_rank_icon")
		local rankImgList = {"paihang_diyiming.png", "paihang_dierming.png", "paihang_disanming.png"}
        if idx + 1 <= 3 then
        	text_rank:setVisible(false)
        	img_rank_icon:setVisible(true)
        	img_rank_icon:loadTexture(rankImgList[idx + 1], me.localType)
        else
        	text_rank:setVisible(true)
        	text_rank:setString(tostring(idx + 1))
        	img_rank_icon:setVisible(false)
        end
		-- 名称
		local text_name = me.assignWidget(node, "text_name")
		text_name:setString(itemInfo.name)
		-- 等级
		local text_lv = me.assignWidget(node, "text_lv")
		text_lv:setString("Lv."..itemInfo.level)
		-- 战力
		local text_fap = me.assignWidget(node, "text_fap")
		text_fap:setString(tostring(itemInfo.value))
    
        return cell
    end
    -- 创建tableview
    self.img_fap_table:removeAllChildren()
    local tableView = cc.TableView:create(self.fap_table_size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.img_fap_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    -- 我的排名
    if self.fapInfo.curRank > 0 then
    	self:selectMyRankCell(tableView, self.fapInfo.curRank, #self.fapInfo.list)
        self.text_myRank:setString("我的排名")
        self.text_myRankNum:setVisible(true)
        self.text_myRankNum:setString(self.fapInfo.curRank)
    else
        self.text_myRank:setString("未上榜")
        self.text_myRankNum:setVisible(false)
    end
    me.registGuiClickEvent(self.img_myRank, function(sender)
    	if self.fapInfo.curRank > 0 then
    		if not self.isBlinking then
                self:setTableOffset(tableView, self.fapInfo.curRank, #self.fapInfo.list)
                self:doBlink()
	        end
    	end
    end)

    -- 我的战力
    self.node_desc1:removeAllChildren()
    local richText = mRichText:create("<txt0016,e1d5b1>战斗力达到&<txt0016,ce4836>"..self.fapInfo.minFight.."&<txt0016,e1d5b1>可进入排行榜&")
    self.node_desc1:addChild(richText)
	self.text_desc2:setString("我的战斗力："..self.fapInfo.fightPower)
end

-- 选中框
function FapRankCell:selectMyRankCell(tableView, selIdx, totalNum)
	if self.selImg and not tolua.isnull(self.selImg) then
		self.selImg:removeFromParent(true)
		self.selImg = nil
	end

    local posX = 410
    local posY = (totalNum - selIdx) * 60 + 28
    self.selImg = me.assignWidget(self, "Image_mine"):clone()
    self.selImg:setVisible(true)
    self.selImg:setPosition(cc.p(posX, posY))
    tableView:addChild(self.selImg)

end

-- 设置tableview偏移量
function FapRankCell:setTableOffset(tableView, selIdx, totalNum)
	if totalNum * 60 < self.fap_table_size.height then
		tableView:setContentOffset(cc.p(0, self.fap_table_size.height - totalNum * 60))
	else
		local maxOffsetY = 0
		local minOffsetY = self.fap_table_size.height - totalNum * 60
		local offsetY = (selIdx - totalNum + 2) * 60  						-- +2表示往上偏移，使其竖直居中
		offsetY = offsetY < minOffsetY and minOffsetY or offsetY
		offsetY = offsetY > maxOffsetY and maxOffsetY or offsetY
		tableView:setContentOffset(cc.p(0, offsetY))
	end
end

-- 闪烁动画
function FapRankCell:doBlink()
	self.isBlinking = true
    self.selImg:stopAllActions()
    self.selImg:runAction(cc.Sequence:create(
    	cc.Blink:create(0.9, 2),
    	cc.DelayTime:create(1.1),
    	cc.CallFunc:create(function()
    		self.isBlinking = false
    	end)
    ))
end

-- 展示奖品分页
function FapRankCell:showRewardView()
    local function numberOfCellsInTableView(table)
        return #self.rewardInfo.award
    end

    local function cellSizeForTable(table, idx)
        return self.reward_table_size.width, 95
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        end
        cell:removeAllChildren()
        -- 创建模板
        local itemInfo = self.rewardInfo.award[idx + 1]
        local node = self.item_reward:clone()
        node:setVisible(true)
        node:setPosition(cc.p(0, 0))
        cell:addChild(node)
        local img_bg = me.assignWidget(node, "img_bg")
        img_bg:setVisible(idx % 2 ~= 0)

        -- 排名
        local text_rank = me.assignWidget(node, "text_rank")
        if itemInfo.bg == itemInfo.ed then
        	text_rank:setString("排名"..itemInfo.bg)
        else
        	text_rank:setString("排名"..itemInfo.bg.."-"..itemInfo.ed)
        end
        
        -- 奖品
        local index = 1
        for k, v in pairs(itemInfo.rw) do
            local item_goods = self.item_goods:clone()
            item_goods:setVisible(true)
            item_goods:setPosition(cc.p(300 + (index - 1) * 105, 47))
            node:addChild(item_goods)
            local etc = cfg[CfgType.ETC][v[1]]
            -- 底框
            item_goods:loadTexture(getQuality(etc.quality))
            -- icon
            local img_goods = me.assignWidget(item_goods, "img_goods")
            img_goods:loadTexture(getItemIcon(etc.id))
            img_goods:setSwallowTouches(false)
            me.registGuiClickEvent(img_goods, function()
                showPromotion(v[1], v[2])
            end)
            -- 描述
            local img_desc_bg = me.assignWidget(item_goods, "img_desc_bg")
            local txt_desc = me.assignWidget(item_goods, "txt_desc")
            if etc.showtxt and etc.showtxt ~= "" then
                img_desc_bg:setVisible(true)
                txt_desc:setVisible(true)
                txt_desc:setString(etc.showtxt)
            else
                img_desc_bg:setVisible(false)
                txt_desc:setVisible(false)
            end
            -- 数量
            local text_num = me.assignWidget(item_goods, "text_num")
            text_num:setString(tostring(v[2]))
            index = index + 1
        end
        return cell
    end
    -- 创建tableview
    self.img_reward_table:removeAllChildren()
    local tableView = cc.TableView:create(self.reward_table_size)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.img_reward_table:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function FapRankCell:onEnter()
    print("FapRankCell onEnter")
end

function FapRankCell:onEnterTransitionDidFinish()
    print("FapRankCell onEnterTransitionDidFinish")
end

function FapRankCell:onExit()
    print("FapRankCell onExit")
    UserModel:removeLisener(self.lisener)
end
