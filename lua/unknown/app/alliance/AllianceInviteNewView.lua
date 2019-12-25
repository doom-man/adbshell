--[[
	文件名：AllianceInviteNewView.lua
	描述：联盟邀请页面(新)
	创建人：libowen
	创建时间：2019.12.13
--]]

AllianceInviteNewView = class("AllianceInviteNewView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
AllianceInviteNewView.__index = AllianceInviteNewView

function AllianceInviteNewView:create(...)
    local layer = AllianceInviteNewView.new(...)
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
function AllianceInviteNewView:ctor()
    print("AllianceInviteNewView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.FAMILY_REQUEST_LIST) then
        	self:refreshView()
        end
    end)
    -- 获取邀请列表
    NetMan:send(_MSG.requestListFamily())
end

-- 初始化
function AllianceInviteNewView:init()
    print("AllianceInviteNewView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    self.node_table = me.assignWidget(self.img_bg, "node_table")
    -- 标题面板
    self.title_table = me.assignWidget(self.img_bg, "title_table")
    self.title_table:setVisible(false)
    -- 空提示
    self.img_empty = me.assignWidget(self.img_bg, "img_empty")
    self.img_empty:setVisible(false)
    	
    return true
end

-- 刷新页面
function AllianceInviteNewView:refreshView()
	self.showList = {}
    for k, v in pairs(user.familyRequestList or {}) do
        table.insert(self.showList, v)
    end
    self.node_table:removeAllChildren()
    if #self.showList > 0 then
        self.title_table:setVisible(true)
        self.img_empty:setVisible(false)
        self:refreshTableView()
    else
        self.title_table:setVisible(false)
        self.img_empty:setVisible(true)
    end
end

-- 刷新列表
function AllianceInviteNewView:refreshTableView()
	function numberOfCellsInTableView(table)
        return #self.showList
    end
    local function cellSizeForTable(table, idx)
        return 1158, 70
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if not cell then
            cell = cc.TableViewCell:new()
            local img_cell = alliancecrcell:create(self.img_bg, "img_cell")
            img_cell:setVisible(true)
            img_cell:setData(self.showList[idx + 1], false)
            me.assignWidget(img_cell, "Panel_16"):setVisible(idx % 2 ~= 0)
         	-- 同意
            local pButtonAgree = me.registGuiClickEventByName(img_cell, "Button_agree_alliance", function(node)
                local pIdx = node:getTag()
           		-- 同意联盟邀请， 响应消息： 3655、1812、1796
                NetMan:send(_MSG.agreeFamily(self.showList[pIdx]["uid"], true))
            end )
            pButtonAgree:setTag(idx + 1)
        	-- 拒绝
            local pButtonrefuse = me.registGuiClickEventByName(img_cell, "Button_refuse_alliance", function(node)
                local pIdx = node:getTag()
                -- 拒绝联盟邀请，响应消息：1805
                NetMan:send(_MSG.agreeFamily(self.showList[pIdx]["uid"], false))
            end )
            pButtonrefuse:setTag(idx + 1)
            pButtonAgree:setSwallowTouches(false)
            pButtonrefuse:setSwallowTouches(false)
            img_cell:setPosition(cc.p(0, 0))
            cell:addChild(img_cell)
        else
            local img_cell = me.assignWidget(cell, "img_cell")
            img_cell:setData(self.showList[idx + 1], false)
            me.assignWidget(img_cell, "Panel_16"):setVisible(idx % 2 ~= 0)
            local pButtonAgree = me.assignWidget(img_cell, "Button_agree_alliance")
            pButtonAgree:setTag(idx + 1)
            local pButtonrefuse = me.assignWidget(img_cell, "Button_refuse_alliance")
            pButtonrefuse:setTag(idx + 1)
        end
        return cell
    end
    local tableView = cc.TableView:create(cc.size(1158, 527))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    self.node_table:addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end

function AllianceInviteNewView:onEnter()
    print("AllianceInviteNewView onEnter")
    me.doLayout(self, me.winSize)
end

function AllianceInviteNewView:onEnterTransitionDidFinish()
    print("AllianceInviteNewView onEnterTransitionDidFinish")
end

function AllianceInviteNewView:onExit()
    print("AllianceInviteNewView onExit")
    UserModel:removeLisener(self.lisener)
end
