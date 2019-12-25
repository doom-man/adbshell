buildTradeLayer = class("buildTradeLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
buildTradeLayer.__index = buildTradeLayer
buildTradeLayer.CreateType = 1
buildTradeLayer.LevelUpType = 2
function buildTradeLayer:create(...)
    local layer = buildTradeLayer.new(...)
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
function buildTradeLayer:ctor()
    print("buildTradeLayer ctor")
    -- 建设的目标点
    self.m_TagPoint = nil
end
function buildTradeLayer:init()
    print("buildTradeLayer init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.icon = me.assignWidget(self, "icon")   
    self.nlist_2 = me.assignWidget(self, "nlist_2")
    self.Node_lvup = me.assignWidget(self,"Node_lvup")
    self.Node_lvup:setVisible(false)
    self.Node_create = me.assignWidget(self,"Node_create")
    self.Node_create:setVisible(false)
    self.optBtn_create =  me.registGuiClickEventByName(self.Node_create, "optBtn_create", function(node)             
        local bastionAsk = bastionDialog:create("bastionNameInputDialog.csb")
        bastionAsk:initWithPoint(self:getTagPoint())
        self:addChild(bastionAsk, me.MAXZORDER)
        me.showLayer(bastionAsk,"bg")        
    end )
    self.optBtn_lvup = me.registGuiClickEventByName(self.Node_lvup, "optBtn_lvup", function(node)             
        print("升级")
        GMan():send(_MSG.levelUpBastion(self:getTagPoint()))
    end )
    self.optBtn_lvup_imm = me.registGuiClickEventByName(self.Node_lvup, "optBtn_lvup_imm", function(node)             
        print("立即升级")
        local function diamondUse()
            GMan():send(_MSG.levelUpBastion(self:getTagPoint(),1))
        end

        local needDiamond = tonumber(me.assignWidget(self.Node_lvup,"diamondNum"):getString())
        if user.diamond<needDiamond then
            diamondNotenough(needDiamond, diamondUse)  
        else
            diamondUse()
        end
    end )
    self.Node_desri_create = me.assignWidget(self,"Node_desri_create")
    self.Node_desri_create:setVisible(false)
    self.Node_desri_lvup = me.assignWidget(self,"Node_desri_lvup")
    self.Node_desri_lvup:setVisible(false)
    self.Text_title_descri = me.assignWidget(self,"Text_title_descri")
    self.Node_descri_hp = me.assignWidget(self,"Node_descri_hp")
    self.Node_descri_power = me.assignWidget(self,"Node_descri_power")
    self.Node_descri_speed = me.assignWidget(self,"Node_descri_speed")
    return true
end

-- 升级据点
function buildTradeLayer:initWithLevelUpData(status,baseData)
    self.nlist_2:removeAllChildren()       
    if baseData then
        self.baseData = baseData
    end
    if self.baseData.lv>=1 then
        me.assignWidget(self, "name"):setString("升级据点")
    else
        me.assignWidget(self, "name"):setString("建造据点")
    end
    self:initWithData(status,self.baseData.lv+1)
    self:setTagPoint(self.baseData.pos)
    local curDef = cfg[CfgType.BASTION_DATA][self.baseData.lv]
    local nextDef = cfg[CfgType.BASTION_DATA][self.baseData.lv+1]
    if user.Cross_Sever_Status == mCross_Sever then        
        curDef = cfg[CfgType.CROSS_STRONG_HOLD][self.baseData.lv]
        nextDef = cfg[CfgType.CROSS_STRONG_HOLD][self.baseData.lv+1]
    end
    me.assignWidget(self.Node_descri_hp,"Text_pre"):setString("+"..curDef.defense)
    me.assignWidget(self.Node_descri_hp,"Text_after"):setString("+"..nextDef.defense)
    me.assignWidget(self.Node_descri_power,"Text_pre"):setString("+"..curDef.num)
    me.assignWidget(self.Node_descri_power,"Text_after"):setString("+"..nextDef.num)
    me.assignWidget(self.Node_descri_speed,"Text_pre"):setString("+"..curDef.speed.."%")
    me.assignWidget(self.Node_descri_speed,"Text_after"):setString("+"..nextDef.speed.."%")
end

function buildTradeLayer:updateData()
    self:initWithData(self.status,self.lv)
end

-- 建造据点
function buildTradeLayer:initWithData(status,lv) 
    self.status = status
    self.lv =lv 
    self.nlist_2:removeAllChildren()       
    local def = cfg[CfgType.BASTION_DATA][lv]
    if user.Cross_Sever_Status == mCross_Sever then        
        def = cfg[CfgType.CROSS_STRONG_HOLD][lv]       
    end
    self.canDo = true
    local itemNums=0
    local function addResItems(typeKey)
        if me.toNum(def[typeKey]) > 0 then
            itemNums=itemNums+1
            local ndata = def
            local tItem = me.createNode("bLevelUpNeedItem.csb")
            local bItem = me.assignWidget(tItem, "bg"):clone()
            bItem:setContentSize(cc.size(658, 40))
            local ticon = me.assignWidget(bItem, "icon")
            local tdesc = me.assignWidget(bItem, "desc")
            local tcomplete = me.assignWidget(bItem, "complete")
            local toptBtn = me.assignWidget(bItem, "optBtn")
            local infoBg = me.assignWidget(bItem, "infoBg")
            infoBg:setContentSize(cc.size(670, 40))
            if itemNums%2==0 then
                infoBg:setVisible(false)
            end
            local resName = nil
            if typeKey == "food" then
                resName = ICON_RES_FOOD
            elseif typeKey == "wood" then
                resName = ICON_RES_LUMBER
            elseif typeKey == "stone" then
                resName = ICON_RES_STONE
            elseif typeKey == "gold" then
                resName = ICON_RES_GOLD
            end
            ticon:loadTexture(resName, me.localType)
            if def[typeKey] > user[typeKey] then
                tdesc:setColor(COLOR_RED)
                tcomplete:loadTexture("shengji_tubiao_buzu.png", me.localType)
                toptBtn:setVisible(true)
                toptBtn:setTitleText(TID_BUTTON_GETMORE)
                self.canDo = false
                me.registGuiClickEvent(toptBtn,function (node,event)
                    if event ~= ccui.TouchEventType.ended then
                        local tmpView = recourceView:create("rescourceView.csb")
                        tmpView:setRescourceType(typeKey)
                        tmpView:setRescourceNeedNums(def[typeKey])
                        pWorldMap:addChild(tmpView, self:getLocalZOrder())
                        me.showLayer(tmpView, "bg")
                    end
                end)
            else
                tcomplete:loadTexture("shengji_tubiao_manzhu.png", me.localType)
                toptBtn:setVisible(false)
                tdesc:setColor(COLOR_GREEN)
            end
            tdesc:setString(def[typeKey])
            self.nlist_2:pushBackCustomItem(bItem)
        end
    end
    addResItems("food")
    addResItems("wood")
    addResItems("stone")
    addResItems("gold")  
    if status == buildTradeLayer.CreateType then --创建
        self.Text_title_descri:setString("注意")
        me.assignWidget(self.Node_create,"ntime"):setString(me.formartSecTime(def.time / (1 +  user.propertyValue["BuildTime"]) ))
        self.optBtn_create:setVisible(true)
        me.setButtonDisable(self.optBtn_create, self.canDo)    
    elseif status == buildTradeLayer.LevelUpType then --升级
        me.assignWidget(self,"sdaa"):setVisible(false)
        self.Text_title_descri:setString("升级预览")
        me.assignWidget(self.Node_lvup,"ntime"):setString(me.formartSecTime(def.time / (1 + user.propertyValue["BuildTime"])))
        me.setButtonDisable(self.optBtn_lvup, self.canDo)    
        local price = { }
        price.food = def.food
        price.wood = def.wood
        price.stone = def.stone
        price.gold = def.gold
        price.time = def.time
        price.index = 1
        local allCost = getGemCost(price)   
        me.assignWidget(self.Node_lvup,"diamondNum"):setString(math.ceil(allCost))
    end
    self.Node_desri_create:setVisible(status == buildTradeLayer.CreateType)
    self.Node_desri_lvup:setVisible(status == buildTradeLayer.LevelUpType)
    self.Node_create:setVisible(status == buildTradeLayer.CreateType)
    self.Node_lvup:setVisible(status == buildTradeLayer.LevelUpType)
end
function buildTradeLayer:getTagPoint()
    return self.m_TagPoint
end
function buildTradeLayer:setTagPoint(m_TagPoint_)
    self.m_TagPoint = m_TagPoint_
end
function buildTradeLayer:onEnter()
    print("buildTradeLayer onEnter")
    me.doLayout(self, me.winSize)
    self.listener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.WORLD_STRONG_HOLD_UPDATE) then
            self:close()        

        end
        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) or 
            checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or
            checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) or 
            checkMsg(msg.t, MsgCode.CITY_UPDATE) then
            self:updateData()
        end
    end)
end
function buildTradeLayer:onEnterTransitionDidFinish()
    print("buildTradeLayer onEnterTransitionDidFinish")
end
function buildTradeLayer:onExit()
    print("buildTradeLayer onExit")
end
function buildTradeLayer:close()
    UserModel:removeLisener(self.listener)
    me.DelayRun( function()
        self:removeFromParentAndCleanup(true)
    end )
    pWorldMap.buildTrade = nil
end
-- rev msg:{"t":1562,"c":{"ox":17,"oy":239,"x":18,"y":298,"list":[{"x":21,"y":248},{"x":49,"y":299},{"x":18,"y":298}]}}
-- rev msg:{"t":1557,"c":{"id":1452218669455,"uid":10031,"name":"CDE_63877","ox":17,"oy":239,"x":18,"y":298,"time":35520,"countdown":35520,"speed":8,"status":42,
-- "list":[{"x":21,"y":248},{"x":49,"y":299},{"x":18,"y":298}]}}