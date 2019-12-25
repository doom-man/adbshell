--联盟创建 
alliancecrcell = class("alliancecrcell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone()
    end
end)
alliancecrcell.__index = alliancecrcell
function alliancecrcell:create(...)
    local layer = alliancecrcell.new(...)
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
function alliancecrcell:ctor()  
    print("alliancecrcell:ctor() ")
end
function alliancecrcell:init()   
    return true
end
function alliancecrcell:setData(pData,pType)
    if pData~= nil then
    -- 联盟名称
      local pAllianceName = me.assignWidget(self,"cr_cell_alliance_name")
      pAllianceName:setString(pData["name"])
    -- 联盟等级
      local pAllianceLevel = me.assignWidget(self,"cr_cell_level")
      pAllianceLevel:setString(pData["level"])
    -- 联盟人数
      local pAlliancePoNum = me.assignWidget(self,"cr_cell_people_num")
      pAlliancePoNum:setString(pData["memberNumber"] .. "/"..pData["maxMember"])
    -- 联盟战斗力
      local pAllianceFight = me.assignWidget(self,"cr_cell_alliance_fight")
      pAllianceFight:setString(pData["power"])
    end
    if pType == true then     
      if pData["appalyStatus"] == 2 then
        me.assignWidget(self,"cr_cell_Application"):setVisible(true)
        me.assignWidget(self,"Button_Application_add"):setVisible(false)
        me.assignWidget(self,"Button_agree_alliance"):setVisible(false)
        me.assignWidget(self,"Button_refuse_alliance"):setVisible(false)
      else
        me.assignWidget(self,"cr_cell_Application"):setVisible(false)
        me.assignWidget(self,"Button_Application_add"):setVisible(true)
        me.assignWidget(self,"Button_agree_alliance"):setVisible(false)
        me.assignWidget(self,"Button_refuse_alliance"):setVisible(false)
      end
    else
      me.assignWidget(self,"Button_Application_add"):setVisible(false)
      me.assignWidget(self,"Button_agree_alliance"):setVisible(true)
      me.assignWidget(self,"Button_refuse_alliance"):setVisible(true)
    end
end
function alliancecrcell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function alliancecrcell:onExit()  
end

