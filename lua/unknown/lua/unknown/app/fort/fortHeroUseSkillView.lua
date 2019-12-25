-- [Comment]
-- jnmo
fortHeroUseSkillView = class("fortHeroUseSkillView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortHeroUseSkillView.__index = fortHeroUseSkillView
function fortHeroUseSkillView:create(...)
    local layer = fortHeroUseSkillView.new(...)
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
function fortHeroUseSkillView:ctor()
    print("fortHeroUseSkillView ctor")
end
function fortHeroUseSkillView:init()
    print("fortHeroUseSkillView init")
    self.skillData = nil
    self.countDown = nil
    self.Text_countDown = me.assignWidget(self, "Text_countDown")
    self.Text_cdTips = me.assignWidget(self, "Text_cdTips")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    self.Button_use = me.registGuiClickEventByName(self, "Button_use", function(node)
        if self.skillData then
            local skillDef = cfg[CfgType.HERO_SKILL][me.toNum(self.skillData.id)]
            
            NetMan:send(_MSG.worldUseSkill(self.skillData.id))
            
        end
    end )

    return true
end
function fortHeroUseSkillView:onEnter()
    print("fortHeroUseSkillView onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_USE_SKILL) then
            self:close()
        elseif checkMsg(msg.t, MsgCode.WORLD_POINT) then
            if msg.c.fromSkill and msg.c.fromSkill == 1 then
                self:jumpToTarget(msg.c.x, msg.c.y)
            end
        end
    end )
    self:setSkillInfo()
end

function fortHeroUseSkillView:jumpToTarget(posX, posY)
    if CUR_GAME_STATE == GAME_STATE_CITY then
        mainCity:cloudClose( function(node)
            local loadlayer = loadWorldMap:create("loadScene.csb")
            if user.Cross_Sever_Status == mCross_Sever_Out then
                loadlayer = loadWorldMap:create("loadScene.csb")
            elseif user.Cross_Sever_Status == mCross_Sever then
                loadlayer = loadBattleNetWorldMap:create("loadScene.csb")
            end
            loadlayer:setWarningPoint(cc.p(posX, posY))
            me.runScene(loadlayer)
        end )
    elseif CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        if pWorldMap then
            pWorldMap:lookMapAt(posX, posY, 0)
        end
    end
end
function fortHeroUseSkillView:setSkillInfo()
    local skillDef = cfg[CfgType.HERO_SKILL][me.toNum(self.skillData.id)]
    me.assignWidget(self, "Text_desc"):setString(skillDef.skilldesc)
    me.assignWidget(self, "Text_title"):setString(skillDef.skillname)
    me.assignWidget(self, "Image_skill"):loadTexture(getHeroSkillIcon(skillDef.skillicon), me.plistType)
    self.Text_cdTips:setString("冷却时间：" .. math.floor(skillDef.coldtime / 3600) .. "小时")
    if skillDef.type == 2 then
        local Text_Totem_Cd = me.assignWidget(self,"Text_Totem_Cd")
        Text_Totem_Cd:setVisible(true)
        if self.skillData.atime  == -1 then
            Text_Totem_Cd:setString("图腾技能激活时间：永久" )
        else 
            Text_Totem_Cd:setString("图腾技能激活时间：" .. me.formartSecTime(math.floor(self.skillData.atime - (me.sysTime()/1000 - self.skillData.sysT) )))
            self.totemTimer = me.registTimer(-1,function (dt)
                   local xtime = self.skillData.atime - (me.sysTime()/1000 - self.skillData.sysT)
                   if xtime > 0 then
                       Text_Totem_Cd:setString("图腾技能激活时间：" .. me.formartSecTime(math.floor(xtime)))
                   else
                       me.clearTimer(self.totemTimer)
                   end
            end,1)
        end

    end
    setHeroSkillStars(me.assignWidget(self, "Panel_star"), skillDef.star)

    if self.skillData.tm and self.skillData.tm > 0 then
        local sysTime = math.floor(me.sysTime() / 1000) - self.skillData.sysT
        self.countDown = self.skillData.tm - sysTime
    end

    if self.countDown and self.countDown > 0 then
        self.Text_countDown:setVisible(true)
        self.Text_cdTips:setVisible(false)
        me.buttonState(self.Button_use, false)
        self.Text_countDown:setString(me.formartSecTime(self.countDown))
        self.timer = me.registTimer(-1, function()
            if self.countDown <= 0 then
                self.Text_countDown:setVisible(false)
                self.Text_cdTips:setVisible(true)
                me.buttonState(self.Button_use, true)
                self.countDown = 0
                me.clearTimer(self.timer)
            end
            self.Text_countDown:setString(me.formartSecTime(self.countDown))
            self.countDown = self.countDown - 1
        end , 1)
    else
        me.buttonState(self.Button_use, true)
        self.Text_countDown:setVisible(false)
        self.Text_cdTips:setVisible(true)
    end

end
function fortHeroUseSkillView:setData(pData)
    self.skillData = pData
end
function fortHeroUseSkillView:onEnterTransitionDidFinish()
    print("fortHeroUseSkillView onEnterTransitionDidFinish")
end
function fortHeroUseSkillView:onExit()
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.timer)
    me.clearTimer(self.totemTimer)
    print("fortHeroUseSkillView onExit")
end
function fortHeroUseSkillView:close()
    self:removeFromParentAndCleanup(true)
end