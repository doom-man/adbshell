fortIdentifyUpgradeView = class("fortIdentifyUpgradeView", function(...)
    return cc.CSLoader:createNode(...)
end )
fortIdentifyUpgradeView.__index = fortIdentifyUpgradeView
fortIdentifyUpgradeView.openAuto = 6666 -- 开启自动进阶
fortIdentifyUpgradeView.closeAuto = 3333 -- 关闭自动进阶
function fortIdentifyUpgradeView:create(...)
    local layer = fortIdentifyUpgradeView.new(...)
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

function fortIdentifyUpgradeView:ctor()
    print("fortIdentifyUpgradeView:ctor()")
end
function fortIdentifyUpgradeView:init()
    self.Panel_property = me.assignWidget(self, "Panel_property")
    self.Panel_skills = me.assignWidget(self, "Panel_skills")
    self.Panel_richText = me.assignWidget(self, "Panel_richText")
    self.Panel_resource = me.assignWidget(self, "Panel_resource")
    self.optBtn_lvup = me.assignWidget(self, "optBtn_lvup")
    self.optBtn_imme = me.assignWidget(self, "optBtn_imme")
    self.optBtn_imme:setTag(fortIdentifyUpgradeView.closeAuto)
    self.CheckBox_AutoBuy = me.assignWidget(self, "CheckBox_AutoBuy")
    self.Image_Ask = me.assignWidget(self, "Image_Ask")
    self.Node_sellDesr_food = me.assignWidget(self,"Node_sellDesr_food")
    self.richText = nil
    self.autoBuy = 0
    self.heroData = nil
    self.btnTimer = nil
    self.anim = nil -- 缩放特效
    -- 按钮恢复的定时器
    print("fortIdentifyUpgradeView:init()")
    self.Button_Add = me.registGuiClickEventByName(self,"Button_Add",function (node)

    end)
    return true
end
function fortIdentifyUpgradeView:onEnter()
    print("fortIdentifyUpgradeView:onEnter()")
    me.doLayout(self,me.winSize)
    self.CheckBox_AutoBuy:addEventListener( function(node, event)
        if self.anim ~= nil then
            self.anim:stopAllActions()
            self.anim:removeFromParent()
            self.anim = nil
        end

        if event == ccui.CheckBoxEventType.selected then
            self.autoBuy = 1
        elseif event == ccui.CheckBoxEventType.unselected then
            self.autoBuy = 0
        end
    end )

    me.registGuiClickEventByName(self.Panel_richText, "Image_item",function ()
        local NoMaterial = true
        for key, var in pairs(user.pkg) do
            local pkgDef = var:getDef()
            if me.toNum(pkgDef.type) == me.toNum(24) then
                -- 名将图鉴材料
                NoMaterial = false
                break
            end
        end
        if NoMaterial == true then
            local tmpDef = self.heroData:getDef()
            local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
            local itemStr = me.split(nextDef.needitem, ":")
            local etc = cfg[CfgType.ETC][me.toNum(itemStr[1])]
            showTips(etc.name..":"..etc.describe)
        else
            self:stopAutoUpgrade()
            local fmv = fortIdentifyMaterialView:create("fortIdentifyMaterialView.csb")
            self:addChild(fmv)
            me.showLayer(fmv,"bg_frame")
        end
    end)
    self.optBtn_0 =  me.registGuiClickEventByName(self.Panel_richText, "optBtn_0",function ()
--        local NoMaterial = true
--        for key, var in pairs(user.pkg) do
--            local pkgDef = var:getDef()
--            if me.toNum(pkgDef.type) == me.toNum(24) then
--                -- 名将图鉴材料
--                NoMaterial = false
--                break
--            end
--        end
--        if NoMaterial == true then
--            local tmpDef = self.heroData:getDef()
--            local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
--            local itemStr = me.split(nextDef.needitem, ":")
--            local etc = cfg[CfgType.ETC][me.toNum(itemStr[1])]
--            showTips(etc.name..":"..etc.describe)
--        else
            self:stopAutoUpgrade()
            local fmv = fortIdentifyMaterialView:create("fortIdentifyMaterialView.csb")
            self:addChild(fmv)
            me.showLayer(fmv,"bg_frame")
        --end
    end)

    me.assignWidget(self.CheckBox_AutoBuy, "Text_autoDescr"):setString("材料、资源不足，自动在商城购买")
    me.registGuiClickEventByName(self, "close", function()
        self:getParent().fiuv=nil
        self:removeFromParentAndCleanup(true)
    end )

    me.registGuiTouchEvent(me.assignWidget(self, "LoadingBar_progress"), function(node, event)
        self:popupAskInfo(node,event)
    end)

    me.registGuiTouchEvent(self.Image_Ask, function(node, event)
        self:popupAskInfo(node,event)
    end)
    me.registGuiClickEvent(self.optBtn_lvup, function()
        local tmpId = self.heroData:getDef().id
        NetMan:send(_MSG.worldHeroUpgrade(tmpId, 0, self.autoBuy))
        me.buttonState(self.optBtn_lvup, false)
        me.buttonState(self.optBtn_imme, false)
    end )

    me.registGuiClickEvent(self.optBtn_imme, function()
        if self.optBtn_imme:getTag() == fortIdentifyUpgradeView.openAuto then
            self:stopAutoUpgrade()
        elseif self.optBtn_imme:getTag() == fortIdentifyUpgradeView.closeAuto then
            self:openAutoUpgrade()
        end
    end )

    self:setHeroProperty()
    self:setHeroSkills()
    self:setProgressInfo()
    self:setResInfo()
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function fortIdentifyUpgradeView:popupAskInfo(node, event)
    if event == ccui.TouchEventType.began then
        if self.panel_skillDetail ~= nil then
            self.panel_skillDetail:removeFromParent()
            self.panel_skillDetail = nil
        end
        self.panel_skillDetail = showHeroSkillDetail(nil)
        self.panel_skillDetail:setAnchorPoint(cc.p(0.5, 0.5))
        self.panel_skillDetail:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
        self:addChild(self.panel_skillDetail)
    elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
        if self.panel_skillDetail ~= nil then
            self.panel_skillDetail:removeFromParent()
            self.panel_skillDetail = nil
        end
    end
end
function fortIdentifyUpgradeView:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE) then        
        self:flushCurrentData()
        self:setUpgradeFinshButtonStatus(msg)
        if table.nums(msg.c) > 0 then
            self:setProgressInfo()
        end
        self:openTipAnim(msg)
    elseif checkMsg(msg.t, MsgCode.ROLE_RESOURCE_UPDATE) then
        self:setResInfo()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_UPGRADE_FINISH) then
        self:getParent().fiuv=nil
        self:removeFromParentAndCleanup(true)
    elseif checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) 
    or checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
        self:setResInfo()
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_EXCHANGE) then
        self:setResInfo()
    end
end
function fortIdentifyUpgradeView:openTipAnim(msg)
    if #msg.c <= 0 and self.autoBuy == 0 then
        if self.anim == nil then
            self.anim = ccui.ImageView:create("shenjiang_goumai_kuang_guangxiao_xiao.png")
            self.anim:setPosition(self.CheckBox_AutoBuy:getContentSize().width/2, self.CheckBox_AutoBuy:getContentSize().height/2)
            self.anim:setAnchorPoint(0.5,0.5)
            self.anim:setScale(1.8)
            self.CheckBox_AutoBuy:addChild(self.anim)
        end
        local zoomB = cc.ScaleTo:create(0.2, 2.3)
        local zoomS = cc.ScaleTo:create(0.1, 1.8)
        local seq = cc.Sequence:create(zoomB, zoomS)
        local fori = cc.RepeatForever:create(seq)
        self.anim:runAction(fori)
    end
end
function fortIdentifyUpgradeView:openAutoUpgrade()
    me.buttonState(self.optBtn_lvup, false)
    me.assignWidget(self.optBtn_imme, "text_title"):setString("取消进阶")
    self.optBtn_imme:setTag(fortIdentifyUpgradeView.openAuto)
    local tmpId = self.heroData:getDef().id
    NetMan:send(_MSG.worldHeroUpgrade(tmpId, 1, self.autoBuy))
end
function fortIdentifyUpgradeView:stopAutoUpgrade()
    if self.btnTimer then
        me.clearTimer(self.btnTimer)
        self.btnTimer = nil    
    end
    me.buttonState(self.optBtn_lvup, true)
    me.assignWidget(self.optBtn_imme, "text_title"):setString("自动进阶")
    self.optBtn_imme:setTag(fortIdentifyUpgradeView.closeAuto)
end
function fortIdentifyUpgradeView:flushCurrentData()
    for key, var in pairs(user.worldIdentifyList.heroList) do
        if me.toNum(var:getDef().id) == me.toNum(self.heroData:getDef().id) then
            self.heroData = var
        end
    end
end

function fortIdentifyUpgradeView:setUpgradeFinshButtonStatus(msg)
    if msg.c.voluntarily == 1 then
        -- 自动进阶
        self.btnTimer = me.registTimer(1, function()
            me.clearTimer(self.btnTimer)
            self.btnTimer = nil
            if self.optBtn_imme:getTag() == fortIdentifyUpgradeView.openAuto then
                me.buttonState(self.optBtn_lvup, false)
                me.buttonState(self.optBtn_imme, true)
                me.assignWidget(self.optBtn_imme, "text_title"):setString("取消进阶")
                local tmpId = self.heroData:getDef().id
                NetMan:send(_MSG.worldHeroUpgrade(tmpId, 1, self.autoBuy))
            end
        end,0.5)
    else
        self.btnTimer = me.registTimer(1, function()
            me.clearTimer(self.btnTimer)
            self.btnTimer = nil
            me.buttonState(self.optBtn_lvup, true)
            me.buttonState(self.optBtn_imme, true)
            me.assignWidget(self.optBtn_imme, "text_title"):setString("自动进阶")
            self.optBtn_imme:setTag(fortIdentifyUpgradeView.closeAuto)
        end , 0.5)
    end
end

function fortIdentifyUpgradeView:onExit()
    me.clearTimer(self.timer)
    me.clearTimer(self.btnTimer)
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    print("fortIdentifyUpgradeView:onExit()")
end

function fortIdentifyUpgradeView:setCurrentHeroData(data)
    self.heroData = data
end

function fortIdentifyUpgradeView:setHeroSkills()
    if self.heroData == nil then
        __G__TRACKBACK__("self.heroData is nil !!!!")
        return
    end
    self.Panel_skills:removeAllChildren()

    local skillList = self.heroData:getSkills()
    local Node_skill = me.assignWidget(self, "Node_skill")
    for key, var in pairs(skillList) do
        local skillDef = cfg[CfgType.HERO_SKILL][var.id]
        local skillSpr = me.createSprite(getHeroSkillIcon(skillDef.skillicon))
        if me.toNum(var.status) == 0 then
            me.graySprite(skillSpr)
        end

        local skillPanel = me.assignWidget(Node_skill, "Panel_singleSkill"):clone()
        skillPanel:setVisible(true)

        if skillDef.skilltype == 2 then
            -- 主动技能
--            me.assignWidget(skillPanel, "Image_skill"):loadTexture("shengjiang_jineng_kuang_yuan.png", me.localType)
            local pCityCommon = nil
            if var.status == 0 then --未开启
                pCityCommon = allAnimation:createAnimation("shenjiang_jineng_an")
            else
                pCityCommon = allAnimation:createAnimation("shenjiang_jineng_hong")
            end
            local Panel_skillAnim = me.assignWidget(skillPanel, "Panel_skillAnim")
            Panel_skillAnim:addChild(pCityCommon,me.ANIMATION)
            pCityCommon:setPosition(Panel_skillAnim:getContentSize().width/2, Panel_skillAnim:getContentSize().height/2)
            pCityCommon:heroSkillAni()
        elseif skillDef.skilltype == 1 then
            -- 被动技能
--            me.assignWidget(skillPanel, "Image_skill"):loadTexture("shengjiang_jineng_kuang_fang.png", me.localType)
        end
        skillSpr:setAnchorPoint(cc.p(0.5, 0.5))
        skillSpr:setPosition(cc.p(skillPanel:getContentSize().width / 2, skillPanel:getContentSize().height / 2))
        skillPanel:addChild(skillSpr)
        skillPanel:setTag(var.id)
        skillPanel:setPosition(cc.p(me.toNum(key - 1) * 130 + 30, 15))
        self.Panel_skills:addChild(skillPanel)
        me.registGuiTouchEvent(skillPanel, function(node, event)
            if event == ccui.TouchEventType.began then
                if self.panel_skillDetail ~= nil then
                    self.panel_skillDetail:removeFromParent()
                    self.panel_skillDetail = nil
                end
                self.panel_skillDetail = showHeroSkillDetail(node:getTag())
                self.panel_skillDetail:setAnchorPoint(cc.p(0.5, 0.5))
                self.panel_skillDetail:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
                self:addChild(self.panel_skillDetail)
            elseif event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
                if self.panel_skillDetail ~= nil then
                    self.panel_skillDetail:removeFromParent()
                    self.panel_skillDetail = nil
                end
            end
        end )

        --设置星级
        local Panel_star = me.assignWidget(skillPanel, "Panel_star")
        if me.toNum(var.status) ~= 0 then
            setHeroSkillStars(Panel_star,skillDef.star)
        end
    end
end

function fortIdentifyUpgradeView:setHeroProperty()
    if self.heroData == nil then
        __G__TRACKBACK__("self.heroData is nil !!!!")
        return
    end
    self.Panel_property:removeAllChildren()

    local tmpDef = self.heroData:getDef()
    local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
    me.assignWidget(self, "Text_generalName"):setString(tmpDef.herobookname)
    local x, y = me.assignWidget(self, "Text_generalName"):getPosition()
    local tempSize = me.assignWidget(self, "Text_generalName"):getContentSize()
    local x_left = x - tempSize.width / 2 - 20
    me.assignWidget(self, "img_title_left"):setPositionX(x_left)
    local x_right = x + tempSize.width / 2 + 20
    me.assignWidget(self, "img_title_right"):setPositionX(x_right)

    local propertyList = { }
    local function setPropertyListData(title, preNum, nextStr)
        propertyList[#propertyList + 1] = { }
        propertyList[#propertyList].title = title
        propertyList[#propertyList].preNum = preNum
        if nextDef then
            propertyList[#propertyList].nextNum = nextDef[nextStr]
        end
    end

    setPropertyListData("附加攻击", tmpDef.atkplus, "atkplus")
    setPropertyListData("附加防御", tmpDef.defplus, "defplus")
    setPropertyListData("附加伤害", tmpDef.dmgplus, "dmgplus")

    local nodeP = me.assignWidget(self, "Node_proerty")
    for key, var in pairs(propertyList) do
        local propertyP = me.assignWidget(nodeP, "Panel_singleProperty"):clone()
        propertyP:setVisible(true)

        me.assignWidget(propertyP, "text_name"):setString(var.title)
        me.assignWidget(propertyP, "Text_pre"):setString(var.preNum)

        if var.nextNum then
            me.assignWidget(propertyP, "Text_next"):setString(var.nextNum)
            me.assignWidget(propertyP, "Image_up"):setVisible(true)
            propertyP:setPosition(cc.p(165 * (me.toNum(key) - 1), 0))
        else
            me.assignWidget(propertyP, "Text_next"):setVisible(false)
            me.assignWidget(propertyP, "Image_up"):setVisible(false)
            propertyP:setPosition(cc.p(165 * (me.toNum(key) - 1), 0))
        end
        self.Panel_property:addChild(propertyP)
    end
end

function fortIdentifyUpgradeView:setProgressInfo()
    if self.heroData == nil then
        __G__TRACKBACK__("self.heroData is nil !!!!")
        return
    end

    local tmpDef = self.heroData:getDef()
    me.assignWidget(self, "LoadingBar_progress"):setPercent(self.heroData.progress)
    me.assignWidget(self, "Text_progress"):setString("进阶进度 " .. self.heroData.progress .. "%")
    me.assignWidget(self, "Text_clearDesc"):setString("升级进度清空倒计时：")

    me.clearTimer(self.timer)
    local countT = self.heroData.countTime
    me.assignWidget(self, "Text_clearTime"):setString(me.formartSecTime(countT))
    self.timer = me.registTimer(-1, function()
        if countT <= 0 then
            countT = 0
        end
        me.assignWidget(self, "Text_clearTime"):setString(me.formartSecTime(countT))
        countT = countT - 1
    end , 1)

    local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
    me.assignWidget(self.optBtn_imme, "Text_sellNum"):setString("价格: " .. nextDef.itemprice)
    me.assignWidget(self.optBtn_imme, "Text_sellNum_food"):setString(self.heroData.diamondCost)
end

function fortIdentifyUpgradeView:setResInfo()
    local tmpDef = self.heroData:getDef()
    local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
    self.Panel_richText:setVisible(nextDef ~= nil and nextDef.needitem ~= nil)
    me.assignWidget(self.optBtn_imme, "Node_sellDesr"):setVisible(nextDef ~= nil and nextDef.needitem ~= nil)
    if nextDef ~= nil and nextDef.needitem ~= nil then
        local itemStr = me.split(nextDef.needitem, ":")
        me.assignWidget(self.Panel_richText, "Image_item"):loadTexture(getItemIcon(itemStr[1]))
        local itemCount = 0
        for key, var in pairs(user.pkg) do
            local pkgDef = var:getDef()
            if me.toNum(pkgDef.type) == me.toNum(24) and pkgDef.id == me.toNum(itemStr[1]) then
                -- 名将图鉴类型
                itemCount = itemCount + var.count
            end
        end        
        if self.richText then
            self.richText:removeFromParent()
        end
        local color = "11ff22"
        if tonumber(itemStr[2]) > tonumber(itemCount) then
             color = "ff0202"        
        end
        local richStr =  "<txt0016," ..color.. ">"..itemCount.."&<txt0016,d4cdb9>/" .. itemStr[2] .. "&"       
        self.richText = mRichText:create(richStr, self.Panel_richText:getContentSize().width)
        self.richText:setAnchorPoint(cc.p(0, 0.5))
        self.richText:setPosition(0 + 5, 20)
        self.Panel_richText:addChild(self.richText)

        me.assignWidget(self.optBtn_imme, "Image_useItem"):loadTexture(getItemIcon(itemStr[1]))
        me.assignWidget(self.optBtn_imme, "Text_sellNum"):setString( nextDef.itemprice)
    end

    self.Panel_resource:setVisible(nextDef ~= nil and nextDef.needsource ~= nil)
    if nextDef ~= nil and nextDef.needsource ~= nil then
        local resStr = me.split(nextDef.needsource, ":")
        local Image_res = me.assignWidget(self.Panel_resource, "Image_res")
        Image_res:loadTexture(getItemIcon(resStr[1]))
        me.assignWidget(self.Node_sellDesr_food, "Image_res_cell"):loadTexture(getItemIcon(resStr[1]))
        --me.assignWidget(self.Panel_resource, "Text_resNum"):setString(resStr[2])
        local itemCount = 0
        if me.toNum(resStr[1]) == 9001 then
            itemCount=  user.food
        elseif me.toNum(resStr[1]) == 9002 then
            itemCount = user.wood 
        elseif me.toNum(resStr[1]) == 9003 then
            itemCount = user.stone
        elseif me.toNum(resStr[1]) == 9004 then
            itemCount = user.gold
        end   
        local color = "11ff22"
        if tonumber(resStr[2]) > tonumber( itemCount ) then
             color = "ff0202"        
        end
        if self.resRichText then
            self.resRichText:removeFromParent()
        end
        local sstr = ""
        if itemCount > 100000 then
            sstr = Scientific( itemCount )
        else
            sstr = itemCount
        end
        local richStr = "<txt0016," ..color.. ">"..sstr .."&<txt0016,d4cdb9>/" .. resStr[2] .. "&"
        self.resRichText = mRichText:create(richStr,200)
        self.resRichText:setAnchorPoint(cc.p(0, 0.5))
        self.Panel_resource:addChild(self.resRichText)
        self.resRichText:setPosition(0 + 5, 20)
        local resEnough = false
        if user.gold >= me.toNum(resStr[2]) then
            resEnough = true
        end
        me.assignWidget(self.Panel_resource, "complete"):setVisible(resEnough)
        me.assignWidget(self.Panel_resource, "optBtn"):setVisible(not resEnough)

        if resEnough then
            --me.assignWidget(self.Panel_resource, "Text_resNum"):setTextColor(COLOR_GREEN)
        else
            me.registGuiClickEventByName(self.Panel_resource, "optBtn", function()
                local tmpDef = self.heroData:getDef()
                local nextDef = cfg[CfgType.HERO_BOOK_TYPE][tmpDef.nextbookid]
                local resStr = me.split(nextDef.needsource, ":")
                local resType = "food"
                if me.toNum(resStr[1]) == 9004 then
                    resType = "gold"
                elseif me.toNum(resStr[1]) == 9003 then
                    resType = "stone"
                elseif me.toNum(resStr[1]) == 9002 then
                    resType = "wood"
                elseif me.toNum(resStr[1]) == 9001 then
                    resType = "food"
                end
                self:stopAutoUpgrade()
                local resView = recourceView:create("rescourceView.csb")
                resView:setRescourceType(resType)
				resView:setRescourceNeedNums(me.toNum(resStr[2]))
                self:addChild(resView)
                me.showLayer(resView, "bg")
            end )
            
        end
    end

    me.assignWidget(self.optBtn_imme, "Text_sellNum_food"):setString(self.heroData.diamondCost)
end