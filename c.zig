const config = @import("config");

pub const c = @cImport({
    @cInclude("hb.h");
    @cInclude("hb-ft.h");
    if (config.coretext) @cInclude("hb-coretext.h");
});
