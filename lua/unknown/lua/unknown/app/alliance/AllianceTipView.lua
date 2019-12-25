--[[
	文件名：AllianceTipView.lua
	描述：联盟好处提示页面
	创建人：libowen
	创建时间：2019.12.14
--]]

AllianceTipView = class("AllianceTipView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
AllianceTipView.__index = AllianceTipView

function AllianceTipView:create(...)
    local layer = AllianceTipView.new(...)
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
function AllianceTipView:ctor()
    print("AllianceTipView ctor")
end

-- 初始化
function AllianceTipView:init()
    print("AllianceTipView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 确定
    self.btn_ok = me.assignWidget(self.img_bg, "btn_ok")
    me.registGuiClickEvent(self.btn_ok, function(sender)
    	self:removeFromParent()
    end)

    return true
end

function AllianceTipView:onEnter()
    print("AllianceTipView onEnter")
    me.doLayout(self, me.winSize)
end

function AllianceTipView:onEnterTransitionDidFinish()
    print("AllianceTipView onEnterTransitionDidFinish")
end

function AllianceTipView:onExit()
    print("AllianceTipView onExit")
end
