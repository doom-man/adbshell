--[Comment]
--jnmo 世界BOSS数据
bossData = class("bossData")
bossData.__index = bossData
function bossData:ctor(id_,time_,hp_,bosstype,uname)
    print("bossData:ctor()")  
    self.bossId =  id_ --id
    self.bossTime = time_
    self.bossHp = hp_
    self.bossType = bosstype
    self.bossUName = uname
end
function bossData:getDef()
   return cfg[CfgType.BOSS_DATA][self.bossId]
end


