--[[
	文件名：PvpSignUpNode.lua
	描述：跨服争霸报名节点
	创建人：libowen
	创建时间：2019.10.19
--]]

PvpSignUpNode = class("PvpSignUpNode", function(...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
PvpSignUpNode.__index = PvpSignUpNode

function PvpSignUpNode:create(...)
    local layer = PvpSignUpNode.new(...)
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
function PvpSignUpNode:ctor()
    print("PvpSignUpNode ctor")
    -- 消息监听
    self.lisener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.PVP_SIGN_UP) then
        	-- 是报名还是取消报名
        	local isSignUp = false
        	for i, v in ipairs(msg.c.list) do
        		if v.inReg then
        			isSignUp = true
        			break
        		end
        	end
        	if isSignUp then
        		showTips("报名成功")
        	else
        		showTips("报名取消")
        	end
            self.info = msg.c.list
			self:refreshView()
        end
    end)
end

-- 初始化
function PvpSignUpNode:init()
    print("PvpSignUpNode init")
    -- 天阶
    self.img_tianjie = me.assignWidget(self, "img_tianjie")
    -- 人阶
    self.img_renjie = me.assignWidget(self, "img_renjie")
	-- 地阶
    self.img_dijie = me.assignWidget(self, "img_dijie")

    return true
end

-- 设置节点数据
function PvpSignUpNode:setData(data)
	self.info = data
	-- 刷新内容
	self:refreshView()
end

-- 刷新内容
function PvpSignUpNode:refreshView()
	for i, v in ipairs({self.img_tianjie, self.img_renjie, self.img_dijie}) do
		local info = self.info[i] 
		-- 主城等级
		local text_centerLv = me.assignWidget(v, "text_centerLv")
		if info.maxLv > 0 then
			text_centerLv:setString(string.format("%s级~%s级", info.level, info.maxLv))
		else
			text_centerLv:setString(string.format(">=%s级", info.level))
		end
		-- 人数
		local text_person_num = me.assignWidget(v, "text_person_num")
		text_person_num:setString(info.size)
		-- 战力
		local text_fap = me.assignWidget(v, "text_fap")
		text_fap:setString(info.fightPower)
		-- 报名
		local btn_sign = me.assignWidget(v, "btn_sign")
		if info.levelAchieve == 1 then
			btn_sign:setTitleText(info.inReg and "取消报名" or "报名")
			btn_sign:setEnabled(true)
		else
			btn_sign:setTitleText("报名")
			btn_sign:setEnabled(false)
		end
		me.registGuiClickEvent(btn_sign, function()
            if not info.inReg then
                local box = MessageBox:create("MessageBox.csb")
                box:setText("确认以当前的阵容与属性报名参与跨服争霸吗？")
                box:register(function(name)
                    if name == "ok" then
                        NetMan:send(_MSG.sign_up_pvp(info.id))
                    end
                end)
                me.runningScene():addChild(box, me.MAXZORDER)
            else
                NetMan:send(_MSG.sign_up_pvp(0))
            end
		end)
		local text_sign = me.assignWidget(v, "text_sign")
		text_sign:setVisible(info.inReg)
	end
end

function PvpSignUpNode:onEnter()
    print("PvpSignUpNode onEnter")
end

function PvpSignUpNode:onEnterTransitionDidFinish()
    print("PvpSignUpNode onEnterTransitionDidFinish")
end

function PvpSignUpNode:onExit()
    print("PvpSignUpNode onExit")
    UserModel:removeLisener(self.lisener)
end
