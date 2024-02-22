function ServerHop(PlaceId, joinLowPlayerServer)
    print("ServerHop(): PlaceId: " .. tostring(PlaceId) .. " | joinLowPlayerServer: " .. tostring(joinLowPlayerServer))
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local retries = 0
    local config = {
        ["url"] = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true",PlaceId, joinLowPlayerServer and "Asc" or "Desc", 100),
        ["servers"] = {
            ["ping"] = 100
        },
        ["retries"] = {
            ["limit"] = 3,
            ["delay"] = 2
        },
        ["delay"] = 5
    }
    print("ServerHop(): URL: " .. config["url"])
    local function toServer()
        if retries < config["retries"]["limit"] then
            local response, body
            pcall(function ()
                response = HttpService:GetAsync(config["url"])
                body = HttpService:JSONDecode(response)
            end)
            if body and body.data then
                local servers, playing = {}, 1
                repeat
                    for _, server in ipairs(body.data) do
                        if type(server) == "table" then
                            if server.playing > playing then break end
                            if server.id ~= game.JobId and server.playing == playing and server.ping < config["servers"]["ping"] then
                                table.insert(servers, 1, server.id)
                            end
                        end
                    end
                    playing = playing + 1
                until #servers > 0
                print("ServerHop(): Server hopping in " .. tostring(config["delay"]) .. " seconds...")
                task.wait(config["delay"])
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                retries = retries + 1
                print("ServerHop(): Failed to get the list of servers. Retrying " .. tostring(retries) .. "/3.")
                task.wait(config["retries"]["delay"])
                pcall(toServer)
            end
        else
            print("[FAIL] ServerHop(): Failed to get the list of servers.")
        end
    end
    pcall(toServer)
end
