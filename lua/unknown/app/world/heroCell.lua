--出征携带英雄和宠物
heroCell = class("heroCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
heroCell.__index = heroCell
function heroCell:create(...)
    local layer = heroCell.new(...)
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
function heroCell:ctor()  
  self.quality = me.assignWidget(self,"heroCell")
  self.icon = me.assignWidget(self,"icon") 
end
function heroCell:init()   
    print("heroCell:init")
    return true
end

--[[
  starLv      -- 英雄星级
--]]
function heroCell:setHeroData(data, starLv)
    self.quality:loadTexture(self:getHeroQuality(data.quality),me.localType)
    self.icon:loadTexture(getItemIcon(data.id),me.plistType)

    -- 星星
    for i, v in ipairs(self.starList or {}) do
      v:removeFromParent()
    end
    self.starList = {}
    local starWidth = 15
    local startX = self:getContentSize().width / 2 + (starLv % 2 == 0 and -starWidth / 2 or 0)
    for i = 1, starLv do
      local img_star = ccui.ImageView:create()
      img_star:loadTexture("rune_star1.png", me.localType)
      local x = startX + (-1)^i * math.ceil((i - 1) / 2) * starWidth
      local y = 40
      img_star:setPosition(cc.p(x, y))
      img_star:setScale(0.5)
      self:addChild(img_star)
      table.insert(self.starList, img_star)
    end
end
function heroCell:setPetData(petId)
   self.quality:setContentSize(cc.size(24,24))
   self.icon:setContentSize(cc.size(24,24))
   self.icon:setPosition(cc.p(self.quality:getContentSize().width / 2,self.quality:getContentSize().height / 2))
   self.quality:loadTexture(self:getPetQuality(cfg[CfgType.ETC][petId].quality),me.localType)
   self.icon:loadTexture(getItemIcon(petId),me.plistType)
end
function heroCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function heroCell:onExit()  
end
function heroCell:getHeroQuality(pQuality)
      local pQualityStr = ""
      if pQuality == 1 then
       pQualityStr = "kaogu_kuang_yingxiong_bai.png"        -- 白色
      elseif pQuality == 2 then
       pQualityStr = "kaogu_kuang_yingxiong_lv.png"         -- 绿色
      elseif pQuality == 3 then
       pQualityStr = "kaogu_kuang_yingxiong_lan.png"        -- 蓝色
      elseif pQuality == 4 then
       pQualityStr = "kaogu_kuang_yingxiong_zi.png"         -- 紫色
      elseif pQuality == 5 then
       pQualityStr = "kaogu_kuang_yingxiong_cheng.png"      -- 橙色
      elseif pQuality == 6 then
       pQualityStr = "kaogu_kuang_yingxiong_hong.png"       -- 红色
      else
       pQualityStr = "kaogu_kuang_yingxiong_bai.png" 
      end
      return pQualityStr
end

function heroCell:getPetQuality(pQuality)
      local pQualityStr = ""
      if pQuality == 1 then
       pQualityStr = "kaogu_kuang_congwu_bai.png"        -- 白色
      elseif pQuality == 2 then
       pQualityStr = "kaogu_kuang_congwu_lv.png"         -- 绿色
      elseif pQuality == 3 then
       pQualityStr = "kaogu_kuang_congwu_lan.png"        -- 蓝色
      elseif pQuality == 4 then
       pQualityStr = "kaogu_kuang_congwu_zi.png"         -- 紫色
      elseif pQuality == 5 then
       pQualityStr = "kaogu_kuang_congwu_cheng.png"      -- 橙色
      elseif pQuality == 6 then
       pQualityStr = "kaogu_kuang_congwu_hong.png"       -- 红色
      else
       pQualityStr = "kaogu_kuang_congwu_bai.png" 
      end
      return pQualityStr
end

