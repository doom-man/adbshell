-- [Comment]
-- jnmo
rechargeGemCell = class("rechargeGemCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
rechargeGemCell.__index = rechargeGemCell
function rechargeGemCell:create(...)
    local layer = rechargeGemCell.new(...)
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
function rechargeGemCell:ctor()
    print("rechargeGemCell ctor")
end
function rechargeGemCell:init()
    print("rechargeGemCell init")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.RECHARGE) then
            self:initList()
        end
    end )
    self.rlist = me.assignWidget(self, "rlist")
    self.rlist:setScrollBarEnabled(false)
    self.ritem = me.assignWidget(self, "ritem")
    self.ritem:setVisible(false)

    self:initList()
    return true
end
function rechargeGemCell:onEnter()
    print("rechargeGemCell onEnter")
    me.doLayout(self, me.winSize)
end
function rechargeGemCell:initList()
    self.rlist:removeAllChildren()
    local temp = { }
    for key, var in pairs(user.recharge) do
        if var.type < 3 then
            table.insert(temp, var)
        end
    end
    for key, var in pairs(temp) do
        local item = self.ritem:clone()
        item:setVisible(true)
        local icon = me.assignWidget(item, "icon")
        local buyBtn = me.assignWidget(item, "buyBtn")
        local text_title_btn = me.assignWidget(buyBtn, "text_title_btn")
        local limit_bg = me.assignWidget(item, "limit_bg")
        local limit = me.assignWidget(item, "limit")
        local give_num = me.assignWidget(item, "give_num")
        local gem_num = me.assignWidget(item, "gem_num")
        local limit_icon = me.assignWidget(item, "limit_icon")
        icon:loadTexture("shangcheng_tubi_zuanshi_" .. var.icon .. ".png", me.localType)
        text_title_btn:setString("￥" .. var.rmb)
        text_title_btn:enableShadow(cc.c4b(0x00, 0x00, 0x00, 0xff), cc.size(-1, -1))  
        me.registGuiClickEvent(buyBtn, function(node)
            payMgr:getInstance():checkChooseIap(var)
            me.setWidgetCanTouchDelay(node, 1)
        end )
        gem_num:setString( me.formatnumberthousands( var.jjgold ))
        limit_icon:setVisible(false)
        limit_bg:setVisible(false)
        if me.toNum(var.limit) > 0 then
            limit_icon:setVisible(true)
            limit_bg:setVisible(true)
            --"额外赠送" ..(var.limitgivegold or 0) .. 
            limit:setString("限购" .. var.limit .. "次")
            give_num:setString("+" ..  me.formatnumberthousands(var.limitgivegold or 0).."元宝")
        elseif me.toNum(var.jjgive) > 0 then
            give_num:setString("+" ..  me.formatnumberthousands(var.jjgive).."元宝")   
        else            
            give_num:setVisible(false)            
        end
        local posX = gem_num:getPositionX()
        give_num:setPositionX(posX + gem_num:getContentSize().width)
        self.rlist:pushBackCustomItem(item)
    end
end
function rechargeGemCell:onEnterTransitionDidFinish()
    print("rechargeGemCell onEnterTransitionDidFinish")
end
function rechargeGemCell:onExit()
    UserModel:removeLisener(self.modelkey)
    print("rechargeGemCell onExit")
end
function rechargeGemCell:close()
    self:removeFromParent()
end

