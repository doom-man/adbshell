useToolsCellView = class("useToolsCellView ", function(csb)
    return  me.assignWidget( cc.CSLoader:createNode(csb),"Panel_cell"):clone()
end )

useToolsCellView._index = useToolsCellView
function useToolsCellView:create(csb)
    local layer = useToolsCellView.new(csb)
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

function useToolsCellView:ctor()
    self.cellData = nil
    self.btnCB = nil
end

function useToolsCellView:init()
    self.Image_itemBg = me.assignWidget(self, "Image_itemBg")
    
    self.Button_item = me.assignWidget(self, "Button_item")
    local function btnTouchEvent(node)
        self:btnItemOnClicked()
    end
    self.Button_item:addClickEventListener(btnTouchEvent)
    --self.Button_item:addTouchEventListener(btnTouchEvent)
    self.Button_item:setSwallowTouches(false)

    self.Image_item = me.assignWidget(self, "Image_item")
    self.Text_Num = me.assignWidget(self, "Text_Num")
    self.Text_itemName = me.assignWidget(self, "Text_itemName")
    self.Image_light = me.assignWidget(self, "Image_light")
    self.Image_light:setVisible(false)
    return true
end

function useToolsCellView:onEnter()
end

function useToolsCellView:onExit()
end

function useToolsCellView:setItemInfo(data)
    self.cellData = data

    if self.cellData then
       def = cfg[CfgType.ETC][me.toNum(self.cellData.defid)]
       self.Text_Num:setString(self.cellData.count)
       self.Text_itemName:setString(def.name)
       me.fixFontWidth(self.Text_itemName,130)
       self.Image_item:loadTexture("item_"..def.icon..".png")
       self.Image_itemBg:loadTexture(getQuality(def["quality"]), me.localType)
    end
end

function useToolsCellView:getItemData()
    return self.cellData
end

function useToolsCellView:setLightStatus(status)
    self.Image_light:setVisible(status)
    if status then
        return self.cellData
    end
end

function useToolsCellView:setBtnCallBack(func_)
    self.btnCB = func_
end

function useToolsCellView:btnItemOnClicked()
    self:setLightStatus(true)
    if self.btnCB then
        self.btnCB(self.cellData.index)
    end
end