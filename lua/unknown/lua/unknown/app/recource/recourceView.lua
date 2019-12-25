recourceView = class("recourceView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
recourceView.__index = recourceView

recourceView.TYPEVAL = {
    ["food"] = 109,
    ["gold"] = 108,
    ["stone"] = 111,
    ["wood"] = 110,
}

local typeName = {
    ["food"] = "粮食",
    ["gold"] = "金子",
    ["stone"] = "石头",
    ["wood"] = "木头",
}

function recourceView:create(...)
    local layer = recourceView.new(...)
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
function recourceView:ctor()
    print("recourceView:ctor()")
    disWaitLayer()

    self.btns = {}
    self.curTypeState = "food"
    self.typeDatas = nil
    self.typeNum = recourceView.TYPEVAL["food"]
    self.cells = {}
end
function recourceView:init()
    self.Button_food = me.assignWidget(self, "Button_food")
    self.btns["food"] = self.Button_food
    self.Button_wood = me.assignWidget(self, "Button_wood")
    self.btns["wood"] = self.Button_wood
    self.Button_stone = me.assignWidget(self, "Button_stone")
    self.btns["stone"] = self.Button_stone
    self.Button_gold = me.assignWidget(self, "Button_gold")
    self.btns["gold"] = self.Button_gold
    for key, var in pairs(self.btns) do
        me.registGuiClickEvent(var, function(node,event)
            if event ~= ccui.TouchEventType.ended then
                self:btnsOnClicked(node)
            end
        end )
    end

    self.Text_foodNum = me.assignWidget(self, "Text_foodNum")
    self.Text_woodNum = me.assignWidget(self, "Text_woodNum")
    self.Text_stoneNum = me.assignWidget(self, "Text_stoneNum")
    self.Text_goldNum = me.assignWidget(self, "Text_goldNum")
    self.Text_foodNum:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))  
    self.Text_woodNum:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))  
    self.Text_stoneNum:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))  
    self.Text_goldNum:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(2, -2))  

    self.ScrollView_cell = me.assignWidget(self, "ScrollView_cell")

    self.quickNode = me.assignWidget(self, "quickNode")
    self.scrollBg = me.assignWidget(self, "Image_tableView")
    self.fastBtn = me.assignWidget(self, "fastBtn")
    me.registGuiClickEvent(self.fastBtn, function(node)
        if #self.typeDatas[ITEM_ETC_TYPE]==0 then 
            showTips("背包没有"..typeName[self.curTypeState].."道具")
            return
        end
        local tmpView = recourceQuick:create("useToolsQuick.csb")
        me.runningScene():addChild(tmpView, me.MAXZORDER)
        me.showLayer(tmpView, "bg")

        local spareResNums=self.resNeedNums-user[self.curTypeState]
        tmpView:setData(self:calc(1), spareResNums, typeName[self.curTypeState], self)
    end )

    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )

    return true
end
function recourceView:setRescourceType(typeKey)
    self.resNeedNums=0
    self.curTypeState = typeKey  
    self.typeNum = recourceView.TYPEVAL[typeKey]

    self:constructData()
end

function recourceView:setRescourceNeedNums(num)
    self.resNeedNums = num  
    self.resNeedType=self.curTypeState
    self.quickNode:setVisible(true)
    self.scrollBg:setContentSize(cc.size(1172.00,451.20))
    self.ScrollView_cell:setContentSize(cc.size(1167.00, 444))

    local resName = typeName[self.curTypeState]
    local pkgNums = self:getPkgResNums()
    local txt1 = me.assignWidget(self.quickNode, "txt1")
    txt1:setString(string.format("背包%s:%s",resName, pkgNums))
    local txt2 = me.assignWidget(self.quickNode, "txt2")
    txt2:setString(resName.."需求：")
    txt2:setPositionX(txt1:getPositionX()+txt1:getContentSize().width+30)

    local txt3 = me.assignWidget(self.quickNode, "txt3")
    local txt4 = me.assignWidget(self.quickNode, "txt4")
    txt3:setString(user[self.curTypeState])
    txt3:setPositionX(txt2:getPositionX()+txt2:getContentSize().width)
    
    txt4:setString("/"..num)
    txt4:setPositionX(txt3:getPositionX()+txt3:getContentSize().width)

    local txt5 = me.assignWidget(self.quickNode, "txt5")
    txt5:setPositionX(txt4:getPositionX()+txt4:getContentSize().width+30)

    local totalResNums = self:calc(0)
    local txt7 = me.assignWidget(self.quickNode, "txt7")
    local txt6 = me.assignWidget(self.quickNode, "txt6")
    txt7:setString(string.format("%s%s",totalResNums, resName))
    local spareResNums=self.resNeedNums-user[self.curTypeState]
    if totalResNums>=spareResNums then
        txt6:setString(",补足本次消耗")
        txt6:setTextColor(cc.c3b(175,165,140))
    else
        txt6:setString(",但仍不能补足本次消耗")
        txt6:setTextColor(cc.c3b(255,0,0))
    end
    txt7:setPositionX(txt5:getPositionX()+txt5:getContentSize().width)
    txt6:setPositionX(txt7:getPositionX()+txt7:getContentSize().width)

    self.fastBtn:setPositionX(txt6:getPositionX()+txt6:getContentSize().width+30)

    if user[self.curTypeState]>num then
        txt3:setTextColor(cc.c3b(175,165,140))
        txt5:setVisible(false)
        txt6:setVisible(false)
        txt7:setVisible(false)
        self.fastBtn:setVisible(false)
    else
        txt3:setTextColor(cc.c3b(255,0,0))
        txt5:setVisible(true)
        txt6:setVisible(true)
        txt7:setVisible(true)
        self.fastBtn:setVisible(true)
    end
end

function recourceView:getPkgResNums()
    local t=0
    for _, v in ipairs(self.typeDatas[ITEM_ETC_TYPE]) do
        t=t+v.count*tonumber(v.def.useEffect)
    end
    return t
end

function recourceView:btnsOnClicked(node)    
    if node == self.Button_gold and self.curTypeState ~= "gold" then
        self.curTypeState = "gold"
        self.typeNum = recourceView.TYPEVAL["gold"]
        self:updateBtnsState()
        self:constructData()
    elseif node == self.Button_stone and self.curTypeState ~= "stone" then
        self.curTypeState = "stone"
        self.typeNum = recourceView.TYPEVAL["stone"]
        self:updateBtnsState()
        self:constructData()
    elseif node == self.Button_wood and self.curTypeState ~= "wood" then
        self.curTypeState = "wood"
        self.typeNum = recourceView.TYPEVAL["wood"]
        self:updateBtnsState()
        self:constructData()
    elseif node == self.Button_food and self.curTypeState ~= "food" then
        self.curTypeState = "food"
        self.typeNum = recourceView.TYPEVAL["food"]
        self:updateBtnsState()
        self:constructData()
    end
    if self.resNeedNums>0  then
        if self.curTypeState~=self.resNeedType then
            self.quickNode:setVisible(false)
            self.scrollBg:setContentSize(cc.size(1172.00,513.50))
            self.ScrollView_cell:setContentSize(cc.size(1167.00, 508.00))
        else
            self.quickNode:setVisible(true)
            self.scrollBg:setContentSize(cc.size(1172.00,451.50))
            self.ScrollView_cell:setContentSize(cc.size(1167.00, 444))
        end
    end
end
function recourceView:updateResNums()
    self.Text_foodNum:setString(me.toNum(user.food))
    self.Text_woodNum:setString(me.toNum(user.wood))
    self.Text_stoneNum:setString(me.toNum(user.stone))
    self.Text_goldNum:setString(me.toNum(user.gold))
end
function recourceView:updateBtnsState()
    if self.curTypeState == nil then
        __G__TRACKBACK__("self.curTypeState is nil ！！！")
        return
    end

    for key, var in pairs(self.btns) do
        if key == self.curTypeState then
            me.assignWidget(self, "Button_"..key.."_select"):setVisible(true)
            var:loadTextureNormal("ui_ty_button_select.png",me.localType)
            var:loadTexturePressed("ui_ty_button_select.png",me.localType)
        else        
            me.assignWidget(self, "Button_"..key.."_select"):setVisible(false)
            var:loadTextureNormal("ui_ty_button_unselect.png",me.localType)
            var:loadTexturePressed("ui_ty_button_unselect.png",me.localType)
        end
        var:ignoreContentAdaptWithSize(false)
        var:setContentSize(217.32, 66)
    end

    self.ScrollView_cell:scrollToTop(0, false)
    self.cthread = coroutine.create(function ()
        --这里为调用的方法 然后在该方法中加入coroutine.yield()
        self:updateScrollView(true)
    end)
    self.schid = me.coroStart(self.cthread)
end
function recourceView:constructData()
    self.typeDatas = getResourceDataByType(self.typeNum)
end
function recourceView:updateScrollView(yield_)
    local datatotalNum=#self.typeDatas[ITEM_ETC_TYPE]+#self.typeDatas[ITEM_SHOP_TYPE]
    if datatotalNum<=0 then
        return
    end    
    self.ScrollView_cell:removeAllChildren()
    me.tableClear(self.cells)
    local cellH = 170
    local sLen = math.floor(datatotalNum/2 + datatotalNum%2)
    local scrollTmpH = cellH*sLen
    self.ScrollView_cell:setInnerContainerSize(cc.size(1167,scrollTmpH))
    for index = 1, datatotalNum do
        local itemCell = recourceItem:create("rescourceItem.csb")
        local cellData = nil
        local cellType = nil
        if index <= #self.typeDatas[ITEM_ETC_TYPE] then
            cellData = self.typeDatas[ITEM_ETC_TYPE][index]
            cellType = ITEM_ETC_TYPE
        else
            cellData = self.typeDatas[ITEM_SHOP_TYPE][index-#self.typeDatas[ITEM_ETC_TYPE]]
            cellType = ITEM_SHOP_TYPE
        end
        itemCell:initWithData(cellData,cellType,function ()
            self:close()
        end)
        self.cells[index]=itemCell
        self.ScrollView_cell:addChild(itemCell)
        local posX,posY = 2,0
        if index%2 == 0 then
            posX = 582
        end
        local totalH = 5
        if datatotalNum >= 6 then
            if datatotalNum%2 == 0 then
                totalH = datatotalNum-1
            else
                totalH = datatotalNum
            end
        end
        posY = math.ceil((totalH-index)/2) * cellH
        if self.quickNode:isVisible()==true and datatotalNum<5 then
            posY=posY-80
        end
        itemCell:setPosition(cc.p(posX,posY))
        itemCell:setAnchorPoint(cc.p(0,0))

        if yield_ then
            coroutine.yield()
        end
    end
    
end
function recourceView:onEnter()
    if self.curTypeState then
        self:updateBtnsState()
        self:updateResNums()
    end
    
    self.lisener = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_USE) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD)
        or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM) or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_REMOVE)
        or checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) then
            self:constructData()
            self:updateScrollView(false)
            if self.quickNode:isVisible()==true then
                self:setRescourceNeedNums(self.resNeedNums)
            end
        end

        if checkMsg(msg.t, MsgCode.ROLE_FOOD_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_WOOD_UPDATE) 
        or checkMsg(msg.t, MsgCode.ROLE_STONE_UPDATE) or checkMsg(msg.t, MsgCode.ROLE_GOLD_UPDATE) then
            self:updateResNums()
        end
    end)
    me.doLayout(self,me.winSize)  
    print("recourceView:onEnter()")
end
function recourceView:onEnterTransitionDidFinish()
    print("recourceView:onEnterTransitionDidFinish()")
end
function recourceView:onExit()
    print("recourceView:onExit()")
end
function recourceView:close()
    UserModel:removeLisener(self.lisener) -- 删除消息通知
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)
        self.schid = nil
    end
    self:removeFromParentAndCleanup(true)
end

function recourceView:calc(mode)
    if #self.typeDatas[ITEM_ETC_TYPE]==0 then
        if mode==0 then
            return 0
        else
            return {}
        end
    end
    local useItemList = { }
    for key, var in ipairs(self.typeDatas[ITEM_ETC_TYPE]) do
        local def = var:getDef()
        table.insert(useItemList,{data=var, count=var.count, useEffect=tonumber(def.useEffect)})
    end

    local function comp(a, b)
        return a.useEffect < b.useEffect
    end
    table.sort(useItemList, comp)

    
    local spareResNums=self.resNeedNums-user[self.curTypeState]
    local srcSpareResNums = spareResNums
    local totalResNums=0
    local overResNums = 0
    local rs = {}
    local isFind=false
    local immediatelyBreak=false
    while true do
        if immediatelyBreak==true then break end
        if isFind==false then
            local len = #useItemList
            local minFlag=false
            while len>0 do
                local v = useItemList[len]
                local t=tonumber(v.useEffect)
                if t<=spareResNums and v.count>0 then
                    local count=0
                    for i=1, v.count do
                        if t<=spareResNums then
                            spareResNums=spareResNums-t
                            count=count+1
                        else
                            break
                        end
                    end
                    v.count=v.count-count
                    if v.count==0 then
                        table.remove(useItemList, len)
                    elseif t-spareResNums<500 and spareResNums>0 then  --小于500
                        count=count+1
                        v.count=v.count-1
                        if v.count==0 then
                            table.remove(useItemList, len)
                        end
                        immediatelyBreak=true --提前完成查找
                        overResNums=t-spareResNums
                    elseif spareResNums==0 then
                        immediatelyBreak=true --提前完成查找
                    end
                    
                    totalResNums=totalResNums+count*t

                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+count
                    else
                        v.useCount=count
                        rs[v.data.uid]=v
                    end
                    minFlag=true
                    if immediatelyBreak==true then
                        break
                    end
                elseif t-spareResNums<500 and v.count>0 then  --小于500
                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+1
                    else
                        v.useCount=1
                        rs[v.data.uid]=v
                    end
                    v.count=v.count-1
                    if v.count==0 then
                        table.remove(useItemList, len)
                    end

                    totalResNums=totalResNums+t
                    overResNums=t-spareResNums
                    print("剩余时间:"..overResNums)
                    immediatelyBreak=true --提前完成查找
                    break
                end
                len=len-1
            end
            if minFlag==false then
                isFind=true
            end
        else
            for k, v in ipairs(useItemList) do
                local t=tonumber(v.useEffect)
                if t>=spareResNums and v.count>0 then
                    overResNums=t-spareResNums
                    print("剩余时间:"..overResNums)
                    if rs[v.data.uid] then
                        rs[v.data.uid].useCount=rs[v.data.uid].useCount+1
                    else
                        v.useCount=1
                        rs[v.data.uid]=v
                    end
                    totalResNums=totalResNums+t
                    v.count=v.count-1
                    if v.count==0 then
                        table.remove(useItemList, k)
                    end
                    break
                end
            end
            break
        end
    end

    if overResNums>500 then  --优化  查找是否能去除多余的
        for k, v in pairs(rs) do
            for i=1, v.useCount do
                if totalResNums-v.useEffect>srcSpareResNums then
                    v.useCount=v.useCount-1
                    totalResNums=totalResNums-v.useEffect
                end
            end
            if v.useCount==0 then
                rs[k]=nil
            end
        end            
    end
    if mode==0 then
        return totalResNums
    end
    
    return rs
end