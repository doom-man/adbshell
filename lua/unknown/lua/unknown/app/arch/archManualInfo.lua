--[Comment]
--jnmo
archManualInfo = class("archManualInfo",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
archManualInfo.__index = archManualInfo
function archManualInfo:create(...)
    local layer = archManualInfo.new(...)
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
function archManualInfo:ctor()   
    print("archManualInfo ctor") 
end
function archManualInfo:init()   
    print("archManualInfo init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    return true
end
function archManualInfo:initWithData(data)
   local pEtcData = cfg[CfgType.ETC][data[1]]   
   me.assignWidget(self,"Text_tech_name"):setString(pEtcData.name)
   if data[2] == 0 then
        me.assignWidget(self,"Text_tech_pro"):setString("图鉴未激活")
   else
        me.assignWidget(self,"Text_tech_pro"):setString("图鉴已激活")
   end
   local promotion_icon = me.assignWidget(self,"promotion_icon")
   promotion_icon:loadTexture(getItemIcon(pEtcData["id"]),me.plistType)
   local pQuity = me.assignWidget(self,"promotion_quilty"):setVisible(true)
   pQuity:loadTexture(getArchQuility(pEtcData["id"]),me.localType)
end
function archManualInfo:onEnter()
    print("archManualInfo onEnter") 
	me.doLayout(self,me.winSize)  
end
function archManualInfo:onEnterTransitionDidFinish()
	print("archManualInfo onEnterTransitionDidFinish") 
end
function archManualInfo:onExit()
    print("archManualInfo onExit")    
end
function archManualInfo:close()
    self:removeFromParent()  
end
