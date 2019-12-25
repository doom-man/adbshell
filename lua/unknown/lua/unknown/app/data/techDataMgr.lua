techDataMgr = {}

function techDataMgr.clearAllData()
    me.tableClear(user.techTypeDatas)
end

--标记当前科技升级所在的建筑toftid (buildingObj构造函数里的一个变量,类似地基一样的id号)
techDataMgr.curToftid = nil
function techDataMgr.setCurToftid(toftid)
    techDataMgr.curToftid = toftid
end

function techDataMgr.getCurToftid()
    return techDataMgr.curToftid
end

techDataMgr.curbuildId = nil
function techDataMgr.setCurbuildId(buildid)
    techDataMgr.curbuildId = buildid
end

function techDataMgr.getCurbuildId()
    return techDataMgr.curbuildId
end

--得到军旗科技 当前最高等级
function techDataMgr.getConvergeTechDatasInServerData(def_,tmpTechDatas)
    local maxData = nil
    local index = nil
    for key, var in pairs(user.techServerDatas) do
        local tmpDef = var:getDef()
        if me.toNum(def_.techid) == me.toNum(tmpDef.techid) then
            if maxData == nil then
                maxData = var
                index = key
            elseif maxData:getDef().level < tmpDef.level then
                maxData = var
                index = key
            end
        end
    end  
    if maxData then
        user.techTypeDatas[index]=maxData
        print("push  index = "..index)
        return true
    end
    return false
end

--根据建筑类型，组装已开启的科技(若有更高等级的同类型科技，则只添加高等级的科技)
function techDataMgr.setTechTypeUsedDatas(def_)
    if nil == def_ then
        return false
    end
    local techDefId = nil 
    local techingVar = nil --正在升级的科技
    for key, var in pairs(user.techServerDatas) do
        local tmpDef = var:getDef()
        if me.toNum(def_.techid) == me.toNum(tmpDef.techid) then
            if var:getLockStatus() == techData.lockStatus.TECH_TECHING then
                techingVar = var
                techDefId = tmpDef.id
                if me.toNum(tmpDef.level) > 1 then
                    techDefId = techDataMgr.getTechIDByTypeAndLV(tmpDef.techid,tmpDef.level-1)
                end
                break
            end
            if techDefId == nil then
                techDefId = tmpDef.id
--            else
--                local tarDef = cfg[CfgType.TECH_UPDATE][me.toNum(techDefId)]
--                if me.toNum(tarDef.level) < me.toNum(tmpDef.level) then
--                    techDefId = tmpDef.id
--                end
            end
--            techDefId = tmpDef.id
        end
    end

    if techDefId then
--        print("找到已开启科技 : techDefId = "..techDefId)
        local tmpVar = techingVar or user.techServerDatas[techDefId]
        local data = techData.new(me.toNum(techDefId))
        data:setLockStatus(tmpVar:getLockStatus())
        data:setServerInfo(tmpVar:getServerInfo())
        user.techTypeDatas[techDefId]=data
        return true
    else 
        return false 
    end
end

function techDataMgr.getMaxLevelByTechId(techid)
    local maxLv = 0
    for key, var in pairs(cfg[CfgType.TECH_UPDATE]) do
        if me.toNum(techid) == me.toNum(var.techid) and me.toNum(maxLv) < me.toNum(var.level) then
            maxLv = var.level
        end
    end
    return maxLv
end

function techDataMgr.getUseStatusByTypeAndLv_Alliance(techType, techLv)
    for key, var in pairs(user.familyTechServerDatas) do
        if var:getLockStatus() == allianceTechData.lockStatus.TECH_USED then
            local def = var:getDef()
            if def and me.toNum(def.techid) == me.toNum(techType) and me.toNum(def.level) >= me.toNum(techLv) then
                return true
            end
        end
    end
    return false
end

--根据输入type，和等级，去服务器下发的已经开启的所有科技里，查看是否在内
function techDataMgr.getUseStatusByTypeAndLv(techType, techLv)
    for key, var in pairs(user.techServerDatas) do
        if var:getLockStatus() == techData.lockStatus.TECH_FINISH or var:getLockStatus() == techData.lockStatus.TECH_USED then
            local def = cfg[CfgType.TECH_UPDATE][me.toNum(key)]
            if me.toNum(def.techid) == me.toNum(techType) and me.toNum(def.level) >= me.toNum(techLv) then
                return true
            end
        end
    end
    return false
end

--根据升级完成的科技类型，返回可能解锁的科技类型
function techDataMgr.getUnlockedTechID_Alliance(techid,curTechid)
    local techIds = {}
    local function haveTechid(needtekId,tarTechid)
        local lockOps = techDataMgr.splitTechOps(needtekId)
        for key, var in pairs(lockOps) do
            if me.toNum(key) == tarTechid then
                return true
            end
        end
        return false
    end

    for key, var in pairs(cfg[CfgType.TECH_FAMILY]) do
        if me.toNum(var.level) == 1 and haveTechid(var.needtekId,techid) then
            techIds[#techIds+1] = var.techid
        end
    end

    for key, var in pairs(techIds) do
        if me.toNum(var) == me.toNum(curTechid) then
            return true
        end
    end
    return false
end

--根据科技类型，得到服务器下发中的科技id(开启中的)
function techDataMgr.getTechIDByType_Alliance(techType)
    for key, var in pairs(user.familyTechServerDatas) do
        local def = var:getDef()
        if (var:getLockStatus() == allianceTechData.lockStatus.TECH_TECHING or 
        var:getLockStatus() == allianceTechData.lockStatus.TECH_USED ) and 
        me.toNum(def.techid) == me.toNum(techType) then
            return def.id
        end
    end
    return nil
end

--根据输入的type和等级，得到该科技id号
function techDataMgr.getTechIDByTypeAndLV_Alliance(techType,techLv)
    for key, var in pairs(cfg[CfgType.TECH_FAMILY]) do
        if me.toNum(var.techid) == me.toNum(techType) and me.toNum(var.level) == me.toNum(techLv) then
            return var.id
        end
    end
    return nil
end

--根据输入的type和等级，得到该科技id号
function techDataMgr.getTechIDByTypeAndLV(techType,techLv,countryID)
    for key, var in pairs(cfg[CfgType.TECH_UPDATE]) do
        if me.toNum(var.techid) == me.toNum(techType) and me.toNum(var.level) == me.toNum(techLv) then
            if countryID then
                if me.toNum(countryID)== me.toNum(var.countryId)then
                    return var.id
                end
            else
                return var.id
            end
        end
    end
    return nil
end

--切割科技的解锁字段
--格式如下：
--"1001:1, 222:3"
--
-- "<var>" = {
--    " 222" = "3"
--    "1001" = "1"
-- }
function techDataMgr.splitTechOps(str_)
    local ops = {}
    local tab = me.split(str_,",")
    if tab then
       for key, var in pairs(tab) do
           local tmp = me.split(var,":")
           ops[tmp[1]]=tmp[2]
       end
    end
    return ops
end

function techDataMgr.setAndGetTechUnlockDatas()
    local unlockDefIds = {}
    local function compareIdAndLv(lockId_, lockLv_)
        for techKey, techVar in pairs(user.techServerDatas) do

            local def = techVar:getDef()
            if (techVar:getLockStatus() ==  techData.lockStatus.TECH_USED or 
                techVar:getLockStatus() ==  techData.lockStatus.TECH_FINISH) and 
                me.toNum(def.techid) == me.toNum(lockId_) and
                me.toNum(def.level) >= me.toNum(lockLv_) then
                return true    
            end                  
        end  
        return false
    end

    for key, var in pairs(user.techTypeDatas) do
        --如果为nil，则无条件可以解锁
        local status = var:getLockStatus()
        local def = var:getDef()
        local tmpStatus = true 

        if status == techData.lockStatus.TECH_UNUSED then
            if nil == def.needtekId then
                var:setLockStatus(techData.lockStatus.TECH_UNLOCKED)
                unlockDefIds[key]=var
            else
                local lockOps = techDataMgr.splitTechOps(def.needtekId)
                for lockId, locklv in pairs(lockOps) do
                     if compareIdAndLv(lockId, locklv) == false then
                        tmpStatus = false
                        break
                     end
                end

                if tmpStatus then
                    var:setLockStatus(techData.lockStatus.TECH_UNLOCKED)
                    unlockDefIds[key]=var
                end
            end
        end
    end
    return unlockDefIds
end

function techDataMgr.getConvergeTechDatas(buildType_)
    me.tableClear(user.techTypeDatas)
    user.techTypeDatas = {}
    for key, var in pairs(cfg[CfgType.TECH_UPDATE]) do
        if me.toNum(buildType_) == me.toNum(var.type) and me.toNum(user.countryId)== me.toNum(var.countryId) and me.toNum(var.level) == 1 then
            if techDataMgr.getConvergeTechDatasInServerData(var) == false then      
                local dataObj=techData.new(me.toNum(key))
                dataObj:setLockStatus(techData.lockStatus.TECH_UNUSED)
                user.techTypeDatas[key]=dataObj
            end
        end
    end
    return user.techTypeDatas
end

--根据建筑物的Type，去cfg本地配置表读取科技数据集合,组装未开启，和已开启的科技，以及已解锁的科技
 function techDataMgr.getTechTypeDatas(buildType_)
--    for key, var in pairs(user.techServerDatas) do
--        print("t********key = "..key)
--        local def = cfg[CfgType.TECH_UPDATE][me.toNum(key)]
--        print("t********name = "..def.name.."  lv = "..def.level)
--        print("t*********************************************")
--    end
    
    me.tableClear(user.techTypeDatas)
    for key, var in pairs(cfg[CfgType.TECH_UPDATE]) do
        if me.toNum(buildType_) == me.toNum(var.type) and me.toNum(user.countryId)== me.toNum(var.countryId) and me.toNum(var.level) == 1 then
            if techDataMgr.setTechTypeUsedDatas(var) == false then      
                local dataObj=techData.new(me.toNum(key))
                dataObj:setLockStatus(techData.lockStatus.TECH_UNUSED)
                user.techTypeDatas[key]=dataObj
            end
        end
    end
    --设置能解锁的科技
    techDataMgr.setAndGetTechUnlockDatas()
    return user.techTypeDatas
end

--得到解锁的前置节点的id(联盟科技)
function techDataMgr.getPreNodePos_Alliance(techid)
    local posTab = {}
    local tmpID = techDataMgr.getTechIDByTypeAndLV_Alliance(me.toNum(techid),1)    
    local def = cfg[CfgType.TECH_FAMILY][tmpID]
    if def and def.needtekId then
        local tmp = techDataMgr.splitTechOps(def.needtekId)
        for key, var in pairs(tmp) do
            local id = techDataMgr.getTechIDByTypeAndLV_Alliance(me.toNum(key),1)    
            if id then
                table.insert(posTab, id)
            end
        end
    end
    return posTab
end

--得到解锁的前置节点的id
function techDataMgr.getPreNodePos(def)
    local posTab = {}
    if def and def.needtekId then
        local tmp = techDataMgr.splitTechOps(def.needtekId)
        for key, var in pairs(tmp) do
            local id = techDataMgr.getTechIDByTypeAndLV(me.toNum(key),1)    
            if id then
                table.insert(posTab, id)
            end             
        end
    end
    return posTab
end

--根据buidling的Todid获取对应的TechData
function techDataMgr.getTechDataByTofId(index_)
    for key, var in pairs(user.techServerDatas) do
        if me.toNum(var:getTofid()) == me.toNum(index_) then
            return var
        end
    end
end

--根据buidling的Todid获取研究未完成的TechData
function techDataMgr.getTechingTechDataByTofId(index_)
    for key, var in pairs(user.techServerDatas) do
        if me.toNum(var:getTofid()) == me.toNum(index_) and var.lockStatus == techData.lockStatus.TECH_TECHING then
            return var
        end
    end
end

--根据buidling的Todid获取对应的Techid
function techDataMgr.getTechDefByTofId(index_)
    for key, var in pairs(user.techServerDatas) do
        if me.toNum(var:getTofid()) == me.toNum(index_) then
            dump(var)
            return var:getDef()
        end
    end
end

--根据当前工人入住数量算出当前科技升级所需时间
function techDataMgr.getTechUpgradeTime(def_)
    local tofid = techDataMgr.getCurToftid()
    local curWorkers =  user.building[tofid].worker
    local function getUpgradeTime()
        local minworkTime , maxworkTime = def_.time1 , def_.time2
        local tmpBuildDef = user.building[tofid]:getDef()
        local tmpTime = minworkTime - (minworkTime-maxworkTime)/(tmpBuildDef.inmaxfarmer-tmpBuildDef.infarmer)*(curWorkers-tmpBuildDef.infarmer)
        return tmpTime*getTimePercentByPropertyValue("TechTime")
    end
    return getUpgradeTime()
end



-----------------  下面是联盟科技部分 ---------------------------
-- 得到联盟科技默认状态
function techDataMgr.getFamilyTechDefault()
    local defaultData = {}
    for key, var in pairs(cfg[CfgType.TECH_FAMILY]) do
        if me.toNum(var.level) == 1 then
            local dataObj = allianceTechData.new(me.toNum(key))
            defaultData[key]=dataObj
        end
    end
    return defaultData
end

--得到结合已经研究过的联盟科技
function techDataMgr.getFamilyTehcDatas()
    local defaultData = techDataMgr.getFamilyTechDefault()
    local function getServerData(techTypeID)
        for key, var in pairs(user.familyTechServerDatas) do
            local def = var:getDef()
            if me.toNum(techTypeID) == me.toNum(def.techid) then
                return var
            end
        end
        return nil
    end
    for key, var in pairs(defaultData) do
        local def = var:getDef()
        local serDate = getServerData(def.techid)
        if serDate ~= nil then
            local def = serDate:getDef()
            user.familyTechDatas[def.techid] = serDate
        else    
            user.familyTechDatas[def.techid] = var
            techDataMgr.setAndGetTechUnlockDatas_Alliance(key)
        end
    end
    return user.familyTechDatas
end

--得到当前科技类型的最高等级
function techDataMgr.getMaxFamilyTechLevelByTechId(techid)
    local maxLv = 0
    for key, var in pairs(cfg[CfgType.TECH_FAMILY]) do
        if me.toNum(techid) == me.toNum(var.techid) and me.toNum(maxLv) < me.toNum(var.level) then
            maxLv = var.level
        end
    end
    return maxLv
end

--判断科技是否已经解锁
function techDataMgr.setAndGetTechUnlockDatas_Alliance(defId)
    local def = cfg[CfgType.TECH_FAMILY][defId]
    if def == nil then
        __G__TRACKBACK__("defId = nil !!!")
        return
    end
    if def.needtekId == nil then
        user.familyTechDatas[def.techid]:setLockStatus(allianceTechData.lockStatus.TECH_UNLOCKED)
    else
        local tmpTables = techDataMgr.splitTechOps(def.needtekId)
        local open = true
        for key, var in pairs(tmpTables) do
            local id = techDataMgr.getTechIDByType_Alliance(key)
            if id == nil or cfg[CfgType.TECH_FAMILY][id].level < me.toNum(var) then
                open = false
                break
            end
        end
        if open==true then
            user.familyTechDatas[def.techid]:setLockStatus(allianceTechData.lockStatus.TECH_UNLOCKED)
        end
    end
end

--判断该联盟科技是否开启
function techDataMgr.isFamilyTechOpen(defId)
    for key, var in pairs(user.familyTechServerDatas) do
        local status = var:getLockStatus()
        local def = var:getDef()
        if me.toNum(def.id) == me.toNum(defId) and 
        (status == allianceTechData.lockStatus.TECH_USED or status == allianceTechData.lockStatus.TECH_TECHING) then
            return true
        end
    end
    return false
end