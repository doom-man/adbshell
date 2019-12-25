troopLineData = class("troopLineData")
troopLineData.__index = troopLineData
--军队ID，军队出发点，军队目标点，时间
function troopLineData:ctor(troopId,op,tp,time,countdown,status,paths,speed,uid,name,cTotalData,cData,cSpeed,power,shorName,familyName,degree,_archBookTime,hero,leader,teamUid)          
    self.m_TroopId = troopId
    self.m_OriPoint = op
    self.m_TagPoint = tp
    self.m_Status = status
    if EXPED_STATE_COLLECTING == self.m_Status then
        self.cTotalData = cTotalData
        self.cSpeed = cSpeed
        self.cData = cData
    elseif THRONE_DEFEND == self.m_Status then -- 王座集火驻扎
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP then
            self.m_Throne_OriPoint = cc.p(600,600)
        end      
    end
    self.revTime = me.sysTime()
    self.time = time
    self.uid = uid
    self.name = name
    self.countdown = countdown
    if _archBookTime then
        self.archBookTime = _archBookTime/1000 --考古每次时间 
    end
    self.speed = speed 
    --所经过的路径点
    local path = {}
    path.ori = op
    path.tag = tp
    path.list = paths   
    self.m_Paths = path   
    self.power = power 
    self.shorName = shorName 
    self.familyName = familyName
    self.degree = degree
    self.hero = hero
    self.leader = leader or 0
    self.teamUid = teamUid -- 援助记录
    self.queueTag = -1 -- 自己的队列标记
    self.createTime = me.sysTime()
end

--军队状态  --41 探索  42出征 43驻扎 40 回城
function troopLineData:getStatus()
	return self.m_Status
end
function troopLineData:setStatus(m_Status_)
	self.m_Status = m_Status_
end

function troopLineData:getPaths()
	return self.m_Paths
end
function troopLineData:setPaths(m_Paths_)
	self.m_Paths = m_Paths_
end

--目标点
function troopLineData:getTagPoint()
	return self.m_TagPoint
end
function troopLineData:setTagPoint(m_TagPoint_)
	self.m_TagPoint = m_TagPoint_
end
--军队触发点
function troopLineData:getOriPoint()
	return self.m_OriPoint
end
function troopLineData:setOriPoint(m_OriPoint_)
	self.m_OriPoint = m_OriPoint_
end
--军队ID
function troopLineData:getTroopId()
	return self.m_TroopId
end
function troopLineData:setTroopId(m_TroopId_)
	self.m_TroopId = m_TroopId_
end


