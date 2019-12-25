TASK_TYPE = {
    CREBUILDING = "creBuilding",
    -- 建造房子
    UPBUILDING = "upBuilding",
    -- 升级房子
    UPBUILDINGNUM = "upBuildNum",
    -- 升级至xx等级，和xx个数量
    GATHER = "gather",
    -- 收集
    FARMERALLOT = "farmerAllot",
    -- 农民分配
    TRADEARMY = "tradeArmy",
    -- 训练士兵
    SOLDIERUPLEVEL = "soldierUpLevel",
    --士兵升级
    CAPLAND = "capLand",
    -- 跳转外城
    BATTLEBYROAD = "battleByRoad",
    -- 跳转外城
    PILLAGE = "pillage",
    -- 跳转外城
    EXPLORE = "explore",
    -- 跳转外城
    DETECT = "detect",
    -- 跳转外城
    BUILDSTATION = "buildStation",
    -- 跳转外城
    READREPORT = "readReport",
    -- 查看战报
    ITEMUSE = "itemUse",
    -- 查看背包
    COLLECT = "collect",
    -- 采集
    JOINUNIONS = "joinUnions",
    -- 加入联盟
    UNIONHELP = "unionHelp",
    -- 联盟帮助
    STUDYTECH = "studyTech",
    -- 学习科技
    UPTECH = "upTech",
    -- 升级科技
    HELP = "help",
    -- 治疗伤兵
    COMPOSE = "compose",
    -- 考古合成
    DIG = "dig",
    -- 开始考古
    TAXATION = "taxation",
    -- 征税
    WHEEL = "integralWheel",
    -- 转盘
    EVENT = "event",
    -- 探索宝箱/商队/贼兵        跳转外城
    PVPCENTERVIC = "pvpCenterVic",
    -- 进攻玩家主城              跳转外城
    PVPKILLNUM = "pvpKillNum",
    -- 击杀玩家部队              跳转外城
    PVPDEFVIC = "pvpDefVic",
    -- 城市防守胜利次数
    DAILYBUILDING = "dailyBuilding",
    -- 建造升级或建造
    DAILYTECH = "dailyTech",
    -- 科技升级或研究
    RELICSEARCH = "relicSearch",
    -- 搜寻圣物
    RELICCOMP = "relicComp",
    -- 搜寻合成
    RELICFIGHT = "relicFight",-- 挑战圣物
} 

-- 根据任务类型执行对应的跳转操作
TASK_JUMPTYPE = {
    [TASK_TYPE.DAILYTECH] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToTechBuilding()
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.DAILYBUILDING] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tar = nil
            local tType = nil
            for key, var in pairs(mainCity.buildingMoudles) do
                local tmp = var:getData():getDef()
                if var:getState() == BUILDINGSTATE_NORMAL.key then
                    tar = var
                    tType = tmp.type
                    break
                end
            end
            if tar ~= nil and tType ~= nil then
                jumpTypeByTarget(tar, tType)
                -- 如果有空闲的建筑物，则跳转升级,没有则打开建造UI
            end
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.WHEEL] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            mainCity:jumpToPromotion(ACTIVITY_ID_TURNPLATE)
        elseif pWorldMap then
            pWorldMap:jumpToPromotion(ACTIVITY_ID_TURNPLATE)
        end
    end,

    [TASK_TYPE.PVPDEFVIC] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.PVPCENTERVIC] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.PVPKILLNUM] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.EVENT] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.TAXATION] = function(valueStr)

        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local center = mainCity.buildingMoudles[user.centerBuild.index]
            if center ~= nil then
                cameraLookAtNode(center, function()
                    center:showBuildingMenu()
                end )
            end
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.CREBUILDING] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local bType, bNum = tmpStr[1], tmpStr[2]
            local tmpNum = 0
            for key, var in pairs(mainCity.buildingMoudles) do
                local tmp = var:getData():getDef()
                if tmp.type == bType then
                    tmpNum = tmpNum + 1
                end
            end
            if me.toNum(tmpNum) >= me.toNum(bNum) then
                -- 如果有在建的，则跳转升级
                jumpToTargetExt(bType, true)
            else
                --- 引导建造军营
                if guideHelper.guideIndex == 20 then
                    mainCity.bshopBox = buildShopView:create("buildShopLayer.csb")
                    mainCity.bshopBox:setGuideTarget(bType, true)
                    mainCity:addChild(mainCity.bshopBox, me.MAXZORDER)
                else
                    mainCity.bshopBox = buildShopView:create("buildShopLayer.csb")
                    mainCity.bshopBox:setGuideTarget(bType)
                    mainCity:addChild(mainCity.bshopBox, me.MAXZORDER)
                    -- me.showLayer(mainCity.bshopBox, "shopbg")
                end
            end
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.UPBUILDING] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            jumpToTargetExt(tmpStr[1], false)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.UPBUILDINGNUM] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local bType, bLevel, bNum = tmpStr[1], tmpStr[2], tmpStr[3]
            jumpToTargetExt2(bType, bLevel)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.GATHER] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToResourceTarget()
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.FARMERALLOT] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local allot = allotLayer:create("allotLayer.csb")
            allot:initialize()
            mainCity:addChild(allot, me.MAXZORDER)
            me.showLayer(allot, "bg")
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.TRADEARMY] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local function callBack(node)
                NetMan:send(_MSG.prodSoldierView(TaskHelper.bTarget:getToftId()))
            end
            if tmpStr[1] ~= "any" then
                TaskHelper.setArmyID(tmpStr[2])
                TaskHelper.bTarget = jumpToTargetExt(tmpStr[1], true, callBack)
            else
                local types = { }
                types[#types + 1] = "barrack"
                types[#types + 1] = "range"
                types[#types + 1] = "horse"
                types[#types + 1] = "siege"
                types[#types + 1] = "wonder"
                TaskHelper.bTarget = jumpToAnyArmyBuildingByTypes(types, callBack)
            end
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,
    [TASK_TYPE.SOLDIERUPLEVEL] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local function callBack(node)
                NetMan:send(_MSG.prodSoldierView(TaskHelper.bTarget:getToftId()))
            end
            if tmpStr[1] ~= "any" then
                TaskHelper.setArmyID(tmpStr[2])
                TaskHelper.bTarget = jumpToTargetExt(tmpStr[1], true, callBack)
            else
                local types = { }
                types[#types + 1] = "barrack"
                types[#types + 1] = "range"
                types[#types + 1] = "horse"
                types[#types + 1] = "siege"
                types[#types + 1] = "wonder"
                TaskHelper.bTarget = jumpToAnyArmyBuildingByTypes(types, callBack)
            end
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,
    
    [TASK_TYPE.CAPLAND] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.EXPLORE] = function(valueStr)
--        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
--            local guide = guideView:getInstance()
--            if guide.anim ~= nil then
--                guide:close()
--                guide = guideView:getInstance()
--            end
--            guide:showGuideView(mainCity.battleBtn, false, false)
--            mainCity:addChild(guide, me.GUIDEZODER)
--        end
            if CUR_GAME_STATE == GAME_STATE_CITY then
                mainCity:cloudClose( function(node)
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    loadlayer:setOpenOpt(3)
                    me.runScene(loadlayer)
                end )       
            else                  
                pWorldMap:cloudClose( function(node)
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    loadlayer:setOpenOpt(3)
                    me.runScene(loadlayer)
                end )              
            end
    end,

    [TASK_TYPE.DETECT] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.BATTLEBYROAD] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.PILLAGE] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.BUILDSTATION] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.READREPORT] = function(valueStr)
        SharedDataStorageHelper():setUserMailType(3)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            mainCity.mailview = mailview:create("mailview.csb")
            mainCity:addChild(mainCity.mailview, me.MAXZORDER)
            me.showLayer(mainCity.mailview, "bg_frame")
            me.assignWidget(mainCity, "mail_red_hint"):setVisible(false)
        elseif pWorldMap then
            pWorldMap.mailview = mailview:create("mailview.csb")
            pWorldMap:addChild(pWorldMap.mailview, me.MAXZORDER)
            me.showLayer(pWorldMap.mailview, "bg_frame")
            me.assignWidget(pWorldMap, "mail_red_hint"):setVisible(false)
        end
    end,

    [TASK_TYPE.ITEMUSE] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local itemID = tmpStr[1]
            if me.toNum(itemID) then
                TaskHelper.setItemID(me.toNum(itemID))
            end
            mainCity.backpack = BackpackView:create("backpackdialog.csb")
            mainCity:addChild(mainCity.backpack, me.MAXZORDER);
            me.showLayer(mainCity.backpack, "bg_frame")
        elseif pWorldMap then
            local tmpStr = me.split(valueStr, "|")
            local itemID = tmpStr[1]
            if me.toNum(itemID) then
                TaskHelper.setItemID(me.toNum(itemID))
            end
            pWorldMap.backpack = BackpackView:create("backpackdialog.csb")
            pWorldMap:addChild(pWorldMap.backpack, me.MAXZORDER);
            me.showLayer(pWorldMap.backpack, "bg_frame")
        end
    end,

    [TASK_TYPE.COLLECT] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToRandomRes()
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.JOINUNIONS] = function(valueStr)
        jumpToAlliancecreateView()
    end,

    [TASK_TYPE.UNIONHELP] = function(valueStr)
        NetMan:send(_MSG.helpListFamily())
        TaskHelper.modelkey = UserModel:registerLisener( function(msg)
            UserModel:removeLisener(TaskHelper.modelkey)
            local pAllianceHelp = allianceHelpView:create("alliance/alliancehelp.csb")
            pAllianceHelp:setCloseEmpty()
            if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
                mainCity:addChild(pAllianceHelp, me.MAXZORDER)
            elseif pWorldMap then
                pWorldMap:addChild(pAllianceHelp, me.MAXZORDER)
            end
            me.showLayer(pAllianceHelp, "bg_frame")
        end )
    end,

    [TASK_TYPE.STUDYTECH] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local function callBack(node)
                if TaskHelper.bTarget then
                    local def = TaskHelper.bTarget:getDef()
                    if def.type == cfg.BUILDING_TYPE_TOWER then
                        local converge = convergeView:create("convergeView.csb")
                        mainCity:addChild(converge, me.MAXZORDER)
                        me.showLayer(converge, "bg")
                        buildingOptMenuLayer:getInstance():clearnButton()
                    else
                        TaskHelper.setTechIDAndType(tmpStr, 1)
                        local tv = techView:getInstance()
                        tv:initData(TaskHelper.bTarget:getDef().id, TaskHelper.bTarget.toftid)
                        mainCity:addChild(tv, 100)
                        me.showLayer(tv, "bg")
                    end
                end
            end
            TaskHelper.bTarget = jumpToTargetExt(tmpStr[1], true, callBack)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.UPTECH] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local tmpStr = me.split(valueStr, "|")
            local function callBack(node)
                TaskHelper.setTechIDAndType(tmpStr, 2)
                local tv = techView:getInstance()
                tv:initData(TaskHelper.bTarget:getDef().id, TaskHelper.bTarget.toftid)
                mainCity:addChild(tv, 100)
                me.showLayer(tv, "bg")
            end
            TaskHelper.bTarget = jumpToTargetExt(tmpStr[1], true, callBack)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.HELP] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToTargetExt("abbey", true, function()
                NetMan:send(_MSG.revertSoldierInit())
            end )
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,

    [TASK_TYPE.COMPOSE] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            mainCity.archbool = false
            local pBookMewnu = cfg[CfgType.BOOKMENU]
            local BookMenuId = mAppBookMenuId
            NetMan:send(_MSG.initBook(BookMenuId))
            showWaitLayer()
        elseif pWorldMap then
            pWorldMap.archbool = false
            local pBookMewnu = cfg[CfgType.BOOKMENU]
            local BookMenuId = mAppBookMenuId
            NetMan:send(_MSG.initBook(BookMenuId))
            showWaitLayer()
        end
    end,

    [TASK_TYPE.DIG] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,
    [TASK_TYPE.RELICSEARCH] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToTargetAndShowMenu(cfg.BUILDING_TYPE_ALTAR)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,
    [TASK_TYPE.RELICCOMP] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            jumpToTargetAndShowMenu(cfg.BUILDING_TYPE_ALTAR)
        elseif pWorldMap then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(pWorldMap.homeBtn, false, false)
            pWorldMap:addChild(guide, me.GUIDEZODER)
        end
    end,
    [TASK_TYPE.RELICFIGHT] = function(valueStr)
        if CUR_GAME_STATE == GAME_STATE_CITY and mainCity then
            local guide = guideView:getInstance()
            if guide.anim ~= nil then
                guide:close()
                guide = guideView:getInstance()
            end
            guide:showGuideView(mainCity.battleBtn, false, false)
            mainCity:addChild(guide, me.GUIDEZODER)
        end
    end,
}

TaskHelper = { }
TaskHelper.bTarget = nil -- 要跳转的目标建筑物moudle
TaskHelper.nArmyID = nil -- 要训练的士兵id
function TaskHelper.setArmyID(armyId)
    TaskHelper.nArmyID = armyId
end
function TaskHelper.getArmyID()
    return TaskHelper.nArmyID
end

TaskHelper.nItemID = nil -- 要使用的道具id
function TaskHelper.setItemID(itemId)
    TaskHelper.nItemID = itemId
end
function TaskHelper.getItemID()
    return TaskHelper.nItemID
end

TaskHelper.nTechID = nil
TaskHelper.nTechType = nil
-- @param techIds:  如果是研究新科技，type_=1，techIds为defid;  如果是升级科技，type_=2,techIds为类型techid类型号；
function TaskHelper.setTechIDAndType(techIds, type_)
    if techIds == nil or type_ == nil then
        TaskHelper.nTechID = nil
        TaskHelper.nTechType = nil
        return
    end
    local techid = nil
    for key, var in pairs(techIds) do
        local tmpStr = me.split(var, ",")
        if tmpStr and tmpStr[2] and me.toNum(tmpStr[1]) == me.toNum(user.countryId) then
            techid = tmpStr[2]
        end
    end
    TaskHelper.nTechID = techid
    TaskHelper.nTechType = type_
end
function TaskHelper.getTechIDAndType()
    return TaskHelper.nTechID, TaskHelper.nTechType
end
-- 跳转充值界面 
function TaskHelper.jumToPay()
    --    mainCity.bshopBox = buildShopView:create("buildShopLayer.csb")
    --    mainCity.bshopBox:setGuideTarget(buildShopView.SHOPTYPE_IAP)
    --    mainCity:addChild(mainCity.bshopBox, me.MAXZORDER)
    --    me.showLayer(mainCity.bshopBox, "shopbg")
    toRechageShop()
end
-- 任务跳转
function TaskHelper.taskJump(tData_)
    local def = tData_:getDef()
    local tmpStr = me.split(def.comConType, ":")
    if TASK_JUMPTYPE[tmpStr[1]] then
        TASK_JUMPTYPE[tmpStr[1]](tmpStr[2])
    else
        __G__TRACKBACK__("找不到对应的跳转函数")
    end
end
-- 任务跳转
function TaskHelper.taskCaphterJump(def)
    local tmpStr = me.split(def.comConType, ":")
    if TASK_JUMPTYPE[tmpStr[1]] then
        TASK_JUMPTYPE[tmpStr[1]](tmpStr[2])
    else
        __G__TRACKBACK__("找不到对应的跳转函数")
    end
end
