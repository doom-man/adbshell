 --[Comment]
--jnmo
fortHeroInfo = class("fortHeroInfo",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
fortHeroInfo.__index = fortHeroInfo
function fortHeroInfo:create(...)
    local layer = fortHeroInfo.new(...)
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
function fortHeroInfo:ctor()   
    print("fortHeroInfo ctor") 
end
function fortHeroInfo:init()   
    print("fortHeroInfo init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function fortHeroInfo:onEnter()
    print("fortHeroInfo onEnter") 
	me.doLayout(self,me.winSize)  
end
battle_types = {
[1] = "城战",
[2] = "野战",
[3] = "",
[4] = "所有战斗",
}
function fortHeroInfo:setData(pData)
     if pData then        
       local pHeroConfig = cfg[CfgType.HERO][pData["heroDefid"]]
       me.assignWidget(self,"s_type_label"):setString(battle_types[pHeroConfig.battletype])
       local pHeroIcon = me.assignWidget(self,"s_icon")
       pHeroIcon:loadTexture("shengjiang_bansheng_"..pHeroConfig["icon"]..".png",me.plistType)

       local pheroName = me.assignWidget(self,"title")
       pheroName:setString(pHeroConfig["name"])

       local pSkillConfig = cfg[CfgType.CFG_SOLDIER][pData["heroDefid"]]

       local pHeroType = me.assignWidget(self,"hero_type")
       pHeroType:setString(soldierType[me.toStr(pSkillConfig["smallType"])])
       
       local pSkillData = me.split(pSkillConfig["skill"],",")
       for key, var in pairs(pSkillData) do
           local pSkillDef = cfg[CfgType.CFG_SOLDIER_SKILL][me.toNum(var)]
           if pSkillDef then
              local pSkillNode = me.assignWidget(self,"Panel_skill"):clone():setVisible(true)
              pSkillNode:setPosition(cc.p(0, 85 - (key - 1) * 35))
               
              local pSkillName = me.assignWidget(pSkillNode,"skill_name")
              pSkillName:setString(pSkillDef["name"])

              local pSkillDesc = me.assignWidget(pSkillNode,"skill_content")
              pSkillDesc:setString(pSkillDef["desc"])

              me.assignWidget(self,"skill_panel"):addChild(pSkillNode)
           end
       end
       -- 试炼指数
       local pHardStar = me.assignWidget(self,"Panel_one"):clone():setVisible(true)
       pHardStar:setPosition(cc.p(0, 115))
       local pHardName = me.assignWidget(pHardStar,"index_Content")
       pHardName:setString("试炼指数")
       self:setStar(pHeroConfig["hardstar"],pHardStar)
       me.assignWidget(self,"Panel_index"):addChild(pHardStar)
       -- 进阶指数
       local pBookStar = me.assignWidget(self,"Panel_one"):clone():setVisible(true)
       pBookStar:setPosition(cc.p(0, 75))
       local pBookName = me.assignWidget(pBookStar,"index_Content")
       pBookName:setString("进阶指数")
       self:setStar(pHeroConfig["bookstar"],pBookStar)
        me.assignWidget(self,"Panel_index"):addChild(pBookStar)
        -- 招募指数            
       local pRecruitStar = me.assignWidget(self,"Panel_one"):clone():setVisible(true)
       pRecruitStar:setPosition(cc.p(0, 35))
       local pRecruitName = me.assignWidget(pRecruitStar,"index_Content")
       pRecruitName:setString("招募指数")
       self:setStar(pHeroConfig["qijistar"],pRecruitStar)
        me.assignWidget(self,"Panel_index"):addChild(pRecruitStar)
     end
end
function fortHeroInfo:setStar(pStarNum,pNode)
     local pStar = math.floor(pStarNum / 2)
     local pmore = pStarNum % 2
      
     for var = 1 ,pStar do
         local pStarIcon = me.assignWidget(pNode,"index_star"):clone():setVisible(true)
         pStarIcon:setPosition(cc.p(90 + var * 33, 15))
         pNode:addChild(pStarIcon)
     end
     if pmore ~= 0 then
        local pStargalfIcon = me.assignWidget(pNode,"index_half_star"):clone():setVisible(true)
         pStargalfIcon:setPosition(cc.p(90 + (pStar + 1) * 33, 15))
         pNode:addChild(pStargalfIcon)
     end
end
function fortHeroInfo:onEnterTransitionDidFinish()
	print("fortHeroInfo onEnterTransitionDidFinish") 
end
function fortHeroInfo:onExit()
    print("fortHeroInfo onExit")    
end
function fortHeroInfo:close()
    self:removeFromParentAndCleanup(true)  
end
