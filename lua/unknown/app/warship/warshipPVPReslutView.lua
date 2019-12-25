--[Comment]
--jnmo
warshipPVPReslutView = class("warshipPVPReslutView",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
warshipPVPReslutView.__index = warshipPVPReslutView
function warshipPVPReslutView:create(...)
    local layer = warshipPVPReslutView.new(...)
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
function warshipPVPReslutView:ctor()   
    print("warshipPVPReslutView ctor") 
end
function warshipPVPReslutView:init()   
    print("warshipPVPReslutView init")
	me.registGuiClickEventByName(self,"Button_Ok",function (node)
        self:close()     
    end)    
    self.Image_icon_mine = me.assignWidget(self,"Image_icon_mine")
    self.Image_icon_other = me.assignWidget(self,"Image_icon_other")
    self.Image_win_item = me.assignWidget(self,"Image_win_item")
    self.Image_win = me.assignWidget(self,"Image_win")
    self.Text_Mine_Name = me.assignWidget(self,"Text_Mine_Name")
    self.Text_Other_Name = me.assignWidget(self,"Text_Other_Name")
    self.Text_Mine_Rank = me.assignWidget(self,"Text_Mine_Rank")
    self.Text_Mine_Rank_add = me.assignWidget(self,"Text_Mine_Rank_add")
    self.Text_Other_Rank = me.assignWidget(self,"Text_Other_Rank")
    self.Text_Other_Rank_add = me.assignWidget(self,"Text_Other_Rank_add")
    return true
end
function warshipPVPReslutView:initWithData(data)
    dump(data)
    self.Text_Mine_Name:setString(data.atkName)
    self.Text_Other_Name:setString(data.defName)
    self.Text_Mine_Rank:setString(data.atkR)
    self.Text_Other_Rank:setString(data.defR)
    self.Text_Mine_Rank_add:setString(data.deltaR)
    self.Text_Other_Rank_add:setString(data.deltaR)
    if data.isWin then
        self.Image_win_item:setVisible(true)
        self.Image_win:loadTexture("refit_pvp_6.png",me.localType)
    else
        self.Image_win:loadTexture("refit_pvp_8.png",me.localType)
        self.Image_win_item:setVisible(false)
    end
    local myshipDef = cfg[CfgType.SHIP_DATA][data.atkShipId]
    local othershipDef = cfg[CfgType.SHIP_DATA][data.defShipId]
    self.Image_icon_mine:loadTexture(getWarshipImageTexture(myshipDef.type), me.localType) 
    self.Image_icon_other:loadTexture(getWarshipImageTexture(othershipDef.type), me.localType)  
    me.resizeImage(self.Image_icon_mine,200,200)
    me.resizeImage(self.Image_icon_other,200,200)
end
function warshipPVPReslutView:onEnter()
    print("warshipPVPReslutView onEnter") 
	me.doLayout(self,me.winSize)  
end
function warshipPVPReslutView:onEnterTransitionDidFinish()
	print("warshipPVPReslutView onEnterTransitionDidFinish") 
end
function warshipPVPReslutView:onExit()
    print("warshipPVPReslutView onExit")    
end
function warshipPVPReslutView:close()
    self:removeFromParent()  
end
