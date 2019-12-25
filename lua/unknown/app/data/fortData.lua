--[Comment]
--jnmo 要塞数据
fortData = class("fortData")
fortData.__index = fortData
function fortData:ctor(id_)
    print("fortData:ctor()")  
    self.id =  id_ --id
    self.occ = -1 -- 状态--1为已经占领 0为可占领 -1 为不可占领 
    self.oType = nil --世界状态
    self.revTime = me.sysTime()  --收到消息的时间 
    self.rPoint = nil --相对坐标
    self.famdata = nil --所属工会   
    self.defense = 1 --当前城防耐久
    self.srcDefense = 1 --总城防耐久
    self.npc = 1 --当前守军波数
    self.srcNpc = 1 --守军总波数
    self.dirGroups = {cc.p(0,1),cc.p(0,-1),cc.p(1,0),cc.p(-1,0)}    
    self:initDefHeroId()
end
function fortData:resetDirGroups()
    self.dirGroups = {cc.p(0,1),cc.p(0,-1),cc.p(1,0),cc.p(-1,0)}
end
function fortData:getOwnFamily()
   return self.famdata
end
function fortData:removeDirGroups(cp)
   local cp = cc.pMul(cp,-1)
   for key, var in pairs(self.dirGroups) do
      if cp.x == var.x and cp.y == var.y then   
           table.remove(self.dirGroups,key)
           break
      end
   end   
end
function fortData:getRelativePoint()
   if self.rPoint == nil then   
     local cp = me.getCoordByFortId(self.id)
     self.rPoint = cc.p(math.floor(cp.x/50),math.floor(cp.y/50))
   end
   return self.rPoint
end
function fortData:getCrood()
   return cc.p( math.floor(self.id / 10000),self.id%10000)
end
function fortData:getDef()
   return GFortData()[self.id]
end
function fortData:initDefHeroId()
   local def =   GFortData()[self.id]
   if self.heroDefId == nil then
       for key, var in pairs(cfg[CfgType.HERO]) do
            if me.toNum(var.herotype) == me.toNum(def.herotype) and  tonumber( var.level) == 1 then
                 self.heroDefId = var.id 
                 break               
            end
       end  
   end
end
