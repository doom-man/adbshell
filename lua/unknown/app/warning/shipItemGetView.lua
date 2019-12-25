shipItemGetView = class("shipItemGetView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
function shipItemGetView:create(...)
    local layer = shipItemGetView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function shipItemGetView:ctor()
end

function shipItemGetView:onEnter()
end

function shipItemGetView:onExit()
end

function shipItemGetView:init()
    print("shipItemGetView init")
    me.doLayout(self, me.winSize)
    me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )
    --图标
    self.imageItemIcon = me.assignWidget(self, "rune_icon")
    --名称
    self.textItemName = me.assignWidget(self, "Text_rune_name")
    -- 拥有数量
    self.textItemNum = me.assignWidget(self, "Text_rune_num")
    -- 道具获取途径 （说明）
    self.textGetWay = me.assignWidget(self, "text_getway")
    --途径文字1
    local textGetWay1   = me.assignWidget(self, "Text_get1")
    --途径文字2
    local textGetWay2   = me.assignWidget(self, "Text_get2")
    --途径文字3
    local textGetWay3   = me.assignWidget(self, "Text_get3")
   

    local buttonGetWay1 = me.assignWidget(self, "btn_puton1")
    local buttonGetWay2 = me.assignWidget(self, "btn_puton2")
    local buttonGetWay3 = me.assignWidget(self, "btn_puton3")

    local bg1 = me.assignWidget(self,"cell_bg_1")
    local bg2 = me.assignWidget(self,"cell_bg_2")
    local bg3 = me.assignWidget(self,"cell_bg_3")
    buttonGetWay1.getWayType = 1
    buttonGetWay2.getWayType = 2
    buttonGetWay3.getWayType = 3

    local function gotoGetItemCallback (sender)
        local getWayType = sender.getWayType
        if self.selectGetWayCallback then
            self.selectGetWayCallback (getWayType)
        end
        self:removeFromParentAndCleanup(true)
    end
    buttonGetWay1:addClickEventListener(gotoGetItemCallback)
    buttonGetWay2:addClickEventListener(gotoGetItemCallback)
    buttonGetWay3:addClickEventListener(gotoGetItemCallback)

    self.itemGetWay = {
        {textDesc = textGetWay1,bg = bg1,  btnToGet = buttonGetWay1},
        {textDesc = textGetWay2,bg = bg2, btnToGet = buttonGetWay2},
        {textDesc = textGetWay3,bg = bg3, btnToGet = buttonGetWay3},
    }

    return true
end

function shipItemGetView:setGetWayData (getWayData)
    local itemIcon = getWayData.itemIcon or "item_9898.png"
    local itemName = getWayData.itemName or "道具名称"
    local itemNum = getWayData.itemNum or 0
    local showTextGetWay = getWayData.showTextGetWay

    self.imageItemIcon:loadTexture (itemIcon)
    self.textItemName:setString (itemName)
    self.textItemNum:setString ("拥有数量：" .. itemNum)

    if showTextGetWay then
        self.textGetWay:setVisible (true)
    else
        self.textGetWay:setVisible (true)
    end
    local arrGetWay = getWayData.arrGetWay

    for k, v in pairs (self.itemGetWay) do
        if arrGetWay[k] and arrGetWay[k].textDesc then
            v.textDesc:setString (arrGetWay[k].textDesc)
            v.textDesc:setVisible (true) 
            v.bg:setVisible(true)         
            v.btnToGet:setVisible (true)
        else
            v.textDesc:setVisible (false) 
            v.btnToGet:setVisible (false)
            v.bg:setVisible(false)
        end
    end

    self.selectGetWayCallback = getWayData.selectGetWayCallback
end