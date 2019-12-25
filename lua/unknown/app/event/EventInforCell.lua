-- 事件详情
EventInforCell = class("EventInforCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）       
        local pCell = me.assignWidget(arg[1],arg[2]):clone()
        pCell:setVisible(true)
        return pCell
    end
end)
EventInforCell.__index = EventInforCell
function EventInforCell:create(...)
    local layer = EventInforCell.new(...)
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
function EventInforCell:ctor()  
   
end
function EventInforCell:init()   
        local rt = mRichText:create("g")
    return true
end
function EventInforCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function EventInforCell:onExit()  

end
function EventInforCell:setData(pData)
--    self:getEtc()
    if pData then      
       local pConfig = cfg[CfgType.NOTICE_INFO][me.toNum(pData["id"])]
       print("cfg id = "..pData["id"])
       local pName = me.assignWidget(self,"table_cell_title")
       pName:setString(pConfig["title"])
       local pTime = me.assignWidget(self,"table_cell_time")
       pTime:setString(me.GetSecTime(pData["time"]))
       local pStr = ""
      if pData["text"] ~= nil then    
           local pStrData = me.split(pConfig["data"],"|")
           self.mId = me.toNum(pData["id"])
           if me.toNum(pData["id"]) == 2 then          
              local pLandConfig = cfg[CfgType.MAP_EVENT_DATA][me.toNum(pData["text"][4])]
              local pNameStr = pLandConfig["name"]
              local pLevelStr = pLandConfig["landlv"]
              local pDec = me.split(pLandConfig["extdesc"],":")          
              local pDecStr = self:getLandDec(pLandConfig)
              local pPoint = me.split(pData["text"][3],":")           
              local pTabLand = {}
              pTabLand[1]= pNameStr
              pTabLand[2]= pLevelStr
              pTabLand[3]= pPoint[1]..","..pPoint[2]
              pTabLand[4]= pDecStr
              for key, var in pairs(pStrData) do
                if key == 1 then
                    pStr = var
                else
                    pStr = pStr..pTabLand[key-1]..var
                end
              end
           elseif me.toNum(pData["id"]) == 3 then
              local pLandConfig = cfg[CfgType.MAP_EVENT_DATA][me.toNum(pData["text"][4])]
              local pNameStr = pLandConfig["name"]
              local pLevelStr = pLandConfig["landlv"]
              local pPoint = me.split(pData["text"][3],":")           
              local pTabLand = {}
              pTabLand[1]= pNameStr
              pTabLand[2]= pLevelStr
              pTabLand[3]= pPoint[1]..","..pPoint[2]
              for key, var in pairs(pStrData) do
                if key == 1 then
                    pStr = var
                else
                    pStr = pStr..pTabLand[key-1]..var
                end
              end
           elseif me.toNum(pData["id"]) == 32 and #pData["text"] == 1 then
               for key, var in pairs(pStrData) do
                   if key == 1 then
                       pStr = var.."流浪".."]"
                   elseif key == 2 then
                       pStr = pStr..pData["text"][1]
                   else
                       pStr = pStr..var
                   end
               end
           elseif me.toNum(pData["id"]) == 37 and #pData["text"] == 4 then
               for key, var in pairs(pStrData) do
                   if key == 3 then
                       pStr = pStr..var.."流浪"
                   elseif key < 3 then   
                       pStr = pStr..var..pData["text"][key]             
                   elseif key < 6 then
                       pStr = pStr..var..pData["text"][key-1]
                   else
                       pStr = pStr..var
                   end
               end                          
           else            
              for key, var in pairs(pStrData) do
               local pStrName = self:getCofigName(pData["text"][1])
               if key == 1 then
                  pStr = var..pStrName
               else
                   if (#pStrData) > (key) and pData["text"][key] ~= nil then
                        local pos = string.find(pData["text"][key], "@")
                        if not pos then          
                           local pStr1 = pData["text"][key]
                           local posP = string.find(pStr1, ":")
                           if  not posP then
                               pStr = pStr..var..pData["text"][key]
                           else
                                local pPoint = me.split(pStr1,":") 
                                pStr = pStr..var..pPoint[1]..","..pPoint[2]       
                           end                           
                        else
                           local pStrEtc = self:getEtc(pData["text"][key],self.mId)
                           pStr = pStr..var..pStrEtc                           
                        end                                               
                   else
                     pStr = pStr..var
                   end                
               end
           end
         end
      else
           pStr = pConfig["data"]
      end     
      me.assignWidget(self,"table_cell_title"):removeAllChildren()
      local rt = parseRichtText(pStr)
      local rt_infor_concent = mRichText:create(rt,1080)
      rt_infor_concent:registCallback(function (pos_)
        LookMap(pos_,"EventInforView","mailview")
      end)
      rt_infor_concent:setAnchorPoint(cc.p(0,1))
      rt_infor_concent:setPosition(cc.p(0,-15))
      me.assignWidget(self,"table_cell_title"):addChild(rt_infor_concent)             
    end
end
local restexts = {
[1] = "粮食",
[2] = "木头",
[3] = "石头",
[4] = "金子",
}
function EventInforCell:getLandDec(pData)
   if pData then
       local pDec = me.split(pData["extdesc"],"|")
       local pStr = ""
       for key, var in pairs(pDec) do
            local pPDec = me.split(var,":")
            local pPName = pPDec[2]
            local pPStr = "<txt0018,f3be4c>" .. restexts[tonumber(pPDec[1])] .. "&" .. "<txt0018,ffffff>"..pPDec[2].."&"
            if key == 1 then
               pStr = pPStr
            else
               pStr = pStr.."<txt0018,ce8247>,&"..pPStr
            end
       end  
       return pStr  
   end
end
function EventInforCell:getCofigName(pStrData)
     local pTab = me.split(pStrData,"@")
     local pStr = "123"
     local pFind = string.find(pStrData,"@")    
     local pStrName = pStrData
     if pFind ~= nil then
         local pCfgNameId = pTab[1] -- 配置文件名字
         if pCfgNameId == 3 then
           -- 特殊处理
         else
            local pCfgId = pTab[2] -- id           
            pStrName = cfg[me.toNum(pCfgNameId)][me.toNum(pCfgId)]["name"]
         end         
     end
    return pStrName
end
-- "c" = {
--[LUA-print] -         "id"  = 12
--[LUA-print] -         "txt" = {
--[LUA-print] -             1 = "18@2212"
--[LUA-print] -             2 = "1"
--[LUA-print] -             3 = "163,14"
--[LUA-print] -             4 = "3@[]"
--[LUA-print] -         }
--[LUA-print] -     }
--[LUA-print] -     "t" = 3588
--[LUA-print] - }
function EventInforCell:getEtc(pStr,pId)
   
     local pTab = me.split(pStr,"@")
     local pEtcNStr = ""
     if pTab ~= nil then
         local pCfgNameId = pTab[1] -- 配置文件名字
         if (3 == me.toNum(pCfgNameId) and (pId == 29 or pId == 12 or pId == 13 or pId == 14 or pId == 15 or pId == 40)) or (16 == me.toNum(pCfgNameId) and pId == 39)then
            local pEtcData = me.cjson.decode(pTab[2])
            local i = 1
            dump(pEtcData)
            for key, var in pairs(pEtcData) do
                local pName = cfg[me.toNum(pCfgNameId)][me.toNum(var[1])]["name"]
                if i== 1 then
                   pEtcNStr = pEtcNStr..pName.."X"..var[2]
                else
                   pEtcNStr = pEtcNStr..","..pName.."X"..var[2]
                end
                i= i+1 
            end 
          else
            pEtcNStr = self:getCofigName(pStr)                                                         
         end
     end    
     return pEtcNStr     
end
function EventInforCell:getStr(str, split_char1,split_char2)
    if str == nil or split_char1 == nil then
        print("split str is nil or key is nil")
        return nil
    end
   local pStr = ""
    while (true) do
        local pos = string.find(str, split_char1);
        local pos1 = string.find(str, split_char2);
        if (not pos) then
          pStr = pStr..str
         
         return pStr
        end
      local pNum =   string.sub(str, pos+1,pos1-1); 
      local pd = pData[me.toNum(pNum+1)]      
      if pd == nil then
          pStr = pStr..str
         
         return pStr
      end
      local str1 = string.sub(str,1,pos-1)   
      pStr = pStr..str1..pd
      local t = string.len(str);
      str = string.sub(str,(pos1+1),t)    
    end  
    return str
 end