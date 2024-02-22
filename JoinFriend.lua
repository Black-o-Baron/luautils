function JoinFriend(UserName)
    print("JoinFriend(): UserName: " .. tostring(UserName))
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local retries = 0
    local config = {
        ["retries"] = {
            ["limit"] = 100,
            ["delay"] = 6
        },
        ["delay"] = 5
    }
    local function toServer()
        if retries < config["retries"]["limit"] then
            local success, result = pcall(LocalPlayer.GetFriendsOnline, LocalPlayer)
            print("JoinFriend(): success: " .. tostring(success))
            if success then
                local PlaceId, GameId
                for _, friend in pairs(result) do
                    if friend.UserName == UserName then
                        PlaceId = friend.PlaceId
                        GameId = friend.GameId
                        break
                    end
                end
                print("JoinFriend(): PlaceId: " .. tostring(PlaceId) .. " | GameId: " .. tostring(GameId))
                if PlaceId and GameId then
                    print("JoinFriend(): Joining " .. UserName .. " in " .. tostring(config["delay"]) .. " seconds...")
                    task.wait(config["delay"])
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, GameId, LocalPlayer)
                else
                    retries = retries + 1
                    print("JoinFriend(): " .. UserName .. " is either OFFLINE or NOT ADDED AS FRIEND. Retrying " .. tostring(retries) .. "/100...")
                    task.wait(config["retries"]["delay"])
                    pcall(toServer)
                end
            else
                retries = retries + 1
                print("JoinFriend(): Failed to get friends online. Retrying " .. tostring(retries) .. "/100...")
                task.wait(config["retries"]["delay"])
                pcall(toServer)
            end
        else
            print("[FAIL] JoinFriend(): Error while trying to join friend. Try checking Privacy Settings")
        end
    end
    pcall(toServer)
end
