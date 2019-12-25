--[Comment]
--jnmo
taskCaphterAni = class("taskCaphterAni",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
taskCaphterAni.__index = taskCaphterAni
function taskCaphterAni:create(...)
    local layer = taskCaphterAni.new(...)
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
function taskCaphterAni:ctor()   
    print("taskCaphterAni ctor") 
end
function taskCaphterAni:init()   
    print("taskCaphterAni init")
    self.ani = me.assignWidget(self,"ani")
    local function animationEvent(armatureBack,movementType,movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
               self:close()
               if not Queue.isEmpty(UserModel.msgControlQueue) then
                  local msg = Queue.pop(UserModel.msgControlQueue)
                  UserModel:reviceData(msg,mCross_Sever_Out,true)
               end
            end
    end
    self.ani:getAnimation():setMovementEventCallFunc(animationEvent)
    return true
end
function taskCaphterAni:initWithData(id)
    me.addSpriteWithFile("ui_anim_zhangjie_010.plist")
    local pIcon = ccs.Skin:createWithSpriteFrameName("ui_zjrw_xtext_0"..id..".png")
    local word = self.ani:getBone("weizi_3")
    word:addDisplay(pIcon, 1)
    word:changeDisplayWithIndex(1, true)
    local data = cfg[CfgType.CAPHTER_TITLE][tonumber(id)]
    local pIcon1 = ccs.Skin:createWithSpriteFrameName("ui_zjrw_ctext_0"..data.icon..".png")
    local word1 = self.ani:getBone("weizi_1")
    word1:addDisplay(pIcon1, 1)
    word1:changeDisplayWithIndex(1, true)

    local pIcon2 = ccs.Skin:createWithSpriteFrameName("ui_zjrw_text_0"..id..".png")
    local word2 = self.ani:getBone("weizi_2")
    word2:addDisplay(pIcon2, 1)
    word2:changeDisplayWithIndex(1, true)
end
function taskCaphterAni:onEnter()
    print("taskCaphterAni onEnter") 
	me.doLayout(self,me.winSize)  
end
function taskCaphterAni:onEnterTransitionDidFinish()
	print("taskCaphterAni onEnterTransitionDidFinish") 
end
function taskCaphterAni:onExit()
    print("taskCaphterAni onExit")    
end
function taskCaphterAni:close()
    self:removeFromParent()  
end

