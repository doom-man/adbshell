-- [Comment]
-- jnmo
fortSoldier = class("fortSoldier", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortSoldier.__index = fortSoldier
function fortSoldier:create(...)
    local layer = fortSoldier.new(...)
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
function fortSoldier:ctor()
    print("fortSoldier ctor")
    self.pPitchOn = 1
    self.pTime = nil
end
function fortSoldier:init()
    print("fortSoldier init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    return true
end
function fortSoldier:setData(pHero, pParent)
    self.mHero = pHero
    self.pParent = pParent
    me.clearTimer(self.pTime)
    local pData = user.fortRecuritSoldierData
    local text_num_limit = me.assignWidget(self, "text_num_limit")
    text_num_limit:setString("奇迹兵：" .. pData.curWonder .. "/" .. pData.wonderMax)
    local pRecuritConfig = cfg[CfgType.MIRACLE_RECTUIT_DEF][pData["soldierid"]]
    local soldier_name_list = me.assignWidget(self, "soldier_name_list")
    soldier_name_list:setString(pRecuritConfig["daytxt"])
    local button_diamond = me.assignWidget(self, "button_diamond")
    button_diamond:setString(pRecuritConfig["refreshcost"])      
    me.assignWidget(self, "yourecurit"):setString("你可招募最大奇迹等级："..pData.max)
    local surplus_recurit_num = me.assignWidget(self, "surplus_recurit_num")
    surplus_recurit_num:setString("剩余招募次数：" .. pData["recuritNum"])
    me.registGuiClickEventByName(self, "Button_renvo", function(node)
        if pData["recuritNum"] > 0 then
            local pHeroConfig = cfg[CfgType.HERO][self.mHero["heroid"]]
            self.pPitchOn = 1
            NetMan:send(_MSG.worldSoldierUpdata(pHeroConfig["herotype"]))
        else
            me.showMessageDialog("今日招募次数已用完，刷新不会增加次数，是否刷新", function(args)
                if args == "ok" then
                    local pHeroConfig = cfg[CfgType.HERO][self.mHero["heroid"]]
                    self.pPitchOn = 1
                    NetMan:send(_MSG.worldSoldierUpdata(pHeroConfig["herotype"]))
                end
            end )
        end
    end )
    local recurit_time = me.assignWidget(self, "recurit_time")

    self.mCountTime = pData["CountTime"] / 1000
    if self.mCountTime > 0 then
        recurit_time:setString(me.formartSecTime(self.mCountTime))
        self.pTime = me.registTimer(-1, function(dt)
            if self.mCountTime > 0 then
                self.mCountTime = self.mCountTime - 1
                recurit_time:setString(me.formartSecTime(self.mCountTime))
            else
                me.clearTimer(self.pTime)
            end
        end , 1)
    end

    me.assignWidget(self, "Node_Table"):removeAllChildren()
    self.mRecuritSoldier = user.fortRecuritSoldierList
    self:initSoldierTab()
    self:setSoldierInfo(self.mRecuritSoldier[self.pPitchOn])
end
function fortSoldier:initSoldierTab()

    local pNum = #self.mRecuritSoldier
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
        local pId = cell:getIdx() + 1
        self.pPitchOn = pId
        self:setSoldierInfo(self.mRecuritSoldier[pId])
        self.selectImg:setPosition(cell:getPositionX() + 115, cell:getPositionY() + 165)
    end
    local function cellSizeForTable(table, idx)
        return 240, 330
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pSoldierCell = me.assignWidget(self, "soldier_cell"):clone():setVisible(true)
            pSoldierCell:setAnchorPoint(cc.p(0.5, 0.5))
            pSoldierCell:setPosition(cc.p(120, 165))
            self:setSoldierCell(pSoldierCell, self.mRecuritSoldier[idx + 1])
            cell:addChild(pSoldierCell)
        else
            local pSoldierCell = me.assignWidget(cell, "soldier_cell")
            self:setSoldierCell(pSoldierCell, self.mRecuritSoldier[idx + 1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return pNum
    end
    tableView = cc.TableView:create(cc.size(1180, 330))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:ignoreAnchorPointForPosition(false)
    tableView:setAnchorPoint(cc.p(0.5, 0.5))
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Node_Table"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    self.ForttableView = tableView
    self.selectImg = ccui.ImageView:create("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setContentSize(cc.size(240, 300))
    self.selectImg:setScale9Enabled(true)
    self.selectImg:setCapInsets(cc.rect(20, 20, 1, 1))
    self.selectImg:setLocalZOrder(10)
    self.ForttableView:addChild(self.selectImg, 2)
    local tcell = self.ForttableView:cellAtIndex(self.pPitchOn - 1)
    self.selectImg:setPosition(tcell:getPositionX() + 115, tcell:getPositionY() + 165)
end
function fortSoldier:setSoldierCell(pNode, pData)
    if pData then
        local pSoldierConfig = pData:getDef()

        local soldier_icon = me.assignWidget(pNode, "soldier_icon")
        soldier_icon:loadTexture(soldierIcon(pSoldierConfig), me.plistType)

        local have_num = me.assignWidget(pNode, "have_num")
        have_num:setString(pData["num"])

        local solider_name = me.assignWidget(pNode, "solider_name")
        solider_name:setString(pSoldierConfig["name"])

        local already_recruit = me.assignWidget(pNode, "already_recruit")
        if pData["halfrecurit"] == 0 then
            already_recruit:setVisible(false)
        else
            already_recruit:setVisible(true)
        end

        local diamond = me.assignWidget(pNode, "diamond")
        if pData["recuritType"] == 1 then
            diamond:setVisible(false)
        else
            local pDiamondNum = pData["needmak"]
            diamond:setVisible(true)
            if me.toNum(pDiamondNum[1][1]) == 9017 then
                diamond:loadTexture("shenjiang_qiji_zhaomu_tubiao.png", me.localType)
            elseif me.toNum(pDiamondNum[1][1]) == 9008 then
                diamond:loadTexture("yaosai_14.png", me.localType)
            end
        end
        me.registGuiClickEventByName(pNode, "Button_explain", function(node)
            local info = soldierInfoLayer:create("soldlierInfoLayer.csb")
            info:initWithData(pSoldierConfig, pData, true)
            pWorldMap:addChild(info, me.MAXZORDER)
            me.showLayer(info, "bg")
        end )
    end
end
function fortSoldier:setSoldierInfo(pData)
    if pData then
        dump(pData)
        local Node_material = me.assignWidget(self, "Node_material")
        local Image_diamond = me.assignWidget(self, "Image_diamond")
        if pData["recuritType"] == 1 then
            Node_material:setVisible(true)
            Image_diamond:setVisible(false)
            self.pMaterBool = true
            for key, var in pairs(pData["needmak"]) do
                if var[1] == 9001 then
                    local food_num = me.assignWidget(self, "food_num")
                    food_num:setString(var[2])
                    if user.food < var[2] then
                        food_num:setTextColor(COLOR_RED)
                        self.pMaterBool = false
                    else
                        food_num:setTextColor(COLOR_WHITE)
                    end
                elseif var[1] == 9002 then
                    local wood_num = me.assignWidget(self, "wood_num")
                    wood_num:setString(var[2])
                    if user.wood < var[2] then
                        wood_num:setTextColor(COLOR_RED)
                        self.pMaterBool = false
                    else
                        wood_num:setTextColor(COLOR_WHITE)
                    end
                elseif var[1] == 9003 then
                    local stone_num = me.assignWidget(self, "stone_num")
                    stone_num:setString(var[2])
                    if user.stone < var[2] then
                        stone_num:setTextColor(COLOR_RED)
                        self.pMaterBool = false
                    else
                        stone_num:setTextColor(COLOR_WHITE)
                    end
                elseif var[1] == 9004 then
                    local gold_num = me.assignWidget(self, "gold_num")
                    gold_num:setString(var[2])
                    if user.gold < var[2] then
                        gold_num:setTextColor(COLOR_RED)
                        self.pMaterBool = false
                    else
                        gold_num:setTextColor(COLOR_WHITE)
                    end
                end

            end
        else
            Node_material:setVisible(false)
            Image_diamond:setVisible(true)
            me.resizeImage(Image_diamond,30,30)
            local pDiamond = me.assignWidget(self, "diamond_num")
            local pDiamondNum = pData["needmak"]
            if me.toNum(pDiamondNum[1][1]) == 9017 then
                pDiamond:setString("x " .. pDiamondNum[1][2])
                Image_diamond:loadTexture("yuanbao.png", me.localType)
            elseif me.toNum(pDiamondNum[1][1]) == 9008 then
                pDiamond:setString("x " .. pDiamondNum[1][2])
                Image_diamond:loadTexture("gongyong_tubiao_zuanshi.png", me.localType)
            end
        end
        local recruit_soldier_num = me.assignWidget(self, "recruit_soldier_num")
        recruit_soldier_num:setString("招募数量:" .. pData["num"])
        local pbtn_Str = "招募"
        if pData["halfrecurit"] == 0 then
            pbtn_Str = "招募"
        else
            pbtn_Str = "已招募"
        end
        local btn_imme = me.assignWidget(self, "btn_imme")
        me.assignWidget(btn_imme, "text_title_btn"):setString(pbtn_Str)
        if pData["halfrecurit"] == 0 then
            -- btn_imme:setBright(true)
            -- btn_imme:setTitleColor(me.convert3Color_("#ffffff"))
            -- btn_imme:setSwallowTouches(true)
            -- btn_imme:setTouchEnabled(true)
            btn_imme:setEnabled(true)
        else
            -- btn_imme:setBright(false)
            -- btn_imme:setTitleColor(me.convert3Color_("#8b8b8b"))
            -- btn_imme:setSwallowTouches(true)
            -- btn_imme:setTouchEnabled(false)
            btn_imme:setEnabled(false)
        end
        me.registGuiClickEventByName(self, "btn_imme", function(node)

            if pData["halfrecurit"] == 0 then
                if pData["recuritType"] == 1 then
                    if self.pMaterBool then
                        local pHeroConfig = cfg[CfgType.HERO][self.mHero["heroid"]]
                        NetMan:send(_MSG.worldSoldierBuy(pHeroConfig["herotype"], pData["index"]))
                    else
                        showTips("材料不足")
                    end
                else
                    local pDiamondNum = pData["needmak"] 
                    if me.toNum(pDiamondNum[1][1]) == 9017 then
                        if user.paygem >= pData["needmak"][1][2] then
                            local tempStr = string.format("确定消耗%s元宝招募%sx%s吗?", pData["needmak"][1][2], pData:getDef().name, pData.num)
                            me.showMessageDialog(tempStr, function(name)
                                if name == "ok" then
                                    local pHeroConfig = cfg[CfgType.HERO][self.mHero["heroid"]]
                                    NetMan:send(_MSG.worldSoldierBuy(pHeroConfig["herotype"], pData["index"]))
                                end
                            end)
                        else
                            showTips("元宝不足")
                        end
                    elseif me.toNum(pDiamondNum[1][1]) == 9008 then
                        if user.diamond >= pData["needmak"][1][2] then
                            local tempStr = string.format("确定消耗%s钻石招募%sx%s吗?", pData["needmak"][1][2], pData:getDef().name, pData.num)
                            me.showMessageDialog(tempStr, function(name)
                                if name == "ok" then
                                    local pHeroConfig = cfg[CfgType.HERO][self.mHero["heroid"]]
                                    NetMan:send(_MSG.worldSoldierBuy(pHeroConfig["herotype"], pData["index"]))
                                end
                            end)
                        else
                            showTips("钻石不足")
                        end
                    end
                end
            else
                showTips("已招募")
            end
        end )
    end
end
 
function fortSoldier:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_FORT_RECURIT_SOLDIER) then
        self:setData(self.mHero, self.pParent)
    elseif checkMsg(msg.t, MsgCode.WORLD_FORT_SOLDIER_BUY) then
        self:setData(self.mHero, self.pParent)
    end
end

function fortSoldier:onEnter()
    print("fortSoldier onEnter")
    me.doLayout(self, me.winSize)
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
end
function fortSoldier:onEnterTransitionDidFinish()
    print("fortSoldier onEnterTransitionDidFinish")
end
function fortSoldier:onExit()
    print("fortSoldier onExit")
    UserModel:removeLisener(self.modelkey)
    me.clearTimer(self.pTime)
end
function fortSoldier:close()
    self.pParent:setParent()
    self:removeFromParentAndCleanup(true)
end

