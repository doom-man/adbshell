strongHoldDetailView = class("strongHoldDetailView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        print("----")
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
strongHoldDetailView.__index = strongHoldDetailView
function strongHoldDetailView.create(...)
    print("-2---")
    local layer = strongHoldDetailView.new(...)
    print("---1-")
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

function strongHoldDetailView:ctor()
    print("strongHoldDetailView:ctor()")
end

function strongHoldDetailView:init()
    print("strongHoldDetailView:init()")
    self.Node_Cancel = me.assignWidget(self,"Node_Cancel")
    self.Node_Cancel:setVisible(false)
    self.Text_cancel = me.assignWidget(self,"Text_cancel")
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        local tmpTxt = nil
        local sendFunc = nil
        if self.mapCellData:bHaveDroping() == true then
            tmpTxt = "拆除?\n(取消后将会返回一部分资源)"
            sendFunc = function ()
                GMan():send(_MSG.cancelDropPoint(self.baseData.pos.x, self.baseData.pos.y))
            end
        elseif self.baseData.state == 3 then
            tmpTxt = "升级?\n(取消后将会返回一部分资源)"
            sendFunc = function ()
                GMan():send(_MSG.cancelUpSpeedUp(self.baseData.pos))
            end
        end
        if tmpTxt and sendFunc then
            me.showMessageDialog("主人，你是否要取消该据点的"..tmpTxt, function(args)
                if args == "ok" then
                    sendFunc()
                    self:close()
                end
            end )
        end
    end)
    self.currentLevel = me.assignWidget(self, "currentLevel")
    self.title_hp_num = me.assignWidget(self, "title_hp_num")
    self.title_strength_num = me.assignWidget(self,"title_strength_num")
    self.title_speed_num = me.assignWidget(self,"title_speed_num")
    self.strong_num = me.assignWidget(self,"Strong_num")
    self.Stronghold_Name = me.assignWidget(self,"Stronghold_Name")
    self.leftTime = nil
    self.Button_remove = me.registGuiClickEventByName(self, "Button_remove", function(node)
        me.removeStrongHoldDialog("主人，你是否要拆除据点:"..self.baseData.name.."?", function(args)
            if args == "ok" then
                GMan():send(_MSG.dropPoint(self.baseData.pos.x, self.baseData.pos.y))
                self:close()
            end
        end )
    end )
    self.Button_imm = me.registGuiClickEventByName(self, "Button_imm", function(node)
        if pWorldMap.buildTrade == nil then
            local function diamondUse()
                GMan():send(_MSG.levelUpSpeedUp(self.baseData.pos))
                self:close()
            end
            local needDiamond = tonumber(me.assignWidget(self.Button_imm,"Text_imm_diamond"):getString())
            if user.diamond<needDiamond then
                diamondNotenough(needDiamond, diamondUse)  
            else
                diamondUse()
            end
        end
    end )
    self.Button_imm:setVisible(false)
    self.Button_update = me.registGuiClickEventByName(self, "Button_update", function(node)
        pWorldMap.buildTrade = buildTradeLayer:create("buildTradeLayer.csb")
        pWorldMap.buildTrade:initWithLevelUpData(buildTradeLayer.LevelUpType,self.baseData)
        pWorldMap:addChild(pWorldMap.buildTrade, me.MAXZORDER)
        me.showLayer(pWorldMap.buildTrade, "bg")
      --  self:close()
    end )
    self.Button_update:setVisible(false)
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_ChangeName", function(node)
           NetMan:send(_MSG.bastion_getPrice(self.baseData.pos.x,self.baseData.pos.y))
           local chanagename = bastionChangeName:create("StrongholdChangeName.csb")
           me.popLayer(chanagename)
    end )
    self.Panel_army = me.assignWidget(self,"Panel_army")
    return true
end

function strongHoldDetailView:onEnter()
    print("strongHoldDetailView:onEnter()")
    me.doLayout(self,me.winSize)  
    self.listener = UserModel:registerLisener(function (msg)
        if checkMsg(msg.t, MsgCode.WORLD_STRONG_HOLD_UPDATE) then
            if me.toNum(msg.c.state) == 1 or me.toNum(msg.c.state) == 3 then --钻石升级和正常升级的返回，关闭当前界面
                self:close()
            end
        elseif checkMsg(msg.t, MsgCode.WORLD_MAP_DROP_POINT) then
            self:close()
        elseif checkMsg(msg.t,MsgCode.ROLE_MAP_LAND_INFO) then 
            self:update(msg)  
        elseif checkMsg(msg.t,MsgCode.WORLD_STRONG_HOLD_UPlEVEL) then
            self:close()
        elseif checkMsg(msg.t,MsgCode.WORLD_STRONG_HOLD_SPEEDUP) then
            self:close()
        elseif checkMsg(msg.t,MsgCode.WORLD_STRONG_HOLD_CANCELUP) then
            self:close()
        elseif checkMsg(msg.t,MsgCode.BASTION_CHANGE_NAME) then
             self.Stronghold_Name:setString(msg.c.name)
             self.baseData.name = msg.c.name
             showTips("据点名字修改成功")
        end
    end)
end

function strongHoldDetailView:initWithBaseData(data,mData)
    self.baseData = data
    self.mapCellData = mData
    self.Stronghold_Name:setString(self.baseData.name)
    if self.baseData.leftTime and me.toNum(self.baseData.leftTime) > 0 then
        self.leftTime = self.baseData.leftTime/1000 - (me.sysTime()-self.baseData.indexTime)/1000
    end
    if self.mapCellData and self.mapCellData:bHaveDroping() == true and me.toNum(self.mapCellData.gtime) > 0 then
        self.leftTime = self.mapCellData.gtime - (me.sysTime()-self.mapCellData.revTime)/1000
    end
    self.armyData = self.baseData:getSortArmyData()
    self.currentLevel:setString(self.baseData.lv)
    local def = self.baseData:getDef()
    self.title_hp_num:setString(self.baseData.defense.."/"..def.defense)
    self.title_strength_num:setString(self.baseData:getArmyNum().."/"..def.num)
    self.title_speed_num:setString("+"..def.speed.."%")
    local pHavenum = 0
    for key, var in pairs(gameMap.bastionData) do
       pHavenum = pHavenum +1
    end
  
    self.strong_num:setString("("..pHavenum.."/"..user.centerBuild.def.extValue.city..")")
    me.registGuiClickEventByName(self,"Strong_Button",function (node)
         GMan():send(_MSG.roleLandInfo())
    end)
    self:initArmyTable()
    self.Button_remove:setVisible(self.baseData.state == 1 and self.mapCellData:bHaveDroping() == false)
    if self.leftTime ~= nil then
        self.Node_Cancel:setVisible(true)
        if self.levelupTimer ~= nil then
            me.clearTimer(self.levelupTimer)
            self.levelupTimer = nil
        end
        local function setTimeAndDiamond()
            local price = { }
            price.food = 0
            price.wood = 0
            price.stone = 0
            price.gold = 0
            price.time = self.leftTime
            price.index = 1
            local allCost = getGemCost(price,true)   
            me.assignWidget(self.Button_imm,"Text_imm_diamond"):setString(math.ceil(allCost))
            me.assignWidget(self.Button_imm,"Text_updateTime"):setString(me.formartSecTime(self.leftTime))
            if self.baseData.state == 3 then --升级中
                self.Button_imm:setVisible(true)
                self.Text_cancel:setString("升级中"..me.formartSecTime(self.leftTime))
            elseif self.mapCellData:bHaveDroping() == true then --拆除中
                self.Text_cancel:setString("拆除中"..me.formartSecTime(self.leftTime))                
            end
        end
        setTimeAndDiamond()
        self.levelupTimer = me.registTimer(self.leftTime,function ()
            if self.leftTime <=0 then
                me.clearTimer(self.levelupTimer)
                self.levelupTimer = nil
            end
            setTimeAndDiamond()
            self.leftTime = self.leftTime-1          
        end,1)
    else
        local nextDef = nil
        if def.nextlvid then
            nextDef = cfg[CfgType.BASTION_DATA][def.nextlvid]
            if user.Cross_Sever_Status == mCross_Sever then       
                nextDef = cfg[CfgType.CROSS_STRONG_HOLD][def.nextlvid]
            end
        end
        self.Button_update:setVisible(nextDef ~= nil)     
        if nextDef ~= nil then
            local upTime = me.assignWidget(self.Button_update,"Text_updateTime")
            upTime:setString(me.formartSecTime(nextDef.time / (1 + user.propertyValue["BuildTime"])))           
        end
    end
end

function strongHoldDetailView:initArmyTable()
    dump(self.armyData)
    local function numberOfCellsInTableView(tableCell)
        if table.nums(self.armyData) < 5 then
            return 5
        end
        return table.nums(self.armyData)
    end

    local function cellSizeForTable(table, idx)
        return 233, 275
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil
        local globalItems = me.createNode("Node_stronghold_trainItem.csb")
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(globalItems, "trainItem"):clone()
            node:setPosition(cc.p(233 / 2, 275 / 2))
            node:setAnchorPoint(cc.p(0.5, 0.5))
            cell:addChild(node)
        else
            node = me.assignWidget(cell, "trainItem")
        end
        if self.armyData ~= nil and self.armyData[me.toNum(idx+1)] ~= nil then
            local armyDef = self.armyData[me.toNum(idx+1)]:getDef()
            me.assignWidget(node, "item_icon"):loadTexture(soldierIcon(armyDef), me.plistType)
            me.assignWidget(node, "item_icon"):setVisible(true)
            me.assignWidget(node, "Text_name"):setString(armyDef.name)
            me.assignWidget(node, "Text_name"):setVisible(true)
            me.assignWidget(node, "item_num"):setString(self.armyData[me.toNum(idx+1)].num)
            me.assignWidget(node, "num_bg"):setVisible(true)
        else
            me.assignWidget(node, "item_icon"):setVisible(false)
            me.assignWidget(node, "Text_name"):setVisible(false)
            me.assignWidget(node, "num_bg"):setVisible(false)
        end
        me.assignWidget(node, "item_mask"):setVisible(self.armyData == nil or self.armyData[me.toNum(idx+1)]==nil)
        local item_empty = me.assignWidget(node, "item_empty")
        if self.armyData == nil or self.armyData[me.toNum(idx+1)]==nil then
            item_empty:setVisible(true)
            me.Helper:grayImageView(item_empty)
        else
            item_empty:setVisible(false)
        end

        return cell
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(1160, 275))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
        self.tableView:setPosition(cc.p(0, 0))
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        self.Panel_army:addChild(self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()    
end

function strongHoldDetailView:onEnterTransitionDidFinish()
    print("strongHoldDetailView:onEnterTransitionDidFinish()")
end

function strongHoldDetailView:onExit()
    print("strongHoldDetailView:onExit()")
end

function strongHoldDetailView:close()
    print("strongHoldDetailView:close()")
    me.clearTimer(self.levelupTimer)
    UserModel:removeLisener(self.listener)
    self.listener = nil
    self.levelupTimer = nil
    self:removeFromParentAndCleanup(true)
    pWorldMap.buildTrade = nil
end
function strongHoldDetailView:update(msg)
   
        local landInfo = landInfoView:create("landInfoView.csb")
        landInfo:initWithData(msg.c.list)
        self:addChild(landInfo)
        me.showLayer(landInfo,"bg_frame")    
     
 end
