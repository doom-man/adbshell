--[Comment]
--jnmo
hornorLevelUp = class("hornorLevelUp",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
hornorLevelUp.__index = hornorLevelUp
function hornorLevelUp:create(...)
    local layer = hornorLevelUp.new(...)
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
function hornorLevelUp:ctor()   
    print("hornorLevelUp ctor") 
end
function hornorLevelUp:init()   
    print("hornorLevelUp init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.Text_Title = me.assignWidget(self,"Text_Title")
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_CITY_HONOUR_TECH_UP_LEVEL) then  
            local pCityCommon = allAnimation:createAnimation("ui_battle_victory_1")
            pCityCommon:CommonSpecific(ALL_COMMON_LEVELUP_COMPLETE)
            pCityCommon:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2+50))
            me.runningScene():addChild(pCityCommon, me.ANIMATION)
            local techdata = cfg[CfgType.HORNOR_TECH][msg.c.defId]                      
            if techdata.nextid and techdata.nextid ~= 0  then
                self:initWithData(self.chooseIdx ,msg.c.defId)
            else
                self:close()
            end
        end
    end )
    return true
end
function hornorLevelUp:initWithData(chooseIdx,defid)
    self.chooseIdx = chooseIdx
    local techdata = cfg[CfgType.HORNOR_TECH][defid]
    self.Text_Title:setString(techdata.name)
    local item1 = me.assignWidget(self,"item_bg1")
    self.num1 = me.assignWidget(item1,"Text_Item_num")
    self. icon1 = me.assignWidget(item1,"icon") 
    local item2 = me.assignWidget(self,"item_bg2")
    self.num2 = me.assignWidget(item2,"Text_Item_num")
    self. icon2 = me.assignWidget(item2,"icon") 
    local x = math.floor( chooseIdx / 10)
    local y = chooseIdx%10
    local data = user.hornor_tech.rankList[x].techList[y]
    self.num1:setString(data.lv.."/"..data.maxLv)  
    self.icon1:loadTexture("icon_tech_".. cfg[CfgType.HORNOR_TECH][ data.defId ].icon..".png",me.localType)      
    self.icon1:ignoreContentAdaptWithSize(false)  
    self.num2:setString((data.lv+1).."/"..data.maxLv)  
    self.icon2:loadTexture("icon_tech_".. cfg[CfgType.HORNOR_TECH][ data.defId ].icon..".png",me.localType)      
    self.icon2:ignoreContentAdaptWithSize(false)  
    self.Text_Item_Per1 = me.assignWidget(item1,"Text_Item_Per")
    self.Text_Item_Per2 = me.assignWidget(item2,"Text_Item_Per")
  
    local needItemTxts = nil
    if data.lv == 0 then
        self.Text_Item_Per1:setString("0")
        self.Text_Item_Per2:setString(techdata.successtxt)
        needItemTxts = me.split(techdata.needItemTxt,",")
    else    
        self.Text_Item_Per1:setString(techdata.successtxt)
        self.Text_Item_Per2:setString( cfg[CfgType.HORNOR_TECH][ techdata.nextid].successtxt)
        needItemTxts = me.split( cfg[CfgType.HORNOR_TECH][techdata.nextid].needItemTxt,",")
    end
    for var = 1, 3 do
          local Button_Level = me.assignWidget(self,"Button_Level"..var)
          Button_Level:setVisible(false)
    end    
    if needItemTxts then
        for key, var in pairs(needItemTxts) do
            local tmp = me.split(var,":")
            local Button_Level = me.assignWidget(self,"Button_Level"..key)
            Button_Level:setVisible(true)
            if #needItemTxts == 1 then
                Button_Level:setPositionX(320)
            elseif #needItemTxts == 2 then
                if key == 1 then
                    Button_Level:setPositionX(170)
                elseif key == 2 then
                    Button_Level:setPositionX(460)
                end
            end
            local Text_Num = me.assignWidget(Button_Level,"Text_Num")
            local Image_7 = me.assignWidget(Button_Level,"Image_7")
            Text_Num:setString(tmp[2])
            Image_7:loadTexture(getItemIcon(tonumber(tmp[1])),me.localType)
            local haveNum = 0
            for k, v in pairs(user.pkg) do
                local pkgDef = v:getDef()
                if me.toNum(pkgDef.id) == tonumber(tmp[1]) then
                    haveNum = haveNum + v.count
                end
            end
            if tonumber(tmp[2])<= haveNum then
                Text_Num:setColor(COLOR_WHITE)
            else
                Text_Num:setColor(COLOR_RED)
            end
            Button_Level.tempdata = tmp 
            Button_Level.have = tonumber(tmp[2])<= haveNum
            me.registGuiClickEvent(Button_Level,function (node)
                if node.have then
                     NetMan:send(_MSG.hornor_levelup(techdata.techid,node.tempdata[1]))
                else
                     showTips("道具不足")               
                end
            end)
        end        
    end
end
function hornorLevelUp:onEnter()
    print("hornorLevelUp onEnter") 
	me.doLayout(self,me.winSize)  
end
function hornorLevelUp:onEnterTransitionDidFinish()
	print("hornorLevelUp onEnterTransitionDidFinish") 
end
function hornorLevelUp:onExit()
    print("hornorLevelUp onExit")    
    UserModel:removeLisener(self.modelkey)
end
function hornorLevelUp:close()
    self:removeFromParent()  
end

