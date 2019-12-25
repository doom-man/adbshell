--[Comment]
--jnmo
StrategyCell = class("StrategyCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
StrategyCell.__index = StrategyCell
function StrategyCell:create(...)
    local layer = StrategyCell.new(...)
    if layer then 
        if layer:init() then 
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
				elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end)            
            return layer
        end
    end
    return nil 
end
function StrategyCell:ctor()   
    print("StrategyCell ctor") 
    self.mTime = nil
end
function StrategyCell:init()   
    print("StrategyCell init")
	
    return true
end
function StrategyCell:setData(pData)
    if pData then
        if self.mTime then
           me.clearTimer(self.mTime)
           self.mTime = nil
        end
        local pConfig = cfg[CfgType.THRONE_STRATEGY][pData.defId]
        local Text_name = me.assignWidget(self,"Text_name")
        Text_name:setString(pConfig.name)
        local pIcon = me.assignWidget(self,"icon")
        pIcon:loadTexture("wci_"..pData.defId..".png",me.plistType)
        local Text_time = me.assignWidget(self,"Text_time")
        me.assignWidget(self,"Image_4"):setVisible(false)
--        local Panel_bg =me.assignWidget(self,"Panel_bg")
--        Panel_bg:removeAllChildren()
--        self.Strategy_bg =  me.createSprite("wangzuo_celv_diban_liang.png")
--        self.Strategy_bg:setPosition(cc.p(0,0))
--        self.Strategy_bg:setAnchorPoint(cc.p(0,0))
--        Panel_bg:addChild(self.Strategy_bg)

        if pData.strgCD > 0  then
           me.graySprite(self.Strategy_bg)
           Text_name:setTextColor(me.convert3Color_("#A9A9A9"))
           self.pStrgCd = pData.strgCD
           me.assignWidget(self,"Image_4"):setVisible(true)
           Text_time:setString(me.formartSecTime(self.pStrgCd))
           self.mTime = me.registTimer(-1, function(dt)
               if self.pStrgCd > 0  then
                   self.pStrgCd = self.pStrgCd - 1
                   Text_time:setString(me.formartSecTime(self.pStrgCd))
               else
                   if self.mTime then
                     me.clearTimer(self.mTime)
                     self.mTime = nil
                   end
                   me.assignWidget(self,"Image_4"):setVisible(false)
                   me.revokeSprite(self.Strategy_bg)
               end                 
           end,1)
        else 
           Text_name:setTextColor(me.convert3Color_("#FFFFFF"))
        end
        local LoadingBar_speed = me.assignWidget(self,"LoadingBar_speed")
        LoadingBar_speed:setPercent(pData.value/pConfig.schedule*100)
        local Text_record = me.assignWidget(self,"Text_record")
        Text_record:setString(pConfig.desc)
    end
end
function StrategyCell:onEnter()
    print("StrategyCell onEnter") 
  
end
function StrategyCell:onEnterTransitionDidFinish()
	print("StrategyCell onEnterTransitionDidFinish") 
end
function StrategyCell:onExit()
    print("StrategyCell onExit")  
    if self.mTime then
        me.clearTimer(self.mTime)
        self.mTime = nil
    end  
end
function StrategyCell:close()
    self:removeFromParentAndCleanup(true)  
end

