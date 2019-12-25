 mailInCell = class("mailInCell",function (...)
     local arg = {...}
    if table.getn(arg) == 1 then    
        return cc.CSLoader:createNode(arg[1])
    elseif table.getn(arg) == 2 then
        --这里当当前layer的父节点不在场景中的时候才用clone（）
        return arg[1]:getChildByName(arg[2])
    end
end)
mailInCell.__index = mailInCell
function mailInCell:create(...)
    local layer = mailInCell.new(...)
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
function mailInCell:ctor()  
   
end
function mailInCell:init()   
    return true
end
function mailInCell:setData(pData,pPitchOn)
     if pData ~= nil then
    -- dump(pData)
        if pPitchOn then     --选中
           --me.assignWidget(self,"bg_up"):setVisible(false)
           me.assignWidget(self,"Image_pitch_on"):setVisible(true)
           else
           --me.assignWidget(self,"bg_up"):setVisible(true)
           me.assignWidget(self,"Image_pitch_on"):setVisible(false)
        end
         --标题
         local pIn_cell_title = me.assignWidget(self,"In_cell_title")
         pIn_cell_title:setString(pData["title"])
         if pData["type"] == mailview.MAILPERSONAL then
            if me.toNum(pData["roleuid"]) == user.uid then
                if pData.title=="" then
                    pIn_cell_title:setString("寄给"..pData.source)
                end
            else
                if pData.title=="" then
                    pIn_cell_title:setString("来自"..pData.source)
                end
            end
        end

         local pOmit = me.assignWidget(self,"Text_omit"):clone()
         if pOmit:getContentSize().width > pIn_cell_title:getContentSize().width then
              me.assignWidget(self,"Text_omit"):setVisible(true)
            else
              me.assignWidget(self,"Text_omit"):setVisible(false)
         end
        
         -- 发件人
         local pIn_cell_people = me.assignWidget(self,"In_cell_people")
         pIn_cell_people:setString(pData["source"])
          
          me.assignWidget(self,"Text_2"):setString("发件人")
         -- 时间 
         local pIn_cell_time = me.assignWidget(self,"In_cell_time")
         pIn_cell_time:setString(self:getTime(pData["time"]))
        
         if pData["type"] == mailview.MAILPERSONAL then  -- 个人
             if me.toNum(pData["roleuid"]) ~= user.uid then
                local pIcon = me.assignWidget(self,"In_mail_Icon")
                pIcon:loadTexture("youjian_tubiao_xinjian_shou.png",me.localType)
                local pReat_status = pData["status"]
                if pReat_status == 0 then     -- 未读取邮件
                    me.assignWidget(self,"In_mail_hint"):setVisible(true)
                elseif pReat_status == -1 or pReat_status == -2 then      -- 读取邮件
                   me.assignWidget(self,"In_mail_hint"):setVisible(false)
                end
              else
                 local pIcon = me.assignWidget(self,"In_mail_Icon")
                 pIcon:loadTexture("youjian_tubiao_xinjian_fa.png",me.localType)
                 me.assignWidget(self,"Text_2"):setString("收件人123123")
                 printInfo("Pareto")
             end
         elseif pData["type"] == mailview.MAILUNION then  -- 联盟 
                local pIcon = me.assignWidget(self,"In_mail_Icon")
                pIcon:loadTexture("youjian_tubiao_xinjian_shou.png",me.localType)
                local pReat_status = pData["status"]
                if pReat_status == 0 then     -- 未读取邮件
                    me.assignWidget(self,"In_mail_hint"):setVisible(true)
                elseif pReat_status == -1 or pReat_status == -2 then      -- 读取邮件
                   me.assignWidget(self,"In_mail_hint"):setVisible(false)
                end
         elseif pData["type"] == mailview.MAILSYSTEM then -- 系统消息
            local pIn_read_Icon = me.assignWidget(self,"In_mail_Icon") -- 邮件读取状态  
            pIn_read_Icon:ignoreContentAdaptWithSize(true)
            local pRead_Str = "youjian_tubiao_xinjian_weidu.png"
            local pReat_status = pData["status"]
            if pReat_status == 0 then     -- 未读取邮件
                pRead_Str ="youjian_tubiao_xinjian_weidu.png"
            elseif pReat_status == -1 or pReat_status == -2 then      -- 读取邮件
                 pRead_Str = "youjian_tubiao_xinjian_du.png"
            end
            pIn_read_Icon:loadTexture(pRead_Str,me.localType)
            pIn_cell_people:setString("系统")

        end
        local pIn_prop_Icon = me.assignWidget(self,"In_read_Icon") -- 有无附件
        local pGoodsData = pData["itemList"]                         
        if pGoodsData~=nil and pData["status"]~=-2 then
           pIn_prop_Icon:setVisible(true)
        else
           pIn_prop_Icon:setVisible(false)
        end                 
     end
end
function mailInCell:getTime(pTime)
   local pCurrentTime = me.sysTime()/1000       -- 当前时间
   local pDifferTime = (pCurrentTime - pTime)        -- 差值
   local pYear = math.floor(pDifferTime/(60*60*24*365))  -- 几年前
   if pYear > 0  then
      return pYear.."年前"
   end
   local pMonth = math.floor(pDifferTime/(60*60*24*30))  -- 几月前
   if pMonth > 0  then
      return pMonth.."个月前"
   end

   local today = os.date("*t")
   local secondOfToday = os.time({day=today.day, month=today.month,year=today.year, hour=0, minute=0, second=0})
   if pTime >= secondOfToday and pTime < secondOfToday + 24 * 60 * 60 then
        return "今天"
   elseif pTime >= secondOfToday- 24 * 60 * 60 and pTime < secondOfToday then
        return "昨天"
   else
        local oldTime = os.date("*t", pTime)
        local secondOfDay = os.time({day=oldTime.day, month=oldTime.month,year=oldTime.year, hour=0, minute=0, second=0})
        local pDay = math.floor((secondOfToday-secondOfDay)/(60*60*24))       -- 几天前
        return pDay.."天前"
   end

end
function mailInCell:onEnter()   
	--me.doLayout(self,me.winSize)  
end
function mailInCell:onExit()  
end
