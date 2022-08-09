package ;

import Protocol; import Types;
using Ex;
import tools.Codec;

/**
 * ...
 * @author de
 */
class ServerProcess
{
	public static var waitingServer : Bool = false;
	
	public static function sendError(e:String)
	{
		Codec.load("rfe",e, function(_)
		{
			Debug.MSG("ERROR:" + e);
			trace("Please report error :" + e);
		});
	}
	
	public static function makeMove( from : RoomId, to : RoomId )
	{
		
		//if ( waitingServer ) return;
		//Debug.MSG("started room transition");
		startRoomTransition( Main.ship.getGrid( from ), Main.ship.getGrid( to ) );
	
		var swf2js = Main.getProxy();
		if ( swf2js == null )
		{
			Debug.MSG("erg, no proxy to target");
			return;
		}
		
		Main.guiStage().useHandCursor = false;
		Main.gui.hideTip();
	
		//Debug.MSG("cal emitted");
		swf2js._makeMove( "/?fa=" + ActionId.MOVE.index()+ "&fp=" + to.index());
	}
	
	public static var closetOpened = false;
	public static var isolateScreen : flash.display.MovieClip = null;
	
	public static function showCloset( forced : Bool )
	{
		var swf2js = Main.getProxy();
		if ( swf2js == null )
		{
			Debug.MSG("erg, no proxy to target");
			return;
		}
		swf2js._showCloset( forced );
		
		if ( isolateScreen == null)
		{
			isolateScreen = new flash.display.MovieClip();
			isolateScreen.graphics.beginFill(0x000000);
			isolateScreen.graphics.drawRect( 0, 0, Window.W(), Window.H());
			isolateScreen.graphics.endFill();
			isolateScreen.alpha = 0.33;
			
			var ev = flash.events.MouseEvent.MOUSE_DOWN;
			var l = null;
			l = function( e )
			{
				Select.cancelAllSelection();
				Main.grid().input.enable();
				Main.setInputSkip( false );
				isolateScreen.parent.removeChild(isolateScreen);
				isolateScreen.removeEventListener( ev, l );
				isolateScreen = null;
			}
			Main.guiStage().useHandCursor = true;
			Main.gui.hideTip();
			
			Main.grid().input.disable();
			Main.setInputSkip( true );
			
			isolateScreen.addEventListener( flash.events.MouseEvent.MOUSE_DOWN, l);
			Main.guiStage().addChild(isolateScreen);
		}
		
		closetOpened = true;
	}
	
	public static function hideCloset()
	{
		var swf2js = Main.getProxy();
		if ( swf2js == null )
		{
			Debug.MSG("erg, no proxy to target");
			return;
		}
		swf2js._hideCloset();
		closetOpened  = false;
	}
	
	
	public static function confirmLeave(from : RoomId, to : RoomId )
	{
		Debug.MSG("player move confirmed " + (leave == null));
		
		var toDo = function()
		{
			Debug.MSG("player move ended");
			new fx.EnterRoom( Main.ship.getGrid( from ), Main.ship.getGrid( to ) );
			Main.ship.forceActiveRoom( to );
			Select.cancelAllSelection();
			waitingServer = false;
		}
		
		if ( leave != null)
		{
			var old = leave.onFinish;
			leave.onFinish = function ()
			{
				if( old!=null)
					old();
				toDo();
			}
		}
		else toDo();
		leave = null;
	}
	
	public static var leave : fx.LeaveRoom = null;
	static function startRoomTransition(from:Grid,to:Grid)
	{
		waitingServer = true;
		leave = new fx.LeaveRoom( from, to );
	}
	
	static function startModuleTransition()
	{
		new fx.Mosaic( Main.view, false );
		waitingServer = true;
	}
	
	static function clearTransition()
	{
		if( fx.Mosaic.me != null)
			fx.Mosaic.me.kill();
	}
	
	//TODO : display error
	public static function cancel()
	{
		clearTransition();
		waitingServer  = false;
		Debug.MSG("server process canceled");
	}
	
	public static function end()
	{
		clearTransition();
		waitingServer  = false;
		Debug.MSG("server process end");
	}
	
	public static function touch()
	{
		var pr : Swf2JsProxi = Main.getProxy();
		if ( pr == null ) return;
		
		pr._touch();
	}
	
	public static function useModule( iid:ItemId )
	{
		Debug.ASSERT( iid != null);
		startModuleTransition();
		
		tools.Codec.load("fl_um", iid.index(), function(p:Dynamic)
		{
			Debug.MSG("received response");
			if( p==null || (p != "OK"))
			{
				Debug.MSG("failed to accurately select module");
				cancel();
			}
			else
			{
				var pr : Swf2JsProxi = Main.getProxy();
				if( pr != null)
				{
					Debug.MSG("calling proxy");
					pr._reload();
				}
				else
					Debug.MSG("unable to call proxy");
					
				end();
			}
		});
	}
	
	public static function cancelSelection()
	{
		var pr : Swf2JsProxi = Main.getProxy();
		
		if (pr != null)
		{
			Debug.MSG("srv:canceling sel");
			pr._cancelSelection();
			//trace(haxe.Stack.callStack());
		}
		else
		{
			Debug.MSG("unreachable proxy");
			Debug.MSG("unable to cancel object");
		}
	}
	
	public static function selectPlayer( ser : String )
	{
		var pr : Swf2JsProxi = Main.getProxy();
		if ( pr == null ) return;
		
		Debug.MSG("selecting player" + ser );
		pr._selectPlayer( ser );
	}
	
	public static function selectNPC( id : Int)
	{
		var pr : Swf2JsProxi = Main.getProxy();
		if ( pr == null ) return;
		pr._selectNpc( id );
	}
	
	public static function selectItem( dep : DepInfos )
	{
		var pr : Swf2JsProxi = Main.getProxy();
		if ( pr == null )
		{
			Debug.MSG("unreachable proxy");
			return;
		}
		
		var str = null;
		var k = null;
		if ( dep.gameData != null)
		switch(dep.gameData)
		{
			case Equipment( iid ):
			{
				str = Protocol.itemIdList[iid.index()].id;
				k = dep.key;
			}
				
			case Door( h,t):
			{
				str = Protocol.itemIdList[DOOR.index()].id;
				k = MathEx.mini( h.index(), t.index()) + "-" + MathEx.maxi(h.index(), t.index());
			}
			default:
		}
		if( k==null) k = dep.key;
	
		if ( str != null && pr != null)
		{
			Debug.MSG("doing selection..."+k);
			pr._selectItem( str, k );
		}
		else
		{
			if( dep != null)	Debug.MSG("unable to select object");
			else				Debug.MSG("dep is null...");
			
			pr._selectItem( null,null );
		}
	}
	
}