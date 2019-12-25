-- 背包格子 2015-12-1 
warShipBagCell = class("warShipBagCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return me.assignWidget(arg[1],arg[2]):clone()
    end
end )
warShipBagCell.__index = warShipBagCell
function warShipBagCell:create(...)
    local layer = warShipBagCell.new(...)
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
function warShipBagCell:ctor()

end
function warShipBagCell:init()
    
    return true
end
function warShipBagCell:setUI(pData)
    if pData ~= nil then
        local pCfgid = pData["defid"]
        -- 道具的配置Id
        local pCfgData = cfg[CfgType.SHIP_REFIX_SKILL][pCfgid]
        self:loadTexture(getQuality(pCfgData["quality"]), me.localType)
        me.assignWidget(self, "Image_NameBg"):setVisible(true)
        local name = me.assignWidget(self, "Text_Name")
        name:setString(pCfgData.name)
        local pIcon = me.assignWidget(self, "icon")
        -- 图标
        pIcon:loadTexture(getRefitIcon(pCfgid), me.localType)
        pIcon:setVisible(true)
        me.assignWidget(self,"Image_Use"):setVisible(pData.location>0)
    else
        me.assignWidget(self, "icon"):setVisible(false)
        me.assignWidget(self, "Image_NameBg"):setVisible(false)
        me.assignWidget(self, "Image_Use"):setVisible(false)
        self:loadTexture("beibao_kuang_hui.png",me.localType)  
    end
end
getQuality = function (pQuality)
   local pQualityStr = ""
    if pQuality == 1 then
        pQualityStr = "beibao_kuang_hui.png"
        -- 白色
    elseif pQuality == 2 then
        pQualityStr = "beibao_kuang_lv.png"
        -- 绿色
    elseif pQuality == 3 then
        pQualityStr = "beibao_kuang_lan.png"
        -- 蓝色
    elseif pQuality == 4 then
        pQualityStr = "beibao_kuang_zi.png"
        -- 紫色
    elseif pQuality == 5 then
        pQualityStr = "beibao_kuang_cheng.png"
        -- 橙色
    elseif pQuality == 6 then
        pQualityStr = "beibao_kuang_hong.png"
        -- 红色
    end
    return pQualityStr
end
function warShipBagCell:onEnter()
    -- me.doLayout(self,me.winSize)
end
function warShipBagCell:onExit()
end
