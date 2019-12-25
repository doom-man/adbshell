-- [Comment]
-- jnmo
fortIdentifyMaterialView = class("fortIdentifyMaterialView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fortIdentifyMaterialView.__index = fortIdentifyMaterialView
function fortIdentifyMaterialView:create(...)
    local layer = fortIdentifyMaterialView.new(...)
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

function fortIdentifyMaterialView:ctor()
    print("fortIdentifyMaterialView ctor")
end
function fortIdentifyMaterialView:init()
    print("fortIdentifyMaterialView init")
    self.materialData = {}
    me.registGuiClickEventByName(self, "Button_cancel", function(node)
        self:close()
    end)
    self.a_shop_cell_bg = me.assignWidget(self,"a_shop_cell_bg")
    self.a_shop_cell_bg:setVisible(false)
    return true
end
function fortIdentifyMaterialView:initList()
    me.tableClear(self.materialData)
    self.materialData = {}
    if self.tableView ~= nil then
        self.tableView:removeFromParent()
        self.tableView = nil
    end
    for key, var in pairs(cfg[CfgType.HERO_MATERIAL]) do
          if me.isValidStr( var.destid ) then               
              local etcItem = EtcItemData.new(nil, var.soureid,getItemNum(var.soureid), nil, nil, nil)
              table.insert(self.materialData,etcItem)
          end
    end   
    local function tableSort(a,b)
         local aDef = a:getDef()
         local bDef = b:getDef()
         if me.toNum(aDef.id) > me.toNum(bDef.id) then
            return  true
         end
    end
    table.sort(self.materialData,tableSort)
    local pNum = #self.materialData   
    local pCellNum = math.floor(pNum/2)+ pNum%2

    local function setCellInfo(node, data)
        local tmpDef = data:getDef()
        me.assignWidget(node,"a_s_goods_name"):setString(tmpDef.name)
        me.assignWidget(node,"a_s_goods_details"):setString(tmpDef.describe)
        me.assignWidget(node,"a_s_goods_quailty"):loadTexture(getQuality(tmpDef.quality),me.localType)
        me.assignWidget(node,"a_s_goods_icon"):loadTexture(getItemIcon(tmpDef.id),me.localType)
        me.assignWidget(node,"Text_limitNum"):setString(data.count)
    end

    local function cellSizeForTable(table, idx)
        return 1180, 181
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local pSingleCell = nil        
        for var = 1, 2 do
            local pTag = idx*2+var
            local data = self.materialData[pTag]
            if nil == cell then
                cell = cc.TableViewCell:new()
            end  
            pSingleCell = cell:getChildByTag(var)
            if pSingleCell == nil then
                pSingleCell = self.a_shop_cell_bg:clone()
                pSingleCell:setVisible(true)
                cell:addChild(pSingleCell)
            end
            local buildBtn = me.assignWidget(pSingleCell,"Button_buy")     
            if data then 
                setCellInfo(pSingleCell,data)
                me.registGuiClickEvent(buildBtn,function (node)
                    local targetData = self.materialData[node:getTag()]
                    local def = targetData:getDef()
                    local canExchange = false
                    for key, var in pairs(cfg[CfgType.HERO_MATERIAL]) do
                        if me.toNum(var.soureid) == def.id then
                            canExchange = true
                            break
                        end
                    end   
                    if canExchange then
                        NetMan:send(_MSG.hero_exchange(def.id))
                        local fev = fortIdentifyExchangeView:create("fortIdentifyExchangeView.csb")
                        fev:setCurrentItemData(targetData)
                        self:addChild(fev)
                    else
                        showTips("低阶材料无法兑换成其他材料")
                    end                        
                end)
            end
            buildBtn:setTag(pTag)
            pSingleCell:setTag(var)
            me.setButtonDisable(buildBtn,data.count>0)
            pSingleCell:setPosition(cc.p((var - 1) * 590, 0))
            if me.toNum(pTag) <= pNum then
                pSingleCell:setVisible(true)
            else
                pSingleCell:setVisible(false)
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)        
        return pCellNum
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(1180, 526))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(cc.p(0, 0))
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        me.assignWidget(self, "Node_tab"):addChild( self.tableView)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()  
end
function fortIdentifyMaterialView:onEnter()
    print("fortIdentifyMaterialView onEnter") 
    self.In_bg = me.assignWidget(self,"In_bg")
	me.doLayout(self,me.winSize)  
    self:initList()
    self.modelkey = UserModel:registerLisener(function(msg)
        if checkMsg(msg.t, MsgCode.WORLD_FORT_HERO_EXCHANGE) then
            if msg.c.result == 1 then
                self:initList()    
            end
        end
    end)
end
function fortIdentifyMaterialView:onEnterTransitionDidFinish()
	print("fortIdentifyMaterialView onEnterTransitionDidFinish") 
end
function fortIdentifyMaterialView:onExit()
    print("fortIdentifyMaterialView onExit")   
    UserModel:removeLisener(self.modelkey) 
end
function fortIdentifyMaterialView:close()
    self:removeFromParentAndCleanup(true)  
end

