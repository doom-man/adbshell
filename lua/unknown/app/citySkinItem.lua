-- [Comment]
-- jnmo
citySkinItem = class("citySkinItem", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return me.assignWidget(arg[1], arg[2]):clone()
    end
end )
citySkinItem.__index = citySkinItem
function citySkinItem:create(...)
    local layer = citySkinItem.new(...)
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
function citySkinItem:ctor()
    print("citySkinItem ctor")
end
function citySkinItem:init()
    print("citySkinItem init")
    self.m_name = me.assignWidget(self, "m_name")
    self.m_di = me.assignWidget(self, "m_di")
    self.Text_state = me.assignWidget(self, "Text_state")
    self.m_time = me.assignWidget(self, "m_time")
    self.m_red = me.assignWidget(self, "m_red")
    self.m_icon = me.assignWidget(self, "m_icon")
    self.m_name_bg = me.assignWidget(self, "m_name_bg")
    self.m_bg = me.assignWidget(self, "m_bg")
    return true
end
function citySkinItem:initWithData(data)
    self.baseData = data
    self.data = data:getDef()
    dump(data)
    local def = data:getDef()
    dump(def)
    local orData = cfg[CfgType.CITY_SKIN][def.typeid]
    self.m_name:setString(def.name)
    if orData.type == 1 then
        if tonumber(def.icon) == 0 then
            self.m_icon:loadTexture(buildIcon(user.centerBuild:getDef()), me.plistType)
        else
            self.m_icon:loadTexture("cityskin" .. def.icon .. "_1.png", me.localType)
        end
    elseif orData.type == 2 then
        self.m_icon:loadTexture("skin" .. def.icon .. ".png", me.localType)
    end
    self.m_time:setVisible(false)
    me.resizeImage(self.m_icon, 137, 119)
    local skindata = data
    me.clearTimer(self.timer)
    if skindata and skindata.status ~= -1 then
        self.m_time:setVisible(true)
        if skindata.duration == -1 then
            self.m_time:setString("永久")
        elseif skindata.duration == 0 then
            self.m_time:setString("失效")
        elseif skindata.duration > 0 then
            local time = skindata.duration
            self.m_time:setString(me.formartSecTime(time))
            self.timer = me.registTimer(time, function(dt)
                time = time - 1
                self.m_time:setString(me.formartSecTime(time))
            end , 1)
            self.m_name:setString("装扮中")            
        end
        if skindata.status == 0 then
            self.Text_state:setString("可装扮")
            self.m_di:setVisible(true)
            self.m_name_bg:setVisible(false)
            me.assignWidget(self,"Image_equip"):setVisible(false)
        elseif skindata.status == 1 then
            self.m_di:setVisible(false)
            self.m_name_bg:setVisible(false)
            me.assignWidget(self,"Image_equip"):setVisible(true)
        end
        me.Helper:normalImageView(self.m_bg)
        me.Helper:normalImageView(self.m_icon)
        
    else
        self.m_name_bg:setVisible(false)
        self.m_di:setVisible(false)
        me.Helper:grayImageView(self.m_bg)
        me.Helper:grayImageView(self.m_icon)
        me.assignWidget(self,"Image_equip"):setVisible(false)
    end
    self:checkRedPoint()
end
-- 221 -267
function citySkinItem:onEnter()
    print("citySkinItem onEnter")
end
function citySkinItem:onEnterTransitionDidFinish()
    print("citySkinItem onEnterTransitionDidFinish")
end
function citySkinItem:checkRedPoint()
    local skinCfg = cfg[CfgType.CITY_SKIN][self.baseData.id]
    local items = me.split(skinCfg.item or "", ",")
    local ihave = false
    for k, v in pairs(items) do
        for key, var in pairs(user.pkg) do
            if tonumber(var.defid) == tonumber(v) then
                ihave = true
            end
        end
    end
    self.m_red:setVisible(ihave)
end
function citySkinItem:onExit()
    print("citySkinItem onExit")
    me.clearTimer(self.timer)
end
function citySkinItem:close()
    self:removeFromParent()
end
