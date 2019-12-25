-- [Comment]
-- jnmo
warshipAutoBreakView = class("warshipAutoBreakView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipAutoBreakView.__index = warshipAutoBreakView
function warshipAutoBreakView:create(...)
    local layer = warshipAutoBreakView.new(...)
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
function warshipAutoBreakView:ctor()
    print("warshipAutoBreakView ctor")
end
function warshipAutoBreakView:init()
    print("warshipAutoBreakView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    local num = 6
    self.cboxs = { }
    for var = 1, num do
        self.cboxs[var] = me.assignWidget(self, "c" .. var)
    end
    me.registGuiClickEventByName(self, "Button_takeoff", function(node)
        self.choosedata = { }
        local ask = false
        for var = 1, num do
            if self.cboxs[var]:isSelected() then
                table.insert(self.choosedata, var)
                if var >= 5 then
                    ask = true
                end
            end
        end
        if ask then
            me.showMessageDialog("你的选择中存在高品质改装，是否确认分解？", function(rev)
                if rev == "ok" then
                    NetMan:send(_MSG.msg_ship_refit_break(nil, self.choosedata, true))
                end
            end )
        else
            NetMan:send(_MSG.msg_ship_refit_break(nil, self.choosedata, true))
        end
    end )

    return true
end
function warshipAutoBreakView:initWithData()
    self.chooseitem = { }
    for var = 1, 6 do
        local numx = 0
        local pUse = user.shipRefixBagData
        for k, v in pairs(pUse) do
            local pCfgData = cfg[CfgType.SHIP_REFIX_SKILL][v.defid]
            print(pCfgData.level,pCfgData.quality,var)
            if tonumber( pCfgData.level) == 1 and tonumber(pCfgData.quality) == var and v.location==0 then
                numx = numx + 1
            end
        end
        me.assignWidget(self.cboxs[var], "Text_Nums"):setString("(" .. numx .. ")")
    end
end
function warshipAutoBreakView:onEnter()
    print("warshipAutoBreakView onEnter")
    me.doLayout(self, me.winSize)
end
function warshipAutoBreakView:onEnterTransitionDidFinish()
    print("warshipAutoBreakView onEnterTransitionDidFinish")
end
function warshipAutoBreakView:onExit()
    print("warshipAutoBreakView onExit")
end
function warshipAutoBreakView:close()
    self:removeFromParent()
end
