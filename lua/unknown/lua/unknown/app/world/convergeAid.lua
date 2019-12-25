--[Comment]
--jnmo
convergeAid = class("convergeAid",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
convergeAid.__index = convergeAid
function convergeAid:create(...)
    local layer = convergeAid.new(...)
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
function convergeAid:ctor()   
    print("convergeAid ctor") 
end
function convergeAid:init()   
    print("convergeAid init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function convergeAid:setPoint(cp,pNumArmy,pMaxArmy)
    self.cp = cp
    self.mMaxArmy = pMaxArmy - pNumArmy
    local pLoadingBar = me.assignWidget(self,"LoadingBar_army")
    pLoadingBar:setPercent(pNumArmy/pMaxArmy*100)

    local pArmynumLabel = me.assignWidget(self,"Text_2")
    pArmynumLabel:setString(pNumArmy.."/"..pMaxArmy)
    me.registGuiClickEventByName(self,"Button_cancel",function (node)
        self:close()     
    end)  
    
    local pButton_confirm =  me.registGuiClickEventByName(self,"Button_confirm",function (node)
      --  pWorldMap:showconverge(cc.p(user.x, user.y),cc.p(self.cp.x, self.cp.y),TEAM_ARMY_DEFENS,0,0) 
      if pMaxArmy > pNumArmy then
         ConvergeStrong(self.cp,TEAM_ARMY_DEFENS,self.mMaxArmy,0)
      else       
            showTips("援军已达到上限，无法派遣援军")        
      end
      self:close() 
    end) 
    if pMaxArmy == 0 then
       self:setButton(pButton_confirm,false)
    else
       self:setButton(pButton_confirm,true)
    end 
end
function convergeAid:setButton(button, b)
    button:setBright(b)
    button:setSwallowTouches(b)
    button:setTouchEnabled(b)
    if b then
        button:setTitleColor(me.convert3Color_("#ffffff"))
    else
        button:setTitleColor(me.convert3Color_("#767676"))
    end
end
function convergeAid:onEnter()
    print("convergeAid onEnter") 
	me.doLayout(me.assignWidget(self,"Panel_7"),me.winSize)  
end
function convergeAid:onEnterTransitionDidFinish()
	print("convergeAid onEnterTransitionDidFinish") 
end
function convergeAid:onExit()
    print("convergeAid onExit")    
end
function convergeAid:close()
    self:removeFromParentAndCleanup(true)  
end
