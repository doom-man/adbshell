giftDetailCell = class("giftDetailCell",function(...)
    return cc.CSLoader:createNode(...)
end)
giftDetailCell.__index = giftDetailCell
function giftDetailCell:create(...)
    local layer = giftDetailCell.new(...)
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
--jnmo god
function giftDetailCell:ctor()
    print("giftDetailCell:ctor()")
end
function giftDetailCell:init()
    self.items = {}
    print("giftDetailCell:init()")
    return true
end
function giftDetailCell:onEnter()  
    me.assignWidget(self, "prom_reward_cell"):setVisible(false)
    me.registGuiClickEventByName(self,"Button_close",function ()
        self:close()
    end)
    self:setTableView()
    me.doLayout(self,me.winSize)
end

--查看联盟礼包的数据传入
function giftDetailCell:setItemData(str)
    local tmp = me.split(str,",")
    for key, var in pairs(tmp) do
        local single = me.split(var,":")
        local itemData = {}
        itemData[1]=single[1]
        itemData[2]=single[2]
        self.items[#self.items+1] = itemData
    end
end

--限时活动礼包的数据传入
function giftDetailCell:setItemData_Limit(args)
    for key, var in pairs(args) do
        local itemData = {}
        itemData[1]=var[1]
        itemData[2]=var[2]
        self.items[#self.items+1] = itemData
    end
end

function giftDetailCell:setTableView()
    if self.items == nil then
        __G__TRACKBACK__("self.items = nil !!!")
        return
    end
    local function numberOfCellsInTableView(table)
        return #self.items
    end

    local function cellSizeForTable(table, idx)
        return 752.,85
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "prom_reward_cell"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "prom_reward_cell")
            node:setVisible(true)
        end
        local tmp = self.items[me.toNum(idx+1)]
        if tmp then
            local def = cfg[CfgType.ETC][me.toNum(tmp[1])]
            if def == nil then
                __G__TRACKBACK__("CfgType.ETC id = "..tmp[1].." is nil !!!")
                return cell
            end
            local num = tmp[2]
            me.assignWidget(node,"p_reward_quilty"):loadTexture(getQuality(def.quality),me.localType)
            me.assignWidget(node,"p_reward_icon"):loadTexture("item_"..def.icon..".png",me.localType)
            me.assignWidget(node,"p_reward_name"):setString(def.name)
            me.assignWidget(node,"p_reward_num"):setString(num)
        end
        if idx%2==0 then
            node:loadTexture("alliance_alpha_bg.png", me.localType)
        else
            node:loadTexture("ui_ty_cell_bg.png", me.localType)
        end
        return cell
    end
    if self.tableView == nil then
        local Panel_table = me.assignWidget(self, "Panel_table")
        self.tableView = cc.TableView:create(cc.size(757,466))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setPosition(cc.p(0,0))
        Panel_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()   
end

function giftDetailCell:close()
    self:removeFromParentAndCleanup(true)
end

function giftDetailCell:onExit()
end
