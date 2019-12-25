troopMartix = class("troopMartix", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
troopMartix.__index = troopMartix
function troopMartix:create(...)
    local layer = troopMartix.new(...)
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
function troopMartix:ctor()
    print("troopMartix ctor")
    self.path = nil
    self.tagFlag = nil
    self.loadBar = nil
    self.soldierAni = nil
    self.troopId = nil
    self.pathStep = 0
    self.m_OriPoint = nil
end
function troopMartix:init()
    print("troopMartix init")

    return true
end
function troopMartix:getTroopId()
    return self.troopId
end
function troopMartix:setTroopId(troopId_)
    self.troopId = troopId_
end
function troopMartix:getLineData()
    return gameMap.troopData[self.troopId]
end

-- [Comment]
function troopMartix:getOriPoint()
    return self.m_OriPoint
end
function troopMartix:setOriPoint(m_OriPoint_)
    self.m_OriPoint = m_OriPoint_
end
function troopMartix:initTroops_KingTarget()
    local tag = me.convertToScreenCoord(tmxMap, cc.p(user.markKingPos.x,user.markKingPos.y))
    local ori = me.convertToScreenCoord(tmxMap, cc.p(user.markKingPos.ox,user.markKingPos.oy))
    self:setPosition(ori)
    local temp = {}
    temp.ori = cc.p(user.markKingPos.ox,user.markKingPos.oy)
    temp.tag = cc.p(user.markKingPos.x,user.markKingPos.y)
    self.path = expedPath:create(temp,555)
end
function troopMartix:initTroops(tdata)
    if tdata then
        self:setTroopId(tdata:getTroopId())
        self:setOriPoint(tdata:getOriPoint())
        local ofx = 0
        local ofy = 0
        local w = 5
        local h = 10
        local ow = 10
        local btime = tdata.time
        local tag = me.convertToScreenCoord(tmxMap, tdata:getTagPoint())
        local ori = me.convertToScreenCoord(tmxMap, tdata:getOriPoint())
        local skinname = "lord"
        if tonumber(tdata.adornment ) == 0 then
            skinname = "lord"
        else
            local skindata = cfg[CfgType.SKIN_STRENGTHEN][tonumber(tdata.adornment ) or 0]
            if skindata.lord then
                 skinname = skindata.lord
            else
                 skinname = "lord"
            end
        end
        if tdata.uid<0 then  --抵御蛮族
            skinname = "boss_bing_82"
        end
        
        self.soldierAni = mAnimation.new(skinname)
        self.soldierAni:setPosition(cc.p(ofx, ofy))
        self:addChild(self.soldierAni)

        --if tdata.uid<0 then  --抵御蛮族
        --    self.soldierAni:setAnchorPoint(0.3, 0.5)
        --end
        --
        print("-----------------------------" .. tdata.occ)
        self:setPosition(ori)
        self:initFlag(tag)
        self:moveOnPaths(tdata)
        if tdata:getStatus() == TEAM_WAIT or tdata:getStatus() == THRONE_TEAM_WAIT  then
            self.tagFlag:setVisible(false)
            self.soldierAni:setVisible(false)
            self.loadBar:setVisible(false)
            self.path = expedPath:create(tdata:getPaths(), tdata.occ, true)
        elseif tdata:getStatus() == TEAM_ARMY_DEFENS_WAIT or tdata:getStatus() == TEAM_ARMY_WAIT or tdata:getStatus() == THRONE_DEFEND  then
            self.tagFlag:setVisible(false)
            self.soldierAni:setVisible(false)
            self.loadBar:setVisible(false)
        else
            self.path = expedPath:create(tdata:getPaths(), tdata.occ)
        end
    end
end
function troopMartix:getToopPosition()
    local x, y = self:getPosition()
    return cc.p(x, y)
end
function troopMartix:moveOnPaths(data)    
    self:initLoadBar(data, data.time, data.countdown)
    local op = data:getPaths().ori
    local tp = data:getPaths().tag
    local vs = data.speed
    local runtimes =(data.time - data.countdown - ( me.sysTime() - data.createTime )/1000 )
    if op and tp then
        local tag = me.convertToScreenCoord(tmxMap, tp)
        local ori = me.convertToScreenCoord(tmxMap, op)
        local dir = self.soldierAni:getDirPTP(ori, tag)
        self.soldierAni:doAction(MANI_STATE_MOVE, dir)
        -- 计算行军时间
        local t = data.time
        --getMarchTimeTwoPoint(op, tp, vs)
        if t >= runtimes then
            self:stopAllActions()
            local leftTime = t - runtimes
            local a = me.getAngle(ori, tag)
            local dis = cc.pGetDistance(ori, tag)
            local cs = dis * runtimes / t            
            local pos = me.circular(ori, cs, a)
            self:setPosition(pos)
            --release_print("left_dis = "..cc.pGetDistance(pos,tag)," dis =  "..(dis - cs).."  leftTime = "..leftTime )
            local a1 = cc.MoveTo:create(leftTime, tag)   
            self.pathStep = self.pathStep + 1
            self:runAction(a1)
        end
    end
end
function troopMartix:onEnter()
    print("troopMartix onEnter")
end
function troopMartix:initFlag(tag)
    self.tagFlag = createArmature("qizi_1")
    self.tagFlag:getAnimation():playWithIndex(0)
    self.tagFlag:setPosition(tag)
    pWorldMap.unitLayer:addChild(self.tagFlag, me.MAXZORDER + 1)
end
function troopMartix:initLoadBar(data, time, ptime)
    if self.loadBar ~= nil then
        self.loadBar:removeFromParent()
    end
    self.loadBar = expedLoadBar:create("expedLoadBar.csb")
    self.loadBar:initWithTime(data, time, ptime)
    self.loadBar:setPosition(cc.p(self.soldierAni:getPositionX(), self.soldierAni:getPositionY() + 95))
    self:addChild(self.loadBar)
end
function troopMartix:purgeFlag()
    if self.tagFlag then
        self.tagFlag:removeFromParentAndCleanup(true)
    end
    -- self.tagFlag = nil
end
function troopMartix:onEnterTransitionDidFinish()
end
function troopMartix:purge()
    self:stopAllActions()
    self:purgeFlag()
    if self.path and self.path.purge then
        self.path:purge()
    end
    self:removeFromParentAndCleanup(true)
end
function troopMartix:onExit()
    print("troopMartix onExit")


end

