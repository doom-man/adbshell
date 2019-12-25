mLanguage = class("mLanguage")
mLanguage.__index = mLanguage
LAN_CN = "cn"
LAN_EN = "en"
function mLanguage:ctor()
    self.lan = "cn"
    self.ltxt = {}
    self:init()
end
function mLanguage:init()   
    
end
function mLanguage:setLanguage(lan_)
    self.lan = lan_
end
function mLanguage:getLanguage()
    return self.lan
end
function mLanguage:text(tid_)
    local str = self.ltxt[tid_][self.lan]
    if str then
        return str
    else
        print("error,can't find tid = %s,lan =%s text",tid_,self.lan)
    end
end
mLanguage_ = nil
function mLanguage.getInstance()
    if mLanguage_ == nil then
        mLanguage_ = mLanguage.new()
    end
    return mLanguage_
end