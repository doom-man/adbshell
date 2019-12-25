runeBreakView = class("runeBreakView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeBreakView:create(...)
    local layer = runeBreakView.new(...)
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
            end)
            return layer
        end
    end
    return nil
end

function runeBreakView:ctor()
end

function runeBreakView:onEnter()
end

function runeBreakView:onEnterTransitionDidFinish()
end

function runeBreakView:onExit()
end

function runeBreakView:init()
    print("runeBreakView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    -- 符文icon
    self.runeIcon = runeItem:create(me.assignWidget(self, "RuneItem"), 1) 
    self.cailiaoItem = me.assignWidget(self, "cailiaoItem")
    self.itemNode = me.assignWidget(self, "itemNode")
    self.detailBox = me.assignWidget(self, "detailBox")

    me.registGuiClickEventByName(self, "btn_takeoff", function(sender)
        -- 请求分解符文
        if self.runeInfo.star>=3 then
            self:confirmBreak()
            return
        end
        NetMan:send(_MSG.Rune_resolve(self.runeInfo.id))
        self:removeFromParent()
        showWaitLayer ()
    end )

    return true
end

function runeBreakView:confirmBreak()

    local date=os.date("%Y-%m-%d")
    local runeBreakPromptTime = cc.UserDefault:getInstance():getStringForKey("runeBreakPromptTime", "")
    if runeBreakPromptTime==date then
        NetMan:send(_MSG.Rune_resolve(self.runeInfo.id))
        self:removeFromParent()
        showWaitLayer()
        return
    end

    local confirmView = cc.CSLoader:createNode("runeBreakMessageBox.csb")
    me.doLayout(confirmView, me.winSize)
    me.assignWidget(confirmView, "msg"):setString("是否分解"..self.runeInfo.star.."星级圣物？")
    local checkBox = me.assignWidget(confirmView,"checkBox")
    me.registGuiClickEventByName(confirmView, "btn_ok", function(node)
        NetMan:send(_MSG.Rune_resolve(self.runeInfo.id))
        
        if checkBox:isSelected() then 
            cc.UserDefault:getInstance():setStringForKey("runeBreakPromptTime", date)
            cc.UserDefault:getInstance():flush()
        end

        self:removeFromParent()
        showWaitLayer ()
    end )
    me.registGuiClickEventByName(confirmView, "btn_cancel", function(node)
        confirmView:removeFromParent()
        confirmView = nil
    end )
    self:addChild(confirmView)

end

function runeBreakView:setSelectRuneInfo(runeInfo)
    self.runeInfo = runeInfo
    self:updateBreakView()
end


function runeBreakView:cailiaoTouch(node, event)  
    if event == ccui.TouchEventType.began then
        self.detailBox:setVisible(true)
        self.detailBox:setPositionX(node:getPositionX())

        local etc = cfg[CfgType.ETC][me.toNum(node["itemId"])]
        me.assignWidget(self.detailBox, "cailiaoIcon"):loadTexture(getItemIcon(node["itemId"]), me.localType)
        me.assignWidget(self.detailBox, "cailiaoNums"):setString(node["nums"])
        me.assignWidget(self.detailBox, "nameTxt"):setString(etc.name)

    elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
        self.detailBox:setVisible(false)
    end
end

function runeBreakView:updateBreakView ()
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][self.runeInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.runeInfo.glv]

    self.runeIcon:setData(self.runeInfo)

    local cailiaoList = string.split(runeStrengthCfg.decomGet,",")
    local count=0
    for i, v in ipairs(cailiaoList) do
        local cailiaoData = string.split(v,":")
        local cailiaoItem = self.cailiaoItem:clone():setVisible(true)
        local etc = cfg[CfgType.ETC][me.toNum(cailiaoData[1])]
        me.assignWidget(cailiaoItem, "cailiaoIcon"):loadTexture(getItemIcon(cailiaoData[1]), me.localType)
        me.assignWidget(cailiaoItem, "cailiaoNums"):setString(cailiaoData[2])
        cailiaoItem["nums"]=cailiaoData[2]
        cailiaoItem["itemId"]=cailiaoData[1]
        cailiaoItem:setPosition(count*93, 0)
        me.registGuiTouchEvent(cailiaoItem, handler(self, self.cailiaoTouch))
        self.itemNode:addChild(cailiaoItem)
        count=count+1
    end
    cailiaoList = runeStrengthCfg.decomGet2~=nil and string.split(runeStrengthCfg.decomGet2,",") or {}
    for i, v in ipairs(cailiaoList) do
        local cailiaoData = string.split(v,":")
        local cailiaoItem = self.cailiaoItem:clone():setVisible(true)
        local etc = cfg[CfgType.ETC][me.toNum(cailiaoData[1])]
        me.assignWidget(cailiaoItem, "cailiaoIcon"):loadTexture(getItemIcon(cailiaoData[1]), me.localType)
        local nums = math.floor(tonumber(cailiaoData[2])*(self.runeInfo.star+2)/2)
        me.assignWidget(cailiaoItem, "cailiaoNums"):setString(nums)
        cailiaoItem["nums"]=nums
        cailiaoItem["itemId"]=cailiaoData[1]
        cailiaoItem:setPosition(count*93, 0)
        me.registGuiTouchEvent(cailiaoItem, handler(self, self.cailiaoTouch))
        self.itemNode:addChild(cailiaoItem)
        count=count+1
    end
    if self.runeInfo.runeSkillId>0 then
        local cailiaoItem = self.cailiaoItem:clone():setVisible(true)
        local etc = cfg[CfgType.ETC][885]
        me.assignWidget(cailiaoItem, "cailiaoIcon"):loadTexture(getItemIcon(885), me.localType)
        local nums = self.runeInfo.awakeTimes
        me.assignWidget(cailiaoItem, "cailiaoNums"):setString(nums)
        cailiaoItem["nums"]=nums
        cailiaoItem["itemId"]=885
        cailiaoItem:setPosition(count*93, 0)
        me.registGuiTouchEvent(cailiaoItem, handler(self, self.cailiaoTouch))
        self.itemNode:addChild(cailiaoItem)
        count=count+1
    end
    self.itemNode:setPositionX((855-count*93)/2)
end
