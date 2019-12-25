 --[Comment]
--jnmo
local searchTypeCfgSrc = {
    {id=5, name="粮食", maxLv=1, tileType=2, serverNo=-3},
    {id=6, name="木头", maxLv=1, tileType=3, serverNo=-5},
    {id=7, name="石头", maxLv=1, tileType=4, serverNo=-6},
    {id=8, name="金子", maxLv=1, tileType=5, serverNo=-7},
    {id=2, name="蛮族", maxLv=1, serverNo=-2},
    {id=9, name="宝箱", maxLv=1, serverNo=-4},
    {id=1, name="军团", maxLv=1, serverNo=0}, 
    {id=4, name="圣地", maxLv=30, serverNo=4}, 
}

local searchTypeCfg = {}

local searchTypeServerCfg = {
    [1]={id=100, name="巨龙", maxLv=1, serverNo=1}, 
    [8]={id=101, name="迅猛龙", maxLv=1, serverNo=8}, 
}

find_rune_boos = class("find_rune_boos",function (...)
     local arg = {...}
    if table.getn(arg) == 2 then    
        return arg[1]:getChildByName(arg[2])
    else
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return cc.CSLoader:createNode(arg[1])
    end
end)
find_rune_boos.__index = find_rune_boos
function find_rune_boos:create(...)
    local layer = find_rune_boos.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
find_rune_boos.MAX_LEVEL = 30
function find_rune_boos:ctor(...)   
    print("find_rune_boos ctor") 
    _, _, self.typeIdFrom = ...

    self.maxLevel = find_rune_boos.MAX_LEVEL

    searchTypeCfg = clone(searchTypeCfgSrc)

    self.mSearhRs = {}

end
function find_rune_boos:init()   
    print("find_rune_boos init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)      
    self.Slider_worker = me.assignWidget(self,"Slider_worker") 
    self.btn_ok = me.assignWidget(self,"btn_ok") 
    self.Node_EditBox = me.assignWidget(self, "Node_EditBox")
    self.editBox = self:createEditBox()
    self.editBox:setFontColor(cc.c3b(196,187,117))
    self.Text_tips = me.assignWidget(self,"Text_tips")
    self.Text_maxWorker = me.assignWidget(self,"Text_maxWorker")
    self.Text_maxWorker:setString(self.maxLevel)
    
    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local slider = sender
            local percent = slider:getPercent() / 100            
            local tempfarmer = math.floor(percent * self.maxLevel)
            if self.curLevel == tempfarmer then
                return
            end
            if tempfarmer == 0 then
               tempfarmer = 1
            end 
            self.curLevel = tempfarmer
            self.editBox:setText(tempfarmer)
            slider:setPercent(tempfarmer*100/self.maxLevel)
 
        end
    end

    local function sliderTouchEvent(sender, eventType)
        local slider = sender
        if eventType == ccui.TouchEventType.ended  then
            slider:setPercent(self.curLevel/self.maxLevel*100) 
            self.editBox:setText(self.curLevel)
            self.editBox:setFontColor(COLOR_WHITE)
            me.setButtonDisable(self.btn_ok, true)
        end
    end
    self.Slider_worker:addEventListener(sliderEvent)
    self.Slider_worker:addTouchEventListener(sliderTouchEvent)
     me.registGuiClickEventByName(self, "btn_add", function(node)
        local tmpWorker = self.curLevel+1
        if tmpWorker > self.maxLevel then
            showTips(TID_BUILDUP_GETMAX)         
        else
            self.curLevel = tmpWorker
            self.Slider_worker:setPercent(self.curLevel * 100 / self.maxLevel)
            self.editBox:setText(self.curLevel)
        end
    end )
        me.registGuiClickEventByName(self, "btn_reduce", function(node)
        local tmpWorker = self.curLevel-1
        if tmpWorker < 1 then
            --showTips("")
        else
            self.curLevel = tmpWorker
            self.Slider_worker:setPercent(self.curLevel * 100 / self.maxLevel)
            self.editBox:setText(self.curLevel)
        end
    end )
   -- self.curLevel = 1
    --self.editBox:setText(self.curLevel)
    --self.Text_maxWorker:setString("/"..self.maxLevel)
    --self.Slider_worker:setPercent(self.curLevel*100/self.maxLevel)
    

    me.registGuiClickEventByName(self,"btn_ok",function (node)
        local data = searchTypeCfg[self.curTypeIndex]
        cc.UserDefault:getInstance():setStringForKey("defaultSearchType"..data.id.."Lv", self.curLevel)
        cc.UserDefault:getInstance():flush()
        if data.serverNo==-1 then
            self:typeChange(self.curTypeIndex)
        else
            NetMan:send(_MSG.Rune_find_guard(self.curLevel, data.serverNo, user.curMapCrood.x, user.curMapCrood.y)) 
        end
    end)

    self:checkClick()
    self:initSearchList()
    
    return true
end

function find_rune_boos:gotoFind()
    self:typeChange(self.curTypeIndex)
end

function find_rune_boos:initSearchList()
    self.searchTableView = nil
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
       local pData = self.mSearhRs[cell:getIdx()+1]
       --local pHeroConfig = cfg[CfgType.HERO][pheroData["heroDefid"]]
       --self:setHeroInfo(pheroData)
       --self.mPitchHero = pheroData
       --self:getFortFort(pHeroConfig["herotype"])     
       --self.HeroPitchImg:setPosition(cc.p(self:getHeroCellPoint(cell:getIdx()+1,pNum)))
    end
    local function cellSizeForTable(table, idx)
      
        return 311, 158
    end

    local function tableCellAtIndex(table, idx)
        -- print(idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()
            local pLeftCell = me.assignWidget(self,"leftCell"):clone():setVisible(true)
            me.registGuiClickEvent(pLeftCell, handler(self, self.onClickSearch)) 
            pLeftCell:setSwallowTouches(false)
            pLeftCell:setTag(33)    
            pLeftCell:setName(idx+1)
            self:setLeftCell(pLeftCell,self.mSearhRs[idx+1])
            cell:addChild(pLeftCell)
        else 
           local pLeftCell = cell:getChildByTag(33)
           pLeftCell:setName(idx+1)
           self:setLeftCell(pLeftCell,self.mSearhRs[idx+1])
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        return #self.mSearhRs
    end

    local tableView = cc.TableView:create(cc.size(311, 489))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "Panel_Left"):addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.searchTableView = tableView
  
end

function find_rune_boos:onClickSearch(node)
    local data = self.mSearhRs[tonumber(node:getName())]
    pWorldMap:lookMapAt(data.pos.x,data.pos.y,0,"searchBoss")
    --pWorldMap:doClickEvent(cc.p(data.pos.x,data.pos.y))
    self:close()     

end
function find_rune_boos:setLeftCell(pNode,pData)
    if pData then
       me.assignWidget(pNode,"Text_1"):enableShadow(cc.c4b(0, 0, 0, 0xff), cc.size(1, -1))   
       me.assignWidget(pNode,"Text_Name"):setString("[Lv."..pData.cfg.landlv.."] "..pData.cfg.name)
       me.assignWidget(pNode,"Text_Info1"):setString("守军强度："..pData.cfg.npclv)
       me.assignWidget(pNode,"Text_Info2"):setString("("..pData.pos.x..","..pData.pos.y..")")
       me.assignWidget(pNode,"Text_Info3"):setString("距离："..pData.dist)
    end
end




function find_rune_boos:initTypeList()
       
    local function scrollViewDidScroll(view)
        --  print("scrollViewDidScroll")
    end

    local function scrollViewDidZoom(view)
        --   print("scrollViewDidZoom")
    end

    local function tableCellTouched(table, cell)
      
    --    table:onTouchBegan()

    end

    local function cellSizeForTable(table, idx)
        return 242, 127
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        if nil == cell then
            cell = cc.TableViewCell:new()
            
            for  var = 1,2 do
                local pTag = idx*2+var
                local leftCell = me.assignWidget(self,"rightCell"):clone():setVisible(true)  
                leftCell:setName(pTag)  
                me.registGuiClickEvent(leftCell, handler(self, self.onClickType)) 
                leftCell:setSwallowTouches(false)
                leftCell:setPosition(cc.p((var-1)*125,0))     
                leftCell:setTag(var*100)    
                cell:addChild(leftCell)
                local leftData = searchTypeCfg[pTag]
                if leftData then
                    self:setRightCell(leftCell,leftData)
                else
                    leftCell:setVisible(false)
                end
            end

        else
            for  var = 1, 2  do
                local pTag = idx*2+var
                local leftCell = cell:getChildByTag(var*100)
                local leftData = searchTypeCfg[pTag]
                if leftCell and leftData then
                    leftCell:setVisible(true)
                    leftCell:setName(pTag)  
                    self:setRightCell(leftCell,leftData)
                else
                    leftCell:setVisible(false)
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        local num = math.ceil(#searchTypeCfg / 2)
        return num
    end

    self.tableView = cc.TableView:create(cc.size(250,489))
    self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self.tableView:setPosition(0, 0)
  --  tableView:setAnchorPoint(cc.p(0,0))
    self.tableView:setDelegate()
    me.assignWidget(self, "Panel_Right"):addChild( self.tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self.tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.tableView:reloadData()

    
    self.selectImg = ccui.ImageView:create()            
    self.selectImg:loadTexture("beibao_xuanzhong_guang.png", me.localType)
    self.selectImg:setScale9Enabled(true)
    self.selectImg:ignoreContentAdaptWithSize(false)
    self.selectImg:setCapInsets(cc.rect(17, 17, 8, 8))
    self.selectImg:setContentSize(cc.size(135, 134))
    self.selectImg:setPosition(cc.p(self:getCellPoint(1)))
    self.selectImg:setLocalZOrder(200)
    self.tableView:addChild(self.selectImg)

    if #searchTypeCfg>0 then
       self.selectImg:setVisible(true) 
    else
       self.selectImg:setVisible(false)
    end  
end

function find_rune_boos:getCellPoint(pTag)
    pTag = me.toNum(pTag)
    self.pCellId = pTag
    local pRow = math.floor((pTag-1)/2)                        --行数
    local pLine = pTag%2                      --列数
    if pLine ==0 then
        pLine = 2
    end
    local pPointX = pLine*125-64
    local totalLineNums = math.ceil(#searchTypeCfg / 2)
    local pPointY =(totalLineNums- pRow)*127-67
    return pPointX,pPointY
end

function find_rune_boos:onClickType(node)
    self.selectImg:setPosition(cc.p(self:getCellPoint(node:getName())))
    self.selectImg:setVisible(true) 
    self:typeChange(node:getName())
    print(data)
end

function find_rune_boos:typeChange(index)
    self.curTypeIndex = tonumber(index)
    local data = searchTypeCfg[self.curTypeIndex]
    self.curTypeId = data.id
    self.curLevel = cc.UserDefault:getInstance():getStringForKey("defaultSearchType"..data.id.."Lv", 1)

    if data.id==4 then
        me.assignWidget(self, "runeLvTips"):setVisible(true)
        me.assignWidget(self, "runeLv"):setString(self.runeLv)
    else
        me.assignWidget(self, "runeLvTips"):setVisible(false)
    end

    if data.maxLv==1 then
        me.assignWidget(self, "lvNode"):setVisible(false)
        me.assignWidget(self, "btn_ok"):setVisible(false)
    else
        me.assignWidget(self, "lvNode"):setVisible(true)
        me.assignWidget(self, "btn_ok"):setVisible(true)
    end

    self.editBox:setText(self.curLevel)
    self.maxLevel=data.maxLv
    self.Text_maxWorker:setString("/"..self.maxLevel)
    self.Slider_worker:setPercent(self.curLevel*100/self.maxLevel)
    if data.serverNo==-1 then
        self.mSearhRs = self:findAroundTile(data.tileType, self.curLevel)
        self.searchTableView:reloadData()
        if #self.mSearhRs==0 then
            me.assignWidget(self,"leftNotFind"):setVisible(true)
        else
            me.assignWidget(self,"leftNotFind"):setVisible(false)
        end
    else
        NetMan:send(_MSG.Rune_find_guard(self.curLevel, data.serverNo, user.curMapCrood.x, user.curMapCrood.y)) 
    end
end

function find_rune_boos:setRightCell(pNode,pData)
    if pData then
        me.assignWidget(pNode,"icon"):loadTexture("search_type_"..pData.id..".png", me.plistType)
        me.resizeImage(me.assignWidget(pNode,"icon"), 103,103)

        me.assignWidget(pNode,"label"):setString(pData.name)
    end
end


function find_rune_boos:checkClick()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(handler(self, self.onTouchBegan), cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(handler(self, self.onTouchMoved), cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(handler(self, self.onTouchEnded), cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, me.assignWidget(self,"bg"))

end
function find_rune_boos:onTouchBegan(touch, event)
    if not self.touchCount then
        self.touchCount = 1
    else
        self.touchCount = self.touchCount + 1
    end
    self.moved = cc.p(0, 0)
    return true
end

function find_rune_boos:onTouchMoved(touch, event)
    self.moved = cc.p(self.moved.x + touch:getDelta().x, self.moved.y + touch:getDelta().y)
end
function find_rune_boos:onTouchEnded(touch, event)
    if not self.touchCount then
        self.touchCount = 0
    else
        self.touchCount = self.touchCount - 1
    end
    if self.touchCount and self.touchCount > 0 then
        return
    end
    if self.moved and cc.pGetLength(self.moved) > 8 then
        return
    end
    local x, y = touch:getLocation().x, touch:getLocation().y
    if not cc.rectContainsPoint(me.assignWidget(self,"bg"):getBoundingBox(), cc.p(x, y)) then
        self:close()
        return true
    end
end

function find_rune_boos:onEnter()
    print("find_rune_boos onEnter") 
	me.doLayout(self,me.winSize)  
    NetMan:send(_MSG.Rune_find_guard_init())
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function find_rune_boos:onEnterTransitionDidFinish()
	print("find_rune_boos onEnterTransitionDidFinish") 
end
function find_rune_boos:onExit()
    print("find_rune_boos onExit")    
    self:getParent().findRuneBoos=nil
end
function find_rune_boos:close()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知   
    self:removeFromParentAndCleanup(true) 
    
end

function find_rune_boos:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_RUNE_FIND_GUARD) then
        for k ,v in ipairs(searchTypeCfg) do
            if msg.c.type==v.serverNo then   
                self.curTypeIndex = k
                self.curTypeId = v.id
                self.curLevel = cc.UserDefault:getInstance():getStringForKey("defaultSearchType"..v.id.."Lv", 1)

                self.editBox:setText(self.curLevel)
                self.maxLevel=v.maxLv
                self.Text_maxWorker:setString("/"..self.maxLevel)
                self.Slider_worker:setPercent(self.curLevel*100/self.maxLevel)

                local findRs = {}
                for i, j in ipairs(msg.c.list) do
                    table.insert(findRs, {pos=cc.p(j.x, j.y), cfg={landlv=j.lv,name=j.name, npclv=j.fight}, dist=string.format("%.1f", j.len)})
                end
                self.mSearhRs = findRs
                self.searchTableView:reloadData()
                if #findRs==0 then
                    me.assignWidget(self,"leftNotFind"):setVisible(true)
                else
                    me.assignWidget(self,"leftNotFind"):setVisible(false)
                end
            end
        end
    elseif checkMsg(msg.t, MsgCode.MSG_RUNE_FIND_GUARD_INIT) then
        local list = msg.c.types
        if list then
            for _, v in ipairs(list) do
                if searchTypeServerCfg[v] then
                    table.insert(searchTypeCfg, searchTypeServerCfg[v])
                end
            end
        end
        self:initTypeList()

        self.runeLv = msg.c.runeLv

        if self.typeIdFrom ~=nil and self.typeIdFrom ~=0 then
            self.selectImg:setPosition(cc.p(self:getCellPoint(self.typeIdFrom)))
            self.selectImg:setVisible(true) 
            self:typeChange(self.typeIdFrom)
        else
            self:typeChange(1)
        end
    end
end



function find_rune_boos:findAroundTile(tileType, lv)
    
    lv = tonumber(lv)
    local x =user.curMapCrood.x   --中心位置
    local y =user.curMapCrood.y
    local findFlag =  false

    local count=0
    local findRs = {}

    local function findResource(tx, ty)
        local tileCfgData = getMapConfigData(cc.p(tx, ty))
        if tileCfgData.typeid==tileType and tileCfgData.landlv==lv then
            local dist,_t =  getMarchDis({ori=cc.p(user.majorCityCrood.x, user.majorCityCrood.y), tag=cc.p(tx, ty)})
            table.insert(findRs, {pos=cc.p(tx, ty), cfg=tileCfgData, dist=string.format("%.1f", dist)})
            return true
        end
        return false
    end
    if findResource(x, y)==true then
        count=1
    end


    local initGrid = 2
    local prevLineGridNums = 1
    for t=1, 50, 1 do  
        local lineGridNums = t*2+1
        local p=lineGridNums*lineGridNums-prevLineGridNums*prevLineGridNums
        local initX=0
        local initY=0
        local srcX = x-(lineGridNums-initGrid)
        local srcY = y-(lineGridNums-initGrid)
        local step = lineGridNums-1
        for i=1, p, 1 do
            local tmpX = srcX+initX
            local tmpY = srcY+initY
            if initX<step and initY==0 then
                initX=initX+1
            elseif initX==step and initY<step then
                initY=initY+1
            elseif initX>0 and initX<=step and initY==step then
                initX=initX-1
            elseif initX==0 and initY<=step then
                initY=initY-1   
            end

            if tmpX>0 and tmpY>0  and tmpY<1202 and tmpX<1202 then
                if findResource(tmpX, tmpY)==true then
                    count=count+1
                    if count>=3 then
                        findFlag=true
                        break
                    end
                end
            end
        end
        if findFlag==true then
            break
        end
        initGrid=initGrid+1
        prevLineGridNums=prevLineGridNums+2
    end

    return findRs
end

function find_rune_boos:createEditBox()
    local function editFiledCallBack(strEventName,pSender)
        if strEventName == "ended" or strEventName == "changed" or strEventName == "return" then
            local text = pSender:getText()
            if text == nil or me.isValidStr(text) == false then
                return 
            end
            
            if me.isPureNumber(text) then
                if me.toNum(text) <= find_rune_boos.MAX_LEVEL then                  
                    self.curLevel = me.toNum(text)
                else
                    showTips("超出上限")
                end
            else
                showTips("请输入有效数字")
            end

            pSender:setText(self.curLevel)
            self.Slider_worker:setPercent(self.curLevel * 100 / self.maxLevel)
        end
    end
    local eb = me.addInputBox(50,32,22,"alliance_alpha_bg.png",editFiledCallBack,cc.EDITBOX_INPUT_MODE_NUMERIC)
    eb:setPosition(-2, 2)
    self.Node_EditBox:addChild(eb)
    return eb
end
