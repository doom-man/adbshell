-- [Comment]
-- jnmo
skinLevelStarLayer = class("skinLevelStarLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
skinLevelStarLayer.__index = skinLevelStarLayer
function skinLevelStarLayer:create(...)
    local layer = skinLevelStarLayer.new(...)
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
function skinLevelStarLayer:ctor()
    print("skinLevelStarLayer ctor")
    self.icon = me.assignWidget(self, "icon")
    self.Node_Ani = me.assignWidget(self, "Node_Ani")
    self.border = me.assignWidget(self, "border")
    self.border_0 = me.assignWidget(self, "border_0")
    self.name = me.assignWidget(self.border, "name")
    self.nextname = me.assignWidget(self.border_0, "name")
    self.Text_Pro = me.assignWidget(self.border, "Text_Pro")
    self.nextText_Pro = me.assignWidget(self.border_0, "Text_Pro")
    self.totem = me.assignWidget(self, "totom")
    self.needitem1 = me.assignWidget(self, "needitem1")
    self.needitem2 = me.assignWidget(self, "needitem2")
    self.needitem3 = me.assignWidget(self, "needitem3")
    me.registGuiClickEventByName(self, "Button_LevelUp", function(node)
        NetMan:send(_MSG.citySkinLevelStar(self.data.id))
    end )
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SKIN_LEVEL_STAR) then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_LEVELSTAR)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
            self:close()
        elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
            self:initWithData(self.data)
        elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) then
            local def = self.data:getDef()
            self:updateNeedItem(def)
        end
    end )

end
function skinLevelStarLayer:initWithData(data)
    local orData = cfg[CfgType.CITY_SKIN][data.id]
    local curSkinData = nil
    local skindata = nil
    if orData.type == 1 then
        curSkinData = data:getDef()
        self.totem:setVisible(false)
        skindata = user.citySkinDatas[tonumber(data.id)]
    elseif orData.type == 2 then
        if tonumber(user.adornment) == 0 then
            curSkinData = cfg[CfgType.SKIN_STRENGTHEN][100]
        else
            curSkinData = cfg[CfgType.SKIN_STRENGTHEN][tonumber(user.adornment)]
        end
        skindata = user.citySkinTotemDatas[tonumber(data.id)]
        self.totem:setVisible(true)
        self.totem:loadTexture("skin" .. orData.icon .. ".png", me.localType)
        self.totem:ignoreContentAdaptWithSize(true)
    end
    self.data = skindata
    local def = skindata:getDef()
    if curSkinData then
        if tonumber(curSkinData.icon) == 0 then
            self.icon:loadTexture(buildIcon(user.centerBuild:getDef()), me.plistType)
        else
            self.icon:loadTexture("cityskin" .. curSkinData.icon .. "_1.png", me.localType)
        end
        me.resizeImage(self.icon, 300, 200)
    end
    self.name:setString(def.name)
    self.nextname:setString(def.name)
    for var = 1, def.lv - 1 do
        local img = ccui.ImageView:create("ui_zb_star.png")
        img:setPosition(self.name:getPositionX() + self.name:getContentSize().width  + var * 30, self.name:getPositionY())
        self.name:getParent():addChild(img)
    end
    if def.desc then
        local descs = me.split(def.desc, ",")
        if descs then
            local idx = 0
            for key, var in pairs(descs) do
                local pro = self.Text_Pro:clone()
                pro:setString(var)
                self.border:addChild(pro)
                pro:setVisible(true)
                pro:setPositionX(self.Text_Pro:getPositionX())
                pro:setPositionY(self.Text_Pro:getPositionY() - idx * 30)
                idx = idx + 1
            end
        end
    end
    if def.nextlv then
        local nextdef = cfg[CfgType.SKIN_STRENGTHEN][def.nextlv]
        for var = 1, nextdef.lv - 1 do
            local img = ccui.ImageView:create("ui_zb_star.png")
            img:setPosition(self.nextname:getPositionX() + self.nextname:getContentSize().width  + var * 30, self.nextname:getPositionY())
            self.nextname:getParent():addChild(img)
        end
        if nextdef.desc then
            local descs = me.split(nextdef.desc, ",")
            if descs then
                local idx = 0
                for key, var in pairs(descs) do
                    local pro = self.nextText_Pro:clone()
                    pro:setString(var)
                    pro:setVisible(true)
                    pro:setPositionY(self.nextText_Pro:getPositionY() - idx * 30)
                    self.border_0:addChild(pro)
                    pro:setPositionX(self.nextText_Pro:getPositionX())
                    idx = idx + 1
                end
            end
        end
        self:updateNeedItem(def)
        self.Node_Ani:removeAllChildren()
        local ofy = 85
        if orData.type == 2 then
            if nextdef.skill then
                local function skill_call(node)
                    local skilldata = node.skilldata
                    local fhu = me.createNode("Layer_HeroUseSkillView.csb")
                    local Text_title = me.assignWidget(fhu, "Text_title")
                    local Image_skill = me.assignWidget(fhu, "Image_skill")
                    local Text_desc = me.assignWidget(fhu, "Text_desc")
                    local Button_use = me.assignWidget(fhu, "Button_use")
                    local text_title_btn = me.assignWidget(Button_use, "text_title_btn")
                    Button_use:setPositionY(60)
                    local Text_countDown = me.assignWidget(fhu, "Text_countDown")
                    Text_countDown:setVisible(false)
                    local Text_cdTips = me.assignWidget(fhu, "Text_cdTips")
                    Text_cdTips:setVisible(false)
                    Button_use:setVisible(true)
                    text_title_btn:setString("确 定")
                    Text_title:setString(skilldata.skillname)
                    Text_desc:setString(skilldata.skilldesc)
                    Image_skill:loadTexture(getHeroSkillIcon(skilldata.skillicon), me.plistType)
                    me.registGuiClickEventByName(fhu, "close", function(node)
                        fhu:removeFromParent()
                    end)
                    me.registGuiClickEvent(Button_use, function(node)
                        fhu:removeFromParent()
                    end)
                    me.popLayer(fhu)
                end
                local skills = me.split(tostring(nextdef.skill), ",")
                for key, var in pairs(skills) do
                    local skillDef = cfg[CfgType.HERO_SKILL][me.toNum(var)]
                    local img = ccui.ImageView:create(getHeroSkillIcon(skillDef.skillicon), me.plistType)
                    img:setScale(0.8)
                    self.Node_Ani:addChild(img)
                    img:setPositionY(ofy -(key - 1) *(img:getContentSize().height))
                    img.skilldata = skillDef
                    me.registGuiClickEvent(img, skill_call)
                end
            end
        end
    else
        for var = 1, def.lv + 1 do
            local img = ccui.ImageView:create("ui_zb_star.png")
            img:setPosition(self.nextname:getPositionX() + self.nextname:getContentSize().width + var * 30, self.nextname:getPositionY())
            self.nextname:getParent():addChild(img)
        end
        self.nextText_Pro:setString("暂未开放")
        self.nextText_Pro:setVisible(true)
        self.needitem1:setVisible(false)
        self.needitem2:setVisible(false)
        self.needitem3:setVisible(false)
    end
end

function skinLevelStarLayer:updateNeedItem(def)
    local nextdef = cfg[CfgType.SKIN_STRENGTHEN][def.nextlv]
    if nextdef.needItem then
        local needs = me.split(nextdef.needItem, ",")
        if needs then
            for key, var in pairs(needs) do
                local icon1 = me.assignWidget(self["needitem" .. key], "icon")
                local desc1 = me.assignWidget(self["needitem" .. key], "desc")
                local complete1 = me.assignWidget(self["needitem" .. key], "complete")
                local optBtn1 = me.assignWidget(self["needitem" .. key], "optBtn")
                local items = me.split(var, ":")
                me.registGuiClickEvent(optBtn1, function(node)
                    if tonumber(items[1]) ~= 9001 and tonumber(items[1]) ~= 9002  and tonumber(items[1]) ~= 9003 and tonumber(items[1]) ~= 9004 then
                        local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
                        me.runningScene():addChild(getWayView, me.MAXZORDER)
                        me.showLayer(getWayView, "bg")
                        getWayView:setData(tonumber(items[1]))
                    else
                        local tmpView = recourceView:create("rescourceView.csb")
                        local shopKey = "food"
                        if tonumber(items[1]) == 9001 then
                            shopKey = "food"
                        elseif tonumber(items[1]) == 9002 then
                            shopKey = "wood"
                        elseif tonumber(items[1]) == 9003 then
                            shopKey = "stone"
                        elseif tonumber(items[1]) == 9004 then
                            shopKey = "gold"
                        end
                        tmpView:setRescourceType(shopKey)
                        tmpView:setRescourceNeedNums(tonumber(items[2]))
                        me.runningScene():addChild(tmpView, me.MAXZORDER)
                        me.showLayer(tmpView, "bg")
                    end
                end )
                if key == 1 then
                    local Text_NeedName = me.assignWidget(self.needitem1, "Text_NeedName")
                    Text_NeedName:setString(cfg[CfgType.ETC][tonumber(items[1])].name)
                end
                icon1:loadTexture(getItemIcon(tonumber(items[1])), me.localType)
                local num = getItemNum(tonumber(items[1]))
                desc1:setString(Scientific(num) .. "/" .. items[2])
                if num >= tonumber(items[2]) then
                    desc1:setColor(COLOR_GREEN)
                    optBtn1:setVisible(false)
                    complete1:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                else
                    complete1:loadTexture("shengji_tubiao_buzu.png", me.localType)
                    desc1:setColor(COLOR_RED)
                    optBtn1:setVisible(true)
                end
            end
        end
    end

end

function skinLevelStarLayer:init()
    print("skinLevelStarLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end
function skinLevelStarLayer:onEnter()
    print("skinLevelStarLayer onEnter")
    me.doLayout(self, me.winSize)
end
function skinLevelStarLayer:onEnterTransitionDidFinish()
    print("skinLevelStarLayer onEnterTransitionDidFinish")
end
function skinLevelStarLayer:onExit()
    print("skinLevelStarLayer onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function skinLevelStarLayer:close()
    self:removeFromParent()
end

