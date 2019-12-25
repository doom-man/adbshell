--jnmo 建筑工厂类
buildingFactroy = class("buildingFactroy")
buildingFactroy.__index = buildingFactroy
local m_factroy = nil
function buildingFactroy:ctor()
           
end
function buildingFactroy:createBuilding(bdata)
    local def = bdata:getDef()
    print(" building name "..def.name)
    local kind = def.type
--    if kind == cfg.BUILDING_TYPE_CENTER then
--        return centerBuildingObj:create()
--    else
    if kind == cfg.BUILDING_TYPE_BARRACK or kind == cfg.BUILDING_TYPE_RANGE or kind == cfg.BUILDING_TYPE_HORSE or kind == cfg.BUILDING_TYPE_SIEGE  or kind == cfg.BUILDING_TYPE_WONDER then
        return barrackBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_FOOD then
        return foodBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_STONE then
        return stoneBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_LUMBER then
        return woodBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_BLACKSMITH or kind == cfg.BUILDING_TYPE_COLLEGE or kind == cfg.BUILDING_TYPE_CASTLE  then
        return techBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_DOOR then
        return wallBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_ABBEY then
        return treatBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_HOUSE then
        return houseBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_MARKET then
        return marketBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_TOWER then
         return towerBuildingObj:create()
    elseif kind == cfg.BUILDING_TYPE_MONK then
         return monkBuildingObj:create()
    else
        return buildingObj:create()
    end
end
function buildingFactroy.getInstance()
	if nil == m_factroy then
	   m_factroy = buildingFactroy.new()        
	end
    return m_factroy
end