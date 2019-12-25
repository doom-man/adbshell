--[[
	文件名：PvpHeroDetailView.lua
	描述：跨服争霸考古英雄详情页面
	创建人：libowen
	创建时间：2019.10.22
--]]

PvpHeroDetailView = class("PvpHeroDetailView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpHeroDetailView.__index = PvpHeroDetailView

function PvpHeroDetailView:create(...)
    local layer = PvpHeroDetailView.new(...)
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
function PvpHeroDetailView:ctor()
    print("PvpHeroDetailView ctor")
end

-- 初始化
function PvpHeroDetailView:init()
    print("PvpHeroDetailView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.img_top = me.assignWidget(self.img_bg, "img_top")
    self.btn_close = me.assignWidget(self.img_top, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
        self:removeFromParent()
    end)
    -- 头像
    self.img_center = me.assignWidget(self.img_bg, "img_center")
    self.img_header = me.assignWidget(self.img_center, "img_header")
    self.panel_star = me.assignWidget(self.img_center, "panel_star")
    -- 名字
    self.text_name = me.assignWidget(self.img_center, "text_name")
    -- 简介
    self.text_desc = me.assignWidget(self.img_center, "text_desc")
    -- 卸下
    self.btn_unload = me.assignWidget(self.img_center, "btn_unload")
    me.registGuiClickEvent(self.btn_unload, function(sender)
        if self.unloadCb then
        	self.unloadCb()
        end
        self:removeFromParent()
    end)
    -- 替换
    self.btn_replace = me.assignWidget(self.img_center, "btn_replace")
    me.registGuiClickEvent(self.btn_replace, function(sender)
        if self.replaceCb then
        	self.replaceCb()
        end
        self:removeFromParent()
    end)
    -- 确定
    self.btn_ok = me.assignWidget(self.img_center, "btn_ok")
    me.registGuiClickEvent(self.btn_ok, function(sender)
        self:removeFromParent()
    end)
    
    return true
end

-- 刷新页面
--[[
    info                -- 考古英雄信息
    onlyLook            -- 仅仅是查看详情
--]]
function PvpHeroDetailView:refreshView(info, onlyLook)
	local cfgItem = cfg[CfgType.ETC][me.toNum(info.defid)]
	self.img_header:loadTexture(getItemIcon(cfgItem.id))
	self.img_header:setVisible(true)
	self.text_name:setString(cfgItem.name)
    -- 星级
    local starLv = info.level
    self.panel_star:removeAllChildren()
    local starWidth = 15
    local startX = self.panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
    for i = 1, starLv do
        local img_star = ccui.ImageView:create()
        img_star:loadTexture("rune_star.png", me.localType)
        local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
        local y = 25
        img_star:setPosition(cc.p(x, y))
        img_star:setScale(0.5)
        self.panel_star:addChild(img_star)
    end
    local tempList = string.split(cfgItem.describe, "|")
    if tempList[info.level + 1] then
	   self.text_desc:setString(tempList[info.level + 1])
    end
    -- 不在报名阶段
    if not PvpMainView.inSignUp then
        self.btn_unload:setEnabled(false)
        self.btn_replace:setEnabled(false)
    end
    if not onlyLook then
        self.btn_unload:setVisible(true)
        self.btn_replace:setVisible(true)
        self.btn_ok:setVisible(false)
    else
        self.btn_unload:setVisible(false)
        self.btn_replace:setVisible(false)
        self.btn_ok:setVisible(true)
    end
end

-- 卸下回调
function PvpHeroDetailView:setUnloadCallback(cb)
	self.unloadCb = cb
end

-- 替换回调
function PvpHeroDetailView:setReplaceCallback(cb)
	self.replaceCb = cb
end

function PvpHeroDetailView:onEnter()
    print("PvpHeroDetailView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpHeroDetailView:onEnterTransitionDidFinish()
    print("PvpHeroDetailView onEnterTransitionDidFinish")
end

function PvpHeroDetailView:onExit()
    print("PvpHeroDetailView onExit")
end
