package ;
import api.AKApi;
import api.AKProtocol;
/**
 * ...
 */
typedef SP  = flash.display.MovieClip;
class Item
{

	public var id : Int;
	public var cycle : Int;
	public var pk:SecureInGamePrizeTokens;
	
	public var type :Int;
	public var color: Int;
	public var protected : Bool;	//needed to complete level
	
	var omc : {>flash.display.Sprite,e0:SP,e1:SP,e2:SP,e3:SP,pk0:SP,pk1:SP,pk2:SP,pk3:SP,f0:SP,f1:SP,f2:SP,f3:SP,_txt:flash.text.TextField}; //original mc
	public var mc : Cacheable; //sprite containing bmp version
	
	public static var TYPE_EMPTY = 0;
	public static var TYPE_NORMAL = 2;
	public static var TYPE_STONE = 1;
	
	//static var PK_FRAME = [0,1, 0, 2, 0, 3, 0, 0, 0, 0, 4];
	var parts:Array<flash.display.MovieClip>;
	var pks:Array<flash.display.MovieClip>;
	var frozens:Array<flash.display.MovieClip>;
	
	
	public function new() {
		type = TYPE_EMPTY;
	}
	
	/**
	 * init DATAS
	 * @param	_type
	 * @param	_color
	 * @param	_id
	 * @param	_cycle
	 * @param	_pk=0
	 */
	public function init(_type, _color, _id:Int, _cycle:Int, ?_pk:SecureInGamePrizeTokens, ?_protected=false ) {
		
		type = _type;
		color = _color;
		id = _id;
		cycle = _cycle;
		pk = _pk;
		protected = _protected;
	}
	
	/**
	 * init visual part
	 */
	public function render() {

		if(omc == null) omc = cast new gfx.Item();
		if(mc!=null && mc.parent != null) mc.parent.removeChild(mc);
		
		parts = [omc.e0, omc.e1, omc.e2, omc.e3];
		pks = [omc.pk0, omc.pk1, omc.pk2, omc.pk3 ];
		//frozens = [omc.f0, omc.f1, omc.f2, omc.f3 ];
		
		for(x in 0...4) {
			if(x != cycle) {
				parts[x].stop();
				parts[x].visible = false;
				pks[x].visible = false;
				//frozens[x].visible = false;
			}else {
				if(type==TYPE_NORMAL){
					/* Normal */
					if(pk!=null && pk.amount.get() > 0) {
						pks[x].gotoAndStop(pk.frame);
						//trace("amount : "+pk.amount.get()+" , frame :"+pk.frame);
						parts[x].gotoAndStop(color+6);
					}else {
						pks[x].visible = false;
						parts[x].gotoAndStop(color);
					}
					//if(frozen) {
						//frozens[x].visible = true;
					//}else {
						//frozens[x].visible = false;
					//}
				}else if(type == TYPE_EMPTY) {
					/* empty */
					pks[x].visible = false;
					//frozens[x].visible = false;
					parts[x].gotoAndStop(12);
					
				}else{
					/* stone */
					pks[x].visible = false;
					//frozens[x].visible = false;
					parts[x].gotoAndStop(6);
				
				}
			}
		}
		
		mc = new Cacheable(omc,false);
		autoPos();
		
		if(mc == null) throw this.toString()+" has no mc";
	}
	
	
	
	function autoPos() {
		
		
				//var rayon = 60 + a * 45;
		mc.x = Level.CENTER.x /*+ rayon * Math.cos(b*ANGLE)*/;
		mc.y = Level.CENTER.y /*+ rayon * Math.sin(b*ANGLE)*/;
		mc.rotation = id * (360 / 12);
	}
	
	
	public function toString() {
		return "item[" + cycle + "][" + id + "]";
	}
	
	
}