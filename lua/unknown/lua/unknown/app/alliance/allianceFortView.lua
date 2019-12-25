--联盟要塞 
allianceFortView = class("allianceFortView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
allianceFortView.__index = allianceFortView
function allianceFortView:create(...)
    local layer = allianceFortView.new(...)
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
function allianceFortView:ctor()  
    self.myFort = {}
    self.myDesc = {}
    self.Panel_huan = me.assignWidget(self,"Panel_huan")
    self.Panel_property = me.assignWidget(self,"Panel_property")
    me.registGuiClickEventByName(self,"Button_cancel",function(node)
        self:close()
    end)
end
function allianceFortView:close()
  self:removeFromParentAndCleanup(true)
end
function allianceFortView:init()
    print("allianceFortView init")
    local desc = clone(gameMap.fortDesc)
    for key,var in pairs(gameMap.fortDatas) do 
      if var.occ == 1 then 
       table.insert(self.myFort,var)
       local tbExt = me.split(GFortData()[var.id].ext,",")   
       for key, var in pairs(tbExt) do
           local tbE = me.split(var,":")
--           dump(tbE)
           desc[tbE[1]].value = desc[tbE[1]].value + me.toNum(tbE[2])
       end            
      end
    end  
    for key,var in pairs(desc) do 
      if var.value > 0 then 
        table.insert(self.myDesc,var)
      end
    end
    me.assignWidget(self,"totalHoldNum"):setString(#self.myFort.."/"..((user.propertyValue["FamilyFortressMax"] or 0 )  + cfg[CfgType.CFG_CONST][40].data)  )
    -- 占领数量提示
    me.registGuiClickEventByName(self, "btn_hold_num_tip", function(node)
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        local wd = node:convertToWorldSpace(cc.p(48, -108))
        stips:initWithStr("联盟要塞数量上限受联盟等级和联盟科技影响，占领的要塞数量达到上限时不可占领新的要塞，可手动放弃已占领的要塞以便占领新的要塞。", wd)
        me.popLayer(stips)
    end)
    return true
end
function allianceFortView:initFortTable()
    local num = #self.myFort

    local function cellSizeForTable(table, idx)
        return 813, 86
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)       
        local cell = table:dequeueCell()   
        local fortCell     
        if nil == cell then
          cell = cc.TableViewCell:new()
          fortCell = allianceFortCell:create(self,"allianceFortCell") 
          fortCell:setData(self.myFort[idx+1],1)
          fortCell:setPosition(cc.p(0, 0))                
          cell:addChild(fortCell)                                       
        else
          fortCell = me.assignWidget(cell,"allianceFortCell")
          fortCell:setData(self.myFort[idx+1],1)
        end  
        if idx%2==1 then
            me.assignWidget(fortCell, "Panel_10"):setVisible(false)
        else
            me.assignWidget(fortCell, "Panel_10"):setVisible(true)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)        
        return num
    end
    self.fortTable = cc.TableView:create(cc.size(813, 537))
    self.fortTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.fortTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.fortTable:setPosition(cc.p(0, 0))
    self.fortTable:setDelegate()
    me.assignWidget(self, "m_m_Node_tab"):addChild(self.fortTable)
    self.fortTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.fortTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.fortTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.fortTable:reloadData()     
end

function allianceFortView:initTotalTable()
    local num = #self.myDesc

    local function cellSizeForTable(table, idx)
        return 341, 43
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)        
        local cell = table:dequeueCell()  
        local totalCell      
        if nil == cell then
            cell = cc.TableViewCell:new()
            totalCell = allianceFortCell:create(self,"totalCell") 
            totalCell:setData(self.myDesc[idx+1],2)
            totalCell:setPosition(cc.p(0, 0))   
            cell:addChild(totalCell)                                
        else
            totalCell = me.assignWidget(cell,"totalCell")
            totalCell:setData(self.myDesc[idx+1],2) 
        end  
        if idx%2==0 then
            me.assignWidget(totalCell, "Panel_11"):setVisible(false)
        else
            me.assignWidget(totalCell, "Panel_11"):setVisible(true)
        end
        return cell
    end

    local function numberOfCellsInTableView(table)        
        return num
    end
    self.totalTable = cc.TableView:create(cc.size(self.Panel_property:getContentSize().width,self.Panel_property:getContentSize().height+1))
    self.totalTable:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.totalTable:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.totalTable:setPosition(cc.p(0, 0))
    self.totalTable:setDelegate()
    self.Panel_property:addChild(self.totalTable)  
    self.totalTable:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.totalTable:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.totalTable:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.totalTable:reloadData()     
end
function allianceFortView:setFortInfo()
    local fData = cfg[CfgType.FORTDATA]
    local tmp = {}
    for key, def in pairs(fData) do
        if tmp[me.toStr(def.star)] == nil then
            tmp[me.toStr(def.star)] = {}
            tmp[me.toStr(def.star)].total = 0
            tmp[me.toStr(def.star)].have = 0
        end
        tmp[me.toStr(def.star)].total = def.max
    end

    for key, var in pairs(self.myFort) do
        local def = cfg[CfgType.FORTDATA][var.id]
        if def then
            tmp[me.toStr(def.star)].have = tmp[me.toStr(def.star)].have+1
        end
    end
    local count=0
    for key, var in pairs(tmp) do
        local item = me.assignWidget(self,"totalCell"):clone()
        local index = me.toNum(key)
        self.Panel_huan:addChild(item)
        item:setVisible(true)
        item:setPosition(cc.p(0,225-count*item:getContentSize().height))
        if count%2==0 then
            me.assignWidget(item,"ImageVIew_cell"):setVisible(false)
        else
            me.assignWidget(item,"ImageVIew_cell"):setVisible(true)
        end
        count=count+1
        if me.isValidStr(var.have) and me.isValidStr(var.total) then
            me.assignWidget(item,"totalDescribe"):setString( (index+1).."环")
            me.assignWidget(item,"numsTxt"):setString( var.have.."/"..var.total)
        end
        --me.assignWidget(item,"totalDescribe"):setTextColor(cc.c3b(255,212,110))
    end
end

function allianceFortView:onEnter()      
	me.doLayout(self,me.winSize)  
    self:initFortTable()
    self:initTotalTable()
    --self:setFortInfo()
end
function allianceFortView:onExit()  
end

