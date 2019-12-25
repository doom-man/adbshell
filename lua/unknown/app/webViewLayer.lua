-- [Comment]
-- jnmo
webViewLayer = class("webViewLayer", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end )
webViewLayer.__index = webViewLayer
function webViewLayer:create(...)
    local layer = webViewLayer.new(...)
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
function webViewLayer:ctor()
    print("webViewLayer ctor")
end
function webViewLayer:init()
    print("webViewLayer init")
    me.registGuiClickEventByName(self, "fixLayout", function(node)
        me.showMessageDialog("是否关闭网页?", function(args)
            if args == "ok" then self:close() end
        end )
    end )
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then      
        --webViewLayer.csb
        local img  = me.assignWidget(self,"Image_frame")   
        self._webView = ccexp.WebView:create()
        local imgSize = img:getContentSize()
        self._webView:setPosition(imgSize.width / 2, imgSize.height / 2 - 40)
        self._webView:setContentSize(imgSize.width -10 ,  imgSize.height -10)
        self._webView:loadURL("http://www.baidu.com")
        self._webView:setScalesPageToFit(true)
        self._webView:setOnShouldStartLoading(function(sender, url)
            print("onWebViewShouldStartLoading, url is ", url)
            return true
        end)
        self._webView:setOnDidFinishLoading(function(sender, url)
            print("onWebViewDidFinishLoading, url is ", url)
        end)
        self._webView:setOnDidFailLoading(function(sender, url)
            print("onWebViewDidFinishLoading, url is ", url)
        end)  
        img:addChild(self._webView)  
    end
    return true
end
function webViewLayer:onEnter()
    print("webViewLayer onEnter")
    me.doLayout(self, me.winSize)
end
function webViewLayer:onEnterTransitionDidFinish()
    print("webViewLayer onEnterTransitionDidFinish")
end
function webViewLayer:onExit()
    print("webViewLayer onExit")
end
function webViewLayer:close()
    self:removeFromParent()
end
