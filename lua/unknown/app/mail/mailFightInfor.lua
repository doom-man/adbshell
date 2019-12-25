-- 战斗详情
mailFightInfor = class("mailFightInfor", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
mailFightInfor.__index = mailFightInfor
function mailFightInfor:create(...)
    local layer = mailFightInfor.new(...)
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
function mailFightInfor:ctor()
    self.closeBtn = me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
end
function mailFightInfor:close()
    print("mailFightInfor:close()")
    local closeBtn = nil
    if CUR_GAME_STATE == GAME_STATE_CITY then
        if mainCity and mainCity.mailview then
            closeBtn = mainCity.mailview.closeBtn
        end
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        if pWorldMap and pWorldMap.mailview then
            closeBtn = pWorldMap.mailview.closeBtn
        end
    end
    guideHelper.nextStepByOpt(false, closeBtn)
    self:removeFromParentAndCleanup(true)
end
function mailFightInfor:init()

    return true
end
function mailFightInfor:setData(pData, pSever)
    self.CurrentSever = pSever
    self.data = pData
    if pData ~= nil then
        self.tx = pData.x
        self.ty = pData.y

        local pAddStr = "+"
        if pData["rType"] == 1 or pData["rType"] == 3 then
            -- 我进攻
            pAddStr = "+"
        else
            pAddStr = "-"
        end
        if self.mailType == mailview.MAILRESIST then --抵御蛮族 特殊处理
            pAddStr = "+"
        end

        local pFight_Type_icon = me.assignWidget(self, "mail_fight_type")
        -- 是否为跨服争霸
        if self.mailType ~= mailview.PVP then
            if pData["loseArmy"] == 1 then

            else
                local pIcon = ccui.ImageView:create("zhanbao_beijing_tupian_yanwu.png")
                pIcon:setPosition(cc.p(pFight_Type_icon:getContentSize().width / 2, pFight_Type_icon:getContentSize().height / 2))
                pFight_Type_icon:addChild(pIcon)
            end
        else
            local pIcon = ccui.ImageView:create("kuafuzhengba_40.png")
            pIcon:setPosition(cc.p(pFight_Type_icon:getContentSize().width / 2, pFight_Type_icon:getContentSize().height / 2))
            pFight_Type_icon:addChild(pIcon)
        end
        local pVisible = false
        if me.toNum(pData["food"]) > 0 or me.toNum(pData["wood"]) > 0 or me.toNum(pData["stone"]) > 0 or me.toNum(pData["gold"]) > 0 then
            pVisible = true
        end
        me.assignWidget(self, "m_f_centre_bg"):setVisible(pVisible)
        -- 粮食
        local pm_f_c_food = me.assignWidget(self, "m_f_c_food")
        pm_f_c_food:setString(pAddStr .. pData["food"])

        -- 木材
        local pm_f_c_wood_num = me.assignWidget(self, "m_f_c_wood_num")
        pm_f_c_wood_num:setString(pAddStr .. pData["wood"])

        -- 石头
        local pm_f_c_stone = me.assignWidget(self, "m_f_c_stone")
        pm_f_c_stone:setString(pAddStr .. pData["stone"])


        -- 金币
        local pm_f_c_gold = me.assignWidget(self, "m_f_c_gold")
        pm_f_c_gold:setString(pAddStr .. pData["gold"])

        -- 坐标
        local pPoint = me.assignWidget(self, "m_f_i_point")
        if self.mailType == mailview.MAILHEROLEVEL then
            pPoint:setString("第" .. self.tx .. "关")
        elseif self.mailType==mailview.MAILDIGORE then
            local page = math.floor(self.ty/5)+1
            local oreIndex= self.ty%5+1
            local base = cfg[CfgType.ORE_GROUP][self.tx]
            pPoint:setString("("..base.name..",第"..page.."页"..oreIndex.."号)")
        elseif self.mailType == mailview.PVP then
            pPoint:setString("跨服争霸")
        else
            pPoint:setString("(" .. pData["x"] .. "," .. pData["y"] .. ")")
        end
        -- 时间
        local pTime = me.assignWidget(self, "mailfight_time")
        pTime:setString(me.GetSecTime(pData["time"], 1))

        self:scrollviewUI(pData, pVisible)
    end
end
function mailFightInfor:scrollviewUI(pData, pVisible)
    local pMy_property = pData["attacker"]["info"]["property"]
    local pRaivl_property = pData["defender"]["info"]["property"]
    local pMy_num = 0
    local pRaivl_num = 0
    for key, var in pairs(pMy_property) do
        local pPData = cfg[CfgType.LORD_INFO][var[1]]
        if pPData then
            pMy_num = pMy_num + 1
        end
    end
    for key, var in pairs(pRaivl_property) do
        local pPData = cfg[CfgType.LORD_INFO][var[1]]
        if pPData then
            pRaivl_num = pRaivl_num + 1
        end
    end
    local pPNum = 0
    pPNum = math.max(pMy_num, pRaivl_num)
    local pWidth = me.assignWidget(self, "m_f_centre_bg"):getContentSize().width
    local pNum = 35 * pPNum+20
    local pHeight = 400 + 30 + pNum
    if pNum > 0 then
        pHeight = 400 + 30 + pNum
    else
        pHeight = 370
    end

    local pGoodsNum = #pData["itemList"]
    local pPropHeight = 0
    if pGoodsNum ~= 0 then
        pPropHeight = 168 +(math.ceil(pGoodsNum / 4) -1) * 90
    end
    pHeight = pHeight + pPropHeight
    local pVisHeight = 0
    if pVisible == false then
        pVisHeight = 178
    end
    local pWarshipHeight = 270
    local pShipBoll = false
    if pData["attacker"]["infoship"] or pData["defender"]["infoship"] then
        pHeight = pHeight + pWarshipHeight
        pShipBoll = true
    end
    local pRuneHeight = 237
    local pRuneBoll = false
    if pData["attacker"]["inforune"] or pData["defender"]["inforune"] then
        pHeight = pHeight + pRuneHeight
        pRuneBoll = true
    end
    local pHeroHeight = 180
    local pHeroBoll = false
   
    if (pData["attacker"]["infohero"] and #pData["attacker"]["infohero"] > 0)
        or (pData["defender"]["infohero"] and #pData["defender"]["infohero"] > 0) then
        pHeight = pHeight + pHeroHeight
        pHeroBoll = true
    end

    local pScrollView = cc.ScrollView:create()
    pScrollView:setViewSize(cc.size(pWidth+20, 236 + pVisHeight))
    pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pScrollView:setLocalZOrder(10)
    pScrollView:setAnchorPoint(cc.p(0, 0))
    pScrollView:setPosition(cc.p(48, 29))
    pScrollView:setContentSize(cc.size(pWidth, pHeight + 3))
    pScrollView:setContentOffset(cc.p(0,(-(pHeight + 3 -(236 + pVisHeight)))))
    me.assignWidget(self, "bg_frame"):addChild(pScrollView)

    --    local pLayer = cc.LayerColor:create(cc.c3b(223,123,88))
    --    pLayer:setContentSize(cc.size(pWidth,pHeight))
    --    pLayer:setAnchorPoint(cc.p(0,0))
    --    pLayer:setPosition(cc.p(0,0))
    --    pScrollView:addChild(pLayer)

    local pNode = cc.Node:create()
    pNode:setContentSize(cc.size(pWidth, pHeight))
    pNode:setAnchorPoint(cc.p(0, 0))
    pNode:setPosition(cc.p(0, 0))
    pScrollView:addChild(pNode)


    for var = 1, 2 do
        local pSData = nil
        local pTitleStr = 1
        local pFightType = false
        if var == 1 then
            if pData["rType"] == 1 or pData["rType"] == 3 then
                pSData = pData["attacker"]
                pTitleStr = 1
            else
                pSData = pData["defender"]
                pTitleStr = 2
                pFightType = true
            end
        elseif var == 2 then
            if pData["rType"] == 1 or pData["rType"] == 3 then
                pSData = pData["defender"]
                pTitleStr = 2
                pFightType = true
            else
                pSData = pData["attacker"]
                pTitleStr = 1
            end
        end
        self:setNode(pHeight, pNode, var, pPNum, pSData, pTitleStr, pPropHeight, pData, pFightType, pShipBoll, pRuneBoll, pData.success, pHeroBoll)
    end
end
function mailFightInfor:setNode(pHeight, pNode, pVar, pPNum, pData, pTitleStr, pPropHeight, pMData, pFightType, pShipBoll, pRuneBoll, success, pHeroBoll)
    if pPropHeight ~= 0 then
        local pProp = me.assignWidget(self, "m_f_prop"):clone():setVisible(true)
        pProp:setAnchorPoint(cc.p(0, 1))
        pProp:setPosition(cc.p(2, pHeight + 1))
        pProp:setContentSize(cc.size(pProp:getContentSize().width, pPropHeight - 5))
        pNode:addChild(pProp)
        local img1 = me.assignWidget(pProp, "Image_87")
        img1:setContentSize(cc.size(1125, pPropHeight - 5))
        local img2 = me.assignWidget(pProp, "Image_55")
        img2:setContentSize(cc.size(1126.05, pPropHeight - 5))

        me.assignWidget(pProp, "tipsTxt"):setVisible(false)
        if self.mailType==mailview.MAILDIGORE  then
            local tipsTxt = me.assignWidget(pProp, "tipsTxt")
            tipsTxt:setVisible(true)
            if pMData["rType"] == 1 or pMData["rType"] == 3 then
                tipsTxt:setString("队伍回城后将获得掠夺道具")
            else
                tipsTxt:setString("队长被击败，正在挖掘的其他成员已自动返回")
            end
        end

        local pGoodsData = pMData["itemList"]
        if pGoodsData ~= nil then
            local pAddStr = "+"
            if pMData["rType"] == 1 or pMData["rType"] == 3 then
                -- 我进攻
                pAddStr = "+"
            else
                pAddStr = "-"
            end
            local goodsTitle = me.assignWidget(pProp, "m_f_c_")
            goodsTitle:setPosition(cc.p(goodsTitle:getPositionX(), pProp:getContentSize().height/2))
            local i = 0
            local j = 0
            for key, var in pairs(pGoodsData) do
                local pGoodsIcon = me.assignWidget(pProp, "m_f_prop_icon"):clone()
                pGoodsIcon:loadTexture(getItemIcon(var[1]), me.localType)
                pGoodsIcon:setPosition(cc.p(200 + 200 *(i % 4) * pGoodsIcon:getScale(), pProp:getContentSize().height - 78 - j * 110))
                pGoodsIcon:setLocalZOrder(10)
                pGoodsIcon:setVisible(true)
                pProp:addChild(pGoodsIcon)

                local pGoodsQuadlity = me.assignWidget(pProp, "m_f_prop_quality"):clone()
                pGoodsQuadlity:loadTexture(self:getGoodsQuilty(var[1]), me.localType)
                pGoodsQuadlity:setPosition(cc.p(200 + 200 *(i % 4) * pGoodsIcon:getScale(), pProp:getContentSize().height - 78 - j * 110))
                pGoodsQuadlity:setVisible(true)
                pProp:addChild(pGoodsQuadlity)

                local pGoodsNum = me.assignWidget(pProp, "m_f_prop_num"):clone()
                pGoodsNum:setString(pAddStr .. var[2])
                pGoodsNum:setPosition(cc.p((200 + 95 + 200 *(i % 4)) * pGoodsIcon:getScale(), pProp:getContentSize().height - 78 - j * 110))
                pGoodsNum:setVisible(true)
                pProp:addChild(pGoodsNum)
                i = i + 1
                if i % 4 == 0 then
                    j = j + 1
                end
            end
        end
    end
    local pWVar = 567.5 *(pVar - 1)
    local pM_f_pancel = me.assignWidget(self, "m_f_pancel"):clone():setVisible(true)
    pM_f_pancel:setAnchorPoint(cc.p(0, 1))
    pM_f_pancel:setPosition(cc.p(pWVar, pHeight - pPropHeight-7))
    pNode:addChild(pM_f_pancel)
    local pShipHeight = 0
    if pShipBoll then
        pShipHeight = 272
    end
    local pRuneHeight = 0
    if pRuneBoll then
        pRuneHeight = 237
    end
    local pHeroHeight = 0
    if pHeroBoll then
        pHeroHeight = 183
    end

    local underBgHeight = 0
    local bgUnder = me.assignWidget(self, "bg_under"):clone():setVisible(true)
    pNode:addChild(bgUnder)

    bgUnder:setPosition(cc.p(pWVar, pHeight - pPropHeight - pM_f_pancel:getContentSize().height - 5 - 105 - pShipHeight - pRuneHeight - pHeroHeight))
    underBgHeight = 35 * pPNum + 67
    bgUnder:setAnchorPoint(cc.p(0, 1))
    bgUnder:setContentSize(cc.size(556.18, underBgHeight))
    me.assignWidget(bgUnder, "bg_under_img1"):setContentSize(cc.size(556.18, underBgHeight))
    me.assignWidget(bgUnder, "bg_under_img2"):setContentSize(cc.size(559.52, underBgHeight))
    local img3 = me.assignWidget(bgUnder, "bg_under_img3")
    img3:setPosition(-1.60,underBgHeight)
    me.assignWidget(bgUnder, "Text_14"):setPositionY(underBgHeight-6)

    -- 标题
    local pTitle1 = me.assignWidget(pM_f_pancel, "m_f_p_title")
    if pData.wenming==0 then
        if pVar==1 then
            pTitle1:loadTexture("mail_fight_cell4.png", me.localType)
        else
            pTitle1:loadTexture("mail_fight_cell3.png", me.localType)
        end
    else
        pTitle1:loadTexture("wmxz_"..pData.wenming..".png", me.localType)
    end
    me.resizeImage(pTitle1, 105, 118)

    --local namestr = me.assignWidget(pTitle1,"namestr")
    --namestr:ignoreContentAdaptWithSize(true)
   -- namestr:loadTexture("mail_atktype_"..pTitleStr..".png", me.localType)



    -- 名字

    local pName = me.assignWidget(pM_f_pancel, "m_f_p_name")
    if self.mailType == mailview.MAILHEROLEVEL or self.mailType == mailview.MAILDIGORE then
        pName:setString(pData["name"])
    elseif self.mailType == mailview.PVP then
        pName:setString(pData["name"])
    else
        pName:setString(pData["name"] .. "(" .. pData["info"]["x"] .. "," .. pData["info"]["y"] .. ")")
    end

    if pTitleStr==1 then
        pName:setTextColor(cc.c3b(111, 198, 72))
    else
        pName:setTextColor(cc.c3b(223, 55, 48))
    end
    if pFightType then
        -- dump(pMData)
        if pMData.FightType == 1 then
            -- dump(pMData)
            me.assignWidget(pM_f_pancel, "m_f_fight_type"):setString("免战中......未发生战斗")
            me.assignWidget(pM_f_pancel, "m_f_Panel_type"):setVisible(false)
            me.assignWidget(pM_f_pancel, "m_f_fight_type"):setVisible(true)
        elseif pMData.FightType == 2 then
            me.assignWidget(pM_f_pancel, "m_f_fight_type"):setString("无部队")
            me.assignWidget(pM_f_pancel, "m_f_Panel_type"):setVisible(false)
            me.assignWidget(pM_f_pancel, "m_f_fight_type"):setVisible(true)
        else
            me.assignWidget(pM_f_pancel, "m_f_Panel_type"):setVisible(true)
            me.assignWidget(pM_f_pancel, "m_f_fight_type"):setVisible(false)
        end
    else
        me.assignWidget(pM_f_pancel, "m_f_Panel_type"):setVisible(true)
        me.assignWidget(pM_f_pancel, "m_f_fight_type"):setVisible(false)
    end
    -- 歼敌
    local pKill = me.assignWidget(pM_f_pancel, "m_f_p_wipe_out_num")
    pKill:setString(pData["info"]["kill"])
    -- 死亡
    local pLose = me.assignWidget(pM_f_pancel, "m_f_p_death_num")
    pLose:setString(pData["info"]["lose"])
    -- 受伤
    local pDisabled = me.assignWidget(pM_f_pancel, "m_f_p_bruised_num")
    pDisabled:setString(pData["info"]["disabled"])
    -- 剩余
    local pAlive = me.assignWidget(pM_f_pancel, "m_f_p_surplus_num")
    pAlive:setString(pData["info"]["alive"])
    local m_f_p_surplus = me.assignWidget(self, "m_f_p_surplus")
    if pMData["FighType"] == 5 and not pFightType then
        m_f_p_surplus:setString("生命")
    else
        m_f_p_surplus:setString("剩余")
    end
    -- 陷阱
    local pLoseAtkTrap = me.assignWidget(pM_f_pancel, "m_f_p_trap_num")
    if pData["loseAtkTrap"] ~= nil then
        pLoseAtkTrap:setString(pData["loseAtkTrap"])
    else
        pLoseAtkTrap:setVisible(false)
        me.assignWidget(pM_f_pancel, "m_f_p_trap"):setVisible(false)
    end
    if pShipBoll then
        local m_f_pancel_warship = me.assignWidget(self, "m_f_pancel_warship"):clone():setVisible(true)
        m_f_pancel_warship:setAnchorPoint(cc.p(0, 1))
        m_f_pancel_warship:setPosition(cc.p(pWVar, pHeight - pPropHeight - pM_f_pancel:getContentSize().height - 90))
        pNode:addChild(m_f_pancel_warship)
        local m_f_w_title = me.assignWidget(m_f_pancel_warship, "m_f_w_title")
        local Panel_ship = me.assignWidget(m_f_pancel_warship, "Panel_ship"):setVisible(true)
        if pData.infoship then
            local pShip = pData.infoship
            if pMData.rType > 2 then
                m_f_w_title:setString("战舰汇总")
                me.assignWidget(m_f_pancel_warship, "Image_41"):setVisible(true)
                me.assignWidget(m_f_pancel_warship, "Image_2"):setVisible(false)
                me.assignWidget(m_f_pancel_warship, "m_f_warship"):setVisible(false)
            else
                local pConfigShip = cfg[CfgType.SHIP_DATA][pShip.id]

                m_f_w_title:setString(pConfigShip.name)
                me.assignWidget(m_f_pancel_warship, "Image_41"):setVisible(false)
                me.assignWidget(m_f_pancel_warship, "Image_2"):setVisible(true)
                local m_f_warship = me.assignWidget(m_f_pancel_warship, "m_f_warship"):setVisible(true)
                m_f_warship:loadTexture("zhanjian_tupian_zhanjian_" .. pConfigShip.icon .. ".png")

                local LoadingBar_ship = me.assignWidget(m_f_pancel_warship, "LoadingBar_ship")
                LoadingBar_ship:setPercent(pShip.endure / pShip.maxEndure * 100)

                local m_f_warship_durable = me.assignWidget(m_f_pancel_warship, "m_f_warship_durable")
                m_f_warship_durable:enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(1, -1))

                m_f_warship_durable:setString(pShip.endure .. "/" .. pShip.maxEndure)
            end
            -- 消灭敌军
            local m_f_w_wipe_out_num = me.assignWidget(m_f_pancel_warship, "m_f_w_wipe_out_num")
            m_f_w_wipe_out_num:setString(pShip.killSolider)
            -- 打击战舰
            local m_f_w_death_num = me.assignWidget(m_f_pancel_warship, "m_f_w_death_num")
            m_f_w_death_num:setString(pShip.killShip)
            -- 弹药损耗
            local m_f_w_bruised_num = me.assignWidget(m_f_pancel_warship, "m_f_w_bruised_num")
            m_f_w_bruised_num:setString(pShip.costEndure)
            -- 获得经验
            local m_f_w_surplus_num = me.assignWidget(m_f_pancel_warship, "m_f_w_surplus_num")
            m_f_w_surplus_num:setString(pShip.exp)

        else
            m_f_w_title:setString("无战舰")
            Panel_ship:setVisible(false)
        end


    end



    if pRuneBoll then
        local runePanel = me.assignWidget(self, "runePanel"):clone():setVisible(true)
        runePanel:setAnchorPoint(cc.p(0, 1))
        runePanel:setPosition(cc.p(pWVar, pHeight - pPropHeight - pM_f_pancel:getContentSize().height - 80 - pShipHeight))
        pNode:addChild(runePanel)
        local rune_title = me.assignWidget(runePanel, "rune_title")
        if pVar == 1 then
            rune_title:setString("己方圣物")
        else
            rune_title:setString("敌方圣物")
        end
        if pData.inforune then
            local c = 0
            for k, v in ipairs(pData.inforune) do
                v.cfgId = v.id
                local runeItem = runeItem:create(me.assignWidget(me.assignWidget(self, "RuneItem"), "Panel"):clone():setVisible(true), 1)
                runeItem.nameTxt:setFontSize(36)
                runeItem:setScale(0.42)
                me.registGuiClickEvent(runeItem, function()
                    local runeDetail = runeDetailView:create("rune/runeDetailView.csb")
                    me.runningScene():addChild(runeDetail, me.MAXZORDER)
                    me.showLayer(runeDetail, "bg")
                    runeDetail:setRuneInfo(v)
                    runeDetail:hideBtn()
                end )
                if v.runeSkillId==nil then
                    v.runeSkillId=0
                end
                runeItem:setSwallowTouches(false)
                runeItem:setPosition(cc.p((k - 1) * 132 + 16, 17))
                runeItem.typeBox:setScale(1.3)
                runeItem.starNode:setAnchorPoint(cc.p(0.3, 0))
                runeItem.starNode:setScale(1.15)
                runeItem.starNode:setPositionY(66)
                runeItem:setData(v)
                runePanel:addChild(runeItem)
                c = k
            end
            for i = c + 1, 4 do
                me.assignWidget(runePanel, "rune_empty" .. i):setVisible(true)
            end
        else
            for i = 1, 4 do
                me.assignWidget(runePanel, "rune_empty" .. i):setVisible(true)
            end
        end
    end

    -- 跨服争霸上阵英雄
    if pHeroBoll then
        local heroPanel = me.assignWidget(self, "heroPanel"):clone()
        heroPanel:setVisible(true)
        heroPanel:setAnchorPoint(cc.p(0, 1))
        heroPanel:setPosition(cc.p(pWVar, pHeight - pPropHeight - pM_f_pancel:getContentSize().height - 109 - pShipHeight - pRuneHeight))
        pNode:addChild(heroPanel)
        -- 标题
        local text_title = me.assignWidget(heroPanel, "text_title")
        text_title:setString(pFightType and "守方英雄" or "攻方英雄")
        for i, v in ipairs(pData.infohero) do
            local hero_item = me.assignWidget(heroPanel, "hero_item"):clone()
            hero_item:setVisible(true)
            hero_item:setPosition(cc.p(63 + (i - 1) * 107, 63))
            heroPanel:addChild(hero_item)
            -- 英雄详情
            v.defid = v.id
            me.registGuiClickEvent(hero_item, function()
                local view = PvpHeroDetailView:create("pvp/PvpHeroDetailView.csb")
                self:addChild(view, me.MAXZORDER)
                me.showLayer(view, "img_bg")
                view:refreshView(v, true)
            end)
            -- 图标
            local img_header = me.assignWidget(hero_item, "img_header")
            img_header:ignoreContentAdaptWithSize(true)
            img_header:loadTexture(getItemIcon(v.id))
            -- 星级
            local starLv = v.level
            local panel_star = me.assignWidget(hero_item, "panel_star")
            panel_star:removeAllChildren()
            local starWidth = 20
            local startX = panel_star:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
            for j = 1, starLv do
                local img_star = ccui.ImageView:create()
                img_star:loadTexture("rune_star.png", me.localType)
                local x = startX + (-1)^j * math.ceil((j - 1) / 2) * starWidth
                local y = 8
                img_star:setPosition(cc.p(x, y))
                img_star:setScale(0.6)
                panel_star:addChild(img_star)
            end
        end
    end

    local pPropertData = pData["info"]["property"] 
    if pData.info.gArmyProperty then
        for key, var in pairs(pData.info.gArmyProperty) do
             table.insert(pPropertData,var)
        end    
    end
    -- 战斗详情
    if pVar == 1 then
        local pButton_m_f_Infor = me.assignWidget(self, "Button_m_f_Infor"):clone()
        pButton_m_f_Infor:setVisible(true)
        pButton_m_f_Infor:setPosition(cc.p(565, pHeight - pM_f_pancel:getContentSize().height - 46 - pPropHeight))
        pNode:addChild(pButton_m_f_Infor)
        pButton_m_f_Infor:setSwallowTouches(false)
        me.registGuiClickEvent(pButton_m_f_Infor, function(node)
            local pMailFightarm = mailFightarm:create("mail/mailFightSoliderInfor.csb")
            self:addChild(pMailFightarm, me.MAXZORDER)
            if self.mailType == mailview.PVP then
                pMailFightarm:setPvpMailData(clone(self.data))
            end
            pMailFightarm:setMailType(self.mailType)
            pMailFightarm:setarmData(pMData, self.CurrentSever)
            me.showLayer(pMailFightarm, "bg_frame")
        end )

        if success == false then
            me.assignWidget(pButton_m_f_Infor, "tips"):setVisible(true)
        end
    end

    if pPNum > 0 then
        if pVar == 2 then
            pWVar = pWVar - 5
        end
        local pNum = 1
        for key, var in pairs(pPropertData) do
            local pPData = cfg[CfgType.LORD_INFO][var[1]]
            if pPData then
                local pM_f_nature = me.assignWidget(self, "m_f_nature"):clone():setVisible(true)
                pM_f_nature:setPosition(280 + pWVar, pHeight - pM_f_pancel:getContentSize().height - 40 - 35 * pNum - pPropHeight - 90 - pShipHeight - pRuneHeight - pHeroHeight)
                pNode:addChild(pM_f_nature)
                -- 名称
                local pName = me.assignWidget(pM_f_nature, "m_f_n_type")
                pName:setString(pPData["name"])
                local pNumType = ""
                local pNumNature = var[2]
                if me.toNum(pPData["isPercent"]) == 1 then
                    pNumType = "%"
                    pNumNature = var[2] * 100
                end
                -- 加成
                local pParcent = me.assignWidget(pM_f_nature, "m_f_n_addNum")
                pParcent:setString(pNumNature .. pNumType)
                pNum = pNum + 1
            end
        end
        if #pPropertData == 0 then
            for i = 1, pPNum do
                local pM_f_nature = me.assignWidget(self, "m_f_nature"):clone():setVisible(true)
                pM_f_nature:setPosition(285 + pWVar, pHeight - pM_f_pancel:getContentSize().height - 40 - 35 * pNum - pPropHeight - 90 - pShipHeight - pRuneHeight - pHeroHeight)
                pNode:addChild(pM_f_nature)
                me.assignWidget(pM_f_nature, "m_f_n_type"):setVisible(false)
                pParcent = me.assignWidget(pM_f_nature, "m_f_n_addNum"):setVisible(false)
                pNum = pNum + 1
            end
        end
    else
        bgUnder:setVisible(false)
    end
end
function mailFightInfor:getGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_" .. pCfgData["icon"] .. ".png"
    return pIconStr
end
function mailFightInfor:getGoodsQuilty(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pQuiltyStr = getQuality(pCfgData["quality"])
    return pQuiltyStr
end

function mailFightInfor:setMailType(mailType)
    self.mailType = mailType
end

function mailFightInfor:onEnter()
    print("mailFightInfor:onEnter()   ")
    me.doLayout(self, me.winSize)
    guideHelper.nextStepByOpt()
end
function mailFightInfor:onExit()

end

