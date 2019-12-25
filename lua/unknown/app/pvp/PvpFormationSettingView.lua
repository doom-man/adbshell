--[[
	文件名：PvpFormationSettingView.lua
	描述：跨服争霸阵容配置页面
	创建人：libowen
	创建时间：2019.10.21
--]]

PvpFormationSettingView = class("PvpFormationSettingView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpFormationSettingView.__index = PvpFormationSettingView

-- 分路页签
local RoadTab = {
	UP = 0, 		-- 上路
	MIDDLE = 1, 	-- 中路
	DOWN = 2, 		-- 下路
}

-- 附加页签
local AppendTab = {
	HERO = 1, 	-- 英雄
	RUNE = 2,	-- 圣物
}

-- 快速配置表
local FastSettingMap = {
	[1] = {name = "战力优先", pic = "expend_state_1.png"},
    [2] = {name = "速度优先", pic = "expend_state_2.png"},
    [3] = {name = "负重优先", pic = "expend_state_3.png"},
    [4] = {name = "均衡配置", pic = "expend_state_4.png"},
    [11] = {name = "步兵优先", pic = "expend_state_11.png"},
    [21] = {name = "骑兵优先", pic = "expend_state_21.png"},
    [31] = {name = "弓兵优先", pic = "expend_state_31.png"},
    [41] = {name = "清空选中", pic = "expend_state_41.png"},
}

function PvpFormationSettingView:create(...)
    local layer = PvpFormationSettingView.new(...)
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
function PvpFormationSettingView:ctor()
    print("PvpFormationSettingView ctor")
    -- 出征兵力上限
    self.soliderLimit = user.maxTroopsNum
    -- 每一路的快捷配置方式
    self.fastSetting = {
    	[RoadTab.UP] = 0,
    	[RoadTab.MIDDLE] = 0,
    	[RoadTab.DOWN] = 0,
    }
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_FORMATION_INFO) then
            self.info = msg.c
            -- 数据处理
            self:dealData(true)
            -- 默认选择上路
            self:selectRoad(RoadTab.UP)
        elseif checkMsg(msg.t, MsgCode.PVP_FORMATION_SET) then
            showTips("保存成功")
        	self.info = msg.c
        	-- 修改那一路的缓存数据
            self:dealData(false, msg.c.updateId)
            -- 刷新页面
            self:selectRoad(self.selRoad)
        	-- 是否三路都配齐
            if self.info.armys and #self.info.armys >= 3 then
                if self.finishCb then
                    self.finishCb()
                end
            end
            -- 有改变才可保存
            self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        elseif checkMsg(msg.t, MsgCode.PVP_FORMATION_EXCHANGE) then
        	showTips("互换成功")
        	-- 更新缓存
        	local a_local = clone(self.localList[msg.c.ida])
        	local b_local = clone(self.localList[msg.c.idb])
        	self.localList[msg.c.ida] = b_local
        	self.localList[msg.c.idb] = a_local
        	local a_server = clone(self.serverList[msg.c.ida])
        	local b_server = clone(self.serverList[msg.c.idb])
        	self.serverList[msg.c.ida] = b_server
        	self.serverList[msg.c.idb] = a_server
        	self:selectRoad(self.selRoad)
        -- 兵力上限修改
       	elseif checkMsg(msg.t, MsgCode.ROLE_PROPERTY_UPDATE) then
       		self.soliderLimit = user.maxTroopsNum
			self.text_limit2:setString(self.soliderLimit)
            if user.propertyValue["BingliAddPct"] and user.propertyValue["BingliAddPct"] > 0 then
                self.text_limit2:setTextColor(cc.c4b(111, 209, 32, 255))
            end
		elseif checkMsg(msg.t, MsgCode.SHOP_INIT) then
			if self.shopView and not tolua.isnull(self.shopView) then
				self.shopView:removeFromParent()
				self.shopView = nil
		    end
		    local view = vipShopView:create("vipShopView.csb")
	        view:expendMax()
	        self:addChild(view)
	        me.showLayer(view, "bg")
	        self.shopView = view
        end
    end)
    -- 获取军队部署信息
    NetMan:send(_MSG.get_pvp_formation_info())
end

-- 初始化
function PvpFormationSettingView:init()
    print("PvpFormationSettingView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.img_top = me.assignWidget(self.img_bg, "img_top")
    self.btn_close = me.assignWidget(self.img_top, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
        self:removeFromParent()
    end)
    -- 兵力上限
    self.text_limit1 = me.assignWidget(self.img_bg, "text_limit1")
    self.text_limit1:setString("-/")
    self.text_limit2 = me.assignWidget(self.img_bg, "text_limit2")
    self.text_limit2:setString(self.soliderLimit)
    if user.propertyValue["BingliAddPct"] and user.propertyValue["BingliAddPct"] > 0 then
        self.text_limit2:setTextColor(cc.c4b(111, 209, 32, 255))
    end
    -- 提升上限
    self.btn_solider_add = me.assignWidget(self.img_bg, "btn_solider_add")
    me.registGuiClickEvent(self.btn_solider_add, function(sender)
        if not PvpMainView.inSignUp then
            showTips("当前阶段只能更换分路，不能调整阵容配置")
            return
        end
    	NetMan:send(_MSG.initShop(ARMY_ADD_TYPE))
    end)

    -- 上路
    self.btn_shang = me.assignWidget(self.img_bg, "btn_shang")
    self.btn_shang.tag = RoadTab.UP
    me.registGuiClickEvent(self.btn_shang, function(sender)
        if PvpMainView.inSignUp then
            if self:checkLocalChanged(self.selRoad) then
                self:showTipViewChangeTab()
            else
                self:selectRoad(RoadTab.UP)
            end
        else
            self:selectRoad(RoadTab.UP)
        end
    end)
    -- 中路
    self.btn_zhong = me.assignWidget(self.img_bg, "btn_zhong")
    self.btn_zhong.tag = RoadTab.MIDDLE
    me.registGuiClickEvent(self.btn_zhong, function(sender)
        if PvpMainView.inSignUp then
            if self:checkLocalChanged(self.selRoad) then
                self:showTipViewChangeTab()
            else
                self:selectRoad(RoadTab.MIDDLE)
            end
        else
            self:selectRoad(RoadTab.MIDDLE)
        end
    end)
    -- 下路
    self.btn_xia = me.assignWidget(self.img_bg, "btn_xia")
    self.btn_xia.tag = RoadTab.DOWN
    me.registGuiClickEvent(self.btn_xia, function(sender)
        if PvpMainView.inSignUp then
            if self:checkLocalChanged(self.selRoad) then
                self:showTipViewChangeTab()
            else
                self:selectRoad(RoadTab.DOWN)
            end
        else
            self:selectRoad(RoadTab.DOWN)
        end
    end)

	-- 士兵
    self.img_left = me.assignWidget(self.img_bg, "img_left")
    self.layout_table_solider = me.assignWidget(self.img_left, "layout_table_solider")
    -- 模板
    self.layout_item_solider = me.assignWidget(self.img_left, "layout_item_solider")
    self.layout_item_solider:setVisible(false)
    -- 战舰
    self.img_right = me.assignWidget(self.img_bg, "img_right")
    self.layout_table_ship = me.assignWidget(self.img_right, "layout_table_ship")
    -- 模板
    self.layout_item_ship = me.assignWidget(self.img_right, "layout_item_ship")
    self.layout_item_ship:setVisible(false)

    -- 英雄选择
    self.btn_hero = me.assignWidget(self.img_bg, "btn_hero")
    self.btn_hero.tag = AppendTab.HERO
    me.registGuiClickEvent(self.btn_hero, function(sender)
        self:selectAppend(AppendTab.HERO)
    end)
    -- 圣物选择
    self.btn_rune = me.assignWidget(self.img_bg, "btn_rune")
    self.btn_rune.tag = AppendTab.RUNE
    me.registGuiClickEvent(self.btn_rune, function(sender)
        self:selectAppend(AppendTab.RUNE)
    end)
    -- 卡槽容器节点
    self.node_slot = me.assignWidget(self.img_bg, "node_slot")
    -- 英雄模板
    self.item_slot_hero = me.assignWidget(self.img_bg, "item_slot_hero")
    self.item_slot_hero:setVisible(false)
    -- 圣物模板
    self.item_slot_rune = me.assignWidget(self.img_bg, "item_slot_rune")
    self.item_slot_rune:setVisible(false)

    -- 队伍互换
    self.panel_team_exchange = me.assignWidget(self.fixLayout, "panel_team_exchange")
	self.panel_team_exchange:setVisible(false)
	me.registGuiClickEvent(self.panel_team_exchange, function(sender)
        self.panel_team_exchange:setVisible(false)
    end)
    self.img_team_exchange = me.assignWidget(self.img_bg, "img_team_exchange")
    me.registGuiClickEvent(self.img_team_exchange, function(sender)
        self:showExchangeView()
    end)
    -- 士兵配置方式
    self.panel_team_setting = me.assignWidget(self.fixLayout, "panel_team_setting")
    self.panel_team_setting:setVisible(false)
    me.registGuiClickEvent(self.panel_team_setting, function(sender)
        self.panel_team_setting:setVisible(false)
    end)
    self.img_team_setting = me.assignWidget(self.img_bg, "img_team_setting")
    me.registGuiClickEvent(self.img_team_setting, function(sender)
        if not PvpMainView.inSignUp then
            showTips("当前阶段只能更换分路，不能调整阵容配置")
            return
        end
        self:showConfigureView()
    end)
    self.text_type = me.assignWidget(self.img_team_setting, "text_type")
    -- 入驻
    self.btn_ok = me.assignWidget(self.img_bg, "btn_ok")
    me.registGuiClickEvent(self.btn_ok, function(sender)
        if not PvpMainView.inSignUp then
            showTips("当前阶段只能更换分路，不能调整阵容配置")
            return
        end
        -- 至少要上1个兵
        local solider_empty = true
        local localList = self.localList[self.selRoad]
        for k, v in pairs(localList.solider) do
            if v ~= 0 then
                solider_empty = false
                break
            end
        end
        if solider_empty then
            showTips("上阵士兵不能为空")
        else
            if self.signUp then
                local box = MessageBox:create("MessageBox.csb")
                box:setText("调整阵容将进行属性更新，确认以当前的阵容与属性重新报名跨服争霸吗？")
                box:register(function(name)
                    if name == "ok" then
                        -- 上传该路配置到服务器
                        self:saveSettingToServer(self.selRoad)
                    end
                end)
                self:addChild(box, me.ANIMATION)
            else
                -- 上传该路配置到服务器
                self:saveSettingToServer(self.selRoad)
            end
        end
    end)
    -- 不在报名阶段
    if not PvpMainView.inSignUp then
        self.btn_solider_add:setBright(false)
        me.Helper:grayImageView(self.img_team_setting)
        self.btn_ok:setBright(false)
    end
    
    return true
end

-- 切换页签提示
function PvpFormationSettingView:showTipViewChangeTab()
    local box = MessageBox:create("MessageBox.csb")
    box:setText(not self.signUp and "本路阵容已经发生变化，是否进行保存？" or "本路阵容已经发生变化，是否进行保存并以当前的阵容与属性重新报名跨服争霸？")
    box:register(function(name)
        if name == "ok" then
            -- 至少要上1个兵
            local solider_empty = true
            local localList = self.localList[self.selRoad]
            for k, v in pairs(localList.solider) do
                if v ~= 0 then
                    solider_empty = false
                    break
                end
            end
            if solider_empty then
                showTips("上阵士兵不能为空")
            else
                -- 上传该路配置到服务器
                self:saveSettingToServer(self.selRoad)
            end
        else
            -- 还原
            self:dealData(true)
            self:selectRoad(self.selRoad)
        end
    end)
    self:addChild(box, me.ANIMATION)
end

-- 数据处理
--[[
	isInit 				-- 是否初次
	targetId 			-- 分路id
--]]
function PvpFormationSettingView:dealData(isInit, targetId)
	if isInit then
		-- 战舰列表：未解锁的 + 已拥有的
		self.shipList = {}
		for k, v in pairs(cfg[CfgType.SHIP_DATA]) do
			self.shipList[v.type] = clone(v)
		end
		-- 考古英雄列表：考古携带的 + 背包中的
		self.heroList = {}
		for k, v in pairs(user.bookPkg) do
	        if cfg[CfgType.ETC][v.defid].useType == 10 then
	        	self.heroList[v.uid] = clone(v)
	        end
	    end
		for k, v in pairs(user.bookEquip) do
		    if cfg[CfgType.ETC][v.defid].useType == 10 then
		    	self.heroList[v.uid] = clone(v)
		    end
		end
        -- 本地拥有的圣物列表：已装备的 + 背包中的
        self.runeList_local = {}
        for _, group in pairs(user.runeEquiped) do
            for _, v in pairs(group) do
                if cfg[CfgType.RUNE_DATA][v.cfgId].type ~= 99 then
                    self.runeList_local[v.id] = clone(v)
                end
            end
        end
        for _, v in pairs(user.runeBackpack) do
            if cfg[CfgType.RUNE_DATA][v.cfgId].type ~= 99 then
                self.runeList_local[v.id] = clone(v)
            end
        end
        -- 服务端传过来的圣物列表
        self.runeList_server = {}
		-- 本地列表，记录三路选择情况
		self.localList = {}
		for _, v1 in pairs(RoadTab) do
			self.localList[v1] = {}
			-- 战舰
			self.localList[v1].ship = 0
			-- 士兵
			self.localList[v1].solider = {}
			for _, v2 in ipairs(self.info.mySoldiers) do
				self.localList[v1].solider[v2.id] = 0
			end
			-- 英雄与圣物，存放实体id
			self.localList[v1].append = {
				[AppendTab.HERO] = {0, 0, 0, 0, 0},
				[AppendTab.RUNE] = {0, 0, 0, 0},
			}
		end
		-- 同步服务端数据
		for _, group in ipairs(self.info.armys or {}) do
			local localList = self.localList[group.id]
			localList.ship = group.ship
			for i, v in ipairs(group.army or {}) do
				localList.solider[v[1]] = v[2]
			end
			for k, v in pairs(group.heros or {}) do
				localList.append[AppendTab.HERO][tonumber(v)] = tonumber(k)
			end
			for k, v in pairs(group.runes or {}) do
				localList.append[AppendTab.RUNE][tonumber(v.index)] = tonumber(v.id)
                local tempItem = clone(v)
                tempItem.cfgId = v.defId
                self.runeList_server[tonumber(v.id)] = tempItem
			end
		end
		-- 用于对比本地是否有修改
		self.serverList = clone(self.localList)
	else
		-- 仅更新某一路数据
		if targetId then
			self.serverList[targetId] = clone(self.localList[targetId])
            -- 更新服务端圣物数据
            for _, group in ipairs(self.info.armys or {}) do
                for k, v in pairs(group.runes or {}) do
                    local tempItem = clone(v)
                    tempItem.cfgId = v.defId
                    self.runeList_server[tonumber(v.id)] = tempItem
                end
            end
		end
	end
    table.sort(self.info.mySoldiers, function(a, b)
        local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
        local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
        return itemA.fight > itemB.fight
    end)
end

-- 选择某一路
function PvpFormationSettingView:selectRoad(tag)
	self.selRoad = tag
	for i, v in ipairs({self.btn_shang, self.btn_zhong, self.btn_xia}) do
		v:setEnabled(v.tag ~= self.selRoad)
	end
	-- 刷新兵力数量
	local tempNum = self:getTroopSoliderNum()
	self.text_limit1:setString(string.format("%s/", tempNum))
    self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
	-- 快速配置方式
	local fastType = self.fastSetting[self.selRoad]
	if fastType == 0 then
		self.img_team_setting:loadTexture(FastSettingMap[1].pic)
		self.text_type:setString("快速配置")
	else
		self.img_team_setting:loadTexture(FastSettingMap[fastType].pic)
		self.text_type:setString(FastSettingMap[fastType].name)
	end
    -- 有改变才可保存
    self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
	-- 刷新士兵table
	self:refreshSoliderTableView()
	-- 刷新战舰table
	self:refreshShipTableView()
	-- 默认选择英雄
	self:selectAppend(AppendTab.HERO)
end

-- 刷新士兵tableview
function PvpFormationSettingView:refreshSoliderTableView()
	local tableSize = self.layout_table_solider:getContentSize()
	local function numberOfCellsInTableView(table)
        return #self.info.mySoldiers
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 120 + 5
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        	-- 创建模板
            local node = self.layout_item_solider:clone()
	        node:setVisible(true)
	        node:setPosition(cc.p(0, 5))
	        cell:addChild(node)
	        cell.node = node
        end

        local soliderInfo = self.info.mySoldiers[idx + 1]
       	-- 该兵种三路可用总数量
       	local totalNum = soliderInfo.num
        -- 其他2路已使用的数量
        local num_other_road = 0
        for k, v in pairs(RoadTab) do
        	if v ~= self.selRoad then
        		num_other_road = num_other_road + self.localList[v].solider[soliderInfo.id]
        	end
        end
        -- 本路可使用最大数量
        local max_num_use = totalNum - num_other_road
        local soliderCfg = cfg[CfgType.CFG_SOLDIER][soliderInfo.id]
        local localSolider = self.localList[self.selRoad].solider

        -- 头像
        local img_header = me.assignWidget(cell.node, "img_header")
        img_header:loadTexture(soliderCfg.icon..".png")
        -- 名字
        local text_name = me.assignWidget(cell.node, "text_name")
        text_name:setString(soliderCfg.name)
        -- 数量
        local text_num = me.assignWidget(cell.node, "text_num")
        text_num:setString(localSolider[soliderInfo.id])
        -- 滑动条
        local slider_num = me.assignWidget(cell.node, "slider_num")
        if max_num_use > 0 then
            text_num:setTextColor(cc.c3b(0xfe, 0xf2, 0xcc))
        	slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
        else
            text_num:setTextColor(cc.c3b(0xf1, 0x43, 0x43))
        	slider_num:setPercent(0)
        end
        local function sliderEvent(sender, eventType)
            if eventType == ccui.SliderEventType.slideBallDown then
                if not PvpMainView.inSignUp then
                    showTips("当前阶段只能更换分路，不能调整阵容配置")
                elseif max_num_use <= 0 then
                    showTips("已分配至其他路")
                end
	        elseif eventType == ccui.SliderEventType.percentChanged then
                if not PvpMainView.inSignUp then
                    sender:setPercent(0)
                    return
                end
                if max_num_use <= 0 then 
                    sender:setPercent(0)
                    return
                end
	            localSolider[soliderInfo.id] = math.floor(sender:getPercent() / 100 * max_num_use)
	            text_num:setString(localSolider[soliderInfo.id])
	           	local tempNum = self:getTroopSoliderNum()
                self.text_limit1:setString(string.format("%s/", tempNum))
                self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
            elseif eventType == ccui.SliderEventType.slideBallUp then
                local tempNum = self:getTroopSoliderNum()
                if tempNum > self.soliderLimit then
                    showTips("超出了可带军队的最大值")
                    local outNum = tempNum - self.soliderLimit
                    localSolider[soliderInfo.id] = localSolider[soliderInfo.id] - outNum
                    tempNum = self:getTroopSoliderNum()
                    text_num:setString(localSolider[soliderInfo.id])
                    slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
                    self.text_limit1:setString(string.format("%s/", tempNum))
                    self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
                    -- 有改变才可保存
                    self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
                end
	        end
	    end
	    slider_num:addEventListener(sliderEvent)        
        -- 加减
        local btn_reduce = me.assignWidget(cell.node, "btn_reduce")
        me.registGuiClickEvent(btn_reduce, function(sender)
            if not PvpMainView.inSignUp then
                showTips("当前阶段只能更换分路，不能调整阵容配置")
                return
            end
        	if localSolider[soliderInfo.id] > 0 then
        		localSolider[soliderInfo.id] = localSolider[soliderInfo.id] - 1
        		text_num:setString(localSolider[soliderInfo.id])
        		slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
        		local tempNum = self:getTroopSoliderNum()
                self.text_limit1:setString(string.format("%s/", tempNum))
                self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        	end
	    end)
        local btn_add = me.assignWidget(cell.node, "btn_add")
        me.registGuiClickEvent(btn_add, function(sender)
            if not PvpMainView.inSignUp then
                showTips("当前阶段只能更换分路，不能调整阵容配置")
                return
            end
            if max_num_use <= 0 then
                showTips("可用数量不足")
                return
            end
			if localSolider[soliderInfo.id] < max_num_use then
				local tempNum = self:getTroopSoliderNum()
				if tempNum >= self.soliderLimit then
					showTips("超出了可带军队的最大值")
					return
				end
				localSolider[soliderInfo.id] = localSolider[soliderInfo.id] + 1
				text_num:setString(localSolider[soliderInfo.id])
				slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
                self.text_limit1:setString(string.format("%s/", tempNum))
                self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
			end
	    end)

        -- 头像快捷操作
        local img_header_bg = me.assignWidget(cell.node, "img_header_bg")
        me.registGuiClickEvent(img_header_bg, function(sender)
            if not PvpMainView.inSignUp then
                showTips("当前阶段只能更换分路，不能调整阵容配置")
                return
            end
            if localSolider[soliderInfo.id] > 0 then
                localSolider[soliderInfo.id] = 0
                text_num:setString(localSolider[soliderInfo.id])
                slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
                local tempNum = self:getTroopSoliderNum()
                self.text_limit1:setString(string.format("%s/", tempNum))
                self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
            else
                if max_num_use <= 0 then
                    showTips("可用数量不足")
                    return
                end
                localSolider[soliderInfo.id] = max_num_use
                local tempNum = self:getTroopSoliderNum()
                if tempNum > self.soliderLimit then
                    localSolider[soliderInfo.id] = localSolider[soliderInfo.id] - (tempNum - self.soliderLimit)
                    tempNum = self:getTroopSoliderNum()
                end
                text_num:setString(localSolider[soliderInfo.id])
                slider_num:setPercent(localSolider[soliderInfo.id] * 100 / max_num_use)
                self.text_limit1:setString(string.format("%s/", tempNum))
                self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
            end
            -- 有改变才可保存
            self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        end)

        -- 不在报名阶段
        if not PvpMainView.inSignUp then
            slider_num:setEnabled(false)
            btn_reduce:setBright(false)
            btn_add:setBright(false)
        else
            slider_num:setEnabled(true)
            btn_reduce:setBright(true)
            btn_add:setBright(true)
        end
        return cell
    end
    self.layout_table_solider:removeAllChildren()
    local tableView = cc.TableView:create(tableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.layout_table_solider:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView_solider = tableView
end

-- 获取当前出征士兵数量
function PvpFormationSettingView:getTroopSoliderNum()
	local localSolider = self.localList[self.selRoad].solider
	local tempNum = 0
	for k, v in pairs(localSolider) do
		tempNum = tempNum + v
	end
	return tempNum
end

-- 刷新战舰tableview
function PvpFormationSettingView:refreshShipTableView()
	local tableSize = self.layout_table_ship:getContentSize()
	local function numberOfCellsInTableView(table)
        return #self.shipList
    end
    local function cellSizeForTable(table, idx)
        return tableSize.width, 107 + 5
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
        	-- 创建模板
            local node = self.layout_item_ship:clone()
	        node:setVisible(true)
	        node:setPosition(cc.p(0, 5))
	        cell:addChild(node)
	        cell.node = node
        end

        local shipCfg = self.shipList[idx + 1]
        local shipInfo = user.warshipData[shipCfg.type]
        -- 弹药恢复
        local btn_recovery = me.assignWidget(cell.node, "btn_recovery")
        btn_recovery:setEnabled(false)
        -- 弹药进度
        local bar_ammo = me.assignWidget(cell.node, "bar_ammo")
        -- 船只
        local img_info = me.assignWidget(cell.node, "img_info")
        img_info:setSwallowTouches(false)
        local img_ship = me.assignWidget(img_info, "img_ship")
        img_ship:ignoreContentAdaptWithSize(true)
        img_ship:setScale(0.3)
        -- 锁
        local img_lock = me.assignWidget(img_info, "img_lock")
        local img_check = me.assignWidget(img_info, "img_check")
        -- 状态
        local text_status = me.assignWidget(img_info, "text_status")
        -- 叉
        local img_forbid = me.assignWidget(img_info, "img_forbid")
        -- 选择
        local img_select = me.assignWidget(img_info, "img_select")
        -- 等级
        local img_lv = me.assignWidget(img_info, "img_lv")
        local text_lv = me.assignWidget(img_info, "text_lv")
    	-- 是否拥有
        if shipInfo then
        	--bar_ammo:setPercent(shipInfo.nowFire * 100 / shipInfo.baseShipCfg.endure)
            bar_ammo:setPercent(100)
        	img_ship:loadTexture("zhanjian_tupian_zhanjian_"..shipInfo.baseShipCfg.icon..".png")
        	me.Helper:normalImageView(img_ship)
        	img_lock:setVisible(false)
        	img_check:setVisible(true)
        	text_status:setVisible(true)
        	if self.localList[RoadTab.UP].ship == shipInfo.type then
        		text_status:setString("上路")
        		img_forbid:setVisible(self.selRoad ~= RoadTab.UP)
        	elseif self.localList[RoadTab.MIDDLE].ship == shipInfo.type then
        		text_status:setString("中路")
        		img_forbid:setVisible(self.selRoad ~= RoadTab.MIDDLE)
        	elseif self.localList[RoadTab.DOWN].ship == shipInfo.type then
        		text_status:setString("下路")
        		img_forbid:setVisible(self.selRoad ~= RoadTab.DOWN)
        	else
        		text_status:setString("空闲")
        		img_forbid:setVisible(false)
        	end
        	img_select:setVisible(self.localList[self.selRoad].ship == shipInfo.type)
        	img_lv:setVisible(true)
        	text_lv:setVisible(true)
        	text_lv:setString(shipInfo.baseShipCfg.lv)
        	me.registGuiClickEvent(img_info, function()
                if not PvpMainView.inSignUp then
                    showTips("当前阶段只能更换分路，不能调整阵容配置")
                    return
                end
        		if self.localList[self.selRoad].ship == shipInfo.type then
        			self.localList[self.selRoad].ship = 0
        			img_select:setVisible(false)
        		else
        			if self.localList[RoadTab.UP].ship ~= shipInfo.type and self.localList[RoadTab.MIDDLE].ship ~= shipInfo.type 
        				and self.localList[RoadTab.DOWN].ship ~= shipInfo.type then
        				for j = 0, #self.shipList - 1 do
        					local cell_ = self.tableView_ship:cellAtIndex(j)
        					if cell_ and cell_.node then
       							local img_info_ = me.assignWidget(cell_.node, "img_info")
       							local img_select_ = me.assignWidget(img_info_, "img_select")
       							img_select_:setVisible(false)
        					end
        				end
        				self.localList[self.selRoad].ship = shipInfo.type
        				img_select:setVisible(true)
        			end
        		end
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        	end)
        else
        	bar_ammo:setPercent(100)
        	img_ship:loadTexture("zhanjian_tupian_zhanjian_"..shipCfg.icon..".png")
        	me.Helper:grayImageView(img_ship)
        	img_lock:setVisible(true)
        	img_check:setVisible(false)
        	text_status:setVisible(false)
        	img_forbid:setVisible(false)
        	img_select:setVisible(false)
        	img_lv:setVisible(false)
        	text_lv:setVisible(false)
        	me.registGuiClickEvent(img_info, function()
        		showTips("未解锁")
        	end)
        end
        -- 不在报名阶段
        if not PvpMainView.inSignUp then
            
        end

        return cell
    end
    self.layout_table_ship:removeAllChildren()
    local tableView = cc.TableView:create(tableSize)
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setDelegate()
    tableView:setPosition(cc.p(0, 0))
    self.layout_table_ship:addChild(tableView)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.tableView_ship = tableView
end

-- 选择附加页签 英雄 or 生物
function PvpFormationSettingView:selectAppend(tag)
	self.selAppend = tag
	for i, v in ipairs({self.btn_hero, self.btn_rune}) do
		v:setEnabled(v.tag ~= self.selAppend)
	end	
	-- 英雄
	if self.selAppend == AppendTab.HERO then
		self:createHeroSlots()
	-- 圣物
	elseif self.selAppend == AppendTab.RUNE then
		self:createRuneSlots()
	end
end

-- 创建英雄卡槽
function PvpFormationSettingView:createHeroSlots()
	local localAppend = self.localList[self.selRoad].append[AppendTab.HERO]
	-- 展示选择页面
	local function showSelectView(index)
        if not PvpMainView.inSignUp then
            showTips("当前阶段只能更换分路，不能调整阵容配置")
            return
        end
        -- 排除已上阵的
        local excludeMap = {}
        for _, v1 in pairs(RoadTab) do
            for _, v2 in ipairs(self.localList[v1].append[AppendTab.HERO]) do
                if v2 ~= 0 then
                    excludeMap[v2] = true
                end
            end
        end
        -- 可用的英雄
        local usableList = {}
        -- 背包中的英雄
        for k, v in pairs(user.bookPkg) do
            if cfg[CfgType.ETC][v.defid].useType == 10 and not excludeMap[v.uid] then
                table.insert(usableList, clone(v))
            end
        end
        -- 考古携带的英雄
        for k, v in pairs(user.bookEquip) do
            if cfg[CfgType.ETC][v.defid].useType == 10 and not excludeMap[v.uid] then
                table.insert(usableList, clone(v))
            end
        end
        table.sort(usableList, function(a, b)
            return a.defid < b.defid
        end)
        if #usableList <= 0 then
            showTips("没有更多英雄可上阵")
        else
            local view = PvpSelectHeroView:create("pvp/PvpSelectHeroView.csb")
            self:addChild(view)
            me.showLayer(view, "img_bg")
            view:setPvpHeroData(usableList)
            view:setSelectCallback(function(heroInfo)
                localAppend[index] = heroInfo.uid
                self:selectAppend(self.selAppend)
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
            end)
        end
	end
	self.node_slot:removeAllChildren()
	for i = 1, 5 do
		local node = self.item_slot_hero:clone()
		node:setVisible(true)
		node:setPosition(cc.p((i - 1) * 120, 0))
		self.node_slot:addChild(node)
		me.registGuiClickEvent(node, function()
			showSelectView(i)
		end)
		-- 加号
		local img_add = me.assignWidget(node, "img_add")
		-- 头像
		local img_header = me.assignWidget(node, "img_header")
        local panel_star = me.assignWidget(node, "panel_star")
		-- 删除
		local img_delete = me.assignWidget(node, "img_delete")
		-- 空展示
		local function showEmptyView()
			node:setTouchEnabled(true)
			img_add:setVisible(true)
			img_add:stopAllActions()
			img_add:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.ScaleTo:create(1.0, 1.2),
				cc.ScaleTo:create(1.0, 1.0)
			)))
			img_header:setVisible(false)
            panel_star:setVisible(false)
			img_delete:setVisible(false)
		end
		-- 非空展示
		local function showNormalView()
			node:setTouchEnabled(false)
			img_add:setVisible(false)
			img_add:stopAllActions()
			-- 英雄信息
			local heroInfo = self.heroList[localAppend[i]]
			img_header:setVisible(true)
			img_header:loadTexture(getItemIcon(heroInfo.defid))
			me.registGuiClickEvent(img_header, function()
				local view = PvpHeroDetailView:create("pvp/PvpHeroDetailView.csb")
        		self:addChild(view)
        		me.showLayer(view, "img_bg")
        		view:refreshView(heroInfo)
        		view:setUnloadCallback(function()
        			localAppend[i] = 0
					showEmptyView()
                    -- 有改变才可保存
                    self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        		end)
        		view:setReplaceCallback(function()
        			showSelectView(i)
        		end)
			end)
            panel_star:setVisible(true)
			img_delete:setVisible(true)
			me.registGuiClickEvent(img_delete, function()
				localAppend[i] = 0
				showEmptyView()
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
			end)

            -- 星级
            local starLv = heroInfo.level
            panel_star:removeAllChildren()
            local starWidth = 15
            local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
            for i = 1, starLv do
                local img_star = ccui.ImageView:create()
                img_star:loadTexture("rune_star.png", me.localType)
                local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
                local y = 25
                img_star:setPosition(cc.p(x, y))
                img_star:setScale(0.5)
                panel_star:addChild(img_star)
            end
		end
		if localAppend[i] == 0 then
			showEmptyView()
		else
			showNormalView()
		end
        -- 不在报名阶段
        if not PvpMainView.inSignUp then
            img_add:stopAllActions()
            me.Helper:grayImageView(img_add)
            img_delete:setVisible(false)
        end
	end
end

-- 创建圣物卡槽
function PvpFormationSettingView:createRuneSlots()
	local localAppend = self.localList[self.selRoad].append[AppendTab.RUNE]
	-- 展示选择页面
	local function showSelectView(index)
        if not PvpMainView.inSignUp then
            showTips("当前阶段只能更换分路，不能调整阵容配置")
            return
        end
        -- 排除已上阵的
		local excludeMap = {}
		for _, v1 in pairs(RoadTab) do
			for _, v2 in ipairs(self.localList[v1].append[AppendTab.RUNE]) do
				if v2 ~= 0 then
					excludeMap[v2] = true
				end
			end
		end
        -- 可用的英雄
        local usableList = {}
        -- 已装备的
        for _, group in pairs(user.runeEquiped) do
            for _, v in pairs(group) do
                if cfg[CfgType.RUNE_DATA][v.cfgId].type ~= 99 and not excludeMap[v.id] then
                    table.insert(usableList,  clone(v))
                end
            end
        end
        -- 背包中的
        for _, v in pairs(user.runeBackpack) do
            if cfg[CfgType.RUNE_DATA][v.cfgId].type ~= 99 and not excludeMap[v.id] then
                table.insert(usableList,  clone(v))
            end
        end
        if #usableList <= 0 then
            showTips("没有更多圣物可上阵")
        else
            local view = runeSelectView:create("runeSelectView.csb")
            self:addChild(view)
            me.showLayer(view, "bg")
            view:setPvpRuneData(usableList)
            view:registerSelecCallback(function(runeInfo)
                -- 本地圣物可能升级、升星，服务端数据却还是老数据，此处优先使用本地圣物数据
                self.runeDataLocalFirst = true
                localAppend[index] = runeInfo.id
                self:selectAppend(self.selAppend)
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
                self.runeDataLocalFirst = false
            end)
        end
	end
	self.node_slot:removeAllChildren()
	for i = 1, 4 do
		local node = self.item_slot_rune:clone()
		node:setVisible(true)
		node:setPosition(cc.p((i- 1) * 95, 0))
		self.node_slot:addChild(node)
		me.registGuiClickEvent(node, function()
			showSelectView(i)
		end)
		-- 加号
		local img_add = me.assignWidget(node, "img_add")
		-- 头像
		local img_header = me.assignWidget(node, "img_header")
		-- 信息
		local img_info = me.assignWidget(node, "img_info")
		-- 删除
		local img_delete = me.assignWidget(node, "img_delete")
		-- 空展示
		local function showEmptyView()
			node:setTouchEnabled(true)
			img_add:setVisible(true)
			img_add:stopAllActions()
			img_add:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.ScaleTo:create(1.0, 0.9),
				cc.ScaleTo:create(1.0, 0.7)
			)))
			img_header:setVisible(false)
			img_info:setVisible(false)
			img_delete:setVisible(false)
		end
		-- 非空展示
		local function showNormalView()
			node:setTouchEnabled(false)
			img_add:setVisible(false)
			img_add:stopAllActions()
			-- 圣物信息
            --[[
                上阵某个圣物后，分解这个圣物，本地圣物信息不存在，服务端圣物信息存在，
                此处需优先读取服务端的圣物数据，然后再读本地
            --]]
            local runeInfo
            if self.runeDataLocalFirst then
                runeInfo = self.runeList_local[localAppend[i]] or self.runeList_server[localAppend[i]]
            else
                runeInfo = self.runeList_server[localAppend[i]] or self.runeList_local[localAppend[i]]
            end
			local cfgItem = cfg[CfgType.RUNE_DATA][runeInfo.cfgId]
			-- 图标
			img_header:setVisible(true)
			img_header:loadTexture(getRuneIcon(cfgItem.icon))
			-- 品质框
			img_info:setVisible(true)
			img_info:loadTexture("levelbox"..cfgItem.level..".png")
			me.registGuiClickEvent(img_info, function()
				local view = runeDetailView:create("runeDetailView.csb")
                self:addChild(view)
                me.showLayer(view, "bg")
                view:setRuneInfo(runeInfo)
                -- 卸下回调
                local function unloadCallback()
                	localAppend[i] = 0
					showEmptyView()
                    -- 有改变才可保存
                    self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
                end
                -- 替换回调
                local function replaceCallback()
                	showSelectView(i)
                end
                -- 跨服争霸展示
                view:showPvpView(unloadCallback, replaceCallback)
			end)
			-- 名字
			local text_name = me.assignWidget(img_info, "text_name")
			text_name:setString(cfgItem.name)
			-- 等级
			local img_lv = me.assignWidget(img_info, "img_lv")
			img_lv:loadTexture("levelbox"..cfgItem.level.."_c1.png")
			local text_lv = me.assignWidget(img_info, "text_lv")
			text_lv:setString(cfg[CfgType.RUNE_STRENGTH][runeInfo.glv].level)
			-- 类型
			local img_type_bg = me.assignWidget(img_info, "img_type_bg")
			img_type_bg:loadTexture("levelbox"..cfgItem.level.."_c2.png")
			local img_type = me.assignWidget(img_info, "img_type")
			img_type:loadTexture("rune_type_"..cfgItem.type..".png")
            -- 技能
            local img_skill = me.assignWidget(img_info, "img_skill")
            if runeInfo.runeSkillId and runeInfo.runeSkillId > 0 then
                img_skill:setVisible(true)
                local cfg_item = cfg[CfgType.RUNE_SKILL][runeInfo.runeSkillId]
                local img_skill_icon = me.assignWidget(img_skill, "img_skill_icon")
                img_skill_icon:loadTexture("juexing_"..cfg_item.icon..".png", me.localType)
                local img_skill_lv = me.assignWidget(img_skill, "img_skill_lv")
                img_skill_lv:loadTexture("runeAwaken"..cfg_item.level..".png", me.localType)
            else
                img_skill:setVisible(false)
            end
			-- 星级
			local starLv = runeInfo.star
			local panel_star = me.assignWidget(img_info, "panel_star")
			panel_star:removeAllChildren()
			local starWidth = 10
			local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
			for i = 1, starLv do
				local img_star = ccui.ImageView:create()
				img_star:loadTexture("rune_star.png", me.localType)
				local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
				local y = 8
				img_star:setPosition(cc.p(x, y))
				img_star:setScale(0.3)
				panel_star:addChild(img_star)
			end
			-- 删除
			img_delete:setVisible(true)
			me.registGuiClickEvent(img_delete, function()
				localAppend[i] = 0
				showEmptyView()
                -- 有改变才可保存
                self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
			end)
		end
		if localAppend[i] == 0 then
			showEmptyView()
		else
			showNormalView()
		end
        -- 不在报名阶段
        if not PvpMainView.inSignUp then
            img_add:stopAllActions()
            me.Helper:grayImageView(img_add)
            img_delete:setVisible(false)
        end
	end
end

-- 上传某一路的配置到服务器
function PvpFormationSettingView:saveSettingToServer(road)
	local localList = self.localList[road]
	-- 构造数据
	local tempList = {}
	tempList.id = road
	tempList.ship = localList.ship
	tempList.army = {}
	for k, v in pairs(localList.solider) do
		if v > 0 then
			table.insert(tempList.army, {id = k, num = v})
		end
	end
	tempList.hero = {}
	for i, v in ipairs(localList.append[AppendTab.HERO]) do
		if v ~= 0 then
			table.insert(tempList.hero, {id = v, loc = i})
		end
	end
	tempList.rune = {}
	for i, v in ipairs(localList.append[AppendTab.RUNE]) do
		if v ~= 0 then
			table.insert(tempList.rune, {id = v, loc = i})
		end
	end
	-- 保存部署信息
    NetMan:send(_MSG.set_pvp_formation(tempList))
end

-- 队伍互换页面
function PvpFormationSettingView:showExchangeView()
	self.panel_team_exchange:setVisible(true)
	local list1 = {
		{id = RoadTab.UP, title = "与上路互换", name = "上路"},
		{id = RoadTab.MIDDLE, title = "与中路互换", name = "中路"},
		{id = RoadTab.DOWN, title = "与下路互换", name = "下路"},
	}
	local list2 = {}
	for i, v in ipairs(list1) do
		if v.id ~= self.selRoad then
			table.insert(list2, v)
		end
	end
	for i, v in ipairs(list2) do
		local btn = me.assignWidget(self.panel_team_exchange, "btn_"..i)
		btn:setTitleText(v.title)
		me.registGuiClickEvent(btn, function()
			self.panel_team_exchange:setVisible(false)
			if self:checkLocalChanged(self.selRoad) then
				showTips("本路配置发生变化，请先保存")
			elseif self:checkLocalChanged(v.id) then
				showTips(string.format("%s配置发生变化，请先保存", v.name))
			else
				-- 互换队伍
    			NetMan:send(_MSG.exchange_pvp_formation(self.selRoad, v.id))
			end
		end)
	end
end

-- 检测某一路设置是否发生改变
function PvpFormationSettingView:checkLocalChanged(roadTag)
    -- 过了报名阶段不再检测
    if not PvpMainView.inSignUp then
        return false
    end
	if self.localList[roadTag].ship ~= self.serverList[roadTag].ship then
		return true
	end
	for k, v in pairs(self.localList[roadTag].solider) do
		if v ~= self.serverList[roadTag].solider[k] then
			return true
		end
	end
	for k, list in pairs(self.localList[roadTag].append) do
		for i, v in ipairs(list) do
			if v ~= self.serverList[roadTag].append[k][i] then
				return true
			end
		end
	end
    -- 单独检测圣物属性
    for i, v in ipairs(self.localList[roadTag].append[AppendTab.RUNE]) do
        if self.runeList_server[v] and self.runeList_local[v] then
            if self.runeList_server[v].glv ~= self.runeList_local[v].glv
                or self.runeList_server[v].star ~= self.runeList_local[v].star
                or me.cjson.encode(self.runeList_server[v].apt) ~= me.cjson.encode(self.runeList_local[v].apt)
                or self.runeList_server[v].runeSkillId ~= self.runeList_local[v].runeSkillId then
                return true
            end
        end
    end

	return false
end

-- 士兵配置方式页面
function PvpFormationSettingView:showConfigureView()
	self.panel_team_setting:setVisible(true)
    for k, v in pairs(FastSettingMap) do
        me.registGuiClickEventByName(self.panel_team_setting, "item_"..k, function(sender)
        	self.fastSetting[self.selRoad] = k
            self.panel_team_setting:setVisible(false)
			self.img_team_setting:loadTexture(v.pic)
			self.text_type:setString(v.name)
            -- 修改士兵分配
            self:modifySoliderAllocation(k)
            -- 有改变才可保存
            self.btn_ok:setEnabled(self:checkLocalChanged(self.selRoad))
        end )
    end
end

-- 修改士兵分配
function PvpFormationSettingView:modifySoliderAllocation(allocateType)
	local localSolider = self.localList[self.selRoad].solider
	local soliderIdList = table.keys(localSolider)
	-- 清空选中
	for _, soliderId in ipairs(soliderIdList) do
		localSolider[soliderId] = 0
	end
	if allocateType ~= 41 then
		-- 战力优先
		if allocateType == 1 then
			table.sort(soliderIdList, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a]
				local itemB = cfg[CfgType.CFG_SOLDIER][b]
				return itemA.traintime > itemB.traintime
			end)
		-- 速度优先
		elseif allocateType == 2 then
			table.sort(soliderIdList, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a]
				local itemB = cfg[CfgType.CFG_SOLDIER][b]
				return itemA.speed > itemB.speed
			end)
		-- 负重优先
		elseif allocateType == 3 then
			table.sort(soliderIdList, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a]
				local itemB = cfg[CfgType.CFG_SOLDIER][b]
				return itemA.carry > itemB.carry
			end)
		-- 均衡配置
		elseif allocateType == 4 then
			table.sort(soliderIdList, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a]
				local itemB = cfg[CfgType.CFG_SOLDIER][b]
				return itemA.traintime > itemB.traintime
			end)
		-- 兵种优先
		elseif allocateType == 11 or allocateType == 21 or allocateType == 31 then
			-- 分配方式-兵种 映射表
	        local tempMap = {[11] = 1, [21] = 2, [31] = 3}
	        local currType = tempMap[allocateType]
	        table.sort(soliderIdList, function(a, b)
	            local itemA = cfg[CfgType.CFG_SOLDIER][a]
				local itemB = cfg[CfgType.CFG_SOLDIER][b]
	            local priorityA = itemA.bigType == currType and 1 or 2
	            local priorityB = itemB.bigType == currType and 1 or 2
	            if priorityA ~= priorityB then
	                return priorityA < priorityB
	            else
	                return itemA.fight > itemB.fight
	            end
	        end)
		end
		-- 各兵种总数
		local soliderNumMap = {}
		for _, v in ipairs(self.info.mySoldiers) do
			soliderNumMap[v.id] = v.num
		end
        -- 本路可用的兵种总数
        local totalNum_currRoad = 0
        for _, soliderId in ipairs(soliderIdList) do
            -- 其他2路已使用的数量
            local num_other_road = 0
            for k, v in pairs(RoadTab) do
                if v ~= self.selRoad then
                    num_other_road = num_other_road + self.localList[v].solider[soliderId]
                end
            end
            -- 本路可使用最大数量
            local max_num_use = soliderNumMap[soliderId] - num_other_road
            totalNum_currRoad = totalNum_currRoad + max_num_use
        end
        -- 均衡配置
        if allocateType == 4 then
            local tempSum = 0
            for _, soliderId in ipairs(soliderIdList) do
                -- 其他2路已使用的数量
                local num_other_road = 0
                for k, v in pairs(RoadTab) do
                    if v ~= self.selRoad then
                        num_other_road = num_other_road + self.localList[v].solider[soliderId]
                    end
                end
                -- 本路可使用最大数量
                local max_num_use = soliderNumMap[soliderId] - num_other_road
                local tempNum = math.min(math.floor(max_num_use * self.soliderLimit / totalNum_currRoad), max_num_use)
                if tempSum + tempNum > self.soliderLimit then
                    local removeNum = tempSum + tempNum - self.soliderLimit
                    tempSum = tempSum + tempNum - removeNum
                    localSolider[soliderId] = tempNum - removeNum
                    break
                else
                    tempSum = tempSum + tempNum
                    localSolider[soliderId] = tempNum
                end
            end
            -- 从前往后弥补
            if tempSum < self.soliderLimit and totalNum_currRoad >= self.soliderLimit then
                for _, soliderId in ipairs(soliderIdList) do
                    -- 其他2路已使用的数量
                    local num_other_road = 0
                    for k, v in pairs(RoadTab) do
                        if v ~= self.selRoad then
                            num_other_road = num_other_road + self.localList[v].solider[soliderId]
                        end
                    end
                    -- 本路可使用最大数量
                    local max_num_use = soliderNumMap[soliderId] - num_other_road
                    local leftNum = max_num_use - localSolider[soliderId]
                    if tempSum + leftNum > self.soliderLimit then
                        localSolider[soliderId] = localSolider[soliderId] + self.soliderLimit - tempSum
                        tempSum = self.soliderLimit
                        break
                    else
                        localSolider[soliderId] = localSolider[soliderId] + leftNum
                        tempSum = tempSum + leftNum
                    end
                end
            end
        else
            local tempSum = 0
            for _, soliderId in ipairs(soliderIdList) do
                -- 其他2路已使用的数量
                local num_other_road = 0
                for k, v in pairs(RoadTab) do
                    if v ~= self.selRoad then
                        num_other_road = num_other_road + self.localList[v].solider[soliderId]
                    end
                end
                -- 本路可使用最大数量
                local max_num_use = soliderNumMap[soliderId] - num_other_road
                if tempSum + max_num_use > self.soliderLimit then
                    local removeNum = tempSum + max_num_use - self.soliderLimit
                    tempSum = tempSum + max_num_use - removeNum
                    localSolider[soliderId] = max_num_use - removeNum
                    break
                else
                    tempSum = tempSum + max_num_use
                    localSolider[soliderId] = max_num_use
                end
            end
        end
	end
	-- 刷新
    if allocateType ~= 41 then
		-- 战力优先
		if allocateType == 1 then
			table.sort(self.info.mySoldiers, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
				local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
				return itemA.traintime > itemB.traintime
			end)
		-- 速度优先
		elseif allocateType == 2 then
			table.sort(self.info.mySoldiers, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
				local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
				return itemA.speed > itemB.speed
			end)
		-- 负重优先
		elseif allocateType == 3 then
			table.sort(self.info.mySoldiers, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
				local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
				return itemA.carry > itemB.carry
			end)
		-- 均衡配置
		elseif allocateType == 4 then
			table.sort(self.info.mySoldiers, function(a, b)
				local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
				local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
				return itemA.traintime > itemB.traintime
			end)
		-- 兵种优先
		elseif allocateType == 11 or allocateType == 21 or allocateType == 31 then
			-- 分配方式-兵种 映射表
	        local tempMap = {[11] = 1, [21] = 2, [31] = 3}
	        local currType = tempMap[allocateType]
	        table.sort(self.info.mySoldiers, function(a, b)
	            local itemA = cfg[CfgType.CFG_SOLDIER][a.id]
				local itemB = cfg[CfgType.CFG_SOLDIER][b.id]
	            local priorityA = itemA.bigType == currType and 1 or 2
	            local priorityB = itemB.bigType == currType and 1 or 2
	            if priorityA ~= priorityB then
	                return priorityA < priorityB
	            else
	                return itemA.fight > itemB.fight
	            end
	        end)
		end
    end
	local tempNum = self:getTroopSoliderNum()
	self.text_limit1:setString(string.format("%s/", tempNum))
    self.text_limit2:setPositionX(self.text_limit1:getContentSize().width)
	self.tableView_solider:reloadData()
end

-- 3路都设置完毕后的回调
function PvpFormationSettingView:setFinishCallback(finishCb)
    self.finishCb = finishCb
end

-- 设置是否报名
function PvpFormationSettingView:setSignUpStatus(val)
    self.signUp = val
end

function PvpFormationSettingView:onEnter()
    print("PvpFormationSettingView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpFormationSettingView:onEnterTransitionDidFinish()
    print("PvpFormationSettingView onEnterTransitionDidFinish")
end

function PvpFormationSettingView:onExit()
    print("PvpFormationSettingView onExit")
    UserModel:removeLisener(self.lisener)
end
