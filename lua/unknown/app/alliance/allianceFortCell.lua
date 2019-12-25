--联盟要塞 
allianceFortCell = class("allianceFortCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2])
        return pCell:clone():setVisible(true)
    end
end)
allianceFortCell.__index = allianceFortCell
function allianceFortCell:create(...)
    local layer = allianceFortCell.new(...)
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
function allianceFortCell:ctor()  
   
end
function allianceFortCell:init()   
    return true
end
function allianceFortCell:setData(data,type) 
    if type == 1 then 
        local def = GFortData()[data.id]
        me.assignWidget(self,"fortIcon"):loadTexture("waicheng_yaosai_shijie_"..def.icon..".png", me.plistType)
        me.resizeImage(me.assignWidget(self,"fortIcon"), 60,60)
        local _, _, name = string.find(def.name,"(.+)%(")
        local _, _, coordinate = string.find(def.name,".-(%(.+%))")
        me.assignWidget(self,"fortName"):setString(name)
        me.assignWidget(self,"fortCoordinate"):setString(coordinate)
        me.assignWidget(self,"fortRing"):setString(def.huan)
        local _, _, desc = string.find(def.desc,".-:(.+)")
        local tbExt = me.split(desc,"|")
        local pStr = ""
        for key, var in pairs(tbExt) do
            if key == 2 then
                local posP = string.find(var, ":")
                local pStr1 = ""
                if posP then
                   local tbExt1 = me.split(var,":")
                   pStr1 = tbExt1[2]..tbExt1[3] 
                end
               pStr = pStr..","..pStr1
               break
            end
            pStr = pStr..var
        end
        me.assignWidget(self,"fortDescribe"):setString(pStr) 
    elseif type == 2 then 
        local dataTxt = string.sub(data.text,1,string.len(data.text)-2)
        if data.value < 5 then 
            local percent = data.value * 100
            me.assignWidget(self,"totalDescribe"):setString(dataTxt)
            me.assignWidget(self,"numsTxt"):setString('+'..percent.."%")
        else
            me.assignWidget(self,"totalDescribe"):setString(dataTxt)
            me.assignWidget(self,"numsTxt"):setString('+'..data.value)
        end
    end
    return true
end
function allianceFortCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function allianceFortCell:onExit()  
end

