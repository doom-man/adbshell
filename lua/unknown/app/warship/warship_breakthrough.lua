
warship_breakthrough = class("warship_breakthrough",function (csb)
    return cc.CSLoader:createNode(csb)
end)
warship_breakthrough.__index = warship_breakthrough
function warship_breakthrough:create(csb)
    local layer = warship_breakthrough.new(csb)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then 
                    layer:enterTransitionFinish()
                end
                print(tag)
            end)            
            return layer
        end
    end
    return nil 
end
function warship_breakthrough:ctor()   
    print("warship_breakthrough ctor") 

end

function warship_breakthrough:init()   
    print("warship_breakthrough init")  
    me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    

    self.nlist_2 = me.assignWidget(self, "nlist_2")
    self.nowLv = me.assignWidget(self, "nowLv")
    self.nextLv = me.assignWidget(self, "nextLv")
    self.shipIcon = me.assignWidget(self, "shipIcon")
    self.shipLv = me.assignWidget(self, "shipLv")
    self.shipComplete = me.assignWidget(self, "shipComplete")
    self.breakthroughBtn  = me.assignWidget(self, "breakthroughBtn")

    -- 舰队
    me.registGuiClickEvent(self.breakthroughBtn, function(sender)
        showWaitLayer()
        NetMan:send(_MSG.Ship_overfull(self.shipType)) 
    end)

    return true
end

function warship_breakthrough:initUIData(shipType)
    
    self.shipType = shipType
    local shipData = user.warshipData[shipType]
    local shipCfg = cfg[CfgType.SHIP_DATA][shipData.defId]
    local breakthroughCfg = nil
    while true do
        shipCfg = cfg[CfgType.SHIP_DATA][shipCfg.nextid]
        if shipCfg then
            if shipCfg.needItem and shipCfg.needItem~="" and shipData.overfull<shipCfg.lv-1 then
                breakthroughCfg=shipCfg
                break
            end
        else
            break
        end
    end

    self.nlist_2:removeAllChildren()
    if breakthroughCfg==nil then
        self.nowLv:setString("-")
        self.nextLv:setString("-")
        self.breakthroughBtn:setBright(false)
        self.breakthroughBtn:setTouchEnabled(false)
        return
    end

    self.nowLv:setString(breakthroughCfg.lv-1)
    self.nextLv:setString(breakthroughCfg.lv+4)

    local tupoFlag=true
    local str = "战舰  等级"..(breakthroughCfg.lv-1).." (满经验)"
    self.shipLv:setString(str)

    if shipData.baseShipCfg.lv<breakthroughCfg.lv-1 or shipData.nowExp < shipData.maxExp then
        self.shipLv:setColor(COLOR_RED)
        self.shipComplete:loadTexture("shengji_tubiao_buzu.png", me.localType)

        tupoFlag=false
    else
        self.shipLv:setColor(COLOR_GREEN)
        self.shipComplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
    end


    self.shipIcon:loadTexture (getWarshipImageTexture(shipType))
    me.resizeImage(self.shipIcon, 45, 45)



    -- 碎片
    local strItemTb = string.split (breakthroughCfg.needItem, ":")

    local itemNums=0
    local function addResItems(typeKey)
        if typeKey=='ship' or me.toNum(breakthroughCfg[typeKey]) > 0 then
            itemNums=itemNums+1
            local ndata = breakthroughCfg
            local tItem = me.createNode("bLevelUpNeedItem_s.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local infoBg = me.assignWidget(bItem, "infoBg")
--            if itemNums%2==0 then
--                infoBg:setVisible(false)
--            end
            local resName = nil
            if typeKey == "food" then
                resName = ICON_RES_FOOD
            elseif typeKey == "wood" then
                resName = ICON_RES_LUMBER
            elseif typeKey == "stone" then
                resName = ICON_RES_STONE
            elseif typeKey == "gold" then
                resName = ICON_RES_GOLD
            elseif typeKey == "ship" then
                resName = getItemIcon(tonumber (strItemTb[1]))
                local debrisCount = 0
                for k, v in pairs (user.pkg) do
                    if v.defid == tonumber(strItemTb[1]) then
                        debrisCount = debrisCount + v.count
                    end
                end
                ticon:loadTexture(resName, me.localType)
                tdesc:setString(debrisCount)
                local needNumsTxt = tdesc:clone()
                needNumsTxt:setPositionY(tdesc:getPositionY())
                needNumsTxt:setString("/"..strItemTb[2])
                bItem:addChild(needNumsTxt)
                needNumsTxt:setPositionX(tdesc:getPositionX()+tdesc:getContentSize().width)

                if tonumber(strItemTb[2]) > debrisCount then
                    tupoFlag=false
                    tdesc:setColor(COLOR_RED)
                    tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                    toptBtn:setVisible(true)
                    toptBtn:setTitleText(TID_BUTTON_GETMORE)
                    me.registGuiClickEvent(toptBtn,function (node,event)
                        if event ~= ccui.TouchEventType.ended then
                            local getWayView = runeGetWayView:create("rune/runeGetWayView.csb")
                            me.runningScene():addChild(getWayView, me.MAXZORDER)
                            me.showLayer(getWayView,"bg")
                            getWayView:setData(strItemTb[1])
                        end
                    end)
                else
                    tdesc:setColor(COLOR_GREEN)
                    tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                    toptBtn:setVisible(false)
                end

                self.nlist_2:pushBackCustomItem(bItem)
                return
            end
            ticon:loadTexture(resName, me.localType)
            if breakthroughCfg[typeKey] > user[typeKey] then
                tupoFlag=false
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_GETMORE)
                self.bMeet = false
                me.registGuiClickEvent(toptBtn,function (node,event)
                    if event ~= ccui.TouchEventType.ended then
                        local tmpView = recourceView:create("rescourceView.csb")
                        tmpView:setRescourceType(typeKey)
						tmpView:setRescourceNeedNums(breakthroughCfg[typeKey])
                        me.runningScene():addChild(tmpView, me.MAXZORDER)
                        me.showLayer(tmpView, "bg")
                    end
                end)
            else
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
                tdesc:setColor(COLOR_GREEN)
            end
            tdesc:setString(breakthroughCfg[typeKey])
            self.nlist_2:pushBackCustomItem(bItem)
        end
    end
    addResItems("ship")
    addResItems("food")
    addResItems("wood")
    addResItems("stone")
    addResItems("gold")

    if tupoFlag==true then
        self.breakthroughBtn:setBright(true)
        self.breakthroughBtn:setTouchEnabled(true)
    else
        self.breakthroughBtn:setBright(false)
        self.breakthroughBtn:setTouchEnabled(false)
    end
end

function warship_breakthrough:close()
    self:removeFromParentAndCleanup(true)  
end
function warship_breakthrough:onEnter()
    print("warship_breakthrough onEnter")   

    self.listener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or 
            checkMsg(msg.t, MsgCode.SHOP_BUY) then
            self:initUIData(self.shipType)
        elseif checkMsg(msg.t, MsgCode.MSG_SHIP_OVERFULL) then
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_TUPO)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height/ 2+50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
            self:close()
        end
    end)   
end

function warship_breakthrough:enterTransitionFinish()
end
function warship_breakthrough:onExit()
  UserModel:removeLisener(self.listener)
end
function warship_breakthrough:resetForWorldMap()

end