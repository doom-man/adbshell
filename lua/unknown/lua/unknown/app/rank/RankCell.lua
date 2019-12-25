-- [Comment]
-- jnmo
RankCell = class("RankCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1], arg[2]):clone()
        pCell:setVisible(true)
        return pCell
    end
end )
RankCell.__index = RankCell
function RankCell:create(...)
    local layer = RankCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end
function RankCell:ctor()
    --    print("RankCell ctor")
end
function RankCell:init()
    --    print("RankCell init")

    return true
end

-- 限时活动的数据
function RankCell:setActivityData(data, index)
    --    dump(data)
    local index = me.toNum(index)
    local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
    local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
    if cell_rank_bg then
        cell_rank_bg:setVisible(index % 2 == 0)
    end
    if index == 1 then
        pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
    elseif index == 2 then
        pRankIcon:loadTexture("paihang_dierming.png", me.localType)
    elseif index == 3 then
        pRankIcon:loadTexture("paihang_disanming.png", me.localType)
    else
        me.assignWidget(self, "R_cell_rank"):setString(me.toStr(index))
    end
    pRankIcon:ignoreContentAdaptWithSize(true)
    me.assignWidget(self, "R_cell_name"):setString(data.name)
    me.assignWidget(self, "R_cell_level"):setString(data.level)
    me.assignWidget(self, "R_cell_unit"):setString(data.unit)
    me.assignWidget(self, "R_cell_num"):setString(data.num)
    pRankIcon:setVisible(index <= 3)
    me.assignWidget(self, "R_cell_rank"):setVisible(index > 3)
end
function RankCell:setPeronalData(pData)
    if pData then
        --  初始化当前时代
        --        dump(pData)
        -- me.assignWidget(self,"R_cell_rank_icon"):setVisible(false)
        local pTimes = cfg[CfgType.BUILDING][pData["defId"]]["era"]
        local pStr = "黑暗时代"
        if pTimes == 0 then
            pStr = "黑暗时代"
        elseif pTimes == 1 then
            -- 封建
            pStr = "封建时代"
        elseif pTimes == 2 then
            -- 城堡
            pStr = "城堡时代"
        elseif pTimes == 3 then
            -- 帝王
            pStr = "帝王时代"
        end
        -- 排名
        local index = me.toNum(pData["rank"])
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        pRankIcon:setVisible(true)
        pRnakIng:setVisible(true)
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(index % 2 == 0)
        end
        if index == 1 then
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
            pRnakIng:setVisible(false)
        elseif index == 2 then
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
            pRnakIng:setVisible(false)
        elseif index == 3 then
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
            pRnakIng:setVisible(false)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setString(pData["rank"])
        end
        -- 名字
        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData["rname"])
        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_level")
        pLevel:setString(getLvStrByPlatform() .. "." .. pData["level"])
        -- 时代
        local pMember = me.assignWidget(self, "R_cell_times")
        pMember:setString(pStr)

        -- 地块
        local pLand = me.assignWidget(self, "R_cell_land")
        pLand:setString(pData["landbnum"])
        -- 战斗力
        local pFight = me.assignWidget(self, "R_cell_fight")
        pFight:setString(pData["fight"])
    end
end
function RankCell:setAllianceData(pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(pData["rank"])
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = pData["rank"]
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(pRank % 2 == 0)
        end
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end

        -- 联盟名字
        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData["rname"])

        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_level")
        pLevel:setString(getLvStrByPlatform() .. "." .. pData["level"])
        -- 成员
        local pMember = me.assignWidget(self, "R_cell_times")
        if pData["maxmember"] then
            pMember:setString(pData["member"] .. "/" .. pData["maxmember"])
        else
            pMember:setString(pData["member"])
        end
        --  要塞
        local pFornum = me.assignWidget(self, "R_cell_land")
        pFornum:setString(pData["fortnum"])
        -- 战斗力
        local pFight = me.assignWidget(self, "R_cell_fight")
        pFight:setString(pData["fight"])
    end
end
function RankCell:setScore_Achievement(pData)
    if pData then
        --        dump(pData)
        me.assignWidget(self, "R_cell_rank_icon"):setVisible(false)
        local pTimes = cfg[CfgType.BUILDING][pData["defId"]]["era"]
        local pStr = "黑暗时代"
        if pTimes == 0 then
            pStr = "黑暗时代"
        elseif pTimes == 1 then
            -- 封建
            pStr = "封建时代"
        elseif pTimes == 2 then
            -- 城堡
            pStr = "城堡时代"
        elseif pTimes == 3 then
            -- 帝王
            pStr = "帝王时代"
        end
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(pData["rank"])
        -- 名字
        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData["rname"])
        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_level")
        pLevel:setString(getLvStrByPlatform() .. "." .. pData["level"])
        -- 时代
        local pMember = me.assignWidget(self, "R_cell_times")
        pMember:setString(pStr)

        -- 战斗力
        local pLand = me.assignWidget(self, "R_cell_land")
        pLand:setString(pData["fight"])
        -- 积分
        local pFight = me.assignWidget(self, "R_cell_fight")
        pFight:setString(pData["score"])
    end
end
function RankCell:setScore(pData)
    if pData then
        --        dump(pData)
        me.assignWidget(self, "R_cell_rank_icon"):setVisible(false)
        local pTimes = cfg[CfgType.BUILDING][pData["defId"]]["era"]
        local pStr = "黑暗时代"
        if pTimes == 0 then
            pStr = "黑暗时代"
        elseif pTimes == 1 then
            -- 封建
            pStr = "封建时代"
        elseif pTimes == 2 then
            -- 城堡
            pStr = "城堡时代"
        elseif pTimes == 3 then
            -- 帝王
            pStr = "帝王时代"
        end
        -- 排名
        local index = me.toNum(pData["rank"])
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        pRankIcon:setVisible(true)
        pRnakIng:setVisible(true)
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(index % 2 == 0)
        end
        if index == 1 then
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
            pRnakIng:setVisible(false)
        elseif index == 2 then
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
            pRnakIng:setVisible(false)
        elseif index == 3 then
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
            pRnakIng:setVisible(false)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setString(pData["rank"])
        end
        -- 名字
        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData["rname"])
        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_level")
        pLevel:setString(getLvStrByPlatform() .. "." .. pData["level"])
        -- 时代
        local pMember = me.assignWidget(self, "R_cell_times")
        pMember:setString(pStr)

        -- 战斗次数
        local pLand = me.assignWidget(self, "R_cell_land")
        pLand:setString(pData["fighttime"])
        -- 积分
        local pFight = me.assignWidget(self, "R_cell_fight")
        pFight:setString(pData["score"])
    end
end
function RankCell:setplunder(pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "P_cell_rank")
        pRnakIng:setString(pData["rank"])
        local pRankIcon = me.assignWidget(self, "P_cell_rank_icon")
        local pRank = pData["rank"]
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end
        local pName = me.assignWidget(self, "P_cell_name")
        pName:setString(pData.rname)

        local pLevel = me.assignWidget(self, "P_cell_level")
        pLevel:setString(pData.level)

        local pNum = me.assignWidget(self, "P_cell_num")
        pNum:setString(pData.num)

        local pfood = me.assignWidget(self, "P_cell_food")
        -- 粮食
        pfood:setString(Scientific(pData.food))

        local pWood = me.assignWidget(self, "P_cell_wood")
        --  木材
        pWood:setString(Scientific(pData.wood))

        local pStone = me.assignWidget(self, "P_cell_stone")
        -- 石头
        pStone:setString(Scientific(pData.stone))

        local pGold = me.assignWidget(self, "P_cell_gold")
        -- 金子
        pGold:setString(Scientific(pData.gold))

        local pFight = me.assignWidget(self, "P_cell_fight")
        -- 战斗力
        pFight:setString(pData.fight)

        local pPoint = me.assignWidget(self, "P_cell_point")
        -- 坐标
        pPoint:setString("(" .. pData.x .. "," .. pData.y .. ")")
        --  Scientific
        local pX = math.abs(user.x - pData.x)
        local pY = math.abs(user.y - pData.y)

        local pDistenceNum = math.sqrt(pX * pX + pY * pY)
        local pDistence = me.assignWidget(self, "P_cell_distance")
        pDistence:setString("距离：" .. string.format("%.1f", pDistenceNum))
    end
end
function RankCell:setNetBattlePerson(pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(pData["rank"])
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = pData["rank"]
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end
        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData.rname)
        local R_cell_server = me.assignWidget(self, "R_cell_server")
        R_cell_server:setString(pData.server)
        local R_cell_score = me.assignWidget(self, "R_cell_score")
        R_cell_score:setString(pData.score)
    end
end
function RankCell:setNetBattleServer(pData)
    if pData then
        -- 排名
       local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(pData["rank"])
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = pData["rank"]
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end   
        local R_cell_server = me.assignWidget(self, "R_cell_server")
        R_cell_server:setString(pData.server)
        local R_cell_score = me.assignWidget(self, "R_cell_score")
        R_cell_score:setString(pData.score)
    end
end
function RankCell:setHeroLevelData(idx,pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(idx)
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = idx
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(pRank % 2 == 0)
        end
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end
        if pData.item[5] then
            me.assignWidget(self, "R_cell_area"):setString("("..pData.item[5].."区)")
            me.assignWidget(self, "R_cell_area"):setVisible(true)
        else
            me.assignWidget(self, "R_cell_area"):setVisible(false)
        end

        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData.item[3])

        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_level")
        pLevel:setString("Lv."..pData.item[4])
        
        local pNums = me.assignWidget(self, "R_cell_nums")
        pNums:setString(pData.item[2].."关")
    end
end

function RankCell:setResistData(idx,pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(idx)
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = idx
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(pRank % 2 == 0)
        end
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end

        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData.item[3])

        -- 等级
        local pdiyu = me.assignWidget(self, "R_cell_diyu")
        pdiyu:setString(pData.item[4])
        
        local pyuanzhu = me.assignWidget(self, "R_cell_yuanzhu")
        pyuanzhu:setString(pData.item[5])

        local pscore = me.assignWidget(self, "R_cell_score")
        pscore:setString(pData.item[2])
    end
end
function RankCell:setDigoreScoreData(idx,pData)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(idx)
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = idx
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(pRank % 2 == 0)
        end
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end

        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData.item[3])

        -- 等级
        local pLevel = me.assignWidget(self, "R_cell_servername")
        pLevel:setString(pData.item[4])
        
        local totalscore = me.assignWidget(self, "R_cell_totalscore")
        totalscore:setString(pData.item[2])
    end
end

function RankCell:setDigoreEnemyData(idx,pData,pa)
    if pData then
        -- 排名
        local pRnakIng = me.assignWidget(self, "R_cell_rank")
        pRnakIng:setString(idx)
        local pRankIcon = me.assignWidget(self, "R_cell_rank_icon")
        local pRank = idx
        local cell_rank_bg = me.assignWidget(self, "cell_rank_bg")
        if cell_rank_bg then
            cell_rank_bg:setVisible(pRank % 2 == 0)
        end
        if pRank == 1 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_diyiming.png", me.localType)
        elseif pRank == 2 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_dierming.png", me.localType)
        elseif pRank == 3 then
            pRankIcon:setVisible(true)
            pRnakIng:setVisible(false)
            pRankIcon:loadTexture("paihang_disanming.png", me.localType)
        else
            pRankIcon:setVisible(false)
            pRnakIng:setVisible(true)
        end

        local pName = me.assignWidget(self, "R_cell_name")
        pName:setString(pData.item[3])

        local pLevel = me.assignWidget(self, "R_cell_server")
        pLevel:setString(pData.item[4])
        
        local atktimes = me.assignWidget(self, "R_cell_atktimes")
        atktimes:setString(pData.item[2].."次")
        
        local pZuiE = me.assignWidget(self, "R_cell_zuiE")
        pZuiE:setString(pData.item[5])
        
        local pDD = me.assignWidget(self, "R_cell_dd")
        pDD:setString(pData.item[6])

        local posTxt = me.assignWidget(self, "R_cell_pos")
        -- groupId=pData.item[7]
        -- page=pData.item[8]
        -- oreId=pData.item[9]
        if pData.item[8]=="" then
            posTxt:setString("当前未在挖掘")
            me.assignWidget(self,"linkLine"):setVisible(false)
        else
            posTxt:setString("第"..pData.item[8].."页"..pData.item[9].."号矿")
            me.assignWidget(self,"linkLine"):setVisible(true)
        end
        me.registGuiClickEvent(posTxt, function(node)
            if pData.item[8]~="" then
                pa.pPerantNode:openToPage({data={page=pData.item[8]}})
                pa:close()
            end
        end)
        posTxt:setSwallowTouches(false)
    end
end

function RankCell:onEnter()
    print("RankCell onEnter")

end
function RankCell:onEnterTransitionDidFinish()
    -- print("RankCell onEnterTransitionDidFinish")
end
function RankCell:onExit()
    print("RankCell onExit")
end
function RankCell:close()
    self:removeFromParentAndCleanup(true)
end

