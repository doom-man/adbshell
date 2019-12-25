-- [Comment]
-- jnmo
fortWorld = class("fortWorld", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortWorld.__index = fortWorld
function fortWorld:create(...)
    local layer = fortWorld.new(...)
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
-- fortWorld.X = 23
-- fortWorld.Y = 23
-- fortWorld.Space = 210
fortWorld.RoadScale = 305
fortWorld.MoveMapX = -40
fortWorld.MoveMapY = 10
fortWorld.MaxMap = 1200
-- fortWorld.ScrollWidth = (fortWorld.X+16)*fortWorld.Space
-- fortWorld.ScrollHeight = ((fortWorld.Y-3)*fortWorld.Space-70)
function fortWorld:ctor()
    print("fortWorld ctor")
    self.curChooseCell = nil
end
function fortWorld:init()
    print("fortWorld init")
    self.map_bg = me.assignWidget(self, "map_bg")
    self.Button_press = me.assignWidget(self, "Button_press"):setVisible(true)
    self.map_Cross_bg = me.assignWidget(self, "map_Cross_bg")
    if user.Cross_Sever_Status == mCross_Sever_Out then
        fortWorld.RoadScale = 305
        fortWorld.MoveMapX = -5
        fortWorld.MoveMapY = 5
        fortWorld.MaxMap = 1200
        self.map_bg:setVisible(true)
        self.map_Cross_bg:setVisible(false)
    elseif user.Cross_Sever_Status == mCross_Sever then
        fortWorld.RoadScale = 25
        fortWorld.MoveMapX = -38
        fortWorld.MoveMapY = -5
        fortWorld.MaxMap = 100
        self.map_bg:setVisible(false)
        self.map_Cross_bg:setVisible(true)
    end

    local function ebXCallFunc(eventType, sender)
        if eventType == "began" then
            sender:setFontColor(me.convert3Color_("ffffff"))
        elseif eventType == "changed" then
            local coX = me.toNum(sender:getText())
            if coX then
                if coX > 1200 then
                    showTips("坐标超出范围")
                    sender:setText(1200)
                elseif coX <= 0 then
                    showTips("坐标需要大于0")
                    sender:setText(1)
                end
            end
        elseif eventType == "return" then
            if sender:getText() and sender:getText() ~= "" and me.toNum(sender:getText()) then
                self.pFortPitchX = me.toNum(sender:getText())
                self.fort_current:setPosition(self:getMapPoint(cc.p(self.pFortPitchX, self.pFortPitchY)))
            elseif string.len(sender:getText()) > 0 then
                showTips("坐标不合法")
                sender:setText(self.pFortPitchX)
            else
                sender:setText(self.pFortPitchX)
            end
        elseif eventType == "ended" then
            sender:setFontColor(me.convert3Color_("67ff02"))
        end
    end
    self.ebX = me.addInputBox(103, 42, 24, nil, ebXCallFunc, cc.EDITBOX_INPUT_MODE_NUMERIC, "")
    self.ebX:setAnchorPoint(0, 0)
    self.ebX:setFontColor(me.convert3Color_("67ff02"))
    me.assignWidget(self, "Image_10"):addChild(self.ebX)

    local function ebYCallFunc(eventType, sender)
        if eventType == "began" then
            sender:setFontColor(me.convert3Color_("ffffff"))
        elseif eventType == "changed" then
            local coY = me.toNum(sender:getText())
            if coY then
                if coY > 1200 then
                    showTips("坐标超出范围")
                    sender:setText(1200)
                elseif coY <= 0 then
                    showTips("坐标需要大于0")
                    sender:setText(1)
                end
            end
        elseif eventType == "return" then
            if sender:getText() and sender:getText() ~= "" and me.toNum(sender:getText()) then
                self.pFortPitchY = me.toNum(sender:getText())
                self.fort_current:setPosition(self:getMapPoint(cc.p(self.pFortPitchX, self.pFortPitchY)))
            elseif string.len(sender:getText()) > 0 then
                showTips("坐标不合法")
                sender:setText(self.pFortPitchX)
            else
                sender:setText(self.pFortPitchX)
            end
        elseif eventType == "ended" then
            sender:setFontColor(me.convert3Color_("67ff02"))
        end
    end
    self.ebY = me.addInputBox(103, 42, 24, nil, ebYCallFunc, cc.EDITBOX_INPUT_MODE_NUMERIC, "")
    self.ebY:setAnchorPoint(0, 0)
    self.ebY:setFontColor(me.convert3Color_("67ff02"))
    me.assignWidget(self, "Image_11"):addChild(self.ebY)

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "landInfoBtn", function(node)
        GMan():send(_MSG.roleLandInfo())
    end )
    --  self.pPancel = me.assignWidget(self,"arch_pancel")
    --    self.pPancel:setSwallowTouches(false)
    self.pFortData = { }
    self.pFortOccupy = { }
    self.mCuPointX = user.x
    -- 主城坐标
    self.mCuPointY = user.y
    -- 主城坐标
    -- self.OffsetX = (fortWorld.X*fortWorld.Space/2-950/2)   -- scrollview的中心
    --  self.OffsetY = ((fortWorld.Y*fortWorld.Space-70)/2-480/2)
    self.pFortPitchX = -1
    self.pFortPitchY = -1
    self.StopNode = nil
    -- 选中的要塞
    --  self:setScorllView()
    self.leftTimerNum = { }
    -- 要塞放弃的时间 table表
    self:setFortMap()

    -- 王座提示标记
    self.img_throne_tip = me.assignWidget(self, "img_throne_tip")
    self.img_throne_tip:setVisible(user.show_throne_flag == true)
    me.registGuiClickEvent(self.img_throne_tip, function()
        askLookMap(cc.p(600, 600), "王座争夺中，是否确定跳转？", "fortWorldClose")
    end)

    self:setInput(user.curMapCrood.x, user.curMapCrood.y)
    self:setFortName(user.name)
    self:setCurrentIcon()
    if user.Cross_Sever_Status == mCross_Sever then
        self:setKingMarks()
        self:setBattleMark()
    end
    self:setCurrent(user.curMapCrood)
    self:setUI()
    self:setFortData()
    self:StagetTab(self.pFortOccupy)
    self:setTouch()

    if user.Cross_Sever_Status == mCross_Sever then
        self.Button_press:setVisible(false)
        me.assignWidget(self, "landNum"):setString(user.lansize .. "/" .. user.Maxlansize)
    else
        me.assignWidget(self, "landNum"):setString(user.lansize .. "/" .. user.propertyValue["LandNumAdd"])
    end
    self.mecthread = coroutine.create( function()
        self:setplotMap()
    end )
    self.meschid = me.coroStart(self.mecthread, 0, function()

    end )
    self.cthread = coroutine.create( function()
        self:setallinaceplotMap()
    end )
    self.schid = me.coroStart(self.cthread, 0, function()

    end )
    if user.Cross_Sever_Status == mCross_Sever then
        self:ThroneMap()
    else
        me.registGuiClickEventByName(self, "Button_throne", function(node)
            self:setInput(600, 600)
        end )
    end
    self.closeEvent = me.RegistCustomEvent("fortWorldClose",function (args)
       self:close()
    end)
    me.assignWidget(self,"Image_6_0"):setVisible(user.Cross_Sever_Status == mCross_Sever)
    me.assignWidget(self,"Image_7_0"):setVisible(user.Cross_Sever_Status == mCross_Sever)
    me.assignWidget(self,"Image_2_0"):setVisible(user.Cross_Sever_Status == mCross_Sever)
    return true
end
function fortWorld:setTouch()
    self.fort_current = me.assignWidget(self, "fort_current")
    --   self.icon:setPosition(cc.p(0,0))
    local move = false
    local pPanel_Touch = me.assignWidget(self, "Panel_Touch")
    me.registGuiTouchEvent(pPanel_Touch, function(node, event)
        if event == ccui.TouchEventType.began then
            move = false
            node:setSwallowTouches(false)
        elseif event == ccui.TouchEventType.moved then
            local mp = node:getTouchMovePosition()
            local sp = node:getTouchBeganPosition()            
            if cc.pGetDistance(sp,mp) > 10 then
                move= true
            end
            if move then
                mp = cc.p(mp.x, mp.y + 150)
                self:setTouchPanel(mp)
            end
        elseif event == ccui.TouchEventType.ended then
            if move == false then
                local mp = node:getTouchBeganPosition()
                mp = cc.p(mp.x, mp.y + 20)
                self:setTouchPanel(mp)
            end
        elseif event == ccui.TouchEventType.canceled then
            node:setSwallowTouches(false)
        end
    end )
    pPanel_Touch:setSwallowTouches(false)
end
function fortWorld:setTouchPanel(mp)
    if mp.x > 270 and mp.x < 1247 and mp.y > 136 and mp.y < 626 then
        local pBool = self:getRangeFort(mp)
        if pBool then
            local pPoint = cc.p(mp.x - 300, mp.y - 148)
            self.fort_current:setPosition(pPoint)
            local pMapPoint = self:getfortPoint(pPoint)
            if pMapPoint.x > fortWorld.MaxMap then
                pMapPoint.x = fortWorld.MaxMap
            end
            if pMapPoint.x < 0 then
                pMapPoint.x = 0
            end
            if pMapPoint.y > fortWorld.MaxMap then
                pMapPoint.y = fortWorld.MaxMap
            end
            if pMapPoint.y < 0 then
                pMapPoint.y = 0
            end
            self:setInput(pMapPoint.x, pMapPoint.y)
            if self.curChooseCell then
                me.assignWidget(self.curChooseCell ,"fort_cell"):loadTexture("ui_wmap_cell.png",me.localType)
                self.curChooseCell = nil
            end
        end
    end
end
function fortWorld:getRangeFort(pPoint)
    local pFortPoint = cc.p(pPoint.x - 270, pPoint.y - 140)
    local pRangeY = 0
    if pFortPoint.x > 485 then
        pRangeY =(485 -(pFortPoint.x - 485))
    else
        pRangeY = pFortPoint.x
    end
    if 250 + pRangeY / 2 > pFortPoint.y and 250 - pRangeY / 2 < pFortPoint.y then
        return true
    end
    return false
end

function fortWorld:posCheck(type, sender)
    local pos = me.toNum(sender:getText())
    if pos then
        if pos > 1200 then
            showTips("坐标超出范围")
            sender:setText(1200)
        elseif pos <= 0 then
            showTips("坐标需要大于0")
            sender:setText(1)
        end
    end
    if type == 1 then
        self.pFortPitchX = pos
    else
        self.pFortPitchY = pos
    end
end
function fortWorld:setUI()
    --     local pInputX = me.assignWidget(self,"TextField_X")
    --     self.pInputHaveX = 0
    --      local function alliance_name_input_regist_callback(sender,eventType)
    --        if eventType == ccui.TextFiledEventType.attach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.225,cc.p(0, 20)))
    --            self.pInputHaveX = me.toNum(sender:getString())
    --            sender:setString("")
    --        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))      -- 输入完成触屏
    --             local pStr = sender:getString()
    --             if string.len(pStr) == 0  then
    --                sender:setString(self.pInputHaveX)
    --             end
    --        elseif eventType == ccui.TextFiledEventType.insert_text then
    --             self.pFortPitchX = me.toNum(sender:getString())                          -- 输入完成
    --             local pStr = sender:getString()
    --             if me.toNum(pStr) ~= nil then
    --                if string.len(pStr) == 0  then
    --                  sender:setString(self.pInputHaveX)
    --                end
    --             else
    --                 showTips("请输入数字")
    --                 self.pFortPitchX = self.pInputHaveX
    --                 sender:setString(self.pInputHaveX)
    --             end

    --        elseif eventType == ccui.TextFiledEventType.delete_backward then
    --             self.pFortPitchX = me.toNum(sender:getString())
    --             local pStr = sender:getString()
    --            if me.toNum(pStr) ~= nil then
    --                if string.len(pStr) == 0  then
    --                  sender:setString(self.pInputHaveX)
    --                end
    --             else
    --                showTips("请输入数字")
    --                 self.pFortPitchX = self.pInputHaveX
    --                 sender:setString(self.pInputHaveX)
    --             end
    --        end
    --    end
    --     pInputX:addEventListener(alliance_name_input_regist_callback)


    --    local pInputY = me.assignWidget(self,"TextField_Y")
    --    self.pInputHaveY = 0
    --      local function alliance_breif_input_regist_callback(sender,eventType)
    --        if eventType == ccui.TextFiledEventType.attach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.225,cc.p(0, 20)))
    --            self.pInputHaveY = me.toNum(sender:getString())
    --            sender:setString("")
    --        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
    --            local textField = sender
    --            textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))      -- 输入完成触屏
    --             local pStr = sender:getString()
    --             if string.len(pStr) == 0  then
    --                sender:setString(self.pInputHaveY)
    --             end
    --        elseif eventType == ccui.TextFiledEventType.insert_text then
    --             self.pFortPitchY = me.toNum(sender:getString())                          -- 输入完成
    --             local pStr = sender:getString()
    --             if me.toNum(pStr) ~= nil then
    --                 if string.len(pStr) == 0  then
    --                   sender:setString(self.pInputHaveY)
    --                 end
    --             else
    --                  showTips("请输入数字")
    --                  sender:setString(self.pInputHaveY)
    --                  self.pFortPitchY = self.pInputHaveY
    --             end

    --        elseif eventType == ccui.TextFiledEventType.delete_backward then
    --            self.pFortPitchY = me.toNum(sender:getString())
    --            local pStr = sender:getString()
    --             if me.toNum(pStr) ~= nil then
    --                 if string.len(pStr) == 0  then
    --                   sender:setString(self.pInputHaveY)
    --                 end
    --             else
    --                  showTips("请输入数字")
    --                  sender:setString(self.pInputHaveY)
    --                  self.pFortPitchY = self.pInputHaveY
    --             end
    --        end
    --    end
    --    pInputY:addEventListener(alliance_breif_input_regist_callback)
    local pSkip = me.assignWidget(self, "fort_Button_skip")

    me.registGuiClickEvent(pSkip, function(node)
        self:posCheck(1, self.ebX)
        self:posCheck(2, self.ebY)
        if self.pFortPitchX ~= -1 and self.pFortPitchY ~= -1 then
            pWorldMap:lookMapAt(self.pFortPitchX, self.pFortPitchY)
            self:close()
        end
    end )
    local pNormal = me.assignWidget(self, "Button_narmal")
    -- 查看
    pNormal:setVisible(false)
    local pPress = me.assignWidget(self, "Button_press")
    -- 关闭查看
    local pMapInfor = me.assignWidget(self, "Node_map_infor")
    pMapInfor:setVisible(false)
    pMapInfor:setLocalZOrder(11)
    me.registGuiClickEvent(pPress, function(node)
        pNormal:setVisible(true)
        pPress:setVisible(false)
        pMapInfor:setVisible(true)
        self:CheckInfor()
    end )
    me.registGuiClickEvent(pNormal, function(node)
        pPress:setVisible(true)
        pNormal:setVisible(false)
        pMapInfor:setVisible(false)
        for var = 1, 5 do
            local pNode = me.assignWidget(self, "map_ring_hint_" .. var)
            pNode:setVisible(false)
        end
        if self.pMapInforTime ~= nil then
            me.clearTimer(self.pMapInforTime)
            self.pMapInforTime = nil
        end
    end )
    -- pSkip:setSwallowTouches(true)
    --     local pButton = me.assignWidget(self,"fort_direction")
    --     me.registGuiClickEvent(pButton,function (node)
    --         self:setScrollOffset(self.mCuPointX,self.mCuPointY)
    --     end)
end
function fortWorld:CheckInfor()
    self.pMapCount = 1
    self.pMapInforTime = me.registTimer(-1, function(dt)
        local pNode = me.assignWidget(self, "map_ring_hint_" .. self.pMapCount)
        pNode:setVisible(true)
        pNode:setLocalZOrder(11)
        if self.pMapCount == 5 then
            me.clearTimer(self.pMapInforTime)
            self.pMapInforTime = nil
        else
            self.pMapCount = self.pMapCount + 1
        end

    end , 0)
end
function fortWorld:contains(node, x, y)
    local point = cc.p(x, y)
    local pRect = cc.rect(0, 0, node:getContentSize().width, node:getContentSize().height)
    local locationInNode = node:convertToNodeSpace(point)
    -- 世界坐标转换成节点坐标
    return cc.rectContainsPoint(pRect, locationInNode)
end

-- function fortWorld:setScorllView()

--    me.registGuiTouchEvent(self.pPancel,function(node,event)
--        if event == ccui.TouchEventType.ended then
--            local pOffset = self.pScrollView:getInnerContainerPosition()
--            self.mPitchImg:setVisible(false)
--            self:setDiection(pOffset)
--        end
--    end)
--    local pScrollView = ccui.ScrollView:create()
--    pScrollView:setContentSize(cc.size(946,500))
--    pScrollView:setDirection(ccui.ScrollViewDir.both)
--    pScrollView:setAnchorPoint(cc.p(0,0))
--    pScrollView:setPosition(cc.p(0,-4))
--    pScrollView:setInnerContainerSize(cc.size(fortWorld.ScrollWidth,fortWorld.ScrollHeight))
--    pScrollView:setInertiaScrollEnabled(false)
--    pScrollView:setBounceEnabled(false)
--    pScrollView:setTouchEnabled(true)
--    self.pScrollView = pScrollView
--    me.assignWidget(self,"Scrollview_Node"):addChild(pScrollView)

--    local pLayerRoad = cc.Layer:create()
--    pLayerRoad:setAnchorPoint(cc.p(0,0))
--    pLayerRoad:setContentSize(pScrollView:getContentSize())
--    pLayerRoad:setPosition(cc.p(0,0))
--    pScrollView:addChild(pLayerRoad)
--    self.pLayerRoad = pLayerRoad
--    local pLayerBuild = cc.Layer:create()
--    pLayerBuild:setAnchorPoint(cc.p(0,0))
--    pLayerBuild:setContentSize(pScrollView:getContentSize())
--    pLayerBuild:setPosition(cc.p(0,0))
--    pScrollView:addChild(pLayerBuild)
--    self.mLayerBuild = pLayerBuild

--  --  self:setFortData()
--    self.pBool = false
--    self:setScrollViewRoad(self.pLayerRoad)
--     self:StagetTab(self.pFortOccupy)
--    self:setCurrent(self.mLayerBuild)
--    self:setInput(self.mCuPointX,self.mCuPointY)

--    self:setMaP()
----    self.cthread = coroutine.create(function ()
----          self:setScrollViewUI(self.pLayerRoad,self.mLayerBuild)
----     end)
----    self.schid = me.coroStart(self.cthread,function ()

----    end)
-- end
-- function fortWorld:setScrollViewRoad(pNode)
--     local dNode =  cc.DrawNode:create()
--     for key, var in pairs(gameMap.lineSegmentDatas) do

--        local pStarPoint,pEndPoint = me.converDualCrood(var["id"])
--        local pIconStr = "yaosai_beijing_lianjie.png"
--        local pColor = cc.c4f(1, 1, 1, 1)
--        if var.state == 1 then  -- 联通的路
--           pIconStr = "yaosai_beijing_lianjie.png"
--           pColor = ccc4FFromccc4B(cc.c4b(216,217,83,255))
--        else
--           pIconStr = "yaosai_beijing_lianjie_wei.png"
--           pColor = ccc4FFromccc4B(cc.c4b(89,89,89,255))
--        end
--    --    pColor = cc.c4b(89, 89, 89, 1)
--        local pCPointX,pCPointY = self:getCurrentPoint(pStarPoint.x,pStarPoint.y)
--        local pCRPointX,pCRPointY = self:getCurrentPoint(pEndPoint.x,pEndPoint.y)
--        local pCPoint = me.convertToScreenCoord(tmxMap,cc.p(pStarPoint.x,pStarPoint.y))
--        local pCRPoint = me.convertToScreenCoord(tmxMap,cc.p(pEndPoint.x,pEndPoint.y))
--        local pRoadX = (pCPoint.x/fortWorld.RoadScale + pCRPoint.x/fortWorld.RoadScale)/2
--        local pRoadY = (pCPoint.y/fortWorld.RoadScale + pCRPoint.y/fortWorld.RoadScale)/2
--        local p = me.getAngleWith2Pos(cc.p(pCPoint.x,pCPoint.y),cc.p(pCRPoint.x,pCRPoint.y))
--        local pLengthX = math.abs(pCPointX- pCRPointX)
--        local pLengthY = math.abs(pCPointY- pCRPointY)
--        local pLength = math.sqrt(pLengthX*pLengthX + pLengthY*pLengthY)
--        local pPoint = me.convertToScreenCoord(tmxMap,cc.p(pRoadX,pRoadY))

--      -- local pRoad = ccui.ImageView:create(pIconStr,me.localType)
--      --  c4FFromccc3B
--        dNode:drawLine(cc.p(pCPoint.x/fortWorld.RoadScale-100,pCPoint.y/fortWorld.RoadScale),cc.p(pCRPoint.x/fortWorld.RoadScale-100,pCRPoint.y/fortWorld.RoadScale),pColor)

----        pRoad:setRotation(p)
----        pRoad:setContentSize(cc.size(200,13.3))
----        pRoad:setPosition(cc.p(pRoadX,pRoadY))
----        pRoad:setLocalZOrder(19)
----        pRoad:setScale9Enabled(true)
----        pRoad:setCapInsets(cc.rect(4,4,7,13))
----        pNode:addChild(pRoad)
--      --  coroutine.yield()
--     end
--     pNode:addChild(dNode)
-- end

-- function fortWorld:setScrollViewUI(pNode,pBuild)
--    local pWinth = fortWorld.Space
--       for key, var in pairs(gameMap.sortFortDatas) do
--            local pRoad = me.assignWidget(self,"fort_build"):clone():setVisible(true)
--            local fort_build_marker = me.assignWidget(pRoad,"fort_build_marker")
--            local pId = var["id"]
--            local pData = GFortData()[pId]
--            local pFortData = var
--            local pIconStr = "waicheng_yaosai_shijie_"..pData["icon"]..".png"
--            local pTouchBool = true
--            if pFortData ~= nil then
--                if pFortData.famdata == nil then
--                   pIconStr = "yaosai_tubiao_yaosai_hui.png"
--                   fort_build_marker:setVisible(false)
--                   pTouchBool = false
--                else
--                  pIconStr = "waicheng_yaosai_shijie_"..pData["icon"]..".png"

--                  if pFortData["occ"] == 0 then
--                     fort_build_marker:loadTexture("yaosai_tubiao_liantong.png",me.localType)
--                  elseif pFortData["occ"] == 1 then
--                     fort_build_marker:setVisible(false)
--                  end
--                end
--                 if pFortData["famdata"] ~= nil then
--                  local pFortFamily = pFortData["famdata"]
--                    if pFortFamily["mine"] ~= 1 then
--                      pIconStr = "waicheng_yaosai_shijie_"..pData["icon"]..".png"
--                    end
--                end
--            end
--            local selectImg = ccui.ImageView:create()
--            selectImg:loadTexture(pIconStr,me.plistType)
--            local p = me.convertToScreenCoord(tmxMap,me.getCoordByFortId(pId))
--            local pScale = 1
--            if pFortData["occ"] == -1 then
--             -- selectImg:setPosition(cc.p(fortWorld.Space+pWinth*(x-1),fortWorld.Space+pWinth*(y-1)-20))
--                selectImg:setPosition(cc.p(p.x/fortWorld.RoadScale-100,p.y/fortWorld.RoadScale))
--              pScale = (50)/(selectImg:getContentSize().height)
--            else
--             -- selectImg:setPosition(cc.p(fortWorld.Space+pWinth*(x-1),fortWorld.Space+pWinth*(y-1)))
--             selectImg:setPosition(cc.p(p.x/fortWorld.RoadScale-100,p.y/fortWorld.RoadScale))
--              pScale = (110)/(selectImg:getContentSize().height)
--            end
--            selectImg:setScale(pScale)
--            selectImg:setTag(pId)
--            pBuild:addChild(selectImg)
--            if pTouchBool == false then
--               selectImg:setName(1)
--            else
--               selectImg:setName(2)
--            end
--            me.registGuiClickEvent(selectImg,function(node)

--            local pTouch = node:getTouchEndPosition()
--            local pBool = me.toNum(node:getName())

--            local pPoint = self:contains(self.pPancel,pTouch.x,pTouch.y)
--            if pPoint and pBool == 2 then
--                 local pId = me.toNum(node:getTag())
--               --  local pData = self.pFortData[pId]
--                 local pX = math.floor(pId/10000)
--                 local pY = math.floor(pId%10000)
--                self:setInput(pX,pY)
--                if self.StopNode ~= nil then
--                    self.StopNode:stopAllActions()
--                end
--                me.clickAni(node)
--                self.StopNode = node
--                node:setSwallowTouches(false)
--            end
--           end)
--            selectImg:setSwallowTouches(false)
--            local pBuild_N = me.assignWidget(pRoad,"fort_build_name_bg"):clone():setVisible(true)
--          --  pBuild_N:setPosition(cc.p(fortWorld.Space+12+pWinth*(x-1),fortWorld.Space-45+pWinth*(y-1)))
--          pBuild_N:setPosition(cc.p(p.x/fortWorld.RoadScale-100,p.y/fortWorld.RoadScale-50))
--            pBuild:addChild(pBuild_N)
--            local pBuildName = me.assignWidget(pBuild_N,"fort_build_name")
--            pBuildName:setString(pData["name"])

--            if pFortData["famdata"] ~= nil then
--            local pFortFamily = pFortData["famdata"]
--                if pFortFamily["mine"] ~= 1 then
--                  fort_build_marker:loadTexture("yaosai_tubiao_dieren.png",me.localType)
--                else
--                  pBuildName:setTextColor(cc.c4b(241,226,209,255))

--                end
--            else
--               pBuildName:setTextColor(cc.c4b(241,226,209,255))
--            end
--            -- 星级
--            local pStar = pData["star"]
--            local pStarNum = math.floor(pStar/2)
--            local pStarNode = me.assignWidget(pBuild_N,"arch_fort_star"):setVisible(true)
--            for var = 1,(pStarNum) do
--                local pStarIcon = ccui.ImageView:create()
--                pStarIcon:loadTexture("yaosai_tubiao_xingxing.png",me.localType)
--                pStarIcon:setAnchorPoint(cc.p(0,0.5))
--                pStarIcon:setPosition(cc.p(5+(var-1)*30,0))
--                pStarNode:addChild(pStarIcon)
--            end
--            if (pStar%2) ~=0 then
--                local pStarIconHalf = ccui.ImageView:create()
--                pStarIconHalf:loadTexture("yaosai_tubiao_xingxing_ban.png",me.localType)
--                pStarIconHalf:setAnchorPoint(cc.p(0,0.5))
--                pStarIconHalf:setPosition(cc.p(5+(pStarNum)*30,0))
--                pStarNode:addChild(pStarIconHalf)
--            end
--            coroutine.yield()
--         end
-- end

function fortWorld:setFortMap()
    local pLayerBuild = cc.Layer:create()
    pLayerBuild:setAnchorPoint(cc.p(0, 0))
    pLayerBuild:setContentSize(cc.size(952, 500))
    pLayerBuild:setPosition(cc.p(0, 0))
    me.assignWidget(self, "Map_Node"):addChild(pLayerBuild)
    --  self.mLayerBuild = pLayerBuild
    for key, var in pairs(gameMap.fortDatas) do
        local pId = var["id"]
        local pFortData = var
        local pStr = "yaosai_tubian_weizhan_xiao.png"
        if pFortData ~= nil then
            local pData = user.fortWorldData[pId]
            if pData == nil or pData.vType == 0 then
                -- 未占领
                pStr = "yaosai_tubian_weizhan_xiao.png"
            else
                if pData["mine"] == 1 then
                    -- 自己联盟占领
                    --                    dump(pData)
                    if pData.giveup and pData.giveup > 0 then
                        local leftTime = ccui.Text:create()
                        leftTime:setFontSize(14)
                        leftTime:setTextColor(COLOR_RED)
                        leftTime:setString(me.formartServerTime(pData.giveup))
                        leftTime:setTag(pData.giveup)
                        self.leftTimerNum[#self.leftTimerNum + 1] = leftTime
                        local pos = self:getMapPoint(me.getCoordByFortId(pId))
                        leftTime:setPosition(pos.x, pos.y - 15)
                        leftTime:setLocalZOrder(11)
                        me.assignWidget(self, "Map_Node"):addChild(leftTime)
                        pStr = "yaosai_tubian_fangqi.png"
                    else
                        pStr = "yaosai_tubian_lianmeng_xiao.png"
                    end
                elseif pData["mine"] == 0 then
                    -- 敌对占领
                    pStr = "yaosai_tubian_dieren_xiao.png"
                end
            end
            if pData and pData["start"] == 1 then
                local pselectImg = ccui.ImageView:create()
                pselectImg:loadTexture("shenjiang_kaiqi.png", me.plistType)
                pselectImg:setScale(0.5)
                pselectImg:setPosition(cc.p(self:getMapPoint(me.getCoordByFortId(pId)).x, self:getMapPoint(me.getCoordByFortId(pId)).y + 10))
                pselectImg:setLocalZOrder(13)
                me.assignWidget(self, "Map_Node"):addChild(pselectImg)
            end
        end

        local selectImg = ccui.ImageView:create()
        selectImg:loadTexture(pStr, me.plistType)
        --        dump(pId)
        selectImg:setPosition(self:getMapPoint(me.getCoordByFortId(pId)))
        selectImg:setLocalZOrder(10)
        me.assignWidget(self, "Map_Node"):addChild(selectImg)
    end
    if table.nums(self.leftTimerNum) > 0 then
        self.timer = me.registTimer(-1, function()
            for key, var in pairs(self.leftTimerNum) do
                local t = var:getTag()
                t = me.toNum(t) -1
                if t <= 0 then
                    t = 0
                end
                var:setTag(t)
                var:setString(me.formartServerTime(t))
            end
        end , 1)
    end
end
function fortWorld:setCurrent(pPoint)
    dump(pPoint)
    local p = me.convertToScreenCoord(tmxMap, pPoint)
    dump(p)
    local pPoint = cc.p(p.x / fortWorld.RoadScale + fortWorld.MoveMapX, p.y / fortWorld.RoadScale + fortWorld.MoveMapY)
    local pCurrent = me.assignWidget(self, "fort_current"):setVisible(true)
    pCurrent:setPosition(pPoint)
    pCurrent:setLocalZOrder(15)
    --   me.assignWidget(self,"Map_Node"):addChild(pCurrent)
end
function fortWorld:getfortPoint(pFortPoint)
    local pPoint = cc.p((pFortPoint.x - fortWorld.MoveMapX) * fortWorld.RoadScale,(pFortPoint.y - fortWorld.MoveMapY) * fortWorld.RoadScale)
    local pMapPoint = me.converScreenToTiledCoord(tmxMap, pPoint)
    return pMapPoint
end
function fortWorld:getMapPoint(pPointMap)
    local p = me.convertToScreenCoord(tmxMap, pPointMap)
    local pPoint = cc.p(p.x / fortWorld.RoadScale + fortWorld.MoveMapX, p.y / fortWorld.RoadScale + fortWorld.MoveMapY)
    return pPoint
end
function fortWorld:setRoad(x, y)
    local pRoadX =(pCPointX + pCRPointX) / 2
    local pRoadY =(pCPointY + pCRPointY) / 2
    local p = me.getAngleWith2Pos(cc.p(pCPointX, pCPointY), cc.p(pCRPointX, pCRPointY))
    local pLengthX = math.abs(pCPointX - pCRPointX)
    local pLengthY = math.abs(pCPointY - pCRPointY)
    local pLength = math.sqrt(pLengthX * pLengthX + pLengthY * pLengthY)
    --   local pRoad = me.assignWidget(self,"fort_road"):clone():setVisible(true)
    local pRoad = ccui.ImageView:create("yaosai_beijing_lianjie.png", me.localType)
    --  pRoad:loadTexture("yaosai_beijing_lianjie.png",me.localType)
    pRoad:setRotation(p)
    pRoad:setContentSize(cc.size(pLength, 13.3))
    pRoad:setPosition(cc.p(pRoadX, pRoadY))
    pRoad:setLocalZOrder(19)
    pRoad:setScale9Enabled(true)
    pRoad:setCapInsets(cc.rect(4, 4, 7, 13))
    pBuild:addChild(pRoad)
end 
-- 输入框
function fortWorld:setInput(pX, pY)

    --     local pXLabel = me.assignWidget(self,"TextField_X")
    --     pXLabel:setString(pX)
    --     local pYLabel = me.assignWidget(self,"TextField_Y")
    --     pYLabel:setString(pY)
    if self.ebX and self.ebX.setText then
        self.ebX:setText(pX)
    end
    if self.ebY and self.ebY.setText then
        self.ebY:setText(pY)
    end
    self.pFortPitchX = pX
    self.pFortPitchY = me.toNum(pY)
end
--  地图要塞名字
function fortWorld:setFortName(pName)
    local pNameLabel = me.assignWidget(self, "fortress_name")
    pNameLabel:setString(pName)
end
function fortWorld:setCurrentIcon()
    local p = me.convertToScreenCoord(tmxMap, cc.p(self.mCuPointX, self.mCuPointY))
    local pPoint = cc.p(p.x / fortWorld.RoadScale + fortWorld.MoveMapX, p.y / fortWorld.RoadScale + fortWorld.MoveMapY)
    local pIcon = me.assignWidget(self, "fort_road_current"):clone():setVisible(true)
    pIcon:setPosition(pPoint)
    pIcon:setLocalZOrder(5)
    me.assignWidget(self, "Map_Node"):addChild(pIcon)
end
function fortWorld:setKingMarks()
    local function click_kingMark(node)
        local signdata = node.data
        local markinfo = mapSetMarkKing:create("mapSetMarkKing.csb")
        markinfo:initWithData(signdata)
        me.popLayer(markinfo)
    end
    for key, var in pairs(user.markKingPos) do
        local p = me.convertToScreenCoord(tmxMap, cc.p(var.x, var.y))
        local pPoint = cc.p(p.x / fortWorld.RoadScale + fortWorld.MoveMapX, p.y / fortWorld.RoadScale + fortWorld.MoveMapY)
        local pIcon = nil
        if var.mine == true then
             pIcon = ccui.ImageView:create("map_tag1.png")
        else
             pIcon = ccui.ImageView:create("map_tag2.png")
        end
        pIcon:setPosition(pPoint)
        pIcon.data = var
        me.registGuiClickEvent(pIcon, click_kingMark)
        pIcon:setLocalZOrder(5)
        me.assignWidget(self, "Map_Node"):addChild(pIcon)
    end
end
function fortWorld:setBattleMark()
    local function click_kingMark(node)
        local data = node.data
        local str = "小型战役"
        if data.num == 1 then
            str = "小型战役"
        elseif data.num == 2 then
            str = "中型战役"
        elseif data.num == 3 then
            str = "大型战役"
        end
        askLookMap(cc.p(data.x, data.y),"此处发生"..str..",是否确定跳转？","fortWorldClose")
    end
    for key, var in pairs(user.battleList) do
        local p = me.convertToScreenCoord(tmxMap, cc.p(var.x, var.y))
        local pPoint = cc.p(p.x / fortWorld.RoadScale + fortWorld.MoveMapX, p.y / fortWorld.RoadScale + fortWorld.MoveMapY)
        local pIcon = ccui.ImageView:create("map_battle.png")
        pIcon:setPosition(pPoint)
        pIcon.data = var
        me.registGuiClickEvent(pIcon, click_kingMark)
        pIcon:setLocalZOrder(6)
        me.assignWidget(self, "Map_Node"):addChild(pIcon)
    end
end
-- 自己的地块
function fortWorld:setplotMap()
    for key, var in pairs(user.plotData) do
        local selectImg = ccui.ImageView:create()
        selectImg:loadTexture("yaosai_di_ziji.png", me.localType)
        selectImg:setPosition(self:getMapPoint(cc.p(var[1], var[2])))
        --  selectImg:setLocalZOrder()
        me.assignWidget(self, "Map_Node"):addChild(selectImg)
        coroutine.yield()
    end
end
function fortWorld:setallinaceplotMap()
    if user.allianceplot ~= nil then
        for key, var in pairs(user.allianceplot) do
            local selectImg = ccui.ImageView:create()
            selectImg:loadTexture("yaosai_di_lianmeng.png", me.localType)
            selectImg:setPosition(self:getMapPoint(cc.p(var[1], var[2])))
            me.assignWidget(self, "Map_Node"):addChild(selectImg)
            coroutine.yield()
        end
    end
end
function fortWorld:ThroneMap()
    if user.throne_plot ~= nil then
        for key, var in pairs(user.throne_plot) do
            local selectImg = ccui.ImageView:create()
            selectImg:loadTexture("wangzuo_tubiao_wangzuo_xiao.png", me.localType)
            selectImg:setPosition(self:getMapPoint(cc.p(var.x, var.y)))
            me.assignWidget(self, "Map_Node"):addChild(selectImg)
        end
    end
end

function fortWorld:TableTouch(pTag)
    local pIcon = self.mLayerBuild:getChildByTag(pTag)
    if self.StopNode ~= nil then
        self.StopNode:stopAllActions()
    end
    me.clickAni(pIcon)
    self.StopNode = pIcon
end
-- function fortWorld:setScrollOffset(X,Y)

--    local pCPoint = me.convertToScreenCoord(tmxMap,cc.p(X,Y))

--    pCPoint = cc.p(pCPoint.x/fortWorld.RoadScale-100,pCPoint.y/fortWorld.RoadScale)

--    local pOffsetX = 0
--    if pCPoint.x > ((fortWorld.X+16)*fortWorld.Space - (950/2)) then
--        pOffsetX = ((fortWorld.X+16)*fortWorld.Space-950)
--    elseif pCPoint.x < (950/2) then
--        pOffsetX = 0
--    else
--       pOffsetX = pCPoint.x - 950/2
--    end
--   local pOffsetY = 0
--    if pCPoint.y > (fortWorld.ScrollHeight - 480/2) then
--        pOffsetY =  fortWorld.ScrollHeight-480
--    elseif pCPoint.y < (480/2) then
--        pOffsetY = 0
--    else
--       pOffsetY = pCPoint.y - 480/2
--    end

--    self.pScrollView:setInnerContainerPosition(cc.p(-pOffsetX ,-pOffsetY))
--    local pOffset = self.pScrollView:getInnerContainerPosition()

--    self:setDiection(pOffset)
-- end
-- function fortWorld:setCurrent(pBuild)
--    local pCPoint = me.convertToScreenCoord(tmxMap,cc.p(self.mCuPointX,self.mCuPointY))
--    local pCurrnt = me.assignWidget(self,"fort_current"):clone():setVisible(true)
--    pCurrnt:setPosition(cc.p(pCPoint.x/fortWorld.RoadScale-100,pCPoint.y/fortWorld.RoadScale+20))
--    pCurrnt:setLocalZOrder(20)
--    pBuild:addChild(pCurrnt)
--    -- 连接路
--    local pCRPoint = me.convertToScreenCoord(tmxMap,cc.p(user.stageX,user.stageY))
-- --   local pCRPointX,pCRPointY = self:getCurrentPoint(user.stageX,user.stageY)
--    local pRCurrent = me.assignWidget(self,"fort_road_current"):clone():setVisible(true)
--    pRCurrent:setPosition(cc.p(pCRPoint.x/fortWorld.RoadScale-100,pCRPoint.y/fortWorld.RoadScale))
--    pRCurrent:setLocalZOrder(20)
--    pBuild:addChild(pRCurrent)

--    pColor = ccc4FFromccc4B(cc.c4b(216,217,83,255))
--    local dNode =  cc.DrawNode:create()
--    dNode:drawLine(cc.p(pCPoint.x/fortWorld.RoadScale-100,pCPoint.y/fortWorld.RoadScale),cc.p(pCRPoint.x/fortWorld.RoadScale-100,pCRPoint.y/fortWorld.RoadScale),pColor)
--    pBuild:addChild(dNode)
-- end
-- 自己在地图的坐标
-- function fortWorld:getCurrentPoint(X,Y)
--    local function getCInteger(pNum)
--        local pInteger = 0
--        if pNum > 48 then
--           pNum = pNum -49
--           pInteger = 1
--        end
--        pInteger =  math.floor(pNum/50)+pInteger
--        local pRem = pNum%50
--        local pPoint = (pInteger*fortWorld.Space)+(pRem/50)*fortWorld.Space
--        return pPoint
--    end
--    local pCPointX = getCInteger(X)
--    local pCPointY = getCInteger(Y)
--    return pCPointX,pCPointY
-- end
-- 返回左下的要塞坐标
-- function fortWorld:getLeftNextPoint(X,Y)
--    local function getInteger(pNum)
--        pNum = pNum- 49
--        local pInteger = math.floor(pNum/50)
--        local pRem = 0
--        if ((pNum%50)/50) > 0.5 then
--            pRem = 1
--        end
--        local pPoint = (pInteger+pRem)*50+49
--        return pPoint
--    end
--    local pX = (fortWorld.X-1)/2
--    local pY = (fortWorld.Y-1)/2
--    local pPointX = getInteger(X)
--    if (pPointX-49)/50 > (pX-1) then
--        if (pPointX +(pX-1)*50) > 1149 then
--            local pNum = ((fortWorld.X-1) - (1149 - pPointX)/50)
--            pPointX = pPointX- (pNum*50)
--        else
--            pPointX = (pPointX)-(50*pX)
--        end
--     else
--        pPointX = 49
--     end

--    local pPointY = getInteger(Y)
--    if (pPointY-49)/50 > (pY-1) then
--        if (pPointY +(pY-1)*50) > 1149 then
--            local pNum = ((fortWorld.Y-1) - (1149 - pPointY)/50)
--            pPointY = pPointY- (pNum*50)
--        else
--            pPointY = (pPointY)-(50*pY)
--        end
--     else
--        pPointY = 49
--     end
--     return pPointX,pPointY
-- end
function fortWorld:setFortData()

    for key, var in pairs(gameMap.fortDatas) do
        local pCofig = GFortData()[var["id"]]
        var.huan = pCofig["capNpcLv"]
        table.insert(self.pFortOccupy, var)
    end

    local function SortFort(pa, pb)
        return pa.huan > pb.huan
    end
    table.sort(self.pFortOccupy, SortFort)
end
-- 中心点对应的大地图坐标
function fortWorld:getCenter(X, Y)
    X =(X + 100) * fortWorld.RoadScale
    Y = Y * fortWorld.RoadScale
    local pPoint = me.converScreenToTiledCoord(tmxMap, cc.p(X, Y))

    return pPoint
end
-- 相对地图坐标
function fortWorld:getWorld(X, Y)
    local pWorldPoint = me.convertToScreenCoord(tmxMap, cc.p(X, Y))
    local pMapPoint = cc.p(pWorldPoint.x / fortWorld.RoadScale - 100, pWorldPoint.y / fortWorld.RoadScale)
    return pMapPoint
end
function fortWorld:setRoadSign(pOffset)
    local pOffsetLeft = math.abs(pOffset.x)
    local pOffsetRight = 950 + math.abs(pOffset.x)
    local pOffsetUp = 480 + math.abs(pOffset.y)
    local pOffsetNext = math.abs(pOffset.y)
    --  local pOffsetMin = self:getWorld(pOffsetLeft,pOffsetNext)
    --   local pOffsetMax = self:getWorld(pOffsetRight,pOffsetUp)
    local pCupoint = self:getWorld(self.mCuPointX, self.mCuPointY)
    local ret = false
    if (pCupoint.x >= pOffsetLeft) and(pCupoint.x <= pOffsetRight) and
        (pCupoint.y >= pOffsetNext) and(pCupoint.y <= pOffsetUp) then
        ret = true
    end
    if ret == true then
        me.assignWidget(self, "fort_direction"):setVisible(false)
        me.assignWidget(self, "fort_direction_range"):setVisible(false)
    else
        me.assignWidget(self, "fort_direction"):setVisible(true)
        me.assignWidget(self, "fort_direction_range"):setVisible(true)
    end
end
-- 计算距离
function fortWorld:setDiection(pOffset)
    local pOffsetX = 950 / 2 + math.abs(pOffset.x) + 440
    local pOffsetY = 480 / 2 + math.abs(pOffset.y) + 140
    local pCuPoint = self:getCenter(pOffsetX, pOffsetY)

    local pCenter = self:getWorld(pCuPoint.x, pCuPoint.y)
    local pCupoint = self:getWorld(self.mCuPointX, self.mCuPointY)
    local pPoorX = math.abs(pCenter.x - pCupoint.x)
    local pPoorY = math.abs(pCenter.y - pCupoint.y)
    local pDistan = math.sqrt(pPoorX * pPoorX + pPoorY * pPoorY)

    local pAngle = me.getAngleWith2Pos(cc.p(pCenter.x, pCenter.y), cc.p(pCupoint.x, pCupoint.y))
    local pRoadSign = me.assignWidget(self, "fort_direction")
    pRoadSign:setRotation(pAngle)
    print("pAngle = " .. pAngle)
    if pAngle > 180 and pAngle < 271 then
        pAngle = 270 - pAngle
    elseif pAngle > 90 and pAngle < 181 then
        pAngle = pAngle - 180
    elseif pAngle > 360 then
        pAngle = pAngle
    else
        pAngle = 0
    end
    local pRoadRange = me.assignWidget(self, "fort_direction_range")
    pRoadRange:setString(math.floor(pDistan))
    pRoadRange:setRotation(pAngle)
    self:setRoadSign(pOffset)
end
function fortWorld:StagetTab(pInfoTab)
    local iNum = #pInfoTab
    self.miNum = iNum
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pIdx = cell:getIdx()
        local pData = pInfoTab[iNum - pIdx]
        local pPoint = me.getCoordByFortId(me.toNum(pData["id"]))
        -- self:setScrollOffset(pPoint.x,pPoint.y)
        --  self:TableTouch(me.toNum(pData["id"]))
        local pCofig = GFortData()[pData["id"]]
        self:setFortName(pCofig["name"])
        self:setCurrent(cc.p(pPoint.x, pPoint.y))
        self:setInput(pPoint.x, pPoint.y)
        if self.curChooseCell then
            me.assignWidget(self.curChooseCell ,"fort_cell"):loadTexture("ui_wmap_cell.png",me.localType)
        end
        me.assignWidget(cell ,"fort_cell"):loadTexture("ui_wmap_cell_choose.png",me.localType)
        self.curChooseCell = cell
    end
    local function cellSizeForTable(table, idx)
        return 236, 70
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pfortOccupyCell = fortOccupyCell:create(self, "fort_cell")
            pfortOccupyCell:setData(pInfoTab[iNum - idx])
            cell:addChild(pfortOccupyCell)
        else
            local pfortOccupyCell = me.assignWidget(cell, "fort_cell")
            pfortOccupyCell:setData(pInfoTab[iNum - idx])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(236, 578))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Table_Node"):addChild(tableView)
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end
function fortWorld:getCellPoint(pTag, pTabNum)
    pTag = me.toNum(pTag)

    local pPointX = 120
    local pPointY =(pTabNum - pTag + 1) * 84 - 39
    return pPointX, pPointY
end
function fortWorld:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_FORTRESS_FAMILY_INIT) then
        --    dump(gameMap.fortDatas)

    end
    if checkMsg(msg.t, MsgCode.ROLE_MAP_LAND_INFO) then
        local landInfo = landInfoView:create("landInfoView.csb")
        landInfo:initWithData(msg.c.list)
        landInfo:setParent(self)
        self:addChild(landInfo)
        me.showLayer(landInfo, "bg_frame")
    end
end
function fortWorld:onEnter()
    print("fortWorld onEnter")
    me.doLayout(self, me.winSize)
    --   self:setScrollOffset(self.mCuPointX,self.mCuPointY)
    -- self.pScrollView:setInnerContainerPosition(cc.p(-5537 ,-2076))
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function fortWorld:onEnterTransitionDidFinish()
    print("fortWorld onEnterTransitionDidFinish")
end
function fortWorld:onExit()
    print("fortWorld onExit")
    self.schid = nil
    self.meschid = nil
    me.clearTimer(self.pAmintionTime)
    me.clearTimer(self.pMapInforTime)
    me.clearTimer(self.timer)
    UserModel:removeLisener(self.modelkey)
    me.RemoveCustomEvent(self.closeEvent )
    -- 删除消息通知
end
function fortWorld:close()
    print("fortWorld:close()!")
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)
        self.schid = nil
    end
    if self.meschid then
        me.Scheduler:unscheduleScriptEntry(self.meschid)
        self.meschid = nil
    end
    self:setVisible(false)
    self.pBool = false
    me.DelayRun( function()
        self:removeFromParentAndCleanup(true)
    end , 1)
end

function fortWorld:setMaP()

    local pTitldWidth = 70
    local pCPoint2 = me.convertToScreenCoord(tmxMap, cc.p(self.mCuPointX, self.mCuPointY))
    local pCpoint3 = cc.p((pCPoint2.x / fortWorld.RoadScale - 100) / pTitldWidth,(pCPoint2.y / fortWorld.RoadScale) / pTitldWidth)

    self.mTmxMap = ccexp.TMXTiledMap:create("fortmap.tmx")
    self.mTmxMap:setLocalZOrder(10)

    self.mTmxMap:setPosition(cc.p(-80, 15))
    self.mLayerBuild:addChild(self.mTmxMap)
    local cloudLayer = self.mTmxMap:getLayer("cloudLayer")
    self.pId = { 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12, 16 }
    self.pCellData = { }

    local tiledMapPos1 = self:getMapTiledPos(self.mTmxMap, pCpoint3)
    self:setMapPoint(cloudLayer, tiledMapPos1)

    for key, var in pairs(gameMap.sortFortDatas) do
        local pId = var["id"]
        local pData = GFortData()[pId]
        local pFortData = var
        if pFortData ~= nil then
            if pFortData["occ"] ~= -1 then
                local pCPoint = me.convertToScreenCoord(tmxMap, me.getCoordByFortId(pId))
                local pCpoint1 = cc.p((pCPoint.x / fortWorld.RoadScale - 100) / pTitldWidth,(pCPoint.y / fortWorld.RoadScale) / pTitldWidth)
                local tiledMapPos = self:getMapTiledPos(self.mTmxMap, pCpoint1)
                self:setMapPoint(cloudLayer, tiledMapPos)
            end
        end
    end
end
function fortWorld:setMapPoint(cloudLayer, tiledMapPos)
    for x = 1, 4 do
        for y = 1, 3 do
            local px = tiledMapPos.x - 1 - 1
            local py = tiledMapPos.y - 1 - 1
            local pNewX = px + x
            local pNewY = py + y
            local pBool = true
            if y == 1 then
                if x == 1 or x == 4 then
                    pBool = false
                end
            end
            if pBool then
                self:setPos(cloudLayer, cc.p(pNewX, pNewY))
            end

        end
    end
end
function fortWorld:setPos(cloudLayer, tiledMapPos)
    self:changeCloudTiled4(cloudLayer, tiledMapPos)
    self:changeCloudTiled8(cloudLayer, ccp(tiledMapPos.x + 1, tiledMapPos.y))
    self:changeCloudTiled1(cloudLayer, ccp(tiledMapPos.x, tiledMapPos.y + 1))
    self:changeCloudTiled2(cloudLayer, ccp(tiledMapPos.x + 1, tiledMapPos.y + 1))
end
function fortWorld:getCellByTiledPos(pPos)
    local mapSize = self.mTmxMap:getMapSize()
    -- 瓦片坐标原本是二维坐标，转换为一维数值
    local index = 10000 * pPos.x + pPos.y
    local pCell = self.pCellData[index]
    local cell = nil
    if (pCell == nil) then
        -- 如果该瓦片没有顶点数据对象，则创建一个，顶点数据值默认都为0
        cell = fortMapCell:create()
        table.insert(self.pCellData, index, cell)
    else
        cell = pCell
    end
    return cell
end

function fortWorld:getMapTiledPos(map, pos)
    local mapSize = map:getMapSize()
    local tiledSize = map:getTileSize()
    local pSize = map:getContentSize()
    local iMapHeight = mapSize.height * tiledSize.height
    -- pos为笛卡尔坐标系的坐标，所以y轴需要修正
    local x = math.floor(pos.x)
    local y = math.floor((pSize.height / tiledSize.height) - pos.y)
    return cc.p(x, y)
end
function fortWorld:setGidByTotalNum(layer, pos, iTotalNum)
    --    CCSize mapSize = map->getMapSize();

    --    --避免超出范围
    --    if(pos.x < 0 || pos. y < 0
    --        || pos.x >= mapSize.width || pos.y >= mapSize.height) {
    --            return;
    --    }
    -- iTotalNum是瓦片的4个顶点数据值的总和，通过这个值获得对应的瓦片图素
    local gidInt = self.pId[iTotalNum + 1]
    --   print("gggggggggg"..gidInt)
    -- 用新的瓦片图素替换pos坐标上的瓦片图素
    layer:setTileGID(gidInt, pos)
end

function fortWorld:changeCloudTiled4(layer, pos)
    local cell = self:getCellByTiledPos(pos)
    -- 数值4，在瓦片右下角
    cell:setiRightBottom(4)
    -- 根据瓦片4个顶点之和设置地图瓦片的图片
    self:setGidByTotalNum(layer, pos, cell:getiTotalNum())
end

function fortWorld:changeCloudTiled8(layer, pos)
    local cell = self:getCellByTiledPos(pos)
    -- 数值8，在瓦片左下角
    cell:setiLeftBottom(8)
    -- 根据瓦片4个顶点之和设置地图瓦片的图片
    self:setGidByTotalNum(layer, pos, cell:getiTotalNum())
end
function fortWorld:changeCloudTiled1(layer, pos)
    local cell = self:getCellByTiledPos(pos)
    -- 数值1，在瓦片右上角
    cell:setiRightTop(1)
    -- 根据瓦片4个顶点之和设置地图瓦片的图片
    self:setGidByTotalNum(layer, pos, cell:getiTotalNum())
end
function fortWorld:changeCloudTiled2(layer, pos)
    local cell = self:getCellByTiledPos(pos)
    -- 数值2，在瓦片左上角
    cell:setiLeftTop(2)
    -- 根据瓦片4个顶点之和设置地图瓦片的图片
    self:setGidByTotalNum(layer, pos, cell:getiTotalNum())
end
fortMapCell = class("fortMapCell")
fortMapCell.__index = fortMapCell
function fortMapCell:create(...)
    local layer = fortMapCell.new(...)
    if layer then
        if layer:init() then
            return layer
        end
    end
    return nil
end
function fortMapCell:ctor()

end
function fortMapCell:init()
    self.iLeftTop = 0
    -- 左上角
    self.iLeftBottom = 0
    -- 左下角
    self.iRightTop = 0
    -- 右上角
    self.iRightBottom = 0
    -- 右下角
    return true
end
function fortMapCell:setiLeftTop(_iLeftTop)
    self.iLeftTop = _iLeftTop
end

function fortMapCell:getiLeftTop()
    return self.iLeftTop
end

function fortMapCell:setiLeftBottom(_iLeftBottom)
    self.iLeftBottom = _iLeftBottom
end

function fortMapCell:getiLeftBottom()
    return self.iLeftBottom
end

function fortMapCell:setiRightTop(_iRightTop)
    self.iRightTop = _iRightTop
end

function fortMapCell:getiRightTop()
    return self.iRightTop
end

function fortMapCell:setiRightBottom(_iRightBottom)
    self.iRightBottom = _iRightBottom
end

function fortMapCell:getiRightBottom()
    return self.iRightBottom
end
function fortMapCell:getiTotalNum()
    return(self.iLeftTop + self.iLeftBottom + self.iRightTop + self.iRightBottom)
end

