tipsNodeTag = 32453
tipsQueue = Queue.new()
tipsNum = 0
-- 字符串，颜色00ff00,字体大小，显示时间 -1为一直显示在屏幕上
function showTips(txt, color, fontSize, time)
    if type(txt) == "table" then
        Queue.push(tipsQueue, txt)
    elseif type(txt) == "string" then
        local tips = { }
        tips.text = txt
        tips.showbg =  true
        tips.fontsize = fontSize or 24
        if color then
            tips.color = me.convert4Color_(color)
        else
            tips.color = cc.c4b(255, 255, 255, 255)
        end
        tips.enableShadow = enableShadow or cc.c4b(0, 0, 0, 255)
        tips.showtime = time or 1
        Queue.push(tipsQueue, tips)
    end
end
function showTipsNoBg(txt, color, fontSize, time)
    if type(txt) == "table" then
        Queue.push(tipsQueue, txt)
    elseif type(txt) == "string" then
        local tips = { }
        tips.text = txt
        tips.showbg = false
        tips.fontsize = fontSize or 24
        if color then
            tips.color = me.convert4Color_(color)
        else
            tips.color = cc.c4b(255, 255, 255, 255)
        end
        tips.enableShadow = enableShadow or cc.c4b(0, 0, 0, 255)
        tips.showtime = time or 1
        Queue.push(tipsQueue, tips)
    end
end
tispTag = 0xff123aa
function showSimpleTips(str,node)
    local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
    local wd = node:convertToWorldSpace(cc.p(0, 0))
    stips:initWithStr(str, wd)
    me.popLayer(stips)
end
function showErrorMsg(txt, status)
    local t = status or 1
    showTips(txt, "ff0000", 24, t)
end
local tipsManagerInited = false
function initTipsManager()
    if tipsManagerInited then
        return
    else
        tipsManagerInited = true
    end
    local function getSpritePng()
        local bg = ccui.Scale9Sprite:create("gongyong_diban_tishi.png")
        bg:setScaleX(0.5)
        bg:setScaleY(0.8)
        bg:setVisible(true)
        bg:setContentSize(cc.size(790, 80))
        return bg
    end
    local pHeiht = 80
    local lastTips = nil
    local function tipsManager(dt)
        if not Queue.isEmpty(tipsQueue) then
            local scene = cc.Director:getInstance():getRunningScene()
            if scene then
                local _tips = Queue.pop(tipsQueue)
                tipsNum = tipsNum + 1
                local node = scene:getChildByTag(tipsNodeTag)
                if node == nil then
                    lastTips = nil
                    node = cc.Layer:create()
                    node:setTag(tipsNodeTag)
                    scene:addChild(node, 999999)
                end
                local label = cc.Label:createWithSystemFont(_tips.text, "", _tips.fontsize)
                label:setColor(_tips.color)
                label:enableShadow(_tips.enableShadow)
                label:enableOutline(cc.c3b(0, 0, 0), 1)
                -- cc.Node:create():getChildrenCount()
                local cb = node:getChildren()
                local num = node:getChildrenCount()
                local varHeight = pHeiht / 4 + 10
                for key, var in pairs(cb) do
                    lastTips = cb[num]
                    if lastTips ~= nil then
                        if lastTips:getPositionY() - pHeiht < 50 then
                            varHeight = pHeiht + 10
                        end

                    end
                    var:setPosition(var:getPositionX(), var:getPositionY() + varHeight)
                    if var:getPositionY() > me.winSize.height + var:getContentSize().height / 2 then
                        var:stopAllActions()
                        var:removeFromParent(true)
                    end
                end
                lastTips = cb[num]
                if lastTips ~= nil then
                    if lastTips:getPositionY() - pHeiht < 50 then
                        label:setPosition(me.winSize.width / 2, 50)
                    else
                        label:setPosition(me.winSize.width / 2, lastTips:getPositionY() - pHeiht / 4 * 3 - 10)
                    end

                else

                    label:setPosition(me.winSize.width / 2, me.winSize.height / 2)
                end
                -- lastTips = label
                label:setScale(1.5)
                local action2 = cc.ScaleTo:create(0.1, 1.0)
                local action4 = cc.DelayTime:create(1.0)
                local action3 = cc.FadeOut:create(0.6)
                local function endlabelCallback(node_)
                    node_:removeFromParent(true)
                    tipsNum = tipsNum - 1
                    if tipsNum == 0 then
                        lastTips = nil
                    end
                end
                local sprite = getSpritePng()
                sprite:setPosition(label:getPosition())
                sprite:setVisible(_tips.showbg)
                node:addChild(sprite)
                node:addChild(label)
                if _tips.showtime then
                    if me.toNum(_tips.showtime) == 1 then
                        sprite:runAction(cc.Sequence:create(cc.DelayTime:create(1.1), cc.FadeOut:create(0.6), cc.CallFunc:create( function(node_)
                            node_:removeFromParent(true)
                        end )))
                        label:runAction(cc.Sequence:create(action2, action4, action3, cc.CallFunc:create(endlabelCallback)))
                    else
                        label:runAction(cc.Sequence:create(action2))
                        sprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.1)))
                    end
                else
                    sprite:runAction(cc.Sequence:create(cc.DelayTime:create(1.1), cc.FadeOut:create(0.6), cc.CallFunc:create( function(node_)
                        node_:removeFromParent(true)
                    end )))
                    label:runAction(cc.Sequence:create(action2, action4, action3, cc.CallFunc:create(endlabelCallback)))
                end
            end
        end
    end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(tipsManager, 0.1, false)
end

-- 展示多行文字
function showMultipleTipWithBg(txtList, color, fontSize)
    local scene = cc.Director:getInstance():getRunningScene()
    local node = me.createNode("Node_MultipleLineTip.csb")
    node:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
    scene:addChild(node, 999999)

    -- 背景框
    local img_bg = me.assignWidget(node, "img_bg")
    local tempBgSize = img_bg:getContentSize()
    local bgScaleX, bgScaleY = img_bg:getScaleX(), img_bg:getScaleY()
    -- 容器
    local panel = me.assignWidget(node, "panel")
    panel:removeAllChildren()
    -- 行间距
    local lineVerSpace = 10
    -- 上下边框距离
    local borderSpace = 20
    -- 背景真实高度
    local realHeight = 0
    local labelList = {}
    for i, v in ipairs(txtList or {}) do
        local label = cc.Label:createWithSystemFont(v, "", fontSize or 24)
        label:setColor(color or cc.c3b(255, 255, 255))
        label:setAnchorPoint(cc.p(0.5, 1))
        label:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        panel:addChild(label)
        table.insert(labelList, label)
        label.height = label:getContentSize().height
        realHeight = realHeight + label.height
    end
    realHeight = realHeight + borderSpace * 2 + (#labelList - 1) * lineVerSpace
    img_bg:setContentSize(cc.size(tempBgSize.width, realHeight / bgScaleY))
    panel:setContentSize(cc.size(tempBgSize.width * bgScaleX, realHeight))

    -- 坐标修正
    local startY = realHeight - borderSpace
    for i, label in ipairs(labelList) do
        label:setPosition(cc.p(tempBgSize.width * bgScaleX / 2, startY - (i - 1) * (label.height + lineVerSpace)))
        label:setVisible(false)
        label:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.08 * i),
            cc.Show:create()
        ))
    end

    -- 动画序列
    node:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.1),
        cc.DelayTime:create(2),
        cc.Spawn:create(cc.MoveBy:create(1.0, cc.p(0, 200)), cc.FadeOut:create(1.0)),
        cc.CallFunc:create(function()
            node:removeFromParent()
        end)
    ))
end