 
-- [Comment]
-- jnmo
archDress = class("archDress", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
archDress.__index = archDress
function archDress:create(...)
    local layer = archDress.new(...)
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
-- 工具
archDress.ToolOne = "1"   -- 铲
archDress.ToolTwo = "2"   -- 锄
archDress.ToolThree = "3" -- 锯
archDress.ToolFour = "4"  -- 镐

-- 装备
archDress.EquipOne = "6"  -- 头盔
archDress.EquipTwo = "7"  -- 衣服
archDress.EquipThree = "8" -- 鞋子
archDress.EquipFour = "5"  -- 武器
archDress.EquipFive = "9"  -- 神器

-- 英雄
archDress.Hero = "10" -- 英雄



function archDress:ctor()
    print("archDress ctor")

end
function archDress:init()
    print("archDress init")
    self.mPkgPitch = nil
    self.mPitch = nil
    self.pType = 0
    self.HeroId = 0
    self:setInfo()
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    self.mEquipPitchImg = ccui.ImageView:create()
    self.mEquipPitchImg:loadTexture("kaogu_kuang_xuanzhong_2.png", me.localType)
    self.mEquipPitchImg:setVisible(false)
    self.mEquipPitchImg:setLocalZOrder(10)
    me.assignWidget(self, "left_bg"):addChild(self.mEquipPitchImg)
    me.registGuiTouchEventByName(self, "bg", function(node, event)
        if event ~= ccui.TouchEventType.ended then
            self.mEquipPitchImg:setVisible(false)
            self:setPitch(nil)
        end
    end )
    return true
end

function archDress:setData(pData)

    if pData == nil then

        -- 工具
        local pLeft_tool_one = me.assignWidget(self, "left_tool_one")
        local ptool_one = self:getEquip(archDress.ToolFour)
        local pLeft_tool_one_Icon = me.assignWidget(self, "left_tool_one_icon")
        local pLeft_tool_one_Quailty = me.assignWidget(self, "left_tool_one_quailty")
        self:setAddDress(pLeft_tool_one, archDress.ToolFour)
        if ptool_one then
            pLeft_tool_one_Icon:setVisible(true)
            pLeft_tool_one_Icon:loadTexture(getItemIcon(ptool_one["id"]), me.plistType)
            pLeft_tool_one_Quailty:setVisible(true)
            pLeft_tool_one_Quailty:loadTexture(getArchQuility(ptool_one["id"]), me.localType)
        else
            pLeft_tool_one_Icon:setVisible(false)
            pLeft_tool_one_Quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_tool_one, function(node)
            self:setNextData(archDress.ToolFour)
            self:setPitch(self:getEquip(archDress.ToolFour))
            self:setEquipPitch(4)
        end )

        local pLeft_tool_two = me.assignWidget(self, "left_tool_two")
        local ptool_two = self:getEquip(archDress.ToolThree)
        local pLeft_tool_two_icon = me.assignWidget(self, "left_tool_two_icon")
        local pLeft_tool_two_Quailty = me.assignWidget(self, "left_tool_two_quailty")
        self:setAddDress(pLeft_tool_two, archDress.ToolThree)
        if ptool_two then
            pLeft_tool_two_icon:loadTexture(getItemIcon(ptool_two["id"]), me.plistType)
            pLeft_tool_two_icon:setVisible(true)
            pLeft_tool_two_Quailty:setVisible(true)
            pLeft_tool_two_Quailty:loadTexture(getArchQuility(ptool_two["id"]), me.localType)
        else
            pLeft_tool_two_icon:setVisible(false)
            pLeft_tool_two_Quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_tool_two, function(node)
            self:setNextData(archDress.ToolThree)
            self:setPitch(self:getEquip(archDress.ToolThree))
            self:setEquipPitch(3)
        end )

        local pLeft_tool_three = me.assignWidget(self, "left_tool_three")
        local ptool_three = self:getEquip(archDress.ToolOne)
        local pLeft_tool_three_icon = me.assignWidget(self, "left_tool_three_icon")
        local pLeft_tool_three_Quailty = me.assignWidget(self, "left_tool_three_quailty")
        self:setAddDress(pLeft_tool_three, archDress.ToolOne)
        if ptool_three then
            pLeft_tool_three_icon:loadTexture(getItemIcon(ptool_three["id"]), me.plistType)
            pLeft_tool_three_icon:setVisible(true)
            pLeft_tool_three_Quailty:setVisible(true)
            pLeft_tool_three_Quailty:loadTexture(getArchQuility(ptool_three["id"]), me.localType)
        else
            pLeft_tool_three_icon:setVisible(false)
            pLeft_tool_three_Quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_tool_three, function(node)
            self:setNextData(archDress.ToolOne)
            self:setPitch(self:getEquip(archDress.ToolOne))
            self:setEquipPitch(1)
        end )

        local pLeft_tool_four = me.assignWidget(self, "left_tool_four")
        local ptool_four = self:getEquip(archDress.ToolTwo)
        local pLeft_tool_four_icon = me.assignWidget(self, "left_tool_four_icon")
        local pLeft_tool_four_Quailty = me.assignWidget(self, "left_tool_four_quailty")
        self:setAddDress(pLeft_tool_four, archDress.ToolTwo)
        if ptool_four then
            pLeft_tool_four_icon:loadTexture(getItemIcon(ptool_four["id"]), me.plistType)
            pLeft_tool_four_icon:setVisible(true)
            pLeft_tool_four_Quailty:setVisible(true)
            pLeft_tool_four_Quailty:loadTexture(getArchQuility(ptool_four["id"]), me.localType)
        else
            pLeft_tool_four_icon:setVisible(false)
            pLeft_tool_four_Quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_tool_four, function(node)
            self:setNextData(archDress.ToolTwo)
            self:setPitch(self:getEquip(archDress.ToolTwo))
            self:setEquipPitch(2)
        end )

        -- 装备

        local pLeft_equip_one = me.assignWidget(self, "left_equip_one")
        local pequip_one = self:getEquip(archDress.EquipOne)
        local pLeft_equip_one_icon = me.assignWidget(self, "left_equip_one_icon")
        local pLeft_equip_one_quailty = me.assignWidget(self, "left_equip_one_quailty")
        self:setAddDress(pLeft_equip_one, archDress.EquipOne)
        if pequip_one then
            pLeft_equip_one_icon:setVisible(true)
            pLeft_equip_one_icon:loadTexture(getItemIcon(pequip_one["id"]), me.plistType)
            pLeft_equip_one_quailty:setVisible(true)
            pLeft_equip_one_quailty:loadTexture(getArchQuility(pequip_one["id"]), me.localType)
        else
            pLeft_equip_one_icon:setVisible(false)
            pLeft_equip_one_quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_equip_one, function(node)
            self:setNextData(archDress.EquipOne)
            self:setPitch(self:getEquip(archDress.EquipOne))
            self:setEquipPitch(5)
        end )

        local pLeft_equip_two = me.assignWidget(self, "left_equip_two")
        local pequip_two = self:getEquip(archDress.EquipTwo)
        local pLeft_equip_two_icon = me.assignWidget(self, "left_equip_two_icon")
        local pLeft_equip_two_quailty = me.assignWidget(self, "left_equip_two_quailty")
        self:setAddDress(pLeft_equip_two, archDress.EquipTwo)
        if pequip_two then
            pLeft_equip_two_icon:loadTexture(getItemIcon(pequip_two["id"]), me.plistType)
            pLeft_equip_two_icon:setVisible(true)
            pLeft_equip_two_quailty:setVisible(true)
            pLeft_equip_two_quailty:loadTexture(getArchQuility(pequip_two["id"]), me.localType)
        else
            pLeft_equip_two_icon:setVisible(false)
            pLeft_equip_two_quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_equip_two, function(node)
            self:setNextData(archDress.EquipTwo)
            self:setPitch(self:getEquip(archDress.EquipTwo))
            self:setEquipPitch(6)
        end )

        local pLeft_equip_three = me.assignWidget(self, "left_equip_three")
        local pequip_three = self:getEquip(archDress.EquipThree)
        local pLeft_equip_three_icon = me.assignWidget(self, "left_equip_three_icon")
        local pLeft_equip_three_quailty = me.assignWidget(self, "left_equip_three_quailty")
        self:setAddDress(pLeft_equip_three, archDress.EquipThree)
        if pequip_three then
            pLeft_equip_three_icon:loadTexture(getItemIcon(pequip_three["id"]), me.plistType)
            pLeft_equip_three_icon:setVisible(true)
            pLeft_equip_three_quailty:setVisible(true)
            pLeft_equip_three_quailty:loadTexture(getArchQuility(pequip_three["id"]), me.localType)
        else
            pLeft_equip_three_icon:setVisible(false)
            pLeft_equip_three_quailty:setVisible(false)
        end

        me.registGuiClickEvent(pLeft_equip_three, function(node)
            self:setNextData(archDress.EquipThree)
            self:setPitch(self:getEquip(archDress.EquipThree))
            self:setEquipPitch(7)
        end )

        local pLeft_equip_four = me.assignWidget(self, "left_equip_four")
        local pequip_four = self:getEquip(archDress.EquipFour)
        local pLeft_equip_four_icon = me.assignWidget(self, "left_equip_four_icon")
        local pLeft_equip_four_quailty = me.assignWidget(self, "left_equip_four_quailty")
        self:setAddDress(pLeft_equip_four, archDress.EquipFour)
        if pequip_four then
            pLeft_equip_four_icon:loadTexture(getItemIcon(pequip_four["id"]), me.plistType)
            pLeft_equip_four_icon:setVisible(true)
            pLeft_equip_four_quailty:setVisible(true)
            pLeft_equip_four_quailty:loadTexture(getArchQuility(pequip_four["id"]), me.localType)
        else
            pLeft_equip_four_icon:setVisible(false)
            pLeft_equip_four_quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_equip_four, function(node)
            self:setNextData(archDress.EquipFour)
            self:setPitch(self:getEquip(archDress.EquipFour))
            self:setEquipPitch(8)
        end )

        local pLeft_equip_five = me.assignWidget(self, "left_equip_five")
        local pequip_five = self:getEquip(archDress.EquipFive)
        local pLeft_equip_five_icon = me.assignWidget(self, "left_equip_five_icon")
        local pLeft_equip_five_quailty = me.assignWidget(self, "left_equip_five_quailty")
        self:setAddDress(pLeft_equip_five, archDress.EquipFive)
        if pequip_five then
            pLeft_equip_five_icon:loadTexture(getItemIcon(pequip_five["id"]), me.plistType)
            pLeft_equip_five_icon:setVisible(true)
            pLeft_equip_five_quailty:setVisible(true)
            pLeft_equip_five_quailty:loadTexture(getArchQuility(pequip_five["id"]), me.localType)
        else
            pLeft_equip_five_icon:setVisible(false)
            pLeft_equip_five_quailty:setVisible(false)
        end
        me.registGuiClickEvent(pLeft_equip_five, function(node)
            self:setNextData(archDress.EquipFive)
            self:setPitch(self:getEquip(archDress.EquipFive))
            self:setEquipPitch(9)
        end )
        -- 英雄
        self:setHeroData()
        self:getHaveHero()
        local pLeft_hero_one = me.assignWidget(self, "left_hero_one")
        local pHero_one = self.hero[1]
        local pLeft_hero_one_icon = me.assignWidget(self, "left_hero_one_icon")
        local pLeft_hero_one_quailty = me.assignWidget(self, "left_hero_one_quailty")
        
        self:setAddHero(pLeft_hero_one, 1)
        if pHero_one then
            pLeft_hero_one_icon:loadTexture(getItemIcon(pHero_one["id"]), me.plistType)
            pLeft_hero_one_icon:setVisible(true)
            pLeft_hero_one_quailty:setVisible(true)
            pLeft_hero_one_quailty:loadTexture(getArchQuility(pHero_one["id"]), me.localType)
            me.assignWidget(pLeft_hero_one,"Image_Level"):setVisible(pHero_one.elevel >  0)
        else
            pLeft_hero_one_icon:setVisible(false)
            pLeft_hero_one_quailty:setVisible(false)
            me.assignWidget(pLeft_hero_one,"Image_Level"):setVisible(false)
        end
        me.registGuiClickEvent(pLeft_hero_one, function(node)
            if self.pType ~= archDress.Hero then
                self.pType = archDress.Hero
                self:setNextData(archDress.Hero)
            end
            self.HeroId = 1
            self:setPitch(self.hero[1])
            self:setEquipPitch(10)
        end )

        local pLeft_hero_two = me.assignWidget(self, "left_hero_two")
        local pHero_two = self.hero[2]
        local pLeft_hero_two_icon = me.assignWidget(self, "left_hero_two_icon")
        local pLeft_hero_two_quailty = me.assignWidget(self, "left_hero_two_quailty")
        self:setAddHero(pLeft_hero_two, 2)
        if pHero_two then
            pLeft_hero_two_icon:loadTexture(getItemIcon(pHero_two["id"]), me.plistType)
            pLeft_hero_two_icon:setVisible(true)
            pLeft_hero_two_quailty:setVisible(true)
            pLeft_hero_two_quailty:loadTexture(getArchQuility(pHero_two["id"]), me.localType)
            me.assignWidget(pLeft_hero_two,"Image_Level"):setVisible(pHero_two.elevel >  0)
        else
            pLeft_hero_two_icon:setVisible(false)
            pLeft_hero_two_quailty:setVisible(false)
            me.assignWidget(pLeft_hero_two,"Image_Level"):setVisible(false)
        end
        me.registGuiClickEvent(pLeft_hero_two, function(node)
            if self.pType ~= archDress.Hero then
                self.pType = archDress.Hero
                self:setNextData(archDress.Hero)
            end
            self.HeroId = 2
            self:setPitch(self.hero[2])
            self:setEquipPitch(11)
        end )

        local pLeft_hero_three = me.assignWidget(self, "left_hero_three")
        local pHero_three = self.hero[3]
        local pLeft_hero_three_icon = me.assignWidget(self, "left_hero_three_icon")
        local pLeft_hero_three_quailty = me.assignWidget(self, "left_hero_three_quailty")
        self:setAddHero(pLeft_hero_three, 3)
        if pHero_three then
            pLeft_hero_three_icon:loadTexture(getItemIcon(pHero_three["id"]), me.plistType)
            pLeft_hero_three_icon:setVisible(true)
            pLeft_hero_three_quailty:setVisible(true)
            pLeft_hero_three_quailty:loadTexture(getArchQuility(pHero_three["id"]), me.localType)
            me.assignWidget(pLeft_hero_three,"Image_Level"):setVisible(pHero_three.elevel >  0)
        else
            pLeft_hero_three_icon:setVisible(false)
            pLeft_hero_three_quailty:setVisible(false)
            me.assignWidget(pLeft_hero_two,"Image_Level"):setVisible(false)
        end
        me.registGuiClickEvent(pLeft_hero_three, function(node)
            if self.pType ~= archDress.Hero then
                self.pType = archDress.Hero
                self:setNextData(archDress.Hero)
            end
            self.HeroId = 3
            self:setPitch(self.hero[3])
            self:setEquipPitch(12)
        end )

        local pLeft_hero_four = me.assignWidget(self, "left_hero_four")
        local pHero_four = self.hero[4]
        local pLeft_hero_four_icon = me.assignWidget(self, "left_hero_four_icon")
        local pLeft_hero_four_quailty = me.assignWidget(self, "left_hero_four_quailty")
        self:setAddHero(pLeft_hero_four, 4)
        if pHero_four then
            pLeft_hero_four_icon:loadTexture(getItemIcon(pHero_four["id"]), me.plistType)
            pLeft_hero_four_icon:setVisible(true)
            pLeft_hero_four_quailty:setVisible(true)
            pLeft_hero_four_quailty:loadTexture(getArchQuility(pHero_four["id"]), me.localType)
            me.assignWidget(pLeft_hero_four,"Image_Level"):setVisible(pHero_four.elevel >  0)
        else
            pLeft_hero_four_icon:setVisible(false)
            pLeft_hero_four_quailty:setVisible(false)
            me.assignWidget(pLeft_hero_four,"Image_Level"):setVisible(false)
        end
        me.registGuiClickEvent(pLeft_hero_four, function(node)
            if self.pType ~= archDress.Hero then
                self.pType = archDress.Hero
                self:setNextData(archDress.Hero)
            end
            self.HeroId = 4
            self:setPitch(self.hero[4])
            self:setEquipPitch(13)
        end )

        local pLeft_hero_five = me.assignWidget(self, "left_hero_five")
        local pHero_five = self.hero[5]
        local pLeft_hero_five_icon = me.assignWidget(self, "left_hero_five_icon")
        local pLeft_hero_five_quailty = me.assignWidget(self, "left_hero_five_quailty")
        self:setAddHero(pLeft_hero_five, 5)
        if pHero_five then
            pLeft_hero_five_icon:loadTexture(getItemIcon(pHero_five["id"]), me.plistType)
            pLeft_hero_five_icon:setVisible(true)
            pLeft_hero_five_quailty:setVisible(true)
            pLeft_hero_five_quailty:loadTexture(getArchQuility(pHero_five["id"]), me.localType)
            me.assignWidget(pLeft_hero_five,"Image_Level"):setVisible(pHero_five.elevel >  0)
        else
            pLeft_hero_five_icon:setVisible(false)
            pLeft_hero_five_quailty:setVisible(false)
            me.assignWidget(pLeft_hero_five,"Image_Level"):setVisible(false)
        end
        me.registGuiClickEvent(pLeft_hero_five, function(node)
            if self.pType ~= archDress.Hero then
                self.pType = archDress.Hero
                self:setNextData(archDress.Hero)
            end
            self.HeroId = 5
            self:setPitch(self.hero[5])
            self:setEquipPitch(14)
        end )
        -- 卸下
        local pDischarge = me.assignWidget(self, "Button_discharge")
        me.registGuiClickEvent(pDischarge, function(node)
            local pData = self:getBookEquip(self.mPitch["id"])
            if pData then
                NetMan:send(_MSG.bookUnEquip(pData["uid"]))
            end
        end )
        pDischarge:setSwallowTouches(false)
        -- 穿戴
        local pDress = me.assignWidget(self, "Button_Dress")
        me.registGuiClickEvent(pDress, function(node)
            if self.equipPitchIndex >= 10 and self.equipPitchIndex <= 14 then
                if self.hero[self.HeroId] == nil then
                    NetMan:send(_MSG.bookEquip(self.mPkgPitch["uid"], self.HeroId or 1))
                else
                    showTips("请先卸下")
                end
            else
                NetMan:send(_MSG.bookEquip(self.mPkgPitch["uid"]))
            end
        end )
        pDress:setSwallowTouches(false)
        pDress:setVisible(false)
        me.assignWidget(self, "next_hint_1"):setVisible(true)
    end
end
function archDress:setInfo()

    local pLevel = me.assignWidget(self, "Right_Info_level")
    local strLv = getLvStrByPlatform()
    pLevel:setString(strLv .. "." .. user.lv)

    local pName = me.assignWidget(self, "Right_Info_name")
    pName:setString(user.name)

    local pData = cfg[CfgType.LORD_INFO]
    local pWarData = { }
    for key, var in pairs(pData) do
        if me.toNum(var["typeId"]) == 1 then
            table.insert(pWarData, 1, var)
        end
    end
    local pHeight = #pWarData * 40
    me.assignWidget(self, "Right_bg"):setVisible(false)
    me.assignWidget(self, "Right_Info_bg"):setVisible(true)
    me.assignWidget(self, "Info_ScrollViewNode"):removeAllChildren()
    local pScrollView = cc.ScrollView:create()
    pScrollView:setViewSize(cc.size(340, 348))
    pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    pScrollView:setAnchorPoint(cc.p(0, 0))
    pScrollView:setPosition(cc.p(5, 10))
    pScrollView:setContentSize(cc.size(340, pHeight))
    pScrollView:setContentOffset(cc.p(0,(-(pHeight - 348))))
    me.assignWidget(self, "Info_ScrollViewNode"):addChild(pScrollView)
    local pIcon = me.assignWidget(self, "Right_Info_icon")
    local curTime = overlordView.Time["TIME_" .. getCenterBuildingTime()]
    pIcon:loadTexture(curTime.icon, me.localType)
    local i = 0
    -- dump(pWarData)
    for key, var in pairs(pWarData) do
        local pUserData = user.propertyValue[var["key"]]
        --  dump(pUserData)
        local pInfo = me.assignWidget(self, "Right_info_cell"):clone():setVisible(true)
        pInfo:setAnchorPoint(cc.p(0, 0))
        pInfo:setPosition(cc.p(0, 40 * i))
        local pName = me.assignWidget(pInfo, "Right_info_cell_name")
        pName:setString(var["name"])

        local pNumLabel = me.assignWidget(pInfo, "Right_info_cell_num")
        local pNum = pUserData
        if me.toNum(var["isPercent"]) == 1 then
            pNum = pNum * 100
            pNumLabel:setString(pNum .. "%")
        else
            pNumLabel:setString(pNum)
        end

        if i % 2 == 0 then
            pInfo:loadTexture("rank_cell_bg.png", me.localType)
        end
        i = i + 1
        pScrollView:addChild(pInfo)
    end
end
function archDress:setScrollView(pData)

    if table.maxn(pData) > 0 then
        me.tableClear(self.mScrollData)
        self.mScrollData = pData
        self.mPkgPitch = pData[1]
        self.piNum = #pData
        me.assignWidget(self, "Button_Dress"):setVisible(true)
        me.assignWidget(self, "next_hint_1"):setVisible(false)
        me.assignWidget(self, "next_hint_2"):setVisible(false)
        self.pNext_pitch = me.assignWidget(self, "next_pitch")
        me.assignWidget(self, "ScrollView_node"):removeAllChildren()
        local pScrollView = cc.ScrollView:create()
        pScrollView:setViewSize(cc.size(870, 115))
        pScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        pScrollView:setAnchorPoint(cc.p(0, 0))
        pScrollView:setPosition(cc.p(10, 10))
        pScrollView:setContentSize(cc.size(self.piNum * 150, 115))
        --   pScrollView:setContentOffset(cc.p(0,(-(pHeightTotal-515))))
        me.assignWidget(self, "ScrollView_node"):addChild(pScrollView)
        local pCfigData = cfg[CfgType.ETC][self.mPkgPitch["defid"]]
        local curdata = nil
        for key, var in pairs(user.bookPkg) do
            if self.mPkgPitch["defid"] == var["defid"] then
                curdata = var
            end
        end
        for key, var in pairs(user.bookEquip) do
            if self.mPkgPitch["defid"] == var["defid"] then
                curdata = var
            end
        end

        local descs = me.split(pCfigData["describe"], "|")

        self.pNext_pitch:setString(descs[curdata.level + 1])

        self.pNext_pitch:setVisible(true)
        for key, var in pairs(pData) do
            local pIcon_bg = me.assignWidget(self, "Replace_cell"):clone():setVisible(true)
            --  pIcon:loadTexture(getItemIcon(var["defid"]),me.plistType)
            pIcon_bg:setTag(key)
            pIcon_bg:setPosition(cc.p(150 *(key - 1) + 60, pScrollView:getContentSize().height / 2))

            local pQuailty = me.assignWidget(pIcon_bg, "Replace_cell_quailty")
            pQuailty:loadTexture(getArchQuility(var["defid"]), me.localType)

            local pIcon = me.assignWidget(pIcon_bg, "Replace_cell_icon")
            pIcon:loadTexture(getItemIcon(var["defid"]), me.plistType)
            local Image_Level = me.assignWidget(pIcon_bg, "Image_Level")
   
            Image_Level:setVisible(var.level > 0 )
            me.registGuiClickEvent(pIcon_bg, function(node)
                local pTag = node:getTag()
                self.selectImg:setPosition(cc.p(150 *(pTag - 1) + 60, pScrollView:getContentSize().height / 2))
                self.mPkgPitch = self.mScrollData[pTag]
                local pCfigData = cfg[CfgType.ETC][self.mPkgPitch["defid"]]              
                local descs = me.split(pCfigData["describe"], "|")
                self.pNext_pitch:setString(descs[self.mPkgPitch.level + 1])

                self.pNext_pitch:setVisible(true)
            end )
            pIcon_bg:setSwallowTouches(false)
            pScrollView:addChild(pIcon_bg)
        end
        self.selectImg = ccui.ImageView:create()
        self.selectImg:loadTexture("kaogu_kuang_xuanzhong_2.png", me.localType)
        self.selectImg:setPosition(cc.p(60, pScrollView:getContentSize().height / 2))
        -- self.selectImg:setPosition(cc.p(self:getCellPoint(1,self.iNum)))
        self.selectImg:setLocalZOrder(10)
        pScrollView:addChild(self.selectImg)
    else
        me.assignWidget(self, "ScrollView_node"):removeAllChildren()
        me.assignWidget(self, "next_hint_1"):setVisible(false)
        me.assignWidget(self, "next_hint_2"):setVisible(true)
        me.assignWidget(self, "Button_Dress"):setVisible(false)
        me.assignWidget(self, "next_pitch"):setVisible(false)
    end

end
function archDress:setAddDress(pNode, pType)
    local pNum = self:getDressEquip(pType)
    if pNum == 1 then
        me.assignWidget(pNode, "left_have_dress"):setVisible(true)
        me.assignWidget(pNode, "left_dress"):setVisible(false)
    elseif pNum == 2 then
        me.assignWidget(pNode, "left_have_dress"):setVisible(false)
        me.assignWidget(pNode, "left_dress"):setVisible(true)
    else
        me.assignWidget(pNode, "left_dress"):setVisible(false)
        me.assignWidget(pNode, "left_have_dress"):setVisible(false)
    end
end
-- 拥有的英雄
function archDress:getHaveHero()
    self.pHaveNum = 0
    --   dump(user.bookPkg)
    for key, var in pairs(user.bookPkg) do
        local pCfigData = cfg[CfgType.ETC][var["defid"]]
        if var["defid"] == 1171 then
            print("userType=" .. pCfigData["useType"])
        end
        if me.toNum(pCfigData["useType"]) == me.toNum(archDress.Hero) then
            self.pHaveNum = self.pHaveNum + 1
        end
    end
end
-- function archDress:setAddHeroData()
--    self.pPkg = {}
--    for key, var in pairs(user.bookPkg) do
--         local pCfigData = cfg[CfgType.ETC][var["defid"]]
--         if me.toNum(pCfigData["useType"]) == me.toNum(archDress.Hero) then
--             table.insert(self.pPkg,1,var)
--         end
--     end
--    local function HeroSort(pa,pb)
--          local pCa = cfg[CfgType.ETC][pa["defid"]]
--          local pCb = cfg[CfgType.ETC][pb["defid"]]
--         if pCa ~= nil and pCb~=nil then
--             if me.toNum(pCa["quality"]) > me.toNum(pCb["quality"]) then
--                return   pa > pb
--             end
--         end
--    end
--    table.sort(self.pPkg,HeroSort)
--    dump(self.pPkg)
-- end
function archDress:setAddHero(pNode, pNum)
    local pheroNum = #self.unHeros
    --    if pheroNum > 3 then
    --       local pEqHero = self.hero[pNum]
    --       if table.nums(self.pPkg) ~= 0 then
    --          local pPakHero = self.pPkg[1]
    --          local pCa = cfg[CfgType.ETC][pEqHero["defid"]]
    --          local pCb = cfg[CfgType.ETC][pPakHero["defid"]]
    --         if pCa ~= nil and pCb~=nil then
    --             if me.toNum(pCa["quality"]) < me.toNum(pCb["quality"]) then
    --                self.pPkg[1]  = nil
    --                me.assignWidget(pNode,"left_have_dress"):setVisible(true)
    --                me.assignWidget(pNode,"left_dress"):setVisible(false)
    --             end
    --         end
    --       end
    --       me.assignWidget(pNode,"left_dress"):setVisible(false)
    --       me.assignWidget(pNode,"left_have_dress"):setVisible(false)
    --    end
    -- if pNum > pheroNum then
    if self.pHaveNum > 0 then
        me.assignWidget(pNode, "left_dress"):setVisible(self.hero[pNum] == nil)
        me.assignWidget(pNode, "left_have_dress"):setVisible(false)
        -- self.pHaveNum = self.pHaveNum -1
    else
        me.assignWidget(pNode, "left_dress"):setVisible(false)
        me.assignWidget(pNode, "left_have_dress"):setVisible(false)
    end
    --    else
    --        me.assignWidget(pNode,"left_dress"):setVisible(false)
    --        me.assignWidget(pNode,"left_have_dress"):setVisible(false)
    --    end
end
-- 有更好的装备
function archDress:getDressEquip(pType)
    -- dump(self.mPitchData)
    -- 1 ： 有更好的装备
    -- 2 ： 有可穿戴的装备
    -- 3 ： 没有装备
    local pEquip = self:getEquip(pType)
    if pEquip then
        for key, var in pairs(user.bookPkg) do
            local pCfigData = cfg[CfgType.ETC][var["defid"]]
            if me.toNum(pEquip["useType"]) == me.toNum(pCfigData["useType"]) then
                if pEquip["quality"] < pCfigData["quality"] then
                    return 1
                end
            end
        end
        return 3
    else
        for key, var in pairs(user.bookPkg) do
            local pCfigData = cfg[CfgType.ETC][var["defid"]]
            if me.toNum(pType) == me.toNum(pCfigData["useType"]) then
                return 2
            end
        end
        return 3
    end
    return 3
end
function archDress:getCellPoint()

end
function archDress:getBookEquip(pDefid)
    for key, var in pairs(user.bookEquip) do
        if var["defid"] == pDefid then
            return var
        end
    end
    return nil
end
-- 指定的配置ID 道具是否比身上的道具好
function archDress:betterThan(defid)
    print(defid)
    local pCfigData = cfg[CfgType.ETC][me.toNum(defid)]
    local type_ = pCfigData.useType
    local use = self:getEquip(type_)
    if use then
        if use.quality >= pCfigData.quality then
            return true
        end
    else
        return false
    end
    return false
end
function archDress:getEquip(pType)
    for key, var in pairs(user.bookEquip) do
        local pCfigData = cfg[CfgType.ETC][var["defid"]]
        if me.toNum(pType) == me.toNum(pCfigData["useType"]) then
            return pCfigData
        end
    end
    return nil
end
function archDress:setHeroData()
    self.hero = { }
    self.unHeros = { }
    for key, var in pairs(user.bookEquip) do
        local pCfigData = cfg[CfgType.ETC][var["defid"]]
        pCfigData.elevel = var.level
        if me.toNum(pCfigData["useType"]) == me.toNum(archDress.Hero) and var.equipLoc ~= 0 then
            self.hero[var.equipLoc] = pCfigData
            self.hero[var.equipLoc].elevel = var.level
        else
            table.insert(self.unHeros, pCfigData)
        end
    end
end
function archDress:setNextData(pType)
    local pBackType = { }
    self.pType = pType
    for key, var in pairs(user.bookPkg) do
        local pCfigData = cfg[CfgType.ETC][var["defid"]]
        if me.toNum(pCfigData["useType"]) == me.toNum(pType) then
            table.insert(pBackType, 1, var)
        end
    end
    local function SortQuailty(pa, pb)
        local pCa = cfg[CfgType.ETC][pa["defid"]]
        local pCb = cfg[CfgType.ETC][pb["defid"]]
        if me.toNum(pCa["quality"]) > me.toNum(pCb["quality"]) then
            return true
        end

    end
    table.sort(pBackType, SortQuailty)
    self:setScrollView(pBackType)
end

function archDress:setPitch(pData)
    if pData then
        --  dump(pData)
        me.assignWidget(self, "Right_bg"):setVisible(true)
        me.assignWidget(self, "Right_Info_bg"):setVisible(false)
        self.mPitch = pData
        local pPitchIcon = me.assignWidget(self, "right_pitch_icon")
        pPitchIcon:loadTexture(getItemIcon(pData["id"]), me.plistType)

        local pPitchQuailty = me.assignWidget(self, "right_pitch_quailty")
        pPitchQuailty:loadTexture(getArchQuility(pData["id"]), me.localType)
        
        local pPitchName = me.assignWidget(self, "right_pitch_name")
        pPitchName:setString(pData["name"])
        
        me.assignWidget(self,"Image_Level_right"):setVisible(pData.elevel> 0)
        local descs = me.split(pData["describe"], "|")
        local pPitchDetails = me.assignWidget(self, "right_pitch_details")
        pPitchDetails:setString(descs[pData.elevel + 1])
    else
        me.assignWidget(self, "Right_bg"):setVisible(false)
        me.assignWidget(self, "Right_Info_bg"):setVisible(true)
    end
end
function archDress:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_CHANGE) then
        self:setData(nil)
        self:setNextData(self.pType)
        if self.pType == archDress.Hero then
            self:setHeroData()
            self:setPitch(self.hero[self.HeroId])
        else
            self:setPitch(self:getEquip(self.pType))
        end
    elseif checkMsg(msg.t, MsgCode.ROLE_PROPERTY_UPDATE) then
        self:setInfo()
    end
end
function archDress:setEquipPitch(pIdx)
    self.equipPitchIndex = pIdx
    self.mEquipPitchImg:setVisible(true)
    pIdx = me.toNum(pIdx)
    if pIdx < 5 then
        self.mEquipPitchImg:setPosition(cc.p(213 +(pIdx - 1) * 113, 355))
        self.mEquipPitchImg:setScale(1)
    elseif pIdx > 4 and pIdx < 8 then
        pIdx = pIdx - 4
        self.mEquipPitchImg:setPosition(cc.p(215 +(pIdx - 1) * 112, 226))
        self.mEquipPitchImg:setScale(1)
    elseif pIdx == 8 then
        self.mEquipPitchImg:setPosition(cc.p(564, 235))
        self.mEquipPitchImg:setScale(1.2)
    elseif pIdx == 9 then
        self.mEquipPitchImg:setPosition(cc.p(700, 235))
        self.mEquipPitchImg:setScale(1.2)
    elseif pIdx > 9 then
        pIdx = pIdx - 9
        self.mEquipPitchImg:setPosition(cc.p(214 +(pIdx - 1) * 112, 79))
        self.mEquipPitchImg:setScale(1)
    end
end
function archDress:onEnter()
    print("archDress onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function archDress:setType(pNode)
    self.pParent = pNode
end
function archDress:onEnterTransitionDidFinish()
    print("archDress onEnterTransitionDidFinish")
end
function archDress:onExit()
    print("archDress onExit")
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
end
function archDress:close()
    local arch = archLayer:create("archLayer.csb")
    arch:setLayerType(self.pParent)
    arch:setData()
    --   arch:initLeftList()

    self.pParent:addChild(arch, me.MAXZORDER)
    me.showLayer(arch, "bg")
    self:removeFromParentAndCleanup(true)
end
