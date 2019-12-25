mapLayer = class("mapLayer ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
mapLayer.__index = mapLayer 
function mapLayer:create(csb)
    local layer = mapLayer.new(csb)
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
function mapLayer:ctor()
    print("mapLayer ctor")
end
local distance;
local deltaX;
local deltaY;
local mscale = 1;
local firsttouch = true;

-- 滑动助力
local lastMove = nil;
local DIS_MIN = 5;
local sid = nil
local mCamera = nil
local scale = 100
local IMG_WIDTH = 1120
local IMG_HEIGHT = 1120
local SPEED = 2048
local bCLICKed = true
local startP = nil
function mapLayer:init()
    print("mapLayer init")
    self.mNode = me.assignWidget(self, "mNode")
    
    local str = "neicheng_1_"
    for i = 1,9 do 
      if cc.FileUtils:getInstance():isFileExist(str..i..".png") then 
        me.assignWidget(self,"m"..i):loadTexture(str..i..".png",me.localType)
      else
        me.assignWidget(self,"m"..i):loadTexture(str..i..".pvr.ccz",me.localType)
      end
    end
    
    local function autoMoveMap()
        if lastMove then
            if (math.abs(lastMove.x) <= 2 and math.abs(lastMove.y) <= 2) then
                local px, py = self.mNode:getPosition();
                self.mNode:setPosition(cc.p(px + lastMove.x, py + lastMove.y));
                self:checkPosition(self.mNode, lastMove, lastMove)
                if sid then
                    me.Scheduler:unscheduleScriptEntry(sid)
                end
                lastMove = nil;
                return;
            end
            local px, py = self.mNode:getPosition();
            local moveX = lastMove.x / 1.2;
            local moveY = lastMove.y / 1.2;
            self:checkPosition(self.mNode, cc.p(moveX, moveY), lastMove)
        end
    end

    local function onTouchBegin(touch, event)
        firsttouch = true;
        bCLICKed = true
        startP = touch[1]:getLocation()
        if sid then
            me.Scheduler:unscheduleScriptEntry(sid)
        end
        -- 点击特效
        local cItem = cc.ParticleSystemQuad:create("click.plist")
        cItem:setPosition(self:convertToNodeSpace(startP))
        self:addChild(cItem)
        local function arrive(node)
            node:removeFromParentAndCleanup(true)
        end
        local callback = cc.CallFunc:create(arrive)
        cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1), callback))
        return true;
    end

    local function onTouchMove(touch, event)
        if guideHelper.getGuideIndex() ~= guideHelper.guide_End and guideHelper.guideNeed == true then --如果在引导阶段，不能滑动地图
            return
        end

        if (#touch == 1) then
            -- single touch
            -- 重置标志位 防止开始用户使用2个手指缩放
            -- 松开一个手指拖动 再用2个手指缩放 不会触发 onTouchBegin 的问题
            firsttouch = true;
            local d = touch[1]:getDelta();
            local mp = touch[1]:getLocation()

            if startP ~= nil then
                if math.abs(mp.x - startP.x) > 5 or math.abs(mp.y - startP.y) > 5 then
                    bCLICKed = false
                    self:clearnButtonBaseOnGuide()
                end
            end
            local scale = self.mNode:getScale();
          
            -- 这里要按照缩放比例来决定滑动的距离 不然在scale较小的情况下会出来 "滑不动"
            d = cc.p(d.x*scale , d.y*scale );
            lastMove = cc.p(0, 0)
            self:checkPosition(self.mNode, d, lastMove)
        else
            -- multi touch
            -- 关闭多点
            self:clearnButtonBaseOnGuide()
            --     if 1 then return end
            lastMove = nil
            bCLICKed = false
            local p1 = touch[1]:getLocation();
            local p2 = touch[2]:getLocation();

            local pMid = cc.pMidpoint(p1, p2);
            if (firsttouch) then
                firsttouch = false;
                distance = cc.pGetDistance(p1, p2);

                return;
            end
            local mdistance = cc.pGetDistance(p1, p2);
            mscale = mdistance / distance * mscale;
            distance = mdistance;
            mscale = math.min(1.5, mscale)
            mscale = math.max(0.75, mscale)
            self.lookp = self.mNode:convertToNodeSpace(cc.pMul(pMid, self.mNode:getScale()))
            safeScale(self.mNode, self.lookp, mscale)
        end
    end

    local function onTouchEnd(touch, event)
        if (#touch == 1) then
            -- single touch

            if bCLICKed then
                self:clearnButtonBaseOnGuide()
            end
            if (lastMove) then
                -- lastMove = cc.pMul(lastMove,5);
                if (math.abs(lastMove.x) <= DIS_MIN and math.abs(lastMove.y) <= DIS_MIN) then
                    return;
                end
                sid = me.Scheduler:scheduleScriptFunc(autoMoveMap, 0, false)
            else

                --                local pp = touch[1]:getLocation()
                --                self.mNode:stopAllActions()
                --                local tp = self.mNode:convertToNodeSpace(pp)
                --                self:lookAtPoint(cc.p(tp.x*self.mNode:getScaleX(),tp.y*self.mNode:getScaleY()))
                return;
            end

        else
            -- multi touch
        end
    end
    local function onMouse(e)
        if e:getScrollY() == 0 then
            return
        end
        scale = scale - e:getScrollY() * 5
        local s = scale / 100

        if self.lookp==nil then
            self.lookp = self.mNode:convertToNodeSpace(cc.p(e:getCursorX(), e:getCursorY()))
        end
        safeScale(self.mNode, self.lookp, s)
    end
    local function mouseDown(e)
        self.lookp = self.mNode:convertToNodeSpace(cc.p(e:getCursorX(), e:getCursorY()))
    end

    self.mNode:setContentSize(cc.size(IMG_WIDTH * 3, IMG_HEIGHT * 3))
    local listener = cc.EventListenerTouchAllAtOnce:create();
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCHES_BEGAN);
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCHES_MOVED);
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCHES_ENDED);
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self);

    local mouseListener = cc.EventListenerMouse:create()
    mouseListener:registerScriptHandler(onMouse, cc.Handler.EVENT_MOUSE_SCROLL)
    mouseListener:registerScriptHandler(mouseDown, cc.Handler.EVENT_MOUSE_DOWN)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(mouseListener, self);

    --self:initWater()
    return true
end
function mapLayer:initWater()
    local wp = WaterEffectSprite:create("water_1_1.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(480, 2393)
    me.assignWidget(self,"floor"):addChild(wp)
     local wp = WaterEffectSprite:create("water_1_2.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(1783, 3199)
    me.assignWidget(self,"floor"):addChild(wp)
     local wp = WaterEffectSprite:create("water_1_3_1.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(2322, 3228)
    me.assignWidget(self,"floor"):addChild(wp)
    local wp = WaterEffectSprite:create("water_1_3_2.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(3215, 2323)
    me.assignWidget(self,"floor"):addChild(wp)
    local wp = WaterEffectSprite:create("water_1_6.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(3224, 1708)
    me.assignWidget(self,"floor"):addChild(wp)
    local wp = WaterEffectSprite:create("water2.png")
    local t = cc.TextureCache:getInstance():addImage("res/water_normal.png")
    wp:initGLProgram(t)
    wp:setPosition(1680, 560)
    me.assignWidget(self,"floor"):addChild(wp)
  
end
function mapLayer:clearnButtonBaseOnGuide()
    if guideHelper.getGuideIndex() ~= guideHelper.guide_End and guideHelper.guideNeed == true then
        return
    end
    buildingOptMenuLayer:getInstance():clearnButton()
end

-- 必须是mNode的子组件
function mapLayer:getNodeCenterPos(node)
    local sc = self.mNode:getScale()
    local lp = cc.p(node:getPositionX() * sc, node:getPositionY() * sc)
    local ap = node:getAnchorPoint()
    local box = node:getBoundingBox()
    local cp = cc.p(lp.x - box.width *(ap.x - 0.5), lp.y - box.height *(ap.y - 0.5))
    return cp
end
function mapLayer:checkPosition(node, d, last)
    local px, py = self.mNode:getPosition();
    if px + d.x > 0 then
        self.mNode:setPositionX(0)
        last.x = 0
    elseif px + d.x < - self.mNode:getBoundingBox().width + me.winSize.width then
        self.mNode:setPositionX(- self.mNode:getBoundingBox().width + me.winSize.width)
        last.x = 0
    else
        self.mNode:setPositionX(px + d.x)
        last.x = d.x
    end
    if py + d.y > 0 then
        self.mNode:setPositionY(0)
        last.y = 0
    elseif py + d.y < - self.mNode:getBoundingBox().height + me.winSize.height then
        self.mNode:setPositionY(- self.mNode:getBoundingBox().height + me.winSize.height)
        last.y = 0
    else
        self.mNode:setPositionY(py + d.y)
        last.y = d.y
    end
    return last
end
function mapLayer:checkPositionforPoint(node, tp, cb_)
    local px, py = self.mNode:getPosition();
    local tag = cc.p(0, 0)
    if tp.x > 0 then
        tag.x = 0
    elseif tp.x < - self.mNode:getBoundingBox().width + me.winSize.width then
        tag.x = - self.mNode:getBoundingBox().width + me.winSize.width
    else
        tag.x = tp.x
    end
    if tp.y > 0 then
        tag.y = 0
    elseif tp.y < - self.mNode:getBoundingBox().height + me.winSize.height then
        tag.y = - self.mNode:getBoundingBox().height + me.winSize.height
    else
        tag.y = tp.y
    end

    local callFunc = cc.CallFunc:create(function ()
            if guideHelper.getGuideIndex() == guideHelper.guide_End or guideHelper.guideNeed == false then --如果在新手引导阶段，移除锁屏由guideHelper来控制
                guideHelper.removeWaitLayer()
            end            
            if cb_ ~= nil then
                cb_()
            end
            me.DelayRun(function ()
                self.mNode:setTouchEnabled(false)
            end,0.5)
        end)
    local t = cc.pGetDistance(cc.p(px, py), tag) / SPEED
    local moveto = cc.MoveTo:create(t, tag)
    local delay = cc.DelayTime:create(0.2)
    local seq = cc.Sequence:create(moveto,delay,callFunc) 
    self.mNode:setTouchEnabled(true)
    guideHelper.showWaitLayer()
    self.mNode:runAction(seq)
    return t
end
function mapLayer:checkPositionforPointByTime(node, tp, t)
    local px, py = self.mNode:getPosition();
    local tag = cc.p(0, 0)
    if tp.x > 0 then
        tag.x = 0
    elseif tp.x < - self.mNode:getBoundingBox().width + me.winSize.width then
        tag.x = - self.mNode:getBoundingBox().width + me.winSize.width
    else
        tag.x = tp.x
    end
    if tp.y > 0 then
        tag.y = 0
    elseif tp.y < - self.mNode:getBoundingBox().height + me.winSize.height then
        tag.y = - self.mNode:getBoundingBox().height + me.winSize.height
    else
        tag.y = tp.y
    end
    local moveto = cc.MoveTo:create(0, tag)

    self.mNode:runAction(moveto)
end
function mapLayer:selectNode(node, callfunc)
    local cp = self:getNodeCenterPos(node)
    center = cp
    local tp = cc.p(- cp.x + me.winSize.width / 2, - cp.y + me.winSize.height / 2)

    local px, py = self.mNode:getPosition();
    local tag = cc.p(0, 0)
    if tp.x > 0 then
        tag.x = 0
    elseif tp.x < - self.mNode:getBoundingBox().width + me.winSize.width then
        tag.x = - self.mNode:getBoundingBox().width + me.winSize.width
    else
        tag.x = tp.x
    end
    if tp.y > 0 then
        tag.y = 0
    elseif tp.y < - self.mNode:getBoundingBox().height + me.winSize.height then
        tag.y = - self.mNode:getBoundingBox().height + me.winSize.height
    else
        tag.y = tp.y
    end
    local t = cc.pGetDistance(cc.p(px, py), tag) / SPEED
    local moveto = cc.MoveTo:create(t, tag)   
    local call_ = cc.CallFunc:create(callfunc)
    local seq = cc.Sequence:create(moveto, call_)
    self.mNode:runAction(seq)
end
function mapLayer:lookAtNode(node,cb_)
    if node and self.mNode:getNumberOfRunningActions() <= 0 then
        local cp = self:getNodeCenterPos(node)
        return self:checkPositionforPoint(self.mNode, cc.p(- cp.x + me.winSize.width / 2, - cp.y + me.winSize.height / 2),cb_)
    end
    return 0
end
function mapLayer:scaleto(s)
    self.mNode:setScale(s)
end
function mapLayer:lookAtPoint(p)
    return self:checkPositionforPoint(self.mNode, cc.p(- p.x + me.winSize.width / 2, - p.y + me.winSize.height / 2))
end
function mapLayer:setLookPoint(p)
    self:checkPositionforPointByTime(self.mNode, cc.p(- p.x + me.winSize.width / 2, - p.y + me.winSize.height / 2), 0)
end
function mapLayer:setLookAtNode(node)
    if node then
        local p = self:getNodeCenterPos(node)
        self:checkPositionforPointByTime(self.mNode, cc.p(- p.x + me.winSize.width / 2, - p.y + me.winSize.height / 2), 0)
    end

end
function mapLayer:onEnter()
    print("mapLayer onEnter")
end
function mapLayer:scaleto(t, s)
    local x, y = self.mNode:getPosition()
    local tx = me.winSize.width / 2 - x
    local ty = me.winSize.height / 2 - y
    local lastAnp = self.mNode:getAnchorPoint()
    doAnchorPoint(self.mNode, cc.p(tx, ty))
    local a = cc.ScaleTo:create(t, s)
    self.mNode:runAction(cc.Sequence:create(a, cc.CallFunc:create( function(node)
        doAnchorPoint(self.mNode, lastAnp)
    end )))
end
function mapLayer:onExit()
    print("mapLayer onExit")
end
