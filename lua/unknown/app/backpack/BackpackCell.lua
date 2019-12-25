-- 背包格子 2015-12-1 
BackpackCell = class("BackpackCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end )
BackpackCell.__index = BackpackCell
function BackpackCell:create(...)
    local layer = BackpackCell.new(...)
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
function BackpackCell:ctor()

end
function BackpackCell:init()

    return true
end
function BackpackCell:setUI(pData, pTag)
    if pData ~= nil then
        local pCfgid = pData["defid"]
        -- 道具的配置Id
        local pCfgData = cfg[CfgType.ETC][pCfgid]
        local pQuality = me.assignWidget(self, "Image_quality")
        -- 品质
        pQuality:setVisible(true)
        pQuality:loadTexture(self:getQuality(pCfgData["quality"]), me.localType)
        pQuality:setVisible(true)
        me.assignWidget(self, "num_bg"):setVisible(true)
        local pNum = me.assignWidget(self, "label_num")
        -- 道具数量
        pNum:setString(pData["count"])
        local pOrderStr = pCfgData["showtxt"]
        -- 数量级
        local pOrderBg = me.assignWidget(self, "Upper_bg")
        if pOrderStr ~= nil then
            pOrderBg:setVisible(true)
            local pOrderLabel = me.assignWidget(self, "Upper_num")
            pOrderLabel:setString(pOrderStr)
        else
            pOrderBg:setVisible(false)
        end
        local pIcon = me.assignWidget(self, "Goods_Icon")
        -- 图标
        pIcon:loadTexture("item_" .. pCfgData["icon"] .. ".png", me.localType)
        pIcon:setVisible(true)
    else
        me.assignWidget(self, "Goods_Icon"):setVisible(false)
        -- 图标
        me.assignWidget(self, "num_bg"):setVisible(false)
        -- 数量背景
        me.assignWidget(self, "Upper_bg"):setVisible(false)
        -- 数量级背景
        me.assignWidget(self, "Image_quality"):setVisible(false)
        -- 品质
    end
end
function BackpackCell:getIconStr(pId)

end

function BackpackCell:getQuality(pQuality)
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
function BackpackCell:onEnter()
    -- me.doLayout(self,me.winSize)
end
function BackpackCell:onExit()
end
