allianceStrongholdSubcell = class("allianceStrongholdSubcell",function(...)
    return cc.CSLoader:createNode(...)
end)
allianceStrongholdSubcell.__index = allianceStrongholdSubcell
function allianceStrongholdSubcell:create(...)
    local layer = allianceStrongholdSubcell.new(...)
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

function allianceStrongholdSubcell:ctor()
    print("allianceStrongholdSubcell:ctor()")
end
function allianceStrongholdSubcell:init()
    print("allianceStrongholdSubcell:init()")
    return true
end
function allianceStrongholdSubcell:onEnter()   
    me.assignWidget(self, "Panel_Title"):setVisible(false)
    me.assignWidget(self, "Panel_stronghold"):setVisible(false)
    local activity = cfg[CfgType.ACTIVITY_LIST][me.toNum(user.activityDetail.activityId)]
    if activity and activity.desc then
        local Panel_richText = me.assignWidget(self,"Panel_richText")
        local rich = mRichText:create(activity.desc,Panel_richText:getContentSize().width)
        rich:setPosition(0,Panel_richText:getContentSize().height)
        rich:setAnchorPoint(cc.p(0,1))
        Panel_richText:addChild(rich)
    end
    self:setContent()
    me.doLayout(self,me.winSize)  
end

function allianceStrongholdSubcell:setContent()
    local ListView_content = me.assignWidget(self, "ListView_content")
    ListView_content:setScrollBarPositionFromCornerForVertical(cc.p(10, 7));
    --配置时间
    if user.activityDetail.startTime and user.activityDetail.closeTime then
        me.assignWidget(self,"huodongTime"):setString(user.activityDetail.startTime.."--"..user.activityDetail.closeTime)
    end
    local count = 0
    for key, var in pairs(user.activityDetail.list) do
        local content = me.assignWidget(self, "Panel_stronghold"):clone()
        me.assignWidget(content, "cellBg"):setVisible(count%2==0)
        content:setVisible(true)
        local titleText = nil
        if var["processNum"] == 0 then
            titleText = "全服首次占领要塞的联盟"
        else
            titleText = "联盟占领"..var["processNum"].."个要塞"
        end
        me.assignWidget(content,"Text_title"):setString(titleText)
        me.assignWidget(content,"Text_content"):setString("   ".."盟主："..var["rewarder"][1].."钻石 副盟主/官员："..var["rewarder"][2].."钻石 成员:"..var["rewarder"][3].."钻石")
        ListView_content:pushBackCustomItem(content)
        count=count+1
    end
    --结束时间
    local title = me.assignWidget(self, "Panel_Title"):clone()
    title:setVisible(true)
    me.assignWidget(title, "cellBg"):setVisible(count%2==0)
    count=count+1
    me.assignWidget(title,"Text_title"):setString("发放时间")
    me.assignWidget(title,"Text_content"):setString("   ".."奖励不可重复领取，以活动时间结束为准")
    ListView_content:pushBackCustomItem(title)
    --方法方式
    local title = me.assignWidget(self, "Panel_Title"):clone()
    me.assignWidget(title, "cellBg"):setVisible(count%2==0)
    title:setVisible(true)
    me.assignWidget(title,"Text_title"):setString("发放方式")
    me.assignWidget(title,"Text_content"):setString("   ".."以系统邮件方式发放至邮箱")
    ListView_content:pushBackCustomItem(title)
end

function allianceStrongholdSubcell:onExit()

end
