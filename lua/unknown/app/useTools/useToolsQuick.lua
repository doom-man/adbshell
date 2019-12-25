useToolsQuick = class("useToolsQuick ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
useToolsQuick._index = useToolsQuick

function useToolsQuick:create(csb)
    local layer = useToolsQuick.new(csb)
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

function useToolsQuick:ctor()

end

function useToolsQuick:init()
    self.addSpeedTime = me.assignWidget(self, "addSpeedTime")
    self.listView = me.assignWidget(self, "ListView_3")
    self.cell = me.assignWidget(self, "cell")
    self.tipsTxt = me.assignWidget(self, "tipsTxt")

    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_cacle", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "okBtn", function(node)
        if table.nums( self.serverData ) > 0 then 
            NetMan:send(_MSG.buildQuickItem(self.bid, 0, 0, self.serverData))
            showWaitLayer()
        else
            showTips("未使用任何道具")
        end
    end )

    return true
end

function useToolsQuick:setData(data,freeTime,spraeTime, bid)
    self.listView:removeAllItems()
    self.data = data
    self.bid=bid
    self.serverData={}

    local times=0
    for key, var in pairs(self.data) do
        local cell=self.cell:clone():setVisible(true)
        item = BackpackCell:create("backpack/backpackcell.csb")
        var.defid=var.data.defid
        var.count=1
        item:setScale(0.55)
        item:setUI(var)  
        item:setAnchorPoint(0, 0)   
        item:setPosition(13, 12.5)  
        me.assignWidget(item, "num_bg"):setVisible(false)

        me.assignWidget(cell,"txt1"):setString(var.data:getDef().name)
        me.assignWidget(cell,"txt2"):setString("已拥有："..var.data.count)
        me.assignWidget(cell,"fastTimeTxt"):setString("消耗："..var.useCount)
        cell:addChild(item)
        self.listView:pushBackCustomItem(cell)
        times=times+var.useCount*var.useEffect
        table.insert(self.serverData,{id=var.data.defid, num=var.useCount})
    end
    me.assignWidget(self, "addSpeedTime"):setString("总计使用："..me.formartSecTime(times))

    if freeTime==0 then
        if times>spraeTime then
            self.tipsTxt:setString("加速后，超出队列总时间")
            self.tipsTxt:setTextColor(cc.c3b(169, 147, 121))
        else
            self.tipsTxt:setString("加速后，距队列完成还剩："..me.formartSecTime(spraeTime-times))
            self.tipsTxt:setTextColor(cc.c3b(108, 159, 74))
        end
    else
        if times>spraeTime then
            self.tipsTxt:setString("加速后可免费完成")
            self.tipsTxt:setTextColor(cc.c3b(169, 147, 121))
        else
            self.tipsTxt:setString("加速后，距可免费还剩："..me.formartSecTime(spraeTime-times))
            self.tipsTxt:setTextColor(cc.c3b(108, 159, 74))
        end
    end
end

function useToolsQuick:update(msg)
    if checkMsg(msg.t, MsgCode.CITY_QUICK_ITEM)  then
        self:close()
    end
end
function useToolsQuick:onEnter()
    print("useToolsQuick:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self,me.winSize)  
end

function useToolsQuick:onExit()
    print("useToolsQuick:onExit()")
    if self.schid then
        me.Scheduler:unscheduleScriptEntry(self.schid)    
        self.schid = nil
    end
    UserModel:removeLisener(self.modelkey)
end

function useToolsQuick:close()
    self:removeFromParentAndCleanup(true)
end

