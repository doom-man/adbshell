turnplateDetailCell = class("turnplateDetailCell",function(...)
    return cc.CSLoader:createNode(...)
end)
turnplateDetailCell.__index = turnplateDetailCell
function turnplateDetailCell:create(...)
    local layer = turnplateDetailCell.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
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
function turnplateDetailCell:ctor()
    print("turnplateDetailCell:ctor()")
    self.detailData = nil
    self.activityItems = {}
end
function turnplateDetailCell:onEnter()
    print("turnplateDetailCell:onEnter()")
    me.doLayout(self,me.winSize)  
end

function turnplateDetailCell:init()
    print("turnplateDetailCell:init()")
    self.activityItems[#self.activityItems+1] = me.assignWidget(self,"Node_today")
    self.activityItems[#self.activityItems+1] = me.assignWidget(self,"Node_yesterday")
    self.activityItems[#self.activityItems+1] = me.assignWidget(self,"Node_yesterday2")
    self.activityItems[#self.activityItems+1] = me.assignWidget(self,"Node_overDate")
    self.Text_half = me.assignWidget(self,"Text_half")
    self.Text_forever = me.assignWidget(self,"Text_forever")


    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end)
    self.Button_Tips = me.registGuiClickEventByName(self, "Button_Tips",function(node)
         local info = turnplateDetailInfo:create("turnplateDetailInfo.csb")
         info:initWithData(self.detailData.detail)
         me.popLayer(info)
    end)
    return true
end
function turnplateDetailCell:setDetailData(data_)
    self.detailData = data_
end
function turnplateDetailCell:hideInfoBtn()
     self.Button_Tips:setVisible(false)
end
function turnplateDetailCell:close()
    self:removeFromParentAndCleanup(true)
end
function turnplateDetailCell:onEnter()
    print("turnplateDetailCell:onEnter()")
    me.doLayout(self,me.winSize)  
    self.Text_half:setString(self.detailData.sv)
    self.Text_forever:setString(self.detailData.pv)

    local max = 1
    for key, var in pairs(self.detailData.list) do
        me.assignWidget(self.activityItems[me.toNum(var.key)],"Text_activityNum"):setString(var.value)
        if me.toNum(var.key) >= max and me.toNum(var.key) <= 3 then
            max = me.toNum(var.key)
        end
    end
    me.assignWidget(self.activityItems[max],"Image_firstFlag"):setVisible(true)
end
function turnplateDetailCell:onExit()
    print("turnplateDetailCell:onExit()")
end
