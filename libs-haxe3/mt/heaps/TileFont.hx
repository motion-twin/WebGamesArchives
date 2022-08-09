package mt.heaps;

import h2d.Font;
using StringTools;

private class Char { 
	public var code:Int;
	public var tile:h2d.Tile;
	
	public inline function new(
	code:Int, 
	tile:h2d.Tile ) { //tile should be from only one texture doh
		this.code = code;
		this.tile = tile;
	}
}

class TileFont extends h2d.Font {
	
	inline function new(  
		name,size, lineHeight,
		symbols : Array<Char>
	) {
		tile = symbols[0].tile;
		super(name, size);
		
		sharedTex = true;
		isBuildable = false;
		
		this.lineHeight = lineHeight;
		for ( e in symbols )
			glyphs.set(e.code, new FontChar( e.tile.clone(), e.tile.width ));
	}
	
	/**
	 * 
	 * @see new ()
	 * var t = new h2d.Text(
	 * 	TileFont.fromTexturePacker("assets/VikingFont.xml", "viking", 120, 280),scene);
	 *	t.x = 700;
	 *	t.y = 50;
	 *	t.text = "ALI\nB0B0";
	 * 
	 * 	<TextureAtlas imagePath="buttonTXT.png" width="1024" height="2048">
    <sprite n="$" x="2" y="2" w="197" h="224" pX="0" pY="0"/>
    <sprite n="-" x="201" y="2" w="70" h="224" pX="0" pY="0"/>
    <sprite n="0" x="273" y="2" w="128" h="224" pX="0" pY="0"/>
    ....=
    <sprite n="9" x="353" y="228" w="116" h="224" pX="0" pY="0"/>
    <sprite n="A" x="471" y="228" w="145" h="224" pX="0" pY="0"/>
    <sprite n="S" x="872" y="680" w="109" h="224" pX="0" pY="0"/>
    <sprite n="Space" x="2" y="906" w="60" h="224" pX="0" pY="0"/>
    <sprite n="T" x="64" y="906" w="105" h="224" pX="0" pY="0"/>
    <sprite n="Z" x="877" y="906" w="135" h="224" pX="0" pY="0"/>
	
	maps !
    <sprite n="char_21" x="2" y="1132" w="58" h="224" pX="0" pY="0"/>
	
	maps ,
    <sprite n="char_2C" x="62" y="1132" w="56" h="224" pX="0" pY="0"/>
    <sprite n="char_2E" x="120" y="1132" w="55" h="224" pX="0" pY="0"/>
    <sprite n="char_3A" x="177" y="1132" w="59" h="224" pX="0" pY="0"/>
    <sprite n="char_3F" x="238" y="1132" w="95" h="224" pX="0" pY="0"/>
</TextureAtlas>
	 */
	//@:noDebug
	public static function fromSlb( 
		name:String, slb : mt.deepnight.slb.BLib,
		size:Int,lineHeight:Int,?desiredSize:Int //ask your gfx'man or try compute it manually...good luck
		) {
		var arr : Array<Char>= [];
		var gs = slb.getGroups();
		for ( k in gs.keys() ) {
			if (k == "")
				continue;
			
			var v = gs.get(k);
			switch(k) {
				case "Space": 
					var fr = slb.getFrameData( k );
					var t : h2d.Tile = slb.getTileWithPivot( k );
					if ( fr.realFrame != null)
						t.setSize( fr.realFrame.realWid, fr.realFrame.realHei );
					else 
						t.setSize( fr.wid, fr.hei);
					arr.push( new Char( 0xA0, 	t ) );
					//arr.push( new Char( 13,		t ) );
					arr.push( new Char( 0x20, 	t ) );
					arr.push( new Char( 0x0A, 	t ) );
				case "char":
					//skip
				default:	
					var c = null;
					if (k.startsWith("char_")) {
						var hexCode = k.split("_")[1];
						if (hexCode.length < 2)
							continue;
						var code = Std.parseInt( "0x" + hexCode);
						arr.push( new Char( code,  slb.getTileWithPivot( k ) ));
					}
					else 
						arr.push( c = new Char( haxe.Utf8.charCodeAt( k, 0 ), slb.getTileWithPivot( k )) );
			}
			
			var l = arr[arr.length - 1];
		}
		
		
		arr.sort( function(c0, c1) return c1.code - c0.code ); 
		
		#if debug
		for ( i in 0...arr.length - 1)
			if ( arr[i].code == arr[i + 1].code ) 
				throw name+" font has duplicate character assertion, bash your gfx man... char:"+String.fromCharCode( arr[i].code)+" code:"+arr[i].code;
		#end
		
		var fnt = new TileFont( name, size, lineHeight, arr );
		if ( desiredSize != null)fnt.resizeTo( size=desiredSize );
		hxd.res.FontBuilder.addFont( name+"#"+size, fnt);
		return fnt;
	}
	
}