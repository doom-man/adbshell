-- [Comment]
-- jnmo
defSoldierTechCell = class("defSoldierTechCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return me.assignWidget(arg[1], arg[2]):clone()
    end
end )
defSoldierTechCell.__index = defSoldierTechCell
function defSoldierTechCell:create(...)
    local layer = defSoldierTechCell.new(...)
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
function defSoldierTechCell:ctor()
    print("defSoldierTechCell ctor")
end
function defSoldierTechCell:init()
    print("defSoldierTechCell init")
    self.Text_Tech_Name = me.assignWidget(self, "Text_Tech_Name")
    self.Text_Tech_Name:enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(2, -2))  
    self.Image_Lock_bg = me.assignWidget(self, "Image_Lock_bg")
    self.Image_Lock = me.assignWidget(self, "Image_Lock")
    self.Image_UnLock = me.assignWidget(self, "Image_UnLock")
    self.Image_bar = me.assignWidget(self, "Image_bar")
    self.pro_bg = me.assignWidget(self, "pro_bg")
    self.Text_Lock = me.assignWidget(self, "Text_Lock")
    self.Button_QH = me.registGuiClickEventByName(self, "Button_QH", function(node)
         local data = cfg[CfgType.ARMYTECH][tonumber(self.val.id)]
         if data.next and data.next > 0 then
             local levelup = defSoldierTechLevelUpLayer:create("defSoldierTechLevelUpLayer.csb")
             levelup:initWithData(self.idx,self.val,self.vdata)
             me.popLayer(levelup)
         else
            showTips("已经达到最大等级")
         end
    end )
    self.choose = me.assignWidget(self, "choose")
    self.evt = me.RegistCustomEvent("defSoldierTechCell_choose", function(evt)
        self.choose:setVisible(evt._userData == self.idx)
        if tonumber(self.val.unlock) == 1 and evt._userData == self.idx then
            self.Button_QH:setVisible(true)
            
        else
            self.Button_QH:setVisible(false)
            
        end
        --[[
        if evt._userData == self.idx  then
            self:loadTexture("guardtech_item_bg.png", me.localType)
        else
            self:loadTexture("guardtech_item_bg1.png", me.localType)
        end
        ]]
    end )

    return true
end
function defSoldierTechCell:initWithData(val, idx, max, vdata)
    self.idx = idx
    self.val = val
    self.vdata = vdata
    --dump(val)
    local data = cfg[CfgType.ARMYTECH][tonumber(val.id)]
    self.Text_Tech_Name:setString(data.name .. " Lv." .. data.level)
    self.Button_QH:setVisible(false)
    if idx == 1 then
        self.Image_bar:setVisible(false)
    else
        self.Image_bar:setVisible(true)
    end
    self.Image_Lock:ignoreContentAdaptWithSize(true)
    if tonumber(val.unlock) == 1 then
        -- 已解锁
        self.Image_Lock:setVisible(false)     
        self.Image_UnLock:setVisible(true)
        self.Text_Lock:setVisible(false)
        me.Helper:normalImageView(self) 
        me.Helper:normalImageView(self.pro_bg)
    elseif tonumber(val.unlock) == 0 then
        me.Helper:grayImageView(self)
        me.Helper:grayImageView(self.Image_Lock)
        me.Helper:grayImageView(self.pro_bg)    
        self.Image_Lock:setVisible(true)     
        self.Image_UnLock:setVisible(false)
        self.Text_Lock:setString("领主" .. data.unlock .. "级解锁")
        self.Text_Lock:setVisible(true)
        self.Text_Tech_Name:setTextColor(cc.c3b(174, 174, 174))
    end
    me.assignWidget(self,"redpoint"):setVisible(val.red)
    if idx > 1 then
        local techdata = user.guard_tech[idx - 1]
        if techdata then
            if tonumber(techdata.unlock) == 1 then
                me.assignWidget(self.Image_bar, "Image_47"):setVisible(true)
                --self.Image_bar:loadTexture("guard_loading.png", me.localType)
            elseif tonumber(techdata.unlock) == 0 then
                --self.Image_bar:loadTexture("guard_loading_bg.png", me.localType)
                me.assignWidget(self.Image_bar, "Image_47"):setVisible(false)
            end
        end
    end
    data.glass = string.gsub(data.glass,';','|')
    local descs = me.split(data.glass, "|")
    local height_idx = 1
    local height = 26
    local val = me.split(data.desc, "|")
    --dump(vdata)
    if descs then
        self.pro_bg:removeAllChildren()
        for key, var in pairs(descs) do
            local desc_cell = me.assignWidget(self, "Text_Tech_Pro_Clone"):clone()
            desc_cell:setVisible(true)
            local pro = me.assignWidget(desc_cell, "pro")
            local ps = me.split(var, ":")
            desc_cell:setString(val[key])
            pro:setPositionX(desc_cell:getContentSize().width)         
            if tonumber(vdata[ps[1]].isPercent) == 1 then
                if tonumber(ps[2]) < 0 then
                    pro:setString( ps[2]*100 .. "%") 
                else
                    pro:setString("+" .. ps[2]*100 .. "%")  
                end
            else
                if tonumber(ps[2]) < 0 then
                    pro:setString( ps[2])
                else    
                    pro:setString("+" .. ps[2])
                end
            end
            self.pro_bg:addChild(desc_cell)
            desc_cell:setPosition(30, 6 * height-height_idx * height)
            height_idx = height_idx + 1

            if self.val.unlock == 0 then
                desc_cell:setTextColor(cc.c3b(174, 174, 174))
                pro:setTextColor(cc.c3b(174, 174, 174))
            end
        end
        self.pro_bg:setContentSize(cc.size(284, 6 * height))
        me.doLayout(self.pro_bg, cc.size(284, 6 * height))
    end
end
function defSoldierTechCell:onEnter()
    print("defSoldierTechCell onEnter")
end
function defSoldierTechCell:onEnterTransitionDidFinish()
    print("defSoldierTechCell onEnterTransitionDidFinish")
end
function defSoldierTechCell:onExit()
    print("defSoldierTechCell onExit")
    me.RemoveCustomEvent(self.evt)
end
function defSoldierTechCell:close()
    self:removeFromParent()
end
