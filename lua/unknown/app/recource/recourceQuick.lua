recourceQuick = class("recourceQuick ", function(csb)
    return cc.CSLoader:createNode(csb)
end )
recourceQuick._index = recourceQuick

function recourceQuick:create(csb)
    local layer = recourceQuick.new(csb)
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

function recourceQuick:ctor()

end

function recourceQuick:init()
    self.addSpeedTime = me.assignWidget(self, "addSpeedTime")
    self.listView = me.assignWidget(self, "ListView_3")
    self.cell = me.assignWidget(self, "cell")
    self.tipsTxt = me.assignWidget(self, "tipsTxt")

    me.assignWidget(self, "Text_Title"):setString("一健使用")

    -- 注册点击事件
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_cacle", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "okBtn", function(node)
        if table.nums( self.serverData ) > 0 then 
            NetMan:send(_MSG.resQuickItemUse(self.serverData))
            showWaitLayer()
        else
            showTips("未使用任何道具")
        end
    end )

    return true
end

function recourceQuick:setData(data,spareResNums, resName, mParent)
    self.listView:removeAllItems()
    self.data = data
    self.serverData={}
    self.mParent=mParent
    self.spareResNums=spareResNums

    local nums=0
    for key, var in pairs(self.data) do
        local cell=self.cell:clone():setVisible(true)
        item = BackpackCell:create("backpack/backpackcell.csb")
        var.defid=var.data.defid
        var.count=1
        item:setScale(0.55)
        item:setUI(var)  
        item:setAnchorPoint(0, 0)   
        item:setPosition(8, 5)  
        me.assignWidget(item, "num_bg"):setVisible(false)

        me.assignWidget(cell,"txt1"):setString(var.data:getDef().name)
        me.assignWidget(cell,"txt2"):setString("已拥有："..var.data.count)
        me.assignWidget(cell,"fastTimeTxt"):setString("消耗："..var.useCount)
        cell:addChild(item)
        self.listView:pushBackCustomItem(cell)
        nums=nums+var.useCount*var.useEffect
        table.insert(self.serverData,{id=var.data.defid, num=var.useCount})
    end
    me.assignWidget(self, "addSpeedTime"):setString(nums..resName)

    self.totalNums = nums
    if nums>spareResNums then
        self.tipsTxt:setString("使用后可补足本次消耗")
        self.tipsTxt:setTextColor(cc.c3b(169, 147, 121))
    else
        self.tipsTxt:setString("使用后仍不能补足本次消耗")
        self.tipsTxt:setTextColor(cc.c3b(108, 159, 74))
    end
end

function recourceQuick:update(msg)
    if checkMsg(msg.t, MsgCode.ROLE_BACKPACK_QUICK_ITEM_USE)  then
        if self.totalNums>self.spareResNums then
            self.mParent:close()
        end
        self:close()
    end
end
function recourceQuick:onEnter()
    print("recourceQuick:onEnter()")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self,me.winSize)  
end

function recourceQuick:onExit()
    print("recourceQuick:onExit()")
    UserModel:removeLisener(self.modelkey)
end

function recourceQuick:close()
    self:removeFromParentAndCleanup(true)
end

