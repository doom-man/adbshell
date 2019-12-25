
allianceLevelDetial = class("allianceLevelDetial", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
allianceLevelDetial.__index = allianceLevelDetial
function allianceLevelDetial:create(...)
    local layer = allianceLevelDetial.new(...)
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
function allianceLevelDetial:ctor()

    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)

    end )
end

-- tableViews数据填充
function allianceLevelDetial:initList()
    
    local unionCfg = cfg[CfgType.FAMILY_BASE]
    local unionData = {}
    for _, v in pairs(unionCfg) do
        table.insert(unionData, v)
    end

    -- 属性的间隔
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end

    local function cellSizeForTable(table, idx)
        return 752, 39
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local data = unionData[idx+1]
        local cellUI = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            cellUI = self.cellUI:clone():setVisible(true)
            cellUI:setTag(133)
            cellUI:setPosition(cc.p(0, 0))
            cell:addChild(cellUI)
        else
            cellUI = cell:getChildByTag(133)
        end
        me.assignWidget(cellUI, "lvTxt"):setString(data.id)
        me.assignWidget(cellUI, "txt1"):setString(data.depLeader)
        me.assignWidget(cellUI, "txt2"):setString(data.official)
        me.assignWidget(cellUI, "txt3"):setString(data.maxMember)
        local Image_5 = me.assignWidget(cellUI, "Image_5")
        Image_5:setVisible(idx % 2 ~= 0)

        local pQuan = cellUI:getChildByTag(1330)
        if pQuan and not tolua.isnull(pQuan) then
            pQuan:removeFromParent()
            pQuan = nil
        end
        if (idx + 1) ~= 0 and data.id == user.famliyInit.level then
            pQuan = ccui.ImageView:create()
            pQuan:loadTexture("zhucheng_kuang_xuanze.png", me.localType)
            pQuan:setTag(1330)
            cellUI:addChild(pQuan)
            local p = cc.p(me.assignWidget(cellUI, "lvTxt"):getPosition())
            pQuan:setPosition(p)
        end

        return cell
    end
    function numberOfCellsInTableView(table)
        return #unionData
    end

    local tableView = cc.TableView:create(cc.size(752, 413))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setDelegate()
    me.assignWidget(self, "boxright"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
    --    --
end
 
function allianceLevelDetial:init()
    self.cellUI = me.assignWidget(self,"cell")
    self:initList()
    return true
end
function allianceLevelDetial:onEnter()
    print("allianceLevelDetial:onEnter()")
    me.doLayout(self, me.winSize)
end
function allianceLevelDetial:onExit()
    print("allianceLevelDetial:onExit()")
end