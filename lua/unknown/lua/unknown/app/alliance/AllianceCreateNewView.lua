--[[
	文件名：AllianceCreateNewView.lua
	描述：创建联盟页面(新)
	创建人：libowen
	创建时间：2019.12.13
--]]

AllianceCreateNewView = class("AllianceCreateNewView", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
AllianceCreateNewView.__index = AllianceCreateNewView

function AllianceCreateNewView:create(...)
    local layer = AllianceCreateNewView.new(...)
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
function AllianceCreateNewView:ctor()
    print("AllianceCreateNewView ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ALLIANCE_CD) then
        	self:checkCountdown(msg)
        end
    end)
    -- 获取退盟后的CD
    NetMan:send(_MSG.getAllianceCd())
end

-- 初始化
function AllianceCreateNewView:init()
    print("AllianceCreateNewView init")
   	-- 底板
    self.fixLayout = me.assignWidget(self, "fixLayout")
    self.img_bg = me.assignWidget(self.fixLayout, "img_bg")
    -- 关闭
    self.btn_close = me.assignWidget(self.img_bg, "btn_close")
    me.registGuiClickEvent(self.btn_close, function(sender)
    	self:removeFromParent()
    end)
    -- 名字输入框
    self.img_edit_box_name = me.assignWidget(self.img_bg, "img_edit_box_name")
    local function callback(strEventName, pSender)
        if strEventName == "changed" then
        	--
        end
    end
    local edit_box_name = me.addInputBox(480, 30, 20, nil, callback, cc.EDITBOX_INPUT_MODE_ANY, "请输入英文，数字")
    edit_box_name:setMaxLength(12)
    edit_box_name:setAnchorPoint(0.5, 0.5)
    edit_box_name:setPosition(cc.p(263.5, 24))
    edit_box_name:setPlaceholderFontColor(cc.c3b(0x5a, 0x5a, 0x5a))
    edit_box_name:setFontColor(cc.c3b(0xff, 0xff, 0xff))
    self.img_edit_box_name:addChild(edit_box_name)
    self.edit_box_name = edit_box_name
    -- 简介输入框
    local text_field_introduce = me.assignWidget(self.img_bg, "text_field_introduce")
    text_field_introduce:setMaxLength(160)
    text_field_introduce:setMaxLengthEnabled( true)
    text_field_introduce:ignoreContentAdaptWithSize(false)
    text_field_introduce:setContentSize(cc.size(732, 133))
    text_field_introduce:setPlaceHolderColor(cc.c3b(0x5a, 0x5a, 0x5a))
    text_field_introduce:setTextColor(cc.c3b(0xff, 0xff, 0xff))
    self.text_field_introduce = text_field_introduce
    -- 创建花费
    self.text_cost = me.assignWidget(self.img_bg, "text_cost")
    self.text_cost:setString(100)
    -- 创建CD
    self.text_create_cd = me.assignWidget(self.img_bg, "text_create_cd")
    self.text_create_cd:setVisible(false)
    -- 创建按钮
    self.btn_create = me.assignWidget(self.img_bg, "btn_create")
    me.registGuiClickEvent(self.btn_create, function(node)
        if self.edit_box_name:getText() ~= nil then
            NetMan:send(_MSG.createFamily(self.edit_box_name:getText(), self.text_field_introduce:getString()))
        else
            showTips("联盟名称不能为空")
        end
    end)

    return true
end

-- 检测是否有倒计时
function AllianceCreateNewView:checkCountdown(msg)
    if msg and msg.c and msg.c.time then
    	local leftTime = msg.c.time
        if leftTime > 0 then
            self.text_create_cd:setString(me.formartSecTime(leftTime))
            self.text_create_cd:setVisible(true)
            self.timer = me.registTimer(-1, function(dt)
                leftTime = leftTime - 1
                if leftTime >= 0 then
                    self.text_create_cd:setString(me.formartSecTime(leftTime))
                else
                    me.clearTimer(self.timer)
                    self.timer = nil
                    self.text_create_cd:setVisible(false)
                end
            end, 1)
        end
    end
end

function AllianceCreateNewView:onEnter()
    print("AllianceCreateNewView onEnter")
    me.doLayout(self, me.winSize)
end

function AllianceCreateNewView:onEnterTransitionDidFinish()
    print("AllianceCreateNewView onEnterTransitionDidFinish")
end

function AllianceCreateNewView:onExit()
    print("AllianceCreateNewView onExit")
    UserModel:removeLisener(self.lisener)
    -- 删除消息通知
    me.clearTimer(self.timer)
end
