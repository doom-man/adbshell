--[Comment]
--jnmo
bastionData = class("bastionData")
bastionData.__index = bastionData
function bastionData:ctor(id,state,name,pos,lv,army,defense,leftTime)
    print("bastionData:ctor()")    
    self.id = id
    self.state = state -- 1 ���� 2 ������ 3����
    self.name = name
    self.lv = lv
    self.pos = pos  
    self.army = army    -- ����
    self.defense = defense  -- �;�  
    self.leftTime = leftTime --�ݵ㽨��/������ʣ��ʱ��
    self.indexTime = me.sysTime()
end
function bastionData:getarmydata()
      local pArmyData = {}  
      for key, var in pairs(self.army) do
        local pDefId = var[1]
        local pNum = var[2]
        if pNum > 0 then
            local soldierData = soldierData.new(pDefId, pNum)            
            pArmyData[pDefId] = soldierData
        end
      end
      return pArmyData
end
--�õ�˳������������������
function bastionData:getSortArmyData()
    local pArmyData = {}  
    for key, var in pairs(self.army) do
    local pDefId = var[1]
    local pNum = var[2]
    if pNum > 0 then
        local soldierData = soldierData.new(pDefId, pNum)            
        pArmyData[#pArmyData+1] = soldierData
    end
    end
    return pArmyData
end
function bastionData:getArmyNum()
    local pNum = 0
    for key, var in pairs(self.army) do
       pNum = pNum + var[2]
    end
    return pNum
end
function bastionData:getDef()
    if user.Cross_Sever_Status == mCross_Sever then
        self.def =  cfg[CfgType.CROSS_STRONG_HOLD][self.lv]
    else
        self.def =  cfg[CfgType.BASTION_DATA][self.lv]
    end
    return self.def
end
function bastionData:init()

    return true
end


