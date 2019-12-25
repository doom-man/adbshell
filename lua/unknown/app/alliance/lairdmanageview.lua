-- 领主管理界面 -- 2015-12-16
lairdmanageview = class("lairdmanageview", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
lairdmanageview.__index = lairdmanageview
function lairdmanageview:create(...)
    local layer = lairdmanageview.new(...)
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
lairdmanageview.MEMBER = 1                -- 成员管理
lairdmanageview.IN_APPLIIA = 2            -- 邀请 
lairdmanageview.APPLY = 3                  -- 申请
lairdmanageview.STUDY_SKILL = 4           -- 学习技能
lairdmanageview.EXIT = 5                  -- 退出联盟
lairdmanageview.CAPTIVE = 6               --下属成员
 
lairdmanageview.SORT_LEVEL = 11 --  等级  
lairdmanageview.SORT_POWER = 12 --  战斗力
lairdmanageview.SORT_CONTRIBUTION = 13 -- 贡献
lairdmanageview.SORT_TIMES = 14 -- 时代
lairdmanageview.SORT_LANDNUM = 15 -- 领地数量
function lairdmanageview:ctor()
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end )
    self.LairbType = lairdmanageview.MEMBER
    self.InviteOpen = false
    self.OldSortType = 0
    self.mBoolSort  = true
    self.TableMange = nil
    self.mOffset = cc.p(0,0)
end
function lairdmanageview:close()
    self:removeFromParentAndCleanup(true)
    self.allianceview = allianceview:create("alliance/allianceview.csb")
    self.allianceview:setUpdataUI()
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity:addChild(self.allianceview, me.MAXZORDER)
        mainCity.allianceExitview = self.allianceview
    else
        pWorldMap:addChild(self.allianceview, me.MAXZORDER)
        pWorldMap.allianceExitview = self.allianceview
    end
    me.showLayer(self.allianceview, "bg_frame")
end
function lairdmanageview:init()

    -- 成员管理
    self.btn_member = me.registGuiClickEventByName(self, "Button_member_manage", function(node)
        self:setButton(self.btn_member, false)
        self:setButton(self.btn_in_applica, true)
        self:setButton(self.btn_shop, true)
        self:setButton(self.btn_study_skill, true)
        self:setButton(self.btn_exit, true)
        self:setButton(self.btn_captive, true)
        self.LairbType = lairdmanageview.MEMBER
        --  self:setLairbType()
        me.tableClear(user.familyMemberList)
        -- 联盟成员数据置空
        NetMan:send(_MSG.getListMember())
        -- 获取联盟成员列表
    end )

    -- 下属成员管理
    self.btn_captive = me.registGuiClickEventByName(self, "Button_captive", function(node)
        self:setButton(self.btn_member, true)
        self:setButton(self.btn_in_applica, true)
        self:setButton(self.btn_shop, true)
        self:setButton(self.btn_study_skill, true)
        self:setButton(self.btn_exit, true)
        self:setButton(self.btn_captive, false)
        self.LairbType = lairdmanageview.CAPTIVE
        NetMan:send(_MSG.getCaptiveList())
        self:setLairbType()
    end )

    -- 邀请
    self.btn_in_applica = me.registGuiClickEventByName(self, "Button_invite_application", function(node)
        self:setButton(self.btn_member, true)
        self:setButton(self.btn_in_applica, false)
        self:setButton(self.btn_shop, true)
        self:setButton(self.btn_study_skill, true)
        self:setButton(self.btn_exit, true)
        self:setButton(self.btn_captive, true)
        self.LairbType = lairdmanageview.IN_APPLIIA
        me.tableClear(user.familyRequestMemberInit)
        -- 联盟申请置空
        NetMan:send(_MSG.requestMemberFamily())
        -- 获取联盟邀请列表
        -- self:setLairbType()
    end )
    -- 申请
    self.btn_shop = me.registGuiClickEventByName(self, "Button_apply", function(node)
        self:setButton(self.btn_member, true)
        self:setButton(self.btn_in_applica, true)
        self:setButton(self.btn_shop, false)
        self:setButton(self.btn_study_skill, true)
        self:setButton(self.btn_exit, true)
        self:setButton(self.btn_captive, true)
        self.LairbType = lairdmanageview.APPLY
        me.tableClear(user.familyInviteMemberInit)
        -- 联盟申请置空
        NetMan:send(_MSG.inviteMemberFamily())
        -- 获取联盟邀请列表
    end )
    -- 学习技能
    self.btn_study_skill = me.registGuiClickEventByName(self, "Button_study_skill", function(node)
        self:setButton(self.btn_member, true)
        self:setButton(self.btn_in_applica, true)
        self:setButton(self.btn_shop, true)
        self:setButton(self.btn_study_skill, false)
        self:setButton(self.btn_exit, true)
        self:setButton(self.btn_captive, true)
        self.LairbType = lairdmanageview.STUDY_SKILL
        self:setLairbType()
    end )
    -- 退出联盟
    self.btn_exit = me.registGuiClickEventByName(self, "Button_alliance_exit", function(node)
        self:setButton(self.btn_member, true)
        self:setButton(self.btn_in_applica, true)
        self:setButton(self.btn_shop, true)
        self:setButton(self.btn_study_skill, true)
        self:setButton(self.btn_exit, false)
        self:setButton(self.btn_captive, true)
        self.LairbType = lairdmanageview.EXIT
        self:setLairbType()
    end )

    self:setButton(self.btn_member, false)
    self:setLairbType()
    self:setPower()

    return true
end
function lairdmanageview:setPower()
    local pData1 = user.familyMember
    if pData1["degree"] == 4 then
        -- 成员
        self.btn_exit:setPosition(cc.p(self.btn_in_applica:getPositionX(), self.btn_in_applica:getPositionY()))
        self.btn_in_applica:setVisible(false)
        self.btn_shop:setVisible(false)
        self.btn_study_skill:setVisible(false)
    elseif pData1["degree"] == 3 then
        -- 官员
        self.btn_exit:setPosition(cc.p(self.btn_shop:getPositionX(), self.btn_shop:getPositionY()))
        self.btn_shop:setVisible(false)
        self.btn_study_skill:setVisible(false)
    else
        self.btn_study_skill:setVisible(false)
    end
end
function lairdmanageview:setButton(button, b)
    button:setEnabled(b)
    local title = me.assignWidget(button, "Text_title")
    if title ~= nil then
        if b then
            title:setTextColor(cc.c3b(0x1b, 0x1b, 0x04))
            title:enableShadow(cc.c4b(0x68, 0x65, 0x61, 0xff), cc.size(2, -2))
        else
            title:setTextColor(cc.c3b(0xe9, 0xdc, 0xaf))
            title:enableShadow(cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(2, -2))
        end
    end
end
function lairdmanageview:setMemberSort(pData,pType,pLType)    
        local pTab = pData
        local pfamilyMenberList = { }
        self.OldSortType = pType
        for key, var in pairs(pTab) do
            table.insert(pfamilyMenberList, var)
        end
        if table.maxn(pfamilyMenberList) ~= 0 then
            local function MenberLevel(pa, pb)
                if self.mBoolSort  then
                    if pa["level"] > pb["level"] then
                      return  true        
                    end
                else
                     if pa["level"] < pb["level"] then
                        return  true        
                     end
                end          
               end
             local function MenberPower(pa, pb)
                 if self.mBoolSort then
                     if pa["power"] > pb["power"] then
                        return true         
                    end
                 else
                      if pa["power"] < pb["power"] then
                        return true         
                      end
                 end              
            end
            local function MenberContribution(pa, pb)
               if self.mBoolSort then
                   if pa["contribution"] > pb["contribution"] then
                    return true                      
                   end
               else
                   if pa["contribution"] < pb["contribution"] then
                    return true                            
                   end
               end               
            end
          local function MenberTimes(pa, pb)  -- 时代
               local pATimes = cfg[CfgType.BUILDING][pa["clv"]]["era"]
               local pBTimes = cfg[CfgType.BUILDING][pb["clv"]]["era"]
               if self.mBoolSort then
                   if pATimes > pBTimes then
                    return true                      
                   end
               else
                   if pATimes < pBTimes then
                    return true                            
                   end
               end               
            end
          local function MenberLandNum(pa, pb)  -- 领地数量
               if self.mBoolSort then
                   if me.toNum(pa["landSize"]) > me.toNum(pb["landSize"]) then
                    return true                      
                   end
               else
                   if me.toNum(pa["landSize"]) < me.toNum(pb["landSize"]) then
                    return true                            
                   end
               end               
            end
        if pType == lairdmanageview.SORT_LEVEL then
            table.sort(pfamilyMenberList, MenberLevel)
        elseif pType == lairdmanageview.SORT_POWER then
            table.sort(pfamilyMenberList, MenberPower)
        elseif pType == lairdmanageview.SORT_CONTRIBUTION then
            table.sort(pfamilyMenberList, MenberContribution)
        elseif pType == lairdmanageview.SORT_TIMES then
            table.sort(pfamilyMenberList, MenberTimes)
        elseif pType == lairdmanageview.SORT_LANDNUM then
            table.sort(pfamilyMenberList, MenberLandNum)
        end
        if pLType == lairdmanageview.MEMBER then -- 成员
            me.assignWidget(self, "m_m_Node_tab"):removeAllChildren()      
           self:initTable(pfamilyMenberList) 
          -- self:setMemberSortWidget()
        elseif pLType == lairdmanageview.CAPTIVE then --下属成员
            me.assignWidget(self, "m_c_Node_tab"):removeAllChildren()                                 
            self:initCaptiveTable(pfamilyMenberList)   
         elseif pLType == lairdmanageview.IN_APPLIIA then --邀请
            me.assignWidget(self, "m_a_Node_tab"):removeAllChildren()                            
            self:applyTable(pfamilyMenberList)
         elseif pLType == lairdmanageview.APPLY then --邀请
            me.assignWidget(self, "Node_i_a_tab"):removeAllChildren()                            
            self:InviteTable(pfamilyMenberList)
        end
       
     end
end
function lairdmanageview:setMemberSortWidget()
        if self.LairbType == lairdmanageview.MEMBER then     -- 成员管理          
        -- 等级
        local pData = user.familyMemberList
        local pLevel = me.assignWidget(self,"m_m_level")
        me.registGuiClickEvent(pLevel,function (node)
                if self.OldSortType == lairdmanageview.SORT_LEVEL then
                    self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pData,lairdmanageview.SORT_LEVEL,self.LairbType)
        end)
        -- 战力
        local pFight = me.assignWidget(self,"m_m_fight")
        me.registGuiClickEvent(pFight,function (node)
                if self.OldSortType == lairdmanageview.SORT_POWER and self.mBoolSort then
                   self.mBoolSort = false
                   
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pData,lairdmanageview.SORT_POWER,self.LairbType)
        end)
        -- 贡献
        local pContribution = me.assignWidget(self,"m_m_contribution")
        me.registGuiClickEvent(pContribution,function (node)
                if self.OldSortType == lairdmanageview.SORT_CONTRIBUTION then
                self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pData,lairdmanageview.SORT_CONTRIBUTION,self.LairbType)
        end)
     elseif self.LairbType == lairdmanageview.CAPTIVE then -- 下属成员
         -- 时代
         local pMailFiTab = CaptiveMgr:getCapticesList().list
        local pContribution = me.assignWidget(self,"m_c_times")
        me.registGuiClickEvent(pContribution,function (node)
                if self.OldSortType == lairdmanageview.SORT_TIMES then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_TIMES,self.LairbType)
        end)
        -- 领地数量
        local pContributionnum = me.assignWidget(self,"m_c_num")
        me.registGuiClickEvent(pContributionnum,function (node)
                if self.OldSortType == lairdmanageview.SORT_LANDNUM then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_LANDNUM,self.LairbType)
        end)
     elseif self.LairbType == lairdmanageview.IN_APPLIIA then -- 邀请列表
        -- 等级
         local pMailFiTab = user.familyRequestMemberInit
         local pContributionlevel = me.assignWidget(self,"m_a_level")
         me.registGuiClickEvent(pContributionlevel,function (node)
                if self.OldSortType == lairdmanageview.SORT_LEVEL then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_LEVEL,self.LairbType)
         end)
         -- 战力
         local pContributionfight = me.assignWidget(self,"m_a_fight")
         me.registGuiClickEvent(pContributionfight,function (node)
                if self.OldSortType == lairdmanageview.SORT_POWER then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_POWER,self.LairbType)
         end)
     elseif self.LairbType == lairdmanageview.APPLY then -- 申请列表
                   -- 等级
         local pMailFiTab = user.familyInviteMemberInit
         local pContributionlevel = me.assignWidget(self,"Text_8")
         me.registGuiClickEvent(pContributionlevel,function (node)
                if self.OldSortType == lairdmanageview.SORT_LEVEL then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_LEVEL,self.LairbType)
         end)
         -- 战力
         local pContributionfight = me.assignWidget(self,"Text_9")
         me.registGuiClickEvent(pContributionfight,function (node)
                if self.OldSortType == lairdmanageview.SORT_POWER then
                   self.mBoolSort = not self.mBoolSort
                else
                    self.mBoolSort = true
                end
                self:setMemberSort(pMailFiTab,lairdmanageview.SORT_POWER,self.LairbType)
         end)
     end
end
function lairdmanageview:setMineInfo(pData)
      self.pmineNum = 0
      self.pSumNum = 0
      for key, var in pairs(pData) do
          if me.toNum(var.uid) == me.toNum(user.uid) then
             self.pmineNum = key             
          end
          self.pSumNum = self.pSumNum +1
      end
      me.registGuiClickEventByName(self,"Button_mine",function (node)
           if self.TableMange and self.pSumNum > 6 then
              if self.pmineNum < 7 then                
                 self.TableMange:setContentOffset(cc.p(0, -(self.pSumNum * 70 - 470)))                     
              elseif self.pmineNum > self.pSumNum - 6 then
                 self.TableMange:reloadData()
                 self.TableMange:setContentOffset(cc.p(0, 0))            
              else
                  local pOffestY = 470 - self.pSumNum * 70
                  self.TableMange:setContentOffset(cc.p(0, pOffestY + (self.pmineNum - 6) * 70))
              end
           end
      end)
end
function lairdmanageview:setLairbType()
    
    local funTab = {
        [lairdmanageview.MEMBER] = {widget = me.assignWidget(self, "Node_member_manage"), 
                                    fun = function ()
                                        me.assignWidget(self, "m_m_Node_tab"):removeAllChildren()
                                        self.TableMange = nil
                                        local pTab = user.familyMemberList
                                        local pfamilyMenberList = { }
                                        self.degreeList={[2]=0, [3]=0}
                                        for key, var in pairs(pTab) do
                                            table.insert(pfamilyMenberList, var)
                                            if self.degreeList[var.degree] then
                                                self.degreeList[var.degree]=self.degreeList[var.degree]+1
                                            end
                                        end
                                        if table.maxn(pfamilyMenberList) ~= 0 then
                                            local function Menber(pa, pb)
                                                if pa["degree"] == pb["degree"] then
                                                    return me.toNum(pa["power"]) > me.toNum(pb["power"])
                                                else
                                                    return pa["degree"] < pb["degree"]
                                                end

                                            end

                                            table.sort(pfamilyMenberList, Menber)
                                            self:initTable(pfamilyMenberList)
                                                                   
                                            self:setMemberSortWidget()
                                            self:setMineInfo(pfamilyMenberList)
                                            dump(self.mOffset)
                                            if self.mOffset.x ~= 0 or self.mOffset.y ~= 0  then
                                               
                                               self.TableMange:reloadData()
                                               self.TableMange:setContentOffset(self.mOffset)
                                               self.mOffset = cc.p(0,0)
                                            end               
                                            self.pTime = nil
                                            if user.familyabdicatetime > 0 then                                                                                       
                                                self.pTime = me.registTimer(-1,function(dt)
                                                  if user.familyabdicatetime == 0 then
                                                     me.clearTimer(self.pTime)
                                                     print("1111111")
                                                     self.mOffset = self.TableMange:getContentOffset()                                                    
                                                     NetMan:send(_MSG.getFamilyInfor())
                                                     NetMan:send(_MSG.getListMember())  -- 请求联盟成员数据
                                                  end
                                                user.familyabdicatetime = user.familyabdicatetime -1                                                                   
                                                end,1)
                                            end
                                        end
                                    end },
        [lairdmanageview.IN_APPLIIA] = {widget = me.assignWidget(self, "Node_apply"), 
                                        fun = function ()
                                            me.assignWidget(self, "m_a_Node_tab"):removeAllChildren()
                                            self:InviteInput()
                                            local pTab = user.familyRequestMemberInit

                                            local familyRequestMemberInit = { }
                                            for key, var in pairs(pTab) do
                                                table.insert(familyRequestMemberInit, var)
                                            end
                                              local function Menber(pa, pb)
                                                    if pa["inviteStatus"] == pb["inviteStatus"] then
                                                        return me.toNum(pa["power"]) > me.toNum(pb["power"])
                                                    else
                                                        return pa["inviteStatus"] < pb["inviteStatus"]
                                                    end

                                                end
                                                table.sort(familyRequestMemberInit, Menber) 
                                            if table.maxn(familyRequestMemberInit) ~= 0 then
                                                self:applyTable(familyRequestMemberInit)
                                                self:setMemberSortWidget()
                                            end
                                        end },
         [lairdmanageview.APPLY] = {widget = me.assignWidget(self, "Node_invite_application"), 
                                    fun = function ()
                                        me.assignWidget(self, "Node_i_a_tab"):removeAllChildren()
                                        self.userLevel = ""
                                        -- 等级限制
                                        self.userFight = ""
                                        -- 战斗力限制
                                        local pData = user.famliyInit

                                        if pData ~= nil then
                                            self.userLevel = pData["minLevel"]
                                            self.userFight = pData["minPower"]
                                        end
                                        self:allianceinvite()
                                        self:refreshInvite()
                                        local pTab = user.familyInviteMemberInit

                                        local familyInviteMemberInit = { }
                                        for key, var in pairs(pTab) do
                                            table.insert(familyInviteMemberInit, var)
                                        end
                                        -- dump(familyInviteMemberInit)
                                        if table.maxn(familyInviteMemberInit) ~= 0 then
                                            self:InviteTable(familyInviteMemberInit)
                                            self:setMemberSortWidget()
                                        end
                                    end },
         [lairdmanageview.STUDY_SKILL] = {widget = nil, 
                                    fun = function ()
                                    end },
         [lairdmanageview.EXIT] = {widget = me.assignWidget(self, "Node_alliance_exit"), 
                                    fun = function ()
                                        self:allianceExit()
                                    end },
         [lairdmanageview.CAPTIVE] = {widget = me.assignWidget(self, "Node_captive"), 
                                    fun = function ()
                                        me.assignWidget(self, "m_c_Node_tab"):removeAllChildren()
                                        local pMailFiTab = CaptiveMgr:getCapticesList().list
                                        
                                        if pMailFiTab then
                                           self:initCaptiveTable(pMailFiTab)
                                           self:setMemberSortWidget()
                                        end                                       
                                        me.assignWidget(self,"Image_attacked"):setVisible(CaptiveMgr:isCaptured())
                                        if CaptiveMgr:isCaptured() then
                                          me.assignWidget(self, "Button_captive_worker"):setVisible(false)
                                          me.assignWidget(self, "Text_13"):setVisible(false)
                                          me.assignWidget(self, "captive_worker_num"):setVisible(false)
                                        end
                                        me.assignWidget(self,"captive_worker_num"):setString("+"..self:getCaptive())
                                        me.registGuiClickEventByName(self,"Button_captive_worker",function (node)
                                            self.globalItems = me.createNode("Node_alliance_worker.csb")                                       
                                            me.registGuiClickEventByName(self.globalItems, "close", function(node)        
                                                self.globalItems:removeFromParentAndCleanup(true)
                                            end)
                                            me.registGuiClickEventByName(self.globalItems, "btn_ok", function(node)        
                                                self.globalItems:removeFromParentAndCleanup(true)
                                            end)
                                            self.globalItems:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))
                                            me.runningScene():addChild(self.globalItems,me.POPUPZODER)
                                       end)

                                    end }, 
     }

    for k, v in pairs(funTab) do
        if v.widget then
            if k == self.LairbType then
                v.widget:setVisible(true)
                v.fun()
            else
                v.widget:setVisible(false)
            end
        end
    end    
end
function lairdmanageview:getCaptive()
    local pNum = 0
    if CaptiveMgr:getCapticesList().list then    
      for key, var in pairs(CaptiveMgr:getCapticesList().list) do
         local pTimes = cfg[CfgType.BUILDING][var["clv"]]["era"]
         if pTimes > 1 then
            pNum = pNum + 1
         end
      end
    end
    return pNum
end
-- 返回选中格子的坐标，参数：第几个格子，table的个数
function lairdmanageview:getCellPoint(pTag, TableNum)
    pTag = me.toNum(pTag)
    local pRow = math.floor(pTag - 1)
    -- 行数
    local pPointX = 1097 / 2 + 4
    local pPointY =(TableNum - pRow) * 94 - 47
    return pPointX, pPointY
end 
function lairdmanageview:setDegree(pData, pUid)

    local pMyData = user.familyMember
    local pMyDegree = pMyData["degree"]
    -- 我的职位
    local pDegree = pData["degree"]
    -- 点击人的职位
    local pAppoint = true
    --   dump(pMyData)
    --   dump(pData)
    -- 禅让盟主
    if pMyDegree == 1 then
    else
        pAppoint = false
    end

    -- 副盟主
    if pMyDegree == 1 and pDegree == 2 then
        pAppoint = true
    else
        pAppoint = false
    end
    -- 官员
    if pMyDegree < 3 and(pMyDegree - pDegree) < 0 and pDegree == 3 then
        pAppoint = true
    else
        pAppoint = false
    end
    -- 成员
    if pMyDegree < 3 and pDegree == 4 and(pMyDegree - pDegree) < 0 then
        pAppoint = true
    else
        pAppoint = false
    end

    -- 辞退
    if pMyDegree < 3 and(pMyDegree - pDegree) < 0 then
        pAppoint = true
    else
        pAppoint = false
    end
    if pUserUid == pData["uid"] then
        pAppoint = false
    end
    return pAppoint
end
-- 成员管理
function lairdmanageview:initTable(pMailFiTab)
    local iNum = #pMailFiTab
    local pHeight = 0
    local pUserUid = user.uid
    self.TableMange = nil
    -- 自己的uid
    --    local pLayer = cc.LayerColor:create(cc.c3b(144,144,100))
    --    pLayer:setAnchorPoint(cc.p(0,0))
    --    pLayer:setContentSize(cc.size(1102,pHeight))
    --    pLayer:setPosition(cc.p(0,0))
    --    pNode:addChild(pLayer)

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 1151, 70
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        local pLairbmembercell
        if nil == cell then
            cell = cc.TableViewCell:new()
            pLairbmembercell = Lairbmembercell:create(self, "m_m_cell")
            pLairbmembercell:setVisible(true)
            pLairbmembercell:setData(pMailFiTab[idx + 1], pUserUid)
            local pBuutonappoint = me.assignWidget(pLairbmembercell, "m_m_cell_appoint_button")
            pBuutonappoint:setTag(idx + 1)
            pBuutonappoint:setContentSize(cc.size(132, 39))
            me.assignWidget(pBuutonappoint, "text_title"):enableShadow(cc.c4b(0, 0, 0, 255), cc.size(-1, -1))
            local pButtonPoint = me.assignWidget(pLairbmembercell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
            print("--------------")
            me.registGuiClickEvent(pButtonPoint, function(node)               
                    local pIndx = me.toNum(node:getTag())
                    local pData = pMailFiTab[pIndx]
                    local pX = pData["x"]
                    local pY = pData["y"]
                    local pMyData = user.familyMember
                    local pMyDegree = pMyData["degree"]
                     
                    if pMyDegree ~= 4 then
                        self:setLookMap(cc.p(pX,pY))
                    end
            end )
            local pCancel = me.assignWidget(pLairbmembercell,"m_m_cell_cancel_button")
            pCancel:setContentSize(cc.size(132, 39))
            me.registGuiClickEvent(pCancel, function(node) 
                    local pStr = "是否取消禅让"
                    me.showMessageDialog(pStr, function(args)
                        if args == "ok" then
                           me.clearTimer(self.pTime)        
                           NetMan:send(_MSG.cancelDegreeFamily())  -- 取消禅让      
                        end
                    end )      
                   
            end )

            me.registGuiClickEvent(pBuutonappoint, function(node)
               -- print("--------------")
                self.selectImg:setPosition(cc.p(self:getCellPoint(node:getTag(), iNum)))
                self.selectImg:setVisible(true)
                local pIndx = me.toNum(node:getTag())
                 print("-----------"..pIndx)
                local lairbappoint = lairappoint:create("alliance/lairdappoint.csb")
                self:addChild(lairbappoint, me.MAXZORDER);
                lairbappoint:setPitchOn(self.selectImg, pMailFiTab[pIndx],pParent,self.degreeList)
                me.showLayer(lairbappoint, "bg_frame")
            end )
            local pAppoint = self:setDegree(pMailFiTab[idx + 1], pUserUid)
            if pAppoint == false then
                pBuutonappoint:setTouchEnabled(false)
                pBuutonappoint:setBright(false)
                me.assignWidget(pBuutonappoint, "text_title"):setTextColor(cc.c3b(0x86, 0x86, 0x86))
            else
                pBuutonappoint:setBright(true)
                pBuutonappoint:setTouchEnabled(true)
                me.assignWidget(pBuutonappoint, "text_title"):setTextColor(cc.c3b(0xff, 0xff, 0xff))
            end
            pButtonPoint:setSwallowTouches(false)
            pBuutonappoint:setSwallowTouches(false)
            pLairbmembercell:setPosition(cc.p(0, 0))
            cell:addChild(pLairbmembercell)
        else
            pLairbmembercell = me.assignWidget(cell, "m_m_cell")
            pLairbmembercell:setData(pMailFiTab[idx + 1], pUserUid)
            local pBuutonappoint = me.assignWidget(pLairbmembercell, "m_m_cell_appoint_button")
            pBuutonappoint:setTag(idx + 1)
            me.registGuiClickEvent(pBuutonappoint, function(node)
               -- print("--------------")
                self.selectImg:setPosition(cc.p(self:getCellPoint(node:getTag(), iNum)))
                self.selectImg:setVisible(true)
                local pIndx = me.toNum(node:getTag())
                 --print("--------------"..pIndx)
                local lairbappoint = lairappoint:create("alliance/lairdappoint.csb")
                self:addChild(lairbappoint, me.MAXZORDER);
                lairbappoint:setPitchOn(self.selectImg, pMailFiTab[pIndx],pParent,self.degreeList)
                me.showLayer(lairbappoint, "bg_frame")
            end )
            local pButtonPoint = me.assignWidget(pLairbmembercell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
            local pAppoint = self:setDegree(pMailFiTab[idx + 1], pUserUid)
            if pAppoint == false then
                pBuutonappoint:setTouchEnabled(false)
                pBuutonappoint:setBright(false)
                me.assignWidget(pBuutonappoint, "text_title"):setTextColor(cc.c3b(0x86, 0x86, 0x86))
            else
                pBuutonappoint:setBright(true)
                pBuutonappoint:setTouchEnabled(true)
                me.assignWidget(pBuutonappoint, "text_title"):setTextColor(cc.c3b(0xff, 0xff, 0xff))
            end
        end
        if idx%2==0 then
            --pLairbmembercell:loadTexture("alliance_alpha_bg.png", me.localType)
            me.assignWidget(pLairbmembercell, "panel_mask"):setVisible(true)
        else
            --pLairbmembercell:loadTexture("alliance_cell_bg1.png", me.localType)
            me.assignWidget(pLairbmembercell, "panel_mask"):setVisible(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(1151, 470))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "m_m_Node_tab"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

    self.selectImg = ccui.ImageView:create()
    self.selectImg:loadTexture("lianmeng_beijing_xuanzhong_guang.png", me.localType)
    self.selectImg:setLocalZOrder(10)
    self.selectImg:setVisible(false)
    tableView:addChild(self.selectImg)
    self.TableMange = tableView
end
-- 下属成员管理
function lairdmanageview:initCaptiveTable(pMailFiTab)
    local iNum = #pMailFiTab
    local pHeight = 0
    me.assignWidget(self,"m_c_c_cell"):setVisible(false)
    local pUserUid = user.uid

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 1151, 70
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        local pCaptiveMemberCell
        if nil == cell then
            cell = cc.TableViewCell:new()
            pCaptiveMemberCell = captiveMemberCell:create(self, "m_c_c_cell")
            pCaptiveMemberCell:setVisible(true)
            pCaptiveMemberCell:setAnchorPoint(cc.p(0,0))
            pCaptiveMemberCell:setPosition(cc.p(0,0))
            pCaptiveMemberCell:setData(pMailFiTab[idx + 1])
            local pButtonPoint = me.assignWidget(pCaptiveMemberCell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
            me.registGuiClickEvent(pButtonPoint, function(node)
                    local pIndx = me.toNum(node:getTag())
                    local pData = pMailFiTab[pIndx]
                    local pX = pData["x"]
                    local pY = pData["y"]
                    self:setLookMap(cc.p(pX,pY))
            end )
            pButtonPoint:setSwallowTouches(false)
            cell:addChild(pCaptiveMemberCell)
        else
            pCaptiveMemberCell = me.assignWidget(cell, "m_c_c_cell")
            pCaptiveMemberCell:setVisible(true)
            pCaptiveMemberCell:setData(pMailFiTab[idx + 1])
            local pButtonPoint = me.assignWidget(pCaptiveMemberCell, "Button_Point")
            pButtonPoint:setTag(idx + 1)
        end
        if idx%2==0 then
            --pCaptiveMemberCell:loadTexture("alliance_alpha_bg.png", me.localType)
            me.assignWidget(pCaptiveMemberCell, "panel_mask"):setVisible(true)
        else
            --pCaptiveMemberCell:loadTexture("alliance_cell_bg1.png", me.localType)
            me.assignWidget(pCaptiveMemberCell, "panel_mask"):setVisible(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(1151, 470))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "m_c_Node_tab"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

--    self.selectImg = ccui.ImageView:create()
--    self.selectImg:loadTexture("lianmeng_beijing_xuanzhong_guang.png", me.localType)
--    self.selectImg:setLocalZOrder(10)
--    self.selectImg:setVisible(false)
--    tableView:addChild(self.selectImg)
end
-- 邀请
function lairdmanageview:applyTable(pMailFiTab)
    local iNum = #pMailFiTab
    local pHeight = 0
    --    local pLayer = cc.LayerColor:create(cc.c3b(144,144,100))
    --    pLayer:setAnchorPoint(cc.p(0,0))
    --    pLayer:setContentSize(cc.size(1102,pHeight))
    --    pLayer:setPosition(cc.p(0,0))
    --    pNode:addChild(pLayer)
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 805, 70
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        local pLairbmembercell
        if nil == cell then
            cell = cc.TableViewCell:new()
            pLairbmembercell = Lairbmembercell:create(self, "m_a_cell")
            pLairbmembercell:setVisible(true)
            pLairbmembercell:setApplyData(pMailFiTab[idx + 1])
            local pBuutonappoint = me.assignWidget(pLairbmembercell, "m_m_cell_appoint_button")
            pBuutonappoint:setTag(idx + 1)
            me.registGuiClickEvent(pBuutonappoint, function(node)
                local pIdx = node:getTag()
                NetMan:send(_MSG.requestFamily(pMailFiTab[pIdx]["uid"]))
                -- 邀请盟友
            end )
            pBuutonappoint:setSwallowTouches(false)
            pLairbmembercell:setPosition(cc.p(0, 0))
            cell:addChild(pLairbmembercell)
        else
            pLairbmembercell = me.assignWidget(cell, "m_a_cell")
            pLairbmembercell:setApplyData(pMailFiTab[idx + 1])
            local pBuutonappoint = me.assignWidget(pLairbmembercell, "m_m_cell_appoint_button")
            pBuutonappoint:setTag(idx + 1)

        end
        if idx%2==0 then
            --pLairbmembercell:loadTexture("alliance_alpha_bg.png", me.localType)
            me.assignWidget(pLairbmembercell, "panel_mask"):setVisible(true)
        else
            --pLairbmembercell:loadTexture("alliance_cell_bg1.png", me.localType)
            me.assignWidget(pLairbmembercell, "panel_mask"):setVisible(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    tableView = cc.TableView:create(cc.size(805, 470))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "m_a_Node_tab"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()

--    self.selectImg = ccui.ImageView:create()
--    self.selectImg:loadTexture("lianmeng_beijing_xuanzhong_guang.png", me.localType)
--    self.selectImg:setLocalZOrder(10)
--    self.selectImg:setVisible(false)
--    tableView:addChild(self.selectImg)
end
-- 申请
function lairdmanageview:InviteTable(pMailFiTab)
    local iNum = #pMailFiTab
    local pHeight = 0

    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 805, 70
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)

        local cell = table:dequeueCell()
        local plairbinvitecell
        if nil == cell then
            cell = cc.TableViewCell:new()
            plairbinvitecell = lairbinvitecell:create(self, "i_a_cell")
            plairbinvitecell:setVisible(true)
            plairbinvitecell:setData(pMailFiTab[idx + 1])
            local pBuutonapinvite = me.assignWidget(plairbinvitecell, "i_a_Button_invite")
            pBuutonapinvite:setTag(idx + 1)
            me.registGuiClickEvent(pBuutonapinvite, function(node)
                local pIdx = node:getTag()
                NetMan:send(_MSG.applyinviteFamily(pMailFiTab[pIdx]["uid"], 1))
                -- 同意
            end )
            local pBuutonaprefuse = me.assignWidget(plairbinvitecell, "i_a_Button_refuse")
            pBuutonaprefuse:setTag(idx + 1)
            me.registGuiClickEvent(pBuutonaprefuse, function(node)
                local pIdx = node:getTag()
                NetMan:send(_MSG.applyinviteFamily(pMailFiTab[pIdx]["uid"], 2))
                -- 拒绝
            end )
            pBuutonapinvite:setSwallowTouches(false)
            pBuutonaprefuse:setSwallowTouches(false)
            plairbinvitecell:setPosition(cc.p(0, 0))
            cell:addChild(plairbinvitecell)
        else
            plairbinvitecell = me.assignWidget(cell, "i_a_cell")
            plairbinvitecell:setData(pMailFiTab[idx + 1])
            local pBuutonapinvite = me.assignWidget(plairbinvitecell, "i_a_Button_invite")
            pBuutonapinvite:setTag(idx + 1)
            local pBuutonaprefuse = me.assignWidget(plairbinvitecell, "i_a_Button_refuse")
            pBuutonaprefuse:setTag(idx + 1)
        end
        if idx%2==0 then
            --plairbinvitecell:loadTexture("alliance_alpha_bg.png", me.localType)
            me.assignWidget(plairbinvitecell, "panel_mask"):setVisible(true)
        else
            --plairbinvitecell:loadTexture("alliance_cell_bg1.png", me.localType)
            me.assignWidget(plairbinvitecell, "panel_mask"):setVisible(false)
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end
    tableView = cc.TableView:create(cc.size(805, 470))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Node_i_a_tab"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
end
-- 刷新
function lairdmanageview:refreshInvite()
    self.btn_refresh = me.registGuiClickEventByName(self, "Button_refresh", function(node)
        me.tableClear(user.familyRequestMemberInit)
        -- 联盟邀请置空
        NetMan:send(_MSG.requestMemberFamily())
        -- 获取联盟邀请列表
    end )
end
function lairdmanageview:setInviteRectuit(pBool)
    if pBool == true then
        me.assignWidget(self, "i_a_left_level"):setVisible(true)
        me.assignWidget(self, "i_a_left_fight"):setVisible(true)
        me.assignWidget(self, "Text_17"):setVisible(true)
        me.assignWidget(self, "Text_18"):setVisible(true)
        me.assignWidget(self, "i_a_setup_Button_bg"):setVisible(true)
    else
        me.assignWidget(self, "i_a_left_level"):setVisible(false)
        me.assignWidget(self, "i_a_left_fight"):setVisible(false)
        me.assignWidget(self, "Text_17"):setVisible(false)
        me.assignWidget(self, "Text_18"):setVisible(false)
        me.assignWidget(self, "i_a_setup_Button_bg"):setVisible(false)
    end
end

function lairdmanageview:updateJoinCondition()
    local pData = user.famliyInit
    if pData ~= nil then
        self.userLevel = pData["minLevel"]
        self.userFight = pData["minPower"]
    end
    -- 需要等级
    local pNeedLevel = me.assignWidget(self, "i_a_left_level")
    local strLv = getLvStrByPlatform()
    pNeedLevel:setString(strLv .. "." .. self.userLevel)
    -- 需要的战斗力
    local pneedFight = me.assignWidget(self, "i_a_left_fight")
    pneedFight:setString(self.userFight)
end

-- 设置加入联盟的条件
function lairdmanageview:allianceinvite()

    me.assignWidget(self, "i_a_setup_Button_bg"):setVisible(true)
    -- 设置按钮

    me.assignWidget(self, "i_a_left_level"):setVisible(true)
    me.assignWidget(self, "i_a_left_fight"):setVisible(true)

    local pData = user.famliyInit
    local pOpenIcon = me.assignWidget(self, "button_open_icon")
    if pData and pData["recruit"] == 1 then
        self.InviteOpen = true
        pOpenIcon:loadTexture("lianmeng_76.png", me.plistType)
        self:setInviteRectuit(true)
    else
        self.InviteOpen = false
        pOpenIcon:loadTexture("lianmeng_77.png", me.plistType)
        self:setInviteRectuit(false)
    end

    me.registGuiClickEventByName(self, "Button_open", function(node)
        if self.InviteOpen == false then
            --  pOpenIcon:loadTexture("lingzhu_shezhi_tubiao_kai.png",me.plistType)
            --  self.InviteOpen = true
            NetMan:send(_MSG.recruitOpenFamily(1))
            --  开
            showWaitLayer()
        else

            NetMan:send(_MSG.recruitOpenFamily(2))
            --  关
            showWaitLayer()
        end
    end )

    if pData ~= nil then
        self.userLevel = pData["minLevel"]
        self.userFight = pData["minPower"]
    end
    -- 需要等级
    local pNeedLevel = me.assignWidget(self, "i_a_left_level")
    local strLv = getLvStrByPlatform()
    pNeedLevel:setString(strLv .. "." .. self.userLevel)
    -- 需要的战斗力
    local pneedFight = me.assignWidget(self, "i_a_left_fight")
    pneedFight:setString(self.userFight)
    -- 设置按钮
    me.registGuiClickEventByName(self, "i_a_setup_Button_bg", function(node)
        if self.InviteOpen == true then
           
            
            local joinCondition = allianceJoinCondition:create("alliance_join_condition.csb")
            joinCondition:initData(self, self.userLevel, self.userFight)
            -- 联盟管理
            self:addChild(joinCondition)
            me.showLayer(joinCondition, "bg")
            
        else
            showTips("请打开公开招募")
        end


        --            -- 输入等级
        --             local pInputLevel = me.assignWidget(self,"i_a_input_lowest_level")
        --              local function alliance_Level_input_regist_callback(sender,eventType)
        --                if eventType == ccui.TextFiledEventType.attach_with_ime then
        --                    local textField = sender
        --                    textField:runAction(cc.MoveBy:create(0.225,cc.p(0, 20)))
        --                elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        --                    local textField = sender
        --                    textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))      -- 输入完成触屏
        --                elseif eventType == ccui.TextFiledEventType.insert_text then
        --                    self.userLevel = me.toNum(sender:getString())
        --                    if self.userLevel~= nil then
        --                        if self.userLevel < 31 then
        --                       sender:setString(self.userLevel)
        --                       else
        --                          showTips("超出了最大等级")
        --                          self.userLevel = 1
        --                          sender:setString("1")
        --                       end
        --                     else
        --                         showTips("请输入数字")
        --                         sender:setString("")
        --                    end                                                                           -- 输入完成
        --                elseif eventType == ccui.TextFiledEventType.delete_backward then
        --                    self.userLevel = me.toNum(sender:getString())
        --                    if self.userLevel~= nil then
        --                        if self.userLevel < 31 then
        --                       sender:setString(self.userLevel)
        --                       else
        --                          showTips("超出了最大等级")
        --                          self.userLevel = 1
        --                          sender:setString("1")
        --                       end
        --                     else
        --                         showTips("请输入数字")
        --                         sender:setString("")
        --                    end
        --                end
        --            end
        --            pInputLevel:addEventListener(alliance_Level_input_regist_callback)

        -- 输入战斗力
        --            local pInputFight = me.assignWidget(self,"i_a_lowest_fight")
        --              local function alliance_Fight_input_regist_callback(sender,eventType)
        --                if eventType == ccui.TextFiledEventType.attach_with_ime then
        --                    local textField = sender
        --                    textField:runAction(cc.MoveBy:create(0.225,cc.p(0, 20)))
        --                elseif eventType == ccui.TextFiledEventType.detach_with_ime then
        --                    local textField = sender
        --                    textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))      -- 输入完成触屏
        --                elseif eventType == ccui.TextFiledEventType.insert_text then
        --                    self.userFight = me.toNum(sender:getString())                    -- 输入完成
        --                    if self.userFight ~= nil  then
        --                        if string.len(sender:getString()) < 10 then
        --                            sender:setString(self.userFight)
        --                        else
        --                            showTips("超出了最大战斗力")
        --                            self.userFight = 1
        --                            sender:setString("1")
        --                        end
        --                    else
        --                        showTips("请输入数字")
        --                        sender:setString("")
        --                    end
        --                elseif eventType == ccui.TextFiledEventType.delete_backward then
        --                     self.userFight = me.toNum(sender:getString())
        --                    if self.userFight ~= nil  then
        --                        if string.len(sender:getString()) < 10 then
        --                            sender:setString(self.userFight)
        --                        else
        --                            showTips("超出了最大战斗力")
        --                            self.userFight = 1
        --                            sender:setString("1")
        --                        end
        --                    else
        --                        showTips("请输入数字")
        --                        sender:setString("")
        --                    end
        --                end
        --            end
        --            pInputFight:addEventListener(alliance_Fight_input_regist_callback)
    end )

    
end
function lairdmanageview:InviteInput()
    self.InviteNameInput = ""
    local pInputLevel = me.assignWidget(self, "apply_input_name_input")
    pInputLevel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    pInputLevel:setTextVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
    -- pInputLevel:setString("")
    local function alliance_Level_input_regist_callback(sender, eventType)
        if eventType == ccui.TextFiledEventType.attach_with_ime then
            local textField = sender
            --textField:runAction(cc.MoveBy:create(0.225, cc.p(0, 20)))
        elseif eventType == ccui.TextFiledEventType.detach_with_ime then
            local textField = sender
           -- textField:runAction(cc.MoveBy:create(0.175, cc.p(0, -20)))
            -- 输入完成触屏
        elseif eventType == ccui.TextFiledEventType.insert_text then
            self.InviteNameInput = sender:getString()
            -- 输入完成
        elseif eventType == ccui.TextFiledEventType.delete_backward then
            self.InviteNameInput = sender:getString()

        end
    end
    pInputLevel:addEventListener(alliance_Level_input_regist_callback)
    -- 搜索按钮
    me.registGuiClickEventByName(self, "Button_search", function(node)

        if string.len(self.InviteNameInput) == 0 then
            showTips("请输入你要邀请玩家的名字")
        else
            NetMan:send(_MSG.inviteNameFamily(self.InviteNameInput))
            --
        end
    end )
      -- 一键邀请
    me.registGuiClickEventByName(self, "Button_all_invite", function(node)
          local pInviteView = allianceInvite:create("alliance/allianceinvite.csb")
          self:addChild(pInviteView,me.MAXZORDER)
          me.showLayer(pInviteView,"bg_frame")
    end )
    local pData = user.familyMember
    if pData["degree"] == 1 then
       me.assignWidget(self,"Button_all_invite"):setVisible(true)
    else
       me.assignWidget(self,"Button_all_invite"):setVisible(false)
    end
end 
function lairdmanageview:UpdataRecruit()
    local pData = user.famliyInit
    if pData then
        local pOpenIcon = me.assignWidget(self, "button_open_icon")
        if pData["recruit"] == 1 then
            pOpenIcon:loadTexture("lianmeng_76.png", me.plistType)
            self.InviteOpen = true
            self:setInviteRectuit(true)
        else
            pOpenIcon:loadTexture("lianmeng_77.png", me.plistType)

            self.InviteOpen = false
            me.assignWidget(self, "i_a_setup_Button_bg"):setVisible(true)
            -- 设置按钮
            me.assignWidget(self, "i_a_left_level"):setVisible(true)
            me.assignWidget(self, "i_a_left_fight"):setVisible(true)
            self:setInviteRectuit(false)
        end
    end
end
-- 退出联盟
function lairdmanageview:allianceExit()
    me.registGuiClickEventByName(self, "Button_N_E_exit", function(node)
        me.showMessageDialog("是否退出联盟", function(args)
            if args == "ok" then
                NetMan:send(_MSG.escFamily())
                -- 退出联盟
            end
        end )
    end )
end
function lairdmanageview:setLookMap(pos)                 
        local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
        me.showMessageDialog(pStr, function(args)
            if args == "ok" then
                if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                   pWorldMap:AllianceSkipPoint(pos)
                elseif canJumpWorldMap() then
                    mainCity:cloudClose(function (node)
                    print("跳转外城")
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                    end)
                    me.DelayRun(function ()                    
                       mainCity.allianceExitview:removeFromParent()        
                       mainCity.allianceExitview = nil
                       mainCity.allianceInfor = false
                    end)
                end             
            end
        end )                               
end
function lairdmanageview:update(msg)

    if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
        -- 联盟成员数据列表
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST_INIT) then
        -- 联盟邀请列表
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_REQUEST) then
        -- 联盟邀请返回
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_INVITE_LIST) then
        -- 联盟申请列表
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_APPLY_INVITE) then
        -- 家族申请成员的列表
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_SET_RESTRI) then
        -- 联盟设置
        self:allianceinvite()
    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER_ESC) then
        -- 退出联盟
        self:removeFromParentAndCleanup(true)
    elseif checkMsg(msg.t, MsgCode.FAMILY_MEMBER) then
        -- 更新个人信息
        self:setPower()
    elseif checkMsg(msg.t, MsgCode.FAMILY_BE_KICK) then
        -- 辞退
        self:setDeletemabge(msg)
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.ERROR_ALERT) then
        -- if msg.c.alertId == 564 then
        --    me.tableClear(user.familyMemberList)   -- 联盟成员数据置空
        --    NetMan:send(_MSG.getListMember())   -- 获取联盟成员列表
        --  elseif msg.c.alertId == 567 then
        --        showTips("副盟主数量达到上限")
        --  elseif msg.c.alertId == 568 then
        --        showTips("官员数量达到上限")
        --  end
    elseif checkMsg(msg.t, MsgCode.MSG_FAMILY_UPDATA_MEMBER_LIST) then
        self:setLairbType()
    elseif checkMsg(msg.t, MsgCode.FAMILY_RECRUIT_OPEN) then
        disWaitLayer()
        self:UpdataRecruit()
    elseif checkMsg(msg.t, MsgCode.FAMILY_INVITE_NAME) then
    elseif checkMsg(msg.t, MsgCode.FAMILY_CAPTIVE_LIST) then
        self:setLairbType()
        --         local alertId = msg.c.alertId
        --         self:InviteInput()
        --         if alertId == 420 then
        --            showTips("没有找到玩家")
        --         elseif alertId == 570 then
        --            showTips("已经邀请过了")
        --         elseif alertId == 572 then
        --            showTips("成功邀请")
        --         elseif alertId == 561 then
        --            showTips("已在联盟中")
        --         end
    end
end
function lairdmanageview:setDeletemabge(msg)
    local pTab = user.familyMemberList
    local pUid = msg.c.uid
    for key, var in pairs(pTab) do
        if var["uid"] == pUid then
            pTab[key] = nil
            break
        end
    end

end
function lairdmanageview:onEnter()
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function lairdmanageview:onExit()
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.pTime)
    -- 删除消息通知
end

