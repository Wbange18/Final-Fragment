
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

local colors = {
	"Really blue",
	"Really red",
	"New Yeller",
	"Toothpaste",
	"Magenta",
	"Institutional white",
	"Lime green",
	"Hot pink",
	"Deep Orange"
}

while true do
   for i, color in ipairs(colors) do
      local ColorTween = TweenService:Create(script.Parent, tweenInfo, {Color = BrickColor.new(color).Color})
      ColorTween:Play()
      ColorTween .Completed:Wait()
   end
end
