-- [Comment]
-- jnmo
convergeFireCell = class("convergeFireCell", function(...)
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
convergeFireCell.__index = convergeFireCell
function convergeFireCell:create(...)
    local layer = convergeFireCell.new(...)
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
function convergeFireCell:ctor()
    print("convergeFireCell ctor")
    self.pTime = nil
end
function convergeFireCell:init()
    print("convergeFireCell init")

    return true
end
 
function convergeFireCell:setDate(pData, pArmyHeight, pTeamId, LeaderBool, pLeaderName, pConverData,warType)
    if pData then
        me.clearTimer(self.pTime)
        if pData.Open == 1 then
            me.assignWidget(self, "n_r_Node_army"):setVisible(false)
            me.assignWidget(self, "n_r_Node_add"):setVisible(true)
            me.assignWidget(self, "n_r_node_not_open"):setVisible(false)
            local Panel_army = me.assignWidget(self, "Panel_army")
            Panel_army:removeAllChildren()
         --   me.assignWidget(self, "n_r_cell"):loadTexture("jihuo_beijingyuanjun_nei_wu.png", me.plistType)
            if pConverData["status"] == TEAM_RUN then
               -- me.assignWidget(self, "n_r_add_icon"):loadTexture("jihuo_anniu_jiaru_hui.png", me.plistType)
                me.Helper:grayImageView(me.assignWidget(self, "n_r_add_icon"))
                me.assignWidget(self, "n_r_add_ash"):setString("队伍已出发，不能加入")
            else
                if pConverData.soliderNum < pConverData.maxSoliderNum then
                    me.assignWidget(self, "n_r_add_icon"):loadTexture("jihuo_anniu_jiaru_zhengchang.png", me.plistType)
                    me.Helper:normalImageView (me.assignWidget(self, "n_r_add_icon"))
                    me.assignWidget(self, "n_r_add_ash"):setString("点击加入军团一起打败敌人")
                    if pConverData.playerNum == pConverData.maxPlayerNum  then
                      -- me.assignWidget(self, "n_r_add_icon"):loadTexture("jihuo_anniu_jiaru_hui.png", me.plistType)
                      me.Helper:grayImageView(me.assignWidget(self, "n_r_add_icon"))
                       me.assignWidget(self, "n_r_add_ash"):setString("集火成员数达到上限")
                    end
                else
                    --me.assignWidget(self, "n_r_add_icon"):loadTexture("jihuo_anniu_jiaru_hui.png", me.plistType)
                    me.Helper:grayImageView(me.assignWidget(self, "n_r_add_icon"))
                    me.assignWidget(self, "n_r_add_ash"):setString("部队已达到上限无法加入")
                end
            end
        elseif pData.Open == 2 then
       --     me.assignWidget(self, "n_r_cell"):loadTexture("jihuo_beijingyuanjun_nei_hui.png", me.plistType)
            me.assignWidget(self, "n_r_Node_army"):setVisible(false)
            me.assignWidget(self, "n_r_Node_add"):setVisible(false)
            me.assignWidget(self, "n_r_node_not_open"):setVisible(true)
            local Panel_army = me.assignWidget(self, "Panel_army")
            Panel_army:removeAllChildren()
        else
         --   me.assignWidget(self, "n_r_cell"):loadTexture("jihuo_beijing_you_da.png.png", me.plistType)
            me.assignWidget(self, "n_r_Node_army"):setVisible(true)
            me.assignWidget(self, "n_r_Node_add"):setVisible(false)
            me.assignWidget(self, "n_r_node_not_open"):setVisible(false)
            local Panel_army = me.assignWidget(self, "Panel_army")
            Panel_army:removeAllChildren()

            self.mData = pData
            self.mTeamID = pTeamId
            local pName = me.assignWidget(self, "n_r_army_name")
            pName:setString(pData.name)
            local pButtonLabel = "遣返"
            if warType == 1 then
               if pLeaderName == pData.name then
                  LeaderBool = false
               end
            else
                pButtonLabel = "召回"
                if pLeaderName == user.name then
                   LeaderBool = false
                end
                if pData.name ==user.name  then
                   LeaderBool = true
                else
                   LeaderBool = false 
                end
            end
            
            local pArmyNumLabel = me.assignWidget(self, "n_r_army_num")
            local pArmyNum = 0
            for key, var in pairs(pData.army) do
                pArmyNum = pArmyNum + var[2]
            end
            pArmyNumLabel:setString(pArmyNum)
            local pArmymass = me.assignWidget(self, "n_r_army_mass")
            pArmymass:setString("已集结")
            if pData.status == TEAM_ARMY_JOIN then
                --  pArmymass:setString("集结中")
            elseif pData.status == TEAM_ARMY_WAIT then
                --  pArmymass:setString("已集结")
            end
            if pData.status ~= TEAM_ARMY_WAIT and pData.status ~= THRONE_TEAM_WAIT  then 
                me.assignWidget(self, "n_r_army_time_bg"):setVisible(true)                
                self.time = pData.counttime
                if self.time > 0 then
                    pArmymass:setString("集结中")
                    me.assignWidget(self, "n_r_army_time_bg"):setVisible(true)
                else
                    pArmymass:setString("已集结")
                    me.assignWidget(self, "n_r_army_time_bg"):setVisible(false)
                end
                local pTime = me.assignWidget(self, "n_r_army_time")
                pTime:setString(me.formartSecTime(self.time))
                self.pTime = me.registTimer(-1, function(dt)
                    if self.time < 0 then
                        me.clearTimer(self.pTime)
                        me.assignWidget(self, "n_r_army_time_bg"):setVisible(false)
                        pArmymass:setString("已集结")
                    else
                        self.time = self.time - 1
                        pTime:setString(me.formartSecTime(self.time))
                    end              
                end , 1)
             else
                 me.assignWidget(self, "n_r_army_time_bg"):setVisible(false)
             end
                local pButton_launch = me.assignWidget(self,"Button_launch")
                if pArmyHeight > 0 then
                    pButton_launch:setRotation(90)
                    Panel_army:setVisible(true)
                    local pBg = me.assignWidget(self, "army_bg"):clone():setVisible(true)
                    pBg:setContentSize(cc.size(730, pArmyHeight))
                    pBg:setAnchorPoint(cc.p(0, 1))
                    pBg:setPosition(cc.p(0, 0))
                    Panel_army:addChild(pBg)
                    local pIn = 0
                    if pData.shipId ~= 0 then
                        dump(pData)
                         pIn = pIn + 1
                        local pLine = math.floor((pIn - 1) / 2)
                        local plist =(pIn - 1) % 2
                        local pConfig = cfg[CfgType.SHIP_DATA][pData.shipId]
                        local pArmyBg = me.assignWidget(self, "army_one_bg"):clone():setVisible(true)
                        me.assignWidget(pArmyBg, "army_icon"):setVisible(false)
                        local warship_icon = me.assignWidget(pArmyBg,"warship_icon"):setVisible(true)
                        warship_icon:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png")

                        local pArmyName = me.assignWidget(pArmyBg, "army_name")
                        pArmyName:setString(pConfig["name"])

                        me.assignWidget(pArmyBg, "army_num"):setVisible(false)
                        pArmyBg:setAnchorPoint(cc.p(0, 1))
                        pArmyBg:setPosition(cc.p((plist) * 365 + 2, -(pLine) * 105 - 4))
                        Panel_army:addChild(pArmyBg)
                    end
                    for key, var in pairs(pData.army) do
                        pIn = pIn + 1
                        local pLine = math.floor((pIn - 1) / 2)
                        local plist =(pIn - 1) % 2
                        pConfig = cfg[CfgType.CFG_SOLDIER][var[1]]

                        local pArmyBg = me.assignWidget(self, "army_one_bg"):clone():setVisible(true)
                        me.assignWidget(pArmyBg,"warship_icon"):setVisible(false)
                        local pIcon = me.assignWidget(pArmyBg, "army_icon"):setVisible(true)
                        pIcon:loadTexture(soldierIcon(pConfig), me.plistType)
                        local pArmyName = me.assignWidget(pArmyBg, "army_name")
                        pArmyName:setString(pConfig["name"])

                        local pArmy = me.assignWidget(pArmyBg, "army_num"):setVisible(true)
                        pArmy:setString(var[2])

                        pArmyBg:setAnchorPoint(cc.p(0, 1))
                        pArmyBg:setPosition(cc.p((plist) * 365 + 2, -(pLine) * 105 - 4))
                        Panel_army:addChild(pArmyBg)
                    end

                local pRepartriate = me.assignWidget(self, "Button_repatriate_army"):clone():setVisible(true)
                pRepartriate:setPositionY(-(math.ceil(#pData.army / 2)) * 105 - 35)
                me.assignWidget(pRepartriate, "text_title_btn"):setString(pButtonLabel)
                Panel_army:addChild(pRepartriate)
                pRepartriate:setTag(2)
                me.registGuiClickEvent(pRepartriate, function(node)
                    local pIndex = node:getTag()
                    if warType == 1 then
                       GMan():send(_MSG.worldTeamArmyReject(self.mTeamID, self.mData.armyId))
                    else
                       GMan():send(_MSG.callbackArmy(self.mData.armyId))
                       me.dispatchCustomEvent("rev_event_convergeFire")
                    end                   
                end )
                pRepartriate:setBright(LeaderBool)
                pRepartriate:setTouchEnabled(LeaderBool)
                pRepartriate:setSwallowTouches(false)
            else
                pButton_launch:setRotation(0)
                me.assignWidget(self, "Panel_army"):setVisible(false)
            end
        end
    end
end
function convergeFireCell:onEnter()
    print("convergeFireCell onEnter")

end
function convergeFireCell:onEnterTransitionDidFinish()
    print("convergeFireCell onEnterTransitionDidFinish")
end
function convergeFireCell:onExit()
    print("convergeFireCell onExit")
    me.clearTimer(self.pTime)
end



