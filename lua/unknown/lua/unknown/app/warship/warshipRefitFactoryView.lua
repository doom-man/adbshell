--[Comment]
--jnmo
warshipRefitFactoryView = class("warshipRefitFactoryView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
warshipRefitFactoryView.__index = warshipRefitFactoryView
function warshipRefitFactoryView:create(...)
    local layer = warshipRefitFactoryView.new(...)
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
function warshipRefitFactoryView:ctor()   
    print("warshipRefitFactoryView ctor") 
    self.timers = {}
end
function warshipRefitFactoryView:init()   
    print("warshipRefitFactoryView init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    self.list = me.assignWidget(self,"list")
    return true
end
function warshipRefitFactoryView:initWithData(data)
    dump(data)
    local tmp = me.assignWidget(self,"Image_order")
    local function call_begin(node)
        if node.data.status == -1 then
            NetMan:send(_MSG.msg_ship_refit_factory_order_start(node.data.id))
        elseif node.data.status == 0 then
            NetMan:send(_MSG.msg_ship_refit_factory_order_complete(node.data.id))
        elseif node.data.status == 1 then
            NetMan:send(_MSG.msg_ship_refit_factory_order_quick(node.data.id))
        end
    end
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end   
    self.timers = {} 
    
    for key, var in pairs(data) do
        local df = cfg[CfgType.SHIP_REFIT_SKILL_ORDER][tonumber(var.id)]
        local cell = tmp:clone()
        local Text_type_title = me.assignWidget(cell,"Text_type_title")
        local Text_time = me.assignWidget(cell,"Text_time")
        local Text_Cost = me.assignWidget(cell,"Text_Cost")
        local Button_Begin = me.assignWidget(cell,"Button_Begin")
        local Text_Need = me.assignWidget(cell,"Text_Need")  
        local Image_Cost = me.assignWidget(cell,"Image_Cost")  
        local Image_quality = me.assignWidget(cell,"Image_quality")  
        local Goods_Icon = me.assignWidget(cell,"Goods_Icon")  
        local label_num = me.assignWidget(cell,"label_num")      
        local Text_time_txt =   me.assignWidget(cell,"Text_time_txt") 
        local Image_8 =   me.assignWidget(cell,"Image_8") 
              
        Image_Cost:setVisible(true)
        Text_Cost:setVisible(true)
        Image_8:setVisible(true)
        Text_time_txt:setVisible(true)
        Button_Begin.data = var
        me.registGuiClickEvent(Button_Begin,call_begin)
        if var.status == -1 then
            --未开始
            Text_time:setString(me.formartSecTime(df.needTime))
            local ns = me.split(df.needItem,":")
            Image_Cost:loadTexture(getItemIcon(tonumber(ns[1])),me.localType)
            Text_Cost:setString(ns[2])
            Button_Begin:setTitleText("开始")
        elseif var.status == 0 then

            --已完成
            Image_Cost:setVisible(false)
            Text_Cost:setVisible(false)
            Image_8:setVisible(false)
            Text_time_txt:setVisible(false)
            local is = var.item[1]
            Image_quality:loadTexture(getQuality(cfg[CfgType.ETC][tonumber(is[1])]),me.localType)
            Goods_Icon:loadTexture( getItemIcon( tonumber(is[1]),me.localType))
            label_num:setString(is[2])
            Goods_Icon:setVisible(true)
            Button_Begin:setTitleText("收取")
            Button_Begin:loadTextureNormal("btn_jiesan.png",me.localType)
        elseif var.status == 1 then
            --进行中
            Image_Cost:loadTexture(getItemIcon(9008),me.localType)
            local xtime = var.time/1000
            Text_Cost:setString(var.gem)
            Text_time:setString(me.formartSecTime(xtime))
            self.timers[var.id] = me.registTimer(xtime,function (dt)
                    xtime = xtime - 1
                    Text_time:setString(me.formartSecTime(xtime))
                    Text_Cost:setString(math.ceil(xtime/36))
            end,1)
            Button_Begin:setTitleText("立即完成")
            Button_Begin:loadTextureNormal("btn_jijie.png",me.localType)
        end
        me.resizeImage(Image_Cost,33,34)
        Text_type_title:setString(df.name)
        self.list:pushBackCustomItem(cell)
    end    
end
function warshipRefitFactoryView:onEnter()
    print("warshipRefitFactoryView onEnter") 
	me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_SHIP_REFIT_FACTORY_ORDER) then
            self.list:removeAllChildren()
            self:initWithData(msg.c.list)  
        end
    end )
end
function warshipRefitFactoryView:onEnterTransitionDidFinish()
	print("warshipRefitFactoryView onEnterTransitionDidFinish") 
end
function warshipRefitFactoryView:onExit()
    print("warshipRefitFactoryView onExit")   
    UserModel:removeLisener(self.modelkey) 
    for key, var in pairs(self.timers) do
        me.clearTimer(var)
    end   
end
function warshipRefitFactoryView:close()
    self:removeFromParent()  
end
