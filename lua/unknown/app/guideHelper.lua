guideHelper = { }
guideHelper.guideIndex = 0-- 引导步骤
guideHelper.guide_End = 99 -- 当前引导结束
guideHelper.guideAllot = 110 -- 分配农民任务的新手引导     (100-199)
guideHelper.guideConquest = 200 -- 外城出征的新手引导     (200 -299)
guideHelper.guideReport = 300 -- 查看战报的新手引导       (300-399)
guideHelper.guideExplore = 400 -- 探索的新手引导         (400-499)
guideHelper.guideComArch = 500 -- 合成考古的新手引导      (500 -599)
guideHelper.guideGoToArch = 600 -- 外城考古的新手引导     (600-699)
guideHelper.guideGoRelic = 700 -- 圣物搜寻的新手引导 （700-799）
guideHelper.guideGoRelicCon = 800 -- 圣物合成的新手引导 （700-799）
guideHelper.waitlayer = nil -- 引导的等待界面
guideHelper.guideNeed = true  -- 是否开启引导

function guideHelper.getGuideIndex()
    return me.toNum(guideHelper.guideIndex)
end
function guideHelper.setGuideIndex(index_)
    print("guideHelper.setGuideIndex = " .. index_)
    --showErrorMsg("".. index_,-1)
    guideHelper.guideIndex = me.toNum(index_)
    NetMan:send(_MSG.uploadGuideIndex(index_, 1))
end
function guideHelper.saveGuideIndex(index_)
    if index_ then
        --showErrorMsg("".. index_,-1)
        NetMan:send(_MSG.uploadGuideIndex(index_))
    else
         --showErrorMsg("".. guideHelper.guideIndex,-1)
        NetMan:send(_MSG.uploadGuideIndex(guideHelper.guideIndex))
    end
end
function guideHelper.getGuideTargetType()
    return guideHelper.targetType
end

function guideHelper.setGuideTargetType(type_)
    guideHelper.targetType = type_
end

-- 所有的引导下一步(包括首次登录和任务引导)
function guideHelper.nextStepByOpt(save_, btn_, f_)
    if guideHelper.guideNeed == false then
        return
    end
    print("guideHelper.~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~guideHelper.nextStepByOpt() = " .. guideHelper.guideIndex)
    if guideHelper.isGuideOver() == false then
        -- 首次登录游戏的引导
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        guideHelper.nextStep(btn_)
    elseif guideHelper.isTaskGuideOver() == false then
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        guideHelper.nextTaskStep(btn_, f_)
    end
    if save_ then
        guideHelper.saveGuideIndex()
    end
end

-- 等待的透明层
function guideHelper.showWaitLayer()
    if guideHelper.waitlayer == nil then
        print("guideHelper.showWaitLayer() !!")
        --showErrorMsg("guideHelper.showWaitLayer() !!", -1)
        guideHelper.waitlayer = waitLayer:create("netLoadingLayer.csb")
        guideHelper.waitlayer:setTag(waitTAG)
        guideHelper.waitlayer:hideAni(true)
    end

    local function layerExist(father_)
        if father_:getChildByTag(waitTAG) == nil then
            return false
        end
        return true
    end

    if CUR_GAME_STATE == GAME_STATE_CITY and layerExist(mainCity) == false then
        mainCity:addChild(guideHelper.waitlayer, me.GUIDEZODER + 10)
    elseif (CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE) and layerExist(pWorldMap) == false then
        pWorldMap:addChild(guideHelper.waitlayer, me.GUIDEZODER + 10)
    end
end

function guideHelper.removeWaitLayer()
    if guideHelper.waitlayer then
        print("guideHelper.removeWaitLayer()")
        --showErrorMsg("guideHelper.removeWaitLayer() !!", -1)
        guideHelper.waitlayer:removeFromParent()
        guideHelper.waitlayer = nil
    end
end

function guideHelper.setAllBuildingTouchEnable(enable_)
    for key, var in pairs(mainCity.buildingMoudles) do
        var.icon:setTouchEnabled(enable_)
    end
end
function guideHelper.isGuideOver()
    print("isGuideOver", guideHelper.getGuideIndex())
    if guideHelper.getGuideIndex() < guideHelper.guide_End then
        return false
    end
    return true
end
function guideHelper.startStep()
    if guideHelper.guideNeed == false then
        return
    end

    local needDelay = false
    local tarType = nil
    local tarStatus = nil

    if guideHelper.getGuideIndex() == 23 then
        needDelay = true
        tarType = "center"
        tarStatus = BUILDINGSTATE_LEVEUP.key
    elseif guideHelper.getGuideIndex() == 14 then
        needDelay = true
        tarType = "food"
        tarStatus = BUILDINGSTATE_BUILD.key
    elseif guideHelper.getGuideIndex() == 5 then
        needDelay = true
        tarType = "house"
        tarStatus = BUILDINGSTATE_BUILD.key
    end

    if needDelay == true then
        local targetM = nil
        targetM = getTargetMoudlesByOpt(tarType, tarStatus)
        if targetM then
            me.DelayRun( function()
                cameraLookAtNode(targetM, function()
                    guideHelper.nextStep()
                end )
            end , 0.2)
        else
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextStep()
        end
    elseif guideHelper.isGuideOver() == false then
        guideHelper.nextStep()
    elseif guideHelper.isGuideOver() == true and guideHelper.isTaskGuideOver() == false then
        guideHelper.nextTaskStep()
    end
end

-- 判断有没有空闲可供分配的建筑物
function guideHelper.haveIdleBuilding()
    for key, var in pairs(user.building) do
        local def = var:getDef()
        if me.toNum(var.worker) < me.toNum(def.inmaxfarmer) then
            return true
        end
    end
    for key, var in pairs(user.buildingDateLine) do
        local def = var:getDef()
        if me.toNum(var.builder) < me.toNum(def.maxfarmer) then
            return true
        end
    end
    return false
end

-- 根据任务开启新手引导
guideHelper.guideAllot_TaskID = 1018 -- 工人分配
guideHelper.guideConquest_TaskID = 1008 -- 外城出征
guideHelper.guideReport_TaskID = 1009 -- 查看战报
guideHelper.guideExplore_TaskID = 1012 -- 探索
guideHelper.guideComArch_TaskID = 1013 -- 合成考古初级铲子
guideHelper.guideGoToArch_TaskID = 1014 -- 外城开始考古
guideHelper.guideRelic_TaskID = 1367  -- 1061 --开启圣物搜寻
guideHelper.guideRelicCon_TaskID = 1368  -- 1368 --开启圣物装备
function guideHelper.isTaskGuideOver()
    if guideHelper.guideIndex > guideHelper.guide_End then
        return false
    end
    return true
end

function guideHelper.haveBaseData()
    -- 判断有没有据点
    return table.nums(gameMap.bastionData) > 0
end

function guideHelper.forceCloseGuideHelper()
    -- 强制中途关闭引导,避免卡死
    guideHelper.setGuideIndex(guideHelper.guide_End)
    guideHelper.saveGuideIndex()
    if guideViewInstace ~= nil then
        guideViewInstace:close()
    end
    guideHelper.removeWaitLayer()
    guideHelper.guideNeed = false
end

function guideHelper.nextTaskStep(btn_, f_)


    --    if true then
    --    guideHelper.saveGuideIndex(guideHelper.guide_End)
    --        return
    --    end

    if guideHelper.guideNeed == false then
        return
    end
    print("guideHelper.nextTaskStep = " .. guideHelper.guideIndex)
    guideHelper.showWaitLayer()
    ------------------------农民分配引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideAllot then
        -- 农民分配对话
        if mainCity.taskview then
            mainCity.taskview:close()
        end

        local guide = guideView:getInstance()
        guide:showDialog(6, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        addToCurrentView(guide)
    end

    if guideHelper.guideIndex == guideHelper.guideAllot + 1 then
        -- 点击分配按钮
        local guide = guideView:getInstance()
        guide:setHandFilp(true, false)
        guide:showGuideView(mainCity.allotBtn, true, true, function()
        end , nil, false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideAllot + 2 and btn_ then
        -- 选中其中一个建筑的按钮
        local guide = guideView:getInstance()
        guide:showGuideViewForList(btn_, true, true, function()
        end , nil, false, f_)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideAllot + 3 and btn_ then
        -- 弹出界面，选择滑动条(在allotPopOver里有特殊处理此guideIndex)
        --        local guide = guideView:getInstance()
        --        guide:showGuideView(btn_,true,true,function ()
        --        end,nil,false)
        --        guide:slideAnimForAllot()
        --        addToCurrentView(guide)
        SharedDataStorageHelper():setAllotGuide()
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
        guideHelper.setGuideIndex(guideHelper.guide_End)
        -- 农民分配引导结束
    end
    --    if guideHelper.guideIndex == guideHelper.guideAllot+4 and btn_ then --点击确定
    --        local guide = guideView:getInstance()
    --        guide:showGuideView(btn_,true,true,function ()
    --        end,nil,false)
    --        addToCurrentView(guide)
    --    end
    --    if guideHelper.guideIndex == guideHelper.guideAllot+5 then --关闭分配界面
    --        if mainCity.allot ~= nil then
    --            local guide = guideView:getInstance()
    --            guide:showGuideView(mainCity.allot.closeBtn,true,true,function ()
    --                guideHelper.guideIndex = guideHelper.guide_End --农民分配引导结束
    --                guideHelper.saveGuideIndex()
    --            end,nil,true)
    --            addToCurrentView(guide)
    --        end
    --    end

    ------------------------外城出征引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideConquest then
        -- 出征对话
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:showDialog(8, function()
                guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
                guideHelper.nextTaskStep()
            end )
            addToCurrentView(guide, 0.5)
        end , 1.8)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 1 then
        -- 点击出城
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.battleBtn, true, true, function()
        end , "zhucheng_waicheng_anniu_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 2 and CUR_GAME_STATE == GAME_STATE_WORLDMAP then
        local tips = battleTipsLayer:create("battleTipsLayer.csb")
        pWorldMap:addChild(tips,me.MAXZORDER)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 3 and CUR_GAME_STATE == GAME_STATE_WORLDMAP then
        -- 选择可征服的领地(  !!!!在WorldMapView里的onTouchEnd有特殊处理!!!!)
        local cell = pWorldMap:getFirstCell()
        local guide = guideView:getInstance()
        guide:showGuideView(cell, true, true, function()
        end , "gongyong_yindao_green.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 4 and btn_ then
        -- 点击mapMenuOpt里的征服按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , "waicheng_anniu_gongyong_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 5 and btn_ then
        -- 点击出征按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , nil, false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideConquest + 6 then
        -- 仅移除引导层，等待出征结束
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        --        guideHelper.removeWaitLayer()
        guideHelper.waitlayer:setTipsInfo("领主大人，等待士兵回城")
        guideHelper.guideIndex = guideHelper.guide_End
        -- 外城出征引导结束,等待查看战报
        guideHelper.saveGuideIndex()
    end
    ------------------------查看战报引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideReport then
        -- 查看战报对话
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        me.DelayRun(function (node)
            local guide = guideView:getInstance()
            guide:showDialog(10, function()
                guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
                guideHelper.nextTaskStep()
            end )
            addToCurrentView(guide)
        end,1)
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 1 then
        -- 点击邮件
        local emailBtn = nil
        if CUR_GAME_STATE == GAME_STATE_CITY then
            emailBtn = mainCity.mailBtn
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            emailBtn = pWorldMap.mailBtn
        end
        if emailBtn then
            local guide = guideView:getInstance()
            guide:showGuideView(emailBtn, true, true, function()
            end , nil, false)
            addToCurrentView(guide)
        end
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 2 and btn_ then
        -- 点击战斗详情
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , nil, false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 3 then
        -- 对话
        guideHelper.saveGuideIndex(guideHelper.guide_End)
        -- 上传服务器战报引导结束
        me.DelayRun(function (args)
            local guide = guideView:getInstance()
            guide:showDialog(17, function()
                guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
                guideHelper.nextTaskStep()
            end )
            addToCurrentView(guide)
        end,1)
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 4 then
        -- 解除锁屏，任意点击
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 5 and btn_ then
        -- 关闭邮件
        local guide = guideView:getInstance()
        guide:setHandFilp(true, true)
        guide:showGuideView(btn_, true, true, function()
        end , nil, false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 6 then
        -- 点击内城
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            local guide = guideView:getInstance()
            guide:showGuideView(pWorldMap.homeBtn, true, true, function()
            end , nil, false)
            addToCurrentView(guide)
        end
        if CUR_GAME_STATE == GAME_STATE_CITY then
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 7 then
        -- 对话
        me.DelayRun(function (args)
            local guide = guideView:getInstance()
            guide:showDialog(21, function()
                guideHelper.setGuideIndex(guideHelper.guideReport + 8)
                guideHelper.nextTaskStep()
            end )
            addToCurrentView(guide)
            guideHelper.removeWaitLayer()
        end,2)
    end
    if guideHelper.guideIndex == guideHelper.guideReport + 8 then
        -- 移除可能的屏蔽层
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
        guideHelper.setGuideIndex(guideHelper.guide_End)
        guideHelper.saveGuideIndex()
    end

    ------------------------探索引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideExplore and CUR_GAME_STATE == GAME_STATE_CITY then
        -- 对话
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        local guide = guideView:getInstance()
        guide:showDialog(11, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 1 and CUR_GAME_STATE == GAME_STATE_CITY then
        -- 点击出城
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.battleBtn, true, true, function()
        end , "zhucheng_waicheng_anniu_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 2 and CUR_GAME_STATE == GAME_STATE_WORLDMAP then
        -- 选择可探索的领地(  !!!!在WorldMapView里的onTouchEnd有特殊处理!!!!)
        local cell = pWorldMap:getEventCell()
        if guideHelper.haveBaseData() then
            -- 如果有据点了，关闭引导
            guideHelper.forceCloseGuideHelper()
        elseif cell then
            local guide = guideView:getInstance()
            guide:showGuideView(cell, true, true, function()
            end , "gongyong_yindao_green.png", false)
            addToCurrentView(guide)
        else
            -- 如果没有可用的 就关闭引导
            guideHelper.forceCloseGuideHelper()
        end
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 3 and btn_ then
        -- 点击mapMenuOpt里的征服按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , "waicheng_anniu_gongyong_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 4 and btn_ then
        -- 点击出征按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , nil, false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 5 then
        -- 点击内城
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            local guide = guideView:getInstance()
            guide:showGuideView(pWorldMap.homeBtn, true, true, function()
            end , nil, false)
            addToCurrentView(guide)
        end
    end
    if guideHelper.guideIndex == guideHelper.guideExplore + 6 then
        -- 外城出征引导结束
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
        guideHelper.setGuideIndex(guideHelper.guide_End)
        guideHelper.saveGuideIndex()
    end

    ------------------------合成考古道具引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideComArch then
        -- 对话
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:showDialog(14, function()
                guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
                guideHelper.nextTaskStep()
            end )
            addToCurrentView(guide)
        end , 1.8)
    end
    if guideHelper.guideIndex == guideHelper.guideComArch + 1 then
        -- 点击考古
        local guide = guideView:getInstance()  
        guide:showGuideView(mainCity.Button_Arch, true, true, function()
        end , "ui_zjm_kaogu_01.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideComArch + 2 then
        -- 对话
        local guide = guideView:getInstance()
        guide:showDialog(13, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideComArch + 3 then
        -- 选择初级铲子
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.arch then
            local tmpBtn = mainCity.arch:getCellForGuide()
            local guide = guideView:getInstance()
            guide:showGuideView(tmpBtn, true, true, function()
            end , nil, false)
            addToCurrentView(guide)
        end
    end
    if guideHelper.guideIndex == guideHelper.guideComArch + 4 then
        -- 点击合成
        if CUR_GAME_STATE == GAME_STATE_CITY then
            local guide = guideView:getInstance()
            guide:showGuideView(mainCity.arch.Button_Altas, true, true, function()
            end , nil, false)
            addToCurrentView(guide)
        end
    end
    if guideHelper.guideIndex == guideHelper.guideComArch + 5 then
        -- 点击关闭
        local guide = guideView:getInstance()
        guide:setHandFilp(true, true)
        guide:showGuideView(mainCity.arch.Button_carryabout, true, true, function()
        end , nil, true)
        addToCurrentView(guide)
        guideHelper.guideIndex = guideHelper.guide_End
        -- 合成道具引导结束
        guideHelper.saveGuideIndex()
    end

    ------------------------外城考古引导------------------------------
    if guideHelper.guideIndex == guideHelper.guideGoToArch then
        -- 出城考古对话
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        local guide = guideView:getInstance()
        guide:showDialog(12, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        addToCurrentView(guide, true)
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch + 1 then
        -- 点击外城
        if CUR_GAME_STATE == GAME_STATE_CITY then
            local guide = guideView:getInstance()
            guide:showGuideView(mainCity.battleBtn, true, true, function()
            end , "zhucheng_waicheng_anniu_zhengchang.png", false)
            addToCurrentView(guide)
        else
            if guideViewInstace ~= nil then
                guideViewInstace:close()
            end
            guideHelper.saveGuideIndex(guideHelper.guide_End)
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch + 2 then  
        guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        local tips = archTipsLayer:create("archTipsLayer.csb")
        pWorldMap:addChild(tips,me.MAXZORDER)
    end    
    --[[
    if guideHelper.guideIndex == guideHelper.guideGoToArch+2 then  --选择可考古的领地(  !!!!在WorldMapView里的onTouchEnd有特殊处理!!!!)
        if CUR_GAME_STATE == GAME_STATE_CITY then
            guideHelper.forceCloseGuideHelper()
        elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            if guideHelper.haveBaseData() then --如果有据点了，强制关闭引导
                guideHelper.forceCloseGuideHelper()
            else
                local cell = pWorldMap:getFirstCell()
                local guide = guideView:getInstance()
                guide:showGuideView(cell,true,true,function ()
                end,"gongyong_yindao_green.png",false)
                addToCurrentView(guide)
            end
        end
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch+3 and btn_ then --点击mapMenuOpt里的征服按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_,true,true,function ()
        end,"waicheng_anniu_gongyong_zhengchang.png",false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch+4 and btn_ then --选择考古次数
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            local guide = guideView:getInstance()
            guide:showGuideView(btn_,true,true,function ()
            end,nil,false)
            addToCurrentView(guide)
        end
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch+5 and btn_ then --点击出征
        local guide = guideView:getInstance()
        guide:showGuideView(btn_,true,true,function ()
        end,nil,false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideGoToArch+6 then --点击内城
        if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
            local guide = guideView:getInstance()
            guide:showGuideView(pWorldMap.homeBtn,true,true,function ()
            end,nil,false)
            addToCurrentView(guide)
        end
    end
    ]]
    
    if guideHelper.guideIndex == guideHelper.guideGoRelic then
        -- 圣物新手引导
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        local guide = guideView:getInstance()
        guide:showDialog(18, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 1 then
        -- 点击圣殿
        guideHelper.showWaitLayer()
        local centerM = nil
        for key, var in pairs(mainCity.buildingMoudles) do
            local mType = var:getData():getDef().type
            if mType == cfg.BUILDING_TYPE_ALTAR then
                centerM = var
                break
            end
        end
        cameraLookAtNode(centerM, function()
            local img = buildIcon(centerM:getData():getDef())
            local guide = guideView:getInstance()
            guide:showGuideView(centerM.icon, true, true, function()
            end , img, false)
            addToCurrentView(guide)
        end )
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 2 then
        -- 点击搜寻按钮
        me.DelayRun( function()
            local btn = buildingOptMenuLayer:getInstance():getMenuBtnByOpt(buildingOptMenuLayer.BTN_TRAIT)
            if btn == nil then
                showTips("引导中断！btn = nil")
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(btn, true, true, function()
            end , "zhucheng_anniu_shengji_zhengchang.png", false)
            addToCurrentView(guide)
        end )
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 3 then
        -- 搜寻
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , "rune_search_btn1.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 4 then
        -- 点击确定
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , "rune_search_btn1.png", false)
        addToCurrentView(guide)
        guideHelper.saveGuideIndex(guideHelper.guideGoRelic + 6)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 5 then
        -- 点击关闭
        local guide = guideView:getInstance()
        guide:setHandFilp(true, true)
        guide:showGuideView(btn_, true, true, function()
            guideHelper.showWaitLayer()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
        end , "gongyong_anniu_hongse_zhengchang_1.png", false)
        addToCurrentView(guide)
        guideHelper.saveGuideIndex(guideHelper.guideGoRelic + 6)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 6 then
        -- 圣物新手引导
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity.taskview then
            mainCity.taskview:close()
        end
        guideHelper.setAllBuildingTouchEnable(false)
        local guide = guideView:getInstance()
        guide:showDialog(19, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextTaskStep()
            me.DelayRun( function(args)
                guideHelper.setAllBuildingTouchEnable(true)
            end )
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 7 then
        -- 点击圣殿
        guideHelper.showWaitLayer()
        local centerM = nil
        for key, var in pairs(mainCity.buildingMoudles) do
            local mType = var:getData():getDef().type
            if mType == cfg.BUILDING_TYPE_ALTAR then
                centerM = var
                break
            end
        end
        cameraLookAtNode(centerM, function()
            local img = buildIcon(centerM:getData():getDef())
            local guide = guideView:getInstance()
            guide:showGuideView(centerM.icon, true, true, function()
            end , img, false)
            addToCurrentView(guide)
        end )
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 8 then
        -- 点击圣物按钮
        me.DelayRun( function()
            local btn = buildingOptMenuLayer:getInstance():getMenuBtnByOpt(buildingOptMenuLayer.BTN_ALTAR)
            if btn == nil then
                showTips("引导中断！btn = nil")
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(btn, true, true, function()
            end , "zhucheng_anniu_shengji_zhengchang.png", false)
            addToCurrentView(guide)
        end , 1)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 9 then
        -- 点击装备按钮
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:showGuideView(btn_, true, true, function()
            end , "rune_equip_bg.png", false)
            addToCurrentView(guide)
        end , 0.5)
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 10 then
        -- 点击选择按钮
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:showGuideView(btn_, true, true, function()
            end , "btn_chengse.png", false)
            addToCurrentView(guide)
        end )
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 11 then
        -- 点击确定选择按钮
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:showGuideView(btn_, true, true, function()
            end , "btn_chengse.png", false)
            addToCurrentView(guide)
            guideHelper.saveGuideIndex(guideHelper.guide_End)
        end )
    end
    if guideHelper.guideIndex == guideHelper.guideGoRelic + 12 then
        -- 点击关闭按钮
        me.DelayRun( function()
            local guide = guideView:getInstance()
            guide:setHandFilp(true, true)
            guide:showGuideView(mainCity.runeAltar.closeBtn, true, true, function()
            end , nil, true)
            addToCurrentView(guide)
            guideHelper.removeWaitLayer()
            guideHelper.guideIndex = guideHelper.guide_End
            -- 新手引导结束
            guideHelper.saveGuideIndex(guideHelper.guide_End)
        end )
    end
end
function addToCurrentView(guideView_)
    if CUR_GAME_STATE == GAME_STATE_CITY and mainCity:getChildByName("guideViewIndex") == nil then
        mainCity:addChild(guideView_, me.GUIDEZODER)
    elseif (CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE) and pWorldMap:getChildByName("guideViewIndex") == nil then
        pWorldMap:addChild(guideView_, me.GUIDEZODER)
    end
    guideHelper.removeWaitLayer()
end
-- 首登游戏的引导部分
function guideHelper.nextStep(btn_)
    if guideHelper.guideNeed == false then
        return
    end
    if guideHelper.isGuideOver() then
        return
    end
    guideHelper.setAllBuildingTouchEnable(true)
    guideHelper.showWaitLayer()
    guideHelper.guideIndex = guideHelper.getGuideIndex()
    -- 开始游戏引导
    if guideHelper.guideIndex == 0 then
        -- 对话
        local guide = guideView:getInstance()
        guide:showDialog(1, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 1 then
        -- 对话
        local guide = guideView:getInstance()
        guide:showDialog(2, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 2 then
        -- 打开建筑商店
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.buildBtn, true, true, function()
        end , "zhucheng_shangcheng_anniu_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 3 then
        -- 选择房屋
        mainCity.bshopBox:setGuideTarget("house", true)
        guideHelper.removeWaitLayer()
    end
    if guideHelper.guideIndex == 4 and btn_ then
        -- 点击建造按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
            guideHelper.saveGuideIndex(5)
        end , "ui_ty_button_hong_154x56.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 5 then
        -- 寻找房屋免费按钮
        me.DelayRun( function()
            tar = getTargetMoudlesByOpt("house", BUILDINGSTATE_BUILD.key)
            if tar == nil or tar.helpBtn == nil then
                guideHelper.setGuideIndex(6)
                guideHelper.nextStep()
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(tar.helpBtn, true, true, function()
            end , "zhucheng_mf_zhengchang.png", false)
            addToCurrentView(guide)
        end , 0.8)
    end
    if guideHelper.guideIndex == 6 then
        -- 对话
        local guide = guideView:getInstance()
        guide:showDialog(3, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
            guideHelper.nextStep()
        end )
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 7 then
        -- 打开建筑商店
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.buildBtn, true, true, function()
        end , "zhucheng_shangcheng_anniu_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 8 then
        -- 选择磨坊
        mainCity.bshopBox:setGuideTarget("food", true)
        guideHelper.removeWaitLayer()
    end
    if guideHelper.guideIndex == 9 and btn_ then
        -- 点击建造按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
            guideHelper.saveGuideIndex(14)
        end , "gongyong_anniu_huangse_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 10 then
        -- 寻找磨坊的免费按钮
        me.DelayRun( function()
            tar = getTargetMoudlesByOpt("food", BUILDINGSTATE_BUILD.key)
            if tar == nil or tar.helpBtn == nil then
                guideHelper.setGuideIndex(15)
                guideHelper.nextStep()
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(tar.helpBtn, true, true, function()
            end , "zhucheng_mf_zhengchang.png", false)
            addToCurrentView(guide)
        end , 2)
    end
    if guideHelper.guideIndex == 11 then
        -- 点击主城
        guideHelper.showWaitLayer()
        local centerM = nil
        for key, var in pairs(mainCity.buildingMoudles) do
            local mType = var:getData():getDef().type
            if mType == "center" then
                centerM = var
                break
            end
        end
        cameraLookAtNode(centerM, function()
            local img = buildIcon(centerM:getData():getDef())
            local guide = guideView:getInstance()
            guide:showGuideView(centerM.icon, true, true, function()
            end , img, false)
            addToCurrentView(guide)
        end )
    end
    if guideHelper.guideIndex == 12 then
        -- 点击升级按钮
        me.DelayRun( function()
            local btn = buildingOptMenuLayer:getInstance():getMenuBtnByOpt(buildingOptMenuLayer.BTN_UPGRADE)
            if btn == nil then
                showTips("引导中断！btn = nil")
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(btn, true, true, function()
            end , "zhucheng_anniu_shengji_zhengchang.png", false)
            addToCurrentView(guide)
        end , 2)
    end
    if guideHelper.guideIndex == 13 and btn_ then
        -- 点击建筑物的升级按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
        end , "gongyong_anniu_huangse_zhengchang.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 14 then
        -- 点击升免费级按钮
        me.DelayRun( function()
            local tar = getTargetMoudlesByOpt("center", BUILDINGSTATE_LEVEUP.key)
            if tar == nil or tar.helpBtn == nil then
                guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
                guideHelper.nextStep()
                return
            end
            local guide = guideView:getInstance()
            guide:showGuideView(tar.helpBtn, true, true, function()
                guideHelper.saveGuideIndex()
            end , "zhucheng_mf_zhengchang.png", false)
            addToCurrentView(guide)
        end , 1)
    end
    if guideHelper.guideIndex == 15 then
        guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        guideHelper.saveGuideIndex()
        guideHelper.nextStep()
    end
    -- 点击章节按钮
    if guideHelper.guideIndex == 16 then
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.taskCaphterBtn, true, true, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        end , "gongyong_yindao_yuan.png", false)
        addToCurrentView(guide)
    end

    if guideHelper.guideIndex == 19 then
        local guide = guideView:getInstance()
        guide:showGuideView(mainCity.taskCaphterBtn, true, true, function()
            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
        end , "gongyong_yindao_yuan.png", false)
        addToCurrentView(guide)
    end
    if guideHelper.guideIndex == 20 then
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
    end
    if guideHelper.guideIndex == 21 and btn_ then
        -- 点击建造按钮
        local guide = guideView:getInstance()
        guide:showGuideView(btn_, true, true, function()
            guideHelper.saveGuideIndex(22)
            guideHelper.nextStep()
        end , "gongyong_anniu_huangse_zhengchang.png", false)
        addToCurrentView(guide)
        guideHelper.removeWaitLayer()
    end
--    if guideHelper.guideIndex == 22 then
--        -- 对话
--        local guide = guideView:getInstance()
--        guide:showDialog(20, function()
--            guideHelper.setGuideIndex(guideHelper.guideIndex + 1)
--            guideHelper.saveGuideIndex()
--            guideHelper.nextStep()
--        end )
--        addToCurrentView(guide)
--        guideHelper.removeWaitLayer()
--    end
    if guideHelper.guideIndex == 22 then
        if guideViewInstace ~= nil then
            guideViewInstace:close()
        end
        guideHelper.removeWaitLayer()
        guideHelper.guideIndex = guideHelper.guide_End
        -- 新手引导结束
        guideHelper.saveGuideIndex(guideHelper.guide_End)
        guideHelper.setAllBuildingTouchEnable(true)
    end
end