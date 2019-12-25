-- [Comment]
-- jnmo
convergeallianceCell = class("convergeallianceCell", function(...)
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
convergeallianceCell.__index = convergeallianceCell
function convergeallianceCell:create(...)
    local layer = convergeallianceCell.new(...)
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
function convergeallianceCell:ctor()
    print("convergeallianceCell ctor")
    self.pTime = nil
end
function convergeallianceCell:init()
    print("convergeallianceCell init")
    self.Button_Convage = me.assignWidget(self,"Button_Convage")
    return true
end

function convergeallianceCell:setData(pData)
    if pData then
        me.clearTimer(self.pTime)
        local pBgStr = "lianmeng_5.png"
        if pData.warType == 0 then
            pBgStr = "lianmeng_6.png"
        end
        local pBg = me.assignWidget(self, "kind_bg")
        pBg:loadTexture(pBgStr, me.plistType)
        local pName = me.assignWidget(self, "con_name")
        pName:setString(pData.CaptainName)

        local pPoint = me.assignWidget(self, "con_point")
        pPoint:setString("(" .. pData.x .. "," .. pData.y .. ")")
        me.registGuiClickEventByName(self,"con_point",function (node)
            LookMap(cc.p(pData.x,pData.y),"convergeView","allianceview")
        end)
        local pCenter = me.assignWidget(self, "con_city_icon")
        if pData.ConergeType == 0 then
           local pCenterIcon = cfg[CfgType.BUILDING][pData.centerId].icon
           pCenter:loadTexture("m" .. pCenterIcon .. ".png", me.plistType)
           pCenter:setScale(0.5)
        elseif pData.ConergeType == 2 then
           pCenter:setScale(0.5)
           pCenter:ignoreContentAdaptWithSize(true)
           pCenter:loadTexture("dragon.png", me.plistType)
        else
           pCenter:loadTexture("wz.png", me.plistType)
           pCenter:setScale(0.4)
        end

        local pCountTime = me.assignWidget(self, "con_count_time")
        pCountTime:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        local pMarchStr = ""
        if pData.warType == 1 then
           if pData.status == TEAM_RUN or pData.status == THRONE_TEAM_RUN then
              pMarchStr = "行军中"
           elseif pData.status == TEAM_WAIT or pData.status == THRONE_TEAM_WAIT then
              pMarchStr = "集结中"
          end
        else
           if pData.status == TEAM_RUN then
              pMarchStr = "敌军逼近中"
           elseif pData.status == TEAM_WAIT then
              pMarchStr = "敌军集结中"
          end
        end
        
        self.time = pData.countTime
        if self.time > 0 then
            pCountTime:setString(pMarchStr .. me.formartSecTime(pData.countTime))
        else
            pCountTime:setString("已集结")
        end
        self.pTime = me.registTimer(-1, function(dt)
            self.time = self.time - 1
            if self.time < 0 then
                me.clearTimer(self.pTime)
                pCountTime:setString("已集结")
            else
                pCountTime:setString(pMarchStr .. me.formartSecTime(self.time))
            end
        end , 1)
        local pFightType = me.assignWidget(self, "con_fight_type")
        -- 阴影
        pFightType:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "img_target"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_attack_name"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_par_attack_name"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_peib_num"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_defend_name"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_par_defend_name"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        me.assignWidget(self, "con_hostility_num"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        if pData.warType == 1 then
            -- 进攻
--            me.assignWidget(self, "con_attack_icon"):setPosition(cc.p(374, 129))
--            me.assignWidget(self, "con_defend_icon"):setPosition(cc.p(374, 41))
            local pAttack = pData.attacker
            local pAttackName = me.assignWidget(self, "con_attack_name")
            local pAttackFamilyName  = pAttack.family
            if pAttackFamilyName == "" then
               pAttackFamilyName ="" 
            else
               pAttackFamilyName = "(" .. pAttackFamilyName .. ")"           
            end
            pAttackFamilyName = pAttack.camp..pAttackFamilyName
            me.assignWidget(self.Button_Convage, "text_title"):setString("前往集结")
            self.Button_Convage:loadTextures("ui_ty_button_cheng_154x56.png.png", "", "", me.localType)
            pAttackName:setString(pAttackFamilyName .. pAttack.leader)
            pFightType:setString("集火")
           -- pAttackName:setTextColor(me.convert3Color_("#6BAEFB"))
            --pName:setTextColor(me.convert3Color_("#CA3119"))
            --pFightType:setTextColor(me.convert3Color_("#CA3119"))
            --pCountTime:setTextColor(me.convert3Color_("#CA3119"))
            local pNameStr = ""
            for key, var in pairs(pAttack.playerlist) do
                if key == 1 then
                    pNameStr = var
                else
                    pNameStr = pNameStr .. "," .. var
                end
            end

            local pArtName = me.assignWidget(self, "con_par_attack_name")
            pArtName:setString(pNameStr)

            local pPeopleNum = me.assignWidget(self, "con_peib_num")
            pPeopleNum:setString(pAttack.playernum .. "/" .. pAttack.playmaxNum)
            --pPeopleNum:setTextColor(me.convert3Color_("#6BAEFB"))
            -- 防御
            if pData.ConergeType == 0  then
                local pDefener = pData.defener
                local pDefenerName = me.assignWidget(self, "con_defend_name")
                local pDefenerFamilyName  = pDefener.family
                if pDefenerFamilyName == "" then
                   pDefenerFamilyName =""   
                else
                   pDefenerFamilyName = "(" .. pDefenerFamilyName .. ")"     
                end
                pDefenerFamilyName = pDefener.camp..pDefenerFamilyName

                pDefenerName:setString(pDefenerFamilyName .. pDefener.leader)
                --pDefenerName:setTextColor(me.convert3Color_("#CA3119"))
                local pDefNameStr = ""
                for key, var in pairs(pDefener.playerlist) do
                    if key == 1 then
                        pDefNameStr = var
                    else
                        pDefNameStr = pDefNameStr .. "," .. var
                    end
                end
                local pDefArtName = me.assignWidget(self, "con_par_defend_name")
                pDefArtName:setString(pDefNameStr)

                local pDefPepole = me.assignWidget(self, "con_hostility_num")
                pDefPepole:setString(pDefener.playernum)
                --pDefPepole:setTextColor(me.convert3Color_("#CA3119"))
            elseif pData.ConergeType == 2  then
                local pDefenerName = me.assignWidget(self, "con_defend_name")
                pDefenerName:setString("远古暴龙")

                local pDefArtName = me.assignWidget(self, "con_par_defend_name")
                pDefArtName:setString("")

                local pDefPepole = me.assignWidget(self, "con_hostility_num")
                pDefPepole:setString("")
            else
                local pDefenerName = me.assignWidget(self, "con_defend_name")
                pDefenerName:setString("王座")

                local pDefArtName = me.assignWidget(self, "con_par_defend_name")
                pDefArtName:setString("")

                local pDefPepole = me.assignWidget(self, "con_hostility_num")
                pDefPepole:setString("")
            end
           
        elseif pData.warType == 0 then
--            me.assignWidget(self, "con_attack_icon"):setPosition(cc.p(374, 41))
--            me.assignWidget(self, "con_defend_icon"):setPosition(cc.p(374, 129))
            local pAttack = pData.attacker
            local pAttackName = me.assignWidget(self, "con_attack_name")
            local pAttackFamilyName  = pAttack.family
            if pAttackFamilyName == "" then
               pAttackFamilyName ="" 
            else
               pAttackFamilyName = "(" .. pAttackFamilyName .. ")"           
            end
            pAttackFamilyName = pAttack.camp..pAttackFamilyName
            self.Button_Convage:loadTextures("ui_ty_button_lv154x56.png", "", "", me.localType)
            me.assignWidget(self.Button_Convage, "text_title"):setString("前往援助")
            pAttackName:setString(pAttackFamilyName .. pAttack.leader)
            pFightType:setString("防御")
            --pAttackName:setTextColor(me.convert3Color_("#CA3119"))
            --pName:setTextColor(me.convert3Color_("#6BAEFB"))
            --pFightType:setTextColor(me.convert3Color_("#6BAEFB"))
            --pCountTime:setTextColor(me.convert3Color_("#6BAEFB"))
            local pNameStr = ""
            for key, var in pairs(pAttack.playerlist) do
                if key == 1 then
                    pNameStr = var
                else
                    pNameStr = pNameStr .. "," .. var
                end
            end
            local pArtName = me.assignWidget(self, "con_par_attack_name")
            pArtName:setString(pNameStr)

            local pPeopleNum = me.assignWidget(self, "con_peib_num")
            pPeopleNum:setString(pAttack.playernum.."/".. pAttack.playmaxNum)
            --pPeopleNum:setTextColor(me.convert3Color_("#CA3119"))
            -- 防御
            local pDefener = pData.defener
            local pDefenerFamilyName  = pDefener.family
            if pDefenerFamilyName == "" then
               pDefenerFamilyName = "" 
            else
               pDefenerFamilyName = "(" .. pDefenerFamilyName .. ")"       
            end
            pDefenerFamilyName = pDefener.camp..pDefenerFamilyName

            local pDefenerName = me.assignWidget(self, "con_defend_name")
            pDefenerName:setString(pDefenerFamilyName .. pDefener.leader)
            --pDefenerName:setTextColor(me.convert3Color_("#6BAEFB"))
            local pDefNameStr = ""
            for key, var in pairs(pDefener.playerlist) do
                if key == 1 then
                    pDefNameStr = var
                else
                    pDefNameStr = pDefNameStr .. "," .. var
                end
            end
            local pDefArtName = me.assignWidget(self, "con_par_defend_name")
            pDefArtName:setString(pDefNameStr)

            local pPeopleNum1 = me.assignWidget(self, "con_hostility_num")
            pPeopleNum1:setString(pDefener.playernum)
            --pPeopleNum1:setTextColor(me.convert3Color_("#6BAEFB"))
        end

        if pData.isJoin==1 then
            me.assignWidget(self.Button_Convage, "text_title"):setString("查看详情")
            self.Button_Convage:loadTextures("ui_ty_button_lv154x56.png", "", "", me.localType)
        end
    end
end
function convergeallianceCell:onEnter()
    print("convergeallianceCell onEnter")

end
function convergeallianceCell:onEnterTransitionDidFinish()
    print("convergeallianceCell onEnterTransitionDidFinish")
end
function convergeallianceCell:onExit()
    print("convergeallianceCell onExit")
    me.clearTimer(self.pTime)
end



