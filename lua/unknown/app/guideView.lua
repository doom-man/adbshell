guideView = class("guideView", function ()
    local layer = ccui.Widget:create()
    layer:setContentSize(me.winSize)
    layer:setAnchorPoint(cc.p(0,0))
    layer:setPosition(cc.p(0,0))
    return layer
end)

guideViewInstace = nil
guideView.__index = guideView
function guideView:create()
    local layer = guideView.new()
    if layer then
        if layer:init() then
            layer:registerScriptHandler( function(tag)
                if "enter" == tag then
                    layer:onEnter()
                elseif "exit" == tag then
                    layer:onExit()
                end
            end )
            return layer
        end
    end
    return nil
end
function guideView:ctor()
    print("guideView:ctor()")
    self.tipsStr = nil
    --手指引导部分
    self.cNode = nil --clippingNode节点
    self.node = nil     --裁剪节点
    self.stencil = nil --蒙层底图

    self.pngSize = nil
    self.pos = nil
    self.swallow = false
    self.bgVisible = false
    self.anim = nil --引导层上的那个手的动画


    --对话框引导部分
    self.dLayer = nil
    self.headImg = nil
    self.dialog = nil

    self.nextStepCB = nil

    self.touchGo = false --判断touch.began和touch.end是否为同一区域的触摸

    self.autoClose = true -- 是否界面触摸后自动关闭()
end
function guideView:init()
    self.tipsStr = "领主大人，跟着我的手!"
    return true
end
function guideView:setTipsInfo(str_)
    self.tipsStr = str_
end
function guideView:onEnter()
    print("guideView:onEnter()")
    me.doLayout(self,me.winSize)  
    self:setTouchEnabled(true)
    self:setName("guideViewIndex")
end

function guideView:close()
    print("guideView:close()")
    guideViewInstace = nil
    if self.anim then
        self.anim:stopAllActions()
    end
    if self.ani then
        self.ani:stopAllActions()
    end
    self:removeFromParentAndCleanup(true)
end
function guideView:onExit()
    guideViewInstace = nil
    print("guideView:onExit()")
end

--@param node_ 需要显示的节点位置
--@param swallow_ 是否需要强制引导
--@param bgVisable_ 是否显示蒙灰背景图
function guideView:showGuideView(node_,swallow_,bgVisable_,cb_,png_,autoClose_)
    print("guideView:showGuideView(node_,swallow_,bgVisable_,cb_,png_,autoClose_)")
    if node_ == nil then
        __G__TRACKBACK__("guideView:showGuideView node_ = nil !")
        return
    end
    self.swallow = swallow_
    self.bgVisible = bgVisable_
    self.nextStepCB = cb_
    self.nodePng = png_
    self.autoClose = true
    if autoClose_ ~= nil then
        self.autoClose = autoClose_
    end
    local pos_ = node_:convertToWorldSpace(cc.p(node_:getContentSize().width/2,node_:getContentSize().height/2))
    local fView = mainCity
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        fView = pWorldMap        
    end
    self.pos = fView:convertToNodeSpace(pos_)    
    --79.4,1201
    self.pngSize = cc.size(node_:getContentSize().width,node_:getContentSize().height)
    self:addClippingLayer()
end
function guideView:showGuideViewCellBtn(cell,node_,swallow_,bgVisable_,cb_,png_,autoClose_)
    print("guideView:showGuideView(node_,swallow_,bgVisable_,cb_,png_,autoClose_)")
    if node_ == nil then
        __G__TRACKBACK__("guideView:showGuideView node_ = nil !")
        return
    end
    self.swallow = swallow_
    self.bgVisible = bgVisable_
    self.nextStepCB = cb_
    self.nodePng = png_
    self.autoClose = true
    if autoClose_ ~= nil then
        self.autoClose = autoClose_
    end
    local x,y = node_:getPosition()
    local pos_ = cell:convertToWorldSpace(cc.p(x,y))
    local fView = mainCity
    if CUR_GAME_STATE == GAME_STATE_WORLDMAP or CUR_GAME_STATE == GAME_STATE_WORLDMAP_NETBATTLE then
        fView = pWorldMap        
    end
    self.pos = fView:convertToNodeSpace(pos_)    
    --79.4,1201
    self.pngSize = cc.size(node_:getContentSize().width,node_:getContentSize().height)
    self:addClippingLayer()
end
--专门针对TableView的处理
function guideView:showGuideViewForTableCell(node_,swallow_,bgVisable_,cellSize_,cb_)
    self.swallow = swallow_
    self.bgVisible = bgVisable_
    self.nextStepCB = cb_
    local pos_ = node_:convertToWorldSpace(cc.p(cellSize_.width/2,cellSize_.height/2))
    self.pos = mainCity:convertToNodeSpace(pos_)
    self.pngSize = cc.size(node_:getContentSize().width,node_:getContentSize().height)
    self:addClippingLayer()
end
--针对ScrollView的处理
function guideView:showGuideViewForScroll(node_,swallow_,bgVisable_,cb_,png_,autoClose_)
    self.swallow = swallow_
    self.bgVisible = bgVisable_
    self.nextStepCB = cb_
    self.nodePng = png_
    self.autoClose = true
    if autoClose_ ~= nil then
        self.autoClose = autoClose_
    end

    local pos_ = node_:getParent():convertToWorldSpace(cc.p(node_:getPositionX()+node_:getContentSize().width/2,
                                                            node_:getPositionY()+node_:getContentSize().height/2))
    self.pos = mainCity:convertToNodeSpace(pos_)
    self.pngSize = cc.size(node_:getContentSize().width,node_:getContentSize().height)

    self:addClippingLayer()
end

--针对工人分配中List的处理
function guideView:showGuideViewForList(node_,swallow_,bgVisable_,cb_,png_,autoClose_,f_)
    self.swallow = swallow_
    self.bgVisible = bgVisable_
    self.nextStepCB = cb_
    self.nodePng = png_
    self.autoClose = true
    if autoClose_ ~= nil then
        self.autoClose = autoClose_
    end
    local pos_ = f_:convertToWorldSpace(cc.p(node_:getPositionX()+node_:getContentSize().width/2,node_:getPositionY()+node_:getContentSize().height/2))
    self.pos = mainCity:convertToNodeSpace(pos_)
    self.pngSize = cc.size(node_:getContentSize().width,node_:getContentSize().height)
    self:addClippingLayer()
end

function guideView:showDialog(dialogId_,cb_,autoClose_)
    print("guideView:showDialog")
    local txt = cfg[CfgType.GUIDE_TEXT][me.toNum(dialogId_)].desc
    if me.isValidStr(txt) == false then
        showTips("txt = nil!!!  dialogId_ = "..dialogId_)
        return
    end
    self.showCanTouch = false
    me.DelayRun(function ()
        self.showCanTouch = true
    end,0.75)
    if self.anim then
         self.anim:setVisible(false)
    end
    if self.cNode then
        self.cNode:setVisible(false)
    end
    self.autoClose = false
    if autoClose_ ~= nil then
        self.autoClose = true
    end
    if cb_ then
        self.nextStepCB = cb_
    end
    self:setSwallowTouches(true)
    if self.dLayer == nil then
        self.dLayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
        self.dLayer:setContentSize(cc.size(me.winSize.width,me.winSize.height))
        self:addChild(self.dLayer)
        
        self.bg = ccui.ImageView:create()
        self.bg:loadTexture("yindao_beijing_gongyong.png", me.localType)   
        self.bg:setAnchorPoint(cc.p(0.5, 0.5))
        
        self.headImg = ccui.ImageView:create()
        local headImgStr = "yindao_nvsheng.png"
        self.headImg:loadTexture(headImgStr, me.localType)   
        self.headImg:setAnchorPoint(cc.p(0.5, 0.5))
        local oofx = 40
        local ofx = 460 + oofx
        self.headImg:setPosition(cc.p(ofx,me.winSize.height/2+30))
        self.dLayer:addChild(self.headImg)
        self.dLayer:addChild(self.bg)
        self.bg:setPosition(me.winSize.width/2+oofx, 
        self.headImg:getPositionY() - self.headImg:getContentSize().height /2  + self.bg:getContentSize().height /2-15)
        self.ani = ccui.ImageView:create()
        self.ani:loadTexture("yindao_anniu_zhengchang.png", me.localType)   
        self.ani:setAnchorPoint(cc.p(0.5, 0.5))
        self.ani:setPosition(cc.p(self.bg:getContentSize().width-45,45))
        self.bg:addChild(self.ani)

        self.dialog = cc.Label:createWithTTF(txt,"UIres/font/fzlsjt.ttf",24)
        self.dialog:setColor(me.convert3Color_("e7ddb9"))
        self.dialog:setAnchorPoint(cc.p(0.5, 0.5))
        self.dialog:setDimensions(self.bg:getContentSize().width-88,self.bg:getContentSize().height-15)
        self.dialog:setPosition(cc.p(self.bg:getContentSize().width/2, self.bg:getContentSize().height/2-35))
        self.bg:addChild(self.dialog)
        me.registGuiTouchEvent(self,function (node,event)
            if event ~= ccui.TouchEventType.began then
                return
            end 
            if self.showCanTouch == true then
                if self.nextStepCB then
                    self.nextStepCB()
                end
                if self.autoClose then
                    me.DelayRun(function ()
                        if self.cNode == nil or self.cNode:isVisible() == false then --如果有ClippingNode层加入了，就不调用Close，不然会关闭整个引导层,导致bug
                            
                             self:close()
                            
                        end                        
                    end,0.25)
                end            
            end
        end)
    else
        self.dLayer:setVisible(true)
        self.dialog:setString(txt)
    end
end

function guideView:addClippingLayer()
    self.clippingLayerCanTouch = false
    me.DelayRun(function ()
        self.clippingLayerCanTouch = true
    end,0.3)

    self.stencil = cc.LayerColor:create(cc.c4b(0,0,0,0))
    self.stencil:setContentSize(cc.size(me.winSize.width,me.winSize.height))
    self.cNode = cc.ClippingNode:create()
    self.node = cc.Node:create()
    self.cNode:setStencil(self.node)
    self.cNode:setAlphaThreshold(0)
    self.cNode:setInverted(true)
    self.cNode:addChild(self.stencil)
    self:addChild(self.cNode)
    self.cNode:setVisible(self.bgVisible)
    --self.cNode:setVisible(true)
    self:setSwallowTouches(self.swallow)
    if self.nodePng then
        self.sp = ccui.Scale9Sprite:create(self.nodePng)    
    else
        self.sp = ccui.Scale9Sprite:create("gongyong_yindao_yuan.png")    
        self.sp:setScale9Enabled(true)
        self.sp:setCapInsets(cc.rect(0,0,self.pngSize.width,self.pngSize.height));
        self.sp:setContentSize(self.pngSize)
    end
    self.sp:setPosition(cc.p(self.pos.x,self.pos.y))
    self.node:addChild(self.sp)

    local function onTouch(sender, event)
        print("clippingLayerCanTouch")
        if self.clippingLayerCanTouch ~= true then
            return
        end
        
            location = sender:getTouchBeganPosition()
            if self.swallow then
                if event == ccui.TouchEventType.began and cc.rectContainsPoint(self.sp:getBoundingBox(), location) then
                    self:setSwallowTouches(false)
                end
                if event == ccui.TouchEventType.began then    
                    if cc.rectContainsPoint(self.sp:getBoundingBox(), location) then
                        if self.nextStepCB then
                            self.nextStepCB()
                        end 
                        if self.autoClose == true then
                             me.DelayRun(function (args)
                                    self:close()
                             end)
                        end
                    else
                        showTips(self.tipsStr)
                        self:setSwallowTouches(true)
                    end
                end            
            else
                self:setSwallowTouches(false)
                if event == ccui.TouchEventType.ended then
                    if self.nextStepCB then
                        self.nextStepCB()
                    end
                    if self.autoClose == true then
                         me.DelayRun(function (args)
                                   if self.close then
                                    self:close()
                                   end
                         end)
                    end
                end
            end
        
    end
    me.registGuiTouchEvent(self,onTouch)
    self:showHandAnim()
    if self.dLayer then
        self.dLayer:setVisible(false)
    end
end

function guideView:slideAnimForAllot()
    self.anim:stopAllActions()
    local a1 = cc.MoveTo:create(1,cc.p(self.pos.x+150,self.pos.y))
    local a2 = cc.MoveTo:create(0.3,cc.p(self.pos.x,self.pos.y))
    local seq = cc.Sequence:create(a1, a2)
    local f = cc.RepeatForever:create(seq)
    self.anim:runAction(f)
end
--设置小手的翻转
function guideView:setHandFilp(fx_,fy_)
    self.filpX,self.filpY = false,false
    if fx_ then
        self.filpX = true
    end
    if fy_ then
        self.filpY = true
    end
end
function guideView:showHandAnim()
    if self.anim == nil then
        self.guardAni = createArmature("guardAni")
        self:addChild(self.guardAni)
        self.guardAni:getAnimation():playWithIndex(0)
        self.anim = ccui.ImageView:create("zhucheng_caijie_liangshi.png")
        self.anim:setAnchorPoint(cc.p(0,0))
        self:addChild(self.anim)
    end
    self.anim:stopAllActions()
    self.anim:setPosition(cc.p(self.pos.x,self.pos.y))
    self.guardAni:setPosition(cc.p(self.pos.x,self.pos.y))
    if self.anim then
         self.anim:setVisible(true)
    end
    local offX,offY = 25,25
    if self.filpX then
        self.anim:setRotation(90)
        offY = -25
    end
    if self.filpY then
        self.anim:setRotation(270)
        offX = -25
    end
    if self.filpY and self.filpX then
        self.anim:setRotation(180)
    end
    local a1 = cc.MoveTo:create(0.5,cc.p(self.pos.x+offX,self.pos.y+offY))
    local a2 = cc.MoveTo:create(0.3,cc.p(self.pos.x,self.pos.y))
    local seq = cc.Sequence:create(a1, a2)
    local f = cc.RepeatForever:create(seq)
    self.anim:runAction(f)
end
function guideView:getInstance()
    if guideViewInstace == nil then
        guideViewInstace = guideView:create()   
    end
    return guideViewInstace
end
