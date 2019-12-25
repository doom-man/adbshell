settingView = class("settingView", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2]):clone()
    end
end )
settingView.__index = settingView
function settingView:create(...)
    local layer = settingView.new(...)
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                elseif "enterTransitionFinish" == tag then
                    layer:onEnterTransitionDidFinish()
                end
            end )
            return layer
        end
    end
    return nil
end

function settingView:ctor()
    print("settingView:ctor()")
    self.BGSwtich = false
    self.EffectSwtich = false
    self.SMSwtich = false
end
function settingView:init()
    print("settingView:init()")
    self.Image_BG = me.assignWidget(self, "Image_BG")
    self.Image_BGswitch = me.assignWidget(self, "Image_BGswitch")
    self.Image_effectswitch = me.assignWidget(self, "Image_effectswitch")
    self.Image_effect = me.assignWidget(self, "Image_effect")
    self.Image_SMswitch = me.assignWidget(self, "Image_SMswitch")
    self.Image_SM = me.assignWidget(self, "Image_SM")

    me.registGuiClickEventByName(self, "Button_msg", function(node)
        print("Button_msg !!!!")
    end )
    me.registGuiClickEventByName(self, "Button_gm", function(node)
        print("Button_gm !!!!")
    end )
    local accBtn = me.registGuiClickEventByName(self, "Button_acount", function(node)
        local logout = logoutView:create("logoutView.csb")
        local parent = mainCity or pWorldMap
        if parent and parent.lordView then
            parent.lordView:addChild(logout)
        end
        me.showLayer(logout, "bg")
        self:close()
    end )
    accBtn:setVisible(getMetaData("cn.jj.sdk.promoteid") ~= "0")
    -- 
    local Button_service = me.registGuiClickEventByName(self, "Button_service", function(node)            
        local curName = SharedDataStorageHelper():getLastLoginName()      
        jjGameSdk.openSubmissionPage(user.name,curName,function (rev)
        end)
    end )
    Button_service:setVisible(false)
    me.registGuiClickEventByName(self, "close", function(node)
        self:close()
    end )
    me.registGuiClickEventByName(self, "Button_effect", function(node)
        print("Button_effect !!!!")
        self.EffectSwtich = not self.EffectSwtich
        mAudioMusic:effectButton()
        self:setState(self.Image_effectswitch, self.Image_effect, self.EffectSwtich)
    end )
    me.registGuiClickEventByName(self, "Button_BG", function(node)
        print("Button_BG !!!!")
        self.BGSwtich = not self.BGSwtich
        mAudioMusic:musicButton()
        self:setState(self.Image_BGswitch, self.Image_BG, self.BGSwtich)
    end )
    me.registGuiClickEventByName(self, "Button_SM", function(node)
        self.SMSwtich = not self.SMSwtich
        if self.SMSwtich == true then
            SharedDataStorageHelper():setSM("sm")
        else
            SharedDataStorageHelper():setSM("nor")
        end
        self:setState(self.Image_SMswitch, self.Image_SM, self.SMSwtich)
    end )

    self.BGSwtich = AudioMusic.MUSICOFF
    self.EffectSwtich = AudioMusic.MUSICEFFECT
    if SharedDataStorageHelper():getSM() == "sm" then
        self.SMSwtich = true
    else
        self.SMSwtich = false
    end
    self:setState(self.Image_BGswitch, self.Image_BG, self.BGSwtich)
    self:setState(self.Image_effectswitch, self.Image_effect, self.EffectSwtich)
    self:setState(self.Image_SMswitch, self.Image_SM, self.SMSwtich)
    return true
end
function settingView:setState(icon_, img_, switch_)
    icon_:setVisible(not switch_)
    if switch_ then
        img_:loadTexture("lingzhu_shezhi_tubiao_kai.png", me.localType)
    else
        img_:loadTexture("lingzhu_shezhi_tubiao_guan.png", me.localType)
    end
end
function settingView:onEnter()
    print("settingView:onEnter()")
    me.doLayout(self, me.winSize)
end
function settingView:onEnterTransitionDidFinish()
    print("settingView:onEnterTransitionDidFinish()")
end
function settingView:onExit()
    print("settingView:onExit()")
end
function settingView:close()
    print("settingView:close()")
    self:removeFromParentAndCleanup(true)
end

