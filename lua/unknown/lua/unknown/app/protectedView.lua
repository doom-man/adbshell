-- 坚守 界面
ProtectedView = class("ProtectedView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
ProtectedView.__index = ProtectedView
function ProtectedView:create(...)
    local layer = ProtectedView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:enterTransitionFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function ProtectedView:ctor()
    print("ProtectedView ctor")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
end

function ProtectedView:close()
    self:removeFromParentAndCleanup(true)
end


function ProtectedView:revMsg(msg)
    local checkMsgTable = { MsgCode.ROLE_PROTECTED, MsgCode.ROLE_CANCEL_PROTECTED, MsgCode.ROLE_CLEAN_PROTECTED_COUNTDONW, MsgCode.ROLE_PROTECTED_INFO }
    for key, var in pairs(checkMsgTable) do
        if checkMsg(msg.t, var) then
            self:initText()
            self:update()
        end
    end
end

local ONE_HOUR = 60 * 60
local PROTECTED_COUNT_TIME = 9 * ONE_HOUR
local COOLING_COUNT_TIME = 7 * ONE_HOUR
function ProtectedView:init()

    self.loadingBar_Protected = me.assignWidget(self, "bar_lv")
    self.loadingBar_Countdonw = me.assignWidget(self, "bar_hong")
    self.btn_Protected = me.registGuiClickEventByName(self, "Button_study", function()
        if self.Text_Protected.state == self.ProtectedBtnState.normal then
            NetMan:send(_MSG.RoleProtected())
        elseif self.Text_Protected.state == self.ProtectedBtnState.cancel then
            if self.protectedTime > PROTECTED_COUNT_TIME - ONE_HOUR then
                me.showMessageDialog("取消后会进入冷却时间，是否取消？", function(args)
                    if args == "ok" then
                        -- me.Helper:endGame()
                        NetMan:send(_MSG.RoleCancelProtected())
                    end
                end )
            else
                showTips("开启坚守超过1小时不能取消坚守")
            end
        end
    end )

    self.ProtectedBtnState = { normal = 1, cancel = 2, other = 3 }

    self.btn_Clear = me.registGuiClickEventByName(self, "Button_study_0", function()

        NetMan:send(_MSG.RoleCleanProtectedCountdonw())

    end )
    self.Text_Protected = me.assignWidget(self, "Text_1")
    self.Text_Countdonw = me.assignWidget(self, "Text_1_0")
    self:initText()
    self:update()
    return true
end

--[[

PROTECTED_TYPE_COUNT_TIME = -2;-- 免战冷却中
PROTECTED_TYPE_NONE = -1;-- 未保护
PROTECTED_TYPE_NEWPLAYER = 0;-- 新手保护
PROTECTED_TYPE_CAPTIVE = 1;-- 沦陷免战
PROTECTED_TYPE_MINE = 2;-- 主动免战
]]


function ProtectedView:initText()
    self.Text_Protected:setString("坚守9小时")
    self.Text_Countdonw:setString("冷却7小时")
    self.loadingBar_Protected:setPercent(100)
    self.loadingBar_Countdonw:setPercent(100)
    self.btn_Protected:setVisible(true)
    self.Text_Protected.state = self.ProtectedBtnState.normal
    me.assignWidget(self.btn_Protected, "title"):setString("开始坚守")
    self.btn_Clear:setVisible(false)
    me.assignWidget(self.btn_Clear, "title"):setString("清除冷却")
end

function ProtectedView:update()
    print("ProtectedView:update")
    self.protectedType = user.protectedType
    self.protectedTime = user.protectedTime

    if self.protectedType == PROTECTED_TYPE_COUNT_TIME then
        if self.protectedTime > 0 then
            self:clearTimer()
            local t = 1
            self.timer = me.registTimer(-1, function(dt)
                local restTime = self.protectedTime - t
                if restTime > 0 then
                    self.Text_Countdonw:setString("冷却中" .. "    " .. me.formartSecTime(restTime))
                    self.loadingBar_Countdonw:setPercent((PROTECTED_COUNT_TIME - restTime * 100) / PROTECTED_COUNT_TIME)
                else
                    self:clearTimer()
                    NetMan:send(_MSG.RoleProtectedInfo())
                end
                t = t + 1
            end , 1)
            self.Text_Protected:setString("未开启坚守")
            self.loadingBar_Countdonw:setPercent(0)
            self.btn_Protected:setVisible(false)
            me.assignWidget(self.btn_Protected, "icon_diamond_0"):setVisible(true)
            self.btn_Clear:setVisible(true)
        end
    elseif self.protectedType == PROTECTED_TYPE_NONE then

    elseif self.protectedType == PROTECTED_TYPE_CAPTIVE then

    elseif self.protectedType == PROTECTED_TYPE_NEWPLAYER then

    elseif self.protectedType == PROTECTED_TYPE_MINE then
        if self.protectedTime > 0 then
            self:clearTimer()
            local t = 1
            self.timer = me.registTimer(-1, function(dt)
                local restTime = self.protectedTime - t
                if restTime > 0 then
                    self.Text_Protected:setString("坚守中" .. "    " .. me.formartSecTime(restTime))
                    self.loadingBar_Protected:setPercent((COOLING_COUNT_TIME - restTime * 100) / COOLING_COUNT_TIME)
                else
                    self:clearTimer()
                    NetMan:send(_MSG.RoleProtectedInfo())
                end
                t = t + 1
            end , 1)
            self.loadingBar_Protected:setPercent(0)
            self.loadingBar_Countdonw:setPercent(0)
            self.Text_Protected.state = self.ProtectedBtnState.cancel
            self.btn_Protected:setVisible(true)
            me.assignWidget(self.btn_Protected, "title"):setString("取消坚守")
            me.assignWidget(self.btn_Protected, "icon_diamond_0"):setVisible(false)
            self.btn_Clear:setVisible(false)
        end
     end
end

function ProtectedView:onEnter()
    print("ProtectedView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        self:revMsg(msg)
    end )
end
function ProtectedView:enterTransitionFinish()

end

function ProtectedView:clearTimer()
    if self.timer then
        me.clearTimer(self.timer)
        self.timer = nil
    end
end

function ProtectedView:onExit()
    UserModel:removeLisener(self.modelkey)
    self:clearTimer()
end