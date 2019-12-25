 --[Comment]
--jnmo
kingdomView_Cross_City = class("kingdomView_Cross_City",function (...)

    return cc.CSLoader:createNode("Layer_cross_city.csb")

end)
kingdomView_Cross_City.__index = kingdomView_Cross_City
function kingdomView_Cross_City:create(...)
    local layer = kingdomView_Cross_City.new(...)
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
function kingdomView_Cross_City:ctor()   
    print("kingdomView_Cross_City ctor") 
    self.pTime = nil
end
function kingdomView_Cross_City:init()   
    print("kingdomView_Cross_City init")
 
   -- me.assignWidget(self,"Cross_one"):setVisible(false)
    self.Cross_one_enter = me.assignWidget(self,"Cross_one_enter")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
--       local Cross_one_enter = me.assignWidget(self,"Cross_one_enter")          
--       me.registGuiClickEvent(Cross_one_enter, function(node)                   
--            print("Cross_one_enter")                    
--            local pData = self.pData                        
--            if pData and pData.status == 1 and  user.Cross_Sever_Status == mCross_Sever_Out then                      
--                NetMan:send(_MSG.getNetBattleDataMsg())              
--            else
--                showTips("活动未开启")     
--            end                                  
--        end)

--        local Cross_one_rank_button = me.assignWidget(self,"Cross_one_rank_button")       
--        me.registGuiClickEvent(Cross_one_rank_button, function(node)                   
--            print("Cross_one_rank_button")   
--            CrossSeverRank(function ()
--                local kingdom_Cross_rank = kingdom_Cross_rank:create("kingdom_Cross_rank.csb")
--                me.showLayer(kingdom_Cross_rank, "bg_frame")
--                if CUR_GAME_STATE == GAME_STATE_CITY then
--                   mainCity:addChild(kingdom_Cross_rank, me.MAXZORDER)
--                else
--                   pWorldMap:addChild(kingdom_Cross_rank, me.MAXZORDER)
--                end                
--            end)         
--        end)
--        local Cross_one_reward_Button = me.assignWidget(self,"Cross_one_reward_Button")  
--        me.registGuiClickEvent(Cross_one_reward_Button, function(node)                   
--            print("Cross_one_reward_Button")
--            local pData = self.pData     
--            NetMan:send(_MSG.Cross_Sever_Reward(kingdom_cross_rewards.RankRewardType,pData.id))
--        end)
--       local Cross_one_explian = me.assignWidget(self,"Cross_one_explian")  
--        me.registGuiClickEvent(Cross_one_explian, function(node)                   
--            print("Cross_one_explian")
--            local pData = self.pData   
--            if pData then
--               self:Cross_des(pData.id)
--            end  
--        end)
       self.Panel_content = me.assignWidget(self,"Panel_content")
        if self.militaryPolicySubcell == nil then
        self.militaryPolicySubcell = kingdomView_Cross:create("kingdomView_Cross.csb")
        self.militaryPolicySubcell:setCity(self)
        self.Panel_content:addChild(self.militaryPolicySubcell)  
    end
    return true
end
function kingdomView_Cross_City:setData(data)
      local data = nil
      for key, var in pairs(user.Cross_PolicyData_Military) do
           data = var
           break
      end    
      self.pData = data      
      if user.Cross_Sever_Status == mCross_Sever then
         self.Cross_one_enter:setBright(false)
         self.Cross_one_enter:setTouchEnabled(false) 
      else
          self.Cross_one_enter:setBright(true)
         self.Cross_one_enter:setTouchEnabled(true)       
      end
      if data then  
          local Cross_one_name = me.assignWidget(self,"Cross_one_name")
           Cross_one_name:setString(data.name)
           local Cross_one_time = me.assignWidget(self,"Cross_one_time")
           local pStr = "结束倒计时 "
           if data.status == 1 then
              pStr = "结束倒计时 "
           else
              pStr = "开始倒计时"
           end
           self.pTime = data.Time
           if self.pTime > 0 then                  
               Cross_one_time:setString(pStr..me.formartSecTime(self.pTime))          
               self.mTime = me.registTimer(-1,function (dt)
                    if self.pTime > 0 then
                       self.pTime = self.pTime -1
                       Cross_one_time:setString(pStr..me.formartSecTime(self.pTime))
                    else
                       me.clearTimer(self.mTime)
                       Cross_one_time:setString("活动已经结束")
                    end
               end,1)
            else
                Cross_one_time:setString("活动已经结束")
            end
        end
end
function kingdomView_Cross_City:Cross_des(id)
    local Cross_des_bg = me.assignWidget(self,"Cross_des_bg"):setVisible(true)
    local Text_des = me.assignWidget(self,"Text_des")
    local pDef = cfg[CfgType.CROSS_ACTIVEITY_DEF][id]
    Text_des:setString(pDef["des"])
    me.registGuiTouchEventByName(self,"Panel_8",function (node)
       me.assignWidget(self,"Cross_des_bg"):setVisible(false)
    end)    
end
function kingdomView_Cross_City:update(msg)
    if checkMsg(msg.t, MsgCode.CROSS_SEVER_REWARD) then -- 奖励
         if self.kingdom_cross_rewards == nil then
            self.kingdom_cross_rewards = nil
            if msg.c.type == kingdom_cross_rewards.RankRewardType or msg.c.type == kingdom_cross_rewards.totalRewardType then
                self.kingdom_cross_rewards = kingdom_cross_rewards:create("kingdom_cross_rewards.csb")          
            end          
            self.kingdom_cross_rewards:setRewardType(msg.c.type,msg.c.stp,msg.c.award,function ()
                self.kingdom_cross_rewards = nil
            end)
            self:addChild(self.kingdom_cross_rewards)
        else
            self.kingdom_cross_rewards:setRewardType(msg.c.type,msg.c.stp,msg.c.award,function ()
                self.kingdom_cross_rewards = nil
            end)
            self.kingdom_cross_rewards:setRewardInfos()
        end
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_CROSS_APPLY_AUTH) then -- 奖励
       self:close()
    end
end
function kingdomView_Cross_City:onEnter()
    print("kingdomView_Cross_City onEnter") 
	me.doLayout(me.assignWidget(self,"fixLayout"),me.winSize) 
     self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end) 
end
function kingdomView_Cross_City:onEnterTransitionDidFinish()
	print("kingdomView_Cross_City onEnterTransitionDidFinish") 
end
function kingdomView_Cross_City:onExit()
    print("kingdomView_Cross_City onExit")    
    me.clearTimer(self.mTime)
    UserModel:removeLisener(self.modelkey)
end
function kingdomView_Cross_City:close()
    self:removeFromParentAndCleanup(true)  
end

