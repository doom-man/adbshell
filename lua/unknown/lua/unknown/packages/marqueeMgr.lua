-- [Comment]
-- jnmo 跑马灯
marqueeMgr = class("marqueeMgr")
marqueeMgr.__index = marqueeMgr
m_marqueeMgr = nil

function marqueeMgr:ctor()
    print("marqueeMgr:ctor()")
    self.m_queue = {}
    self.m_curMarquee = nil
    self.isShowing = false
end

function marqueeMgr:update()
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
            if #self.m_queue > 1 then
                local function comp(a, b)
                    return  me.toNum(a.plv) > me.toNum(b.plv)
                end
                table.sort(self.m_queue, comp)               
            end
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
function marqueeMgr:addQuee(quee)
    table.insert(self.m_queue,quee)
    self:update()
end
tag_quee = 0xffee22
spd_quee = 40
function marqueeMgr:showMarquee()
    self.m_curMarquee.num = self.m_curMarquee.num - 1
    self.isShowing = true
    local s = me.runningScene()
    local bg = s:getChildByTag(tag_quee)
    if bg then
        bg:setVisible(true)
    else
        bg = me.createNode("marqueeLayer.csb")
        bg:setTag(tag_quee)
        s:addChild(bg, me.MAXZORDER + 1)
       -- bg:setPosition(me.winSize.width / 2, me.winSize.height - 150);
    end
    me.doLayout(me.assignWidget(bg,"fixLayout"),me.winSize)
    if string.find(self.m_curMarquee.txt,"<txt")==nil then
        self.m_curMarquee.txt = "<txt0024,ffffff>"..self.m_curMarquee.txt.."&"
    end
    local rquee = mRichText:create(self.m_curMarquee.txt)
    rquee:setPositionY(5)
    local Image_bg = me.assignWidget(bg,"Image_bg")
    Image_bg:addChild(rquee)
    rquee:setPosition(Image_bg:getContentSize().width,(Image_bg:getContentSize().height - rquee:getContentSize().height-10)/2 )
    local function arrive(node)
        self.isShowing = false
        bg:setVisible(false)
        node:removeFromParentAndCleanup(true)
        self:update()
    end
    local moveto = cc.MoveBy:create(Image_bg:getContentSize().width / spd_quee, cc.p(-rquee:getContentSize().width - Image_bg:getContentSize().width, 0))
    local callf = cc.CallFunc:create(arrive)
    rquee:runAction(cc.Sequence:create(moveto, callf))
end
function marqueeMgr.getInstance()
    if m_marqueeMgr == nil then
        m_marqueeMgr = marqueeMgr.new()
        me.registTimer(-1,function (dt)
                  m_marqueeMgr:update(dt)
        end,10)
    end
    return m_marqueeMgr
end

