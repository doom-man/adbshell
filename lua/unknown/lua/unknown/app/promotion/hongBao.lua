hongBao = class("hongBao",function(...)
    return cc.CSLoader:createNode(...)
end)
hongBao.__index = hongBao
function hongBao:create(...)
    local layer = hongBao.new(...)
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

function hongBao:ctor()
    print("hongBao:ctor()")
end
function hongBao:init()
    print("hongBao:init()")
    self.Text_time = me.assignWidget(self,"Text_time")
    me.registGuiClickEventByName(self,"Button_close",function (node)

end)
    return true
end
function hongBao:onEnter()  
    me.doLayout(self,me.winSize)
    --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_HONGBAO)] == 1 then
        -- ÒÆ³ýºìµã
        removeRedpoint(ACTIVITY_ID_HONGBAO)
    --end

    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
        self.Text_time:setString(me.GetSecTime(user.activityDetail.openDate) .. "-" .. me.GetSecTime(user.activityDetail.endDate))
    end
end

function hongBao:onExit()
    self.timer = nil
end
