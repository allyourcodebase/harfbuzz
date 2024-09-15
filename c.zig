const builtin = @import("builtin");

pub const c = @cImport({
    @cInclude("hb.h");
    @cInclude("hb-ft.h");
    if (builtin.os.tag == .macos) @cInclude("hb-coretext.h");
});
