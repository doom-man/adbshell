--[Comment]
--jnmo
convergeReliefCell = class("convergeReliefCell",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2]):clone()
        pCell:setVisible(true)
        return pCell 
    end
end)
convergeReliefCell.__index = convergeReliefCell
function convergeReliefCell:create(...)
    local layer = convergeReliefCell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function convergeReliefCell:ctor()   
    print("convergeReliefCell ctor") 
end
function convergeReliefCell:init()   
    print("convergeReliefCell init")
	
    return true
end

function convergeReliefCell:setDate(pData,pArmyHeight)  
        me.clearTimer(self.pTime)   
        self.mTeamID = pTeamID
        self.mData = pData
        local Panel_army = me.assignWidget(self,"Panel_army")       
        Panel_army:removeAllChildren()  
        local pName = me.assignWidget(self,"relief_name")
        pName:setString(pData.name)
        pName:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))

        local pArmyNumlabel = me.assignWidget(self,"relief_army_num")
        local pArmyNum = 0
        for key, var in pairs(pData.army) do
        pArmyNum = pArmyNum + var[2]
        end
        pArmyNumlabel:setString("部队："..pArmyNum)
        pArmyNumlabel:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))

        local pCenterIcon = cfg[CfgType.BUILDING][pData.city].icon
        local pCenter = me.assignWidget(self,"relief_city_icon")
        pCenter:loadTexture("m"..pCenterIcon..".png", me.localType)
        local pFight = me.assignWidget(self,"relief_fighting")
        pFight:setString("战斗力:"..pData.fightPower)
        pFight:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))

        local pTime = me.assignWidget(self,"relief_time")
        pTime:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        local pArmymass = me.assignWidget(self,"Text_5")
        pArmymass:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
        if pData.status == TEAM_ARMY_JOIN then
            pArmymass:setString("集结中")
            me.assignWidget(self,"relief_time"):setVisible(true)
        elseif pData.status == TEAM_ARMY_WAIT then 
            pArmymass:setString("已集结")
            me.assignWidget(self,"relief_time"):setVisible(false)
        end
        self.time = pData.counttime         
        if self.time > 0 then
            pArmymass:setString("集结中")
            pTime:setString(me.formartSecTime(self.time))  
            self.pTime = me.registTimer(-1,function(dt)
            if self.time < 0 then
                me.clearTimer(self.pTime)
                me.assignWidget(self,"relief_time"):setVisible(false)
                pArmymass:setString("已集结")
            end
            self.time = self.time -1
            pTime:setString(me.formartSecTime(self.time))
          end,1)
        else
          pArmymass:setString("已集结")
          me.assignWidget(self,"relief_time"):setVisible(false)
        end
       local pButton_army_info = me.assignWidget(self,"Button_army_info")       
       pButton_army_info:setTouchEnabled(false)     
      if pArmyHeight > 0 then  
         pButton_army_info:setRotation(90)
         Panel_army:setVisible(true)         
         local pBg = me.assignWidget(self,"army_bg"):clone():setVisible(true)
         pBg:setContentSize(cc.size(1140, pArmyHeight))
         pBg:setAnchorPoint(cc.p(0,1))
         pBg:setPosition(cc.p(0,0))
         Panel_army:addChild(pBg)
         local pIn = 0
         if pData.shipId ~= 0 then
            pIn = pIn + 1
            local pLine = math.floor((pIn-1) / 3)
            local plist = (pIn-1) % 3
            local pConfig = cfg[CfgType.SHIP_DATA][pData.shipId]
            local pArmyBg = me.assignWidget(self,"army_one_bg"):clone():setVisible(true)
            me.assignWidget(pArmyBg,"army_icon"):setVisible(false)
            local pIcon = me.assignWidget(pArmyBg,"warship_icon")
            pIcon:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png")

            local pArmyName = me.assignWidget(pArmyBg,"army_name")
            pArmyName:setString(pConfig["name"])

            me.assignWidget(pArmyBg,"army_num"):setVisible(false)
            
            pArmyBg:setAnchorPoint(cc.p(0,1))
            pArmyBg:setPosition(cc.p((plist) * 385 + 2, -(pLine)*103-4))
            Panel_army:addChild(pArmyBg)        
         end
         
         for key, var in pairs(pData.army) do
                pIn = pIn + 1
                local pLine = math.floor((pIn-1) / 3)
                local plist = (pIn-1) % 3
                pConfig = cfg[CfgType.CFG_SOLDIER][var[1]]
                local pArmyBg = me.assignWidget(self,"army_one_bg"):clone():setVisible(true)
                me.assignWidget(pArmyBg,"warship_icon"):setVisible(false)

                local pIcon = me.assignWidget(pArmyBg,"army_icon"):setVisible(true)
                pIcon:loadTexture(soldierIcon(pConfig),me.plistType)

                local pArmyName = me.assignWidget(pArmyBg,"army_name")
                pArmyName:setString(pConfig["name"])

                local pArmy = me.assignWidget(pArmyBg,"army_num")
                pArmy:setString(var[2])

                pArmyBg:setAnchorPoint(cc.p(0,1))
                pArmyBg:setPosition(cc.p((plist) * 385 + 2,-(pLine)*103-4))
                Panel_army:addChild(pArmyBg)        
         end
         local pRepartriate = me.assignWidget(self,"Button_repatriate"):clone():setVisible(true)
         pRepartriate:setPositionY(-(math.ceil(pIn/3)) * 105 - 35)
         Panel_army:addChild(pRepartriate)
          
         me.registGuiClickEvent(pRepartriate,function (node)
            local pIndex = node:getTag()
             GMan():send(_MSG.worldTeamArmyReject(user.CityteamArmyteamId,self.mData.armyId))
       end)
       pRepartriate:setSwallowTouches(false)
     else
         pButton_army_info:setRotation(0)
         me.assignWidget(self,"Panel_army"):setVisible(false)
     end
end
function convergeReliefCell:onEnter()
    print("convergeReliefCell onEnter") 
	  
end
function convergeReliefCell:onEnterTransitionDidFinish()
	print("convergeReliefCell onEnterTransitionDidFinish") 
end
function convergeReliefCell:onExit()
    print("convergeReliefCell onExit")  
    me.clearTimer(self.pTime)   
end



