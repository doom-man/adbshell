--[Comment]
--jnmo
archManualLayer = class("archManualLayer",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
archManualLayer.__index = archManualLayer
function archManualLayer:create(...)
    local layer = archManualLayer.new(...)
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
function archManualLayer:ctor()   
    print("archManualLayer ctor") 
end
local boxnum = 3
function archManualLayer:init()   
    print("archManualLayer init")
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)   
    me.registGuiClickEventByName(self,"Button_Tips",function (sender)
        local wd = sender:convertToWorldSpace(cc.p(0 + 45, 0 - 7))
        local stips = simpleTipsLayer:create("simpleTipsLayer.csb")
        stips:initWithRichStr("<txt0016,d4cdb9>通过消耗对应考古材料可以升级科技#n英雄图鉴科技可以消耗英雄类、宝石类、通用类材料#n装备图鉴科技可以消耗装备类、动植物类、通用类材料#n建筑图鉴科技可以消耗建筑类、木材类、通用类材料&",
         wd,400)
        me.runningScene():addChild(stips, me.MAXZORDER + 1)
    end)
    self.pCheckBox = { }
    self.manual_kind = 1
    
    local function callback2_(sender, event)
        if event == ccui.CheckBoxEventType.selected then
            if self.manual_kind ~= sender.id then
                self.manual_kind = sender.id
                self:updateUI()
                me.assignWidget(sender,"red_point"):setVisible(false)
                for var = 1, boxnum do
                    if var == sender.id then
                        self.pCheckBox[var]:setSelected(true)
                        self.pCheckBox[var]:setTouchEnabled(false)
                        me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c3b(0x7c, 0x5f, 0x36))
                        me.assignWidget(self.pCheckBox[var], "img_dark"):setVisible(true)
                        me.assignWidget(self.pCheckBox[var], "img_bright"):setVisible(false)
                    else
                        self.pCheckBox[var]:setSelected(false)
                        self.pCheckBox[var]:setTouchEnabled(true)
                        me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c3b(0xb1, 0x95, 0x5f))
                        me.assignWidget(self.pCheckBox[var], "img_dark"):setVisible(false)
                        me.assignWidget(self.pCheckBox[var], "img_bright"):setVisible(true)
                    end                    
                end
            end
        end
    end
    for var = 1, boxnum do
        self.pCheckBox[var] = me.assignWidget(self, "cbox" .. var)
        self.pCheckBox[var]:addEventListener(callback2_)
        self.pCheckBox[var].id = var
        if self.manual_kind == self.pCheckBox[var].id then
            self.pCheckBox[var]:setSelected(true)
            self.pCheckBox[var]:setTouchEnabled(false)
            me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c3b(0x7c, 0x5f, 0x36))
            me.assignWidget(self.pCheckBox[var], "img_dark"):setVisible(true)
            me.assignWidget(self.pCheckBox[var], "img_bright"):setVisible(false)
        else
            self.pCheckBox[var]:setSelected(false)
            self.pCheckBox[var]:setTouchEnabled(true)
            me.assignWidget(self.pCheckBox[var], "Text_title"):setTextColor(cc.c3b(0xb1, 0x95, 0x5f))
            me.assignWidget(self.pCheckBox[var], "img_dark"):setVisible(false)
            me.assignWidget(self.pCheckBox[var], "img_bright"):setVisible(true)
        end
    end 
    self.list = me.assignWidget(self,"list")
    self.list:setScrollBarEnabled(false)
    return true
end
function archManualLayer:updateList(bthread)
   for var = 1, boxnum do
     me.assignWidget(self.pCheckBox[var],"red_point"):setVisible(false)
   end   
   if user.archRedPoints and table.nums(user.archRedPoints) then
       for key, var in pairs(user.archRedPoints) do
           me.assignWidget(  self.pCheckBox[tonumber(key)] ,"red_point"):setVisible(true)
       end       
   end
   user.archRedPoints = nil
   local tmp = {}
   for key, var in pairs(user.arch_tech_book) do
       local bookdata = cfg[CfgType.BOOK_TECH_MENU][var.id]
       if bookdata.typeid == self.manual_kind then
         table.insert(tmp,var)
       end
   end   
   self.list:removeAllChildren()
   self.list:jumpToTop()   
   local function levelUp_callback(node)
        local level =   archManualTechLevel:create("archManualTechLevel.csb")
        level:initWithData(node.data)
        me.popLayer(level)
   end
   local function manual_callback(node)
        local pTouch = node:getTouchBeganPosition()        
        local pPoint = me.contains(self.list, pTouch.x, pTouch.y)
        if pPoint then
            local info = archManualInfo:create("manualInfo.csb")
            info:initWithData(node.data)  
            me.popLayer(info)
        end
   end
   for key, var in pairs(tmp) do
        local bookdata = cfg[CfgType.BOOK_TECH_MENU][var.id]
        local techdata = cfg[CfgType.BOOK_TECH][var.techId]
        local Image_Item = me.assignWidget(self,"Image_Item"):clone()
        Image_Item:setVisible(true)
        local Text_Title = me.assignWidget(Image_Item,"Text_Title")
        local Image_tech_icon = me.assignWidget(Image_Item,"Image_tech_icon")
        local Text_tech_name = me.assignWidget(Image_Item,"Text_tech_name")
        local Text_tech_pro = me.assignWidget(Image_Item,"Text_tech_pro")
        local tech_loadbar = me.assignWidget(Image_Item,"tech_loadbar")
        local Text_process = me.assignWidget(Image_Item,"Text_process")
        local Button_LevelUp = me.assignWidget(Image_Item,"Button_LevelUp")
        Text_tech_name:setString(techdata.name.."Lv."..techdata.level)
        Image_tech_icon:loadTexture(techIcon(techdata.icon),me.localType)
        Text_tech_pro:setString(techdata.desc..(techdata.beforetxt or ""))
        Text_Title:setString(bookdata.name)  
        me.registGuiClickEvent(Button_LevelUp,levelUp_callback)   
        Button_LevelUp.data = var       
        if var.active < bookdata.unlockneednum then
            Text_process:setString("激活进度(" ..var.active .."/"..bookdata.unlockneednum .. ")")
            tech_loadbar:setPercent(100*var.active/bookdata.unlockneednum )
            me.Helper:grayImageView(Image_tech_icon)
            me.setButtonDisable(Button_LevelUp,false)
        else
            Text_process:setString(var.exp .."/" ..techdata.exp)
            tech_loadbar:setPercent(100*var.exp/techdata.exp)
            me.Helper:normalImageView(Image_tech_icon)
            me.setButtonDisable(Button_LevelUp,true)
        end
        local w = 15
        for k, v in pairs(var.book) do                
                local archDebrisItem = archDebris:create("archDebris.csb") 
                archDebrisItem:setManualData(v)
                archDebrisItem:setAnchorPoint(cc.p(0, 0.5))
                archDebrisItem:setPosition(25 + (108 + w) * (k - 1), 60.5)
                local Image_Qua1 = me.registGuiClickEventByName(archDebrisItem,"Image_Qua1",manual_callback)
                Image_Qua1:setSwallowTouches(false)
                Image_Qua1.data = v
                me.assignWidget(Image_Item,"Image_bg"):addChild(archDebrisItem)
                archDebrisItem:setScale(0.84)   
        end       
        self.list:pushBackCustomItem(Image_Item)
        if bthread then
            coroutine.yield()
        end
   end   
end
function archManualLayer:updateUI()    
   me.coroClear(self.schid)
   self.cthread =   coroutine.create(function ()
            --这里为调用的方法 然后在该方法中加入coroutine.yield()
            self:updateList(true)
    end)
   self.schid =me.coroStart(self.cthread)
end
function archManualLayer:onEnter()
    print("archManualLayer onEnter") 
	me.doLayout(self,me.winSize)  
    self.modelkey = UserModel:registerLisener( function(msg)
        -- 注册消息通知
        if checkMsg(msg.t, MsgCode.MSG_BOOK_TECH_MENU) then
            self:updateUI()
        elseif checkMsg(msg.t, MsgCode.MSG_BOOK_TECH_UP_LEVL) then         
            self:updateUI()        
        end
    end )
end
function archManualLayer:onEnterTransitionDidFinish()
	print("archManualLayer onEnterTransitionDidFinish") 
end
function archManualLayer:onExit()
    print("archManualLayer onExit")   
    UserModel:removeLisener(self.modelkey) 
    me.coroClear(self.schid)
end
function archManualLayer:close()
    self:removeFromParent()  
end
