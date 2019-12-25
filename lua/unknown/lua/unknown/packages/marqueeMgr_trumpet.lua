-- [Comment]
-- jnmo 跑马灯
marqueeMgr_trumpet = class("marqueeMgr_trumpet")
marqueeMgr_trumpet.__index = marqueeMgr_trumpet
m_marqueeMgr_trumpet = nil

function marqueeMgr_trumpet:ctor()
    print("marqueeMgr_trumpet:ctor()")
    self.m_queue = {}
    self.m_curMarquee = nil
    self.isShowing = false
end

function marqueeMgr_trumpet:update()
    local s = me.runningScene()
    local bg = s:getChildByTag(tag_quee)
    if not bg then
        self.isShowing  = false
    end
    if self.isShowing then
        return
    end
    if self.m_curMarquee == nil then
        if  #self.m_queue > 0 then
--            if #self.m_queue > 1 then
--                local function comp(a, b)
--                    return  me.toNum(a.plv) > me.toNum(b.plv)
--                end
--                table.sort(self.m_queue, comp)               
--            end
            self.m_curMarquee = self.m_queue[1]
            table.remove(self.m_queue,1)
--            dump(self.m_curMarquee)
            if self.m_curMarquee.num > 0 then
                self:showMarquee()
            else
                self.m_curMarquee = nil
                self:update()
            end
        end
    else
        -- num 次数
        -- txt 文i9
        -- plv 优先级
        -- -
        if self.m_curMarquee.num > 0 then
            self:showMarquee()
        else
            self.m_curMarquee = nil
            self:update()
        end
    end

end
function marqueeMgr_trumpet:addQuee(quee)
    table.insert(self.m_queue,quee)
    self:update()
end
tag_quee = 0xffee22
spd_quee = 40
function marqueeMgr_trumpet:showMarquee()
    self.m_curMarquee.num = self.m_curMarquee.num - 1
    self.isShowing = true
    local s = me.runningScene()
    local bg = s:getChildByTag(tag_quee)
    if bg then
        bg:setVisible(true)
    else
        bg = me.createNode("marqueeLayer_trumpet.csb")
        bg:setTag(tag_quee)
        s:addChild(bg, me.MAXZORDER + 1)
    end
    me.doLayout(me.assignWidget(bg,"fixLayout"),me.winSize)
    local rquee = mRichText:create(self.m_curMarquee.txt)
    local icon = self.m_curMarquee.icon
    local Panel_chatBoard = me.assignWidget(bg,"Panel_chatBoard")
    local Image__weChat = me.assignWidget(bg,"Image__weChat")
    local function arrive(node)
        self.isShowing = false
        bg:setVisible(false)
        node:removeAllChildren()
        self:update()
    end
    Image__weChat:loadTexture("item_"..icon..".png",me.localType)
    Image__weChat:addChild(rquee)
    rquee:setPosition(50,14)
    Image__weChat:setPositionX(Panel_chatBoard:getContentSize().width-25)
    local moveto_Img = cc.MoveBy:create(Panel_chatBoard:getContentSize().width / spd_quee, 
                               cc.p(-rquee:getContentSize().width - Panel_chatBoard:getContentSize().width-25, 0))
    local callf = cc.CallFunc:create(arrive)
    Image__weChat:runAction(cc.Sequence:create(moveto_Img,callf))
end
function marqueeMgr_trumpet.getInstance()
    if m_marqueeMgr_trumpet == nil then
        m_marqueeMgr_trumpet = marqueeMgr_trumpet.new()
        me.registTimer(-1,function (dt)
            m_marqueeMgr_trumpet:update(dt)
        end,10)
    end
    return m_marqueeMgr_trumpet
end

