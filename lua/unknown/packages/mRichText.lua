--[[
require "mRichText"
local str =  "<txt0014,ff00ff>[活动通知]#n&<txt0018,ffaaf0>[大家注意了这是新的富文本]#n哈哈#n99999&"
local rt = mRichText:create(str,200)
rt:setPosition(320,600)
self:addChild(rt)

<txt0014,ff00ff>
类型标示符号
txt 文本   -00 暂无，-14 字体大小，ff00ff 颜色
img 图片   -00 X缩放*100 -14Y缩放*100 ------
ani 动画   ---------------------------------
]]
mRichText = class("mRichText", function()
    return ccui.Layout:create()
end)
mRichText.__index = mRichText
function mRichText:create(text_, width_, font_, v_)
    local label = mRichText.new() 
    if label then
        label.width = width_ or nil
        label.text = text_
        label.font = font_ or "fzlsjt.ttf"
        label.space = v_ or 0
        label.canTouch  = false
        if label:init() then           
            label:registerScriptHandler( function(tag)
                if "enter" == tag then
                    label:onEnter()
                elseif "exit" == tag then
                    label:onExit()
                end
            end )
            return label
        end
    end
    return nil
end

--[[ 解析16进制颜色rgb值 ]]
function mRichText:convertColor_(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end
    local b = string.sub(xStr, -2, -1)
    local g = string.sub(xStr, -4, -3)
    local r = string.sub(xStr, -6, -5)
    local red = toTen(r)
    local green = toTen(g)
    local blue = toTen(b)
    return cc.c3b(red, green, blue)
end
function mRichText:parseHead(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end
    local fontsize = string.sub(xStr, -2, -1)
    local touchType = string.sub(xStr, -4, -3)
    local headType = string.sub(xStr, -7, -5)
    local fsize = toTen(fontsize)
    local ttype = toTen(touchType)
    return headType, ttype, fsize
end
function mRichText:setString(text_)
    local result = { }
    local index = 1
    local getCheck = false
    local str_ = ""
    local startPos, endPos, head, color, bodyText = nil ,nil ,nil,nil
    while (true) do
        if string.len(text_) <= 7 then
            break
        end
        startPos, endPos, head, color, bodyText = string.find(text_, "<(%w-),(%x-)>(.-)&")
        if startPos and endPos and bodyText and head and color then
            local item = { }
            item.type, item.tType, item.fontSize = self:parseHead(head)
            item.color = self:convertColor_(color)
            item.cnum = tonumber("0x" .. color)
            item.ofx = tonumber("0x" .. color)
            item.text = bodyText
            str_ = str_ .. bodyText
            item.id = index
            table.insert(result, index, item)
            index = index + 1
            text_ = string.sub(text_, endPos, -1)
            getCheck = true            
        else
            break
        end
    end
    if getCheck and string.len(str_) > 0 then
        self:constructLabel(result)
    else
        local label = ccui.RichText:create()
        label:ignoreContentAdaptWithSize(false)
        label:setContentSize(cc.size(self.width or me.winSize.width, 0))
        label:setVerticalSpace(self.space or 0)
        if string.len(text_) > 0 then
            local rt = ccui.RichElementText:create(1, cc.c3b(255, 255, 255), 255, text_, self.font, 20)
            label:pushBackElement(rt)
        end
        label:formatText()
        self:setContentSize(label:getContentSize())
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPosition(label:getContentSize().width / 2, label:getContentSize().height / 2)
        self:addChild(label)
    end
end
function mRichText:constructLabel(strTable)
    self:removeAllChildren()
    local ofx = 0
    local ofy = 0
    local tempText = ""
    local maxFontSize = 0
    local nearMaxFont = 0
    local height = 0
    local indexTag = 100
    local function registListener(node_, id)
        local function Nodecallback(sender, event)
            if self.callback then
                if event == ccui.TouchEventType.began then
                   
                elseif event == ccui.TouchEventType.moved then
                    
                elseif event == ccui.TouchEventType.ended then
                   me.clickAni6(sender)

                elseif event == ccui.TouchEventType.canceled then
                    me.clickAni6(sender)
                end
                self.callback(sender, event)
            end
        end
        node_.pId = id
        node_:setTouchEnabled(true)
        node_:addTouchEventListener(Nodecallback)
    end
    --    self:setBackGroundColor(cc.c3b(1,222,0))
    --    self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self.label = ccui.RichText:create()
    self.label:setVerticalSpace(self.space or 0)
    local width = 0
    for key, var in pairs(strTable) do
        if var.type == "txt" then
            if string.len(var.text) > 0 then
                local rt = ccui.RichElementText:create(indexTag, var.color, 255, var.text, self.font, var.fontSize)             
                if var.tType and var.tType > 0 then
                    self.canTouch = true
                    self.targetPos = {}
                    _,_,self.targetPos.x,self.targetPos.y = string.find(var.text,"%((%d-),(%d-)%)")
                    self.targetPos.x = me.toNum(self.targetPos.x)
                    self.targetPos.y = me.toNum(self.targetPos.y)
                end
                self.label:pushBackElement(rt)
            end
        elseif var.type == "img" then 
            local b = cc.FileUtils:getInstance():isFileExist(var.text)
            local spr = ccui.ImageView:create(var.text)
            if not spr then
               break
            end        
            if var.tType and var.tType > 0 then
                spr:setScaleX(var.tType / 100.0)
            end
            if var.fontSize and var.fontSize > 0 then
                spr:setScaleY(var.fontSize / 100.0)
            end
            if var.cnum  then
                registListener(spr,var.cnum)
            end
            local cItem = ccui.RichElementCustomNode:create(indexTag, cc.c3b(255, 255, 255), 255, spr)           
            self.label:pushBackElement(cItem)
        elseif var.type == "cus" then
            local b = cc.FileUtils:getInstance():isFileExist(var.text)
            local spr = me.createSprite(var.text)
            spr:setScale(var.fontSize / 100.0)
            local cItem = ccui.RichElementCustomNode:create(indexTag, cc.c3b(255, 255, 255), 255, spr)          
            self.label:pushBackElement(cItem)
       elseif var.type == "pet" then
            local spr = me.createNode("petCell.csb")
           if var.tType and var.tType > 0 then
                spr:setScaleX(var.tType / 100.0)
            end
            if var.fontSize and var.fontSize > 0 then
                spr:setScaleY(var.fontSize / 100.0)
            end
            local quality = me.assignWidget(spr,"quality")
            local petIcon = me.assignWidget(spr,"petIcon")
            quality:loadTexture(petCell.getQuality(var.color.b))
            --quality:ignoreContentAdaptWithSize(true)
            --petIcon:ignoreContentAdaptWithSize(true)
           -- petIcon:setPosition(cc.p(quality:getContentSize().width / 2,0))
            petIcon:setVisible(true)
            if var.cnum  then
                registListener(petIcon,var.cnum)
            end
            quality:setVisible(true)
            petIcon:loadTexture(var.text)
            me.assignWidget(spr,"numBg"):setVisible(false)
            local cItem = ccui.RichElementCustomNode:create(indexTag, cc.c3b(255, 255, 255), 255, spr)
            self.label:pushBackElement(cItem)
        elseif var.type == "ani" then
            local ani = createArmature(var.text)
            ani:getAnimation():play("hq")
            local cItem = ccui.RichElementCustomNode:create(indexTag, cc.c3b(255, 255, 255), 255, ani)
            self.label:pushBackElement(cItem)
        end
        indexTag = indexTag + 1
    end
    if self.width == nil then
        self.label:ignoreContentAdaptWithSize(true)
        local s = self.label:getContentSize()
        self.label:formatText()
        s = self.label:getContentSize()
        width = self.label:getContentSize().width
    end
    local s = self.label:getContentSize()
    self.label:ignoreContentAdaptWithSize(false)
    self.label:setContentSize(cc.size(self.width or width, 0))
    self.label:formatText()
    s = self.label:getVirtualRendererSize()
    s = self.label:getContentSize()
    self:setContentSize(s)

    self.label:setAnchorPoint(cc.p(0.5, 0.5))
    self.label:setPosition(self.label:getContentSize().width / 2, self.label:getContentSize().height * 3 / 2)
    self:addChild(self.label)
    self:setSwallowTouches(false)
    self.label:setSwallowTouches(false)
    
    if self.canTouch then
        me.registGuiClickEvent(self,function ()
            if self.callback and canJumpWorldMap() then
                self.callback(self.targetPos)
            end
        end)
    end
end

function mRichText:getTargetPos()
    return self.targetPos
end

function mRichText:ctor()
    self.callback = nil
    self.targetPos  = nil
end
function mRichText:registCallback(call_)
    self.callback = call_
end

function mRichText:init()
    self:setString(self.text)
    return true
end
function mRichText:onEnter()
    
end
function mRichText:onExit()

end