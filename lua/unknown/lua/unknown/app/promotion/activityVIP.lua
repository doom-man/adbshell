--[Comment]
--jnmo
activityVIP = class("activityVIP",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
activityVIP.__index = activityVIP
function activityVIP:create(...)
    local layer = activityVIP.new(...)
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
function activityVIP:ctor()   
    print("activityVIP ctor") 
    self.mTime = nil;
end
function activityVIP:init()   
    print("activityVIP init")
	me.registGuiClickEventByName(self,"fixLayout",function (node)
     --   self:close()     
    end)   
   -- NetMan:send(_MSG.activityDetail(13)) 
    self.Node_tab = me.assignWidget(self, "Node_tab")
   self.a_v_cell = me.assignWidget(self,"a_v_cell")
   self.a_v_cell:setVisible(false)
   self.a_v_quality = me.assignWidget(self.a_v_cell, "a_v_quality")
   self.a_v_quality:setVisible(false)

    return true
end
function activityVIP:setData(pType)
    self.mType = pType
    local pVIP = me.split(user.activityDetail.cd,",")
    local pDiamond = pVIP[1]
    local pDiscount = pVIP[2]
    local pDiamondLabel = me.assignWidget(self,"up_diamond")
    pDiamondLabel:setString(pDiamond)

    local pDiscountLabel = me.assignWidget(self,"up_discount")
    pDiscountLabel:setString(pDiscount.."%")

    local pTabTable = {}
    for key, var in pairs(user.activityDetail.list) do
        table.insert(pTabTable,var)
    end

    self.Buyht = table.nums(user.activityDetail.gls)
    me.assignWidget(self, "Node_tab"):removeAllChildren()
    self:initList(pTabTable)
    if self.mTime then
       me.clearTimer(self.mTime)
       self.mTime = nil;
    end
    local pTime = me.assignWidget(self,"Text_time")
    pTime:setString(me.formartSecTime(user.activityDetail.time))
    if self.mType == ACTIVITY_ID_VIPTIMEL_SKIP then
       pTime:setVisible(true)
        self.mTime = me.registTimer(-1,function(dt)
            if user.activityDetail.time == 0 then
                me.clearTimer(self.mTime)
                self.mTime = nil

                user.activityDetail.time = 0
            else
                user.activityDetail.time = user.activityDetail.time -1;
                pTime:setString(me.formartSecTime(user.activityDetail.time))
            end                                                                        
        end,1)

    else
       pTime:setVisible(false)
    end

end
function activityVIP:initList(pTable)
    local pNum = #pTable
    if pNum %2 == 0 then
       pNum = pNum/2
    else
       pNum = pNum/2+1
    end
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
        return 839, 219 + 15
    end

    local function tableCellAtIndex(table, idx)       
        local cell = table:dequeueCell()        
        if nil == cell then
            cell = cc.TableViewCell:new()
            for  var = 1,2 do
                local pTag = idx*2+var
                local pVipCell = self.a_v_cell:clone():setVisible(true)
                pVipCell:setTag(var)
                self:setVipCell(pVipCell,pTable[pTag],pTag)               
                local buyBtn = me.assignWidget(pVipCell,"a_v_Button_buy")                                                  
                buyBtn:setTag(pTag)  
                pVipCell:setAnchorPoint(cc.p(0.5, 0))
                pVipCell:setPosition(cc.p(829 / 4 + (var - 1) * 419.5, 15))                                      
                me.registGuiClickEvent(buyBtn,function (node)                  
                       local pTag = me.toNum(node:getTag())

                       if pTag == (self.Buyht +1) then
                           if self.mType == ACTIVITY_ID_VIPTIMEL_SKIP then
                              if user.activityDetail.time == 0 then
                                 showTips("优惠活动已结束")
                              else
                                  payMgr:getInstance():checkChooseIap(user.recharge[pTable[pTag]])
                                  me.setWidgetCanTouchDelay(node,2)
                              end
                           else
                               payMgr:getInstance():checkChooseIap(user.recharge[pTable[pTag]])
                               me.setWidgetCanTouchDelay(node,2)
                           end                                                  
                       end
                end)               
                buyBtn:setSwallowTouches(false) 
                cell:addChild(pVipCell)  
            end                                         
        else            
           for  var = 1, 2  do
               local pTag = idx*2+var
               local pVipCell = cell:getChildByTag(var)
               self:setVipCell(pVipCell,pTable[pTag],pTag)
               local buyBtn = me.assignWidget(pVipCell,"a_v_Button_buy")                                                  
               buyBtn:setTag(pTag)  
             end             
           end       
        return cell
    end
    function numberOfCellsInTableView(table)        
        return pNum
    end

    self.Node_tab:removeAllChildren()
    tableView = cc.TableView:create(cc.size(839, 421))
    tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    tableView:setPosition(cc.p(0, 0))
    tableView:setAnchorPoint(cc.p(0, 0 + 3))
    tableView:setDelegate()
    self.Node_tab:addChild(tableView)
    -- registerScriptHandler functions must be before the reloadData funtion
    tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    tableView:registerScriptHandler(scrollViewDidScroll, cc.SCROLLVIEW_SCRIPT_SCROLL)
    tableView:registerScriptHandler(scrollViewDidZoom, cc.SCROLLVIEW_SCRIPT_ZOOM)
    tableView:registerScriptHandler(tableCellTouched, cc.TABLECELL_TOUCHED)
    tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
    tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)
    tableView:reloadData()
 
end
function activityVIP:setVipCell(pNode,pData,pTag)
    if pData then
       local pDefData = user.recharge[pData]         
            -- 钻石的配置                 
            me.assignWidget(pNode,"Panel_Icon"):removeAllChildren()                     
           local pCfgData = cfg[CfgType.ETC][9017] 
           local pQuality1 = self.a_v_quality:clone():setVisible(true)         -- 品质
           pQuality1:setPosition(cc.p(0,0))     
           pQuality1:loadTexture(getQuality(pCfgData["quality"]), me.localType)
           local picon = me.assignWidget(pQuality1,"a_v_icon")         -- 品质
           picon:loadTexture("shangcheng_tubi_zuanshi_2.png", me.localType)         
           local pNum1 = me.assignWidget(pQuality1,"a_v_num")    -- 道具数量
           pNum1:setString("x"..pDefData.jjgold)   
           me.assignWidget(pQuality1,"Button_item"):setSwallowTouches(false)
           me.registGuiClickEventByName(pQuality1,"Button_item",function ()
                showPromotion(9017,pDefData.jjgold)
           end)    
           me.assignWidget(pNode,"Panel_Icon"):addChild(pQuality1)     
       for key, var in pairs(pDefData.items) do      
            -- 道具的配置
           local pCfgData = cfg[CfgType.ETC][var[1]] 
           local pQuality = self.a_v_quality:clone():setVisible(true)
           pQuality:setPosition(cc.p(115 * (key), 0))   
           pQuality:loadTexture(getQuality(pCfgData["quality"]), me.localType)
           local picon = me.assignWidget(pQuality,"a_v_icon")         -- 品质
           picon:loadTexture(getItemIcon(var[1]), me.localType)         
           local pNum = me.assignWidget(pQuality,"a_v_num")    -- 道具数量
           pNum:setString("x"..var[2])
           me.assignWidget(pQuality,"Button_item"):setSwallowTouches(false)
           me.registGuiClickEventByName(pQuality,"Button_item",function ()
                showPromotion(var[1],var[2])
           end)         
           me.assignWidget(pNode,"Panel_Icon"):addChild(pQuality) 
       end
        local pName = me.assignWidget(pNode,"a_v_name")
        pName:setString("阶段"..pTag)
        pName:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        local pButton = me.assignWidget(pNode,"a_v_Button_buy")
        pButton:setVisible(false)
        local pBuying = me.assignWidget(pNode,"a_v_buying")
        pBuying:setVisible(false)
        local pPrice = me.assignWidget(pButton,"buy_price")
        pPrice:setString("￥"..pDefData.rmb)  
        pPrice:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        if pTag == (self.Buyht +1) then
          self:setButton(pButton,true)
          pButton:setVisible(true)
        elseif pTag > (self.Buyht +1)then 
          self:setButton(pButton,false) 
          pButton:setVisible(true) 
        else
          pButton:setVisible(false)
          me.assignWidget(pNode,"a_v_buying"):setVisible(true)
        end
    end

end
function activityVIP:setButton(button, b)
    button:setBright(b)
    local title = me.assignWidget(button, "buy_price")
    if b then
        
        title:setTextColor(cc.c4b(255, 255, 255, 255))
    else
        title:setTextColor(cc.c4b(182, 182, 182, 255))
    end
    button:setSwallowTouches(true)
    button:setTouchEnabled(b)
end
function activityVIP:update(msg)
    if checkMsg(msg.t, MsgCode.ACTIVITY_INIT_VIEW) then
--        self:setData() 
    elseif checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
        self:setData()
    end
end

function activityVIP:onEnter()
    print("activityVIP onEnter") 
	me.doLayout(self,me.winSize)  
      --发送活动接口
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        self:update(msg)        
    end)
end
function activityVIP:onEnterTransitionDidFinish()
	print("activityVIP onEnterTransitionDidFinish") 
end
function activityVIP:onExit()
    print("activityVIP onExit")  
    UserModel:removeLisener(self.modelkey) -- 删除消息通知  
    me.clearTimer(self.mTime)
end
function activityVIP:close()
    self:removeFromParentAndCleanup(true)
end
