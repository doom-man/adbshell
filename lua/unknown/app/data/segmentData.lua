--[Comment]
--jnmo
segmentData = class("segmentData")
segmentData.__index = segmentData
function segmentData:ctor(id,state)    
    self.id = id
    self.state = state or 0 --0是未连通 1连通     
end

