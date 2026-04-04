// c wraps
// uses: https://docs.python.org/3/c-api/structures.html#c.PyCFunctionFastWithKeywords

const std = @import("std");
const use_Formatters = @import("utils.zig");

// Supports 3.14+ because i only have that installed as of 2026 Apr. 4
// however plans to support 3.13+ as it's the lowest I can go since this uses PyCFunctionFastWithKeywords
const py = @cImport({
	@cDefine("PY_SSIZE_T_CLEAN", "1");
    @cDefine("Py_LIMITED_API", "0x030E0000");
    @cInclude("Python.h");
});


// wrapper for time formatter
// i heard [*] <- many item pointer is better than [*c] <- c pointer but im not entirely sure
export fn WRAPS_timeFormatter(self: ?*py.PyObject, args: [*c]const ?*py.PyObject, nargs: py.Py_ssize_t, kwnames: ?*py.PyObject) callconv(.c) ?*py.PyObject {
	// discard
	_ = self;
	
	// [_:null]?[*:0]const u8{...} supposed to be better but im not good enough to cast it so it could be used in py
	var kwlist = [_][*c]const u8 { "ms", "round", "compound", null };
	
	// defaults
	var ms: i64 = 0;
	var round: bool = false;
	var compound: bool = false;
	
	//---------------------------- MANUAL PARSING START ----------------------------///
	// will break down to a separate module in the future if time allows
	// py._PyArg_ParseStackAndKeywords could've been used but it's an internal api
	var ms_there = false;
	var round_there = false;
	var compound_there = false;
	
	// postional args parsing
	if (nargs > 0) { ms = py.PyLong_AsLongLong(args[0]); if (py.PyErr_Occurred() != null) return null; ms_there = true; }
	if (nargs > 1) { round = py.PyObject_IsTrue(args[1]); if (py.PyErr_Occurred() != null) return null; round_there = true; }
	if (nargs > 2) { compound = py.PyObject_IsTrue(args[2]); if (py.PyErr_Occurred() != null) return null; compound_there = true; }
	
	// keyword args parsing
	if (kwnames != null) {
		const key_count: py.Py_ssize_t = py.PyTuple_Size(kwnames);
		if (key_count < 0) return null;
		
		var i: py.Py_ssize_t = 0;
		
		while ( key_count > i ) : ( i += 1) {
			const key = py.PyTuple_GetItem(kwnames, i);
			if (key == null ) return null;
			
			const value = args[nargs+i]; // in fast call layout is [positional..., keyword_values...]
			
			if (py.PyUnicode_CompareWithASCIIString(key, "ms") == 0) {
				ms = py.PyLong_AsLongLong(value);
				if (py.PyErr_Occurred() != null) return null;
				
				if (ms_there) { PyErr_SetString(PyExc_TypeError, "Multiple values for argument 'ms'"); return null; }
				ms_there = true;
			}
			else if (py.PyUnicode_CompareWithASCIIString(key, "round") == 0) {
				round = py.PyObject_IsTrue(value);
				if (py.PyErr_Occurred() != null) return null;
				
				if (round_there) { PyErr_SetString(PyExc_TypeError, "Multiple values for argument 'round'"); return null; }
				round_there = true;
			}
			else if (py.PyUnicode_CompareWithASCIIString(key, "compound") == 0) {
				compound = py.PyObject_IsTrue(value);
				if (py.PyErr_Occurred() != null) return null;
				
				if (compound_there) { PyErr_SetString(PyExc_TypeError, "Multiple values for argument 'compound'"); return null; }
				compound_there = true;
			}
			else { py.PyErr_Format(py.PyExc_TypeError, "Unexpected keyword argument '%U'", key); return null; }
		}
	}
	
	// required arguments
	if (!ms_there) { py.PyErr_SetString(py.PyExc_TypeError, "Missing required argument: ms"); return null; }
	
	//---------------------------- MANUAL PARSING END ----------------------------///
	
    var buf: [128]u8 = undefined;
    var writer = std.Io.Writer.fixed(&buf);

    use_Formatters.timeFormatter(writer, ms, round, compound) catch return null;

    return py.PyUnicode_FromStringAndSize(@ptrCast(&buf), @intCast(writer.end));
}



// wrapper for byte formatter
export fn WRAPS_byteFormatter(self: ?*py.PyObject, args: [*c]const ?*py.PyObject, nargs: py.Py_ssize_t) callconv(.c) ?*py.PyObject {
	// discard
	_ = self;
	
    var size: ?i64 = null;
    
    //---------------------------- MANUAL PARSING START ----------------------------///
	// will break down to a separate module in the future if time allows
	// py._PyArg_ParseStackAndKeywords could've been used but it's an internal api
	
	// postional args parsing
	if (nargs > 0) { size = py.PyLong_AsLongLong(args[0]); if (py.PyErr_Occurred() != null) return null; }
	
	//---------------------------- MANUAL PARSING END ----------------------------///
	
    if (size) |s_val| {
		var buf: [64]u8 = undefined;
		var writer = std.Io.Writer.fixed(&buf);
    
		use_Formatters.byteFormatter(writer, s_val) catch return null;

		return py.PyUnicode_FromStringAndSize(@ptrCast(&buf), @intCast(writer.end));
		
	} else { py.PyErr_SetString(py.PyExc_TypeError, "Missing required argument: size"); return null; }
}



// Python extention def
const HUMANS_METHODS = [_:null]py.PyMethodDef{
    .{
        .ml_name = "human_time",
        .ml_meth = @ptrCast(&WRAPS_timeFormatter),
        .ml_flags = py.METH_FASTCALL | py.METH_KEYWORDS,
        .ml_doc = "human_time(ms: int, round: bool = False, compound: bool = False)\nFormat milliseconds into human readable form.",
    },
    .{
        .ml_name = "human_bytes",
        .ml_meth = @ptrCast(&WRAPS_byteFormatter), // Your wrapper
        .ml_flags = py.METH_FASTCALL,
        .ml_doc = "human_bytes(size: int)\nConvert byte count into human readable KiB/MiB/etc.",
    },
    .{ .ml_name = null, .ml_meth = null, .ml_flags = 0, .ml_doc = null },
};

export var humansmodule = py.PyModuleDef{
    .m_base = py.PyModuleDef_HEAD_INIT,
    .m_name = "humans",
    .m_doc = "Utility to convert time and bytes to human readable format",
    .m_size = -1,
    .m_methods = &HUMANS_METHODS,
    .m_slots = null,
    .m_traverse = null,
    .m_clear = null,
    .m_free = null,
};

pub export fn PyInit_humans() ?*py.PyObject {
    return py.PyModule_Create(&humansmodule);
}
