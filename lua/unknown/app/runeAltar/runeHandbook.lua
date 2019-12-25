local runeHandbookItem = class("runeHandbookItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHandbookItem:create(...)
    local layer = runeHandbookItem.new(...)
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

function runeHandbookItem:ctor()

end

function runeHandbookItem:onEnter()

end

function runeHandbookItem:onExit()

end

function runeHandbookItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.lvBox:setVisible(false)
    self.typeBox = me.assignWidget(self, "typeBox")
    self.typeBox:setVisible(false)
    self.nameBox = me.assignWidget(self, "nameBox")
    self.nameBox:setVisible(false)

    self.starNode = me.assignWidget(self, "starNode")
    self.star = me.assignWidget(self, "star")

    self.newIcon = cc.Sprite:create("runeNew.png")
    self.newIcon:setPosition(257, 378)
    self.newIcon:setVisible(false)
    self:addChild(self.newIcon)

    return true
end

function runeHandbookItem:setData(data)
    self.data=data
    local runeData= data.data
    self.icon:loadTexture(getRuneIcon(runeData.icon), me.plistType)
    self.box:loadTexture("levelbox"..runeData.level..".png", me.plistType)
    --self.nameTxt:setString(self.data.name)
    --self.typeIco:loadTexture("rune_type_"..self.data.type..".png",me.plistType)
    if data.isNew==true then
        self.newIcon:setVisible(true)
    else
        self.newIcon:setVisible(false)
    end
    
    
    self.starNode:removeAllChildren()
    if self.data.star~=nil then
        local starNums = self.data.star
        for i=1, starNums ,1 do 
            local star = self.star:clone():setVisible(true)
            star:setPositionX((i-1)*36)
            self.starNode:addChild(star)
        end
        self.starNode:setPositionX((357-starNums*36)/2)
    end

    if self.data.star~=nil then
       me.Helper:normalImageView(self.icon) 
       me.Helper:normalImageView(self.box)
       --self.nameTxt:setTextColor(cc.c3b(212,205,185))
       --self.lvTxt:setTextColor(cc.c3b(255,255,255))
       --me.Helper:normalImageView(self.typeIco)
    else
       me.Helper:grayImageView(self.icon) 
       me.Helper:grayImageView(self.box)
       --self.nameTxt:setTextColor(cc.c3b(112,109,99))
       --self.lvTxt:setTextColor(cc.c3b(112,109,99))
       --me.Helper:grayImageView(self.typeIco)
    end
end


runeHandbook = class("runeHandbook",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeHandbook:create(...)
    local layer = runeHandbook.new(...)
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

function runeHandbook:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )

    self.arrRuneBackpack={}
end

function runeHandbook:onEnter()
   
end

function runeHandbook:onExit()
    UserModel:removeLisener(self.netListener)

    for _, schid in pairs(self.schidCache) do
        if schid then
            me.Scheduler:unscheduleScriptEntry(schid)    
            schid = nil
        end
    end
    self.schidCache={}
end

function runeHandbook:init()
    me.registGuiClickEventByName(self,"close",function ()
        self:removeFromParent()
    end)

    self.schidCache={}

    self.cellpanel = me.assignWidget(self, "cellpanel")
    self.runeIcon = me.assignWidget(self, "runeIcon")

    self:initRuneTable()

    me.doLayout(self, me.winSize)

    return true
end

function runeHandbook:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.RUNE_HANDBOOK_ACTIVE) then
        self:setData(msg.c.list)
    end
end

function runeHandbook:setData(tmpData)
    local activeData={}
    for _, v in ipairs(tmpData) do
        activeData[v.defId]={star=v.star, isNew=v.isNew}
    end

    self.runeTechAll = {}
    local runeTechAll = cfg[CfgType.RUNE_TECH]
    for _, v in pairs(runeTechAll) do
        if self.runeTechAll[v.rank]==nil then
            self.runeTechAll[v.rank]={}
        end
        table.insert(self.runeTechAll[v.rank], v)
    end
    for _, v in pairs(self.runeTechAll) do
        table.sort(v, function(a, b) return a.star<b.star end)
    end

    self.arrRuneBackpack = {}
    self.arrRuneStar={}
    local runeDatasAll = cfg[CfgType.RUNE_DATA]
    for _, v in pairs(runeDatasAll) do
        if v.type~=99 then
            if self.arrRuneBackpack[v.level]==nil then
                self.arrRuneBackpack[v.level]={}
                self.arrRuneStar[v.level]=0
            end
            local ac=activeData[v.id]
            if ac then
                self.arrRuneStar[v.level]=self.arrRuneStar[v.level]+ac.star
                table.insert(self.arrRuneBackpack[v.level], {data=v, star=ac.star, isNew=ac.isNew})
            else
                table.insert(self.arrRuneBackpack[v.level], {data=v})
            end
        end
    end

    self.runeTableView:reloadData()

end


function runeHandbook:onClickRune(node)
    local cellData = node.data
    local detail = runeHandbookDetail:create("runeHandbookDetail.csb")
    me.runningScene():addChild(detail,me.MAXZORDER)
    me.showLayer(detail,"bg")
    detail:setData(cellData)
end


function runeHandbook:fillCellData(cell, data, idx, isFirst)
    me.assignWidget(cell, "cateIco"):loadTexture("rune_cate"..data[1].data.level..".png")
    me.assignWidget(cell, "cateIco"):ignoreContentAdaptWithSize(true)
    me.assignWidget(cell, "cateStarTxt"):setString(self.arrRuneStar[idx+1])
    
    local techTbl = self.runeTechAll[idx+1]
    local function fillRuneItem()
        for k, v in ipairs(data) do
            local runeIcon = cell:getChildByTag(k)
            if runeIcon==nil then
                local runeItemNode = me.assignWidget(self.runeIcon, "Panel"):clone():setVisible(true)  
                runeIcon = runeHandbookItem:create(runeItemNode, 1) 
                runeIcon:setScale(0.4) 
                runeIcon:setPosition(147+125*(k-1), 114)
                runeIcon:setTag(k)
                me.registGuiClickEvent(runeIcon, handler(self, self.onClickRune)) 
                runeIcon:setSwallowTouches(false)
                cell:addChild(runeIcon)
            end
            runeIcon:setData(v)
            
            local techData = techTbl[k]  --填充科技图标
            if techData then
                me.assignWidget(cell, "Text_process_"..k):setString(techData.star)
                local techUI = me.assignWidget(cell, "Button_Tech"..k)
                me.assignWidget(techUI, "Text_Level"):setString(techData.exttxt)
                local techNameTxt = me.assignWidget(techUI, "techNameTxt")
                techNameTxt:setString(techData.name)
                local img=me.assignWidget(techUI, "img")
                img:loadTexture(techIcon(techData.icon))
                img:setVisible(true)
                if self.arrRuneStar[idx+1]<techData.star then
                    me.Helper:grayImageView(img)
                    techNameTxt:setTextColor(cc.c3b(112,109,99))
                else
                    me.Helper:normalImageView(img)
                    techNameTxt:setTextColor(cc.c3b(209,158,86))
                end
            end

            if isFirst==true then
                coroutine.yield() 
            end
        end
    end

    if isFirst==true then
        local cthread = coroutine.create(fillRuneItem)
        if self.schidCache[idx] then
            me.Scheduler:unscheduleScriptEntry(self.schidCache[idx])    
            self.schidCache[idx] = nil
        end
        self.schidCache[idx] = me.coroStart(cthread)
    else
        fillRuneItem()
    end

    local stepStar = techTbl[2].star-techTbl[1].star
    local cnums = math.floor(self.arrRuneStar[idx+1]/stepStar)
    for k, v in ipairs(techTbl) do
        if k<=cnums then
            me.assignWidget(cell, "LoadingBar_process_"..k):setPercent(100)
        elseif k-cnums==1 then
            me.assignWidget(cell, "LoadingBar_process_"..k):setPercent(((self.arrRuneStar[idx+1]-cnums*stepStar)/stepStar)*100)
        else
            me.assignWidget(cell, "LoadingBar_process_"..k):setPercent(0)
        end
    end
end

function runeHandbook:initRuneTable()
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
        return 1169, 295
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        local cellData = self.arrRuneBackpack[idx+1]
        if nil == cell then
            cell = cc.TableViewCell:new()
            local leftCell = self.cellpanel:clone():setVisible(true)
            leftCell:setTag(111)
            self:fillCellData(leftCell, cellData, idx, true)
            cell:addChild(leftCell)
        else
            local leftCell = cell:getChildByTag(111)
            self:fillCellData(leftCell, cellData, idx, false)
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.arrRuneBackpack
    end

    local tableView = cc.TableView:create(cc.size(1170, 590))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(0, 3))
    tableView:setDelegate()
    me.assignWidget(self, "border"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end