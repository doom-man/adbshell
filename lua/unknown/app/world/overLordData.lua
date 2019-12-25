--jnmo
overLordData = class("overLordData")
overLordData.__index = overLordData

-- 5; -- ���ѱ��������ѿ����� 6;-- ������ݵ���
OVER_LORD_TAG_MINE = 1
OVER_LORD_TAG_FAMILY = 2
OVER_LORD_TAG_ENEMY = 3
OVER_LORD_TAG_FORTRESS = 4
OVER_LORD_TAG_MINE_FAMILY_CAPTIVE = 5
OVER_LORD_TAG_FAMILY_CAPTIVE = 6

PROTECTED_TYPE_COUNT_TIME = -2;-- ��ս��ȴ��
PROTECTED_TYPE_NONE = -1;-- δ����
PROTECTED_TYPE_NEWPLAYER = 0;-- ���ֱ���
PROTECTED_TYPE_CAPTIVE = 1;-- ������ս
PROTECTED_TYPE_MINE = 2;-- ������ս
function overLordData:ctor(var)
    self.name = var.name or ""
    self.uid = var.uid or 0
    self.centerId = var.centerId or 0    -- ����ID
    self.familyName = var.familyName or nil -- ��������
    self.shorName = var.shorName or nil    -- ������
    self.roadLen = var.roadLen or 0
    self.protectedTime = var.protectedTime 
    self.protectedType = var.protectedType 
    self.cityDefense = var.cityDefense
    self.cityMaxDefense = var.cityMaxDefense or 0
    self.cityMasterName = var.cityMasterName or nil
    self.cityMasterState = var.cityMasterState
    self.origin = var.origin or 0 -- 1 �������û�г�����0����
    self.userType = var.type or -1 -- �������Ǻ�����
    self.isInCross = var.isInCross or 0  -- 0 ���ڿ�� ��1 ���
    self.camp = var.camp or "" -- ����
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

--�Ƿ񱣻�
function overLordData:isProtected()
   return self.protectedType and self.protectedType >= 0 
end

--�Ƿ�����
function overLordData:isCaptived()
   return self.cityMasterName ~= nil
end

function overLordData:getProtectedType()
    return self.protectedType
end