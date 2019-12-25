kingdomView_foundation_given = class("kingdomView_foundation_given", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
kingdomView_foundation_given.__index = kingdomView_foundation_given
function kingdomView_foundation_given:create(...)
    local layer = kingdomView_foundation_given.new(...)
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
function kingdomView_foundation_given:ctor()
    print("kingdomView_foundation_given:ctor()")
end
function kingdomView_foundation_given:init()
    self.Panel_cells =me.assignWidget(self,"Panel_cells")
    self.givenRes = {}
    self.Image_input = me.assignWidget(self,"Image_input")
    self.Node_res = me.assignWidget(self,"Node_res")
    self.Button_comfirm = me.assignWidget(self,"Button_comfirm")
    me.registGuiClickEvent(me.assignWidget(self,"Button_alliance"),function ()
        NetMan:send(_MSG.getListMember())
    end)
    me.registGuiClickEvent(self.Button_comfirm,function ()
        if self.givenRes[1]<=0 and self.givenRes[2] <=0 and self.givenRes[3] <=0 and self.givenRes[4] <=0 then
            showTips("没有可赏赐资源")
        elseif me.isValidStr(self.msgEb:getText()) == false then
            showTips("请输入玩家名")
        else
            if user.kingdom_OfficerData.kingId == user.uid then --国王本人才能赏赐
                NetMan:send(_MSG.kingdom_given_item(self.msgEb:getText(),self.givenRes[1],self.givenRes[2],self.givenRes[3],self.givenRes[4]))
            else
                showTips("只有国王才有权利分配!")
            end
        end
    end)
    me.registGuiClickEvent(me.assignWidget(self,"close"),function (node)
        self:close()
    end)

    self.msgEb = me.addInputBox(self.Image_input:getContentSize().width, self.Image_input:getContentSize().height, 26,nil,msgEbCallFunc,cc.EDITBOX_INPUT_MODE_ANY,"请输入名字")
    self.msgEb:setFontColor(cc.c3b(212,205,185))
    self.msgEb:setMaxLength(15)
    self.msgEb:setAnchorPoint(0,0)
    self.Image_input:addChild(self.msgEb)

    return true
end
function kingdomView_foundation_given:close()
    UserModel:removeLisener(self.modelkey)
    self:removeFromParentAndCleanup(true)
end
function kingdomView_foundation_given:update(msg)
    if checkMsg(msg.t, MsgCode.MSG_FAMILY_INIT_MEMBER_LIST) then
        me.tableClear(self.memberList)
        self.memberList = {}
        for key, var in pairs(msg.c.list) do
            if me.toNum(user.uid) ~= me.toNum(var.uid) then
                self.memberList[#self.memberList+1]  = {["uid"] = var.uid,["name"] = var.name}
            end
        end
        self:openFamilyList()
    elseif checkMsg(msg.t, MsgCode.KINGDOM_GIVEN_ITEM) then
        self:close()
    end
end
function kingdomView_foundation_given:onEnter()
    me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener(function(msg)
        -- 注册消息通知
        self:update(msg)
    end ,"kingdomView_foundation_given")
    self:setResItem()
end
function kingdomView_foundation_given:onEnterTransitionDidFinish()
end
function kingdomView_foundation_given:onExit()
    print("kingdomView_foundation_given:onExit()")
end
function kingdomView_foundation_given:setResItem()
    print("kingdomView_foundation_given:setResItem !! ")
    local res_icon = {}
    res_icon[#res_icon+1] = "gongyong_tubiao_liangshi.png"
    res_icon[#res_icon+1] = "gongyong_tubiao_mucai.png"
    res_icon[#res_icon+1] = "gongyong_tubiao_shitou.png"
    res_icon[#res_icon+1] = "gongyong_tubiao_jingbi.png"
    
    self.res_maxNum = {}
    self.res_maxNum[#self.res_maxNum+1] = user.kingdon_foundationData.food
    self.res_maxNum[#self.res_maxNum+1] = user.kingdon_foundationData.wood
    self.res_maxNum[#self.res_maxNum+1] = user.kingdon_foundationData.stone
    self.res_maxNum[#self.res_maxNum+1] = user.kingdon_foundationData.gold

    local function sliderEvent(sender, eventType)
        if eventType == ccui.SliderEventType.percentChanged then
            local percent = sender:getPercent() / 100
            local tag = sender:getTag()
            local curNum = math.floor(percent*self.res_maxNum[tag])
            me.assignWidget(sender:getParent(),"Text_workNum"):setString(curNum)
            self.givenRes[tag] = curNum
        elseif eventType == ccui.SliderEventType.slideBallUp then
            if self.res_maxNum[sender:getTag()] <= 0 then
                sender:setPercent(0)
            end
        end
    end

    self.items = {}
    for var = 1, 4 do
        self.items[var] = me.assignWidget(self.Node_res,"Panel_cell_res"):clone()
        self.items[var]:setTag(var)
        self.items[var]:setVisible(true)
        self.Panel_cells:addChild(self.items[var])
        self.items[var]:setPosition(cc.p(5,223-(me.toNum(var)-1)*70))
        me.assignWidget(self.items[var],"Image_res_icon"):loadTexture(res_icon[me.toNum(var)],me.localType)
        me.assignWidget(self.items[var],"Slider_worker"):addEventListener(sliderEvent)
        me.assignWidget(self.items[var],"Slider_worker"):setTag(var)
        me.assignWidget(self.items[var],"btn_add"):setTag(var)
        me.assignWidget(self.items[var],"btn_reduce"):setTag(var)
        me.registGuiClickEvent(me.assignWidget(self.items[var],"btn_add"),function (node)
            local tag = node:getTag()
            self.givenRes[tag] = self.givenRes[tag]+1
            if self.givenRes[tag] >= self.res_maxNum[tag] then
                self.givenRes[tag] = self.res_maxNum[tag]
            end
            if self.res_maxNum[tag] <= 0 then
                me.assignWidget(self.items[tag],"Slider_worker"):setPercent(0)
            else
                me.assignWidget(self.items[tag],"Slider_worker"):setPercent(self.givenRes[tag]/self.res_maxNum[tag]*100)
            end
            me.assignWidget(self.items[tag],"Text_workNum"):setString(self.givenRes[tag])
        end)

        me.registGuiClickEvent(me.assignWidget(self.items[var],"btn_reduce"),function (node)
            local tag = node:getTag()
            self.givenRes[tag] = self.givenRes[tag]-1
            if self.givenRes[tag] <= 0 then
                self.givenRes[tag] = 0
            end
            if self.res_maxNum[tag] <= 0 then
                me.assignWidget(self.items[tag],"Slider_worker"):setPercent(0)
            else
                me.assignWidget(self.items[tag],"Slider_worker"):setPercent(self.givenRes[tag]/self.res_maxNum[tag]*100)
            end
            me.assignWidget(self.items[tag],"Text_workNum"):setString(self.givenRes[tag])
        end)

        local tmpRes = math.min(1, self.res_maxNum[var])
        me.assignWidget(self.items[var],"Text_workNum"):setString(tmpRes)
        self.givenRes[#self.givenRes+1] = tmpRes
        if self.res_maxNum[var] <= 0 then
            me.assignWidget(self.items[var],"Slider_worker"):setPercent(0)
        else
            me.assignWidget(self.items[var],"Slider_worker"):setPercent(tmpRes/self.res_maxNum[var]*100)
        end
    end
end

function kingdomView_foundation_given:openFamilyList()
    if self.layout == nil then
        self.layout = ccui.Layout:create() 
        self.layout:setContentSize(cc.size(me.winSize.width,me.winSize.height))
        self.layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        self.layout:setBackGroundColor(cc.c3b(0,0,0))
        self.layout:setBackGroundColorOpacity(165)
        self.layout:setAnchorPoint(cc.p(0,0))
        self.layout:setPosition(cc.p(0,0))
        self.layout:setSwallowTouches(true)  
        self.layout:setTouchEnabled(true)
        self:addChild(self.layout,me.MAXZORDER)
    end
    local list = me.assignWidget(self, "Panel_list"):clone()
    self.layout:addChild(list,me.MAXZORDER)
    list:setVisible(true)
    list:setAnchorPoint(cc.p(0.5,0.5))
    list:setPosition(cc.p(me.winSize.width/2,me.winSize.height/2))

    local function closeList()
        self.tableView:removeFromParent()
        self.tableView= nil
        self.layout:removeFromParent()
        self.layout = nil
    end
    me.registGuiClickEvent(me.assignWidget(list,"close_0"),function (node)
        closeList()
    end)

    me.registGuiTouchEvent(self.layout,function (node,event)
        if event ~= ccui.TouchEventType.ended then
            return
        end 
        closeList()
    end)

   local function cellSizeForTable(table, idx)
        return 394, 77
    end
    function numberOfCellsInTableView(table)
        return #self.memberList
    end
    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            local item = me.assignWidget(self,"Panel_cell"):clone()
            item:setVisible(true)
            item:setAnchorPoint(cc.p(0,0))
            item:setPosition(cc.p(0,0))
            cell:addChild(item)  
        end
        if self.memberList[idx+1] then
            me.assignWidget(cell,"Text_cell_name"):setString(self.memberList[idx+1].name)
        else
            __G__TRACKBACK__("idx = "..idx .." is  nil !!!! ")
        end
        
        return cell
    end
    local function tableCellTouched(table, cell)    
        local data = self.memberList[cell:getIdx()+1]
        self.officerName = data.name
        self.msgEb:setText(self.officerName)
        me.DelayRun(function ()
            self.tableView:removeFromParent()
            self.tableView= nil
            self.layout:removeFromParent()
            self.layout = nil
        end,0.1)
    end

    if self.tableView == nil then
        self.tableView = cc.TableView:create(cc.size(403,471))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:setPosition(0,0)
        self.tableView:setAnchorPoint(cc.p(0,0))
        self.tableView:setDelegate()
        me.assignWidget(self.layout,"Panel_table"):addChild(self.tableView)
        self.tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    end
    self.tableView:reloadData()
end