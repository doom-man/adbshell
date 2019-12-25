timeLimitSubcell = class("timeLimitSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
timeLimitSubcell.__index = timeLimitSubcell

function timeLimitSubcell:create(...)
    local layer = timeLimitSubcell.new(...)
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

function timeLimitSubcell:ctor()
    print("timeLimitSubcell:ctor()")
end
function timeLimitSubcell:init()
    print("timeLimitSubcell:init()")
    self.timers = {}
    return true
end
function timeLimitSubcell:onEnter()  
    me.assignWidget(self, "Button_item"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end
    self:panelItems()

    local time = user.activityDetail.countDown-(me.sysTime()-user.activityDetail.startTime)/1000
    me.assignWidget(self,"Text_time"):setString(me.formartSecTime(time).."后开启")
    self.timer = me.registTimer(-1,function ()
        time = time-1
        if time <= 0 then
            time = 0
            me.clearTimer(self.timer)
        end
        local t = me.formartSecTime(time)
        me.assignWidget(self,"Text_time"):setString(t.."后开启")
    end,1)

    me.registGuiClickEventByName(self,"Button_check",function (node)
        NetMan:send(_MSG.rankList(rankView.PROMITION_HISTORY ))
    end) 
    me.doLayout(self,me.winSize)
end

function timeLimitSubcell:panelItems()
    self.listData = user.activityDetail.rewards
    local w = 100
    local Panel_items = me.assignWidget(self,"Panel_items")
    local totalW = Panel_items:getContentSize().width
    if totalW < #self.listData * w then
        totalW = #self.listData * w
    end
    for key, var in pairs(self.listData) do
        local cell = me.assignWidget(self, "Button_item"):clone()
        cell:setVisible(true)
        local index = me.toNum(key) -1
        cell:setAnchorPoint(cc.p(0, 0))
        cell:setPosition(cc.p(w * index+40, 80))
        Panel_items:addChild(cell)

        local cfg = cfg[CfgType.ETC][var[1]]
        me.assignWidget(cell, "Goods_Icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
        me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(cfg.quality),me.localType)
        me.registGuiClickEventByName(cell, "Button_item", function(node)        
            showPromotion(var[1],var[2])
        end )
    end
    Panel_items:setInnerContainerSize(cc.size(totalW, 140))
end

function timeLimitSubcell:onExit()
    me.clearTimer(self.timer)
end
