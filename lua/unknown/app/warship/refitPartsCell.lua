-- [Comment]
-- jnmo
refitPartsCell = class("refitPartsCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return me.assignWidget(arg[1], arg[2]):clone()
    end
end )
refitPartsCell.__index = refitPartsCell
function refitPartsCell:create(...)
    local layer = refitPartsCell.new(...)
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
function refitPartsCell:ctor()
    print("refitPartsCell ctor")
end
function refitPartsCell:init()
    print("refitPartsCell init")
    self.Image_icon = me.assignWidget(self, "Image_icon")

    self.Text_NotRefit = me.assignWidget(self, "Text_NotRefit")
    self.Text_Name = me.assignWidget(self, "Text_Name")
    self.Text_desc = me.assignWidget(self, "Text_desc")
    self.Image_Name_bg = me.assignWidget(self, "Image_Name_bg")
    self.Button_Info = me.registGuiClickEventByName(self, "Button_Info", function(node)
          local info = refitPartsInfo:create("shipPartsInfo.csb")
          info:initPartsInfo(self.data,self.shipId,self.idx)
          me.popLayer(info)
    end )
    self.Button_Refit = me.registGuiClickEventByName(self, "Button_Refit", function(node)
          NetMan:send(_MSG.ship_refit_bag(self.shipId,self.idx))  
          
    end )
    return true
end
function refitPartsCell:initWithData(data, idx,shipId)
    self.data = data
    self.shipId = shipId
    self.idx = idx
    if self.data.id == 0 then
        self.Image_icon:setVisible(false)
        self.Text_NotRefit:setVisible(true)
        self.Image_Name_bg:setVisible(false)
        self.Text_NotRefit:setString("未改装")
        self.Text_desc:setVisible(false)
        self.Button_Info:setVisible(false)
        self.Button_Refit:setVisible(true)
    elseif self.data.id == -1 then
        self.Image_icon:setVisible(false)
        self.Image_Name_bg:setVisible(false)
        self.Text_NotRefit:setVisible(true)
        self.Text_NotRefit:setString("突破" ..(idx - 1 ) .. "次解锁")
        self.Text_desc:setVisible(false)
        self.Button_Info:setVisible(false)
        self.Button_Refit:setVisible(false)
    else
        self.Image_Name_bg:setVisible(true)
        self.Text_NotRefit:setVisible(false)
        local curDef = cfg[CfgType.SHIP_REFIX_SKILL][self.data.defid]
        self.Text_Name:setString(curDef.name)
        self.Text_desc:setString(curDef.desc)
        self.Text_desc:setVisible(true)
        self.Button_Info:setVisible(true)
        self.Button_Refit:setVisible(false)
        self.Image_icon:loadTexture(getRefitIcon(self.data.defid), me.localType)
        self.Image_icon:setVisible(true)
        
    end
end
function refitPartsCell:onEnter()
    print("refitPartsCell onEnter")
end
function refitPartsCell:onEnterTransitionDidFinish()
    print("refitPartsCell onEnterTransitionDidFinish")
end
function refitPartsCell:onExit()
    print("refitPartsCell onExit")
end
function refitPartsCell:close()
    self:removeFromParent()
end
