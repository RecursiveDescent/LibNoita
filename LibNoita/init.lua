mods = ModGetActiveModIDs();

function Load(id)
    local dir = "mods/" .. id .. "/";

    ModMaterialsFileAdd(dir .. "materials.xml");

    local init = loadfile(dir .. "init.lua");

    local sandbox = {};

    for i, v in pairs(_G) do
        sandbox[i] = v;
    end

    if not ModSettingGet(id .. "_io") then
        sandbox.io = nil;
    end
    
    if not ModSettingGet(id .. "_os") then
        sandbox.os = nil;
    end

    if not ModSettingGet(id .. "_require") then
        sandbox.require = nil;
    end
    
    sandbox._ID = id;

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

        ModTextFileSetContent("mods/" .. v .. "/init.lua", "if not _ID then return end\n\n" .. code);

        Load(v);
    end
end