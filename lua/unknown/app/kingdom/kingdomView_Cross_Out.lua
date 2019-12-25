--[Comment]
--jnmo
kingdomView_Cross_Out = class("kingdomView_Cross_Out",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
kingdomView_Cross_Out.__index = kingdomView_Cross_Out
function kingdomView_Cross_Out:create(...)
    local layer = kingdomView_Cross_Out.new(...)
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

function kingdomView_Cross_Out:ctor()   
    print("kingdomView_Cross_Out ctor") 
end
function kingdomView_Cross_Out:init()   
    print("kingdomView_Cross_Out init")
    self.Fail = false
	me.registGuiClickEventByName(self,"fixLayout",function (node)         
        if self.Fail then
           GMan():send(_MSG.Cross_Sever_onExit())
        end   
        self:close()
    end)    
    self.Panel_win = me.assignWidget(self,"Panel_win")
  
    return true
end
function kingdomView_Cross_Out:setWin()
    self.Panel_node = me.assignWidget(self,"Panel_node")
    local Text_out = me.assignWidget(self,"Text_out")
    local Text_sure = me.assignWidget(self,"Text_sure")
    local win_bg = me.assignWidget(self,"win_bg")
    local fail_bg = me.assignWidget(self,"fail_bg")
 
    local pStr =  ""
    local pData = user.Cross_Throne_Occupy
    if pData.win == 0 then  -- 失败
       pStr = "<txt0018,ffffff>"..pData.shortName..pData.name.."&<txt0018,ffc000>被&<txt0018,ffffff>"..pData.mstShortName..pData.mstName.."&<txt0018,f7672e>沦陷&"      
       self.Fail = true
       me.registGuiClickEventByName(self,"Button_Out",function (node)
           GMan():send(_MSG.Cross_Sever_onExit())
           self:close()
       end)   
    else
       pStr = "<txt0018,ffffff>"..pData.mstShortName..pData.mstName.."&<txt0018,ffc000>将&<txt0018,ffffff>"..pData.shortName..pData.name.."&<txt0018,f7672e>沦陷&"
       me.registGuiClickEventByName(self,"Button_Out",function (node)
           self:close()
       end)   
    end
    me.assignWidget(self,"Image_4"):setVisible(false)
    local pConentlabel = mRichText:create(pStr, 450)
    pConentlabel:setAnchorPoint(cc.p(0.5,0.5))
    pConentlabel:setPosition(cc.p(10,-10))
    self.Panel_node:addChild(pConentlabel)
end
function kingdomView_Cross_Out:setEnd()
    local pData = user.Cross_Throne_End
    local pNum = 0
    local pSid = SharedDataStorageHelper():getLastLoginSID()  
    self.Fail = true
    for key, var in pairs(pData) do          
        pNum = pNum + 1
        local Panel_cell = me.assignWidget(self,"Panel_cell"):clone():setVisible(true)
        Panel_cell:setAnchorPoint(cc.p(0,0.5))
        Panel_cell:setPosition(cc.p(10,300-pNum*66))
        local pRankIcon = me.assignWidget(Panel_cell,"rank_bg")
        if pNum == 1 then
            pRankIcon:loadTexture("wangzuo_tubiao_paiming_1.png",me.localType)
        elseif pNum == 2 then
            pRankIcon:loadTexture("wangzuo_tubiao_paiming_2.png",me.localType)
        elseif pNum == 3 then
            pRankIcon:loadTexture("wangzuo_tubiao_paiming_3.png",me.localType)
        elseif pNum == 4 then
            pRankIcon:loadTexture("wangzuo_tubiao_paiming_4.png",me.localType)
        end
        local pscore = me.assignWidget(Panel_cell,"score")
        pscore:setString(var.socre)
        local Image_6 = me.assignWidget(Panel_cell,"Image_6")
        if me.toNum(pSid) == me.toNum(var.id) then
           Image_6:setVisible(true)
        else
           Image_6:setVisible(false)
        end
        local pStr = ""
        if var.mstShortName and var.mstName then
           pStr = "<txt0016,ffffff>"..var.shortName ..var.name.."&<txt0016,d4c5b4>(被"..var.mstShortName..var.mstName.."&<txt0016,fb5b5b>沦陷)&"
        else
           pStr = "<txt0016,ffffff>"..var.shortName ..var.name.."&"
        end
        local Panel_Rich = me.assignWidget(Panel_cell,"Panel_Rich")
        local pConentlabel = mRichText:create(pStr, 450 )
        pConentlabel:setAnchorPoint(cc.p(0,0.5))
        pConentlabel:setPosition(cc.p(0,0))
        Panel_Rich:addChild(pConentlabel)
        me.assignWidget(self,"Panel_node_end"):addChild(Panel_cell):setVisible(true)
    end 
    me.registGuiClickEventByName(self,"Button_Out",function (node)
           GMan():send(_MSG.Cross_Sever_onExit())
           self:close()
    end)   
end
function kingdomView_Cross_Out:onEnter()
    print("kingdomView_Cross_Out onEnter") 
	me.doLayout(self,me.winSize)  
end
function kingdomView_Cross_Out:onEnterTransitionDidFinish()
	print("kingdomView_Cross_Out onEnterTransitionDidFinish") 
end
function kingdomView_Cross_Out:onExit()
    print("kingdomView_Cross_Out onExit")    
end
function kingdomView_Cross_Out:close()
    self:removeFromParentAndCleanup(true)  
end
