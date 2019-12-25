--[Comment]
--jnmo
archDebris = class("archDebris",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）并且该对象必须是UIWidget 子类 一般是从globalItems里面取的时候用
        return arg[1]:getChildByName(arg[2])
    end
end)
archDebris.__index = archDebris
function archDebris:create(...)
    local layer = archDebris.new(...)
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
function archDebris:ctor()   
    self.data = nil
    --print("archDebris ctor") 
end
function archDebris:init()   
    --print("archDebris init")   
    return true
end
function archDebris:onEnter()
    --print("archDebris onEnter") 
end
function archDebris:getData()
    return self.data
end
function archDebris:setData(pData,level)    
     if pData then
        self.data = pData
        local curdata = nil 
        for key, var in pairs(user.bookPkg) do
            if var["defid"] == pData.id then
                curdata =  var
            end
        end
        for key, var in pairs(user.bookEquip) do
            if var["defid"] == pData.id then
               curdata = var
            end
        end
        if curdata == nil then
            curdata = {}
            curdata.count = 0
        end
        --print("pData.id "..pData["id"])
        local pEtcData = cfg[CfgType.ETC][pData["id"]]         
        local pIcon = me.assignWidget(self,"Image_Icon")
        local descs =  me.split(pEtcData.describe,"|")
        pIcon:loadTexture(getItemIcon(pEtcData["id"]),me.plistType)
        pIcon:setVisible(true)
        local pQuity = me.assignWidget(self,"Image_quity"):setVisible(true)
        pQuity:loadTexture(getArchQuility(pData["id"]),me.localType)
        if pData["status"] == 1 then           
               local pBookNum = me.assignWidget(self,"Image_Bar")
               local pNum = pData["Altas"]
               if pNum > 0 then
                  me.assignWidget(self,"Text_Num"):setString(pNum)
                  pBookNum:setVisible(true)
                  if level + 1 < #descs and curdata.count > 0 then
                      me.assignWidget(self,"Text_Num"):setVisible(false)
                      me.assignWidget(self,"Text_LevelUp"):setVisible(true)
                  else
                      me.assignWidget(self,"Text_Num"):setVisible(true)
                      me.assignWidget(self,"Text_LevelUp"):setVisible(false)
                  end
               else
                  pBookNum:setVisible(false) 
               end
         else
            local pBookNum = me.assignWidget(self,"Text_Num"):setVisible(false)
        end       
        me.assignWidget(self,"Image_Level"):setVisible(level>0)      
     end
end
function archDebris:setManualData(pData)    
     if pData then       
        local pEtcData = cfg[CfgType.ETC][pData[1]]         
        local pIcon = me.assignWidget(self,"Image_Icon")
        pIcon:loadTexture(getItemIcon(pEtcData["id"]),me.plistType)
        pIcon:setVisible(true)
        local pQuity = me.assignWidget(self,"Image_quity"):setVisible(true)
        pQuity:loadTexture(getArchQuility(pData[1]),me.localType)          
        local pBookNum = me.assignWidget(self,"Image_Bar")
        pBookNum:setVisible(false)
        if pData[2] == 0 then
            me.Helper:grayImageView(pIcon)
            me.Helper:grayImageView(pQuity)
        else
            me.Helper:normalImageView(pIcon)
            me.Helper:normalImageView(pQuity)
        end
     end
end
function archDebris:setManualLevelUpData(pEtcData,data,tmp)   
        local pIcon = me.assignWidget(self,"Image_Icon")
        pIcon:loadTexture(getItemIcon(pEtcData:getDef().id),me.plistType)
        pIcon:setVisible(true)
        local pQuity = me.assignWidget(self,"Image_quity"):setVisible(true)
        pQuity:loadTexture(getArchQuility(pEtcData:getDef().id),me.localType)          
        local pBookNum = me.assignWidget(self,"Image_Bar")
        pBookNum:setVisible(false)
        local Image_Bar_choose = me.assignWidget(self,"Image_Bar_choose")
        local Text_Num_choose = me.assignWidget(self,"Text_Num_choose")
        Image_Bar_choose:setVisible(true)
        me.registGuiClickEvent(pQuity,function (node)
            
             pEtcData.choose = not pEtcData.choose 
             
             if pEtcData.choose == true then
                 local bookdata = cfg[CfgType.BOOK_TECH_MENU][data .id]
                 local techdata = cfg[CfgType.BOOK_TECH][data.techId]
                 local addexp =0 
                 for key, var in pairs(tmp) do
                      if var.choose == true then
                           addexp = addexp + var.choose_num
                      end
                 end     
                 if data.exp + addexp < techdata.exp then
                       pEtcData.choose_num = math.min(techdata.exp -  data.exp - addexp , pEtcData.count )
                       me.dispatchCustomEvent("archManualTechLevel_update_choose")
                 else
                       showTips("材料已足够")
                       if pEtcData.choose_num == 0 then
                           pEtcData.choose = false
                       end 
                 end
             else
                 pEtcData.choose_num = 0 
                 me.dispatchCustomEvent("archManualTechLevel_update_choose")
             end
            me.assignWidget(self,"Image_ChooseMark"):setVisible(pEtcData.choose)
            me.assignWidget(self,"Image_xz"):setVisible(pEtcData.choose)
            Text_Num_choose:setString(pEtcData.choose_num.."/"..pEtcData.count)
        end)  
        pQuity:setSwallowTouches(false)  
        me.assignWidget(self,"Image_ChooseMark"):setVisible(pEtcData.choose)
        me.assignWidget(self,"Image_xz"):setVisible(pEtcData.choose)
        Text_Num_choose:setString(pEtcData.choose_num.."/"..pEtcData.count)
        local Text_Name = me.assignWidget(self,"Text_Name")
        Text_Name:setString(pEtcData.name)
        Text_Name:setVisible(true)
end
function archDebris:onExit()
    --print("archDebris onExit")    
end
function archDebris:close()
    self:removeFromParentAndCleanup(true)  
end
