runeAltarView = class("runeAltarView",function (...)
     local arg = {...}
    if table.getn(arg) == 2 then    
        return arg[1]:getChildByName(arg[2])
    else
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return cc.CSLoader:createNode(arg[1])
    end
end)
function runeAltarView:create(...)
    local layer = runeAltarView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler(function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end)
            return layer
        end
    end
    return nil
end

function runeAltarView:ctor(...)
    ----self.jumpToNoActive 图鉴未激活时，跳转到当前页面的标识
    _, self.jumpToNoActive, self.from = ...
    self.currentPanel = nil
end

function runeAltarView:onEnter()
    if self.from==1 then
        self:openHeceng()
    elseif self.from==2 then
        self:openSWCangku()
    elseif self.from==3 then
        self:openCLCangku()
    end
end

function runeAltarView:onExit()
    me.RemoveCustomEvent(self.jumptoListener)
end


function runeAltarView:switchButtons(node)
    local btns = {self.btn_heceng, self.btn_sw_cangku, self.btn_cl_cangku}
    for key, var in ipairs(btns) do
        if node ~= var then
            me.setButtonDisable(var,true)
            var:loadTextureNormal("youjian_anniu_anxia.png", me.localType)
            var:setContentSize(cc.size(219.53,56))
            me.assignWidget(var, "Panel_6"):setVisible(false)
        else        
            me.setButtonDisable(var,false)
            var:loadTextureNormal("youjian_anniu_zhengchang.png", me.localType)
            var:setContentSize(cc.size(219.53,56))
            me.assignWidget(var, "Panel_6"):setVisible(true)
        end
    end
end
function runeAltarView:openHeceng()
    self:switchButtons(self.btn_heceng)
    if self.currentPanel~=nil then
        me.assignWidget(self,"contentNode"):removeChild(self.currentPanel)
        self.currentPanel=nil
    end
    local isFirstLoad=true
    if cc.Director:getInstance():getTextureCache():getTextureForKey("rune_heceng_bg.png") then--是否首次加载
        isFirstLoad=false
    end 
    self.currentPanel = runeHeceng:create("rune/runeHeceng.csb")
    self.currentPanel:setPosition(0, 0)
    if isFirstLoad==false then--是否首次加载
        self.currentPanel:setData(self.nowCate, self.jumpToNoActive)
    else
        self.currentPanel:firstLoad(self.nowCate, self.jumpToNoActive)
    end 
    me.assignWidget(self,"contentNode"):addChild(self.currentPanel) 

end
function runeAltarView:openSWCangku()
    self:switchButtons(self.btn_sw_cangku)
    if self.currentPanel~=nil then
        me.assignWidget(self,"contentNode"):removeChild(self.currentPanel)
        self.currentPanel=nil
    end
    self.currentPanel = runePackage:create("rune/runePackage.csb")
    self.currentPanel:setPosition(0, 0)
    self.currentPanel:setData(self.nowCate)
    me.assignWidget(self,"contentNode"):addChild(self.currentPanel) 
end
function runeAltarView:openCLCangku()   
    self:switchButtons(self.btn_cl_cangku)
    if self.currentPanel~=nil then
        me.assignWidget(self,"contentNode"):removeChild(self.currentPanel)
        self.currentPanel=nil
    end

    self.currentPanel = runeMaterial:create("rune/runeMaterial.csb")
    self.currentPanel:setPosition(0, 0)
    self.currentPanel:setData(self.nowCate)
    me.assignWidget(self,"contentNode"):addChild(self.currentPanel)
end

function runeAltarView:jumpToTab(evt)
    local tabIndex  =  tonumber(evt._userData)
    if tabIndex==1 then
        self:openHeceng()
    elseif tabIndex==2 then
        self:openSWCangku()
    elseif tabIndex==3 then
        self:openCLCangku()
    end
end

function runeAltarView:init()
    print("runeAltarView init")
    me.doLayout(self, me.winSize)
    self.closeBtn = me.registGuiClickEventByName(self, "close", function(node)
        self:removeFromParentAndCleanup(true)
    end )

    self.nowCate=0
    local btns = {"cateAllBtn", "cate1Btn", "cate2Btn", "cate3Btn", "cate4Btn", "cate5Btn", "cate6Btn"}
    local function selectRuneCate (sender)
        self.nowCate = sender:getTag()
        for key, var in pairs(btns) do
            if var ~= sender:getName() then
                me.assignWidget(self, var):loadTextureNormal("rune_catebox.png",me.localType)
            else        
                me.assignWidget(self, var):loadTextureNormal("rune_catebox_select.png",me.localType)
            end
        end

        if self.currentPanel~=nil then
            self.currentPanel:setData(self.nowCate)
        end
    end
    for key, var in pairs(btns) do
        me.assignWidget(self, var):addClickEventListener(selectRuneCate)
    end
    me.assignWidget(self, "cateAllBtn"):loadTextureNormal("rune_catebox_select.png",me.localType)


    self.btn_heceng=me.assignWidget(self,"btn_heceng")
    self.btn_sw_cangku=me.assignWidget(self,"btn_sw_cangku")
    self.btn_cl_cangku=me.assignWidget(self,"btn_cl_cangku")
    
    me.registGuiClickEvent(self.btn_heceng,function (node)
        self:openHeceng()
    end)
    me.registGuiClickEvent(self.btn_sw_cangku,function (node)
        self:openSWCangku()
    end)
    me.registGuiClickEvent(self.btn_cl_cangku,function (node)   
        self:openCLCangku()
    end)

    self.jumptoListener = me.RegistCustomEvent("jumpToRuneStore", handler(self, self.jumpToTab))

    return true
end


