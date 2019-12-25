--[Comment]
--jnmo
sumCostCell = class("sumCostCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
sumCostCell.__index = sumCostCell
function sumCostCell:create(...)
    local layer = sumCostCell.new(...)
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
function sumCostCell:ctor()   
    print("sumCostCell ctor") 
end
function sumCostCell:init()   
    print("sumCostCell init")
    self.Text_time = me.assignWidget(self, "Text_Time")
    self.Image_up_frame = me.assignWidget(self,"Image_up_frame")
 
    return true
end
function sumCostCell:initActivity(id)
    self.activity_id = id
    local data = user.activityPayData[self.activity_id]
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(data.activityId)]
	self.Text_time:setString(me.GetSecTime(data.openDate) .. "-" .. me.GetSecTime(data.endDate))
    self.modelkey = UserModel:registerLisener(function(msg)  -- 注册消息通知
        if checkMsg(msg.t, MsgCode.ACTIVITY_UPDATE_DETAIL) then
            if msg.c.activityId == ACTIVITY_ID_SUMCOST then
                self:setTableView()
            end
        end
    end)
    self.Image_up_frame:loadTexture("huodong_sum_cost_bar.png",me.localType)
    
    self:setTableView()
end
function sumCostCell:setTableView()
    self.listData = user.activityPayData[self.activity_id].list

    local function comp(a, b)
        local priorityA = a.status == 1 and 1 or (a.status == 0 and 2 or 3)
        local priorityB = b.status == 1 and 1 or (b.status == 0 and 2 or 3)
        if priorityA ~= priorityB then
            return priorityA < priorityB
        else
            return a.id < b.id
        end
    end
    table.sort(self.listData,comp)
    local px  ={}
    for key, var in pairs(self.listData) do
        if var.status ~= 2 then 
            table.insert(px,var)
        end
    end
    for key, var in pairs(self.listData) do
        if var.status == 2 then 
            table.insert(px,var)
        end
    end
    local function numberOfCellsInTableView(table)
        return #self.listData
    end

    local function cellSizeForTable(table, idx)
        return 832,116
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
            node:setVisible(true)
        end 
        local tmp = self.listData[me.toNum(idx+1)]
        local Text_plunderNum = me.assignWidget(node,"Text_plunderNum")
        local Image_txt_Label = me.assignWidget(node,"Image_txt_Label")
        Image_txt_Label:loadTexture("huodong_sum_cost_txt.png",me.localType)
        if tmp then
            if tmp.status == 0 then --不能领取
                Text_plunderNum:setString(user.activityPayData[self.activity_id].value.."/"..tmp.id)
                Text_plunderNum:setTextColor(me.convert3Color_("d4cdb9"))
               -- me.assignWidget(node,"Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png",me.localType)
                me.assignWidget(node,"Image_got"):setVisible(false)
                local btn = me.assignWidget(node,"Button_get")
                btn:setVisible(true)
                me.assignWidget(btn, "image_title"):setString("未达成")
                me.setButtonDisable(btn,false)
            elseif tmp.status == 2 then --已经领取过
                Text_plunderNum:setString(user.activityPayData[self.activity_id].value.."/"..tmp.id)
                Text_plunderNum:setTextColor(me.convert3Color_("d4cdb9"))
                --me.assignWidget(node,"Image_panel"):loadTexture("huodong_beijing_fanli_guoqi.png",me.localType)
                me.assignWidget(node,"Image_got"):setVisible(true)
                me.assignWidget(node,"Button_get"):setVisible(false)
            elseif tmp.status == 1 then --能领取
                Text_plunderNum:setString(user.activityPayData[self.activity_id].value.."/"..tmp.id)
                Text_plunderNum:setTextColor(me.convert3Color_("67ff02"))
               -- me.assignWidget(node,"Image_panel"):loadTexture("huodong_beijing_fanli_lingqu.png",me.localType)
                me.assignWidget(node,"Image_got"):setVisible(false)
                local btn = me.assignWidget(node,"Button_get")
                me.registGuiClickEventByName(node,"Button_get",function ()
                    NetMan:send(_MSG.updateActivityDetail(self.activity_id,tmp.id))
                end)
                btn:setVisible(true)                
                me.assignWidget(btn, "image_title"):setString("领取")
                me.setButtonDisable(btn,true)
            end

            local itemPanel = me.assignWidget(node,"Panel_itemIcon")
            itemPanel:removeAllChildren()
            local indexX = 0
            for key, var in pairs(tmp.items) do
                local item = me.assignWidget(self,"Image_itemBg"):clone()
                item:setVisible(true)
                local etc = cfg[CfgType.ETC][me.toNum(var[1])]
                me.assignWidget(item,"Image_itemBg"):loadTexture(getQuality(etc.quality))
                me.assignWidget(item,"Image_item"):loadTexture(getItemIcon(etc.id))
                me.assignWidget(item,"Text_Num"):setString(var[2])
                me.assignWidget(item,"Button_item"):setSwallowTouches(false)
                me.registGuiClickEventByName(item,"Button_item",function ()
                    showPromotion(var[1],var[2])
                end)
                itemPanel:addChild(item)
                item:setAnchorPoint(cc.p(0,0.5))
                item:setPosition(indexX*135,itemPanel:getContentSize().height/2)
                indexX = indexX+1
            end
        end
        return cell
    end
    if self.tableView == nil then
        local Image_table = me.assignWidget(self, "Image_table")
        self.tableView = cc.TableView:create(cc.size(834,422))
        self.tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        self.tableView:setDelegate()
        self.tableView:setPosition(cc.p(3,1))
        Image_table:addChild(self.tableView)
        self.tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
        self.tableView:registerScriptHandler(numberOfCellsInTableView, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
        self.tableView:registerScriptHandler(cellSizeForTable, cc.TABLECELL_SIZE_FOR_INDEX)
        self.tableView:registerScriptHandler(tableCellAtIndex, cc.TABLECELL_SIZE_AT_INDEX)      
    end
    self.tableView:reloadData()   
end

function sumCostCell:onEnter()
    print("sumCostCell onEnter") 
    --if user.UI_REDPOINT.promotionBtn[tostring(ACTIVITY_ID_SUMCOST)] == 1 then
        -- 移除红点
        removeRedpoint(ACTIVITY_ID_SUMCOST)
    --end
	me.doLayout(self,me.winSize)  
end
function sumCostCell:onEnterTransitionDidFinish()
	print("sumCostCell onEnterTransitionDidFinish") 
end
function sumCostCell:onExit()
    print("sumCostCell onExit")  
    UserModel:removeLisener(self.modelkey) -- 删除消息通知  
end
function sumCostCell:close()
    self:removeFromParent()  
end

