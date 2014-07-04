local function copyTable(t)
   if type(t) ~= "table" then return t; end
   local tc = {};
   for k, v in pairs(t) do
      tc[k] = v;
   end
   return tc;
end

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

            local env = copyTable(getfenv(0));
            env.print =
               function(...)
                  minetest.chat_send_player(name, table.concat({...}), false);
               end;

            setfenv(cmdFunc, env);

            success, errMsg = pcall(cmdFunc);
            if not success then
               minetest.chat_send_player(name, "ERROR: "..errMsg);
            end
         end
   });
