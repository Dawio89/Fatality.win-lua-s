local urn = "Dawio89" --info.fatality.username // doesnt work yet
local url = "" -- set your webhook here
local hitboxes = {'Head','Chest','Stomach','Left Arm', 'Right Arm','Left Leg','Right Leg'}
function hook(msg)
    --print(post)
    utils.http_post(url,"Content-Type: application/x-www-form-urlencoded", string.format("content=%s",msg), function(urlContent)
    end)
end

function on_shot_registered(hit)
    if hit.manual then return end
    local target = entities.get_entity(hit.target)
    local target_name = target:get_player_info()
    local name = target_name.name
    local hitchance = hit.hitchance
    local backtrack = hit.backtrack
    local hitbox = hitboxes[hit.client_hitgroup]
    local damage = hit.client_damage
    local reason = hit.result
    if (hit.result ~= "hit") then
       post = string.format("**["..urn.."]** Missed %s | [hc] %i | [bt] %i | [hg] %s | [dmg] %i | missed due to: %s",
       name, hitchance, backtrack, hitbox, damage, reason)
    else 
    return
    end
    hook(post)
end


