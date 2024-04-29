local Spinner = {}

Spinner.__index = Spinner

--METHODS

--[[Run
Run the spinner
]]
function Spinner:Run()

   coroutine.resume(self.Spin)
   
   return
end

--[[Yield
Stop the spinner
]]
function Spinner:Yield()
   coroutine.yield(self.Spin)
   return
end

--[[Change
Change the spinner's properties
]]
function Spinner:Change()
   
   return
end

--CONSTRUCTOR

--[[new
Create a new spinner object
]]
function Spinner.new()
   local newSpinner = {}
   
   setmetatable(newSpinner, Spinner)
   
   newSpinner.ring1 = script.Parent.InnerRing
   newSpinner.ring2 = script.Parent.OuterRing
   
   newSpinner.Spin = coroutine.create(function()
      
   end)
   
   return newSpinner
end

return Spinner