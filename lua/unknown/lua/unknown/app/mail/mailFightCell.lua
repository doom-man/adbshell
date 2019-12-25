 mailFightCell = class("mailFightCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
mailFightCell.__index = mailFightCell
function mailFightCell:create(...)
    local layer = mailFightCell.new(...)
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
function mailFightCell:setData(pData)
     --dump(pData)
     if pData ~= nil then 
        self.tx = pData.x
        self.ty = pData.y
        local pColor = cc.c4b(241,67,67,255)
        local pColorHero = cc.c4b(241,67,67,255)
        local pFight_Type = pData["rType"]     --  战斗类型
        local pFight_Type_Icon_str = "zhanbao_icon_jinggong.png"        --  战斗类型图标：战斗图标
        local pIconStr = "zhanbao_icon_shengli.png"   -- 胜利图标
        local pMy_F_Type1 = ""
        local pMy_F_Type = ""                                           --  我的战斗类型
        local pMy_F_Name = ""                                           --  我的名字
        local pMy_F_Level= ""                                           --  我的等级
        local pRival_F_type = ""                                        --  对手战斗类型
        local pRival_F_Name = ""                                        --  对手名字
        local pRival_F_level =""                                        --  对手等级
        local myWenming = 0
        local otherWenming=0
        local pReportX = 0
        local pReportY = 0
        me.assignWidget(self,"fight_peo_icon"):setVisible(false)
        me.assignWidget(self,"match_peo_icon"):setVisible(false)
        me.assignWidget(self,"belong_occupy_bg"):setVisible(false)
        me.assignWidget(self,"belong_lose_bg"):setVisible(false)
        if pData["type"] == 3 then          
             pReportX = pData["x"]
             pReportY = pData["y"]            
            local pwin = pData["win"]
            if pwin == 1 then
                pIconStr = "zhanbao_icon_shengli.png"   -- 胜利图标
               else
               pIconStr = "zhanbao_icon_shibai.png"   -- 失败图标
            end
              me.assignWidget(self,"Fight_level"):setVisible(true)
              me.assignWidget(self,"Fight_match_level"):setVisible(true)
           if pFight_Type == 1 then       -- 进攻
              pFight_Type_Icon_str = "zhanbao_icon_jinggong.png"            -- 出征图标                          
              local pMyData = pData["attacker"]                         --  我的数据
              local pRivalData = pData["defender"]                      --  对手数据
              myWenming = pMyData.wenming
              otherWenming=pRivalData.wenming
              pMy_F_Type1 = 1--"进攻"
              pMy_F_Type = 1--"进攻方"                                     --  我的战斗类型
              pMy_F_Name = pMyData["name"]                              --  我的名字
              pMy_F_Level= pMyData["lv"]                                --  我的等级
              pRival_F_type = 2--"防守方"                                  --  对手战斗类型
              pRival_F_Name = pRivalData["name"]                        --  对手名字
              pRival_F_level =pRivalData["lv"]                          --  对手等级
              if pData["Property"] == 41 then
                 pFight_Type_Icon_str = "zhanbao_icon_tansuo_dao.png" -- 探索
                 pColor = cc.c4b(205,200,121,255)
                 pMy_F_Type1 = 2--"探索"
              elseif pData["Property"] == 46 then 
                 pFight_Type_Icon_str = "zhanbao_icon_tansuo_dao.png" -- 考古
                 pColor = cc.c4b(205,200,121,255)
                 pMy_F_Type1 = 3--"考古"
              elseif pData["Property"] == 42 then
                 pFight_Type_Icon_str = "zhanbao_icon_jinggong.png" -- 出征
                 pMy_F_Type1 = 4--"出征"
              end
              me.assignWidget(self,"Fight_level"):setVisible(true)
              me.assignWidget(self,"Fight_match_level"):setVisible(true)
              me.assignWidget(self,"Fight_win_Icon"):setVisible(true)
              me.assignWidget(self,"match_attack_durable"):setVisible(false)
              me.assignWidget(self,"Next_attack_durable"):setVisible(false)
              
              if pData.FighType ~= 0 then                          
                if pData.durable > 0 then
                    local pDurable = me.assignWidget(self,"match_attack_durable")
                    pDurable:setVisible(true) 
                    if pData.FighType == 5 then
                       pFight_Type_Icon_str = "zhanbao_icon_shenjiang.png" -- 出征
                       pMy_F_Type1 = 5--"名将试炼"
                       pDurable:setString("生命减少: "..pData.durable) 
                        pColorHero = me.convert3Color_("#D4C5B4")
                        local pHeroConfig = cfg[CfgType.HERO][pRivalData["lv"]]   --  名将id
                        if pHeroConfig then
                           pRival_F_level = "试炼度 "..pHeroConfig["leveltxt"]
                        end                     
                    else
                       pDurable:setString("耐久降低："..pData.durable) 
                    end 
                end
                if pData.belong == 1 then
                    local occupyBg = me.assignWidget(self,"belong_occupy_bg")
                    occupyBg:setVisible(true)
                    me.assignWidget(occupyBg,"txtstr"):ignoreContentAdaptWithSize(true)
                    if pData.FighType == 5 or pData.FighType == 6 then
                       me.assignWidget(occupyBg,"txtstr"):loadTexture("mail_fight_cell10.png")           
                    elseif pData.FighType == 4 then
                       me.assignWidget(occupyBg,"txtstr"):loadTexture("mail_fight_cell13.png")  
                    elseif pData.FighType ==3 then 
                       me.assignWidget(occupyBg,"txtstr"):loadTexture("mail_fight_cell11.png")  
                    else
                       me.assignWidget(occupyBg,"txtstr"):loadTexture("mail_fight_cell12.png")  
                    end                    
                end
              end
           elseif pFight_Type == 2 then       -- 防御
              pFight_Type_Icon_str = "zhanbao_icon_jinggong.png"        -- 战斗图标
              local pMyData = pData["defender"]                         --  我的数据
              local pRivalData = pData["attacker"]                      --  对手数据

              myWenming = pMyData.wenming
              otherWenming=pRivalData.wenming

             -- dump(pMyData)
           --   dump(pRivalData)
              pMy_F_Type1 = 6--"防守"
              pMy_F_Type = 2 --"防守方"                                     --  我的战斗类型
              pMy_F_Name = pMyData["name"]                              --  我的名字
              pMy_F_Level= pMyData["lv"]                                --  我的等级
              pRival_F_type = 1--"进攻方"                                  --  对手战斗类型
              pRival_F_Name = pRivalData["name"]                        --  对手名字
              pRival_F_level =pRivalData["lv"]                          --  对手等级
              me.assignWidget(self,"Fight_win_Icon"):setVisible(true)
              me.assignWidget(self,"match_attack_durable"):setVisible(false)           
              me.assignWidget(self,"Next_attack_durable"):setVisible(false)
              me.assignWidget(self,"belong_occupy_bg"):setVisible(false)
              if pData.FighType ~= 0 then                          
                if pData.durable > 0 then
                    local pDurable = me.assignWidget(self,"Next_attack_durable")
                    pDurable:setString("耐久降低："..pData.durable) 
                    pDurable:setVisible(true) 
                end
                if pData.belong == 1 then
                    local loseBg = me.assignWidget(self,"belong_lose_bg")
                    loseBg:setVisible(true)
                    me.assignWidget(loseBg,"txtstr"):ignoreContentAdaptWithSize(true)
                    if pData.FighType == 4 then
                      me.assignWidget(loseBg,"txtstr"):loadTexture("mail_fight_cell16.png")        
                    elseif pData.FighType == 3 then
                      me.assignWidget(loseBg,"txtstr"):loadTexture("mail_fight_cell14.png")
                    else
                      me.assignWidget(loseBg,"txtstr"):loadTexture("mail_fight_cell15.png")
                    end
                end
              end
           elseif pFight_Type == 3 then       -- 集火进攻
              pFight_Type_Icon_str = "jihuo_tubiao_jilv_jingong.png"            -- 出征图标                          
              local pMyData = pData["attacker"]                         --  我的数据
              local pRivalData = pData["defender"]                      --  对手数据
              myWenming = pMyData.wenming
              otherWenming=pRivalData.wenming

              pMy_F_Type1 = 7--"集火"
              pMy_F_Type = 1 --"进攻方"                                     --  我的战斗类型
              pMy_F_Name = pMyData["name"].."的队伍"                              --  我的名字
              pMy_F_Level= pMyData["lv"]                                --  我的等级
              pRival_F_type = 2--"防守方"                                  --  对手战斗类型
              pRival_F_Name = pRivalData["name"].."的队伍"                        --  对手名字
              pRival_F_level =pRivalData["lv"]                          --  对手等级
              me.assignWidget(self,"Fight_level"):setVisible(false)
              me.assignWidget(self,"Fight_match_level"):setVisible(false)
              me.assignWidget(self,"fight_peo_icon"):setVisible(true)
              me.assignWidget(self,"fight_peo_num"):setString(pData.atcNum)
              me.assignWidget(self,"match_peo_icon"):setVisible(true)
              me.assignWidget(self,"match_peo_num"):setString(pData.defNum)
              me.assignWidget(self,"belong_occupy_bg"):setVisible(false)
              me.assignWidget(self,"belong_lose_bg"):setVisible(false)

              local pDurable = me.assignWidget(self,"match_attack_durable")
              if pData.FighType == 10 then
                    pDurable:setVisible(true) 
                    pDurable:setString("生命减少: "..pData.durable) 
                    if pData.belong == 1 then
                      local belong_occupy_bg = me.assignWidget(self, "belong_occupy_bg")
                      belong_occupy_bg:setVisible(true)
                      me.assignWidget(belong_occupy_bg, "txtstr"):loadTexture("mail_fight_cell10.png")
                    end
                    me.assignWidget(self,"match_peo_icon"):setVisible(false)
              else
                  pDurable:setVisible(false) 
              end 

           elseif pFight_Type == 4 then       -- 集火防御
              pFight_Type_Icon_str = "jihuo_tubiao_jilv_fangyu.png"        -- 战斗图标
              local pMyData = pData["defender"]                         --  我的数据
              local pRivalData = pData["attacker"]                      --  对手数据
              myWenming = pMyData.wenming
              otherWenming=pRivalData.wenming

              pMy_F_Type1 = 8--"防御"
              pMy_F_Type = 2 --"防守方"                                     --  我的战斗类型
              pMy_F_Name = pMyData["name"].."的队伍"                              --  我的名字
              pMy_F_Level= pMyData["lv"]                                --  我的等级
              pRival_F_type = 1--"进攻方"                                  --  对手战斗类型
              pRival_F_Name = pRivalData["name"].."的队伍"                         --  对手名字
              pRival_F_level =pRivalData["lv"]                          --  对手等级
              me.assignWidget(self,"Fight_level"):setVisible(false)
              me.assignWidget(self,"Fight_match_level"):setVisible(false)
              me.assignWidget(self,"fight_peo_icon"):setVisible(true)
              me.assignWidget(self,"belong_lose_bg"):setVisible(false)
              me.assignWidget(self,"fight_peo_num"):setString(pData.defNum)
              me.assignWidget(self,"match_peo_icon"):setVisible(true)
              me.assignWidget(self,"match_peo_num"):setString(pData.atcNum)
           end
         elseif pData["type"] == 4 then       -- 侦查
              me.assignWidget(self,"match_attack_durable"):setVisible(false)
              me.assignWidget(self,"Next_attack_durable"):setVisible(false)
              me.assignWidget(self,"belong_occupy_bg"):setVisible(false)
              me.assignWidget(self,"belong_lose_bg"):setVisible(false)
              pFight_Type_Icon_str = "zhanbao_icon_zhencha.png"             -- 侦查图标
              local pSpyData = pData["content"]
            --  local pSpyData=me.cjson.decode(pSpyData1)
              pReportX = pSpyData["x"]
              pReportY = pSpyData["y"]              
              if pSpyData ~= nil then
                if pSpyData["rType"]== 1 then                           -- 侦查                 
                      pMy_F_Type1 = 9--"侦查"
                      pMy_F_Type = 3 --"侦查"
                   --   local  pMyData = pSpyData["attacker"]                         --  我的数据
                   --   local pRivalData = pSpyData["defender"]                       --  对手数据
                      pMy_F_Name = pSpyData["attacker"]                              --  我的名字
                      pMy_F_Level= pSpyData["alv"]                                --  我的等级
                      pRival_F_type = 4--"被侦查"                                  --  对手战斗类型
                      pRival_F_Name = pSpyData["defender"]                        --  对手名字
                      pRival_F_level =pSpyData["dlv"]                          --  对手等级
                      pIconStr = "zhanbao_icon_chenggong.png"                   --  成功图标
                      myWenming = pSpyData["atkCountry"] 
                      otherWenming=pSpyData["defCountry"] 

                      if pSpyData.success  then
                           pIconStr = "zhanbao_icon_chenggong.png"                   --  成功图标
                      else
                           pIconStr = "zhanbao_icon_shibai.png"   -- 失败图标
                      end
                      me.assignWidget(self,"Fight_win_Icon"):setVisible(true)
               elseif pSpyData["rType"] ==2 then                           --  被侦查
                      pMy_F_Type1 = 10--"被侦查"
                      pMy_F_Type = 4--"被侦查"
                   --   local  pMyData = pSpyData["defender"]                     --  我的数据
                   --   local pRivalData = pSpyData["attacker"]                   --  对手数据
                      pMy_F_Name = pSpyData["defender"]                              --  我的名字
                      pMy_F_Level= pSpyData["dlv"]                                --  我的等级
                      pRival_F_type = 3--"侦查"                                    --  对手战斗类型
                      pRival_F_Name = pSpyData["attacker"]                        --  对手名字
                      pRival_F_level =pSpyData["alv"]                          --  对手等级
                      me.assignWidget(self,"Fight_win_Icon"):setVisible(false)
                      myWenming = pSpyData["defCountry"] 
                      otherWenming=pSpyData["atkCountry"] 
                 end
              end
       end
        -- 攻击标志
        --local pFight_Icon = me.assignWidget(self,"Fight_Icon")
        --pFight_Icon:loadTexture(pFight_Type_Icon_str,me.localType)
        -- 进攻方
        local pFight_attack = me.assignWidget(self,"Fight_attack")
        pFight_attack:ignoreContentAdaptWithSize(true)
        pFight_attack:loadTexture("mail_fight_type_"..pMy_F_Type1..".png", me.localType)
        --pFight_attack:setString(pMy_F_Type1)
         -- 下进攻方
        local pNext_attack_type = me.assignWidget(self,"Next_attack_type")  --显示文明
        if myWenming==0 then
            pNext_attack_type:loadTexture("mail_fight_cell4.png", me.localType)
        else
            pNext_attack_type:loadTexture("wmxz_"..myWenming..".png", me.localType)
        end
        me.resizeImage(pNext_attack_type, 105, 118)
        --local namestr = me.assignWidget(pNext_attack_type,"namestr")
        --namestr:ignoreContentAdaptWithSize(true)
        --namestr:loadTexture("mail_atktype_"..pMy_F_Type..".png", me.localType)

        -- 位置
        local pFight_Position = me.assignWidget(self,"Fight_Position")
        pFight_Position:setString("("..pReportX..","..pReportY..")")
        -- 时间
        local pFight_Time = me.assignWidget(self,"Fight_Time")
        pFight_Time:setString(me.GetSecTime(pData["time"],1))
        --名称
        local pFight_name = me.assignWidget(self,"Fight_name")
        pFight_name:setString(pMy_F_Name)
        -- 等级
        local pFight_level = me.assignWidget(self,"Fight_level")
        --[[
        me.DelayRun(function (args)
            me.putNodeOnRight(pFight_name,pFight_level,10,cc.p(0,2))
        end)
        ]]
         
        pFight_level:setString(getLvStrByPlatform()..pMy_F_Level)
        if pMy_F_Level==0 then
            pFight_level:setVisible(false)
        end

        -- 对手名称
        local pFight_match_name = me.assignWidget(self,"Fight_match_name")
        pFight_match_name:setString(pRival_F_Name)
        --pFight_match_name:setTextColor(pColor)
        -- 对手等级
        local pFight_match_level = me.assignWidget(self,"Fight_match_level")
        --me.DelayRun(function (args)
        --    me.putNodeOnRight(pFight_match_name,pFight_match_level,10,cc.p(0,2))
        --end)
        if pData.FighType  == 5 then
           pFight_match_level:setString(pRival_F_level)
           --pFight_match_level:setTextColor(pColorHero) 
        else
           pFight_match_level:setString(getLvStrByPlatform()..pRival_F_level)
           --pFight_match_level:setTextColor(pColor) 
        end
        if pRival_F_level==0 then
            pFight_match_level:setVisible(false)
        end
       
        -- 对手进攻方
        local pmatch_attack_type = me.assignWidget(self,"match_attack_type")  --对手文明
        if otherWenming==0 then
            pmatch_attack_type:loadTexture("mail_fight_cell3.png", me.localType)
        else
            pmatch_attack_type:loadTexture("wmxz_"..otherWenming..".png", me.localType)
        end
        me.resizeImage(pmatch_attack_type, 105, 118)
        

        --namestr = me.assignWidget(pmatch_attack_type,"namestr")
        --namestr:ignoreContentAdaptWithSize(true)
        --namestr:loadTexture("mail_atktype_"..pRival_F_type..".png", me.localType)

        -- 胜利/失败图标
        local pFight_win_Icon = me.assignWidget(self,"Fight_win_Icon")
        pFight_win_Icon:ignoreContentAdaptWithSize(true) 
        pFight_win_Icon:loadTexture(pIconStr,me.localType)
        local pFight_Name_level = me.assignWidget(self,"Fight_Name_level")
        local pLandLv = pData.landLv
        --dump(pData.name)
        if pData.name ~= "nil" then
           if pData.FighType == 1 and pLandLv > 0  then         
              pFight_Name_level:setString(pData.name..getLvStrByPlatform()..pLandLv)
           else
              pFight_Name_level:setString(pData.name)
           end
        else
           pFight_Name_level:setString("")
        end
        
        -- 读取
        if pData["status"] == -1 then
             me.assignWidget(self,"Image_4"):setVisible(false)
             else
             me.assignWidget(self,"Image_4"):setVisible(true)
        end
     end
end

function mailFightCell:setMailType(mailType)
    if mailType==mailview.MAILHEROLEVEL then
        me.assignWidget(self, "Fight_Position"):setVisible(false)
        me.assignWidget(self, "Button_point"):setVisible(false)
        me.assignWidget(self, "Image_4"):setVisible(false)
        me.assignWidget(self,"Fight_Name_level"):setString("第"..self.tx.."关")
    elseif mailType==mailview.MAILDIGORE then
        me.assignWidget(self, "Fight_Position"):setVisible(false)
        me.assignWidget(self, "Button_point"):setVisible(false)
        me.assignWidget(self, "Image_4"):setVisible(false)
        local page = math.floor(self.ty/5)+1
        local oreIndex= self.ty%5+1
        local base = cfg[CfgType.ORE_GROUP][self.tx]
        me.assignWidget(self,"Fight_Name_level"):setString("("..base.name..",第"..page.."页"..oreIndex.."号)")
    elseif mailType == mailview.MAILSHIPPVP then
        me.assignWidget(self, "Fight_Position"):setVisible(false)
        me.assignWidget(self, "Button_point"):setVisible(false)
        me.assignWidget(self, "Image_4"):setVisible(false)
    else
        me.assignWidget(self, "Fight_Position"):setVisible(true)
        me.assignWidget(self, "Button_point"):setVisible(true)
    end

end

function mailFightCell:ctor()  
   
end
function mailFightCell:init()  
    self.Image_bg = me.assignWidget(self,"Image_bg") 
    return true
end
function mailFightCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function mailFightCell:onExit()  
end
