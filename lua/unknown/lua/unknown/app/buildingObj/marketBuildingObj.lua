--市场礼包
marketBuildingObj = class("marketBuildingObj",buildingObj)
marketBuildingObj.__index = marketBuildingObj
function marketBuildingObj:ctor()
    super(self)  
    self.awardsData = {}
    self.packageId = 0
end
function marketBuildingObj:init()
    superfunc(self,"init")
    self.gainBtn = me.assignWidget(self,"gainBtn")
    self.originX = self.gainBtn:getPositionX()
    self.originY = self.gainBtn:getPositionY()
    self.gainImg = me.assignWidget(self.gainBtn,"gain_img"):loadTexture("zhucheng_caijie_shichang.png", me.localType)
    me.registGuiClickEvent(self.gainBtn,function (node)

--       self:seeGain()
       --self:stoneParticl()
--       mainCity:ResUIAction(2)
--       mainCity:setActionNum(1,self:getToftId())
--       mAudioMusic:setPlayEffect(MUSIC_TYPE.MUSIC_EFFECT_WOOD_HARVEST,false)
       --todo gain msg
       NetMan:send(_MSG.getPackage(user.packageData.id))
    end)
   
    return true
end
function marketBuildingObj:create()
    local layer = marketBuildingObj.new()
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

function marketBuildingObj:onEnter()
    print("marketBuildingObj onEnter")
    --todo  fix bug  ani state
    superfunc(self,"onEnter") 
        self.icon:removeAllChildren()
    --    self.ani = buildingAni:createById(1121)
     --   self.ani:getAnimation():play("idle")
     --   self.icon:addChild(self.ani)   
    ----if self.state == BUILDINGSTATE_BUILD.key then
      --  self.ani:setVisible(false)
    ----elseif self.state == BUILDINGSTATE_NORMAL.key then
      if user.packageData then
        if user.packageData.status == 2 then
           self.packageId = user.packageData.award
           for key,var in pairs(user.packageData.award) do 
            table.insert(self.awardsData,var)
            end
           self:seeGain()
        end
      end  
end
function marketBuildingObj:seeGain()
                    self.gainBtn:setPosition(cc.p(self.originX-40,self.originY))
                    self.gainBtn:setVisible(true)
                    self.gainBtn:stopAllActions()
                    local pMoveBy1 = cc.MoveTo:create(1.5,cc.p(self.gainBtn:getPositionX(),self.gainBtn:getPositionY()+30))  
                    local pMoveBy2 = cc.MoveTo:create(1.5,cc.p(self.gainBtn:getPositionX(),self.gainBtn:getPositionY()-30))     
                    self.gainBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(pMoveBy1,pMoveBy2)))                          
end

-- 收集粒子
function marketBuildingObj:stoneParticl() 
    local cItem = cc.ParticleSystemQuad:create("collection_wood.plist")
    cItem:setPosition(cc.p(50*self.gainBtn:getScale(),200*self.gainBtn:getScale()))
    self:addChild(cItem, me.MAXZORDER)
      
    local function arrive(node)
        node:removeFromParentAndCleanup(true)
    end

    local callback = cc.CallFunc:create(arrive)
    cItem:runAction(cc.Sequence:create(cc.DelayTime:create(1),callback))
end

function  marketBuildingObj:initBuildForData(data_)
     superfunc(self,"initBuildForData",data_)
     mainCity.marketToftId = self:getToftId()
end



function marketBuildingObj:onExit()
    print("woodBuildingObj onExit") 
    superfunc(self,"onExit")
end


--function marketBuildingObj:RewardsAnimation(pData,pIndx)

--       local function arrive(node)
--             node:removeFromParentAndCleanup(true)           
--         end

--         local var = pData[pIndx]

--         local pRewards = cc.Layer:create()



--         local pRewardsIcon = me.assignWidget(pRewards,"rewards_icon")
--         pRewardsIcon:loadTexture(self:getGoodsIcon(var[1]),me.localType)
--         local pRewardsNum = me.assignWidget(pRewards,"rewards_num")
--         pRewardsNum:setString("×"..var[2])


--         local pMoveBy = cc.MoveBy:create(0.8,cc.p(0,90))
--         local pFadeOut = cc.FadeOut:create(0.8)
--         local pFadeOut1 = cc.FadeOut:create(0.8)
--         local pFadeOut2 = cc.FadeOut:create(0.8)
--         local pSpawn = cc.Spawn:create(pMoveBy,pFadeOut)

--         local callback = cc.CallFunc:create(arrive)
--         pRewardsIcon:runAction(pFadeOut1)
--         pRewardsNum:runAction(pFadeOut2)
--         pRewards:runAction(cc.Sequence:create(pSpawn, callback))

--end


function marketBuildingObj:getGoodsIcon(pId)
    local pCfgData = cfg[CfgType.ETC][pId]
    local pIconStr = "item_"..pCfgData["icon"]..".png"
    return pIconStr
end





 
