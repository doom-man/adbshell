myclass = class("myclass")
myclass.__index = myclass
function myclass:ctor(id)
    print("myclass:ctor()")
    self.id = id
end
function myclass:getId()
    print("id = ",self.id)
end
function myclass:setId(id_)
    self.id = id_
end
