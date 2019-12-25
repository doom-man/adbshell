runeAllAttr = class("runeAllAttr",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]:getChildByName(arg[2])
    end
end)
function runeAllAttr:create(...)
    local layer = runeAllAttr.new(...)
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

function runeAllAttr:ctor()
end

function runeAllAttr:onEnter()

end

function runeAllAttr:onExit()

end


function runeAllAttr:init()
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    
    self:initRuneTable()

    return true
end

function runeAllAttr:initData(nowCaseIndex)
    local attr = {}
	local attrUnit={}
    local nowEquip = user.runeEquiped[nowCaseIndex]
    local fightTotal = 0
    for k, v in pairs (nowEquip) do
        local runeStrengthCfg = cfg[CfgType.RUNE_STRENGTH][v.glv]
        local strPropKV = string.split(runeStrengthCfg.property, ",")
        fightTotal = fightTotal+v.fight
        for k1, v1 in pairs (strPropKV) do
            local arrKV = string.split(v1, ":")
            local attKey = arrKV[1]
            local attValue = tonumber(arrKV[2])*100
            if attr[attKey] then
                attr[attKey]=attr[attKey]+attValue
            else
                attr[attKey]=attValue
            end
            if attrUnit[attKey]==nil then
                attrUnit[attKey]='%'
            end
        end
        local aptPro = getRuneStrengthAttr(runeStrengthCfg, v.apt)
        for k1, v1 in ipairs (aptPro) do
            if attr[v1.k] then
                attr[v1.k]=attr[v1.k]+v1.v
            else
                attr[v1.k]=v1.v
            end
			if attrUnit[v1.k]==nil then
                attrUnit[v1.k]=v1.unit
            end
        end
    end
    local attrList={}
    for k, v in pairs(attr) do
		local unit="%"
		if attrUnit[k] then
			unit=attrUnit[k]
		end
        table.insert(attrList, {id =cfg[CfgType.LORD_INFO][k].id, name=cfg[CfgType.LORD_INFO][k].name..":", value="+ "..v..unit})
    end

    table.sort (attrList, function (a, b)
        return tonumber(a.id)<tonumber(b.id)
    end)

    me.assignWidget(self, "fightTotal"):setString(fightTotal)

    self.attrList = attrList
    self.runeTableView:reloadData()
end

function runeAllAttr:initRuneTable()
    self.runeTableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)

    end
    local function cellSizeForTable(table, idx)
        return 843, 50
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local data = self.attrList[idx+1]
        local cell = table:dequeueCell()
        local attrCell
        if nil == cell then
            cell = cc.TableViewCell:new()
            attrCell = me.assignWidget(self, "cell"):clone():setVisible(true)
            me.assignWidget(attrCell, "txt1"):setString(data.name)
            me.assignWidget(attrCell, "txt2"):setString(data.value)
         
            cell:addChild(attrCell)
        else
            attrCell = me.assignWidget(cell, "cell")
            me.assignWidget(attrCell, "txt1"):setString(data.name)
            me.assignWidget(attrCell, "txt2"):setString(data.value)
        end
        if idx%2==1 then
            attrCell:loadTexture("alliance_alpha_bg.png", me.localType)
        else
            attrCell:loadTexture("rune_attr_cell.png", me.localType)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.attrList
    end

    local tableView = cc.TableView:create(cc.size(838, 473))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "tblNode"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end