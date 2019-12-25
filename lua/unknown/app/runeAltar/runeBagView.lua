runeBagView = class("runeBagView",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeBagView:create(...)
    local layer = runeBagView.new(...)
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

function runeBagView:ctor()
    self.runeMaterList = {
        RUNE  = 0,
        MATER = 1,
    }
    self.arrmaterBackpack = {}
    self.arrRuneBackpack = {}

    self:updateMaterData()
    self:updateRuneData()
end

function runeBagView:onEnter()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )
end

function runeBagView:onExit()
    UserModel:removeLisener(self.netListener)
end

function runeBagView:onRevMsg(msg)
    print ("runeBagView:onRevMsg " .. msg.t)
    if checkMsg(msg.t, MsgCode.BOX_REMAKE) then
        if msg.c.id then
            local varCfg = cfg[CfgType.ETC][msg.c.id]
            if varCfg then
                if varCfg.useType == 124 then
                    self:updateMaterData()
                    self:updateMaterScrollView()
                    self:updateMaterInfo()
                    disWaitLayer()

                    local materCfgId = msg.c.id
                    local materBaseCfg = cfg[CfgType.ETC][materCfgId]

                    local num = msg.c.num
                    local tipStr = "合成成功，获得" .. materBaseCfg.name .. "×" .. num
                    showTips (tipStr)
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.RUNE_REMOVE) then -- 装备
        self:updateRuneData()
        self:updateRuneScrollView()
        self:updatePropertyList()
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RUNE_UPDATE) then -- 替换
        self:updateRuneData()
        self:updateRuneScrollView()
        self:updatePropertyList()
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RUNE_STRENGTH) then -- 强化符文
        self:updateRuneData()
        self:updateRuneScrollView()
        self:updatePropertyList()
        disWaitLayer()
    elseif checkMsg(msg.t, MsgCode.RUNE_RESOLVE) then  -- 分解符文
        self:updateRuneData()
        self:updateRuneScrollView()
        self:updatePropertyList()

        self:updateMaterData()
        self:updateMaterScrollView()
        self:updateMaterInfo()

        disWaitLayer()

        local num = 0
        local tbValues = json.decode (msg.c.got)
        for k, v in pairs (tbValues) do
            if v[1] == 2100 then
                num = num + v[2]
            end
        end
        local tipStr = "分解成功，获得强化石×" .. num
        showTips (tipStr)
    end
end
-- 更新材料数据
function runeBagView:updateMaterData()
    self.arrmaterBackpack = table.values(user.materBackpack)
    table.sort (self.arrmaterBackpack, function (a, b)
        local materACfg = cfg[CfgType.RUNE_MAP][a.defid]
        local materBCfg = cfg[CfgType.RUNE_MAP][b.defid]
        return materACfg.order < materBCfg.order
    end)
end
-- 更新符文数据
function runeBagView:updateRuneData()
    self.arrRuneBackpack = table.values(user.runeBackpack)
    table.sort (self.arrRuneBackpack, function (a, b)
        local baseLvA = cfg[CfgType.RUNE_DATA][a.cfgId].level
        local baseLvB = cfg[CfgType.RUNE_DATA][b.cfgId].level
        local strengthLvA = cfg[CfgType.RUNE_STRENGTH][a.glv].level
        local strengthLvB = cfg[CfgType.RUNE_STRENGTH][b.glv].level

        if baseLvA == baseLvB then
            if strengthLvA == strengthLvB then
                return a.cfgId < b.cfgId
            else
                return strengthLvA > strengthLvB
            end
        else
            return baseLvA > baseLvB
        end
    end)
end

function runeBagView:init()
    print("runeBagView init")
    me.doLayout(self, me.winSize)

    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    -- 符文icon
    self.runeIcon = me.assignWidget(self, "rune_icon")
    -- 符文名称
    self.runeName = me.assignWidget(self, "Text_rune_name")
    -- 强化等级
    self.runeSetLv = me.assignWidget(self, "Text_set_name")
    -- 附加攻击
    self.rune_extra_pro = me.assignWidget(self, "Text_str_name")
    -- bg
    local viewBg = me.assignWidget(self, "bg")
    self.radioBtnGroup = ccui.RadioButtonGroup:create ()
    viewBg:addChild (self.radioBtnGroup)
    local function radioBtnClickCallback (radioButton, index, evenType)
        if ccui.RadioButtonGroupEventType.select_changed == evenType then
            self:updateSelectScrollView()
        end
    end
    self.radioBtnGroup:addEventListener(radioBtnClickCallback)
    -- 符文
    self.radioRuneBtnGroup = ccui.RadioButtonGroup:create ()
    viewBg:addChild (self.radioRuneBtnGroup)
    local function radioRuneBtnClickCallback (radioButton, index, evenType)
        if ccui.RadioButtonGroupEventType.select_changed == evenType then
            if #self.arrRuneBackpack > 0 then
                local runeInfo = self.arrRuneBackpack[index+1]
                if runeInfo.isnew == true then
                    runeInfo.isnew = nil
                    radioButton:removeChildByName ("newIcon")
                end
            end
            self:updatePropertyList()
        end
    end
    self.radioRuneBtnGroup:addEventListener(radioRuneBtnClickCallback)
    -- 材料
    self.radioMaterBtnGroup = ccui.RadioButtonGroup:create ()
    viewBg:addChild (self.radioMaterBtnGroup)
    local function radioMaterBtnClickCallback (radioButton, index, evenType)
        if ccui.RadioButtonGroupEventType.select_changed == evenType then
            self:updateMaterInfo()
        end
    end
    self.radioMaterBtnGroup:addEventListener(radioMaterBtnClickCallback)

    local radioRuneBtn = ccui.RadioButton:create("fuwen_anniu_cailiao_an.png", "fuwen_anniu_cailiao_liang.png")
    radioRuneBtn:setZoomScale(0)
    radioRuneBtn:setPosition (cc.p (186, 574))
    viewBg:addChild (radioRuneBtn)
    local runeBtnSize = radioRuneBtn:getContentSize()
    local runeText = ccui.Text:create("圣物","Arail",30)
    runeText:setPosition (cc.p(runeBtnSize.width/2, runeBtnSize.height/2))
    radioRuneBtn:addChild (runeText)
    self.radioBtnGroup:addRadioButton(radioRuneBtn)

    local radioMaterBtn = ccui.RadioButton:create("fuwen_anniu_cailiao_an.png", "fuwen_anniu_cailiao_liang.png")
    radioMaterBtn:setZoomScale(0)
    radioMaterBtn:setPosition (cc.p (530, 574))
    viewBg:addChild (radioMaterBtn)
    local MaterBtnSize = radioMaterBtn:getContentSize()
    local materText = ccui.Text:create("材料","Arail",30)
    materText:setPosition (cc.p(MaterBtnSize.width/2, MaterBtnSize.height/2))
    radioMaterBtn:addChild (materText)
    self.radioBtnGroup:addRadioButton(radioMaterBtn)
    -- 强化
    self.btnStrength = me.assignWidget(self, "btn_strength")
    me.registGuiClickEventByName(self, "btn_strength", function(node)
        if #self.arrRuneBackpack <= 0 then
            return
        end
        local selectIndex = self.radioRuneBtnGroup:getSelectedButtonIndex()
        local runeInfo = self.arrRuneBackpack[selectIndex+1]

        local strengthView = runeStrengthView:create("rune/runeStrengthView.csb")
        
        me.runningScene():addChild(strengthView, me.MAXZORDER)
        
        strengthView:setSelectRuneInfo(runeInfo)
        me.showLayer(strengthView, "bg")
    end )
    -- 穿戴
    me.registGuiClickEventByName(self, "btn_puton", function(node)
        -- 装备符文
        if #self.arrRuneBackpack <= 0 then
            return
        end
        local selectIndex = self.radioRuneBtnGroup:getSelectedButtonIndex()
        local runeInfo = self.arrRuneBackpack[selectIndex+1]
        local index = cfg[CfgType.RUNE_DATA][runeInfo.cfgId].type
        NetMan:send(_MSG.Rune_equip(index, runeInfo.id))
        showWaitLayer ()
    end )
    -- 分解
    me.registGuiClickEventByName(self, "btn_takeoff", function(node)
        if #self.arrRuneBackpack <= 0 then
            return
        end
        local selectIndex = self.radioRuneBtnGroup:getSelectedButtonIndex()
        local runeInfo = self.arrRuneBackpack[selectIndex+1]

        local breakView = runeBreakView:create("rune/runeBreakView.csb")
     
        me.runningScene():addChild(breakView, me.MAXZORDER)
      
        breakView:setSelectRuneInfo(runeInfo)
        me.showLayer(breakView, "bg")
    end )
    -- 符文列表
    self.runeList = me.assignWidget(self, "scroll_rune")
    self.runeList:setScrollBarEnabled (false)
    -- 材料列表
    self.materList = me.assignWidget(self, "scroll_mater")
    self.materList:setScrollBarEnabled (false)
    -- 符文属性列表
    self.runePropList = me.assignWidget(self, "list_property")
    self.runePropList:setScrollBarEnabled (false)

    self.panelRuneDetail = me.assignWidget(self, "Panel_rune_0")
    self.panelRuneInfo = me.assignWidget(self, "Panel_rune")
    self.panelMaterInfo = me.assignWidget(self, "Panel_mater")
    -- 合成
    self.btnComposite = me.assignWidget(self, "btn_composite")
    self.btnComposite:addClickEventListener(function (sender)
        -- 最大合成数量
        local curIndex = self.radioBtnGroup:getSelectedButtonIndex()
        if curIndex ~= self.runeMaterList.MATER then
            return
        end
        local selectIndex = self.radioMaterBtnGroup:getSelectedButtonIndex()
        local materData = self.arrmaterBackpack[selectIndex+1]
        local materMapCfg = cfg[CfgType.RUNE_MAP][materData.defid]

        local function confirmCallback(selectNum)
            print ("selectNum = " .. selectNum)
            NetMan:send(_MSG.Prop_compound(materMapCfg.destID ,selectNum))
            showWaitLayer ()
        end
        local selectView = selectNumberView:create("selectNumberView.csb")
        
        me.runningScene():addChild(selectView, me.MAXZORDER)
       
        selectView:setSliderMaxNum(math.floor(materData.count/4))
        local titleData = {
            {
                strTitle = "请选择合成数量",
                font = "Arail",
                fontSize = 30,
                hAlignment = cc.TEXT_ALIGNMENT_LEFT,
                textColor = cc.c4b(255, 255, 255, 255)
            },
        }
        selectView:setTitleData(titleData, 10)
        local btnTextData = {text = "合成"}
        selectView:setBtnConfirmText(btnTextData)
        selectView:registerConfirmCallback(confirmCallback)
        me.showLayer(selectView, "bg")
    end)
    self.text_top_level   = me.assignWidget(self, "text_top_level")
    self.text_mater_use   = me.assignWidget(self, "text_mater_use")
    self.icon_dest_bg     = me.assignWidget(self, "sp_ditu")

    self.compositeView = {}
    for k=1, 4 do
        local tbView = {}
        local spIconName = "mater_icon_" .. k
        local textIconName = "text_mater_icon_name" .. k
        local iconFrame = "mater_icon_frame" .. k
        local textBgName = "sp_runeNameBg" .. k
        local spIcon = me.assignWidget(self, spIconName)
        local textIcon = me.assignWidget(self, textIconName)
        local spFrame = me.assignWidget(self, iconFrame)
        local spTextBg = me.assignWidget(self, textBgName)
        tbView.spriteIcon = spIcon
        tbView.textIcon   = textIcon
        tbView.spFrame    = spFrame
        tbView.spTextBg    = spTextBg
        table.insert (self.compositeView, tbView)
    end
    self.iconMaterComposite = me.assignWidget(self, "icon_mater_composite")
    self.textMaterComposite = me.assignWidget(self, "text_mater_name_composite")

    self:updateRuneScrollView()
    self:updateMaterScrollView()
    self:updatePropertyList()
    self:updateMaterInfo()

    self:updateSelectScrollView ()

    return true
end

function runeBagView:setSelectedButton(index1, runeOrMaterId)
    index1 = index1 or 0
    if index1==nil or index1 < 0 or index1 >= 2 then
        return
    end
    self.radioBtnGroup:setSelectedButton(index1)

    local index2 = 0
    if index1 == 0 then
        for i = 1, #self.arrRuneBackpack do
            if self.arrRuneBackpack[i].id == runeOrMaterId then
                index2 = i - 1
                break
            end
        end
        if index2 < 0 or index2 >= #self.arrRuneBackpack then
            return
        end
        self.radioRuneBtnGroup:setSelectedButton(index2)
    elseif index1 == 1 then
        for i = 1, #self.arrmaterBackpack do
            if self.arrmaterBackpack[i].defid == runeOrMaterId then
                index2 = i - 1
                break
            end
        end
        if index2 < 0 or index2 >= #self.arrmaterBackpack then
            return
        end
        self.radioMaterBtnGroup:setSelectedButton(index2)
    end
end

function runeBagView:updateSelectScrollView()
    local selectIndex = self.radioBtnGroup:getSelectedButtonIndex()
    if selectIndex == self.runeMaterList.RUNE then
        self.runeList:setVisible(true)
        self.materList:setVisible(false)
        self.panelRuneInfo:setVisible(true)
        self.panelMaterInfo:setVisible(false)
    else
        self.runeList:setVisible(false)
        self.materList:setVisible(true)
        self.panelRuneInfo:setVisible(false)
        self.panelMaterInfo:setVisible(true)
    end
end
-- 符文列表
function runeBagView:updateRuneScrollView()
    self.runeList:removeAllChildren()
    self.radioRuneBtnGroup:removeAllRadioButtons()

    local runeNum = #self.arrRuneBackpack
    local rowNum = math.ceil(runeNum / 6)

    local containerSize = self.runeList:getInnerContainerSize()

    local radioBtn = ccui.RadioButton:create("fuwen_kuang_quelity1.png", "kaogu_kuang_xuanzhong.png")
    radioBtn:setZoomScale(0)
    local itemSize = radioBtn:getContentSize()

    local offsetRow = 3
    local offsetCol = 12

    local continerHeight = rowNum*(itemSize.height+offsetCol)
    if continerHeight > containerSize.height then
        containerSize.height = continerHeight
        self.runeList:setInnerContainerSize(containerSize)
    end
    for k, v in pairs (self.arrRuneBackpack) do
		local runeBaseCfg = cfg[CfgType.RUNE_DATA][v.cfgId]

        local listItem = radioBtn:clone ()
        self.radioRuneBtnGroup:addRadioButton(listItem)

        local col = k % 6
        if col == 0 then col = 6 end
        local row = math.floor((k+5)/6)
        local offsetXValue = 2*col - 1
        local offsetYValue = 2*row - 1

        local imagePosX = offsetXValue*(offsetRow+itemSize.width)/2
        local imagePosY = containerSize.height - offsetYValue*(offsetCol+itemSize.height)/2
        listItem:setPosition (imagePosX, imagePosY)
        self.runeList:addChild (listItem)
        -- Icon
		local fileIcon = getRuneIcon(runeBaseCfg.id)
        local runeIcon = cc.Sprite:createWithSpriteFrameName (fileIcon)
        runeIcon:setPosition (itemSize.width/2, itemSize.height/2)
        listItem:addChild (runeIcon)

        local strengthLvBg = cc.Sprite:create ("fuwen_kuang_dengji.png")
        strengthLvBg:setPosition (cc.p (strengthLvBg:getContentSize().width/2+7, strengthLvBg:getContentSize().height/2+7))
        listItem:addChild (strengthLvBg)
        -- 强化等级
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][v.glv]
        local textStrengthLv = ccui.Text:create(tostring(runeStrengthCfg.level), "Arail", 22)
        textStrengthLv:setAnchorPoint(cc.p (0.5, 0.5))
        textStrengthLv:setPosition (strengthLvBg:getContentSize().width/2+7, strengthLvBg:getContentSize().height/2+7)
        listItem:addChild (textStrengthLv)

        if v.isnew == true then
            local newIcon = cc.Sprite:create ("gongyong_icon_tishi.png")
            newIcon:setPosition (itemSize.width-newIcon:getContentSize().width/2-5, itemSize.height-newIcon:getContentSize().height/2-5)
            listItem:addChild (newIcon, 0, "newIcon")
        end
    end
    for k=#self.arrRuneBackpack+1, 24 do
        local listItem = ccui.ImageView:create("fuwen_kuang_quelity1.png")

        local col = k % 6
        if col == 0 then col = 6 end
        local row = math.floor((k+5)/6)
        local offsetXValue = 2*col - 1
        local offsetYValue = 2*row - 1

        local imagePosX = offsetXValue*(offsetRow+itemSize.width)/2
        local imagePosY = containerSize.height - offsetYValue*(offsetCol+itemSize.height)/2
        listItem:setPosition (imagePosX, imagePosY)
        self.runeList:addChild (listItem)
    end
end
-- 材料列表
function runeBagView:updateMaterScrollView()
    self.materList:removeAllChildren()
    self.radioMaterBtnGroup:removeAllRadioButtons()

    local runeNum = #self.arrmaterBackpack
    local rowNum = math.ceil(runeNum / 6)

    local containerSize = self.materList:getInnerContainerSize()

    local radioBtn = ccui.RadioButton:create("fuwen_kuang_quelity1.png", "fuwen_kuang_xuanzhong.png")
    radioBtn:setZoomScale(0)
    local itemSize = radioBtn:getContentSize()

    local offsetRow = 3
    local offsetCol = 12

    local continerHeight = rowNum*(itemSize.height+offsetCol)
    if continerHeight > containerSize.height then
        containerSize.height = continerHeight
        self.materList:setInnerContainerSize(containerSize)
    end
    for k, v in pairs (self.arrmaterBackpack) do
        local etcCfg = cfg[CfgType.ETC][v.defid]

        local listItem = radioBtn:clone ()
        self.radioMaterBtnGroup:addRadioButton(listItem)

        local col = k % 6
        if col == 0 then col = 6 end
        local row = math.floor((k+5)/6)
        local offsetXValue = 2*col - 1
        local offsetYValue = 2*row - 1

        local imagePosX = offsetXValue*(offsetRow+itemSize.width)/2
        local imagePosY = containerSize.height - offsetYValue*(offsetCol+itemSize.height)/2
        listItem:setPosition (imagePosX, imagePosY)
        self.materList:addChild (listItem)
        -- Icon
        local runeIcon = cc.Sprite:create ()
		runeIcon:setSpriteFrame(getItemIcon(v.defid))
        runeIcon:setPosition (itemSize.width/2, itemSize.height/2)
        listItem:addChild (runeIcon)

        local image = ccui.ImageView:create ("beibao_beijing_shuzi_xia.png")
        image:setAnchorPoint(cc.p (0.5, 0))
        image:setScaleX (0.7)
        image:setPosition (cc.p (itemSize.width/2, 5))
        listItem:addChild (image)
        local imageSize = image:getContentSize()

        local textCount = ccui.Text:create (tostring(v.count), "Arail", 22)
        textCount:setAnchorPoint(cc.p (1, 0.5))
        textCount:setPosition (cc.p (imageSize.width-5, imageSize.height/2))
        image:addChild (textCount)

        listItem.etcCfgId = v.defid
        listItem.textCount = textCount
    end
    for k=#self.arrmaterBackpack+1, 24 do
        local listItem = ccui.ImageView:create("fuwen_kuang_quelity1.png")

        local col = k % 6
        if col == 0 then col = 6 end
        local row = math.floor((k+5)/6)
        local offsetXValue = 2*col - 1
        local offsetYValue = 2*row - 1

        local imagePosX = offsetXValue*(offsetRow+itemSize.width)/2
        local imagePosY = containerSize.height - offsetYValue*(offsetCol+itemSize.height)/2
        listItem:setPosition (imagePosX, imagePosY)
        self.materList:addChild (listItem)
    end
end
-- 更新符文属性
function runeBagView:updatePropertyList()
    self.runePropList:removeAllItems()

    if #self.arrRuneBackpack <= 0 then
        self.panelRuneDetail:setVisible (false)
        return
    end

    self.panelRuneDetail:setVisible (true)
    local selectIndex = self.radioRuneBtnGroup:getSelectedButtonIndex()
    -- icon
    local runeInfo = self.arrRuneBackpack[selectIndex+1]
    local runeBaseCfg = cfg[CfgType.RUNE_DATA][runeInfo.cfgId]
    local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][runeInfo.glv]
    local extendRuneAttCfg = cfg[CfgType.RUNE_PROPERTY]

    self.runeName:setString(runeBaseCfg.name)
    -- 符文icon
    local fileIcon = getRuneIcon(runeInfo.cfgId)
    self.runeIcon:setSpriteFrame(fileIcon)
    -- 强化等级
    self.runeSetLv:setString ("强化等级 " .. runeStrengthCfg.level)
    -- 强化属性
    local strengthCfgAtt = {}
    local strPropKV = string.split(runeStrengthCfg.property, ",")
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = arrKV[2]
        local attName = cfg[CfgType.LORD_INFO][attKey].name .. ": +" .. attValue
        table.insert (strengthCfgAtt, attName)
    end
    --附加攻击
    self.rune_extra_pro:setString(strengthCfgAtt[1])
    -- 基本属性
    strPropKV = string.split(runeBaseCfg.basePro, ",")
    for k, v in pairs (strPropKV) do
        local arrKV = string.split(v, ":")
        local attKey = arrKV[1]
        local attValue = arrKV[2]
        local attName = cfg[CfgType.LORD_INFO][attKey].name .. ": "
        if tonumber (attValue) < 1 then
            attValue = "+" .. math.floor(attValue*100) .. "%"
        else
            attValue = "+" .. attValue
        end

        local textAttribute = ccui.Text:create(attName .. attValue, "Arail", 24)
        textAttribute:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        textAttribute:setAnchorPoint(cc.p(0, 0.5))
        textAttribute:setTextColor (cc.c4b(63, 54, 33, 255))
        self.runePropList:pushBackCustomItem(textAttribute)
    end
    if #runeInfo.aptPro > 0 then
        local textExtendTitle = ccui.Text:create("追加属性", "Arail", 24)
        textExtendTitle:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        textExtendTitle:setAnchorPoint(cc.p(0, 0.5))
        textExtendTitle:setTextColor (cc.c4b(137, 226, 66, 255))
        self.runePropList:pushBackCustomItem(textExtendTitle)
        for k, v in pairs (runeInfo.aptPro) do
            local basePropKV = string.split(extendRuneAttCfg[v].property, ",")
            for k, v in pairs (basePropKV) do
                local arrKV = string.split(v, ":")
                local attKey = arrKV[1]
                local attValue = arrKV[2]
                local attName = cfg[CfgType.LORD_INFO][attKey].name .. ": "
                if tonumber (attValue) < 1 then
                    attValue = "+" .. math.floor(attValue*100) .. "%"
                else
                    attValue = "+" .. attValue
                end
                local textAttribute = ccui.Text:create(attName .. attValue, "", 24)
                textAttribute:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
                textAttribute:setAnchorPoint(cc.p(0, 0.5))
                textAttribute:setTextColor (cc.c4b(137, 226, 66, 255))
                self.runePropList:pushBackCustomItem(textAttribute)
            end
        end
    end
end
-- 符文材料信息
function runeBagView:updateMaterInfo()
    local selectIndex = self.radioMaterBtnGroup:getSelectedButtonIndex()
    if selectIndex < 0 then
        self.iconMaterComposite:setVisible (false)
        self.textMaterComposite:setVisible (false)
        self.btnComposite:setVisible(false)
        self.text_mater_use:setVisible(false)
        self.icon_dest_bg:setVisible(false)
        self.text_top_level:setVisible(false)
        for k=1, 4 do
            self.compositeView[k].textIcon:setVisible (false)
            self.compositeView[k].spriteIcon:setVisible (false)
            self.compositeView[k].spFrame:setVisible (false)
            self.compositeView[k].spTextBg:setVisible (false)
        end
        return
    end

    local runeMaterData = self.arrmaterBackpack[selectIndex+1]
    local materBaseCfg = cfg[CfgType.ETC][runeMaterData.defid]
    local materMapCfg = cfg[CfgType.RUNE_MAP][runeMaterData.defid]

    self.iconMaterComposite:setVisible (true)
    self.textMaterComposite:setVisible (true)
    self.text_mater_use:setVisible(true)
    self.icon_dest_bg:setVisible(true)

    if materMapCfg.destID == 0 then
        -- 达到最大等级，不能升级了
        self.btnComposite:setVisible(false)
        self.text_top_level:setVisible(true)

        self.iconMaterComposite:loadTexture (getItemIcon(materBaseCfg.id), UI_TEX_TYPE_PLIST)
        self.textMaterComposite:setString (materBaseCfg.name)
        self.text_mater_use:setString(materBaseCfg.describe)

        for k=1, 4 do
            self.compositeView[k].spriteIcon:setVisible(false)
            self.compositeView[k].textIcon:setVisible (false)
            self.compositeView[k].spFrame:setVisible (false)
            self.compositeView[k].spTextBg:setVisible (false)
        end
    else
        self.btnComposite:setVisible(true)
        self.text_top_level:setVisible(false)

        local nextMaterBaseCfg = cfg[CfgType.ETC][materMapCfg.destID]
        local nextMaterMapCfg = cfg[CfgType.RUNE_MAP][nextMaterBaseCfg.id]
        self.iconMaterComposite:loadTexture (getItemIcon(nextMaterBaseCfg.id), UI_TEX_TYPE_PLIST)
        self.textMaterComposite:setString (nextMaterBaseCfg.name)

        self.text_mater_use:setString(nextMaterBaseCfg.describe)

        local arrNeedItem = string.split(nextMaterMapCfg.needItem, ":")
        local attCfgId = tonumber(arrNeedItem[1])
        local attCount = tonumber(arrNeedItem[2])

        for k=1, attCount do
            local itemIconFile = getItemIcon(attCfgId)
            if k <= runeMaterData.count then
                self.compositeView[k].textIcon:setVisible (true)
                self.compositeView[k].spTextBg:setVisible (true)
                self.compositeView[k].spriteIcon:setVisible (true)
                self.compositeView[k].spriteIcon:setSpriteFrame(itemIconFile)
                self.compositeView[k].textIcon:setString (materBaseCfg.name)
            else
                self.compositeView[k].textIcon:setVisible (false)
                self.compositeView[k].spTextBg:setVisible (false)
                self.compositeView[k].spriteIcon:setVisible (false)
            end
            self.compositeView[k].spFrame:setVisible (true)
        end
        if runeMaterData.count >= 4 then
            self.btnComposite:setBright(true)
            self.btnComposite:setTouchEnabled(true)
        else
            self.btnComposite:setBright(false)
            self.btnComposite:setTouchEnabled(false)
        end
    end
end