hornShopView = class("hornShopView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
hornShopView.__index = hornShopView

function hornShopView:create(...)
    local layer = hornShopView.new(...)
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
function hornShopView:ctor()
    print("hornShopView:ctor()")
end
function hornShopView:init()
    disWaitLayer()
    return true
end
function hornShopView:onEnter()
    me.doLayout(self,me.winSize)  
    me.registGuiClickEventByName(self,"close",function ()
        self:close()
    end)
    me.assignWidget(self,"title"):setString("战争号角")
    self:setHornNum()
    self:initTableView()

    self.listener = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_CHANGE) or 
        checkMsg(msg.t, MsgCode.ROLE_BACKPACK_ITEM_ADD) then
            self:setHornNum()
        end
    end)
    print("hornShopView:onEnter()")
end
function hornShopView:setHornNum()
    local haveNum = 0
    for key, var in pairs(user.pkg) do
        local pkgDef = var:getDef()
        if me.toNum(pkgDef.id) == me.toNum(73) then
            haveNum = haveNum + var.count
        end
    end
    me.assignWidget(self,"Text_hornNum"):setString(haveNum)
    if tonumber(self.toolType) == 10 then
        me.assignWidget(self,"title"):setString("圣物强化石")
        -- TODO: 当背包中没有强化石时，strengthStone字段为空！！
        local stoneNum = 0
        if user.strengthStone then
            stoneNum = user.strengthStone.count
        end
        me.assignWidget(self,"Text_hornNum"):setVisible(false)
        me.assignWidget(self,"Image_2"):setVisible(false)
    else
        me.assignWidget(self,"Text_hornNum"):setVisible(true)
        me.assignWidget(self,"Image_2"):setVisible(true)
    end
end
function hornShopView:onEnterTransitionDidFinish()
    print("hornShopView:onEnterTransitionDidFinish()")
end
function hornShopView:onExit()
    UserModel:removeLisener(self.listener)
    print("hornShopView:onExit()")
end
function hornShopView:close()
    self:removeFromParentAndCleanup(true)
end
function hornShopView:initWithType(type_)
    self.toolType = type_
    self.typeDatas = getShopResourceDataByType(self.toolType)
    
end
function hornShopView:initTableView()
    if self.shopTable then 
       self.shopTable:removeFromParent()
       self.shopTable = nil
    end
    local itemNum = #self.typeDatas
    local cellNum = math.ceil(itemNum / 2)

    local function cellSizeForTable(table, idx)
        return 1170, 175
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local shopCell_1 = recourceItem:create("rescourceItem.csb")
            local shopCell_2
            if self.typeDatas[idx*2+1] then 
                local cellData = self.typeDatas[idx*2+1]   
                shopCell_1:initWithData(cellData,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            else
                local cellData = self.typeDatas[idx*2+1-#self.typeDatas]
                shopCell_1:initWithData(cellData,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            end
            if self.typeDatas[idx*2+2] then 
                local cellData = self.typeDatas[idx*2+2]   
                shopCell_2 = recourceItem:create("rescourceItem.csb")
                shopCell_2:initWithData(cellData,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
--            elseif self.typeDatas[idx*2+2-#self.typeDatas] then 
--                local cellData = self.typeDatas[idx*2+2-#self.typeDatas]   
--                shopCell_2 = recourceItem:create("rescourceItem.csb")
--                shopCell_2:initWithData(cellData,ITEM_SHOP_TYPE,function(node)
--                self:close()
--                end)
            end
            shopCell_1:setAnchorPoint(0,0)
            shopCell_1:setPositionX(6)
            shopCell_1:setTag(123)        
            cell:addChild(shopCell_1)
            if shopCell_2 then 
                shopCell_2:setTag(124)
                shopCell_2:setAnchorPoint(0,0)
                shopCell_2:setPositionX(shopCell_1:getContentSize().width + 16)
                cell:addChild(shopCell_2)
            end                                   
        else
            local shopCell_1 = cell:getChildByTag(123)
            local shopCell_2 = cell:getChildByTag(124)
            if self.typeDatas[idx*2+1] then  
                local cellDatas = self.typeDatas[idx*2+1]
                shopCell_1:initWithData(cellDatas,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            else
                local cellDatas = self.typeDatas[idx*2+1-#self.typeDatas]
                local cellType = ITEM_SHOP_TYPE
                shopCell_1:initWithData(cellDatas,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            end

            if self.typeDatas[idx*2+2] then 
                local cellDatas = self.typeDatas[idx*2+2]
                shopCell_2:initWithData(cellDatas,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            elseif self.typeDatas[idx*2+2 - #self.typeDatas] then 
                local cellDatas = self.typeDatas[idx*2+2 - #self.typeDatas]
                shopCell_2:initWithData(cellDatas,ITEM_SHOP_TYPE,function(node)
                self:close()
                end)
            else 
                shopCell_2:removeFromParent()
            end 
        end  
        return cell
    end

    local function numberOfCellsInTableView(table)        
        return cellNum
    end

    self.shopTable = cc.TableView:create(cc.size(1170, 507))
    self.shopTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.shopTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.shopTable:setPosition(cc.p(0,0))
    self.shopTable:setDelegate()
    me.assignWidget(self,"Image_tableView"):addChild(self.shopTable)      
    self.shopTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.shopTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.shopTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.shopTable:reloadData()     
end