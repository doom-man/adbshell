--[Comment]
--jnmo
downloadRebate = class("downloadRebate",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
downloadRebate.__index = downloadRebate
function downloadRebate:create(...)
    local layer = downloadRebate.new(...)
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
function downloadRebate:ctor()   
    print("downloadRebate ctor") 
end
function downloadRebate:init()   
    print("downloadRebate init")
	
    return true
end
function downloadRebate:setData(pData)
    if pData then
       local Node_Prop = me.assignWidget(self,"Node_Prop")     
       local i = 0
       self.mData = pData
       Node_Prop:removeAllChildren()
       for key, var in pairs(pData["hortations"]) do
           local cfg = cfg[CfgType.ETC][var[1]]
           local prop_quiltay = me.assignWidget(self,"next_prop_quiltay"):clone():setVisible(true)
           prop_quiltay:loadTexture(getQuality(cfg.quality),me.localType)
           prop_quiltay:setPosition(cc.p(100*i,0))

           me.assignWidget(prop_quiltay, "next_prop_icon"):loadTexture("item_"..cfg.icon..".png",me.localType)
           
           me.assignWidget(prop_quiltay, "Prop_num"):setString(var[2])
           i = i + 1
           me.assignWidget(prop_quiltay,"Button_item"):setTag(i)
           me.registGuiClickEventByName(prop_quiltay, "Button_item", function(node)        
            local pTag = me.toNum(node:getTag())
            local pData = pData["hortations"][pTag]                      
            local defId = pData[1]
            local pNum = pData[2]
               showPromotion(defId,pNum)              
           end )
           Node_Prop:addChild(prop_quiltay)
       end

       local pContent = me.assignWidget(self,"content")
       pContent:setString(pData["content"])

       if pData["pType"] == recomondPromView.DOWNLOADREBATE or pData["pType"] == recomondPromView.PINGLUN then -- 跳转
            local pbuttonStr = "去下载"
            if pData["pType"] == recomondPromView.PINGLUN then
               pbuttonStr = "去评论"
            end
            if pData["status"] == 1 then
                pbuttonStr= "领取"
            elseif pData["status"] == 2 then
                pbuttonStr= "已领取"        
            end
            me.assignWidget(self,"Button_download"):setTitleText(pbuttonStr)
            me.registGuiClickEventByName(self,"Button_download",function (node)          
                if self.mData["status"] == 0 then
                --    mSkipTimeBool = true    
                    mSkipTimeId = self.mData["id"]
                 --   NetMan:send(_MSG.Popularize_Skip_Time(mSkipTimeId,0))     
                    self:openAppstore(pData["link"])
                elseif self.mData["status"] == 1 then
                    NetMan:send(_MSG.Popularize_Draw_Rewards(self.mData["id"]))                                
                end            
            end)
        elseif pData["pType"] == recomondPromView.SHARE then -- 分享
            local pbuttonStr = "分享"
            if pData["status"] == 1 then
                pbuttonStr= "领取"
            elseif pData["status"] == 2 then
                pbuttonStr= "已领取"        
            end
            me.assignWidget(self,"Button_download"):setTitleText(pbuttonStr)
            me.registGuiClickEventByName(self,"Button_download",function (node)          
                if self.mData["status"] == 0 then
                   -- 分享
                   local Node_share = Node_share:create("Node_share.csb")                    
                   Node_share:setPosition(cc.p(me.winSize.width / 2, me.winSize.height / 2))
                   mainCity:addChild(Node_share,me.MAXZORDER)                                                      
                elseif self.mData["status"] == 1 then
                    NetMan:send(_MSG.Popularize_Draw_Rewards(self.mData["id"]))                                
                end            
            end)
       end
      
    end
end
function downloadRebate:openAppstore(url_) -- 推广
    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or(cc.PLATFORM_OS_IPAD == targetPlatform) or(cc.PLATFORM_OS_MAC == targetPlatform) then
        local args = { url = url_ }
        local luaoc = require "cocos.cocos2d.luaoc"
        local className = "AppController"
        local ok, ret = luaoc.callStaticMethod(className, "openAppstore", args)
        if not ok then
            print("老蒋是二货")
        else
            mSkipTimeBool = true
            NetMan:send(_MSG.Popularize_Skip_Time(mSkipTimeId,0))     
            cc.Director:getInstance():resume() 
            print("The ret is:", ret)
        end
    else
        print("仅支持IOS")
    end
end

function downloadRebate:onEnter()
    print("downloadRebate onEnter") 
	me.doLayout(self,me.winSize)  
end
function downloadRebate:onEnterTransitionDidFinish()
	print("downloadRebate onEnterTransitionDidFinish") 
end
function downloadRebate:onExit()
    print("downloadRebate onExit")    
end
function downloadRebate:close()
    self:removeFromParentAndCleanup(true)  
end
