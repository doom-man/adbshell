firstBuySubcell = class("firstBuySubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
firstBuySubcell.__index = firstBuySubcell
function firstBuySubcell:create(...)
    local layer = firstBuySubcell.new(...)
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

function firstBuySubcell:ctor()
    print("firstBuySubcell:ctor()")
end
function firstBuySubcell:init()
    print("firstBuySubcell:init()")
    return true
end
function firstBuySubcell:onEnter()
    me.doLayout(self,me.winSize)  
    local function setBtnStatus()
        me.assignWidget(self,"Button_buy"):setEnabled(user.activityDetail.status==ACTIVITY_STATUS_1 or user.activityDetail.status==ACTIVITY_STATUS_3)
        if user.activityDetail.status==ACTIVITY_STATUS_1 then
            me.assignWidget(self,"Button_buy"):setVisible(false)
            me.assignWidget(self,"Button_lingqu"):setVisible(true)
            me.assignWidget(self,"Button_yilingqu"):setVisible(false)
        elseif user.activityDetail.status==ACTIVITY_STATUS_3 then
            me.assignWidget(self,"Button_buy"):setVisible(true)
            me.assignWidget(self,"Button_lingqu"):setVisible(false)
            me.assignWidget(self,"Button_yilingqu"):setVisible(false)
        else 
            me.assignWidget(self,"Button_buy"):setVisible(false)
            me.assignWidget(self,"Button_lingqu"):setVisible(false)
            me.assignWidget(self,"Button_yilingqu"):setVisible(true)
        end
    end
    local Panel_item = me.assignWidget(self, "Panel_item")
    local index = 1
    for key, var in pairs(user.activityDetail.items) do
        local cell = me.assignWidget(self, "Button_item"):clone()
        cell:setVisible(true)
        cell:setPosition(cc.p(105*me.toNum(key-1)+75,55))
        cell:setTag(key)
        local cfg = cfg[CfgType.ETC][ tonumber(var[1])]
        if cfg ~= nil then
            me.assignWidget(cell, "label_num"):setString(var[2])
            me.assignWidget(cell, "Goods_Icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
            me.assignWidget(cell, "Image_quality"):loadTexture(getQuality(cfg.quality),me.localType)
            me.registGuiClickEventByName(cell, "Button_item", function(node)        
                local pTag = me.toNum(node:getTag())
                local pData = user.activityDetail.items[pTag]                          
                local defId =pData[1]
                local pNum = pData[2]
                showPromotion(defId,pNum)
            end )
            Panel_item:addChild(cell)
        end
        
        if index >= 4 then --只显示4个
            break
        end
        index = index +1
    end

    setBtnStatus()
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_FIRST then --首充
                setBtnStatus()
            end
        elseif checkMsg(msg.t, MsgCode.ACTIVITY_FINISH_REWARD) then --奖励领取
            if msg.c.activityId ~= ACTIVITY_ID_FIRST then
                return
            end
        end
    end)

    me.registGuiClickEventByName(self, "Button_buy", function(node)
        if user.activityDetail.status==ACTIVITY_STATUS_1 then
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
        elseif user.activityDetail.status==ACTIVITY_STATUS_3 then
            me.dispatchCustomEvent("promotionViewclose")
            TaskHelper.jumToPay()
        end
    end )
    me.registGuiClickEventByName(self, "Button_lingqu", function(node)
        if user.activityDetail.status==ACTIVITY_STATUS_1 then
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId))
        elseif user.activityDetail.status==ACTIVITY_STATUS_3 then
            if mainCity.promotionView then
                mainCity.promotionView:close()
            end
            TaskHelper.jumToPay()
        end
    end )
end

function firstBuySubcell:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
