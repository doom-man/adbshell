expedLoadBar = class("expedLoadBar", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
expedLoadBar.__index = expedLoadBar
function expedLoadBar:create(...)
    local layer = expedLoadBar.new(...)
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
function expedLoadBar:ctor()
    print("expedLoadBar ctor")
    self.maxTime = 0
    self.curTime = 0
    self.Text_time = nil
end
function expedLoadBar:init()
    print("expedLoadBar init")
    self.loadbar = me.assignWidget(self, "timeBar")
    self.Text_time = cc.Label:createWithSystemFont("1", "", 20)
    self.Text_time:enableOutline(cc.c3b(0,0,0),1)    
    self:addChild(self.Text_time)   
    return true
end
function expedLoadBar:initHeroCell(pHero)
  local idx = 0
  local heroNode = cc.Node:create()
  local hsize
  for key,var in pairs(pHero) do 
    local def = cfg[CfgType.ETC][var.id]
    if def.useType == 10 then --英雄
        local hero = heroCell:create(self,"heroCell")
        hsize = hero:getContentSize()
        hero:setHeroData(def, var.level)
        hero:setPosition(cc.p(hsize.width / 2 + (hsize.width + 2)*idx, hsize.height/2))
        hero:setVisible(true)
        heroNode:addChild(hero)
        idx = idx + 1
    end
   end
   if idx > 0 then 
       heroNode:setContentSize(cc.size(idx*hsize.width + (idx-1)*2, 0))
       heroNode:setAnchorPoint(0.5,0.5)
       heroNode:setPosition(cc.p(self.loadbar:getContentSize().width / 2 ,self.loadbar:getContentSize().height+1))
       self.loadbar:addChild(heroNode)   
   end 
end
function expedLoadBar:initPetCell(petId)
      local pet = heroCell:create(self,"heroCell")
      pet:setPetData(petId)
      pet:setPosition(cc.p(-pet:getContentSize().width / 2 + 15,self.loadbar:getContentSize().height / 2))
      pet:setVisible(true)
      self.loadbar:addChild(pet)
end
-- 最大时间 ptime剩余时间
function expedLoadBar:initWithTime(data,max, ptime)
    print("initWithTime")
    self.maxTime = max
    self.curTime = ptime
    print(" self.maxTime ".. self.maxTime .." - "..self.curTime)
    self.Text_time:setString(me.formartSecTime(math.floor(ptime)))
    self.loadbar:setPercent(100 *(max - self.curTime) / max)
    local last = math.floor(ptime)
    self.m_timer = me.registTimer(ptime, function(dt)
        if self.curTime - dt >= 0 then
            self.curTime = self.curTime - dt
            local nowt = math.floor(self.curTime)
            if last ~= nowt then
                last = nowt
                self.Text_time:setString(me.formartSecTime(last))
                self.loadbar:setPercent(100 *(max - self.curTime) / max)
            end
        else
            self.curTime = 0
            self.Text_time:setString(me.formartSecTime(0))
            self.loadbar:setPercent(100)
        end
    end)
    if data.hero then
       self:initHeroCell(data.hero)
    end    
    -- if user.dressPetId and user.uid == data.uid and data.m_Status ~= EXPED_STATE_ARCH  then 
    --    self:initPetCell(user.dressPetId)
    -- end
    if data.pet and data.pet > 0 then
       self:initPetCell(data.pet)
    end
end
function expedLoadBar:onEnter()

end
function expedLoadBar:onEnterTransitionDidFinish()

end
function expedLoadBar:onExit()
    me.clearTimer(self.m_timer)
end

