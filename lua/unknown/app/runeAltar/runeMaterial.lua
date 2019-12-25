local filterTbl={btn_quality_iorder="品质倒序",
                 btn_quality_rorder="品质顺序",
                 btn_name_iorder="名称倒序",
                 btn_name_rorder="名称顺序",
                 }
runeMaterial = class("runeMaterial",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeMaterial:create(...)
    local layer = runeMaterial.new(...)
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

function runeMaterial:ctor()
    self.netListener = UserModel:registerLisener( function(msg)
        self:onRevMsg(msg)
    end )

    self.arrMTBackpack={}
    self.nowCate = 0
end

function runeMaterial:onEnter()
    
end

function runeMaterial:onExit()
    UserModel:removeLisener(self.netListener)
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
end

function runeMaterial:init()
    
    self.currentItem = me.assignWidget(self, "currentMT")
    self.cailiao={}
    for i=1, 4, 1 do
        local cailiao = me.assignWidget(self, "cailiao"..i)
        table.insert(self.cailiao, cailiao)
    end
    self.clTxt = me.assignWidget(self, "clTxt")
    self.clNumsTxt1 = me.assignWidget(self, "clNumsTxt1")
    self.clNumsTxt2 = me.assignWidget(self, "clNumsTxt2")
    self.btn_heceng_duoge = me.assignWidget(self, "btn_heceng_duoge")
    self.btn_heceng = me.assignWidget(self, "btn_heceng")
    self.btn_heceng_style = me.assignWidget(self, "btn_heceng_style")
    self.btn_heceng:addClickEventListener(handler(self, self.onHecheng))
    self.btn_heceng_duoge:addClickEventListener(handler(self, self.onHechengBatch))
    self.btn_heceng_style:addClickEventListener(handler(self, self.onHechengStyle))

    self.tipsTxt = me.assignWidget(self, "tipsTxt")

    ---条件过滤
    self.nowFilter = "btn_name_rorder"
    local function selectFilter (sender)
        self.nowFilter = sender:getName()
        me.assignWidget(self, "popfilter"):setVisible(false)
        me.assignWidget(self, "pingzhiName"):setString(filterTbl[self.nowFilter])

        self.selectMT=nil
        self.selectMTData=nil
        self:initMaterialList()
    end
    for key, var in pairs(filterTbl) do
        me.assignWidget(self, key):addClickEventListener(selectFilter)
    end
    me.assignWidget(self, "pingzhiName"):setString(filterTbl[self.nowFilter])


    local function onOpenFilterPanel(sender)
        me.assignWidget(self, "popfilter"):setVisible(true)
    end
    me.assignWidget(self, "pingzhiBtn"):addClickEventListener(onOpenFilterPanel)
    me.registGuiClickEventByName(self,"popfilterPanel",function (node)
        local pTouch = node:getTouchBeganPosition()    
        local popfilter = me.assignWidget(self, "popfilter")    
        local pRect = cc.rect(0,0,popfilter:getContentSize().width,popfilter:getContentSize().height)  
        local locationInNode = popfilter:convertToNodeSpace(pTouch) 
        if not cc.rectContainsPoint(pRect, locationInNode) then
            popfilter:setVisible(false)
        end
    end)      

    self.selectMT = nil
    self.selectMTData = nil
    self:initMaterialTable()


    return true
end

function runeMaterial:onHecheng(node, nums)
    local hcCfg = cfg[CfgType.RUNE_MAP][self.selectMTData.defid]
    if hcCfg==nil or hcCfg.destID=='' then
        return
    end

    local hcCfg1 = cfg[CfgType.RUNE_MAP][hcCfg.destID]
    local tmp = string.split(hcCfg1.needItem, ":")
    local haveNums = self:getMtNums(tonumber(tmp[1]))
    local needNums = tonumber(tmp[2])
    if haveNums<needNums then
        showTips("材料不足")
        return
    end

    nums = nums or 1
    NetMan:send(_MSG.Prop_compound(hcCfg.destID ,nums))
    showWaitLayer ()
end

function runeMaterial:onHechengBatch()
    local hcCfg = cfg[CfgType.RUNE_MAP][self.selectMTData.defid]
    if hcCfg==nil or hcCfg.destID=='' then
        return
    end

    local hcCfg1 = cfg[CfgType.RUNE_MAP][hcCfg.destID]
    local tmp = string.split(hcCfg1.needItem, ":")
    local haveNums = self:getMtNums(tonumber(tmp[1]))
    local needNums = tonumber(tmp[2])
    if haveNums<needNums then
        showTips("材料不足")
        return
    end

    local selectView = runeMaterialUse:create("rune/runeMaterialBatchCompose.csb")
    me.runningScene():addChild(selectView, me.MAXZORDER)
    selectView:setData(math.floor(self.selectMTData.count/4), handler(self, self.onHecheng))
    me.showLayer(selectView, "bg")
end
function runeMaterial:onHechengStyle()
    local styleView = runeMaterialStyle:create("rune/runeMaterialStyle.csb")  
    styleView:setData(self.selectMTData)
    me.runningScene():addChild(styleView, me.MAXZORDER)   
    me.showLayer(styleView, "bg")
end

function runeMaterial:onRevMsg(msg)
    if checkMsg(msg.t, MsgCode.BOX_REMAKE) or checkMsg(msg.t, MsgCode.RUNE_COMPOUND_STYLE) then
        if msg.c.id then
            local varCfg = cfg[CfgType.ETC][msg.c.id]
            if varCfg then
                local offset=self.runeTableView:getContentOffset()
                if self.selectMTData and user.materBackpack[self.selectMTData.uid]==nil then
                    self.selectMT=nil
                    self.selectMTData=nil
                end

                self:initMaterialList()
                self.runeTableView:setContentOffset(offset)

                self:onClickMT(self.selectMT)

                disWaitLayer()

                local materCfgId = msg.c.id
                local materBaseCfg = cfg[CfgType.ETC][materCfgId]

                local num = msg.c.num
                local tipStr = "合成成功，获得" .. materBaseCfg.name .. "×" .. num
                showTips (tipStr)
            end
        end
    end
end

function runeMaterial:initMaterialTable()
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
        return 658, 132
    end

    function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()

        if nil == cell then
            cell = cc.TableViewCell:new()
            for  var = 1,5 do
                local pTag = idx*5+var
                local pData = self.arrMTBackpack[pTag]
                if pData and pData~=0 then
                    local leftCell = me.assignWidget(self,"cailiaoItem"):clone():setVisible(true)
                    leftCell:setName('normal'..var)  
                    me.registGuiClickEvent(leftCell, handler(self, self.onClickMT)) 
                    leftCell:setSwallowTouches(false)
                    leftCell:setPosition(cc.p((var-1)*128+14,0))   
                    self:fillCellData(leftCell, pData)  
                    cell:addChild(leftCell)

                    if pTag==1 and self.selectMT==nil then
                        self:onClickMT(leftCell)
                    end
                else
                    local leftCell = me.assignWidget(self,"cailiaoGray"):clone():setVisible(true)  
                    leftCell:setName('gray'..var)  
                    leftCell:setPosition(cc.p((var-1)*128+14,0))     
                    cell:addChild(leftCell)
                end
             end
        else
            for  var = 1, 5  do
                local pTag = idx*5+var
                local pData = self.arrMTBackpack[pTag]
                if pData and pData~=0 then
                    local leftCell = cell:getChildByName('normal'..var)
                    if leftCell~=nil then
                        self:fillCellData(leftCell, pData)
                    else
                        leftCell = me.assignWidget(self,"cailiaoItem"):clone():setVisible(true)
                        leftCell:setName('normal'..var)  
                        me.registGuiClickEvent(leftCell, handler(self, self.onClickMT)) 
                        leftCell:setSwallowTouches(false)
                        leftCell:setPosition(cc.p((var-1)*128+14,0))   
                        self:fillCellData(leftCell, pData)  
                        cell:addChild(leftCell)
                        
                    end
                    if pTag==1 and self.selectMT==nil then
                        self:onClickMT(leftCell)
                    end
                    cell:removeChildByName('gray'..var)
                else
                    local leftCell = cell:getChildByName('gray'..var)
                    if leftCell==nil then
                        leftCell = me.assignWidget(self,"cailiaoGray"):clone():setVisible(true)  
                        leftCell:setName('gray'..var)  
                        leftCell:setPosition(cc.p((var-1)*128+14,0))     
                        cell:addChild(leftCell)
                    end
                    cell:removeChildByName('normal'..var)
                end
            end
        end
        return cell
    end
    function numberOfCellsInTableView(table)
        local num = math.ceil(#self.arrMTBackpack / 5)
        return num
    end

    local tableView = cc.TableView:create(cc.size(658, 538))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setAnchorPoint(cc.p(0, 0))
    tableView:setPosition(cc.p(2, 0))
    tableView:setDelegate()
    me.assignWidget(self, "tbl_node"):addChild(tableView)

    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    self.runeTableView = tableView
  
end

function runeMaterial:fillCellData(leftCell, data)
    local baseData = cfg[CfgType.ETC][data.defid]
    leftCell:loadTexture("fuwen_kuang_pingzhi_"..baseData.quality..".png", me.plistType)
    leftCell["data"]=data
    me.assignWidget(leftCell, "cailiaoIcon"):loadTexture(getItemIcon(data.defid), me.localType)
    me.assignWidget(leftCell, "cailiaoNums"):setString(data.count)
    me.assignWidget(leftCell, "selected"):setVisible(false)
    if self.selectMTData ~= nil and self.selectMTData.uid==data.uid then
        self.selectMT=leftCell
        me.assignWidget(leftCell, "selected"):setVisible(true)
    end

    me.assignWidget(leftCell, "newIcon"):setVisible(false)
    if data.isnew then
        me.assignWidget(leftCell, "newIcon"):setVisible(true)
    end
end

---
-- 右边没有数据
--
function runeMaterial:disableRight(mode)
    self.currentItem:setVisible(false)
    for i=1, 4, 1 do
        local cailiao = self.cailiao[i]
        cailiao:setVisible(false)
    end
    self.clTxt:setVisible(false)
    self.btn_heceng_duoge:setBright(false)
    self.btn_heceng_duoge:setTouchEnabled(false)
    self.btn_heceng:setBright(false)
    self.btn_heceng:setTouchEnabled(false)
    self.btn_heceng_style:setBright(false)
    self.btn_heceng_style:setTouchEnabled(false)

    if mode==1 then
        self.tipsTxt:setString("4个相同的材料，可以合成一个高一阶的同类型的材料")
    elseif mode==2 then
        self.tipsTxt:setString("最高级材料无法合成")    
        self.clTxt:setVisible(true)

        local baseData = cfg[CfgType.ETC][self.selectMTData.defid]
        self.clTxt:setString(baseData.name)

        local cailiao = self.cailiao[1]
        cailiao:loadTexture(getItemIcon(self.selectMTData.defid), me.localType)
        cailiao:setVisible(true)

        self.clNumsTxt1:setString("")
        self.clNumsTxt2:setString("")
    end
end

--点击列表中的材料
function runeMaterial:onClickMT(node)

    if self.selectMT ~= nil then
        me.assignWidget(self.selectMT, "selected"):setVisible(false)
    end

    self.selectMT=node
    me.assignWidget(self.selectMT, "selected"):setVisible(true)
    self.selectMTData = self.selectMT["data"]
    local baseData = cfg[CfgType.ETC][self.selectMTData.defid]
    local hcCfg = cfg[CfgType.RUNE_MAP][self.selectMTData.defid]
    if hcCfg==nil or hcCfg.destID=='' or hcCfg.destID==0 then
        self:disableRight(2)
    else
        self.currentItem:setVisible(true)
        self.btn_heceng_duoge:setBright(true)
        self.btn_heceng_duoge:setTouchEnabled(true)
        self.btn_heceng:setBright(true)
        self.btn_heceng:setTouchEnabled(true)
        self.btn_heceng_style:setBright(true)
        self.btn_heceng_style:setTouchEnabled(true)
        self.clTxt:setVisible(true)
        self.tipsTxt:setString("4个相同的材料，可以合成一个高一阶的同类型的材料")

        local hcCfg1 = cfg[CfgType.RUNE_MAP][hcCfg.destID]
        local tmp = string.split(hcCfg1.needItem, ":")
        tmp[1] = tonumber(tmp[1])
        tmp[2] = tonumber(tmp[2])
        
        local baseData1 = cfg[CfgType.ETC][hcCfg.destID]
        self.currentItem:loadTexture(getItemIcon(hcCfg.destID), me.localType)
        me.assignWidget(self.currentItem, "currentMTName"):setString(baseData1.name)

        self.clTxt:setString(baseData.name)
        self.clNumsTxt2:setString("/"..tmp[2])

        local mtNums = self:getMtNums(tmp[1])
        local imgNums = mtNums
        self.clNumsTxt1:setString(mtNums)
        if mtNums<tmp[2] then
            self.clNumsTxt1:setTextColor(cc.c3b(255, 0, 0))
        else
            self.clNumsTxt1:setTextColor(cc.c3b(9, 241, 60))
            imgNums=tmp[2]
        end

        if me.assignWidget(self.selectMT, "newIcon"):isVisible()==true then
            self.selectMTData.isnew=nil
            me.assignWidget(self.selectMT, "newIcon"):setVisible(false)
        end


        for i=1, imgNums, 1 do
            local cailiao = self.cailiao[i]
            cailiao:loadTexture(getItemIcon(tmp[1]), me.localType)
            cailiao:setVisible(true)
        end
        for i=imgNums+1, 4, 1 do
            local cailiao = self.cailiao[i]
            cailiao:setVisible(false)
        end
    end

end

---
-- 查找指定材料个数
--
function runeMaterial:getMtNums(id)
    local count=0
    for key, var in pairs(user.materBackpack) do
        --print("var.defid = "..var.defid)
        if tonumber(var.defid) == tonumber(id) then
            count=count+var.count
        end
    end
    return count
end

---
-- 初始化背包数据
--
function runeMaterial:setData(nowCate)
    self.nowCate=nowCate
    self.selectMT=nil
    self.selectMTData=nil
    self:initMaterialList()
end
function runeMaterial:initMaterialList()
    self.arrMTBackpack={}
    local etc = cfg[CfgType.ETC]
    for _, v in pairs(user.materBackpack) do
        if self.nowCate==0 or etc[v.defid].quality==self.nowCate then
            table.insert(self.arrMTBackpack, v)
        end
    end
    
    if self.nowFilter=="btn_quality_iorder" then  --品质倒序
        table.sort (self.arrMTBackpack, function (a, b)
            local baseLvA = etc[a.defid].quality
            local baseLvB = etc[b.defid].quality

            return baseLvA > baseLvB
        end)
    elseif self.nowFilter=="btn_quality_rorder" then  --品质顺序
        table.sort (self.arrMTBackpack, function (a, b)
            local baseLvA = etc[a.defid].quality
            local baseLvB = etc[b.defid].quality

            return baseLvA < baseLvB
        end)
    elseif self.nowFilter=="btn_name_iorder" then  --名称倒序
        table.sort (self.arrMTBackpack, function (a, b)
            local baseLvA = a.defid
            local baseLvB = b.defid

            return baseLvA > baseLvB
        end)
    elseif self.nowFilter=="btn_name_rorder" then  --名称顺序
        table.sort (self.arrMTBackpack, function (a, b)
            local baseLvA = a.defid
            local baseLvB = b.defid

            return baseLvA < baseLvB
        end)
    end

    local runeNum = #self.arrMTBackpack
    if runeNum==0 then
        self:disableRight(1)
    end
    if runeNum<25 then
        for k=runeNum+1, 25 do
            table.insert(self.arrMTBackpack, 0)
        end
    end
    self.runeTableView:reloadData()
end