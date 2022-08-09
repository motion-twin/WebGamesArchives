package ;

import mt.deepnight.slb.BLib;

import mod.ModAssets;

/**
 * ...
 * @author Tipyx
 */
class Settings
{
	public static var SIZE				= 62;
	
	public static var GRID_WIDTH		= 9;
	public static var GRID_HEIGHT		= 10;
	
	public static var STAGE_WIDTH		= 0;
	public static var STAGE_HEIGHT		= 0;
	
	public static var SLB_GRID			: BLib;
	public static var SLB_TAUPI			: BLib;
	public static var SLB_UI			: BLib;
	public static var SLB_UI2			: BLib;
	public static var SLB_FX			: BLib;
	public static var SLB_FX2			: BLib;
	public static var SLB_UNIVERS1		: BLib;
	public static var SLB_UNIVERS2		: BLib;
	public static var SLB_UNIVERS3		: BLib;
	
	public static var FONT_ARIAL_26		: h2d.Font;
	public static var FONT_ARIAL_20		: h2d.Font;
	public static var FONT_ARIAL_14		: h2d.Font;
	
	public static function CREATE() {
		STAGE_WIDTH = mt.Metrics.w();
		STAGE_HEIGHT = mt.Metrics.h();
		
		SLB_GRID = mt.deepnight.slb.assets.TexturePacker.importXmlMt("assets1.xml", true);
		SLB_TAUPI = mt.deepnight.slb.assets.TexturePacker.importXmlMt("taupinotron.xml");
		SLB_UI = mt.deepnight.slb.assets.TexturePacker.importXmlMt("design.xml");
		SLB_UI2 = mt.deepnight.slb.assets.TexturePacker.importXmlMt("design2.xml");
		SLB_UNIVERS1 = mt.deepnight.slb.assets.TexturePacker.importXmlMt("universCIM.xml");
		SLB_UNIVERS2 = mt.deepnight.slb.assets.TexturePacker.importXmlMt("universWCC.xml");
		SLB_UNIVERS3 = mt.deepnight.slb.assets.TexturePacker.importXmlMt("universNL.xml");
		SLB_FX = mt.deepnight.slb.assets.TexturePacker.importXmlMt("fx.xml", true);
		SLB_FX2 = mt.deepnight.slb.assets.TexturePacker.importXmlMt("fx2.xml", true);
		
		FONT_ARIAL_26 = hxd.res.FontBuilder.getFont("arial", 26, { antiAliasing : false , chars : hxd.Charset.DEFAULT_CHARS } );
		FONT_ARIAL_20 = hxd.res.FontBuilder.getFont("arial", 20, { antiAliasing : false , chars : hxd.Charset.DEFAULT_CHARS } );
		FONT_ARIAL_14 = hxd.res.FontBuilder.getFont("arial", 14, { antiAliasing : false , chars : hxd.Charset.DEFAULT_CHARS } );
	}
	
	public static var AR_BASIC		: Array<String> = ["crystal", "ground", "roc", "sand", "vegeta"];
	public static var AR_JEWEL		: Array<String> = ["redStone", "blueStone", "greenStone", "whiteStone"];
	public static var AR_LOOT		: Array<String> = ["chest"];
}