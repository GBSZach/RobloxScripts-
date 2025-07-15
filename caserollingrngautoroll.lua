--Case Rolling RNG Auto Roll
--Config
local args = {
  "OpenCase",
  "Weapon Case",
  1
}
local requested_time = 7
--Script
local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("MainEvent")
local run_service = game:GetService("RunService")
local total_time = 0
local con = run_service.Heartbeat:Connect(function(dt)
  total_time += dt
  if total_time < requested_time then return end
  total_time -= requested_time
  remote:FireServer(unpack(args))
end)
local player = game:GetService("Players").LocalPlayer
player.Chatted:Connect(function()
  con:Disconnect()
end)