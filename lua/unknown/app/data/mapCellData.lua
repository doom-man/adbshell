mapCellData = class("mapCellData")
mapCellData.__index = mapCellData
 --0 --未占领  1--敌对占领  2.自己占领 3自己占领非联通 4 同盟 
 --5被沦陷 盟友看到我  6沦陷别人 自己和盟友看到的  7被沦陷 沦陷人和沦陷人的帮派 
OCC_STATE_NONE = 0    
OCC_STATE_HOSTILE = 1
OCC_STATE_OWN = 2
OCC_STATE_OWN_OFF = 3
OCC_STATE_ALLIED = 4
OCC_STATE_CAPTIVE_ALLYED = 5
OCC_STATE_CAPTIVE = 6
OCC_STATE_CAPTIVE_MATSTER_FAMILY = 7

--100 城市 
POINT_CITY=100
--101  驿站
POINT_POST=101
--102 主城地基
POINT_CBASE = 102
--103 要塞
POINT_FORT = 103
--104 要塞地基
POINT_FBASE = 104
--105 王座
POINT_THRONE = 106
--106王座城区
POINT_TBASE = 107

--据点
POINT_STRONG_HOLD = 110

POINT_NORMAL = 0
--地形
POINT_NONE = -1
-- 据点被打掉更新地块
OLD_STRONGHOLD = 1 
function mapCellData:ctor(x,y,type_,ownerId,state,px,py,eventId,etime,data,gtime,pstatus,buffs,origin,cityMasterName,masterCamp,giveup)    
    self.crood =cc.p(x,y) --地图坐标系坐标
    self.pointType = type_ or POINT_NORMAL  --是否是主城
    self.ownerId = ownerId --拥有者id 
    if buffs and #buffs >0 then
        self.buffs = buffs --当前技能buff
        self.sysT = me.sysTime()/1000
    end
    self.eventId = eventId or 0 --事件ID   --事件 0 -- 无事件  >0有事件
    self.etime = etime --如果有事件 事件剩余时间
    if self.eventId > 0 then
        self.estart_time = me.sysTime() --记录系统时间  事件剩余时间 = (self.etime -  (me.sysTime() - self.estart_time))/1000  秒
        self.eventData = data --剩余数量     
    end
    self.occState = state or OCC_STATE_NONE -- 占领状态     0 --  未占领  1 --敌对占领  2 自己占领 3 自己占领非联通 4 同盟      
    
    self.defId = nil --配置数据ID     --配置数据层 0 --无 >0 有配置 
    self.id = nil --逻辑ID
    self.position = nil --屏幕坐标系坐标
    if self.pointType == POINT_FORT then  --只用于驿站
        self.postPos = cc.p(px,py)
    end
    if gtime and pstatus then  --土地放弃倒计时，如果有则正在放弃 1放弃 2保护
        self.gtime = gtime
        self.revTime = me.sysTime()
        self.pstatus = pstatus
    end
    self.bossId = -1 --BOSS数据 如果小于0 则没有BOSS
    self.m_FortId = nil--要塞id
    self.def = nil --配置数据
  --  self.experOpen = experOpen or 0  -- 是否已开启 0:关闭 1：开启 
    self.origin = origin or -1 -- 跨服出生，1 没有出生
    self.cityMasterName = cityMasterName or nil -- 跨服，沦陷信息，用于沦陷王座后的显示
    self.masterCamp = masterCamp or nil -- 区服
    self.giveup = giveup or 0 -- 要塞是否处于放弃
end

function mapCellData:setWagonType(eventWagon)
    self.eventWagon = eventWagon --0普通马车  1豪华马车
end

--获取地图配置事件数据
function mapCellData:getDef()
   if self.def == nil then 
       if user.Cross_Sever_Status == mCross_Sever_Out then 
            self.def = cfg[CfgType.MAP_EVENT_DATA][me.Helper:getMapDataById(me.getIdByCoord(self.crood))]
       elseif user.Cross_Sever_Status == mCross_Sever then 
            
            self.def = cfg[CfgType.MAP_EVENT_DATA][me.toNum(getNetBattleMapDataId(self.crood))]
       end
   end
   return self.def
end
--是否正在考古中
function mapCellData:bHaveArch()
    for key, var in pairs(gameMap.troopData) do       
      if me.toNum(var.m_Status) == EXPED_STATE_ARCHING and var.m_OriPoint.x == self.crood.x and var.m_OriPoint.y ==  self.crood.y then
         return var 
      end
   end    
   return nil
end
--是否正在放弃中
function mapCellData:bHaveDroping()
   if self.gtime and self.pstatus and self.pstatus == 1 then
      return true
   end
   return false
end
--是否免战中
function mapCellData:bHaveProtect()
   if self.gtime and self.gtime > 0 and self.pstatus and self.pstatus == 2 then
      return true
   end
   return false
end
--是否有事件
function mapCellData:bHaveEvent()
   return  self.eventId and self.eventId > 0 
end
--是否有驻扎
function mapCellData:bHaveStation()
   for key, var in pairs(gameMap.troopData) do      
         if (me.toNum(var.m_Status) == EXPED_STATE_STATIONED or me.toNum(var.m_Status) == THRONE_DEFEND)and var.m_OriPoint.x == self.crood.x and var.m_OriPoint.y ==  self.crood.y then
         return var 
        end
   end
   return nil
end
--是否有采集
function mapCellData:bHaveCollecting()
   for key, var in pairs(gameMap.troopData) do
      if me.toNum(var.m_Status) == EXPED_STATE_COLLECTING and var.m_OriPoint.x == self.crood.x and var.m_OriPoint.y ==  self.crood.y then
         return var 
      end
   end    
   return nil
end
--是否有世界BOSS数据
function mapCellData:bHaveBoss()
   return self.bossId > 0 
end
function mapCellData:getBossData()
   if self:bHaveBoss() then
      local id = me.getIdByCoord(self.crood)
      return gameMap.bossDatas[id]
   end
   return nil
end
--获取地块所属状态
function mapCellData:getOccState()
   if  self.pointType == POINT_FORT or self.pointType == POINT_FBASE then
        local fdata = self:getFortData()
        if fdata then
            if fdata.famdata then               
                if fdata.famdata.mine and me.toNum(fdata.famdata.mine) == 1 then
                    self.occState = OCC_STATE_ALLIED
                else
                    self.occState = OCC_STATE_HOSTILE
                end
            end
        end        
   end
   return self.occState
end
function mapCellData:getId()
   self.id = me.getIdByCoord(self.crood)  
   return self.id
end
--获取领主
function mapCellData:getOwnerData()
    return gameMap.overLordDatas[self.ownerId]
end
-- 获取王座
function mapCellData:getCrossThroneData()
    return gameMap.throneDatas[self.ownerId]
end
--获取领主配置
function mapCellData:getEventDef()
   if self.eventId > 0 then
       return cfg[CfgType.MAP_RAND_EVENT_DATA][self.eventId]
   else
      return nil
   end
end
--获取当前事件剩余的时间 
function mapCellData:getEventTime()    
     local ct = me.sysTime()  
     local t =  (self.etime -  (ct - self.estart_time))/1000     
     return t
end
--[Comment]
--所属要塞的坐标
function mapCellData:getFortId()
    if self.pointType == POINT_FBASE or self.pointType == POINT_FORT then
	    return self.m_FortId
    else 
        return nil
    end
end
function mapCellData:setGiveup(giveup)
    self.giveup = giveup
end
function mapCellData:setFortId(m_FortId_)
    print(m_FortId_)
	self.m_FortId = m_FortId_
end
function mapCellData:getFortData()    
    if self.pointType == POINT_FBASE or self.pointType == POINT_FORT then
	    return gameMap.fortDatas[self.m_FortId] --GFortData()[self.m_FortId]
    else 
        return nil
    end 
end
function mapCellData:getThroneData()
     if self.pointType == POINT_THRONE or self.pointType == POINT_TBASE then
	    return gameMap.fortDatas[self.m_FortId] --GFortData()[self.m_FortId]
    else 
        return nil
    end 
end
function mapCellData:getFortDefData()    
    if self.pointType == POINT_FBASE or self.pointType == POINT_FORT then
	    return GFortData()[self.m_FortId]
    else 
        return nil
    end 
end

