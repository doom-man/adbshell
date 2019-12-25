fuhuoView = class("fuhuoView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
fuhuoView.__index = fuhuoView
fuhuoView.instance = nil

function fuhuoView:getInstance()
    if fuhuoView.instance == nil then
        print("create new treat view !!!! ")
        fuhuoView.instance = fuhuoView:create("fuhuoLayer.csb")
    end
    return fuhuoView.instance
end

function fuhuoView:create(...)
    local layer = fuhuoView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
function fuhuoView:ctor()
    print("fuhuoView ctor")
    self.allData = nil
    self.tableView = nil
    self.timer = nil
end
function fuhuoView:init()
    print("fuhuoView init")
    me.registGuiClickEventByName(self, "close", function()
        self:close()
    end )

    local selAll = false
    me.registGuiClickEventByName(self, "Button_All", function()
        selAll = false
        if self.spareReliveNums==0 then
            showTips("今日死兵复活数已用完")
            return
        end
        if self.spareReliveNums~=self.selectNums and self.data.total~=self.selectNums then
            selAll=true
        end

        local t = self.spareReliveNums-self.selectNums
        local tmp = 0
        for key, var in ipairs(self.allData) do
            if selAll then
                if tmp+var.num>t then
                    var.curNum = t-tmp
                    break
                else
                    var.curNum = var.num
                    tmp = tmp+var.num
                end
            else
                var.curNum = 0
            end
        end
        self:initList()
        self:updateRes()
    end )

    
    me.registGuiClickEventByName(self, "Button_Fast", function()
        local army = {}
        local curNum = 0
        for key, var in pairs(self.allData) do
             local temp = {}
             temp.id = var.defId
             temp.num = var.curNum
             curNum = curNum+var.curNum
             if var.curNum > 0 then
                table.insert(army,temp)
             end
        end   
        if curNum > 0 then
            local function diamondUse()
                NetMan:send(_MSG.reliveSoldier(army,1))                    
                self:close()
            end
            local needDiamond = tonumber(self.Text_Diamond:getString())
            if user.diamond<needDiamond then
                diamondNotenough(needDiamond, diamondUse)  
            else
                me.showMessageDialog("确认消耗"..needDiamond.."钻石复活吗?", function(args)
                    if args == "ok" then
                        diamondUse()
                    end
                end )
            end
        else
            showTips("请选择死兵数量","FF0000")
        end
    end )

    self.totalNumTxt = me.assignWidget(self, "totalNum")
    self.todayNumsTxt = me.assignWidget(self, "todayNums")
    self.selectNumsTxt = me.assignWidget(self, "selectNums")
    self.Text_Diamond = me.assignWidget(self, "Text_Diamond")
    self.rateTxt = me.assignWidget(self, "rateTxt")
    self.rateTxt:setVisible(false)

    self.border = me.assignWidget(self, "border")

    self.Button_All = me.assignWidget(self,"Button_All")
    self.Button_Treat = me.assignWidget(self,"Button_Treat")
    return true
end
function fuhuoView:setData(data)
    self.data = data
    self.totalNumTxt:setString(data.total)
    
    self.spareReliveNums = data.treatNumAdd-data.relive
    self.todayNumsTxt:setString(self.spareReliveNums.."/"..data.treatNumAdd)

    self.selectNums = 0

    self.Text_Diamond:setString("0")
    self.selectNumsTxt:setString('选择数量：0')

    self.allData = {}
    for _, var in ipairs(data.list) do
        local soldierData = revertSoilderData.new(var.defId, var.num, 0)
        table.insert(self.allData,soldierData)
    end
end

function fuhuoView:getTreatState()
    local state = nil
    if user.building[self.tofid] then
        state = user.building[self.tofid].state
    else
        __G__TRACKBACK__("user.building["..self.tofid.."[.state is nil !!!!! ")
    end
    return state
end
function fuhuoView:initList()
    
    local iNum = #self.allData
    local function cellSizeForTable(table, idx)
        return 1162, 135
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local soldierdata = self.allData[idx+1]   
        local label = nil
        if nil == cell and soldierdata then 
            cell = cc.TableViewCell:new()
            local item = fuhuoCell:create(me.createNode("Node_Treat_Item.csb"), "expedItem")        
            item:setPosition(item:getContentSize().width / 2,item:getContentSize().height/2)
            item:initWithData(soldierdata, self.data)
            item:setParent(self)

            cell:addChild(item)

            me.assignWidget(item,"shangbingIco"):setVisible(true)
            local slider = me.assignWidget(item,"Slider_Soldier")
            local Button_Reduce = me.assignWidget(item,"Button_Reduce")
            local Button_Add = me.assignWidget(item,"Button_Add")
            if self.data.relive>self.data.treatNumAdd then
                slider:setEnabled(false)
                Button_Reduce:setTouchEnabled(false)
                Button_Add:setTouchEnabled(false)
            else
                slider:setEnabled(true)
                slider:setTouchEnabled(true)
                Button_Reduce:setTouchEnabled(true)
                Button_Add:setTouchEnabled(true)
            end
        else
            local item = me.assignWidget(cell, "expedItem")
            item:setParent(self)

            item:initWithData(soldierdata, self.data)
            local slider = me.assignWidget(item,"Slider_Soldier")
            local Button_Reduce = me.assignWidget(item,"Button_Reduce")
            local Button_Add = me.assignWidget(item,"Button_Add")
            if self.data.relive>self.data.treatNumAdd then
                slider:setEnabled(false)
                Button_Reduce:setTouchEnabled(false)
                Button_Add:setTouchEnabled(false)
            else
                slider:setEnabled(true)
                slider:setTouchEnabled(true)
                Button_Reduce:setTouchEnabled(true)
                Button_Add:setTouchEnabled(true)
            end
        end
        return cell
    end

    function numberOfCellsInTableView(table)
        return iNum
    end

    if self.tableView then
        self.tableView:reloadData()
    else
        self.tableView = cc.TableView:create(cc.size(1162, 352))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setDelegate()
        self.border:addChild(self.tableView)
        self.tableView:setPosition(cc.p(7,4))
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
        self.tableView:reloadData()    
    end
end


function fuhuoView:updateRes()

    local totalNum = 0
    local totalCost = 0
    for key, var in pairs(self.allData) do
        totalNum = totalNum+var.curNum
        local def = var:getDef()
        totalCost = totalCost+math.ceil(def.fuhuocost*var.curNum)
    end

    self.rateTxt:setVisible(false)
    local allCost =  totalCost
    totalCost = math.ceil(totalCost*(1-user.propertyValue["FuHuoDiscount"]))
    local t=math.floor((user.propertyValue["FuHuoDiscount"]*totalCost/totalCost)*100)
    if allCost~=totalCost and t>0 then
        self.rateTxt:setVisible(true)
        self.rateTxt:setString("原始花费钻石 "..allCost.."  已享受复活优惠："..(t).."%")
    end
    
    self.selectNums=totalNum
    self.Text_Diamond:setString(totalCost)
    self.selectNumsTxt:setString('选择数量：'..totalNum)
end

function fuhuoView:close()
    print("fuhuoView:close()")
    me.clearTimer(self.timer)
    self.timer = nil
    self:removeFromParentAndCleanup(true)
end
function fuhuoView:onEnter()
    print("fuhuoView onEnter")
    me.doLayout(self,me.winSize)  

    self:initList()
 
end

function fuhuoView:onExit()
    print("fuhuoView onExit")
    me.clearTimer(self.timer)
    self.timer = nil
    fuhuoView.instance = nil
    self.allData = nil
end
