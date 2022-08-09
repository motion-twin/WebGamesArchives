class BuildDate {
	public static macro function get() {
		haxe.macro.Context.registerModuleDependency("BuildDate", "Game.hx");
		return {
			pos	: haxe.macro.Context.currentPos(),
			expr: EConst( CString(Date.now().toString()) )
		}
	}
}
