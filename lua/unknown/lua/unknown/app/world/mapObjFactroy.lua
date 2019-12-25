--jnmo 建筑工厂类
mapObjFactroy = class("mapObjFactroy")
mapObjFactroy.__index = mapObjFactroy
local m_factroy = nil
MAP_OBJ_TYPE_CITY = 1
function mapObjFactroy:ctor()
           
end
function mapObjFactroy:createMapObj(cdata)
    local pointType = cdata.pointType
    if pointType == POINT_CITY then  --主城
        return  mapCityObj:create(cdata:getId())
    elseif pointType == POINT_POST then  --驿站
        return mapPostObj:create(cdata:getId()) 
    elseif pointType == POINT_FORT then --要塞
       return mapFortObj:create(cdata:getId())
    elseif pointType == POINT_THRONE then --王座
        return mapThroneObj:create(cdata:getId())
    elseif pointType == POINT_STRONG_HOLD then --据点
        return mapBastionObj:create(cdata:getId())
    else 
        return mapObj:create(cdata:getId())
    end     
end                   
function mapObjFactroy.getInstance()
	if nil == m_factroy then
	   m_factroy = mapObjFactroy.new()        
	end
    return m_factroy
end
