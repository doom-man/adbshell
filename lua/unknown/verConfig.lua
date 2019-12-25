APP_VER = 1
PACKAGE_CHANNEL ="ver20191214"
SERVER_MODE = 2
if SERVER_MODE == 1 then
    -- 正式服
    IAP_URL = "http://47.94.250.10:10002"
    -- 正式
    http_ip = "http://47.94.250.10:10001/mgame-uc"
elseif SERVER_MODE == 2 then
    -- 外网测试服
    IAP_URL = "http://39.107.240.90:10040"
    http_ip = "http://39.107.240.90:20000/mgame-uc"
elseif SERVER_MODE == 3 then
    -- 内网测试服
    IAP_URL = "http://39.107.240.90:10040"
    http_ip = "http://100.64.10.150:10020/mgame-uc"
end
--http_ip = "http://192.168.96.94:8070/mgame-uc"
--whiteUrl = "http://47.94.250.10:10001/mgame-uc/checkUpdate"
whiteUrl = "http://100.64.25.43:8080/mgame-uc/checkUpdate"
nocticUrl = http_ip .. "/notice.jsp"
