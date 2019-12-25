--[[
	文件名：LordImageChangeView.lua
	描述：更换领主形象页面
	创建人：libowen
	创建时间：2019.9.23
--]]

LordImageChangeView = class("LordImageChangeView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
LordImageChangeView.__index = LordImageChangeView

local TextureCache = cc.Director:getInstance():getTextureCache()

function LordImageChangeView:create(...)
    local layer = LordImageChangeView.new(...)
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
function LordImageChangeView:ctor()
    print("LordImageChangeView ctor")
    -- 数据处理
    self:dealData()
    self.lisener = UserModel:registerLisener(function(msg)
        -- 获取头像列表
        if checkMsg(msg.t, MsgCode.GET_LORD_IMAGE_LIST) then
        	self.ownMap = {}
        	for i, v in ipairs(msg.c.list) do
        		self.ownMap[v.id] = true
        	end
	        -- 刷新形象列表
	        self:refreshPageView()
	  	-- 更换
	    elseif checkMsg(msg.t, MsgCode.CHANGE_LORD_IMAGE) then
	    	showTips("更换成功")
        end
    end)
    NetMan:send(_MSG.get_lord_image_list())
end

-- 数据处理
function LordImageChangeView:dealData()
	self.cfg_image = clone(cfg[CfgType.ROLE_IMAGE])
	self.keys = table.keys(self.cfg_image)
	table.sort(self.keys, function(a, b)
		return a < b
	end)
end

-- 初始化
function LordImageChangeView:init()
    print("LordImageChangeView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 滑动窗体
    self.pageView_image = me.assignWidget(self.img_bg, "pageView_image")
    self.pageView_image:setDirection(ccui.PageViewDirection.HORIZONTAL)
    self.pageView_image:setClippingEnabled(true)
    self.pageView_image:addEventListener(function(sender, eventType)
    	if ccui.PageViewEventType.turning == eventType then
    		self.selIndex = sender:getCurPageIndex() + 1
    		self:showImageDetail()
    	end
    end)
    -- 左右箭头
    self.btn_left = me.assignWidget(self.img_bg, "btn_left")
    self.btn_left:setVisible(false)
    me.registGuiClickEvent(self.btn_left, function()
    	if self.selIndex > 1 then
    		self.selIndex = self.selIndex - 1
    		self.pageView_image:setCurPageIndex(self.selIndex - 1)
    		self:showImageDetail()
    	end
	end)
    self.btn_right = me.assignWidget(self.img_bg, "btn_right")
    self.btn_right:setVisible(false)
    me.registGuiClickEvent(self.btn_right, function()
    	if self.selIndex < #self.keys then
    		self.selIndex = self.selIndex + 1
    		self.pageView_image:setCurPageIndex(self.selIndex - 1)
    		self:showImageDetail()
    	end
	end)
    -- 更换按钮
    self.btn_change = me.assignWidget(self.img_bg, "btn_change")
    self.btn_change:setVisible(false)
    me.registGuiClickEvent(self.btn_change, function()
    	local tempId = self.keys[self.selIndex]
    	NetMan:send(_MSG.change_lord_head(tempId))
    	self.btn_change:setVisible(false)
	end)
    -- 解锁条件
    self.img_condition = me.assignWidget(self.img_bg, "img_condition")
    self.img_condition:setVisible(false)
    self.node_rich = me.assignWidget(self.img_condition, "node_rich")

    return true
end

-- 刷新列表
function LordImageChangeView:refreshPageView()
	self.pageView_image:removeAllPages()
	local pageSize = self.pageView_image:getContentSize()
	for i, key in ipairs(self.keys) do
		local layout = ccui.Layout:create()
		layout:setContentSize(pageSize)
		self.pageView_image:addPage(layout)
		-- 形象
		local str = self.cfg_image[key].icon..".png"
		TextureCache:addImageAsync(str, function()
			local img_image = ccui.ImageView:create(str, me.localType)
			img_image:setPosition(cc.p(pageSize.width / 2, pageSize.height / 2 - 10))
			layout:addChild(img_image)
            img_image:setScale(0.85)
            if not self.ownMap[key] then
                me.Helper:grayImageView(img_image)
            end
		end)
	end
	-- 默认选中
	self.selIndex = 1
	for i, key in ipairs(self.keys) do
		if key == user.image then
			self.selIndex = i
			break
		end
	end
	self.pageView_image:setCurPageIndex(self.selIndex - 1)
	self:showImageDetail()
end

-- 展示形象
function LordImageChangeView:showImageDetail()
	self.btn_left:setVisible(self.selIndex > 1)
	self.btn_right:setVisible(self.selIndex < #self.keys)
	-- 是否是当前形象
	local tempId = self.keys[self.selIndex]
	if tempId == user.image then
		self.btn_change:setVisible(false)
		self.img_condition:setVisible(false)
	else
		-- 是否解锁
		if not self.ownMap[tempId] then
			self.btn_change:setVisible(false)
			self.img_condition:setVisible(true)
			self.node_rich:removeAllChildren()
			local richText = mRichText:create(self.cfg_image[tempId].desc)
			richText:setAnchorPoint(cc.p(0.5, 0.5))
			self.node_rich:addChild(richText)
		else
			self.btn_change:setVisible(true)
			self.img_condition:setVisible(false)
		end
	end
end

function LordImageChangeView:onEnter()
    print("LordImageChangeView onEnter")
    me.doLayout(self, me.winSize)
end

function LordImageChangeView:onEnterTransitionDidFinish()
    print("LordImageChangeView onEnterTransitionDidFinish")
end

function LordImageChangeView:onExit()
    print("LordImageChangeView onExit")
    UserModel:removeLisener(self.lisener)
    -- 移除缓存
    for i, key in ipairs(self.keys) do
    	local str = self.cfg_image[key].icon..".png"
    	TextureCache:removeTextureForKey(str)
    end
end
