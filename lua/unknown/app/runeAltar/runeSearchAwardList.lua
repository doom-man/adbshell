local runeSearchItem = class("runeSearchItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeSearchItem:create(...)
    local layer = runeSearchItem.new(...)
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

function runeSearchItem:ctor()

end

function runeSearchItem:onEnter()

end

function runeSearchItem:onExit()

end

function runeSearchItem:init()
    self.Button_bg = me.assignWidget(self, "Button_bg")
    self.quality = me.assignWidget(self, "Image_quality")
    self.Goods_Icon = me.assignWidget(self, "Goods_Icon")
    self.txt = me.assignWidget(self, "txt")

    return true
end

function runeSearchItem:getQuality(pQuality)
      local pQualityStr = ""
      if pQuality == 1 then
       pQualityStr = "beibao_kuang_hui.png"        -- 白色
      elseif pQuality == 2 then
       pQualityStr = "beibao_kuang_lv.png"         -- 绿色
      elseif pQuality == 3 then
       pQualityStr = "beibao_kuang_lan.png"        -- 蓝色
      elseif pQuality == 4 then
       pQualityStr = "beibao_kuang_zi.png"         -- 紫色
      elseif pQuality == 5 then
       pQualityStr = "beibao_kuang_cheng.png"      -- 橙色
      elseif pQuality == 6 then
       pQualityStr = "beibao_kuang_hong.png"       -- 红色
      end
      return pQualityStr
end
function runeSearchItem:setData(data)
    local pCfgData = cfg[CfgType.ETC][data] 
    self.quality:loadTexture(self:getQuality(pCfgData["quality"]), me.localType)
    self.Goods_Icon:loadTexture("item_"..pCfgData["icon"]..".png",me.localType)
    self.txt:setString(pCfgData.name)
end





local SearchRuneItem = class("SearchRuneItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function SearchRuneItem:create(...)
    local layer = SearchRuneItem.new(...)
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

function SearchRuneItem:ctor()

end

function SearchRuneItem:onEnter()

end

function SearchRuneItem:onExit()

end

function SearchRuneItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.lvBox:setVisible(false)
    self.typeBox = me.assignWidget(self, "typeBox")
    self.typeBox:setVisible(true)
    self.typeIco = me.assignWidget(self, "typeIco")
    self.nameBox = me.assignWidget(self, "nameBox")
    self.nameBox:setVisible(true)
    self.nameTxt = me.assignWidget(self, "nameTxt")
    self.nameTxt:setFontSize(36)
    self.star = me.assignWidget(self, "star")
    self.starNode = me.assignWidget(self, "starNode")

    return true
end

function SearchRuneItem:setData(data)
    local cfg = cfg[CfgType.RUNE_DATA][data[1]]
    self.icon:loadTexture(getRuneIcon(cfg.icon), me.plistType)
    self.box:loadTexture("levelbox"..cfg.level..".png", me.plistType)
    self.nameTxt:setString(cfg.name)
    self.typeIco:loadTexture("rune_type_"..cfg.type..".png",me.plistType)
    self.lvBox:loadTexture("levelbox"..cfg.level.."_c1.png", me.plistType)
    self.typeBox:loadTexture("levelbox"..cfg.level.."_c2.png", me.plistType)

    local starNums = data[2]
    self.starNode:removeAllChildren()
    for i=1, starNums ,1 do 
        local star = self.star:clone():setVisible(true)
        star:setPositionX((i-1)*36)
        self.starNode:addChild(star)
    end
    self.starNode:setPositionX((357-starNums*36)/2)
end









runeSearchAwardList = class("runeSearchAwardList",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeSearchAwardList:create(...)
    local layer = runeSearchAwardList.new(...)
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

function runeSearchAwardList:ctor()

end

function runeSearchAwardList:onEnter()
    
end

function runeSearchAwardList:onExit()

end

function runeSearchAwardList:close()
    self:removeFromParentAndCleanup(true)
end
function runeSearchAwardList:init()
    
    local closeBtn = me.assignWidget(self, "close")
    me.registGuiClickEvent(closeBtn, handler(self, self.close))

    self.Button_bg = me.assignWidget(self,"Button_bg")
    self.RuneItem = me.assignWidget(self,"runeItem")
    self:initRuneTable()

    return true
end

function runeSearchAwardList:setData(runes, ids)
    self.data={{type=1, name="圣物", h=35}}
    local nums = #runes
    local t={}
    for i=1, nums do
        if (i-1)%4==0 then
            t={}
            table.insert(self.data, {type=2, h=240, data=t})
        end
        table.insert(t, runes[i])
    end

    table.insert(self.data, {type=1, name="道具", h=35})
    
    local nums = #ids
    local t={}
    for i=1, nums do
        if (i-1)%4==0 then
            t={}
            table.insert(self.data, {type=3, h=189, data=t})
        end
        table.insert(t, ids[i])
    end

    self.runeTableView:reloadData()
end

function runeSearchAwardList:initRuneTable()
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
        local cellData = self.data[idx+1]
        return 658, cellData.h
    end

    local function addTitle(cell, cellData)
        local title = me.assignWidget(self,"title"):clone():setVisible(true)
        me.assignWidget(title, "titleTxt"):setString(cellData.name)
        cell:addChild(title)
    end

    local function addItem(cell, cellData)
        for  k, i in ipairs(cellData.data) do
            local item = runeSearchItem:create(self.Button_bg:clone():setVisible(true), 1) 
            item:setContentSize(cc.size(123, 123))
            item:setData(i)
            item:setPosition((k-1)*196+60, 45)
            --me.registGuiClickEvent(item,function ()
            --     showPromotion(i,1)
            --end)  
            item:setSwallowTouches(false)
            cell:addChild(item)
        end
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()
        local cellData = self.data[idx+1]

        if nil == cell then
            cell = cc.TableViewCell:new()
            if cellData.type==1 then
                addTitle(cell, cellData)
            elseif cellData.type==2 then
                local t=0
                for k, i in ipairs(cellData.data) do
                    local item = SearchRuneItem:create(me.assignWidget(self.RuneItem, "Panel"):clone():setVisible(true), 1)
                    item:setScale(0.55)
                    item:setData(i)
                    item:setPosition((k-1)*200+20, 0)
                    item:setName("runeItem"..k)
                    cell:addChild(item)
                    t=k
                end
                for i=t, 4 do
                    local item = SearchRuneItem:create(me.assignWidget(self.RuneItem, "Panel"):clone():setVisible(true), 1)
                    item:setScale(0.55)
                    item:setPosition((i-1)*200+20, 0)
                    item:setName("runeItem"..i)
                    item:setVisible(false)
                    cell:addChild(item)
                end
            elseif cellData.type==3 then
                addItem(cell, cellData)
            end
        else
            if cellData.type==2 then
                local item = cell:getChildByName('runeItem1')
                if item~=nil then
                    for k, i in ipairs(cellData.data) do
                        local item=cell:getChildByName('runeItem'..k)
                        item:setData(i)
                        item:setVisible(true)
                    end
                else
                    cell:removeAllChildren()
                    local t=0
                    for k, i in ipairs(cellData.data) do
                        local item = SearchRuneItem:create(me.assignWidget(self.RuneItem, "Panel"):clone():setVisible(true), 1)
                        item:setScale(0.55)
                        item:setData(i)
                        item:setPosition((k-1)*200+20, 0)
                        item:setName("runeItem"..k)
                        cell:addChild(item)
                        t=k
                    end
                    for i=t, 4 do
                        local item = SearchRuneItem:create(me.assignWidget(self.RuneItem, "Panel"):clone():setVisible(true), 1)
                        item:setScale(0.55)
                        item:setPosition((i-1)*200+20, 0)
                        item:setName("runeItem"..i)
                        item:setVisible(false)
                        cell:addChild(item)
                    end
                end
            elseif cellData.type==1 then
                cell:removeAllChildren()
                addTitle(cell, cellData)
            elseif cellData.type==3 then
                cell:removeAllChildren()
                addItem(cell, cellData)
            end
        
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        local num = #self.data
        return num
    end

    local tableView = cc.TableView:create(cc.size(843, 473))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel_1"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end