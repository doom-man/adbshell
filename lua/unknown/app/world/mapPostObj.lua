-- jnmo
mapPostObj = class("mapPostObj", mapObj)
mapPostObj.__index = mapPostObj
function mapPostObj:ctor()
    super(self)
    self.roadType = nil
    self.roadPos = nil
end
-- mapCellData.id 主城的id
function mapPostObj:create(id)
    local layer = mapPostObj.new()
    layer.m_id = id
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
function mapPostObj:init()
    superfunc(self, "init")

    return true
end
function mapPostObj:initObj()
    superfunc(self, "initObj")
    local data = self:getCellData()
    if data then
        self:chanageRoad()
        local owner = data:getOwnerData()
        if owner then
            local centerId = owner.centerId
            self.icon:setVisible(true)
            self.nameBg:setVisible(true)
            self.icon:loadTexture(self:getIconById(centerId), me.localType)

            if mMapPost then
                mMapPost = false
                local pMapPost = allAnimation:createAnimation("scene_buildStation")
                pMapPost:MapPostObj()
                pMapPost:setScale(0.7)
                pMapPost:setPosition(cc.p(120,90))                
                self:addChild(pMapPost)
                self.icon:setScale(1.2)
                local pPointX = self.icon:getPositionX()
                local pPointY = self.icon:getPositionY()
                self.icon:setPosition(cc.p(pPointX,pPointY+80))
                local pMoveTo = cc.MoveTo:create(0.3,cc.p(pPointX,pPointY))
                local pSineIn = cc.EaseSineIn:create(pMoveTo)
                local pScaleTo = cc.ScaleTo:create(0.3, 1.0)
                local pSpawn = cc.Spawn:create(pSineIn, pScaleTo)
                self.icon:runAction(pSpawn)
            end         
            local name = ""
            if owner.familyName then
                name = "[" .. owner.familyName .. "]" .. owner.name
            else
                name = owner.name
            end
            self.name:setString(name)
        end
    end
    --self:setLocalZOrder(10)
end
TILED_ROAD_LEFT = 53
TILED_ROAD_TOP = 46
TILED_ROAD_RIGHT = 56
TILED_ROAD_BOTTOM = 42
TILED_RAOD_CROSS = 71
function mapPostObj:chanageRoad()
    local data = self:getCellData()
    if data and data.postPos then
        local crood = data.crood
        local pos = data.postPos
        local gid, _ = pWorldMap.floor:getTileGIDAt(pos)
        self.roadType = gid
        self.roadPos = pos
        if data:getOccState() == OCC_STATE_OWN then
            if crood.x == pos.x - 1 and crood.y == pos.y then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_LEFT), pos)
            elseif crood.x == pos.x + 1 and crood.y == pos.y then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_RIGHT), pos)
            elseif crood.x == pos.x and crood.y == pos.y - 1 then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_BOTTOM), pos)
            elseif crood.x == pos.x and crood.y == pos.y + 1 then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_TOP), pos)
            end
        else
           if crood.x == pos.x - 1 and crood.y == pos.y then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_LEFT), pos)
            elseif crood.x == pos.x + 1 and crood.y == pos.y then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_RIGHT), pos)
            elseif crood.x == pos.x and crood.y == pos.y - 1 then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_BOTTOM), pos)
            elseif crood.x == pos.x and crood.y == pos.y + 1 then
                pWorldMap.floor:setTileGID(getConnectedRoadByGird(TILED_ROAD_TOP), pos)
            end
        end
        print("self.roadType =" .. self.roadType)
    end
end
function mapPostObj:resetRoad()
    print("self.roadType = " .. self.roadType)
    pWorldMap.floor:setTileGID(self.roadType, self.roadPos)
end
function mapPostObj:getIconById(eid)
    local id = math.abs(eid)
    local icon = cfg[CfgType.BUILDING][id].countryId
    return "post_" .. icon .. ".png"
end
function mapPostObj:onEnter()
    superfunc(self, "onEnter")
end
function mapPostObj:onExit()
    superfunc(self, "onExit")
    print("self:resetRoad()")
    self:resetRoad()
end



