-- [Comment]
-- jnmo
serverGroupCell = class("serverGroupCell", function(...)
    local arg = { ...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        -- 这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return me.assignWidget(arg[1], arg[2]):clone()
    end
end )
serverGroupCell.__index = serverGroupCell
function serverGroupCell:create(...)
    local layer = serverGroupCell.new(...)
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
function serverGroupCell:ctor()
    print("serverGroupCell ctor")
end
function serverGroupCell:init()
    print("serverGroupCell init")
    self.choose = me.assignWidget(self, "choose")
    self.text = me.assignWidget(self, "Text_t")
    self.text:enableShadow(cc.c4b(0x0, 0x0, 0x0, 0xff), cc.size(2, -2))   
    return true
end
function serverGroupCell:initData(idx,b)
     self.choose:setVisible(b)
     local num = #user.servsers 
     if b then
        self.text:setTextColor(cc.c3b(232,225,144))
     else
        self.text:setTextColor(cc.c3b(192,178,151))
     end
     local row = math.floor(num / 10)
     if #user.servsers % 10 ~= 0 then
           row = math.ceil(num / 10)
     end 
         
     if idx == 1 then
         self.text:setString("最近登录")
     else
         self.text:setString( ((row - (idx-1))*10 + 1) .."服-"..  (row - (idx-2)) *10 .."服" )        
     end
end
function serverGroupCell:onEnter()
    print("serverGroupCell onEnter") 

end
function serverGroupCell:onEnterTransitionDidFinish()
	print("serverGroupCell onEnterTransitionDidFinish") 
end
function serverGroupCell:onExit()
    print("serverGroupCell onExit")    
end
function serverGroupCell:close()
    self:removeFromParent()  
end

