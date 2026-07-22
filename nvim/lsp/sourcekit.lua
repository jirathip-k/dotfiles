-- Swift / Objective-C via sourcekit-lsp (ships with Xcode).
-- Uses `xcrun sourcekit-lsp` so it follows the active Xcode toolchain.
return {
	cmd = { "xcrun", "sourcekit-lsp" },
	filetypes = { "swift", "objc", "objcpp" },
	root_markers = {
		"Package.swift",
		"buildServer.json",
		"*.xcodeproj",
		"*.xcworkspace",
		".git",
	},
}
