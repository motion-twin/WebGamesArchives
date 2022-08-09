package mt.bumdum;
import mt.bumdum.Lib;

class Bouille{//}

	static public var SEP = ",";

	public var colorDecal:Int;
	public var firstDecal:Int;
	public var palette:Array<Array<Int>>;
	public var skin:Array<Int>;
	public var paletteRedirect:Array<Int>;

	public function new(?str){
		palette = [];
		firstDecal = 1;
		colorDecal = 5;
		palette = [
			[
				0xFF0000,
				0x00FF00,
				0x0000FF,
				0x00FFFF,
				0xFFFF00,
				0xFF00FF
			]
		];
		if( str!=null )parseSkin(str);
	}

	public function parseSkin(str:String){
		var a = str.split(SEP);
		skin = [];
		if( a.length == 1 ) {
			// alternative parsing
			for( p in 0...str.length ) {
				var c = str.charCodeAt(p);
				if( c >= 97 && c <= 122 ) // a...z
					skin.push(c-97);
				else if( c >= 65 && c <= 90 ) // A...Z
					skin.push(c-65 + 26);
				else if( c >= 48 && c <= 57 ) // 0...9
					skin.push(c-48 + 52);
				else
					skin.push(62);
			}
		} else
			for( str in a )
				skin.push(Std.parseInt(str));
	}


	public function setPalette(a,?id){
		if(id==null)id=0;
		palette[id] = a;
	}


	public function apply(mc){
		framize(mc);
		colorize(mc);
	}
	public function framize(root:flash.MovieClip){
		var a = flash.Lib.keys(root);
		for( str in a ){
			var o = Reflect.field(root,str);
			if( Std.is(o,flash.MovieClip) ){
				var mc:flash.MovieClip = cast o;
				if( str.substr(0,1) == "_" )str = str.substr(1,str.length);
				if( str.substr(0,1) == "p" ){
					var st = str.substr(1,1);
					if(st=="r"){
						mc.gotoAndStop( Std.random(mc._totalframes)+1 );
					}else{
						setFrame(mc,Std.parseInt(st));
					}
				}
				framize(mc);
			}
		}
	}
	public function colorize(root:flash.MovieClip){

		var a =flash.Lib.keys(root);
		for( str in a ){
			var o = Reflect.field(root,str);
			if( Std.is(o,flash.MovieClip) ){
				var mc:flash.MovieClip = cast o;
				if( str.substr(0,1) == "_" )str = str.substr(1,str.length);
				for( i in 0...2 ){
					if( str.substr(i*2,3) == "col" ){

						var n = Std.parseInt(str.substr(3+i*2,2));
						setCol(mc,n);
					}
				}
				colorize(mc);
			}
		}
	}

	public function setCol(mc,n){
		var pid = n;
		if(paletteRedirect!=null)pid = paletteRedirect[n];


		var pal = palette[pid];
		if( pal==null )pal = palette[0];
		n += colorDecal+firstDecal;
		Col.setColor( mc, pal[skin[n]%pal.length]);
	}

	public function setFrame(mc:flash.MovieClip,n){


		mc.gotoAndStop( (skin[firstDecal+n])%mc._totalframes +1 );
	}






//{
}
