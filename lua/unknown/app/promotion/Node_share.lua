 --[Comment]
--jnmo
Node_share = class("Node_share",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
Node_share.__index = Node_share
function Node_share:create(...)
    local layer = Node_share.new(...)
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
function Node_share:ctor()   
    print("Node_share ctor") 
end
function Node_share:init()   
  print("Node_share init")    
	me.registGuiClickEventByName(self,"close",function (node)
        self:close()     
    end)    
    local data = self:getData()
    local tmp = me.split(data.content,"|")
    local title = tmp[1]
    local text = tmp[2]
    local function call_back( p,stCode,err ) 
           -- body
           if stCode == 200 then
                showTips("分享成功")
           else
                showTips("分享失败")
           end
    end       
    mSkipTimeId = 3   
    mShareHelper:getInstance():registCallBack(call_back)   
    -- 新浪
    me.registGuiClickEventByName(self,"Button_sina",function (node)
      mSkipTimeBool = true
      mShareHelper:getInstance():Share("0",title,text,data.image,data.link)
    end)
     
    -- 微信
    me.registGuiClickEventByName(self,"Button_Wechat",function (node)
      mSkipTimeBool = true
      mShareHelper:getInstance():Share("1",title,text,data.image,data.link)
    end)
    -- 微信朋友圈
    me.registGuiClickEventByName(self,"Button_Friend",function (node)
       mSkipTimeBool = true
       mShareHelper:getInstance():Share("2",title,text,data.image,data.link)
    end)
    return true
end
function Node_share:onEnter()
    print("Node_share onEnter") 
	me.doLayout(self,me.winSize)  
end
function Node_share:onEnterTransitionDidFinish()
	print("Node_share onEnterTransitionDidFinish") 
end
function Node_share:getData()
   local id = 3
   local data = user.popularizeData[id]
   return data
end
function Node_share:onExit()
    print("Node_share onExit")    
end
function Node_share:close()
    self:removeFromParentAndCleanup(true)  
end

