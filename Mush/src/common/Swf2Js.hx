package ;

#if js
import js.Browser;
import js.JQuery;
import ActionListMaintainer;
#end

/**
 * ...
 * @author de
 */

@:native("Swf2Js")
@:expose
@:keep
class Swf2Js {
	
	public function new()
	{
		
	}
	
	public function _echo()
	{
		//Debug.MSG("swf2js echo");
	}
	
	#if js
	public static function j(s)
	{
		return new JQuery(s);
	}
	#end
	
	
	public function _touch()
	{
		#if js
			haxe.Timer.delay( function()
			Main.ajax("/touch",null),
			10);
			null;
		#end
	}
	
	public function _acFaHoverIn( rindex : Int )
	{
		#if js
			_acFaHoverOut();
			var jq = j(".butbg a"+"[data="+rindex+"]");
			jq.parent().parent().parent().addClass("swfhover");
		#end
	}
	
	public function _acFaHoverOut( )
	{
		#if js
			var jq = j(".move.but").removeClass("swfhover");
		#end
	}
	
	public function _useModule( iid : Int )
	{
		#if js
		#end
	}
	
	public function _showCloset(_force:Bool)
	{
		#if js
		Main.closet.show(_force,false);
		#end
	}
	
	public function _hideCloset()
	{
		#if js
		Debug.MSG("js:hiding closet" );
		Main.closet.hide(false);
		#end
	}

	public function _cancelSelection()
	{
		#if js
			Debug.MSG("js:canceling selection" );
			Main.cancelSelection();
		#end
	}
	
	public function _selectPlayer( ser  : String )
	{
		#if js
			Debug.MSG("selecting player " + ser );
			Main.selectBySerial(ser);
		#end
	}
	
	public function _selectNpc( uid:Int )
	{
		#if js
			_hideCloset();
			var ser = Main.npcKey2Serial( uid );
			if ( ser == null ) Debug.MSG("no npc for key " + uid);
			else Debug.MSG(" found ser for k:"+uid+" ser:"+ser );
			Main.selectBySerial( ser );
		#end
	}
	
	public function _selectItem( iid : String , k : String )
	{
		#if js
			Debug.MSG("selecting " +iid + " => "+  k);
			if ( k == null)
			{
				if ( iid == null)
				{
					Main.cancelSelection();
					return;
				}
				
				var req = '.item';
				var jitem = j(req);
				
				var jqx = null;
				for ( x in jitem)
					if ( x.data('id') == iid ) {
						jqx = x;
					}
				
				if ( jqx != null && jqx.length > 0)
				{
					Main.selectItem( jqx.toArray()[0] );
				}
				else
				{
					var ser = Main.iid2Serial( iid );
					
					if ( ser != null)	Main.selectBySerial( ser );
					else 				Debug.MSG("invalid iid, it has no serial " + iid);
				}
			}
			else
			{
				_hideCloset();
				var ser = Main.ikey2Serial( k );
				if ( ser == null ) Debug.MSG("no item for key " + k);
				else Debug.MSG(" found ser for k:"+k+" ser:"+ser );
				Main.selectBySerial( ser );
			}
		#end
	}
	
	public function _reload(){
		#if js
			Browser.window.location.assign("/");
		#end
	}
	
	public function _makeMove(lnk:String)
	{
		#if js
		Debug.MSG("execing jump");
		Main.execJump( lnk );
		#end
	}
}