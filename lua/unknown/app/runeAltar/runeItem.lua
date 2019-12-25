runeItem = class("runeItem",function (...)
    local arg = {...}
    if table.getn(arg) == 1 then
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        return arg[1]
    end
end)
function runeItem:create(...)
    local layer = runeItem.new(...)
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

function runeItem:ctor()

end

function runeItem:onEnter()

end

function runeItem:onExit()

end

function runeItem:init()
    self.icon = me.assignWidget(self, "icon")
    self.box = me.assignWidget(self, "box")
    self.lvBox = me.assignWidget(self, "lvBox")
    self.typeBox = me.assignWidget(self, "typeBox")
    self.nameTxt = me.assignWidget(self, "nameTxt")
    self.lvTxt = me.assignWidget(self, "lvTxt")
    self.typeIco = me.assignWidget(self, "typeIco")
    self.selected = me.assignWidget(self, "selected")
    self.starNode = me.assignWidget(self, "starNode")
    self.star = me.assignWidget(self, "star")
    self.star1 = me.assignWidget(self, "star1")
    self.lock = me.assignWidget(self, "lock")
    self.newIcon = me.assignWidget(self, "newIcon")
    self.skillPanel = me.assignWidget(self, "skillPanel")
    self.skillIco = me.assignWidget(self.skillPanel, "skillIco")
    self.skillLv = me.assignWidget(self.skillPanel, "skillLv")

    return true
end

function runeItem:setData(data)
    self.data=data
    local baseData = cfg[CfgType.RUNE_DATA][data.cfgId]
    self.icon:loadTexture(getRuneIcon(baseData.icon), me.plistType)
    self.box:loadTexture("levelbox"..baseData.level..".png", me.plistType)
    self.lvBox:loadTexture("levelbox"..baseData.level.."_c1.png", me.plistType)
    self.typeBox:loadTexture("levelbox"..baseData.level.."_c2.png", me.plistType)
    self.nameTxt:setString(baseData.name)

    self.typeIco:loadTexture("rune_type_"..baseData.type..".png",me.plistType)

    self.lvTxt:setString(cfg[CfgType.RUNE_STRENGTH][data.glv].level)

    if data.lock==true then
        self.lock:setVisible(true)
    else
        self.lock:setVisible(false)
    end

    local skillLv=0
    if self.data.runeSkillId>0 then
        self.skillPanel:setVisible(true)
        local skillBase = cfg[CfgType.RUNE_SKILL][self.data.runeSkillId]
        self.skillIco:loadTexture("juexing_"..skillBase.icon..".png", me.localType)
        self.skillLv:loadTexture("runeAwaken"..skillBase.level..".png", me.localType)
        self.skillPanel:loadTexture("runeAwakenbox"..skillBase.rank..".png", me.localType)
        self.skillIco:ignoreContentAdaptWithSize(true)
        self.skillLv:ignoreContentAdaptWithSize(true)
        skillLv=skillBase.level
    else
        self.skillPanel:setVisible(false)
    end

    local starNums = data.star
    self.starNode:removeAllChildren()
    for i=1, starNums ,1 do 
        local star = nil
        if i<=skillLv then
            star = self.star1:clone():setVisible(true)
            --star:setPositionY(10)
        else
            star = self.star:clone():setVisible(true)
            --star:setPositionY(0)
        end
        star:setPositionX((i-1)*36)
        self.starNode:addChild(star)
    end
    self.starNode:setPositionX((357-starNums*36)/2)

    self.newIcon:setVisible(false)
    if data.isnew then
        data.isnew=nil
        self.newIcon:setVisible(true)
    end
end

function runeItem:unSelect()
    self.selected:setVisible(false)
end

function runeItem:select()
    self.selected:setVisible(true)
end
