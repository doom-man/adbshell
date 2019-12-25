--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--endregion
saodangResult = class("saodangResult", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
saodangResult.__index = saodangResult

function saodangResult:create(...)
    local layer = saodangResult.new(...)
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

function saodangResult:ctor()
end

function saodangResult:init()
    self.itemNode = me.assignWidget(self, "itemNode")
    self.normalJianli = me.assignWidget(self, "normalJianli")
    self.listView = me.assignWidget(self, "ListView")
    self.listView:setScrollBarPositionFromCornerForVertical(cc.p(2, 2))
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        me.DelayRun(function (args)
           self:close()
        end)
    end)
    return true
end

function saodangResult:setData(data)
    self.listView:removeAllItems()
    self.data = data
    if self.data.itemList==nil then return end

    -- local msg1 = me.assignWidget(self, "msg1")
    -- local msg2 = me.assignWidget(self, "msg2")
    -- local msg3 = me.assignWidget(self, "msg3")
    -- local levelNums = me.assignWidget(self, "levelNums")
    -- local battleNums = me.assignWidget(self, "battleNums")
    -- local powerNums = me.assignWidget(self, "powerNums")

    -- powerNums:setString(data.power)
    -- battleNums:setString(data.battleNum)
    -- levelNums:setString(data.currentLv)

    -- local w1=powerNums:getPositionX()+powerNums:getContentSize().width+2
    -- msg1:setPositionX(w1)
    -- w1=msg1:getPositionX()+msg1:getContentSize().width+2
    -- battleNums:setPositionX(w1)
    -- w1=battleNums:getPositionX()+battleNums:getContentSize().width+2
    -- msg2:setPositionX(w1)
    -- w1=msg2:getPositionX()+msg2:getContentSize().width+2
    -- levelNums:setPositionX(w1)
    -- w1=levelNums:getPositionX()+levelNums:getContentSize().width+2
    -- msg3:setPositionX(w1)
    local node_rich = me.assignWidget(self, "node_rich")
    node_rich:removeAllChildren()
    local tempStr = string.format("<txt0016,C19E61>本次扫荡消耗&<txt0016,E1D5B1>%s&<txt0016,C19E61>点体力，发生&<txt0016,E1D5B1>%s&<txt0016,C19E61>场战斗，扫荡至&<txt0016,E1D5B1>%s&<txt0016,C19E61>关&",
        data.power, data.battleNum, data.currentLv)
    local richTxt = mRichText:create(tempStr)
    richTxt:setAnchorPoint(cc.p(0.5, 0.5))
    richTxt:setPosition(cc.p(0, 0))
    node_rich:addChild(richTxt)

    local normalJianli = me.assignWidget(self, "normalJianli")
    local w = 50
    table.sort(self.data.itemList, function(a, b)
        if a[1] > b[1] then
            return true
        end
    end)
    for key, var in ipairs(self.data.itemList) do
        if (key-1)%4==0 then
            w = 50
            normalJianli = self.normalJianli:clone():setVisible(true)
            self.listView:pushBackCustomItem(normalJianli)
        end
        local item = self.itemNode:clone():setVisible(true)
        local txt = me.assignWidget(item, "numsTxt")
        txt:setString("+"..var[2])
        local icon = me.assignWidget(item, "itemNode")
        icon:loadTexture(getItemIcon(var[1]))
        normalJianli:addChild(item)
        me.registGuiClickEventByName(item,"itemNode",function ()
            showPromotion(tonumber(var[1]),var[2])
        end) 
        local w1=0
        if tonumber(var[2])>100 then
            me.resizeImage(icon, 45, 45)
            w1=35
            txt:setPositionX(44)
        else
            me.resizeImage(icon, 55, 55)
            w1=55
            txt:setPosition(50, 25)
        end
        item:setPosition(w, 22)
        w=w+w1+txt:getPositionX()+txt:getContentSize().width
    end
end

function saodangResult:onEnter()
    me.doLayout(self,me.winSize)
end

function saodangResult:onExit()
    print("saodangResult:onExit()")
end

function saodangResult:close()
    self:removeFromParentAndCleanup(true)
end

