-- 战报兵种损失详情
mailFightarmCell = class("mailFightarmCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
mailFightarmCell.__index = mailFightarmCell
function mailFightarmCell:create(...)
    local layer = mailFightarmCell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function mailFightarmCell:ctor()  
   
end
function mailFightarmCell:init()   
    self:setContentSize(cc.size(363, 121))
    return true
end
function mailFightarmCell:setDataFIFUI(pData,pHpBool)
    if pData ~= nil then
       local pType = pData.pType
       local pSData = pData.Fdata
       if pType == 1 then -- 战舰
          local pConfig = cfg[CfgType.SHIP_DATA][pSData.id]
           me.assignWidget(self,"m_s_i_icon"):setVisible(false)  
           me.assignWidget(self,"m_s_hero_icon"):setVisible(false)
           local m_s_warship_icon = me.assignWidget(self,"m_s_warship_icon"):setVisible(true)
           m_s_warship_icon:loadTexture("zhanjian_tupian_zhanjian_"..pConfig.icon..".png")
           me.resizeImage(m_s_warship_icon, 130, 130)
             -- 兵种
           local pM_s_i_name = me.assignWidget(self,"m_s_i_name")
           pM_s_i_name:setString(pConfig["name"]) 

            -- 弹药
            local m_s_i_surplus = me.assignWidget(self,"m_s_i_surplus")
            m_s_i_surplus:setString("弹药")

            local pm_s_i_surplus_num = me.assignWidget(self,"m_s_i_surplus_num")
            pm_s_i_surplus_num:setString(pSData.endure)
            -- 打击
            local m_s_i_wipeout = me.assignWidget(self,"m_s_i_wipeout")
            m_s_i_wipeout:setString("打击")

            local pm_s_i_wipeout_num = me.assignWidget(self,"m_s_i_wipeout_num")
            pm_s_i_wipeout_num:setString(pSData.killShip)
            --歼敌
            local m_s_i_death = me.assignWidget(self,"m_s_i_death")
            m_s_i_death:setString("歼敌")

            local pm_s_i_death_num = me.assignWidget(self,"m_s_i_death_num")
            pm_s_i_death_num:setString(pSData.killSolider)
            -- 损耗
            local m_s_i_hurt = me.assignWidget(self,"m_s_i_hurt")
            m_s_i_hurt:setString("损耗")

            local pm_s_i_hurt_num = me.assignWidget(self,"m_s_i_hurt_num")
            pm_s_i_hurt_num:setString(pSData.costEndure)

       else
           local pConfig = nil
           local pOneNum = "" -- 伤病
           local pTwoNum = "" 
           local pThreeNum = ""
           local pFourNum = "" 
           local pFdata = pData.Fdata
           local pIdNum = me.toNum(pFdata[1])
           me.assignWidget(self,"m_s_warship_icon"):setVisible(false)
           if pIdNum > 0 then
                pConfig = cfg[CfgType.CFG_SOLDIER][pFdata[1]]
                pOneNum = pFdata[2]
                pTwoNum = pFdata[4]
                pThreeNum = pFdata[3]
                pFourNum = pFdata[5]
                 -- 图标
                local pIcon =  me.assignWidget(self,"m_s_i_icon"):setVisible(false)  
                
                local pIconName = soldierIcon(pConfig)         
                if pHpBool then
                   pIcon = me.assignWidget(self,"m_s_hero_icon"):setVisible(true)
                   --192.169
                   pIconName = "shenjiang_tu_texiao_"..soldierIcon(pConfig)         
                   me.assignWidget(self,"m_s_i_icon"):setVisible(false)
                   pIcon:loadTexture(pIconName,me.plistType)              
                    me.resizeImage(pIcon, 100, 100)
                   --pIcon:setScale(0.4)
                else
                   pIconName = soldierIcon(pConfig)     
                   pIcon = me.assignWidget(self,"m_s_i_icon"):setVisible(true)
                   me.assignWidget(self,"m_s_hero_icon"):setVisible(false)
                   pIcon:ignoreContentAdaptWithSize(true)

                   pIcon:loadTexture(pIconName,me.plistType)              
                    me.resizeImage(pIcon, 150, 150)
                end

                me.assignWidget(self,"m_s_i_icon_build"):setVisible(false)
           else   
                pConfig = cfg[CfgType.BUILDING][math.abs(pIdNum)]
                pOneNum = pFdata[2]
                pTwoNum = pFdata[4]
                pThreeNum = "-"
                pFourNum = "-"
                 -- 图标
                local pIcon = me.assignWidget(self,"m_s_i_icon_build"):setVisible(true)
                pIcon:loadTexture(soldierIcon(pConfig),me.plistType)           
                --pIcon:setScale(0.3)
                pIcon:ignoreContentAdaptWithSize(false)
                pIcon:setPosition(cc.p(me.assignWidget(self,"m_s_i_icon"):getPositionX()-6,me.assignWidget(self,"m_s_i_icon"):getPositionY()-20))
                me.assignWidget(self,"m_s_i_icon"):setVisible(false)
                me.resizeImage(pIcon, 150, 100)
           end
        
            -- 兵种
            local pM_s_i_name = me.assignWidget(self,"m_s_i_name")
            pM_s_i_name:setString(pConfig["name"]) 
            -- 剩余
            local m_s_i_surplus = me.assignWidget(self,"m_s_i_surplus")
            m_s_i_surplus:setString("剩余")

            local pm_s_i_surplus_num = me.assignWidget(self,"m_s_i_surplus_num")
            pm_s_i_surplus_num:setString(pOneNum)
            -- 歼敌
            local m_s_i_wipeout = me.assignWidget(self,"m_s_i_wipeout")
            m_s_i_wipeout:setString("歼敌")

            local pm_s_i_wipeout_num = me.assignWidget(self,"m_s_i_wipeout_num")
            pm_s_i_wipeout_num:setString(pTwoNum)
            --死亡
            local m_s_i_death = me.assignWidget(self,"m_s_i_death")
            m_s_i_death:setString("死亡")

            local pm_s_i_death_num = me.assignWidget(self,"m_s_i_death_num")
            pm_s_i_death_num:setString(pThreeNum)
            -- 受伤
            local m_s_i_hurt = me.assignWidget(self,"m_s_i_hurt")
            m_s_i_hurt:setString("受伤")

            local pm_s_i_hurt_num = me.assignWidget(self,"m_s_i_hurt_num")
            pm_s_i_hurt_num:setString(pFourNum)
            local m_s_i_surplus = me.assignWidget(self,"m_s_i_surplus")
            if pHpBool then
               m_s_i_surplus:setString("生命")
            else
               m_s_i_surplus:setString("剩余")
            end  
       end
      
    end
end
function mailFightarmCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function mailFightarmCell:onExit()  
end


