-- [Comment]
-- jnmo
warshipBreakView = class("warshipBreakView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
warshipBreakView.__index = warshipBreakView
function warshipBreakView:create(...)
    local layer = warshipBreakView.new(...)
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
function warshipBreakView:ctor()
    print("warshipBreakView ctor")
end
function warshipBreakView:init()
    print("warshipBreakView init")
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "btn_takeoff", function(node)
        NetMan:send(_MSG.msg_ship_refit_break(self.data.id,nil,false))
        self:close()
    end )
    self.Image_Qua = me.assignWidget(self, "Image_Qua")
    self.Image_icon = me.assignWidget(self, "Image_icon")
    self.list = me.assignWidget(self, "list")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Text_level = me.assignWidget(self, "Text_level")
    self.list = me.assignWidget(self, "list")
    
    return true
end
function warshipBreakView:initWithData(data)
    self.data = data
    dump(self.data)
    local pCfgData = cfg[CfgType.SHIP_REFIX_SKILL][data.defid]
    self.Image_Qua:loadTexture(getQuality(pCfgData["quality"]), me.localType)
    self.Image_icon:ignoreContentAdaptWithSize(true)
    self.Text_Name:setString(pCfgData.name)
    self.Image_icon:loadTexture(getRefitIcon(data.defid), me.localType)
    self.Text_level:setString("Lv.".. pCfgData.level)
    self.list:removeAllChildren()
    local width_list = 400
    local height_list = 360
    local sph = 10
    local index = 0
    local h = 0
    local m = 4
    if pCfgData.decompose then
        local ds = me.split(pCfgData.decompose, ",")
        local num = #ds
        for key, var in pairs(ds) do
            local is = me.split(var, ":")
            local item = me.assignWidget(self, "cailiaoItem"):clone()
            local cailiaoIcon = me.assignWidget(item, "cailiaoIcon")
            local cailiaoNums = me.assignWidget(item, "cailiaoNums")
            cailiaoIcon:loadTexture(getItemIcon(tonumber(is[1])), me.localType)
            cailiaoNums:setString(is[2])
            self.list:addChild(item)
            local iSize = item:getContentSize()
            local spw = math.floor((width_list - iSize.width * m) /(m + 1))
            local i = 0
            if num % m ~= 0 then
                i = 1
            end
            local height =(math.floor(num / m) + i) *(iSize.height + sph)
            if height < height_list then
                height = height_list
            end
            item:setPosition((iSize.width + spw) *(index % m + 1) - iSize.width / 2,
            height - math.floor(index / m) *(iSize.height + sph) - iSize.height / 2 - sph)
            index = index + 1
            self.list:setInnerContainerSize(cc.size(width_list, height))
        end
    end
end
function warshipBreakView:onEnter()
    print("warshipBreakView onEnter")
    me.doLayout(self, me.winSize)
end
function warshipBreakView:onEnterTransitionDidFinish()
    print("warshipBreakView onEnterTransitionDidFinish")
end
function warshipBreakView:onExit()
    print("warshipBreakView onExit")
end
function warshipBreakView:close()
    self:removeFromParent()
end
