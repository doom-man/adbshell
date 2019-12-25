freshMeatSubcell = class("freshMeatSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
freshMeatSubcell.__index = freshMeatSubcell
-- 积分兑换
function freshMeatSubcell:create(...)
    local layer = freshMeatSubcell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end

function freshMeatSubcell:ctor()
    print("freshMeatSubcell:ctor()")
end

function freshMeatSubcell:init()
    print("freshMeatSubcell:init()")
    self.lunch = me.assignWidget(self,"lunch")
    self.supper = me.assignWidget(self,"supper")
    self.strengthNum = me.assignWidget(self,"strengthNum")
    self.Button_eat = me.assignWidget(self,"Button_eat")
    me.registGuiClickEventByName(self,"Button_eat",function ()
        NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))

        --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_FRESHMEAT)]==1 then --移除红点
            removeRedpoint(ACTIVITY_ID_FRESHMEAT)
        --end
    end)
    return true
end
function freshMeatSubcell:onEnter()
    print("freshMeatSubcell:onEnter()")
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_FINISH_REWARD then
                self.Button_eat:setEnabled(false)
            end
        end
    end)
    self:updateData()
    me.doLayout(self,me.winSize)  
end
function freshMeatSubcell:updateData()
--    dump(user.activityDetail)
    local lData = user.activityDetail.dlist[1]
    local sData = user.activityDetail.dlist[2]
    self.lunch:setString("午餐"..lData.beginDate.." - "..lData.endDate)
    self.supper:setString("晚餐"..sData.beginDate.." - "..sData.endDate)
    self.strengthNum:setString("x"..user.activityDetail.power)
    self.Button_eat:setEnabled(user.activityDetail.open ~= 0)
end
function freshMeatSubcell:onExit()
    print("freshMeatSubcell:onExit()")
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
