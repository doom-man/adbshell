--[[
	文件名：WarShipShowView.lua
	描述：战舰预览页面
	创建人：libowen
	创建时间：2019.12.5
--]]

WarShipShowView = class("WarShipShowView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
WarShipShowView.__index = WarShipShowView

function WarShipShowView:create(...)
    local layer = WarShipShowView.new(...)
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
function WarShipShowView:ctor()
    print("WarShipShowView ctor")
end

-- 初始化
function WarShipShowView:init()
    print("WarShipShowView init")
    self.img_bg = me.assignWidget(self, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 战舰节点
    self.layout_ship = me.assignWidget(self.img_bg, "layout_ship")
    -- 名字
    self.text_name = me.assignWidget(self.img_bg, "text_name")
    -- 攻击
    self.text_att_val = me.assignWidget(self.img_bg, "text_att_val")
    -- 防御
    self.text_def_val = me.assignWidget(self.img_bg, "text_def_val")
    -- 性能
    self.text_cap_val = me.assignWidget(self.img_bg, "text_cap_val")
    -- 速度
    self.text_speed_val = me.assignWidget(self.img_bg, "text_speed_val")

    return true
end

-- 设置数据
--[[
	cfgInfo 			-- 战舰配置信息
--]]
function WarShipShowView:setData(cfgInfo)
	self.cfgInfo = cfgInfo
	-- 名字
	self.text_name:setString(self.cfgInfo.name)
	-- 动画展示
	self.layout_ship:removeAllChildren()
	local sk = sp.SkeletonAnimation:create("animation/anim_zhanjian_0" .. self.cfgInfo.type .. ".json", "animation/anim_zhanjian_0" .. self.cfgInfo.type .. ".atlas", 1)
    sk:setPosition(cc.p(380, 90))
    sk:setScale(1.0)
    self.layout_ship:addChild(sk)
    sk:setAnimation(0, "animation1", true)
    -- 属性
	self.text_att_val:setString(self.cfgInfo.atk)
    self.text_def_val:setString(self.cfgInfo.def)
    self.text_cap_val:setString(self.cfgInfo.hp)
    self.text_speed_val:setString(self.cfgInfo.atkRange)
end

function WarShipShowView:onEnter()
    print("WarShipShowView onEnter")
    me.doLayout(self, me.winSize)
end

function WarShipShowView:onEnterTransitionDidFinish()
    print("WarShipShowView onEnterTransitionDidFinish")
end

function WarShipShowView:onExit()
    print("WarShipShowView onExit")
end
