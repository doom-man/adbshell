armyData = {
    soliderNum=0, --������
    atkTrap=0, --�ݾ�
    totalAtkTrap=0, --�ݾ�����
    toops=0,--����
    totalToops=0, --��������
    desableSoliderNum=0, --�˱�
    totalDesableSoliderNum=0, --�˱�����
    outArmyNum=0,--��ǲ���
    outDisableNum=0,--����˱�
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

