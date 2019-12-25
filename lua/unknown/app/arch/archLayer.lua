-- [Comment]
-- jnmo
archLayer = class("archLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
archLayer.__index = archLayer
function archLayer:create(...)
    local layer = archLayer.new(...)
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
function archLayer:ctor()
    print("archLayer ctor")
    self.selectDebrisIndex = 1
    self.archPlot = { }
    self.descIndex = 0
end
function archLayer:init()
    print("archLayer init")
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        self.pParent.archbool = false
        self:close()
    end )
    self.Image_Left = me.assignWidget(self, "Image_Left")

    self.BookMenuId = 1
    self.selectImg = nil
    self.tableView = nil
    self.pBoolDress = false
    self.pTag = 1
    self.ComposeNum = 0
    self.pPitchNameStr = ""
    self.mPitchComId = 0
    self.pLoadingBar = me.assignWidget(self, "LoadingBar_Book")
    self.pLoadingBar:setPercent(0)
    self.pComposeNumLabel = me.assignWidget(self, "loading_num")
    self.pComposeNumLabel:setString("x" .. 0)
    self.left_list_panel = me.assignWidget(self, "left_list_panel")
    me.assignWidget(self, "arch_amintion"):setVisible(false)
    me.assignWidget(self, "arch_Info_bg"):setVisible(false)

    self.pBookMewnu = cfg[CfgType.BOOKMENU]
    self.pOpenNum = table.maxn(user.bookHand)
    self.BookMenuId = mAppBookMenuId
    for key, var in pairs(user.bookHand) do
        if var == mAppBookMenuId then
            self.ListNum = key - 1
        end
    end
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        me.assignWidget(self, "arch_Info_bg"):setVisible(false)
    end )
    GMan():send(_MSG.roleLandInfo())
    self.Button_manual = me.registGuiClickEventByName(self, "Button_manual", function(node)
        NetMan:send(_MSG.book_tech_menu())
        local manualLayer = archManualLayer:create("archManualLayer.csb")
        me.popLayer(manualLayer)
        me.assignWidget(node, "red_point"):setVisible(false)
    end )
    return true
end
function archLayer:setData()
    self:initLeftList()
    self:setBookData()
    self:setRight(self.pTag)
end
function archLayer:setAppoint()
    print("mAppBookId.........." .. mAppBookId)
    local pKey = self.pTag
    --    if mAppBookId ~= 1 then
    --       for key, var in pairs(self.mBookData) do
    --           if mAppBookId == me.toNum(var["id"]) then
    --              pKey = key
    --              break
    --           end
    --       end
    --    end
    local pCellNum = math.floor(pKey / 4)
    if pKey % 4 ~= 0 then
        pCellNum = pCellNum + 1
    end
    if pCellNum <(self.iNum - 2) then
        if pCellNum < 3 then
        else
            local pOffestY =(self.iNum - 2 - pCellNum) * 117
            self.tableView:reloadData()
            self.tableView:setContentOffset(cc.p(0, - pOffestY))
        end
    else
        self.tableView:reloadData()
        self.tableView:setContentOffset(cc.p(0, 0))
    end
    self.selectImg:setPosition(cc.p(self:getCellPoint(pKey, self.iNum)))
end
function archLayer:setLayerType(pNode)
    self.pParent = pNode
end
function archLayer:initLeftList(data)
    self.left_list_panel:removeAllChildren()
    local w = self.left_list_panel:getContentSize().width - 100
    local h = self.left_list_panel:getContentSize().height - 100
    local globalItems = me.createNode("Node_arch_Item.csb")
    local item_ = me.assignWidget(globalItems, "arch_Item")
    self.list = mListMenu:createListMenu(false, w, h)
    self.pOpenNum = table.maxn(user.bookHand)
    for key, var in pairs(user.bookHand) do
        local item = item_:clone()
        local pConfig = cfg[CfgType.BOOKMENU][var]
        local pBookName = me.assignWidget(item, "Text_Name")
        pBookName:setString(pConfig["name"])
        local pBookIcon = me.assignWidget(item, "Image_Icon")
        pBookIcon:loadTexture("arch_" .. pConfig["icon"] .. ".png", me.localType)
        item.index = key
        self.list:addMenuItem(item)
    end
    self.list:setCalcFactor(0.92)
    local function scroll_callback(node, str)
        print("str = " .. str)
        print(node.index)
        local pMenuId = node.index
        if self.BookMenuId ~= user.bookHand[pMenuId] then
            self.ListNum = me.toNum(node.index - 1)
            self.pTag = 1
            mAppBookId = self.pTag
            self.BookMenuId = user.bookHand[pMenuId]
            mAppBookMenuId = self.BookMenuId
            NetMan:send(_MSG.initBook(self.BookMenuId))
        end
    end
    self.list:addScrollSelectEvent(scroll_callback)
    self.list:setPosition(self.left_list_panel:getContentSize().width / 2, self.left_list_panel:getContentSize().height / 2)
    self.list:setIndex(self.ListNum)
    self.list:updatePositionWithAnimation()
    self.left_list_panel:addChild(self.list)

    -- 携带
    self.Button_carryabout = me.assignWidget(self, "Button_carryabout")
    me.registGuiClickEvent(self.Button_carryabout, function(node)
        local view = overlordView:create("overlordView.csb")
        self.pParent:addChild(view, me.MAXZORDER)
        self:close()
    end )
end
-- 返回选中格子的坐标，参数：第几个格子，table的个数
function archLayer:getCellPoint(pTag, TableNum)
    pTag = me.toNum(pTag)
    self.pCellId = pTag
    local pRow = math.floor((pTag - 1) / 4)
    -- 行数
    local pLine = pTag % 4
    -- 列数
    if pLine == 0 then
        pLine = 4
    end
    local pPointX = 12 + (pLine - 1) * (129 + 8) + 129 / 2
    local pPointY = (TableNum - pRow - 1) * (129 + 10 + 5) + 10 + 129 / 2
    return pPointX, pPointY
end

function archLayer:setBookData()
    self.mBookData = { }
    for key, var in pairs(user.bookAtlas) do
        local pNum = 0
        if table.maxn(mBookAltasNum) ~= 0 then
            pNum = mBookAltasNum[self.BookMenuId][var["id"]]["num"]
        end
        var.order = cfg[CfgType.BOOK][var["id"]]["order"]
        var.Altas = pNum
        table.insert(self.mBookData, 1, var)
    end
    me.assignWidget(self, "midlist_node"):removeAllChildren()
    local function archCom(pa, pb)
        return pa["order"] < pb["order"]
    end
    table.sort(self.mBookData, archCom)
    -- dump(self.mBookData)
    if mAppBookId ~= 1 then
        for key, var in pairs(self.mBookData) do
            if mAppBookId == me.toNum(var["id"]) then
                self.pTag = key
                break
            end
        end
    end
    self:initMidList()
    self:setAppoint()
end

function archLayer:setRight(pTag)
    self.descIndex = 0
    local pData = self.mBookData[pTag]
    self.pTag = pTag
    if pData then
        mAppBookId = pData["id"]
        self.mStatusData = pData
        self.mPitchData = cfg[CfgType.BOOK][pData["id"]]
        local pEtc = cfg[CfgType.ETC][self.mPitchData["id"]]
        --    dump(self.mPitchData)

        local pIcon = me.assignWidget(self, "pitch_icon")
        pIcon:loadTexture(getItemIcon(pEtc["id"]), me.plistType)

        local pQuity = me.assignWidget(self, "pitch_quilty")
        pQuity:loadTexture(getArchQuility(pData["id"]), me.localType)

        local pName = me.assignWidget(self, "pitch__name")
        pName:setString(pEtc["name"])
        self.pPitchNameIcon = getItemIcon(pEtc["id"])
        local pDetails = me.assignWidget(self, "pitch_details")
        print(pEtc["describe"])
        local descs = me.split(pEtc["describe"], "|")
        pDetails:setString(descs[self:getItemLevel(pData["id"]) + 1])
        local canlevel =(self:getItemLevel(pData["id"]) + 1) < #descs
        if canlevel then
            local Button_LevelUp = me.registGuiClickEventByName(self, "Button_LevelUp", function(rev)
                if self.descIndex == 0 then
                    self.descIndex = 1
                    pDetails:setString(descs[self:getItemLevel(pData["id"]) + 2])
                    rev:loadTextureNormal("kaogu_jinshengqian.png", me.localType)
                else
                    self.descIndex = 0
                    rev:loadTextureNormal("kaogu_jinshenghou.png", me.localType)
                    pDetails:setString(descs[self:getItemLevel(pData["id"]) + 1])
                end

            end )
            Button_LevelUp:setVisible(true)
            if self.descIndex == 0 then
                Button_LevelUp:loadTextureNormal("kaogu_jinshenghou.png", me.localType)
            elseif self.descIndex == 1 then
                Button_LevelUp:loadTextureNormal("kaogu_jinshengqian.png", me.localType)
            end
        else
            me.assignWidget(self, "Button_LevelUp"):setVisible(false)
        end
        local pNumLabel = me.assignWidget(self, "pitch_num")
        local pNum = self:getHaveNum(pData["id"])
        if pNum > 0 then
            pNumLabel:setString(pNum)
            pNumLabel:setVisible(true)
            me.assignWidget(self, "pitch_have"):setVisible(true):setString("拥有")
        else
            me.assignWidget(self, "pitch_have"):setVisible(false)
        end
        --  dump(self.mPitchData)
        local pComposeNum = self.mStatusData["Altas"]
        if pComposeNum > self.ComposeNum or self.ComposeNum == 0 then
            local pNeedData = me.split(self.mPitchData["recipe"], ",")
            me.assignWidget(self, "pitch_group_node"):removeAllChildren()
            for key, var in pairs(pNeedData) do
                local pGoodsData = me.split(var, ":")
                local pId = pGoodsData[1]
                local pNeedNum = pGoodsData[2]
                local pGroup_bg = me.assignWidget(self, "pitch_group_bg"):clone():setVisible(true)
                pGroup_bg:setPosition(cc.p(95 *((key - 1) % 4), - math.floor((key - 1) / 4) * 100))
                me.assignWidget(self, "pitch_group_node"):addChild(pGroup_bg)
                local pQuality = me.assignWidget(pGroup_bg, "pitch_group_quality")
                pQuality:loadTexture(getArchQuility(pId), me.localType)
                local pRecipe = me.assignWidget(pGroup_bg, "pitch_group_icon")
                pRecipe:loadTexture(getItemIcon(pId), me.plistType)
                pRecipe:setTag(pId)
                local pRecNum = me.assignWidget(pGroup_bg, "pitch_group_num")
                local pHaveNum = self:getHaveNum(pId)
                pHaveNum = pHaveNum -(self.ComposeNum * pNeedNum)
                --    pHaveNum = math.max(0,pHaveNum)
                pRecNum:setString(Scientific(pHaveNum) .. "/" .. pNeedNum)
                if me.toNum(pHaveNum) < me.toNum(pNeedNum) then
                    pRecNum:setTextColor(me.convert3Color_("ED6464"))
                else
                    pRecNum:setTextColor(COLOR_GREEN)
                end
                local archdata = cfg[CfgType.ETC][tonumber(pId)]
                -- 大于为了判断是否是合成建筑
                local showseach =(tonumber(archdata.useType) == 102 and tonumber(pNeedNum) > 2)
                me.registGuiClickEvent(pRecipe, function(node)
                    local pId = node:getTag()
                    self:ArchInfo(pId, showseach)
                end )
                --       pIdLabel:setVisible(false)
            end
        end
        --  dump(self.mPitchData)
        -- 合成
        self.Button_Altas = me.assignWidget(self, "Button_Altas")
        --self.Button_Altas:setTitleText(self:getButtonName(self.mPitchData))
        me.assignWidget(self.Button_Altas, "text_title_btn"):setString(self:getButtonName(self.mPitchData))

        if pComposeNum > 0 then
            self.Button_Altas:setBright(true)
            self.Button_Altas:setTouchEnabled(true)
            self.Button_Altas:setTitleColor(cc.c4b(227, 226, 198, 255))
        else
            self.Button_Altas:setBright(false)
            self.Button_Altas:setTouchEnabled(false)
            self.Button_Altas:setTitleColor(cc.c4b(102, 102, 102, 255))
        end
        if pComposeNum > self.ComposeNum then
            self.Button_Altas:setBright(true)
            self.Button_Altas:setTouchEnabled(true)
            self.Button_Altas:setTitleColor(cc.c4b(227, 226, 198, 255))
        else
            self.Button_Altas:setBright(false)
            self.Button_Altas:setTouchEnabled(false)
            self.Button_Altas:setTitleColor(cc.c4b(102, 102, 102, 255))
        end
        if self.mPitchData["num"] == 1 then
            if pNum >= self.mPitchData["num"] then
                pNumLabel:setVisible(false)
                local pHaveLabel = me.assignWidget(self, "pitch_have"):setVisible(true)
                pHaveLabel:setString("已拥有")
                if canlevel then
                    --self.Button_Altas:setTitleText("晋升")
                    me.assignWidget(self.Button_Altas, "text_title_btn"):setString("晋 升")
                else
                    self.Button_Altas:setBright(false)
                    self.Button_Altas:setTouchEnabled(false)
                    self.Button_Altas:setTitleColor(cc.c4b(102, 102, 102, 255))
                end
            else
                me.assignWidget(self, "Button_LevelUp"):setVisible(false)
            end
        else
            me.assignWidget(self, "Button_LevelUp"):setVisible(false)
        end
        me.registGuiClickEvent(self.Button_Altas, function(node)
            me.assignWidget(self, "arch_Info_bg"):setVisible(false)
            self.mPitchComId = self.mPitchData["id"]
            if self.mPitchData["num"] == 1 then
                if pNum < self.mPitchData["num"] then
                    if self.mStatusData["status"] == 1 then
                        if self.ComposeNum < pComposeNum then
                            me.assignWidget(self, "arch_amintion"):setVisible(true)
                            if self.ComposeNum == 0 then
                                self.ComposeNum = 1
                                self:setReduce(false)
                                self:setAmintion()
                            else
                                showTips("达到最大合成数")
                            end
                        else
                            showTips("材料不足")
                        end
                    else
                        showTips("图鉴没有开放")
                    end
                else
                    if canlevel then

                        NetMan:send(_MSG.bookCompoundLevel(self:getItemData(pData["id"])["uid"]))
                    else
                        showTips("达到最大合成数")
                    end
                end
            else
                if self.mStatusData["status"] == 1 then
                    if self.ComposeNum < pComposeNum then
                        me.assignWidget(self, "arch_amintion"):setVisible(true)
                        if self.ComposeNum == 0 then
                            self.ComposeNum = 1
                            self:setReduce()
                            self:setAmintion()
                        else
                            self.ComposeNum = self.ComposeNum + 1
                            self:setReduce()
                            self.pComposeNumLabel:setString("x" .. self.ComposeNum)
                        end
                    else
                        showTips("材料不足")
                    end
                else
                    showTips("图鉴没有开放")
                end
            end
        end )
    end
end
function archLayer:setReduce(pBool)
    self.Button_Altas = me.assignWidget(self, "Button_Altas")
    --self.Button_Altas:setTitleText(self:getButtonName(self.mPitchData))
    me.assignWidget(self.Button_Altas, "text_title_btn"):setString(self:getButtonName(self.mPitchData))
    local pComposeNum = self.mStatusData["Altas"]
    if pBool == nil then
        if pComposeNum > self.ComposeNum then
            self.Button_Altas:setBright(true)
            self.Button_Altas:setTouchEnabled(true)
            self.Button_Altas:setTitleColor(cc.c4b(227, 226, 198, 255))
        else
            self.Button_Altas:setBright(false)
            self.Button_Altas:setTouchEnabled(false)
            self.Button_Altas:setTitleColor(cc.c4b(102, 102, 102, 255))
        end
    else
        self.Button_Altas:setBright(false)
        self.Button_Altas:setTouchEnabled(false)
        self.Button_Altas:setTitleColor(cc.c4b(102, 102, 102, 255))
    end

    local pNeedData = me.split(self.mPitchData["recipe"], ",")
    me.assignWidget(self, "pitch_group_node"):removeAllChildren()
    for key, var in pairs(pNeedData) do
        local pGoodsData = me.split(var, ":")
        local pId = pGoodsData[1]
        local pNeedNum = pGoodsData[2]
        local pGroup_bg = me.assignWidget(self, "pitch_group_bg"):clone():setVisible(true)
        print(key, "-------------------------------")
        pGroup_bg:setPosition(cc.p(95 *((key - 1) % 4), - math.floor((key - 1) / 4) * 100))
        me.assignWidget(self, "pitch_group_node"):addChild(pGroup_bg)
        local pQuality = me.assignWidget(pGroup_bg, "pitch_group_quality")
        pQuality:loadTexture(getArchQuility(pId), me.localType)
        local pRecipe = me.assignWidget(pGroup_bg, "pitch_group_icon")
        pRecipe:loadTexture(getItemIcon(pId), me.plistType)
        pRecipe:setTag(pId)

        local pRecNum = me.assignWidget(pGroup_bg, "pitch_group_num")

        local pHaveNum = self:getHaveNum(pId)
        pHaveNum = pHaveNum -(self.ComposeNum * pNeedNum)
        --     pHaveNum = math.max(0,pHaveNum)
        pRecNum:setString(Scientific(pHaveNum) .. "/" .. pNeedNum)
        if me.toNum(pHaveNum) < me.toNum(pNeedNum) then
            pRecNum:setTextColor(me.convert4Color_("ae3710"))
        else
            pRecNum:setTextColor(me.convert4Color_("66a053"))
        end
        local archdata = cfg[CfgType.ETC][tonumber(pId)]
        local showseach =(tonumber(archdata.useType) == 102 and tonumber(pNeedNum) > 2)
        me.registGuiClickEvent(pRecipe, function(node)
            local pId = node:getTag()
            self:ArchInfo(pId, showseach)
        end )
        --       pIdLabel:setVisible(false)
    end
end
function archLayer:getButtonName(pData)
    local pStr = "合 成"
    if pData then
        if pData["buttonname"] == 1 then
            pStr = "打 造"
        elseif pData["buttonname"] == 2 then
            pStr = "召 唤"
        elseif pData["buttonname"] == 3 then
            pStr = "驯 养"
        elseif pData["buttonname"] == 4 then
            pStr = "建 筑"
        elseif pData["buttonname"] == 5 then
            pStr = "合 成"
        elseif pData["buttonname"] == 0 then
            pStr = "即将来临"
        end
    end
    return pStr
end
function archLayer:ArchInfo(pId, showseach)
    me.assignWidget(self, "arch_Info_bg"):setVisible(true)
    local pConfig = cfg[CfgType.ETC][pId]
    local pName = me.assignWidget(self, "arch_pitch_name")
    pName:setString(pConfig["name"])

    local pDec = me.assignWidget(self, "arch_pitch_conter")
    pDec:setString(pConfig["describe"])

    local pIcon = me.assignWidget(self, "arch_pitch_icon")
    pIcon:loadTexture(getItemIcon(pId), me.plistType)
    local pArchBool = false
    local pArchid = 0
    local pPointLabel = me.assignWidget(self, "arch_pitch_point")
    if showseach then
        for key, var in pairs(self.archPlot) do
            for key1, var1 in pairs(var.arch) do
                if me.toNum(var1) == pId then
                    pArchBool = true
                    pArchid = key
                    break
                end
            end
            if pArchBool then
                break
            end
        end

        if pArchBool then
            pPointLabel:setVisible(true)
            local pArchData = self.archPlot[pArchid]
            pPointLabel:setString("(" .. pArchData.point.x .. "," .. pArchData.point.y .. ")")
            local pButtonPoint = me.assignWidget(self, "Button_point")
            pButtonPoint:setTag(pArchid)

            me.registGuiClickEvent(pButtonPoint, function(node)
                local pIndx = me.toNum(node:getTag())
                local pData = self.archPlot[pIndx]
                local pX = pArchData.point.x
                local pY = pArchData.point.y
                self:setLookMap(cc.p(pX, pY))
            end )
        else
            pPointLabel:setVisible(true)
            pPointLabel:setString("点击搜索")
            local pButtonPoint = me.assignWidget(self, "Button_point")
            me.registGuiClickEvent(pButtonPoint, function(node)
                local px, py = self:findArchItemCell(pId)
                if px ~= -1 and py ~= -1 then
                    self:setLookMap(cc.p(px, py))
                else
                    showTips("当前范围未找到符合条件的土地")
                end
            end )
        end
        me.assignWidget(self, "Text_No"):setVisible(false)
    else
        pPointLabel:setVisible(false)
        me.assignWidget(self, "Text_No"):setVisible(true)
        local pButtonPoint = me.assignWidget(self, "Button_point")
        pButtonPoint:setTouchEnabled(false)
    end
end
function archLayer:setLookMap(pos)
    local pStr = "是否跳转到坐标" .. "(" .. pos.x .. "," .. pos.y .. ")"
    me.showMessageDialog(pStr, function(args)
        if args == "ok" then
            if pos.x > getWorldMapWidth() or pos.y > getWorldMapHeight() then
                showErrorMsg("此坐标为无效点！", 1)
                return
            end
            if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
                pWorldMap:RankSkipPoint(pos)
                self:close()
            elseif canJumpWorldMap() then
                mainCity:cloudClose( function(node)
                    print("跳转外城")
                    local loadlayer = loadWorldMap:create("loadScene.csb")
                    loadlayer:setWarningPoint(pos)
                    me.runScene(loadlayer)
                end )
                me.DelayRun( function()
                    self:close()
                end )
            end
        end
    end )
end
function archLayer:setAmintion()
    self.pCountTime = 0

    self.pLoadingBar:setPercent(0)

    self.pComposeNumLabel:setString("x" .. self.ComposeNum)
    self.pAmintionTime = me.registTimer(-1, function(dt)
        self.pCountTime = self.pCountTime + 2
        if self.pCountTime > 100 then
            self.ComposeNum = self.ComposeNum - 1
            self.pComposeNumLabel:setString("x" .. self.ComposeNum)
            if self.ComposeNum > 0 then
                NetMan:send(_MSG.bookCompound(self.mPitchComId, 1))
                self.pCountTime = 0
                self.pLoadingBar:setPercent(0)
                self:Compound()
            else
                NetMan:send(_MSG.bookCompound(self.mPitchComId, 1))
                me.clearTimer(self.pAmintionTime)
                self.ComposeNum = 0
                self.pLoadingBar:setPercent(0)
                self:Compound()
                me.assignWidget(self, "arch_amintion"):setVisible(false)
            end
        else
            self.pLoadingBar:setPercent(self.pCountTime)
        end
    end , 0)
end
function archLayer:getHaveNum(pId)
    local pHaveNum = 0
    for key, var in pairs(user.bookPkg) do
        if var["defid"] == me.toNum(pId) then
            pHaveNum = pHaveNum + var["count"]
        end
    end
    for key, var in pairs(user.bookEquip) do
        if var["defid"] == me.toNum(pId) then
            pHaveNum = pHaveNum + var["count"]
        end
    end
    return pHaveNum
end
function archLayer:getItemLevel(pId)
    for key, var in pairs(user.bookPkg) do
        if var["defid"] == me.toNum(pId) then
            return var.level
        end
    end
    for key, var in pairs(user.bookEquip) do
        if var["defid"] == me.toNum(pId) then
            return var.level
        end
    end
    return 0
end
function archLayer:getItemData(pId)
    for key, var in pairs(user.bookPkg) do
        if var["defid"] == me.toNum(pId) then
            return var
        end
    end
    for key, var in pairs(user.bookEquip) do
        if var["defid"] == me.toNum(pId) then
            return var
        end
    end
    return nil
end
function archLayer:initMidList()
    --    if self.selectImg ~=nil then
    --       self.selectImg:removeFromParentAndCleanup(true)
    --    end
    local num = math.max(#self.mBookData, 20)
    local cellNum
    local ofx = 12
    local ofy = 10
    if num % 4 ~= 0 then
        cellNum = math.floor(num / 4) + 1
    else
        cellNum = num / 4
    end
    self.iNum = cellNum
    local cellw = 129 + 8
    local function scrollViewDidScroll(view)
        print("scrollViewDidScroll")
    end
    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

        --    table:onTouchBegan()
    end

    local function cellSizeForTable(table, idx)
        return 563, 129 + ofy + 5
    end
    local curNum = #self.mBookData
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local archDebrisItem = archDebris:create("archDebris.csb")
                archDebrisItem:setTag(var)
                if self.mBookData[pTag] then
                    archDebrisItem:setData(self.mBookData[pTag], self:getItemLevel(self.mBookData[pTag].id))
                else
                    archDebrisItem:setData(self.mBookData[pTag], 0)
                end
                archDebrisItem:setPosition(cc.p((var - 1) * cellw + ofx, ofy))
                local buildBtn = me.assignWidget(archDebrisItem, "Image_Qua1")
                buildBtn:setTag(123)
                buildBtn:setName(pTag)
                print("pTag = " .. pTag)
                me.registGuiClickEvent(buildBtn, function(node)
                    local pTag = me.toNum(node:getName())
                    self.pTag = pTag
                    self.selectImg:setPosition(cc.p(self:getCellPoint(pTag, self.iNum)))
                    self:stopAniamtion()
                    self:setRight(pTag)
                    guideHelper.nextStepByOpt()
                end )
                if pTag <(curNum + 1) then
                    archDebrisItem:setVisible(true)
                else
                    archDebrisItem:setVisible(false)
                end
                buildBtn:setSwallowTouches(false)
                cell:addChild(archDebrisItem)
            end
        else
            for var = 1, 4 do
                local pTag = idx * 4 + var
                local archDebrisItem = cell:getChildByTag(var)
                if pTag <(curNum + 1) then
                    archDebrisItem:setVisible(true)
                    archDebrisItem:setData(self.mBookData[pTag], self:getItemLevel(self.mBookData[pTag].id))
                else
                    archDebrisItem:setVisible(false)
                end
                local pButton = archDebrisItem:getChildByTag(123)
                pButton:setName(pTag)
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return cellNum
    end
    self.tableView = cc.TableView:create(cc.size(563, 639))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
    self.tableView:setDelegate()
    me.assignWidget(self, "midlist_node"):addChild(self.tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()
    self.selectImg = ccui.ImageView:create()
    self.selectImg:setScale9Enabled(true)
    --self.selectImg:ignoreContentAdaptWithSize(false)
    self.selectImg:setCapInsets(cc.rect(10, 10, 10, 10))
    self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setPosition(cc.p(self:getCellPoint(self.pTag, self.iNum)))
    self.selectImg:setContentSize(cc.size(143, 143))
    -- self.selectImg:setPosition(cc.p(self:getCellPoint(1,self.iNum)))
    self.selectImg:setLocalZOrder(10)
    self.tableView:addChild(self.selectImg)
end
function archLayer:stopAniamtion()
    if self.ComposeNum > 0 then
        NetMan:send(_MSG.bookCompound(self.mPitchComId, self.ComposeNum))
        self.ComposeNum = 0
    end
    me.clearTimer(self.pAmintionTime)
    me.assignWidget(self, "arch_amintion"):setVisible(false)
    self.ComposeNum = 0
    self.pLoadingBar:setPercent(0)
end
-- 根据引导，定位左边listView的位置
function archLayer:getGuideViewIndex()
    local itemID = TaskHelper.getItemID()
    if itemID == nil then
        return nil
    end
    for key, var in pairs(user.bookHand) do
        local cfg = cfg[CfgType.BOOK][me.toNum(itemID)]
        if me.toNum(cfg.bookId) == me.toNum(var) then
            index = me.toNum(key) -1
            return index
        end
    end
end

-- 根据引导，定位tebleView的位置
function archLayer:setGuideView(getItem_)
    local itemID = nil
    if getItem_ ~= nil then
        itemID = getItem_
    else
        itemID = TaskHelper.getItemID()
    end
    if itemID == nil then
        return
    end
    print("itemID = " .. itemID)
    local tmpIndex = nil
    for key, var in pairs(self.mBookData) do
        if me.toNum(var.id) == itemID then
            tmpIndex = me.toNum(key)
            break
        end
    end
    dump(self.mBookData)
    print("tmpIndex = " .. tmpIndex)
    if tmpIndex == nil then
        print("没有找到对应考古的Index")
        return
    end

    if tmpIndex % 4 ~= 0 then
        cellNum = math.floor(tmpIndex / 4) + 1
    else
        cellNum = tmpIndex / 4
    end
    local tcell = self.tableView:cellAtIndex(cellNum - 1):getChildByTag(tmpIndex)
    if getItem_ ~= nil then
        return tcell
    end
    if tcell then
        local tmpOffSet = cc.p(self:getCellPoint(tmpIndex, cellNum))
        self.tableView:setContentOffset(cc.p(0, tmpOffSet.y))
        local guide = guideView:getInstance()
        --        guide:showGuideView(tcell,false,false)
        guide:showGuideViewForTableCell(tcell, false, false, self.selectImg:getContentSize())
        mainCity:addChild(guide, me.GUIDEZODER)
    else
        showTips("没有找到所需的考古物品")
    end
end
function archLayer:getCellForGuide()
    -- 任务引导的初级铲子
    local tcell = self:setGuideView(1071)
    if tcell then
        return tcell
    end
end
function archLayer:update(msg)
    if checkMsg(msg.t, MsgCode.BOOK_INIT) then

        local p = table.maxn(user.bookHand)
        if self.pOpenNum ~= table.maxn(user.bookHand) then
            self:initLeftList()
            setBookAltas()
            self:setArchHint()
            self:setBookData()
            self:setRight(self.pTag)
            -- 任务或者新人引导的跳转
            --                if TaskHelper.getItemID() then
            --                    me.DelayRun(self:setGuideView(),0.01)
            --                end
        else
            setBookAltas()
            self:setBookData()
            self:setRight(self.pTag)
        end
        if user.archRedPoints then
            me.assignWidget(self.Button_manual, "red_point"):setVisible(true)
        else
            me.assignWidget(self.Button_manual, "red_point"):setVisible(false)
        end
    elseif checkMsg(msg.t, MsgCode.BOOK_COMPOUND) then
        -- self:setDressEquip()
        if self.pBoolDress == false then
            setBookAltas()
            self:setArchHint()
            self:setBookData()
            self:setRight(self.pTag)
            self:upDataTableView()
        else
            --  self.pBoolDress = false
        end
        if user.archRedPoints then
            me.assignWidget(self.Button_manual, "red_point"):setVisible(true)
        else
            me.assignWidget(self.Button_manual, "red_point"):setVisible(false)
        end
    elseif checkMsg(msg.t, MsgCode.BOOK_MENU_ADD) then
        self:initLeftList()
    elseif checkMsg(msg.t, MsgCode.ROLE_BOOK_ITEM_CHANGE) then
        if self.pBoolDress == true then
            setBookAltas()
            self:setArchHint()
            self:setBookData()
            self:setRight(self.pTag)
            self:upDataTableView()
            self.pBoolDress = false
        end
    elseif checkMsg(msg.t, MsgCode.BOOK_COMPOUND_LEVEL) then
        setBookAltas()
        self:setArchHint()
        self:setBookData()
        self:setRight(self.pTag)
        self:upDataTableView()
        self.pBoolDress = false
        local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
        pCityCommon:CommonSpecific(ALL_COMMON_HERO_LEVELUP)
        pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2 + 50))
        me.runningScene():addChild(pCityCommon, me.ANIMATION)
    elseif checkMsg(msg.t, MsgCode.ROLE_MAP_LAND_INFO) then

        self.archPlot = { }
        for key, var in pairs(msg.c.list) do
            local pCfg = getMapConfigData(var)
            local pPlot = { }
            local parchid = { }
            pPlot.point = var
            local pArchItem = me.split(pCfg.kaoguItems, ",")
            for key, var in pairs(pArchItem) do
                local pidData = me.split(var, ":")
                local pId = pidData[1]
                table.insert(parchid, pId)
            end
            pPlot.arch = parchid
            local pX = math.abs(user.x - var.x)
            local pY = math.abs(user.y - var.y)
            pPlot.distance = math.floor(math.sqrt(pX * pX + pY * pY))
            --            local pbastion = true
            --            -- 剔除据点地块
            --            for key, var2 in pairs(gameMap.bastionData) do
            --                if var2.pos.x == var.x and var2.pos.y == var.y then
            --                    pbastion = false
            --                end
            --            end
            if var.type == 0 then
                table.insert(self.archPlot, pPlot)
            end
        end
        if table.maxn(self.archPlot) ~= 0 then
            local function archPlota(pa, pb)
                if pa["distance"] < pb["distance"] then
                    return true
                end
            end
            table.sort(self.archPlot, archPlota)
        end
    end
end
function archLayer:setArchHint()
    self.pParent:archHint()
end
function archLayer:upDataTableView()
    local pOffset = self.tableView:getContentOffset()
    self.tableView:reloadData()
    self.tableView:setContentOffset(pOffset)
end
function archLayer:findArchItemCell(pId)

    lv = tonumber(lv)
    local x = user.curMapCrood.x
    -- 中心位置
    local y = user.curMapCrood.y
    local findFlag = false
    local count = 0

    local function findResource(tx, ty)
        local tileCfgData = getMapConfigData(cc.p(tx, ty))
        local pArchItem = me.split(tileCfgData.kaoguItems, ",")
        for key, var in pairs(pArchItem) do
            local pidData = me.split(var, ":")
            if tonumber(pId) == tonumber(pidData[1]) then
                return true
            end
        end
        return false
    end
    if findResource(x, y) == true then
        return x, y
    end
    local initGrid = 2
    local prevLineGridNums = 1
    for t = 1, 50, 1 do
        local lineGridNums = t * 2 + 1
        local p = lineGridNums * lineGridNums - prevLineGridNums * prevLineGridNums
        local initX = 0
        local initY = 0
        local srcX = x -(lineGridNums - initGrid)
        local srcY = y -(lineGridNums - initGrid)
        local step = lineGridNums - 1
        for i = 1, p, 1 do
            local tmpX = srcX + initX
            local tmpY = srcY + initY
            if initX < step and initY == 0 then
                initX = initX + 1
            elseif initX == step and initY < step then
                initY = initY + 1
            elseif initX > 0 and initX <= step and initY == step then
                initX = initX - 1
            elseif initX == 0 and initY <= step then
                initY = initY - 1
            end

            if tmpX > 0 and tmpY > 0 and tmpY < 1202 and tmpX < 1202 then
                if findResource(tmpX, tmpY) == true then
                    return tmpX, tmpY
                end
            end
        end
        if findFlag == true then
            break
        end
        initGrid = initGrid + 1
        prevLineGridNums = prevLineGridNums + 2
    end
    return -1, -1
end
function archLayer:onEnter()
    print("archLayer onEnter")
    --      TaskHelper.setItemID(1031) --任务的跳转

    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )

    if guideHelper.isTaskGuideOver() == false then
        guideHelper.nextStepByOpt()
    end

end
function archLayer:setDressEquip()
    self.pBoolDress = self:getDressEquip()
    if self.pBoolDress == true then
        for key, var in pairs(user.bookPkg) do
            if self.mPitchComId == var["defid"] then
                NetMan:send(_MSG.bookEquip(var["uid"]))
                break
            end
        end
    end
end
function archLayer:getDressEquip()
    -- dump(self.mPitchData)
    local pSynEquip = cfg[CfgType.ETC][self.mPitchComId]
    if --[[ me.toNum(pSynEquip["useType"]) == 10 or -- ]]me.toNum(pSynEquip["useType"]) == 119 or me.toNum(pSynEquip["useType"]) == 102 then
        return false
    end
    for key, var in pairs(user.bookEquip) do
        local pCfigData = cfg[CfgType.ETC][var["defid"]]
        if me.toNum(pSynEquip["useType"]) == me.toNum(pCfigData["useType"]) then
            if pSynEquip["quality"] > pCfigData["quality"] then
                return true
            else
                return false
            end
        end
    end
    return true
end
function archLayer:Compound()
    local pCompound = me.assignWidget(self, "arch_compound_sp"):clone()
    pCompound:setVisible(true)
    me.assignWidget(self, "bg"):addChild(pCompound)
    local pCityC = allAnimation:createAnimation("item_ani")
    pCityC:archCompound()
    pCompound:addChild(pCityC, me.MAXZORDER)

    local pIcon = ccui.ImageView:create()
    pIcon:loadTexture(self.pPitchNameIcon, me.plistType)
    pIcon:setLocalZOrder(10)
    pCityC:addChild(pIcon)
    local pDressBool = self:getDressEquip()

    local function ComRemove(node)
        node:removeFromParentAndCleanup(true)
    end
    if pDressBool ~= true then
        local pCallF = cc.CallFunc:create(ComRemove)
        local pDelay = cc.DelayTime:create(1.7)
        local pSquen = cc.Sequence:create(pDelay, pCallF)
        pCompound:runAction(pSquen)
    else
        local pCallF = cc.CallFunc:create(ComRemove)
        local pMove = nil
        local pEtc = cfg[CfgType.ETC][self.mPitchData["id"]]
        if me.toNum(pEtc["useType"]) == 118 then
            pMove = cc.MoveTo:create(0.5, cc.p(150, 500))
        else
            pMove = cc.MoveTo:create(0.5, cc.p(150, 80))
        end
        local pDelay = cc.DelayTime:create(1.7)
        local pSquen = cc.Sequence:create(pDelay, pMove, pCallF)
        pCompound:runAction(pSquen)
    end


end
function archLayer:onEnterTransitionDidFinish()
    disWaitLayer(true)
    print("archLayer onEnterTransitionDidFinish")
end
function archLayer:onExit()
    print("archLayer onExit")
    if self.ComposeNum > 0 then
        NetMan:send(_MSG.bookCompound(self.mPitchComId, self.ComposeNum))
    end
    UserModel:removeLisener(self.modelkey)
    -- 删除消息通知
    me.clearTimer(self.pAmintionTime)
    --   me.tableClear(user.bookHand)
end
function archLayer:close()
    self:removeFromParentAndCleanup(true)
end
