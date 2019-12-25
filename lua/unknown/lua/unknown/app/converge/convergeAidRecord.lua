-- [Comment]
-- jnmo
convergeAidRecord = class("convergeAidRecord", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
convergeAidRecord.__index = convergeAidRecord
function convergeAidRecord:create(...)
    local layer = convergeAidRecord.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
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
function convergeAidRecord:ctor()
    print("convergeAidRecord ctor")
    self.pTime = nil
end
function convergeAidRecord:init()
    print("convergeAidRecord init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self:setScorollView(user.ConvergeAid)
    return true
end
function convergeAidRecord:setScorollView(pData)
    if pData then
        dump(pData)
        local pIn = 0
        local pArmyNum = 0
        if pData.shipId ~= 0 then
           pIn = pIn + 1
        end
        for key, var in pairs(pData.army) do
            pIn = pIn + 1
            pArmyNum = pArmyNum + var[2]
        end
        local pName = me.assignWidget(self, "aid_name")
        pName:setString(pData.name)
        local pArmyNumlabel = me.assignWidget(self, "army_num")
        pArmyNumlabel:setString("士兵数量: " .. pArmyNum)
        local pTimeLabel = me.assignWidget(self, "aid_time")
        self.time = pData.counttime
        if self.time > 0 then
            pTimeLabel:setString("集结中" .. me.GetSecTime(pData.time))
            self.pTime = me.registTimer(-1, function(dt)
                if self.time < 0 then
                    me.clearTimer(self.pTime)
                    pTimeLabel:setString("已集结")
                else
                    self.time = self.time - 1
                    pTimeLabel:setString("集结中" .. me.formartSecTime(self.time))
                end
            end , 1)
        else
           pTimeLabel:setString("已集结")
        end
        me.registGuiClickEventByName(self, "Button_aid", function(node)
            GMan():send(_MSG.callbackArmy(pData["armyId"]))
            self:close()
        end )

        local pWidth = 1090
        local pHeight = math.ceil(pIn / 2) * 75
        local pScrollView = cc.ScrollView:create()
        pScrollView:setViewSize(cc.size(pWidth, 335))
        pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        pScrollView:setLocalZOrder(10)
        pScrollView:setAnchorPoint(cc.p(0, 0))
        pScrollView:setPosition(cc.p(0, 0))
        pScrollView:setContentSize(cc.size(pWidth, pHeight))
        pScrollView:setContentOffset(cc.p(0,(-(pHeight - 335))))
        me.assignWidget(self, "Node_tab"):addChild(pScrollView)

        local pNum = 0
        if pData.shipId ~= 0 then
            pNum = pNum + 1
            local pLine = math.floor((pNum - 1) / 2)
            local plist =(pNum - 1) % 2
            print("yy" .. pLine)
            local pConfig = cfg[CfgType.SHIP_DATA][pData.shipId]
             
            local pConverAid = me.assignWidget(self, "m_s_i_cell"):clone():setVisible(true)
            pConverAid:setAnchorPoint(cc.p(0, 0))
            local pConName = me.assignWidget(pConverAid, "m_s_i_name")
            pConName:setString(pConfig.name)
            me.assignWidget(pConverAid, "m_s_i_num"):setVisible(false)
           
            me.assignWidget(pConverAid, "m_s_i_icon"):setVisible(false)

            local pIcon = me.assignWidget(pConverAid, "warship_icon"):setVisible(true)
            pIcon:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png")

            pConverAid:setPosition(cc.p((plist) * 418, pHeight -(pLine + 1) * 77))
            pScrollView:addChild(pConverAid)

        end

        for key, var in pairs(pData.army) do
            pNum = pNum + 1
            local pLine = math.floor((pNum - 1) / 2)
            local plist =(pNum - 1) % 2
            print("yy" .. pLine)
            local pConfig = cfg[CfgType.CFG_SOLDIER][var[1]]
             
            local pConverAid = me.assignWidget(self, "m_s_i_cell"):clone():setVisible(true)
            pConverAid:setAnchorPoint(cc.p(0, 0))
            local pConName = me.assignWidget(pConverAid, "m_s_i_name")
            pConName:setString(pConfig.name)
            local pConNum = me.assignWidget(pConverAid, "m_s_i_num")
            pConNum:setString(var[2])
            me.assignWidget(pConverAid, "warship_icon"):setVisible(false)
            local pIcon = me.assignWidget(pConverAid, "m_s_i_icon"):setVisible(true)
            pIcon:loadTexture(soldierIcon(pConfig), me.plistType)
            pConverAid:setPosition(cc.p((plist) * 418, pHeight -(pLine + 1) * 77))
            pScrollView:addChild(pConverAid)
        end
    end
end
function convergeAidRecord:onEnter()
    print("convergeAidRecord onEnter")
    me.doLayout(self, me.winSize)
end
function convergeAidRecord:onEnterTransitionDidFinish()
    print("convergeAidRecord onEnterTransitionDidFinish")
end
function convergeAidRecord:onExit()
    print("convergeAidRecord onExit")
    me.clearTimer(self.pTime)
end
function convergeAidRecord:close()
    self:removeFromParentAndCleanup(true)
end
