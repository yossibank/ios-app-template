@attached(member, names: named(requiredAttributes))
public macro Requires(_ attributes: String...) = #externalMacro(
    module: "RequiresMacroPlugin",
    type: "RequiresMacro"
)
