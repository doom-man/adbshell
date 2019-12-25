-- [Comment]
-- jnmo
serverTaskCell = class("serverTaskCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
serverTaskCell.__index = serverTaskCell
function serverTaskCell:create(...)
    local layer = serverTaskCell.new(...)
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
function serverTaskCell:ctor()
    print("serverTaskCell ctor")
end
function serverTaskCell:init()
    print("serverTaskCell init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    self.list = me.assignWidget(self, "list")
    self.Text_Title_A = me.assignWidget(self, "Text_Title_A")
    self.gift_item = me.createNode("gift_item.csb")
    self.gift_item:retain()
    return true
end
function serverTaskCell:initByMsg(msg)
    self.Text_Title_A:setString(msg.c.name)
    local tmp = me.assignWidget(self, "cell_bar")
    local tmp_gift = me.assignWidget(self, "cell_gift")
    local tmp_rank = me.assignWidget(self, "cell_rank")
    local cell_bar = tmp:clone()
    local Text_Title = me.assignWidget(cell_bar, "Text_Title")
    local desc = me.assignWidget(cell_bar, "desc")
    Text_Title:setString("目标")
    desc:setString(msg.c.desc)
    self.list:pushBackCustomItem(cell_bar)
    cell_bar = tmp:clone()
    local Text_Title = me.assignWidget(cell_bar, "Text_Title")
    local desc = me.assignWidget(cell_bar, "desc")
    if msg.c.process == 1 then
        Text_Title:setString("剩余时间")
        desc:setString(me.formartSecTime(msg.c.time / 1000))
        local xtime = msg.c.time
        if xtime == -1 then
            desc:setString("永久")
        else
        self.timer = me.registTimer(-1,function (dt)
               xtime =  xtime - dt*1000
               desc:setString(me.formartSecTime(xtime/1000))
        end,1)
        end
    elseif msg.c.process == 2 then
        Text_Title:setString("达成时间")
        desc:setString(me.GetInSecTime(msg.c.time / 1000))
    elseif msg.c.process == 3 then
        Text_Title:setString("结束时间")
        desc:setString(me.GetInSecTime(msg.c.time / 1000))
    end
    self.list:pushBackCustomItem(cell_bar)
    if msg.c.nameList then
        cell_bar = tmp:clone()
        local Text_Title = me.assignWidget(cell_bar, "Text_Title")
        local desc = me.assignWidget(cell_bar, "desc")
        Text_Title:setString("达成联盟")
        desc:setString(msg.c.nameList)
        self.list:pushBackCustomItem(cell_bar)
    end
    local itemCell = me.assignWidget(self.gift_item, "Image_itemBg")
    local function item_call(node)
        showPromotion(node.itemid, node.itemnum)
    end
    if me.isValidStr(msg.c.reward) then
        local cell_gift = tmp_gift:clone()
        local gift = me.assignWidget(cell_gift, "gift")
        local Text_Title = me.assignWidget(cell_gift, "Text_Title")
        if msg.c.stype == 1 then
            Text_Title:setString("全服奖励")
        elseif msg.c.stype == 3 then
            Text_Title:setString("排行奖励")
        elseif msg.c.stype == 2 then
            Text_Title:setString("联盟奖励")
        end
        local reward = me.split(msg.c.reward, ",")
        for key, var in pairs(reward) do
            local data = me.split(var, ":")
            local item = itemCell:clone()
            local Image_item = me.assignWidget(item, "Image_item")
            local Text_Num = me.assignWidget(item, "Text_Num")
            local Image_13 = me.assignWidget(item, "Image_13")
            local Image_shxiao = me.assignWidget(item, "Image_shxiao")
            Image_item:loadTexture(getItemIcon(data[1]), me.localType)
            Text_Num:setString(data[2])
            item:setVisible(true)
            Image_shxiao:setVisible(msg.c.process == 3)
            item:setPosition(key * 105 - 30, 40)
            gift:addChild(item)
            item.itemid = data[1]
            item.itemnum = data[2]
            me.registGuiClickEvent(item, item_call)
        end
        self.list:pushBackCustomItem(cell_gift)
    end
    if msg.c.list then
        local cell_rank = tmp_rank:clone()
        local tem_cell = me.assignWidget(self, "rank_cell")
        self.list:pushBackCustomItem(cell_rank)

        for key, var in pairs(msg.c.list) do
            local r = tem_cell:clone()
            r:setVisible(true)
            local Text_rank = me.assignWidget(r, "Text_rank")
            local Text_aName = me.assignWidget(r, "Text_aName")
            local Text_fight = me.assignWidget(r, "Text_fight")
            local Text_item2 = me.assignWidget(r, "Text_item2")
            local Text_item1 = me.assignWidget(r, "Text_item1")
            local Image_rank = me.assignWidget(r, "Image_rank")
            local Image_item1 = me.assignWidget(r, "Image_item1")
            local Image_item2 = me.assignWidget(r, "Image_item2")
            me.assignWidget(r, "bg"):setVisible(key%2==0)
            if var.rank == 1 then
                Text_rank:setVisible(false)
                Image_rank:setVisible(true)
                Image_rank:loadTexture("paihang_diyiming.png", me.localType)
            elseif var.rank == 2 then
                Text_rank:setVisible(false)
                Image_rank:setVisible(true)
                Image_rank:loadTexture("paihang_dierming.png", me.localType)
            elseif var.rank == 3 then
                Text_rank:setVisible(false)
                Image_rank:setVisible(true)
                Image_rank:loadTexture("paihang_disanming.png", me.localType)
            else
                Text_rank:setVisible(true)
                Text_rank:setString(var.rank)
                Image_rank:setVisible(false)
            end
            Text_aName:setString(var.name)
            Text_fight:setString(var.value)
            Image_item1:loadTexture(getItemIcon(var.rw[1][1], me.localType))
            Image_item2:loadTexture(getItemIcon(var.rw[2][1], me.localType))
            Text_item2:setString(var.rw[2][2])
            Text_item1:setString(var.rw[1][2])
            self.list:pushBackCustomItem(r)
        end
    end
    if me.isValidStr(msg.c.unlock) then
        local cell_gift = tmp_gift:clone()
        local gift = me.assignWidget(cell_gift, "gift")
        local Text_Title = me.assignWidget(cell_gift, "Text_Title")
        Text_Title:setString("功能开启")
        local reward = me.split(msg.c.unlock, ",")
        for key, var in pairs(reward) do
            local data = me.split(var, ":")
            local item = itemCell:clone()
            local Image_item = me.assignWidget(item, "Image_item")
            local Text_Num = me.assignWidget(item, "Text_Num")
            local Image_13 = me.assignWidget(item, "Image_13")
            local Image_shxiao = me.assignWidget(item, "Image_shxiao")
            Image_item:loadTexture(getItemIcon(data[1]), me.localType)
            Text_Num:setString(data[2])
            item:setVisible(true)
            Image_shxiao:setVisible(msg.c.process == 3)
            item:setPosition(key * 105 - 30, 40)
            gift:addChild(item)
            item.itemid = data[1]
            item.itemnum = data[2]
            me.registGuiClickEvent(item, item_call)
        end
        self.list:pushBackCustomItem(cell_gift)
    end
end
function serverTaskCell:onEnter()
    print("serverTaskCell onEnter")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        self:update(msg)
    end )
    me.doLayout(self, me.winSize)

end
function serverTaskCell:update(msg)
    if checkMsg(msg.t, MsgCode.WORLD_TASK_NAME_VIEW) then
        self:initByMsg(msg)

    end
end
function serverTaskCell:onEnterTransitionDidFinish()
    print("serverTaskCell onEnterTransitionDidFinish")
end
function serverTaskCell:onExit()
    print("serverTaskCell onExit")
    UserModel:removeLisener(self.modelkey)
    self.gift_item:release()
    me.clearTimer(self.timer)
end
function serverTaskCell:close()
    self:removeFromParent()
end
