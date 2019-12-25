mysticalShipCell = class("mysticalShipCell", function(...)
    return cc.CSLoader:createNode(...)
end )
mysticalShipCell.__index = mysticalShipCell
function mysticalShipCell:create(...)
    local layer = mysticalShipCell.new(...)
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

function mysticalShipCell:ctor()
    print("mysticalShipCell:ctor()")
end
function mysticalShipCell:init()
    print("mysticalShipCell:init()")
    me.registGuiClickEventByName(self, "btn", function()
        NetMan:send(_MSG.initShop(ELEVENSHOP))

    end)

    return true
end
function mysticalShipCell:onEnter()
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self, "Panel_richText")
        local rich = mRichText:create(activity.desc, Panel_richText:getContentSize().width)
        rich:setPosition(0, Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0, 1))
        Panel_richText:addChild(rich)
    end

    -- 活动倒计时
    local Text_countDown = me.assignWidget(self, "Text_countDown")

    if tonumber(user.activityDetail.open) == 1 then
        local leftT = user.activityDetail.countdown
        Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动结束")
            end
            Text_countDown:setString("活动结束倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
    else
        local leftT = user.activityDetail.countdown
        Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
        self.timer = me.registTimer(leftT, function()
            if me.toNum(leftT) <= 0 then
                me.clearTimer(self.timer)
                Text_countDown:setString("活动开启")
            end
            Text_countDown:setString("活动开启倒计时：" .. me.formartSecTime(leftT))
            leftT = leftT - 1
        end , 1)
    end

    me.assignWidget(self, "tipsTxt"):setString(user.activityDetail.notice)
    me.assignWidget(self, "txt1"):setString(user.activityDetail.comsume)
    me.assignWidget(self, "txt2"):setString(user.activityDetail.agio==1 and "无" or user.activityDetail.agio)
    me.doLayout(self, me.winSize)
end




function mysticalShipCell:onExit()
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
