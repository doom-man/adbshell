--jnmo
overLordData = class("overLordData")
overLordData.__index = overLordData

-- 5; -- 自已被沦陷盟友看到的 6;-- 帮会沦陷的人
OVER_LORD_TAG_MINE = 1
OVER_LORD_TAG_FAMILY = 2
OVER_LORD_TAG_ENEMY = 3
OVER_LORD_TAG_FORTRESS = 4
OVER_LORD_TAG_MINE_FAMILY_CAPTIVE = 5
OVER_LORD_TAG_FAMILY_CAPTIVE = 6

PROTECTED_TYPE_COUNT_TIME = -2;-- 免战冷却中
PROTECTED_TYPE_NONE = -1;-- 未保护
PROTECTED_TYPE_NEWPLAYER = 0;-- 新手保护
PROTECTED_TYPE_CAPTIVE = 1;-- 沦陷免战
PROTECTED_TYPE_MINE = 2;-- 主动免战
function overLordData:ctor(var)
    self.name = var.name or ""
    self.uid = var.uid or 0
    self.centerId = var.centerId or 0    -- 主城ID
    self.familyName = var.familyName or nil -- 公会名字
    self.shorName = var.shorName or nil    -- 公会简称
    self.roadLen = var.roadLen or 0
    self.protectedTime = var.protectedTime 
    self.protectedType = var.protectedType 
    self.cityDefense = var.cityDefense
    self.cityMaxDefense = var.cityMaxDefense or 0
    self.cityMasterName = var.cityMasterName or nil
    self.cityMasterState = var.cityMasterState
    self.origin = var.origin or 0 -- 1 跨服主城没有出生，0出生
    self.userType = var.type or -1 -- 区分主城和王座
    self.isInCross = var.isInCross or 0  -- 0 不在跨服 ，1 跨服
    self.camp = var.camp or "" -- 区服
    self.masterCamp = var.masterCamp or nil
end

function overLordData:update(var)
    if type(var) ~= "table" then 
        print("overLordData:update Parameter type error!")
        return
    end
--    print("overLordData:update")
--    dump(var)
    for k, v in pairs(var) do
        if self[k] and k ~= "uid" then 
            self[k] = v
        end
    end
end

--是否保护
function overLordData:isProtected()
   return self.protectedType and self.protectedType >= 0 
end

--是否被沦陷
function overLordData:isCaptived()
   return self.cityMasterName ~= nil
end

function overLordData:getProtectedType()
    return self.protectedType
end