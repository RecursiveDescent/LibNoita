mods = ModGetActiveModIDs();

function Load(id)
    local dir = "mods/" .. id .. "/";

    pcall(ModMaterialsFileAdd, dir .. "materials.xml");

    local init = loadfile(dir .. "init.lua");

    local sandbox = {};

    for i, v in pairs(_G) do
        sandbox[i] = v;
    end

    -- TODO Add security here, as any mod can just set these and get access to them.
    if not ModSettingGet(id .. "_io") then
        sandbox.io = nil;
    end
    
    --[[ Disabled until secure. ]]--

    if not ModSettingGet(id .. "_os") then
        -- sandbox.os = nil;
    end

    if not ModSettingGet(id .. "_require") then
        -- sandbox.require = nil;
    end
    
    sandbox._ID = id;

    -- dofile wants to run in this scope, we can't allow that.
    sandbox.dofile = function(file)
        local f = loadfile(file);

        setfenv(f, sandbox)();
    end

    local success, err = pcall(setfenv(init, sandbox));

    if not success then
        GamePrintImportant(id .. " failed to load: " .. err);
    end
end

for i, v in pairs(mods) do
    if v ~= "LibNoita" then
        local code = ModTextFileGetContent("mods/" .. v .. "/init.lua");

        -- Make sure the mod isn't loaded twice.
        ModTextFileSetContent("mods/" .. v .. "/init.lua", "if not _ID then return end\n\n" .. code);

        if not pcall(Load, v) then
            error("Failed to load " .. v);
        end
    end
end