-- [Comment]
-- jnmo
unlockPrompt = class("unlockPrompt", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
unlockPrompt.__index = unlockPrompt
function unlockPrompt:create(...)
    local layer = unlockPrompt.new(...)
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
function unlockPrompt:ctor()
    print("unlockPrompt ctor")
end

function unlockPrompt:init()
    
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    self.title = me.assignWidget(self, "Text_Title")
    self.isLoaded={}
    self.pageView = me.assignWidget(self, "PageView_2")
    
    
    
    if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
        self.pageView:addEventListenerPageView(handler(self, self.pageEvent))
    else
        self.pageView:addEventListener(handler(self, self.pageEvent))
    end

    local function func()
        me.assignWidget(self, "Image_Left_arr"):setTouchEnabled(false)
        me.assignWidget(self, "Image_right_arr"):setTouchEnabled(false)
        me.DelayRun(function()
            if not tolua.isnull(self) then
                me.assignWidget(self, "Image_Left_arr"):setTouchEnabled(true)
                me.assignWidget(self, "Image_right_arr"):setTouchEnabled(true)
            end
        end, 0.5)
    end
    me.registGuiClickEventByName(self,"Image_Left_arr",function (node)
        func()
        self:arrowPage(-1)
    end)
    me.registGuiClickEventByName(self,"Image_right_arr",function (node)
        func()
        self:arrowPage(1)
    end)
    return true
end

function unlockPrompt:pageEvent(pSender, eventType)       
        if eventType == 0 then
            local idx = nil
            if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
                idx = pSender:getCurPageIndex()
            else
                idx = pSender:getCurrentPageIndex()
            end
            
            if self.isLoaded[idx + 2] == false then
                
                local body = self:createPageBody(idx + 2)
                if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
                    self.pageView:addWidgetToPage(body, idx + 1, false)
                else
                    local layout=self.pageView:getItem(idx + 1)
                    layout:addChild(body)
                end
                self.isLoaded[idx + 2] = true
            end        
            local info = self.dataList[idx+1]  
            self.title:setString(info.name)

            me.assignWidget(self, "Image_Left_arr"):setVisible(idx ~= 0)
            me.assignWidget(self, "Image_right_arr"):setVisible(idx ~= #self.dataList - 1)
        end
       
end
function unlockPrompt:arrowPage(step)
    local idx = nil
    if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
        idx = self.pageView:getCurPageIndex()
    else
        idx = self.pageView:getCurrentPageIndex()
    end
    if idx+step>=0 and idx+step<#self.dataList then
        self.pageView:scrollToPage(idx+step)
        self:pageEvent(self.pageView, 0)
    end
end

function unlockPrompt:setUnlockId(id)
    self.unlockId=id
    local allData = cfg[CfgType.UNLOCK_FUNC_PROMPT]
    self.dataList= {}
    for _, v in ipairs(allData) do
        if v.id>=self.unlockId then
            table.insert(self.dataList, v)
        end
    end


    if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
        self.pageView:setUsingCustomScrollThreshold(true)
        self.pageView:setCustomScrollThreshold(100)
    end
    for i = 1, #self.dataList do
        self.isLoaded[i] = false
        local layout = ccui.Layout:create()
        layout:setContentSize(self.pageView:getContentSize())
        layout:setSwallowTouches(true)
        self.pageView:addPage(layout)
    end
    for level = 1, 2 do
        local body = self:createPageBody(level)
        if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
            self.pageView:addWidgetToPage(body, level - 1, false)
        else
            local layout=self.pageView:getItem(level - 1)
            layout:addChild(body)
        end
            
        self.isLoaded[level] = true
    end
    if not (targetPlatform ==cc.PLATFORM_OS_IPHONE or targetPlatform ==cc.PLATFORM_OS_IPAD) then
        self.pageView:setCurPageIndex(0)
    else
        self.pageView:scrollToPage(0, 0)
    end
    local info = self.dataList[1]  
    self.title:setString(info.name)
    me.assignWidget(self, "Image_Left_arr"):setVisible(false)
    me.assignWidget(self, "Image_right_arr"):setVisible(#self.dataList > 1)
end

function unlockPrompt:createPageBody(level)
    local body = me.assignWidget(self, "pageBody"):clone():setVisible(true)
    body:setAnchorPoint(cc.p(0, 0))
    body:setPosition(cc.p(0, 0))
    local info = self.dataList[level]
    me.assignWidget(body, "desc"):setString(info.desc)
    me.assignWidget(body, "fdesc"):setString(info.fdesc)
    me.assignWidget(body, "unlockIcon"):loadTexture("unlock_"..info.icon..".png", me.localType)
    me.assignWidget(body, "unlockIcon"):ignoreContentAdaptWithSize(true)
    return body
end

function unlockPrompt:update(msg)
    if checkMsg(msg.t, MsgCode.CROSS_SEVER_FIGHT_RECORD) then
        self:setNowTable(user.CrossSeverRank)
    elseif checkMsg(msg.t, MsgCode.CROSS_RANK) then
        self:setNowTable(user.CrossSeverRank)
    end
end
function unlockPrompt:onEnter()
    print("unlockPrompt onEnter")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)
end
function unlockPrompt:onEnterTransitionDidFinish()
    print("unlockPrompt onEnterTransitionDidFinish")
end
function unlockPrompt:onExit()
    print("unlockPrompt onExit")
    UserModel:removeLisener(self.modelkey)
end
function unlockPrompt:close()
    self:removeFromParentAndCleanup(true)
end
