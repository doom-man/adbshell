--[[
	文件名：PvpRuleView.lua
	描述：跨服争霸规则页面
	创建人：libowen
	创建时间：2019.10.14
--]]

PvpRuleView = class("PvpRuleView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpRuleView.__index = PvpRuleView

function PvpRuleView:create(...)
    local layer = PvpRuleView.new(...)
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
function PvpRuleView:ctor()
    print("PvpRuleView ctor")
end

-- 初始化
function PvpRuleView:init()
    print("PvpRuleView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 标题
    self.text_title = me.assignWidget(self.img_bg, "text_title")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 确定
    self.btn_ok = me.assignWidget(self.img_bg, "btn_ok")
    me.registGuiClickEvent(self.btn_ok, function(sender)
    	self:removeFromParent()
    end)
    -- 滑动窗体
    self.listView = me.assignWidget(self.img_bg, "listView")
    self.listView:setScrollBarEnabled(false)

    return true
end

-- 设置标题
function PvpRuleView:setTitle(str)
	self.text_title:setString(str)
end

-- 设置规则列表
function PvpRuleView:setRuleList(ruleList)
	self.listView:removeAllItems()
    local tempWidth = self.listView:getContentSize().width
	for i, str in ipairs(ruleList) do
		local richText = mRichText:create(str, tempWidth)
		self.listView:pushBackCustomItem(richText)
	end
end

function PvpRuleView:onEnter()
    print("PvpRuleView onEnter")
    me.doLayout(self, me.winSize)
end

function PvpRuleView:onEnterTransitionDidFinish()
    print("PvpRuleView onEnterTransitionDidFinish")
end

function PvpRuleView:onExit()
    print("PvpRuleView onExit")
end
