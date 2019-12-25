--[[
	文件名：PvpPlayerDetailView.lua
	描述：跨服争霸玩家详情页面
	创建人：libowen
	创建时间：2019.10.28
--]]

PvpPlayerDetailView = class("PvpPlayerDetailView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpPlayerDetailView.__index = PvpPlayerDetailView

function PvpPlayerDetailView:create(...)
    local layer = PvpPlayerDetailView.new(...)
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
function PvpPlayerDetailView:ctor()
    print("PvpPlayerDetailView ctor")
end

-- 初始化
function PvpPlayerDetailView:init()
    print("PvpPlayerDetailView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 形象
    self.img_image = me.assignWidget(self.img_bg, "img_image")
    -- 名字
    self.text_name = me.assignWidget(self.img_bg, "text_name")
    -- 战力
	self.text_fap = me.assignWidget(self.img_bg, "text_fap")
	-- 联盟
	self.text_guild = me.assignWidget(self.img_bg, "text_guild")
	-- 身价
	self.text_value = me.assignWidget(self.img_bg, "text_value")
	-- 赔率
	self.text_odds = me.assignWidget(self.img_bg, "text_odds")

    return true
end

function PvpPlayerDetailView:setData(data)
	self.info = data
	self:refreshView()
end

-- 刷新页面
function PvpPlayerDetailView:refreshView()
	self.img_image:loadTexture(cfg[CfgType.ROLE_IMAGE][self.info.image].icon..".png")
	self.text_name:setString(string.format("%s.%s", self.info.serverName, self.info.playerName))
	self.text_fap:setString(string.format("战力：%s", self.info.fightPower))
	self.text_guild:setString(string.format("联盟：%s", self.info.familyName))
	self.text_value:setString(string.format("身价：%s", self.info.value))
	self.text_odds:setString(string.format("奖金：%s", self.info.odds))
end

function PvpPlayerDetailView:onEnter()
    print("PvpPlayerDetailView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpPlayerDetailView:onEnterTransitionDidFinish()
    print("PvpPlayerDetailView onEnterTransitionDidFinish")
end

function PvpPlayerDetailView:onExit()
    print("PvpPlayerDetailView onExit")
    -- 移除缓存
    local TextureCache = cc.Director:getInstance():getTextureCache()
    for k, v in pairs(cfg[CfgType.ROLE_IMAGE]) do
    	local str = v.icon..".png"
    	TextureCache:removeTextureForKey(str)
    end
end
