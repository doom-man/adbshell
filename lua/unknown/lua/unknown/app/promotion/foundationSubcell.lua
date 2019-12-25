foundationSubcell = class("foundationSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
foundationSubcell.__index = foundationSubcell
function foundationSubcell:create(...)
    local layer = foundationSubcell.new(...)
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

function foundationSubcell:ctor()
    print("foundationSubcell:ctor()")
end
function foundationSubcell:init()
    print("foundationSubcell:init()")
    return true
end
function foundationSubcell:onEnter()  
    me.assignWidget(self, "Panel_item"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(Panel_richText:getContentSize().width/2,Panel_richText:getContentSize().height/2)
        rich:setAnchorPoint(cc.p(0.5,0.5))
        Panel_richText:addChild(rich)
    end
    me.assignWidget(self,"TextAtlas_percent"):setString(user.activityDetail.addPercent)
    me.assignWidget(self,"AtlasLabel_diamond"):setString(user.activityDetail.addDiamond)
    me.assignWidget(self,"Text_recharge"):setString("已充值"..user.activityDetail.chargeNum.."元")
    local Button_recharge = me.assignWidget(self,"Button_recharge")
    if me.toNum(user.activityDetail.chargeNum) >= user.activityDetail.chargeLimit then
        me.setButtonDisable(Button_recharge,false)
    else
        me.setButtonDisable(Button_recharge,true)
        --跳转充值
        me.registGuiClickEvent(Button_recharge,function ()
            me.dispatchCustomEvent("promotionViewclose")
            toRechageShop()           
        end)
    end

    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_FOUNDATION then
                dump(user.activityDetail)
                self:setTableView()
                if user.UI_REDPOINT.payBtn[tostring(ACTIVITY_ID_FOUNDATION)]==1 then
                    self:removeRedPoint()
                end
            end
        end
    end)
    self:setTableView()

    local lastBtn = me.assignWidget(self, "lastBtn")
    me.registGuiClickEvent(lastBtn, function()
        if self.lastData.status == 0 then --已领取
            showTips("已领取")
        elseif self.lastData.status == 2 then 
            showTips("城镇中心"..self.lastData.lv.."级领取")
        else
            NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,self.lastData.lv))
        end
    end)
    me.registGuiClickEventByName(self, "Image_86", function()
        showPromotion(self.lastData.rewarder[1],self.lastData.rewarder[2])
    end)

    if user.UI_REDPOINT.payBtn[tostring(ACTIVITY_ID_FOUNDATION)]==1 then
        self:removeRedPoint()
    end
    me.doLayout(self,me.winSize)
end

function foundationSubcell:setLastButton()
    local lastBtn = me.assignWidget(self, "lastBtn")
    me.assignWidget(lastBtn, "image_title"):setString("城镇中心"..self.lastData.lv.."级领取")
    if self.lastData.status == 0 then --已领取
        me.setButtonDisable(lastBtn,false)
    elseif self.lastData.status == 1 then --可领取
        me.setButtonDisable(lastBtn,true)
    elseif self.lastData.status == 2 then --不可领取
        me.setButtonDisable(lastBtn,false)
    end
end

function foundationSubcell:removeRedPoint()
    local listData = user.activityDetail.dlist
    for _, v in ipairs(listData) do
        if v.status == 1 then
            return
        end
    end
    removeRedpoint(ACTIVITY_ID_FOUNDATION)
end

function foundationSubcell:setTableView()
    self.listData = {}
    
    self.lastData = user.activityDetail.dlist[#user.activityDetail.dlist]

    for key, var in pairs( user.activityDetail.dlist) do
       if var.status~=0 and var.lv~=self.lastData.lv then
         table.insert(self.listData,var)
       end
    end

    for key, var in pairs( user.activityDetail.dlist) do
       if var.status ==0 and var.lv~=self.lastData.lv then
         table.insert(self.listData,var)
       end
    end

    self:setLastButton()

    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 552.09, 106
    end

    local function tableCellAtIndex(table, idx)
        local cell = table:dequeueCell() 
        local node = nil
        if nil == cell then
            cell = cc.TableViewCell:new()
            node = me.assignWidget(self, "Panel_item"):clone()
            cell:addChild(node)
            node:setVisible(true)
        else
            node = me.assignWidget(cell, "Panel_item")
        end
        local tmp = self.listData[me.toNum(idx+1)]
        if tmp then
            me.registGuiClickEventByName(node,"Button_detail",function ()
                showPromotion(tmp.rewarder[1],tmp.rewarder[2])
            end)
            if tmp.rewarder[1] == 9017 then                
                me.assignWidget(node,"Image_icon"):loadTexture("shangcheng_tubi_zuanshi_2.png",me.plistType)
              
            else               
                me.assignWidget(node,"Image_icon"):loadTexture(getItemIcon(tmp.rewarder[1]) ,me.plistType)
               
            end
            me.assignWidget(node,"Text_itemNum"):setString(tmp.rewarder[2])
            me.assignWidget(node,"Text_describe"):setString("个人城镇中心等级达到"..tmp.lv.."级")
            if tmp.status == 0 then --已领取 
                me.assignWidget(node,"Button_get"):setVisible(false)
                me.assignWidget(node,"Image_got"):setVisible(true)
                --me.assignWidget(node,"Image_panel"):loadTexture("huodong_beijing_fanli_guoqi.png",me.localType)
            elseif tmp.status == 1 then --可领取
                --me.assignWidget(node,"Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png",me.localType)
                me.assignWidget(node,"Image_got"):setVisible(false)
                local btn = me.assignWidget(node,"Button_get")
                btn:setVisible(true)
                me.setButtonDisable(btn,true)
                me.registGuiClickEvent(btn,function ()
                    NetMan:send(_MSG.updateActivityDetail(user.activityDetail.activityId,tmp.lv))
                end)
            elseif tmp.status == 2 then --不能领取
                me.assignWidget(node,"Image_got"):setVisible(false)
                local btn = me.assignWidget(node,"Button_get")
                btn:setVisible(true)
                me.setButtonDisable(btn,false)                
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(553,Image_table:getContentSize().height))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setAnchorPoint(cc.p(0.5,0.5))
        self.tableView:setPosition(cc.p(0,0))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()   
end

function foundationSubcell:onExit()
    UserModel:removeLisener(self.modelkey) -- 删除消息通知
end
