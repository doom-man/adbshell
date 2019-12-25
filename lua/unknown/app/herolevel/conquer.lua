--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local TileData = class("TileData")
function TileData:ctor()
    self.isAbleBattle = false
    self.baseData = nil
    self.level=0
    self.posi=0
end


--endregion
conquer = class("conquer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
conquer.__index = conquer
local Conquer_Tile_Pos = {
    [1]={36.25, 26.10},
    [2]={168.83,87.80},
    [3]={295.56, 151.18},
    [4]={425.80, 217.22},
    [5]={556.53, 281.26},
    [6]={687.53, 347.26},
    [7]={809.01, 412.58},
    [0]={-92.47, -38.74},
    [-1]={-221.47, -104.74},
}

function conquer:create(...)
    local layer = conquer.new(...)
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

function conquer:ctor()
    --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)
    end)
end

function conquer:initTile()
    self.tileQueue = Queue.new()
    local tilePanel = self.tile_panel:clone():setVisible(true)  
    self.clipingNode:addChild(tilePanel)
    for j=1, 3 do
        local tile = me.assignWidget(tilePanel, "tile"..j)
        me.assignWidget(tile, "battle"):setLocalZOrder(3)
        tile.tileData = TileData.new()
        tile:loadTexture("herolevel_conquer_tile1.png", me.localType)
        tile:loadNormalTransparentInfoFromFile()
        me.registGuiClickEvent(tile, handler(self, self.onClickTile))
        --me.registGuiTouchEvent(tile, handler(self, self.onClickTile))
    end
    tilePanel:setPosition(Conquer_Tile_Pos[0][1]-624.08+247/4, Conquer_Tile_Pos[0][2]-307.17+124/4)
    Queue.push(self.tileQueue, tilePanel)   --self.tileQueue index=0

    for i=1, 6 do
        local tilePanel = self.tile_panel:clone():setVisible(true)
        tilePanel:setPosition(Conquer_Tile_Pos[i][1]-624.08+247/4, Conquer_Tile_Pos[i][2]-307.17+124/4)
        me.assignWidget(tilePanel, "levelTxt"):setString(i)
        me.assignWidget(tilePanel, "Text_1"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        me.assignWidget(tilePanel, "levelTxt"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        me.assignWidget(tilePanel, "levelTxt1"):enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        for j=1, 3 do
            local tile = me.assignWidget(tilePanel, "tile"..j)
            me.assignWidget(tile, "battle"):setLocalZOrder(3)
            tile.tileData = TileData.new()
            tile:loadTexture("herolevel_conquer_tile1.png", me.localType)
            tile:loadNormalTransparentInfoFromFile()
            me.registGuiClickEvent(tile, handler(self, self.onClickTile))
            --me.registGuiTouchEvent(tile, handler(self, self.onClickTile))
        end
        self.clipingNode:addChild(tilePanel)
        Queue.push(self.tileQueue, tilePanel)
    end
end

function conquer:onClickTile(node)
    local function continue(str)
        if str=="ok" then
            local conquerPanel = conquerConfirm:create("herolevel/conquerConfirm.csb")
            conquerPanel:setData(node.tileData, self.initData.isWin, self.initData.revert, self.initData.revertGem)
            self.nowPosi = node.tileData.posi
            mainCity:addChild(conquerPanel, me.MAXZORDER)        
            me.showLayer(conquerPanel,"bg")
        end
    end
    if node.tileData.isAbleBattle==true then
        if self.battleResult~=nil then
            showTips("等待战斗完成")
            return
        end

        continue('ok')
    else
        if node.tileData.level>self.initData.currentLv then  --当前关卡之后的格子
            showTips("前置关卡未通过")
        else   --当前关卡之前的格子

        end
    end
end
function conquer:onClickTile1(node, event)
    if event == ccui.TouchEventType.began then
        self.bclicked = true
        node:setSwallowTouches(false)
    elseif event == ccui.TouchEventType.moved then
        local mp = node:getTouchMovePosition()
        local sp = node:getTouchBeganPosition()
        if math.abs(mp.x - sp.x) < 5 and math.abs(mp.y - sp.y) < 5 then
            node:setSwallowTouches(true)
            self.bclicked = true
        else
            node:setSwallowTouches(false)
            self.bclicked = false
        end
    elseif event == ccui.TouchEventType.ended then
        if self.bclicked then
            print(node:getTag())
            node:setSwallowTouches(true)
        end
     elseif event == ccui.TouchEventType.canceled then
        node:setSwallowTouches(false)
     end

end

function conquer:init()
    self.tile_panel = me.assignWidget(self, "tile_panel")

    local maskNode = cc.Node:create()
    local stencil = cc.Sprite:create("herolevel_conquer_mask.png")
    maskNode:addChild(stencil)

    self.clipingNode = cc.ClippingNode:create(maskNode)
    self.clipingNode:setAlphaThreshold(0)
    self.clipingNode:setPosition(624.08, 307.17)
    me.assignWidget(self, "clipingNode"):addChild(self.clipingNode)

    local data = user.building[4001]
    self.icon = me.assignWidget(self, "icon")
    self.icon:loadTexture(buildIcon(data.def), me.plistType)
    self.icon:setVisible(true)
    me.resizeImage(self.icon,217,169)


    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)

    self.saodangBtn = me.registGuiClickEventByName(self, "saodangBtn", function(node)
        local function continue(str)
            if str=="ok" then
                showWaitLayer()
                NetMan:send(_MSG.HeroLevel_saodang())
            end
        end
        if self.battleResult~=nil then
            showTips("等待当前战斗完成")
            return
        end
        if self.initData.cleanAble==true then
            me.showMessageDialog("是否快速扫荡？", continue)
        elseif user.currentPower==0 then
            showTips("体力不足无法扫荡")
        else
            showTips("当前已在最高关卡无法扫荡")
        end
    end)
    
    self.reportBtn = me.registGuiClickEventByName(self, "reportBtn", function(node)
        local mailview = mailview:create("mailview.csb",8,1)
        me.runningScene():addChild(mailview, me.MAXZORDER);
        me.showLayer(mailview, "bg_frame")
        mainCity.mailview = mailview
    end)

    self:initTile()
    self.pathNode = cc.Node:create()
    self.clipingNode:addChild(self.pathNode)

    self.soldierAni = mAnimation.new("lord")
    self.soldierAniNode=me.assignWidget(self, "soldierAniNode")
    self.soldierAniNode:addChild(self.soldierAni)
    self.soldierAniNode:setVisible(false)

    if user.vip>=5 and user.vipTime > 0 then
        me.assignWidget(self, "vipTips"):setTextColor(cc.c3b(0x97, 0xe9, 0x49))
    else
        me.assignWidget(self, "vipTips"):setTextColor(cc.c3b(0xf2, 0x4f, 0x4a))
    end

    me.assignWidget(self, "powerTxt"):setString(user.currentPower.."/"..getUserMaxPower())


    me.registGuiClickEventByName(self, "powerBtn", function(node)
        local powerShop = vipShopView:create("vipShopView.csb")
        powerShop:initCost()
        me.runningScene():addChild(powerShop)
        me.showLayer(powerShop, "bg")
    end )
    --[[
    local tile = me.assignWidget(self.tileQueue[3], "tile3")
    local targetpos = me.assignWidget(self, "bg"):convertToNodeSpace(self.tileQueue[3]:convertToWorldSpace(cc.p(tile:getPosition())))
    targetpos = cc.p(targetpos.x-40,targetpos.y+5)
    
    local sp = cc.Sprite:create("herolevel_conquer_ico1.png")
    me.assignWidget(self, "bg"):addChild(sp)
    sp:setPosition(cc.p(targetpos))
    ]]

    return true
end

----
-- tilePanel--关卡面板
-- level  第几关
-- posi   哪一路
-- baseData 关卡当前路基础数据
-- isAbleBattle 是否可以战斗
--
function conquer:setTilePanelData(tilePanel, level, posi, baseData, isAbleBattle)
    local levelTxt = me.assignWidget(tilePanel, "levelTxt")
    levelTxt:setString(level)
    me.assignWidget(tilePanel, "levelTxt1"):setPositionX(levelTxt:getPositionX()+levelTxt:getContentSize().width+15)
    local tile = me.assignWidget(tilePanel, "tile"..posi)
    tile:removeChildByName('soldierAni')

    local battleFlag = me.assignWidget(tile, "battle")
    if baseData==nil then
        tile:loadTexture("herolevel_conquer_tile3.png", me.localType)
        me.assignWidget(tile, "yingdi"):setVisible(false)
        me.assignWidget(tile, "flag"):setVisible(false)
        battleFlag:setVisible(false)
        tile.tileData.isAbleBattle=false
    else
        if isAbleBattle==true then
            battleFlag:setVisible(true)
        else
            battleFlag:setVisible(false)
        end

        if level==self.initData.currentLv and posi == self.initData.currentPosi then
            me.assignWidget(tile, "yingdi"):setVisible(true)
        else
            me.assignWidget(tile, "yingdi"):setVisible(false)
        end
        
        if self.initData.history[tostring(level)] and self.initData.history[tostring(level)][posi]>0 then
            me.assignWidget(tile, "flag"):setVisible(true)
        else
            me.assignWidget(tile, "flag"):setVisible(false)
        end

        tile.tileData.baseData=baseData
        tile.tileData.isAbleBattle=isAbleBattle
        tile.tileData.level=level
        tile.tileData.posi=posi

        local npc = string.split(baseData.npc, ":")
        local sani = soldierMoudle:createSoldierById(tonumber(npc[1]))
        sani:doAction(MANI_STATE_IDLE,DIR_LEFT_BOTTOM)
        sani:getAnimation():setSpeedScale(0.5)
        sani:setPosition(247/2, 124/2-26)

        ------------------ 如果是战象模型 -----------------
        local sdata = user.soldierData[tonumber(npc[1])]
        local iconId = nil
        if sdata then
            iconId = sdata:getDef().icon
        else
            iconId = cfg[CfgType.CFG_SOLDIER][tonumber(npc[1])].icon
        end
        if iconId and tostring(iconId) == "3101" then
            sani:setPosition(100, 95)
        end
        ---------------------------------------------------
        sani:setName("soldierAni")
        sani:setLocalZOrder(1)
        tile:addChild(sani)

        if level<=self.initData.currentLv then
            if  self.initData.history[tostring(level)][posi]==2 then
                tile:loadTexture("herolevel_conquer_tile1.png", me.localType)  --已打过，绿色显示
            else
                tile:loadTexture("herolevel_conquer_tile2.png", me.localType)
                sani:setVisible(false)
            end
        else
            tile:loadTexture("herolevel_conquer_tile2.png", me.localType)
        end
    end

    
end


----
-- data.history={1={0, 1, 2]}每路数据状态  0从没打开 1昨天打过  2当天打过
--
function conquer:setData(data)
    self.initData = data
    local nowLv = data.currentLv
    local nowPosi = data.currentPosi
    local maxLv = data.max
    me.assignWidget(self, "maxLevel"):setString(maxLv)
    me.assignWidget(self, "reliveTimes"):setString(data.revert)


    local startLv = 1
    local endLv = 5
    if nowLv<4 then
        startLv=1
    elseif nowLv>3 then
        startLv=nowLv-2
    end
    endLv = startLv+4
    local tmax = #user.herolevelCfg
    if endLv>tmax then
        endLv=tmax
        startLv=endLv-4
    end

    self.nowTileIndex=self.tileQueue.first
    local count=self.tileQueue.first+1
    for i=startLv, endLv do
        if i==nowLv then
            self.nowTileIndex=count
        end

        local lvData = user.herolevelCfg[i]
        for j=1, 3 do
            local panel = self.tileQueue[count]
            self:setTilePanelData(panel, i, j, lvData[j], nowLv+1==i)
        end
        count=count+1
    end

end


---
-- 显示战斗结果
--
function conquer:showBattleResult(targetpos)
    
    local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
    if self.battleResult.isWin==true then
        pCityCommon:CommonSpecific(ALL_COMMON_VICTORY)
    else
        pCityCommon:CommonSpecific(ALL_COMMON_FAILURE)
    end
    pCityCommon:setPosition(targetpos.x, targetpos.y)
    me.assignWidget(self, "bg"):addChild(pCityCommon, me.MAXZORDER)

    if self.battleResult.isWin==true then
        local nowLv = self.initData.currentLv
        local nowPosi = self.initData.currentPosi

        local startLv = nowLv
        local endLv = 5
        if startLv<1 then
            startLv=1
        end
        endLv = startLv+2
        local tmax = #user.herolevelCfg
        if endLv>tmax then
            endLv=tmax
        end

        local history = self.initData.history
        for k, v in pairs(self.battleResult.history) do
            history[k]=v
        end
        self.battleResult.history = history
        self.initData = self.battleResult

        nowLv = self.initData.currentLv

        me.assignWidget(self, "maxLevel"):setString(self.initData.max)
        me.assignWidget(self, "reliveTimes"):setString(self.initData.revert)

        local count=self.nowTileIndex
        if count<1 then count=1 end
        self.nowTileIndex=self.nowTileIndex+1
        for i=startLv, endLv do
            local lvData = user.herolevelCfg[i]
            for j=1, 3 do
                local panel = self.tileQueue[count]
                self:setTilePanelData(panel, i, j, lvData[j], nowLv+1==i)
            end
            count=count+1
        end

        if self.initData.currentLv+2<=tmax and self.initData.currentLv>3 then
            self:scrollToNextLine(self.initData.currentLv+2)
        elseif self.initData.currentLv==tmax then
            me.showMessageDialog("后续关卡暂未开放", nil, 1)
        end

        self.battleResult=nil
        
        local tmp={}
        for i, v in ipairs(self.initData.ItemList) do
            tmp[#tmp + 1] = { }
            tmp[#tmp]["defId"] = v[1]
            tmp[#tmp]["itemNum"] = v[2]
            tmp[#tmp]["needColorLayer"] = true
        end 
        self.initData.ItemList=nil
        if #tmp>0 then
            getItemAnim(tmp)
        end

        --[[
        if self.initData.cleanAble==true then
            self.saodangBtn:setSwallowTouches(true)
            self.saodangBtn:setTouchEnabled(true)
            self.saodangBtn:setBright(true)
            me.Helper:normalImageView(me.assignWidget(self.saodangBtn, "saodangIco")) 
        else
            self.saodangBtn:setSwallowTouches(true)
            self.saodangBtn:setTouchEnabled(false)
            self.saodangBtn:setBright(false)
            me.Helper:grayImageView(me.assignWidget(self.saodangBtn, "saodangIco")) 
        end
        --]]
    else
        self.initData.isWin=false
        self.initData.revert=self.battleResult.revert
        self.initData.revertGem=self.battleResult.revertGem
        self.battleResult=nil
    end
end

---
-- 播放战斗动画
--
function conquer:playBattleAnim(targetpos)
    if self.battleAnim==nil then
        self.battleAnim = battleAni:create("battle_fight")
        me.assignWidget(self, "bg"):addChild(self.battleAnim, me.MAXZORDER)
    end
    self.battleAnim:setPosition(targetpos.x, targetpos.y)
    self.battleAnim:setVisible(true)
    self.battleAnim:playAni()
    me.DelayRun(function ()
        self.battleAnim:setVisible(false)
        self:showBattleResult(targetpos)
    end,2, self)
end

---
-- 行军
--
function conquer:march(targetTileIndex, posi)
    local nowLv = self.initData.currentLv
    local nowPosi = self.initData.currentPosi

    local startPos = nil
    if nowLv==0 then
        startPos = cc.p(self.soldierAniNode:getPosition())
    else
        local tile = me.assignWidget(self.tileQueue[self.nowTileIndex], "tile"..nowPosi)
        startPos = me.assignWidget(self, "bg"):convertToNodeSpace(self.tileQueue[self.nowTileIndex]:convertToWorldSpace(cc.p(tile:getPosition())))
        startPos = cc.p(startPos.x-40,startPos.y+5)
    end

    local tile = me.assignWidget(self.tileQueue[targetTileIndex], "tile"..posi)
    local targetpos = me.assignWidget(self, "bg"):convertToNodeSpace(self.tileQueue[targetTileIndex]:convertToWorldSpace(cc.p(tile:getPosition())))
    targetpos = cc.p(targetpos.x,targetpos.y)


    local dir = self.soldierAni:getDirPTP(startPos, targetpos)
    self.soldierAniNode:setVisible(true)
    self.soldierAniNode:setPosition(startPos.x, startPos.y)
    self.soldierAni:doAction(MANI_STATE_MOVE, dir)

    self.soldierAniNode:stopAllActions()
    local a1 = cc.MoveTo:create(2.5, targetpos)
    local callc = cc.CallFunc:create(function() 
        self.soldierAniNode:setVisible(false)
        self:removePath()
        self:playBattleAnim(targetpos)
    end)
    local seq = cc.Sequence:create(a1, callc)
    self.soldierAniNode:runAction(seq)
    self:createPath({startPos, targetpos})
end


function conquer:removePath()
    for key, var in pairs(self.pathNodes) do
        var:removeFromParentAndCleanup(true)
    end
end

function conquer:createPath(path_)
    local op = path_[1]
    local tp = path_[2]
    local dis = cc.pGetDistance(op, tp)
    local w = 50
    local num = math.floor(dis / 50)
    local a = me.getAngle(op, tp)
    self.pathNodes = { }
    for var = 1, num do
        self.pathNodes[var] = me.createSprite("waicheng_tubiao_xingjun.png")
        self.pathNodes[var]:setScale(0.5)
        local p = me.circular(op, dis - var * w, a)
        self.pathNodes[var]:setPosition(p)
        self.pathNodes[var]:setRotation(360 - a)
        me.assignWidget(self, "nodePathUI"):addChild(self.pathNodes[var])
    end
end



function conquer:scrollToNextLine(newLv)
    local lvData = user.herolevelCfg[newLv] 
    for j=1, 3 do
        local panel = self.tileQueue[self.tileQueue.last]
        self:setTilePanelData(panel, newLv, j, lvData[j], false)--显示出来的新关卡数据
    end

    for index=self.tileQueue.first+1, self.tileQueue.last do
        local panel = self.tileQueue[index]
        panel:stopAllActions()

        local i = index-self.tileQueue.first
        local moveAct = cc.MoveTo:create(0.5, cc.p(Conquer_Tile_Pos[i-1][1]-624.08+247/4, Conquer_Tile_Pos[i-1][2]-307.17+124/4))
        if index==self.tileQueue.first+1 then
            local cSequence = cc.Sequence:create(moveAct, cc.CallFunc:create(function() 
                local panel = Queue.pop(self.tileQueue)
                local i = self.tileQueue.last-self.tileQueue.first+1
                panel:setPosition(Conquer_Tile_Pos[i][1]-624.08+247/4, Conquer_Tile_Pos[i][2]-307.17+124/4)
                Queue.push(self.tileQueue, panel)
            end))
            panel:runAction(cSequence)
        else
            panel:runAction(moveAct)
        end


    end

end


function conquer:onEnter()
    
    me.doLayout(self,me.winSize)
end

function conquer:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_HEROLEVEL_CONQUER_RESULT) then
        self.battleResult = msg.c
        me.assignWidget(self, "reliveTimes"):setString(self.battleResult.revert)
        if self.battleResult.isWin==true then
            self:march(self.nowTileIndex+1, self.battleResult.currentPosi)
        else
            self:march(self.nowTileIndex+1, self.nowPosi)
        end
        print(msg)
    elseif checkMsg(msg.t, MsgCode.MSG_HEROLEVEL_SAODANG_RESULT) then
        disWaitLayer()

        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_HEROLEVEL_SAODANG)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2+50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)

        local sdResult = saodangResult:create("herolevel/saodangResult.csb")
        sdResult:setData(msg.c)
        msg.c.itemList=nil
        mainCity:addChild(sdResult, me.MAXZORDER)        
        me.showLayer(sdResult,"bg")
        self:setData(msg.c)
    elseif checkMsg(msg.t, MsgCode.ROLE_POWER_UPDATE) then
        me.assignWidget(self, "powerTxt"):setString(user.currentPower.."/"..getUserMaxPower())
    elseif checkMsg(msg.t, MsgCode.MSG_HEROLEVEL_RESET) then
        me.showMessageDialog("每日重置成功", function(str) 
                if str=="ok" then
                    me.DelayRun(function (args)
                       self:close()
                    end)
                end
            end, 1)
    end
end
function conquer:onExit()
    print("conquer:onExit()")
    self.battleResult=nil
    self.soldierAniNode:stopAllActions()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知

    NetMan:send(_MSG.HeroLevel_indexdata()) --更新首页数据
end
function conquer:close()
    self:removeFromParentAndCleanup(true)
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end

