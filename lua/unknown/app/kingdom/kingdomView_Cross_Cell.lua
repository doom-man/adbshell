--[Comment]
--jnmo
kingdomView_Cross_Cell = class("kingdomView_Cross_Cell",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2]):clone()
        pCell:setVisible(true)
        return pCell 
    end
end)
kingdomView_Cross_Cell.__index = kingdomView_Cross_Cell
function kingdomView_Cross_Cell:create(...)
    local layer = kingdomView_Cross_Cell.new(...)
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
function kingdomView_Cross_Cell:ctor()   
    print("kingdomView_Cross_Cell ctor") 
    self.mTime = nil
end
function kingdomView_Cross_Cell:init()   
    print("kingdomView_Cross_Cell init")
	
    return true
end


function kingdomView_Cross_Cell:Cross_Cell(data)
    local Cross_one = me.assignWidget(self,"Cross_one")  
    local Cross_one_enter = me.assignWidget(self,"Cross_one_enter")
    local Button_out = me.assignWidget(self,"Button_out")
    if user.Cross_Sever_Status == mCross_Sever and CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
       Cross_one_enter:setVisible(false)
    else
       Cross_one_enter:setVisible(true)
    end
    if CaptiveMgr:isCaptured() and user.Cross_Sever_Status == mCross_Sever then
       Button_out:setVisible(true)
       Cross_one_enter:setVisible(false)  
    end
    if data then
        me.clearTimer(self.mTime)
        local Cross_one = me.assignWidget(self,"Cross_one") 
       -- local Cross_one_name = me.assignWidget(self,"Cross_one_name")
       -- Cross_one_name:setString( cfg[CfgType.CROSS_ACTIVEITY_DEF][tonumber( data.id )].name)    
        if data.NotOpen == 0 then
           Cross_one:setVisible(true)        
           if data.ExtOut == 1 then
              Cross_one_enter:setVisible(false)
              Button_out:setVisible(false)
           end
          
           local Cross_one_time = me.assignWidget(self,"Cross_one_time")
           local pStr = "结束倒计时 "
           if data.status == 1 or data.status == 2 then
              pStr = "结束倒计时 "
           else
              pStr = "开启倒计时"
           end
           self.pTime = data.Time
           dump(self.pTime)
           if self.pTime > 0 then                  
               Cross_one_time:setString(pStr..me.formartSecTime(self.pTime))          
               self.mTime = me.registTimer(-1,function (dt)
                    if self.pTime > 0 then
                       self.pTime = self.pTime -1
                       Cross_one_time:setString(pStr..me.formartSecTime(self.pTime))
                    else
                       me.clearTimer(self.mTime)
                       Cross_one_time:setString("活动已经结束")
                    end
               end,1)
            else
                Cross_one_time:setString("活动已经结束")
            end
        elseif data.NotOpen == 1 then
           Cross_one:setVisible(false)         
        elseif data.NotOpen == 2 then
           Cross_one:setVisible(false)        
        end
    else
       Cross_one:setVisible(false)    
    end
end

function kingdomView_Cross_Cell:onEnter()
    print("kingdomView_Cross_Cell onEnter") 
	  
end
function kingdomView_Cross_Cell:onEnterTransitionDidFinish()
	print("kingdomView_Cross_Cell onEnterTransitionDidFinish") 
end
function kingdomView_Cross_Cell:onExit()
    print("kingdomView_Cross_Cell onExit")   
    me.clearTimer(self.mTime) 
end
function kingdomView_Cross_Cell:close()
    self:removeFromParentAndCleanup(true)  
end


