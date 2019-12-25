mAnimation = class("mAnimation", function(aname)   
   return createArmature(aname)
end )
mAnimation.__index = mAnimation
DIR_BOTTOM = 1
DIR_LEFT_BOTTOM = 2
DIR_LEFT = 3
DIR_LEFT_TOP = 4
DIR_TOP = 5
DIR_RIGHT_TOP = 6
DIR_RIGHT = 7
DIR_RIGHT_BOTTOM = 8

MANI_STATE_IDLE = "idle"  --待机
MANI_STATE_MOVE = "move"   --移动
MANI_STATE_BUILD = "build" --建造
MANI_STATE_GATHER = "collect" --采集
MANI_STATE_MINING = "mining" --挖矿
MANI_STATE_PLANT = "plant" --种植
MANI_STATE_WOOD = "wood" --伐木
MANI_STATE_CARRY = "cgold" --搬矿
function mAnimation:ctor()
    print("mAnimation ctor")

    self.direction = DIR_BOTTOM
    self.state = MANI_STATE_IDLE
    self.speed = 50
    self:getAnimation():play("move1")
    self.movePath = nil
end

function mAnimation:playToBeShadow(p_,aName,pDirection)
    self:dirToPoint(p_)
    self.direction = pDirection
    if not aName then
        aName = "move"
    end
    if self.direction == DIR_BOTTOM then
        self:getAnimation():play(aName .. "1")
    elseif self.direction == DIR_LEFT_BOTTOM or self.direction == DIR_RIGHT_BOTTOM then
        self:getAnimation():play(aName .. "2")
    elseif self.direction == DIR_LEFT or self.direction == DIR_RIGHT then
        self:getAnimation():play(aName .. "3")
    elseif self.direction == DIR_LEFT_TOP or self.direction == DIR_RIGHT_TOP then
        self:getAnimation():play(aName .. "4")
    elseif self.direction == DIR_TOP then
        self:getAnimation():play(aName .. "5")
    end
end

function mAnimation:moveToPoint(p_, callfunc, animName_)    
    self:dirToPoint(p_)
    local lp = cc.p(self:getPositionX(), self:getPositionY())
    local dis = cc.pGetDistance(lp, p_)
    local moveto = cc.MoveTo:create(dis / self.speed, p_  )
    local call
    local function endmove(node)
       self:doAction(MANI_STATE_IDLE)
    end
    if callfunc == nil then
        call = cc.CallFunc:create(endmove)
    else    
        call = cc.CallFunc:create(callfunc)
    end
    local seq = cc.Sequence:create(moveto, call)
    self:runAction(seq)
  --  self:getAnimation():setSpeedScale(1)
    self:doAction(animName_ or "move")
end

--function mAnimation:moveToBuilding(obj, callfunc, animName_)
--    local cp = cc.p(obj:getPositionX() + obj.icon:getPositionX(),obj:getPositionY() + obj.icon:getPositionY())
--    self:dirToPoint(cp)
--    local lp = cc.p(self:getPositionX(), self:getPositionY())
--    local dis = cc.pGetDistance(lp, cp)
----    local cosa = (cp.x - lp.x)/dis
----    local sina = (cp.y -lp.y)/dis
----    local disReduce = math.abs(obj.icon:getContentSize().width / 2 / cosa)
----    local disNew = dis - disReduce
----    local p_ = cc.p(lp.x + disNew * cosa, lp.y + disNew * sina)
--    local moveto = cc.MoveTo:create(dis / self.speed, cp)
--    local moveback = cc.MoveTo:create(dis / self.speed, lp)
--    local call
--    local function endmove(node)
--       self:doAction(MANI_STATE_IDLE)
--    end

--    local function readyToBack(node)
--       self:stopAllActions()
--       self:dirToPoint(lp)+
--       self:doAction(animName_ or "move")
--    end

--    callTurn = cc.CallFunc:create(readyToBack)
--    if callfunc == nil then
--        call = cc.CallFunc:create(endmove)
--    else    
--        call = cc.CallFunc:create(callfunc)
--    end
--    local seq = cc.Sequence:create(moveto, callTurn, moveback, call)
--    self:runAction(seq)
--  --  self:getAnimation():setSpeedScale(1)
--    self:doAction(animName_ or "move")

--end

function mAnimation:doAction(aName, dir)
    self.direction = dir or self.direction
    self.state = aName
    if self.direction == DIR_BOTTOM then
        self:setRotationSkewY(0)
        self:getAnimation():play(aName .. "1")
    elseif self.direction == DIR_LEFT_BOTTOM then
        self:setRotationSkewY(0)
        self:getAnimation():play(aName .. "2")
    elseif self.direction == DIR_LEFT then
        self:setRotationSkewY(0)
        self:getAnimation():play(aName .. "3")
    elseif self.direction == DIR_LEFT_TOP then
        self:setRotationSkewY(0)
        self:getAnimation():play(aName .. "4")
    elseif self.direction == DIR_TOP then
        self:setRotationSkewY(0)
        self:getAnimation():play(aName .. "5")
    elseif self.direction == DIR_RIGHT_TOP then
        self:setRotationSkewY(180)
        self:getAnimation():play(aName .. "4")
    elseif self.direction == DIR_RIGHT then
        self:setRotationSkewY(180)
        self:getAnimation():play(aName .. "3")
    elseif self.direction == DIR_RIGHT_BOTTOM then
        self:setRotationSkewY(180)
        self:getAnimation():play(aName .. "2")
    end
end

function mAnimation:setState(s_)
    self.state = s_
end
function mAnimation:dirToPoint(p_)
    local lp = cc.p(self:getPositionX(), self:getPositionY())
    local dis = cc.pGetDistance(lp, p_)
    local a = math.acos((lp.x - p_.x) / dis) * 180 / 3.1415926
    a = math.floor(a)
    if a <= 15 then
        self.direction = DIR_LEFT
    elseif a <= 75 then
        if lp.y < p_.y then
            self.direction = DIR_LEFT_TOP
        else
            self.direction = DIR_LEFT_BOTTOM
        end
    elseif a <= 105 then
        if lp.y < p_.y then
            self.direction = DIR_TOP
        else
            self.direction = DIR_BOTTOM
        end
    elseif a <= 165 then
        if lp.y < p_.y then
            self.direction = DIR_RIGHT_TOP
        else
            self.direction = DIR_RIGHT_BOTTOM
        end
    elseif a <= 180 then
        self.direction = DIR_RIGHT
    end
   -- print("dir = "..self.direction)
end
function mAnimation:getdirection()
     return self.direction
end
--获取方向从一点到另一点
function mAnimation:getDirPTP(p1,p2)
    local lp = p1
    local p_ = p2
    local dis = cc.pGetDistance(lp, p_)
    local a = math.acos((lp.x - p_.x) / dis) * 180 / 3.1415926
  
    a = math.floor(a)
    if a <= 15 then
        return DIR_LEFT
    elseif a <= 75 then
        if lp.y < p_.y then
            return  DIR_LEFT_TOP
        else
            return DIR_LEFT_BOTTOM
        end
    elseif a <= 105 then
        if lp.y < p_.y then
            return DIR_TOP
        else
            return DIR_BOTTOM
        end
    elseif a <= 165 then
        if lp.y < p_.y then
            return DIR_RIGHT_TOP
        else
            return DIR_RIGHT_BOTTOM
        end
    elseif a <= 180 then
        return DIR_RIGHT
    end
end
function mAnimation:init()
   
    return true
end
function mAnimation:onEnter()
   
end
function mAnimation:moveOnPaths(pQueue, callback, needExpedPath_)
    if not Queue.isEmpty(pQueue) then        
        local function arrive(node)
            if not Queue.isEmpty(pQueue) then
                local p_ = Queue.pop(pQueue)
                if Queue.isEmpty(pQueue) then
                    node:moveToPoint(p_, callback)
                else
                    node:moveToPoint(p_, arrive)
                end           
            end
        end
        local p = Queue.pop(pQueue)
        if Queue.isEmpty(pQueue) then
            self:moveToPoint(p, callback)
        else
            self:moveToPoint(p, arrive)
        end  
    end
end

function mAnimation:carryToBuilding(pQueue1, pQueue2, callback, animName_)
    if not Queue.isEmpty(pQueue1) or Queue.isEmpty(pQueue2) then 
        local back       
        local function arrive(node)

            if not Queue.isEmpty(pQueue1) then
                local p_ = Queue.pop(pQueue1)
                if Queue.isEmpty(pQueue1) then
                    node:moveToPoint(p_, back, animName_)
                else
                    node:moveToPoint(p_, arrive, animName_)
                end           
            end
        end
         
         back = function(node)
            if not Queue.isEmpty(pQueue2) then
                local p_ = Queue.pop(pQueue2)
                if Queue.isEmpty(pQueue2) then
                    node:moveToPoint(p_, callback)
                else
                    node:moveToPoint(p_, back)
                end           
            end
        end

        local p = Queue.pop(pQueue1)
        if p and Queue.isEmpty(pQueue1) then
            self:moveToPoint(p, back, animName_)
        elseif p then
            self:moveToPoint(p, arrive, animName_)
        end  
    end
end

function mAnimation:getNearPointInFour(build)
    local p = cc.p(self:getPositionX(), self:getPositionY())
    local groups = { }
    table.insert(groups, build:getLeftPoint())
    table.insert(groups, build:getRightPoint())
    table.insert(groups, build:getBottomPoint())
    table.insert(groups, build:getTopPoint())
    local maxdis = 0
    local key_ = 0
    for key, var in pairs(groups) do
        local dis = cc.pDistanceSQ(var, p)
        if dis > maxdis then
            maxdis = dis
            key_ = key
        end
    end
    return groups[key_]
end
function mAnimation:onExit()
   
end
function mAnimation:fishPaly(aName)
     self:getAnimation():play(aName)
end
