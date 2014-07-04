local function copyTable(t)
   if type(t) ~= "table" then return t; end
   local tc = {};
   for k, v in pairs(t) do
      tc[k] = v;
   end
   return tc;
end

local function posToStr(pos)
   return "(" .. pos.x .. ", " ..pos.y.. ", " .. pos.z .. ")";
end
local posMeta = { __tostring = posToStr };

minetest.register_privilege(
   "lua",
   {
      description = "Allows use of the /lua chat command for debugging.",
      give_to_singleplayer = false
   });

minetest.register_chatcommand(
   "lua",
   {
      params = "<luaStatement>",
      description = "Executes a lua statement (chunk), for debugging.",
      privs = { lua = true },
      func =
         function(name, param)
            local cmdFunc, success, errMsg;

            cmdFunc, errMsg = loadstring(param, "/lua command");
            if not cmdFunc then
               minetest.chat_send_player(name, "ERROR: "..errMsg);
               return;
            end

            local player = minetest.get_player_by_name(name);
            local pos = player:getpos();
            setmetatable(pos, posMeta);

            local env = copyTable(getfenv(0));
            env.print =
               function(...)
                  str = "";
                  for _, arg in ipairs({...}) do
                     str = str .. tostring(arg);
                  end
                  minetest.chat_send_player(name, str, false);
               end;
            env.myname = name;
            env.me = player;
            env.here = pos;

            setfenv(cmdFunc, env);

            success, errMsg = pcall(cmdFunc);
            if not success then
               minetest.chat_send_player(name, "ERROR: "..errMsg);
            end
         end
   });
