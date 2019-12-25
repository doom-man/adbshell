--[[
	文件名：HeaderChangeView.lua
	描述：更换头像页面
	创建人：libowen
	创建时间：2019.9.19
--]]

HeaderChangeView = class("HeaderChangeView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
HeaderChangeView.__index = HeaderChangeView

function HeaderChangeView:create(...)
    local layer = HeaderChangeView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
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
function HeaderChangeView:ctor()
    print("HeaderChangeView ctor")
    -- 数据处理
    self:dealData()
    self.lisener = UserModel:registerLisener( function(msg)
        -- 获取头像列表
        if checkMsg(msg.t, MsgCode.GET_HEAD_LIST) then
            self.ownMap = { }
            for i, v in ipairs(msg.c.list) do
                self.ownMap[v.id] = true
            end
            -- 刷新头像列表
            self:refreshListView()
            -- 更换
        elseif checkMsg(msg.t, MsgCode.CHANGE_HEAD) then
            showTips("更换成功")
            for k, v in pairs(self.img_using_list) do
                v:setVisible(k == user.head)
            end
        elseif  checkMsg(msg.t, MsgCode.SHOW_VIP_MSG) then        
            user.vipshow = msg.c.show
        end
    end )
    NetMan:send(_MSG.get_head_list())
end

-- 数据处理
function HeaderChangeView:dealData()
    local cfg_head = clone(cfg[CfgType.ROLE_HEAD])
    -- 头像分组
    self.groupList = { }
    for k, v in pairs(cfg_head) do
        if v.type ~= 0 then
            self.groupList[v.type] = self.groupList[v.type] or { }
            table.insert(self.groupList[v.type], v)
        end
    end
    -- id排序
    for k, v in pairs(self.groupList) do
        table.sort(v, function(a, b)
            return a.id < b.id
        end)
    end
    self.keys = table.keys(self.groupList)
    table.sort(self.keys, function(a, b)
        return a < b
    end)
end

-- 初始化
function HeaderChangeView:init()
    print("HeaderChangeView init")
    -- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
        self:removeFromParent()
    end )
    -- 滑动窗体
    self.listView_header = me.assignWidget(self.img_bg, "listView_header")
    self.listView_header:setScrollBarEnabled(false)
    -- 模板节点
    self.layout_item = me.assignWidget(self.img_bg, "layout_item")
    self.layout_item:setVisible(false)
    -- 预览
    self.img_look = me.assignWidget(self.img_bg, "img_look")
    self.img_look:ignoreContentAdaptWithSize(true)
    -- 头像描述
    self.node_rich = me.assignWidget(self.img_bg, "node_rich")
    -- 更换按钮
    self.btn_change = me.assignWidget(self.img_bg, "btn_change")
    me.registGuiClickEvent(self.btn_change, function()
        -- 换回时代头像要传0
        local tempId = self.selId
        local cfg_head = cfg[CfgType.ROLE_HEAD]
        if cfg_head[self.selId].type == 0 then
            tempId = 0
        end
        NetMan:send(_MSG.change_head(tempId))
        me.setButtonDisable(self.btn_change, false)
    end )
    self.Image_vip = me.assignWidget(self, "Image_vip")
    self.vip = me.assignWidget(self, "vip")
    self.Image_vip:setVisible(user.vip > 0 and user.vipTime > 0 and user.vipshow == 1)
    self.vip:setString(user.vip)
    local function choose_vipshow(node)        
        if node:isSelected() then
            if user.vipTime>0 then 
                NetMan:send(_MSG.show_vip_msg(1))
                self.Image_vip:setVisible(true)
            else    
                showTips("VIP未激活")
                node:setSelected(false)
            end
        else
            NetMan:send(_MSG.show_vip_msg(0))
            self.Image_vip:setVisible(false)
        end
    end
    self.CheckBox_vipshow = me.assignWidget(self, "CheckBox_vipshow")
    me.registGuiClickEvent(self.CheckBox_vipshow, choose_vipshow)
    self.CheckBox_vipshow:setSelected(user.vipshow == 1)    
    return true
end

-- 刷新列表
function HeaderChangeView:refreshListView()
    self.img_sel_list = { }
    self.img_using_list = { }
    self.listView_header:removeAllItems()
    for _, key in ipairs(self.keys) do
        local group = self.groupList[key]
        -- 列数
        local colNum = 3
        -- 行数
        local rowNum = math.ceil(#group / colNum)
        -- 标题高度
        local titleHeight = 45
        -- 头像所占宽高
        local headerWidth, headerHeight = 142, 135
        -- 计算layout宽高
        local height = rowNum * headerHeight + titleHeight
        local width = self.layout_item:getContentSize().width
        local layout = self.layout_item:clone()
        layout:setContentSize(cc.size(width, height))
        layout:setVisible(true)
        self.listView_header:pushBackCustomItem(layout)
        -- 标题
        local img_title = me.assignWidget(layout, "img_title")
        img_title:setPositionY(height)
        local text_title = me.assignWidget(img_title, "text_title")
        text_title:setString(group[1].typename)

        local startX = 85
        for i = 1, rowNum do
            for j = 1, colNum do
                local item = group[(i - 1) * colNum + j]
                if not item then
                    break
                end
                local x = startX + (j - 1) * headerWidth
                local y = height - titleHeight - headerHeight / 2 - (i - 1) * headerHeight
                -- 底框
                local img_headerBg = ccui.ImageView:create("beibao_kuang_hui.png", me.localType)
                img_headerBg:setContentSize(cc.size(120, 120))
                img_headerBg:setScale9Enabled(true)
                img_headerBg:setPosition(cc.p(x, y))
                layout:addChild(img_headerBg)
                -- 头像
                local img_header = ccui.ImageView:create(item.icon .. ".png", me.localType)
                img_header:setPosition(cc.p(x, y + (item.type == 0 and 7 or 0)))
                layout:addChild(img_header)
                if not self.ownMap[item.id] then
                    me.Helper:grayImageView(img_header)
                end
                me.registGuiClickEvent(img_header, function()
                    -- 选中头像
                    self:selectHeader(item.id)
                end )
                -- 选中框
                local img_sel = ccui.ImageView:create("beibao_xuanzhong_guang.png", me.localType)
                img_sel:setContentSize(cc.size(145, 145))
                img_sel:setScale9Enabled(true)
                img_sel:setCapInsets(cc.rect(20, 20, 1, 1))
                img_sel:setPosition(cc.p(x, y))
                layout:addChild(img_sel)
                img_sel:setVisible(false)
                self.img_sel_list[item.id] = img_sel
                -- 使用中
                local img_using = ccui.ImageView:create()
                img_using:loadTexture("gerenxinxi_40.png", me.localType)
                img_using:setPosition(cc.p(x, y - 45))
                layout:addChild(img_using)
                img_using:setVisible(false)
                self.img_using_list[item.id] = img_using
            end
        end
    end
    -- 选中默认
    self:selectHeader(user.head)
    -- 使用中标识
    for k, v in pairs(self.img_using_list) do
        v:setVisible(k == user.head)
    end
end

-- 选中头像
function HeaderChangeView:selectHeader(id)
    if self.selId == id then
        return
    end
    self.selId = id
    for k, v in pairs(self.img_sel_list) do
        v:setVisible(k == id)
    end
    -- 预览与描述
    local cfg_head = cfg[CfgType.ROLE_HEAD]
    self.img_look:loadTexture(cfg_head[id].icon .. ".png", me.localType)
    self.node_rich:removeAllChildren()
    local richText = mRichText:create(cfg_head[id].desc, 320, "fzlsjt.ttf")
    richText:setAnchorPoint(cc.p(0, 1))
    self.node_rich:addChild(richText)
    -- 更换按钮
    if self.ownMap[id] and id ~= user.head then
        me.setButtonDisable(self.btn_change, true)
    else
        me.setButtonDisable(self.btn_change, false)
    end
end

function HeaderChangeView:onEnter()
    print("HeaderChangeView onEnter")
    me.doLayout(self, me.winSize)
end

function HeaderChangeView:onEnterTransitionDidFinish()
    print("HeaderChangeView onEnterTransitionDidFinish")
end

function HeaderChangeView:onExit()
    print("HeaderChangeView onExit")
    UserModel:removeLisener(self.lisener)
end
