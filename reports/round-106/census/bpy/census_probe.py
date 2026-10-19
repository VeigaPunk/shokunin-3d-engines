import sys
print("CENSUS_IMPORT_START")
try:
    import bpy
except Exception as exc:
    print("CENSUS_IMPORT_FAIL", type(exc).__name__, exc)
    raise SystemExit(2)
ver = ".".join(str(x) for x in bpy.app.version)
print("bpy.app.version", ver)
print("bpy.app.version_string", bpy.app.version_string)
print("bpy.app.build_hash", bpy.app.build_hash.decode() if isinstance(bpy.app.build_hash, bytes) else bpy.app.build_hash)
print("bpy.app.background", bpy.app.background)
print("bpy.app.binary_path", bpy.app.binary_path)
print("python", sys.version.split()[0])
print("CENSUS_IMPORT_OK")
