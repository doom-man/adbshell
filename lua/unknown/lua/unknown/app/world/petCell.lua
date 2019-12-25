petCell = class("petCell",function (...)   
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end    
end)
petCell.__index = petCell
function petCell:create(...)
    local layer = petCell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then 
                    layer:enterTransitionFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function petCell:ctor()   
    print("petCell ctor")
    self.petData = nil 
end
function petCell:init()   
    print("petCell init")
   self.petBtn = me.assignWidget(self,"petBtn")
   self.quality = me.assignWidget(self,"quality")
   self.petBtn:setSwallowTouches(false)

    return true
end
function petCell:getBuildData()
    return self.itemData
end


function petCell:initWithData(petData,num)
   self.add = me.assignWidget(self,"add")
   if self.add:isVisible() then 
     self.add:stopAllActions()
     self.add:setColor(cc.c3b(255,255,255))
     self.add:setVisible(false)
   end    
   self.petData = petData
   local petIcon = me.assignWidget(self,"petIcon")
   local petNum = me.assignWidget(self,"petNum")
   local numBg = me.assignWidget(self,"numBg")
   
   self.quality:loadTexture(self:getQuality(petData.quality),me.localType)
   self.quality:setVisible(true)

   petNum:setString(num)
   petIcon:loadTexture(getItemIcon(petData.id),me.plistType)
   if not petIcon:isVisible() then 
     petIcon:setVisible(true)
   end
   if not numBg:isVisible() then 
     numBg:setVisible(true)
   end
  -- petIcon:setPosition(cc.p(self.quality:getContentSize().width / 2,0))
  -- petIcon:ignoreContentAdaptWithSize(true)
end

function petCell:getQuality(pQuality)
    local pQualityStr = "beibao_kuang_hui.png"
    if pQuality == 1 then
        pQualityStr = "beibao_kuang_hui.png"
        -- 灰色
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

function petCell:onEnter()
  
  print("petCell onEnter")
end
function petCell:enterTransitionFinish()

end

function petCell:onExit()
print("petCell onExit")    
end


