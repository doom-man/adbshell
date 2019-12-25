runeAwaken = class("runeAwaken", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
runeAwaken.__index = runeAwaken
function runeAwaken:create(...)
    local layer = runeAwaken.new(...)

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
        else
        print("---------------------->>>>")
    end
    return nil
end

function runeAwaken:ctor()
    self.view_name = "runeAwaken"
end

function runeAwaken:getNextSkillId(data)
    local runeSkill = cfg[CfgType.RUNE_SKILL]
    for _, v in pairs(runeSkill) do
        if v.typeid==data.typeid and v.level==data.level+1 then
            return v
        end
    end
    return nil
end

function runeAwaken:setData(data)
    self.data = data

    self.runeIcon:setData(data)

    local runeBaseData = cfg[CfgType.RUNE_DATA][data.cfgId]

    local needCfg=nil
    if self.data.runeSkillId==0 then
        self.skillPanel1:setVisible(false)
        me.Helper:grayImageView(self.skillPanel2) 
        me.assignWidget(self.skillPanel2, "skillIco"):setVisible(false)
        me.assignWidget(self.skillPanel2, "skillLv"):setVisible(false)
        me.assignWidget(self.skillPanel2, "lock"):setVisible(true)
        self.skillDesc1:setString("")
        self.skillDesc2:setString("觉醒后将随机获得一条觉醒技能")
        self.skillName1:setString("")
        self.skillName2:setString("")
        needCfg = self.ResNeedCfg[runeBaseData.level.."_1"]
    else
        me.assignWidget(self.skillPanel2, "lock"):setVisible(false)
        self.skillPanel1:setVisible(true)
        me.Helper:normalImageView(self.skillPanel2) 

        local skillBase1 = cfg[CfgType.RUNE_SKILL][self.data.runeSkillId]
        local skillBase2 = self:getNextSkillId(skillBase1)

        local skillIco = me.assignWidget(self.skillPanel1, "skillIco")
        local skillLv = me.assignWidget(self.skillPanel1, "skillLv")
        skillIco:loadTexture("juexing_"..skillBase1.icon..".png", me.localType)
        skillLv:loadTexture("runeAwaken"..skillBase1.level..".png", me.localType)
        self.skillPanel1:loadTexture("runeAwakenbox"..skillBase1.rank..".png", me.localType)
        skillIco:ignoreContentAdaptWithSize(true)
        skillLv:ignoreContentAdaptWithSize(true)
        self.skillName1:setString(skillBase1.name)
        self.skillDesc1:setString(skillBase1.desc)

        if skillBase2==nil then
            self.skillPanel2:setVisible(false)
            self.skillName2:setString("")
            self.skillDesc2:setString("觉醒技能已达最高等级")
        elseif self.data.star<=self.data.awakeTimes then
            self.skillPanel2:setVisible(false)
            self.skillName2:setString("")
            self.skillDesc2:setString("觉醒次数已达到最高")
        else
            self.skillPanel2:setVisible(true)
            skillIco = me.assignWidget(self.skillPanel2, "skillIco")
            skillLv = me.assignWidget(self.skillPanel2, "skillLv")
            skillIco:loadTexture("juexing_"..skillBase2.icon..".png", me.localType)
            skillLv:loadTexture("runeAwaken"..skillBase2.level..".png", me.localType)
            self.skillPanel2:loadTexture("runeAwakenbox"..skillBase2.rank..".png", me.localType)
            skillIco:ignoreContentAdaptWithSize(true)
            skillLv:ignoreContentAdaptWithSize(true)
            self.skillName2:setString(skillBase2.name)
            self.skillDesc2:setString(skillBase2.desc)
            skillIco:setVisible(true)
            skillLv:setVisible(true)
        end
        needCfg = self.ResNeedCfg[runeBaseData.level.."_"..(self.data.awakeTimes+1)]
    end
    
    if self.data.star<=self.data.awakeTimes or needCfg==nil then
        self.resNode:setVisible(false)
        me.buttonState(self.btnAwaken, false)
    else
        self.resNode:setVisible(true)
        me.buttonState(self.btnAwaken, true)
        local tipStr = ""
        local qxTxt = me.assignWidget(self.resNode, "qxTxt")
        qxTxt:setString("强化等级"..needCfg.needlv)
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][self.data.glv]
        if runeStrengthCfg.level>=tonumber(needCfg.needlv) then
            qxTxt:setTextColor(cc.c4b (65, 229, 33, 255))
            me.assignWidget(self.resNode, "qx_enough"):setTexture("shengji_tubiao_manzhu.png")
            me.assignWidget(self.resNode, "btn_get_more_qx"):setVisible(false)
        else
            qxTxt:setTextColor(cc.c4b (255, 0, 0, 255))
            me.assignWidget(self.resNode, "qx_enough"):setTexture("shengji_tubiao_buzu.png")
            me.assignWidget(self.resNode, "btn_get_more_qx"):setVisible(true)
            tipStr = "强化等级不足"..needCfg.needlv.."级"
        end


        -- 消耗材料（粮食，木头等）
        local arrTbRes = {}
        local stoneRes = nil
	    local resourceStr = string.split(needCfg.needitem, ",")
	    for k, v in pairs (resourceStr) do
		    local tbRes = {}
    	    tbRes.color = cc.c4b (65, 229, 33, 255)
	        local resStr = string.split(v, ":")
	        if tonumber(resStr[1]) == 9004 and tonumber(resStr[2]) ~= 0 then
	    	    tbRes.resIcon = "gongyong_tubiao_jingbi.png"
                tbRes.shopKey = "gold"
	    	    tbRes.resNum = tonumber(resStr[2])
                tbRes.resNowNum = user.gold
                tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
                tbRes.isEnough = true
	    	    if tbRes.resNum > user.gold then
    			    tbRes.color = cc.c4b (255, 0, 0, 255)
                    tbRes.isEnough = false
                    tbRes.enoughIcon = "shengji_tubiao_buzu.png"
                    tbRes.tipStr = "金币不足"
	    	    end
	    	    table.insert (arrTbRes, tbRes)
	        elseif tonumber(resStr[1]) == 9003  and tonumber(resStr[2]) ~= 0 then
	            tbRes.resIcon = "gongyong_tubiao_shitou.png"
                tbRes.shopKey = "stone"
	    	    tbRes.resNum = tonumber(resStr[2])
                tbRes.resNowNum = user.stone
                tbRes.isEnough = true
                tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
	    	    if tbRes.resNum > user.stone then
    			    tbRes.color = cc.c4b (255, 0, 0, 255)
                    tbRes.isEnough = false
                    tbRes.enoughIcon = "shengji_tubiao_buzu.png"
                    tbRes.tipStr = "石头不足"
	    	    end
	    	    table.insert (arrTbRes, tbRes)
	        elseif tonumber(resStr[1]) == 9002  and tonumber(resStr[2]) ~= 0 then
	            tbRes.resIcon = "gongyong_tubiao_mucai.png"
                tbRes.shopKey = "wood"
	    	    tbRes.resNum = tonumber(resStr[2])
                tbRes.resNowNum = user.wood
                tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
                tbRes.isEnough = true
	    	    if tbRes.resNum > user.wood then
                    tbRes.isEnough = false
                    tbRes.enoughIcon = "shengji_tubiao_buzu.png"
    			    tbRes.color = cc.c4b (255, 0, 0, 255)
                    tbRes.tipStr = "木材不足"
	    	    end
	    	    table.insert (arrTbRes, tbRes)
	        elseif tonumber(resStr[1]) == 9001  and tonumber(resStr[2]) ~= 0 then
	            tbRes.resIcon = "gongyong_tubiao_liangshi.png"
                tbRes.shopKey = "food"
	    	    tbRes.resNum = tonumber(resStr[2])
                tbRes.resNowNum = user.food
                tbRes.isEnough = true
                tbRes.enoughIcon = "shengji_tubiao_manzhu.png"
	    	    if tbRes.resNum > user.food then
                    tbRes.isEnough = false
                    tbRes.enoughIcon = "shengji_tubiao_buzu.png"
    			    tbRes.color = cc.c4b (255, 0, 0, 255)
                    tbRes.tipStr = "粮食不足"
	    	    end
	    	    table.insert (arrTbRes, tbRes)
	        end
	    end
    
        if arrTbRes[1].isEnough == false then
            tipStr = arrTbRes[1].tipStr
        elseif arrTbRes[2].isEnough == false then
            tipStr = arrTbRes[2].tipStr
    
        end
        self.goldIcon:setTexture(arrTbRes[1].resIcon)
        self.textGoldNum1:setString(tostring(Scientific(arrTbRes[1].resNowNum)))
        self.textGoldNum1:setTextColor(arrTbRes[1].color)
        self.textGoldNum2:setString("/"..tostring(arrTbRes[1].resNum))
        self.gold_icon_enough:setTexture (arrTbRes[1].enoughIcon)

        self.woodIcon:setTexture(arrTbRes[2].resIcon)
        self.textWoodNum1:setString(tostring(Scientific(arrTbRes[2].resNowNum)))
        self.textWoodNum1:setTextColor(arrTbRes[2].color)
        self.textWoodNum2:setString("/"..tostring(arrTbRes[2].resNum))
        self.wood_icon_enough:setTexture (arrTbRes[2].enoughIcon)


        self.btn_get_more_gold:setVisible (not arrTbRes[1].isEnough)
        self.btn_get_more_wood:setVisible (not arrTbRes[2].isEnough)

        self.btn_get_more_gold.shopKey = arrTbRes[1].shopKey
        self.btn_get_more_wood.shopKey = arrTbRes[2].shopKey
        self.btn_get_more_gold.needNums = arrTbRes[1].resNum
        self.btn_get_more_wood.needNums = arrTbRes[2].resNum
    
        self.tipStr = tipStr
        self.textGoldNum2:setPositionX(self.textGoldNum1:getPositionX()+self.textGoldNum1:getContentSize().width)
        self.textWoodNum2:setPositionX(self.textWoodNum1:getPositionX()+self.textWoodNum1:getContentSize().width)
    end

    --材料数量
    self.numsTxt1:setTextColor(cc.c3b(121,255,44))
    self.numsTxt1:setVisible(true)
    me.assignWidget(self, "autoPlayBtn"):setVisible(true)
    
    local count=0
    for k, v in pairs (user.runeBackpack) do
        local baseCfgDst = cfg[CfgType.RUNE_DATA][v.cfgId]
        if (v.cfgId==self.data.cfgId or (baseCfgDst.type==99 and baseCfgDst.level==runeBaseData.level)) and v.star >= self.data.star and self.data.id~=v.id--[[ and (self.runeAdded==nil or self.runeAdded.id~=v.id)]] then
            count=count+1
        end
    end
    
    self.numsTxt1:setString(count)
    self.numsTxt2:setString("/1")
    self.numsTxt2:setPositionX(self.numsTxt1:getPositionX()+self.numsTxt1:getContentSize().width)
    if count<1 then
        self.numsTxt1:setTextColor(cc.c3b(255,0,0))
    end
    
    if self.runeAdded~=nil then    

    else
        self.equip:setVisible(false)
        me.assignWidget(self.clickArea, "Image_cancel"):setVisible(false)
        self.equipEmpty:setVisible(true)
        me.assignWidget(self.equipEmpty, "jia"):setVisible(true)
        me.assignWidget(self.equipEmpty, "lock"):setVisible(false)

        me.assignWidget(self.equipEmpty, "jia"):stopAllActions()
        if count>0 then
            me.clickAni(me.assignWidget(self.equipEmpty, "jia"))
        end
    end
end

--点击选择圣器
function runeAwaken:clickRune(node)
    local arrRune = {}
    local baseCfgSrc = cfg[CfgType.RUNE_DATA][self.data.cfgId]
    for k, v in pairs (user.runeBackpack) do
        local baseCfgDst = cfg[CfgType.RUNE_DATA][v.cfgId]
        if (v.cfgId==self.data.cfgId or (baseCfgDst.type==99 and baseCfgDst.level==baseCfgSrc.level)) and v.star >= self.data.star and self.data.id~=v.id  --[[and (self.runeAdded==nil or self.runeAdded.id~=v.id)]] then
            table.insert (arrRune, v)
        end
    end
    
    if #arrRune <= 0 then
        -- 提示背包无当前选中类型的符文
        showTips("背包里没有所需圣物")
        print ("背包无当前选中类型的圣物")
    else
        local function registerSelecCallback (data)
            -- 这个是装备卸载符文!!
            -- NetMan:send(_MSG.Rune_equip(runeType, runeId))
            -- showWaitLayer ()
            if data.lock==true then
                showTips("圣物被锁定不能使用")
                return
            end 
            self:addOneRune(data)
        end
        local selectView = runeSelectView:create("rune/runeSelectView.csb")
        
        me.runningScene() :addChild(selectView, me.MAXZORDER)
        
        me.showLayer(selectView,"bg")
        selectView:setRuneBagData(arrRune, "awaken")
        selectView:registerSelecCallback(registerSelecCallback)
    end

end

--
--  一健放入
--
function runeAwaken:autoPlay()
    
    local baseCfgSrc = cfg[CfgType.RUNE_DATA][self.data.cfgId]
    local arrRune = {}
    for k, v in pairs (user.runeBackpack) do
        local baseCfgDst = cfg[CfgType.RUNE_DATA][v.cfgId]
        if (v.cfgId==self.data.cfgId or (baseCfgDst.type==99 and baseCfgDst.level==baseCfgSrc.level)) and v.star >= self.data.star and self.data.id~=v.id --[[and (self.runeAdded==nil or self.runeAdded.id~=v.id)]] then
            table.insert (arrRune, v)
        end
    end

    table.sort (arrRune, function (a, b)
        local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
        local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level
        if a.lock==b.lock then
            if a.star == b.star then
                return strengthLvA < strengthLvB
            else
                return a.star > b.star
            end
        elseif a.lock==false then
            return true
        else
            return false
        end
    end)
    if #arrRune==0 then
        showTips("背包里没有所需的圣物")
        return
    end

    local hasLock=false
    local hasRune=false
    if arrRune[1].lock==true then
        hasLock=true
    elseif self.runeAdded==nil then
       self.runeAdded=arrRune[1]
       hasRune=true
    end

    if hasLock==true then
        showTips("背包里有被锁定的圣物")
    elseif hasRune==false then  --没有空位置了，不用一健填充
        return 
    end
    self:updateView()
end


function runeAwaken:initNeedCfg()
    self.ResNeedCfg = {}
    local tmp = cfg[CfgType.RUNE_AWAKEN_NEED]
    for _, v in pairs(tmp) do
        self.ResNeedCfg[v.rank.."_"..v.time]=v
    end
end

function runeAwaken:init()
    print("runeAwaken:init() ")
    me.doLayout(self, me.winSize)
    
    self:initNeedCfg()

    -- 符文icon
	self.runeIcon = runeItem:create(me.assignWidget(self, "runeIcon"), 1) 

    self.numsTxt1 = me.assignWidget(self, "numsTxt1")
    self.numsTxt2 = me.assignWidget(self, "numsTxt2")

    self.runeAdded = nil  --已选中的圣物

    self.equipEmpty=me.assignWidget(self, "equip_empty_1")
    self.equip=runeItem:create(me.assignWidget(self, "equip_1"), 1) 
    self.clickArea=me.assignWidget(self, "clickArea1")
    self.clickArea:setTag(1)
    me.registGuiClickEvent(self.clickArea, handler(self, self.clickRune))
    me.assignWidget(self.clickArea, "Image_cancel"):setVisible(false)
    me.assignWidget(self.clickArea, "Image_cancel"):setTag(1)
    me.registGuiClickEventByName(self.clickArea, "Image_cancel", function(node)
        self:cancelOneRune(node:getTag())
    end )

    self.skillPanel1 = me.assignWidget(self, "skill1")
    self.skillPanel2 = me.assignWidget(self, "skill2")
    self.skillName1 = me.assignWidget(self, "skillName1")
    self.skillName2 = me.assignWidget(self, "skillName2")
    self.skillDesc1 = me.assignWidget(self, "skillDesc1")
    self.skillDesc2 = me.assignWidget(self, "skillDesc2")

    self.resNode = me.assignWidget(self, "resNode")

    me.registGuiClickEventByName(self.resNode, "btn_get_more_qx", function(node)
        local function refreshData(data)
            self:setData(data)
        end
        local strengthView = runeStrengthView:create("rune/runeStrengthView.csb")
        me.runningScene():addChild(strengthView, me.MAXZORDER)
        strengthView:setSelectRuneInfo(self.data)
        strengthView:setCloseCallback(refreshData)
        me.showLayer(strengthView, "bg")
    end )

    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        --self:removeMtrInfoView()
        self:close()
    end )

    self.goldIcon = me.assignWidget(self, "text_gold_icon")
    self.textGoldNum1 = me.assignWidget(self, "text_gold_num_1")
    self.textGoldNum2 = me.assignWidget(self, "text_gold_num_2")
    self.gold_icon_enough = me.assignWidget(self, "gold_icon_enough")
    self.btn_get_more_gold = me.assignWidget(self, "btn_get_more_gold")

    self.woodIcon = me.assignWidget(self, "text_wood_icon")
    self.textWoodNum1 = me.assignWidget(self, "text_wood_num_1")
    self.textWoodNum2 = me.assignWidget(self, "text_wood_num_2")
    self.wood_icon_enough = me.assignWidget(self, "wood_icon_enough")
    self.btn_get_more_wood = me.assignWidget(self, "btn_get_more_wood")

    me.registGuiClickEvent(self.btn_get_more_gold, function (sender)
        -- 商店
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(sender.shopKey)
        tmpView:setRescourceNeedNums(sender.needNums)
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    end)
    me.registGuiClickEvent(self.btn_get_more_wood, function (sender)
        -- 商店
        local tmpView = recourceView:create("rescourceView.csb")
        tmpView:setRescourceType(sender.shopKey)
        tmpView:setRescourceNeedNums(sender.needNums)
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")
    end)

    self.btnAwaken = me.registGuiClickEventByName(self, "btn_awaken", function(node)
        
        if self.runeAdded==nil then
            showTips("没有所需圣物")
            return
        end
        if self.tipStr~="" then
            showTips(self.tipStr)
            return
        end

        showWaitLayer()
        NetMan:send(_MSG.Rune_awaken(self.data.id, self.runeAdded.id))
    end )

    me.registGuiClickEventByName(self, "autoPlayBtn", handler(self, self.autoPlay))

    
    return true
end


--更新界面显示
function runeAwaken:updateView()
    local eq = self.equip
    local eqEmpey = self.equipEmpty
    if self.runeAdded~=nil then
        eq:setVisible(true)
        eq:setData(self.runeAdded)

        eqEmpey:setVisible(false)

        local clickArea = self.clickArea
        me.assignWidget(clickArea, "Image_cancel"):setVisible(true)
     else
        eq:setVisible(false)
        eqEmpey:setVisible(true)

        local clickArea = self.clickArea
        me.assignWidget(clickArea, "Image_cancel"):setVisible(false)
    end
end




function runeAwaken:close()
    me.DelayRun( function(args)
        self:removeFromParentAndCleanup(true)
    end )
end

function runeAwaken:onEnter()

    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
--    self.close_event = me.RegistCustomEvent("runeAwaken",function (evt)
--        self:close()
--    end)
    --runeComposeView:removeFromParent()
end
function runeAwaken:onExit()
    UserModel:removeLisener(self.netListener)
    me.RemoveCustomEvent(self.close_event)
end

function runeAwaken:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_AWAKEN_REQUEST) then
        disWaitLayer()

        self.runeAdded=nil

        local runeInfo = user.runeBackpack[msg.c.awakenRuneId]
        if runeInfo == nil then
            local nowEquip = user.runeEquiped[self.data.plan]
            runeInfo = nowEquip[self.data.index]
        end
        self:setData(runeInfo)
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_AWAKEN)
        pCityCommon:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2+50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
        --if self.parentView ~= nil then  --更新上级页面上阶圣器数量
        --    self.parentView:reComplexCacl()
        --end

        -- 返还道具展示
        if msg.c.items and #msg.c.items > 0 then
            local txtList = {"觉醒返还以下道具"}
            local etc = cfg[CfgType.ETC]
            for k, v in pairs(msg.c.items) do
                table.insert(txtList, string.format("%s x%s", etc[v[1]].name, v[2]))
            end
            showMultipleTipWithBg(txtList)
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or  
           checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
           checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then -- 背包数量改变
        self:setData(self.data)
    end
end

function runeAwaken:addOneRune(data)
    self.runeAdded = data
    self:updateView()

end

function runeAwaken:cancelOneRune(index)
    self.runeAdded = nil
    self:updateView()
end



function runeAwaken:setParentView(parent)
    self.parentView = parent
end