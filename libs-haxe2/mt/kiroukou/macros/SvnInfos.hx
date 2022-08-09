package mt.kiroukou.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

using Lambda;
using StringTools;

class SvnInfos {
	
	static var BREAKING_SPACE = String.fromCharCode(194) + String.fromCharCode(160) ;
	@:macro public static function getFullInfos( infos : Array<String> ) {
		var cmd = "svn";
		var args = ["info", "."];
		var p = try new sys.io.Process(cmd, args) catch(e:Dynamic) { null; }
		var availableInfos = [];
		var resInfos = [];
		infos.map( function(s) return s.toLowerCase() );
		if( p != null ) {
			try {
				while(true) {
					var line = p.stdout.readLine();
					var infoName = line.substring(0, line.indexOf(":")).toLowerCase().trim();
					if( infoName.endsWith( BREAKING_SPACE ) )
						infoName = infoName.replace(BREAKING_SPACE, "");
					var infoData = line.substring(line.indexOf(":") + 1).toLowerCase().trim();
					availableInfos.push(infoName);
					if( infos.has(infoName) ) {
						resInfos.push( infoData );
						infos.remove(infoName);
					}
				}
			} catch( e: Dynamic) { };
			#if debug
			if( infos.length != 0 ) {
				Context.error("Some information can't be retrieved : " + infos.join(",")+"\n Available informations are : "+availableInfos.join(","), Context.currentPos());
			}
			#end
		}
		return Context.makeExpr( resInfos, Context.currentPos() );
	}
	
	@:macro public static function getInfos() {
		var revision, date;
		var infos:Array<String> = getFullInfos(["revision", "last changed date"]);
		if( infos.length == 0 )
			infos = getFullInfos(["révision", "date de la dernière modification"]);
		if( infos.length > 0 ) {
			revision = Std.parseInt(infos[0]);
			date = infos[1].substr(0, 19);
		} else {
			revision = -1;
			date = "Invalid date";
		}
		var exprInfos = {revision: revision, date: date};
		return Context.makeExpr( exprInfos, Context.currentPos() );
	}
}