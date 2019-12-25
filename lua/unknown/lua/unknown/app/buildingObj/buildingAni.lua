--建筑动画
--jnmo
buildingAni = class("buildingAni",function (id)
     print("building_"..id)
     return createArmature("building_"..id)
end)
buildingAni.__index = buildingAni
function buildingAni:ctor()
    print("buildingAni:ctor()")   
    self.ani_id = -1     
end
function buildingAni:init()

    return true
end
function buildingAni:getAniID()
    return  self.ani_id
end
function buildingAni:createById(id)
    local m = buildingAni.new(id)
    m.ani_id = id
    if m and m:init() then
        return m
    end
    return nil
end
