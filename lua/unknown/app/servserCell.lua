servserCell = class("servserCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
servserCell.__index = servserCell
function servserCell:create(...)
    local layer = servserCell.new(...)
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
function servserCell:ctor()
    self.sid = nil 
    self.curSelectSoldierNum = 0
end
function servserCell:init()
    self.Image_recom = me.assignWidget(self, "Image_recom")
    self.Image_new = me.assignWidget(self, "Image_new")
    self.Text_serverName = me.assignWidget(self, "Text_serverName")
    me.registGuiClickEventByName(self,"Image_1",function (node)
        self.callBack(self.sdata.sid)        
    end)
    me.assignWidget(self, "Image_1"):setSwallowTouches(false)
    return true
end
function servserCell:initWithData(sdata,cb_)
    self.sdata = sdata
    if me.toNum(sdata.status) == 1 then--(1：新服，2：推荐服，3：推荐和新服)
        self.Image_recom:setVisible(false)
        self.Image_new:setVisible(true)
    elseif me.toNum(sdata.status) == 2 then
        self.Image_recom:setVisible(true)
        self.Image_new:setVisible(false)
    elseif  me.toNum(sdata.status) ==3 then
        self.Image_recom:setVisible(true)
        self.Image_new:setVisible(true)
    else
        self.Image_recom:setVisible(false)
        self.Image_new:setVisible(false)
    end
    if  tonumber( sdata.state ) <= 0  then
        self.Text_serverName:setString(sdata.name.."(维护中)")
    else
    end
    self.Text_serverName:setString(sdata.name)
    self.callBack = cb_
end
function servserCell:onEnter()
end
function servserCell:onExit()
end
function servserCell:close()
end

