expedPath = class("expedPath")
expedPath.__index = expedPath
function expedPath:ctor()
    print("expedPath:ctor()")
    self.nodes = {}
end
function expedPath:init()

    return true
end
function expedPath:purge()
    local num = 0
    if table.nums(self.nodes) ~= 0 then
        for key, var in pairs(self.nodes) do
            if type(var) == "table" then
                for ikey, ivar in pairs(var) do
                    ivar:stopAllActions()
                    ivar:removeFromParentAndCleanup(true)
                    num = num + 1
                end
            else
                var:stopAllActions()
                var:removeFromParentAndCleanup(true)
                num = num + 1
            end
        end
    end
    if self.pNodes then
        for key, var in pairs(self.pNodes) do
            if type(var) == "table" then
                for ikey, ivar in pairs(var) do
                    ivar:stopAllActions()
                    ivar:removeFromParentAndCleanup(true)
                    num = num + 1
                end
            else
                var:stopAllActions()
                var:removeFromParentAndCleanup(true)
                num = num + 1
            end
        end
    end
    if self.drawNodeTbl then
        for _, v in ipairs(self.drawNodeTbl) do
            v:removeFromParent()
        end
        self.drawNodeTbl=nil
    end    
end

function expedPath:initFarmerPath(path_)
    local index = 0
    if path_ == nil or table.nums(path_) <= 0 then
        return
    end
    while path_[index + 1] do
        local op = path_[index]
        local tp = path_[index + 1]
        local dis = cc.pGetDistance(op, tp)
        local w = 50
        local num = math.floor(dis / 50)
        local a = me.getAngle(op, tp)
        for var = 1, num do
            if self.nodes[index] == nil then
                self.nodes[index] = { }
            end
            self.nodes[index][var] = me.createSprite("waicheng_tubiao_xingjun.png")
            self.nodes[index][var]:setScale(0.5)
            local p = me.circular(op, dis - var * w, a)
            self.nodes[index][var]:setPosition(p)
            self.nodes[index][var]:setRotation(360 - a)
            mainCity.bathNode:addChild(self.nodes[index][var])
            local pN = me.circular(p, w, a)
            local pMoveBy1 = cc.MoveTo:create(1, cc.p(pN.x, pN.y))
            local pMoveBy2 = cc.MoveTo:create(0, cc.p(p.x, p.y))
            self.nodes[index][var]:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1, pMoveBy2)))
        end
        index = index + 1
    end
end
function expedPath:createFarmerPath(farmerPaths)
    local m = expedPath.new()
    if m and m:init() then
        m:initFarmerPath(farmerPaths)
        return m
    end
    return nil
end
function expedPath:drawTriangle(node, p, lp, a, c)
    local px = p.x
    local py = p.y
    local lpx = lp.x
    local lpy = lp.y
    local w = 5
    local s1 = math.tan(math.angle2radian(30)) * w
    local x = px - w * math.cos(math.angle2radian(90 - a))
    local y = py + w * math.sin(math.angle2radian(90 - a))
    local x2 = px + w * math.cos(math.angle2radian(90 - a))
    local y2 = py - w * math.sin(math.angle2radian(90 - a))
    node:drawTriangle(lp, cc.p(x, y), cc.p(x2, y2), cc.c4b(c.r / 255, c.g / 255, c.b / 255, 1))
end
-- 路径 paths = { oir,tag,list}
function expedPath:initPath(paths_)
    if paths_.ori.x == paths_.tag.x and paths_.ori.y == paths_.tag.y then
       return
    end
    local index = 1
    local paths = me.copyTab(paths_.list or { })
    table.insert(paths, 1, paths_.ori)
    table.insert(paths, paths_.tag)
    
    local c = nil
    if self.occ == 1 then
        c = me.convert4Color_("b0ff70")
    elseif self.occ == 0 then
        c = me.convert4Color_("70ffec")
    elseif self.occ == -1 then
        c = me.convert4Color_("fe5353")
        if  SharedDataStorageHelper():getSM() == "sm" then
            c = me.convert4Color_("A919A9")
        end
    elseif self.occ == 555 then --国王目标 的行军颜色专用 
        c = me.convert4Color_("ffa500")
    else
        c = me.convert4Color_("fe5353")
        if  SharedDataStorageHelper():getSM() == "sm" then
            c = me.convert4Color_("A919A9")
        end
    end 
    self.drawNodeTbl = {}
    local mdrawNode = nil
    local drawTotalTimes = 256
    local drawTimes = 0
    local startPos = nil

    while paths[index + 1] do
        local op = me.convertToScreenCoord(tmxMap, paths[index])
        local tp = me.convertToScreenCoord(tmxMap, paths[index + 1])
        if op.x == tp.x and op.y == tp.y then
            return
        end
        local dis = cc.pGetDistance(op, tp)
        local w = 10
        local num = math.floor(dis / w)
        local a = me.getAngle(op, tp)
        for var = 1, num do
            local p = me.circular(op, dis - var * w, a)
            if var % 2 == 0 then
                if drawTimes==0 then
                    startPos = p
                    mdrawNode = cc.DrawNode:create()
                    mdrawNode:setPosition(startPos)
                    pWorldMap.bathNode:addChild(mdrawNode)
                    table.insert(self.drawNodeTbl, mdrawNode)
                end
                drawTimes=drawTimes+1
                if drawTimes>=drawTotalTimes then
                    drawTimes=0
                end

                local lastp = me.circular(op, dis -(var - 1) * w, a)
                lastp = cc.pSub(lastp, startPos)
                p = cc.pSub(p, startPos)
                -- self.mdrawNode:drawDot(p,5,cc.c4b(0,0.5,0,1))
                self:drawTriangle(mdrawNode, p, lastp, a, c)
            end
        end
        index = index + 1
    end
    local pFadeIn = cc.FadeIn:create(2)
    local pFadeOut = cc.FadeOut:create(2)
    if self.plan == true then
        --self.mdrawNode:runAction(cc.RepeatForever:create(cc.Sequence:create(pFadeIn, pFadeOut)))
    end
    
end
function expedPath:create(paths, occ, plan)
    local m = expedPath.new()
    m.occ = me.toNum(occ)
    if plan == nil then
        m.plan = false
    else
        m.plan = plan
    end
    if m and m:init() then
        m:initPath(paths)
        return m
    end
    return nil
end
