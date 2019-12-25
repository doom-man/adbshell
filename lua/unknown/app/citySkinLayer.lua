-- [Comment]
-- jnmo
citySkinLayer = class("citySkinLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
citySkinLayer.__index = citySkinLayer
function citySkinLayer:create(...)
    local layer = citySkinLayer.new(...)
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
function citySkinLayer:ctor()
    print("citySkinLayer ctor")
    self.select_index = 1
    self.curSelectData = nil

end
local boxnum = 2
function citySkinLayer:init()
    print("citySkinLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.list = me.assignWidget(self, "list")
    self.icon = me.assignWidget(self, "icon")
    self.showTotem = me.assignWidget(self, "showTotem")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Button_Skin = me.registGuiClickEventByName(self, "Button_Skin", function(node)

        NetMan:send(_MSG.citySkinEquip(self.curSelectData.typeid))

    end )
    self.ScrollView_conent = me.assignWidget(self, "ScrollView_conent")
    self.Text_Buff = me.assignWidget(self, "Text_Buff")
    self.Text_Times = me.assignWidget(self, "Text_Times")
    self.Image_Time_bg = me.assignWidget(self, "Image_Time_bg")
    self.Node_Ani = me.assignWidget(self, "Node_Ani")
    self.totem = me.assignWidget(self, "totom")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_ADORNMENT_UPDATE) then
            self:initList()
        elseif checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE) then
            self:initSkinInfo(self.curSelectData)
        end
    end )
    self.Button_LevelStar = me.registGuiClickEventByName(self, "Button_LevelStar", function(node)
        if self.curSkindata then
            if self.curSkindata:getDef().nextlv and self.curSkindata:getDef().nextlv > 0 then
                local levelstar = skinLevelStarLayer:create("skinLevelStarLayer.csb")
                levelstar:initWithData(self.curSkindata)
                me.popLayer(levelstar)
            else
                showTips("已经达到最大星级")
            end
        end
    end )
    me.registGuiClickEventByName(self, "Button_Shop", function(node)
        NetMan:send(_MSG.initShop(SKINSHOP))
        local shop = citySkinShop:create("citySkinShop.csb")
        me.popLayer(shop)
    end )
    self.pCheckBox = { }
    self.skinType = 1
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            self.skinType = sender.id
            self.select_index = 1
            self:initList()
            me.assignWidget(sender, "red_point"):setVisible(false)
            for var = 1, boxnum do
                self:setCheckBoxState(self.pCheckBox[var], var == sender.id, var)
                me.setWidgetCanTouchDelay(self.pCheckBox[var], 0.1)
            end
        end
    end
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        self:setCheckBoxState(self.pCheckBox[var], self.skinType == self.pCheckBox[var].id, var)
    end
    local function showtotem_callback(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            NetMan:send(_MSG.msg_show_totem(0))
        else
            NetMan:send(_MSG.msg_show_totem(1))
        end
    end
    self.showTotem:addEventListener(showtotem_callback)
    return true
end
function citySkinLayer:setCheckBoxState(node, b, v)
    node:setSelected(b)
    node:setTouchEnabled(not b)
    if b then
        me.assignWidget(node, "cbox_icon"):loadTexture("ui_zb_icon_" .. v .. "2.png", me.localType)
    else
        me.assignWidget(node, "cbox_icon"):loadTexture("ui_zb_icon_" .. v .. "1.png", me.localType)
    end
    me.assignWidget(node, "cbox_icon"):ignoreContentAdaptWithSize(true)
    me.assignWidget(node, "Text_title"):setTextColor(not b and cc.c3b(0x1b, 0x1b, 0x04) or cc.c3b(0xe9, 0xdc, 0xaf))   
    me.assignWidget(node, "Text_title"):enableShadow(not b  and cc.c4b(0x68, 0x65, 0x61, 0xff) or cc.c4b(0x34, 0x33, 0x2d, 0xff), cc.size(-2, -2))
end
function citySkinLayer:initSkinInfo(data)
    local orData = cfg[CfgType.CITY_SKIN][data.typeid]
    local curSkinData = nil
    local skindata = nil
    if orData.type == 1 then
        curSkinData = data
        self.totem:setVisible(false)
        skindata = user.citySkinDatas[tonumber(data.typeid)]
    elseif orData.type == 2 then
        curSkinData = cfg[CfgType.SKIN_STRENGTHEN][tonumber(user.adornment)]
        skindata = user.citySkinTotemDatas[tonumber(data.typeid)]
        self.totem:setVisible(true)
        self.totem:loadTexture("skin" .. data.icon .. ".png", me.localType)
        self.totem:ignoreContentAdaptWithSize(true)
    end
    if curSkinData then
        if tonumber(curSkinData.icon) == 0 then
            self.icon:loadTexture(buildIcon(user.centerBuild:getDef()), me.plistType)
        else
            self.icon:loadTexture("cityskin" .. curSkinData.icon .. "_1.png", me.localType)
        end
        me.resizeImage(self.icon, 300, 200)
    end
    self.Text_Name:setString(data.name)
    self.Text_Name:removeAllChildren()
    for var = 1, data.lv - 1 do
        local img = ccui.ImageView:create("ui_zb_star.png")
        img:setPosition(self.Text_Name:getContentSize().width + var * 30 - 10, 12)
        self.Text_Name:addChild(img)
    end
    self.Text_Buff:setString(data.desc)
    me.clearTimer(self.timer)

    self.curSkindata = skindata
    if skindata and skindata.status ~= -1 then
        self.Image_Time_bg:setVisible(true)
        self.Button_Skin:setVisible(skindata.status == 0)
        local time = skindata.duration
        if time > 0 then
            self.Text_Times:setString(me.formartSecTime(time))
            self.timer = me.registTimer(time, function(dt)
                time = time - 1
                self.Text_Times:setString(me.formartSecTime(time))
            end , 1)
            self.Button_LevelStar:setVisible(false)
        elseif time == -1 then
            self.Text_Times:setString("永久")
            self.Button_LevelStar:setVisible(skindata.id > 0)
        elseif time == 0 then
            self.Text_Times:setString("过期")
            self.Button_LevelStar:setVisible(false)
        end
    else
        self.Button_Skin:setVisible(false)
        self.Image_Time_bg:setVisible(false)
        self.Button_LevelStar:setVisible(false)
    end
    self.Node_Ani:removeAllChildren()
    if data.lord then
        self.soldierAni = mAnimation.new(data.lord)
        self.soldierAni:setPosition(2, 2)
        local dir = self.soldierAni:dirToPoint(cc.p(0, 0))
        self.soldierAni:doAction(MANI_STATE_MOVE, dir)
        self.Node_Ani:addChild(self.soldierAni)
    end
    local ofy = 85
    if orData.type == 2 then
        if data.skill then
            local function skill_call(node)
                local skilldata = node.skilldata
                local fhu = me.createNode("Layer_HeroUseSkillView.csb")
                local Text_title = me.assignWidget(fhu, "Text_title")
                local Image_skill = me.assignWidget(fhu, "Image_skill")
                local Text_desc = me.assignWidget(fhu, "Text_desc")
                local Button_use = me.assignWidget(fhu, "Button_use")
                Button_use:setPositionY(60)
                local Text_countDown = me.assignWidget(fhu, "Text_countDown")
                local text_title_btn = me.assignWidget(Button_use, "text_title_btn")
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
            local skills = me.split(tostring(data.skill), ",")
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
    self:intItemList(cfg[CfgType.CITY_SKIN][tonumber(data.typeid)])
end
function citySkinLayer:intItemList(def)
    local index = 1
    local items = me.split(def.item or "", ",")
    self.ScrollView_conent:removeAllChildren()
    for key, var in pairs(user.pkg) do
        local ihave = false
        for k, v in pairs(items) do
            if tonumber(var.defid) == tonumber(v) then
                ihave = true
            end
        end
        if ihave then
            local data = { }
            local tmpCell = useToolsCellView:create("skinItem.csb")
            data.count, data.defid, data.index = var["count"], var["defid"], index
            self.ScrollView_conent:pushBackCustomItem(tmpCell)
            tmpCell:setItemInfo(data)
            tmpCell.itemdata = var
            me.registGuiClickEvent(tmpCell, function(node)
                if self.curSkindata.duration == -1 then
                    if node.itemdata:getDef().isBreak == 1 then
                        local breakView = BackpackBreak:create("backpack/backpackBreak.csb")
                        me.runningScene():addChild(breakView, me.MAXZORDER)
                        breakView:setItemData(node.itemdata)
                        me.showLayer(breakView, "bg")
                    else
                        showTips("不能分解")
                    end
                else
                    self.BackpackUse = BackpackUse:create("backpack/BackpackUse.csb")
                    self:addChild(self.BackpackUse, me.MAXZORDER);
                    self.BackpackUse:setData(node.itemdata)
                    self.BackpackUse:setParent(self)
                    me.showLayer(self.BackpackUse, "bg")
                end
            end )
            index = index + 1
        end
    end
end
function citySkinLayer:initList()
    local function calback(node)
        self.select_img:setPosition(node:getPositionX(), node:getPositionY() + 15)
        self.select_index = node.idx
        self:initSkinInfo(node.data)
        self.curSelectData = node.data
    end
    self.list:removeAllChildren()
    self.select_img = me.assignWidget(self, "select_img"):clone()
    self.list:addChild(self.select_img, 1000)
    self.listItems = { }
    me.assignWidget(self, "Text_Tips"):setVisible(self.skinType == 1)
    self.showTotem:setVisible(self.skinType == 2)
    self.showTotem:setSelected(user.showTotem == 0)
    local width_list = 636
    local height_list = 486
    local spw = 1
    local sph = 5
    local index = 0
    local h = 0
    local m = 4
    local listdata = user.citySkinDatas
    if self.skinType == 1 then
        listdata = user.citySkinDatas
    elseif self.skinType == 2 then
        listdata = user.citySkinTotemDatas
    end
    local idx = 1
    local tmp = { }
    for key, var in pairs(listdata) do
        table.insert(tmp, var)
    end
    table.sort(tmp, function(a, b)
        return a:getDef().id < b:getDef().id
    end )
    local num = table.nums(tmp)
    for key, skindata in pairs(tmp) do
        local skin = citySkinItem:create(self, "skinItem")
        skin:initWithData(skindata)
        skin.idx = idx
        me.registGuiClickEvent(skin, calback)
        self.list:addChild(skin)
        self.listItems[skindata.id] = skin
        local iSize = skin:getContentSize()
        local i = 0
        if num % m ~= 0 then
            i = 1
        end
        local height =(math.floor(num / m) + i) *(iSize.height + sph)
        if height < height_list then
            height = height_list
        end
        skin:setPosition((iSize.width + spw) *(index % m + 1) - iSize.width / 2,
        height - math.floor(index / m) *(iSize.height + sph) - iSize.height / 2 - sph)
        index = index + 1
        self.list:setInnerContainerSize(cc.size(width_list, height))
        if idx == self.select_index then
            self.curSelectData = skindata:getDef()
            self.select_img:setPosition(skin:getPositionX(), skin:getPositionY() + 15)
            self:initSkinInfo(skindata:getDef())
        end
        idx = idx + 1
        if bthread then
            coroutine.yield()
        end
    end

end
function citySkinLayer:onEnter()
    print("citySkinLayer onEnter")
    me.doLayout(self, me.winSize)
end
function citySkinLayer:onEnterTransitionDidFinish()
    print("citySkinLayer onEnterTransitionDidFinish")
end
function citySkinLayer:onExit()
    print("citySkinLayer onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    me.clearTimer(self.timer)
end
function citySkinLayer:close()
    self:removeFromParent()
end
