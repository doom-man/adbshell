armyData = {
    soliderNum=0, --部分数
    atkTrap=0, --陷井
    totalAtkTrap=0, --陷井上限
    toops=0,--队列
    totalToops=0, --队列上限
    desableSoliderNum=0, --伤兵
    totalDesableSoliderNum=0, --伤兵上限
    outArmyNum=0,--外城部队
    outDisableNum=0,--外城伤兵
}
 
function armyData.sortSoldierData()
    local sortTmpData = {}

    for key, var in pairs(user.soldierData) do
        sortTmpData[#sortTmpData+1] = var
    end
    
    local function sortFunc(a,b)
        if me.toNum(a:getDef().id) > me.toNum(b:getDef().id) then
            return true
        end
        return false
    end
    table.sort(sortTmpData,sortFunc)

    local sortData = {}
    for key, var in pairs(sortTmpData) do
        local def = var:getDef()
        if sortData[def.bigType] == nil then
            sortData[def.bigType] = {}
        end
        sortData[def.bigType][def.id] = var
    end
    return sortData    
end

