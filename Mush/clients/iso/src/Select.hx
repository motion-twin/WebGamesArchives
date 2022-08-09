/**
 * ...
 * @author de
 */
import Data;
import Protocol;
import Types;
import CrossConsts;
using Ex;



//centralized management to avoid spaghettis
class Select 
{
	public var grid : Grid;
	var dep : DepInfos;
	var te : TileEntry;
	var grPos : V2I;
	var tile : Tile;
	var player:  HumanNPC;
	var npc : NPC;
	
	var doorHovered : Bool;
	
	var glowFX : fx.CustomHighlight;
	var doorGlowFX : fx.SpriteHighlight;
	var charGlowFX : fx.SimpleHighlight;
	
	public var isCloset : Bool;
	public var isDoor : Bool;
	public var selected : Bool;
	
	public static var HOVER_COL = 0xFFFFFF;
	public static var SELECTED_COL = 0x99ff99;
	public static var BROKEN_COL = 0xFF0000;
	
	public function new(g,?d : DepInfos,?p:HumanNPC,?npc:NPC) 
	{
		grid = g;
		dep = d;
		te = (dep != null)?dep.te: ((p != null)?p.te:null);
		
		if ( dep != null)
		{
			grPos = dep.tile.getGridPos(); 
			tile = dep.tile;
		}
		
		selected = false;
		player = p;
		this.npc =  npc;
	}
	
	public function repadPlayer()
	{
		var pad = dep.pad.random();
		var pl = s().player;
		
		if ( pad != null )
		{
			pl.setPos( pad.x, pad.y );
			pl.changeDir( dep.dir );
		}
	}
	
	public inline function update()
	{
		if(isDoor)
		{
			if ( te.el.anim == null)
			{
				var anm =  te.setup.index + "#0";
				if ( te.el.hasAnim(anm))
				{
					te.el.play(  anm , false );
					te.el.anim.playSpeed = 0;
					te.el.anim.cursor = 0;
				}
			}
			
			if ( te.el.anim != null)
			{
				var v = 1.0;
				if (doorHovered)
					te.el.anim.cursor += v;
				else
					te.el.anim.cursor -= v;
			}
		}
	}
	
	public function clearText()
	{
		Main.gui.hideTip();
	}
	
	public function unglow()
	{
		if ( dep != null)	
		{
			if ( glowFX != null) glowFX.degressive = true;
			glowFX = null;
			
			if ( doorGlowFX != null) doorGlowFX.degressive = true;
			doorGlowFX = null;
		}
		else if (npc == null)
			Player_unglow();
		else
			NPC_unglow();
	}
	
	public function STD_glow(c)
	{
		if ( glowFX == null)
		{
			var mask = (dep.mask != null) ? dep.mask : dep.te.setup;
			var hl = new fx.CustomHighlight( 	grid, grPos,  mask,
												te.el, c, dep.mask == null );
			hl.progressive = true;									
			//Debug.MSG(Std.string(dep));
			//Debug.MSG(dep.ent.te.setup.index);
			glowFX = hl;
			s().addFx( grid, grPos, hl);
		}
		else
		{
			glowFX.filt.color = c;
			glowFX.tick();
		}
	}
	
	public function DOOR_glow(c)
	{
		if ( doorGlowFX == null)
		{
			var dfx = new fx.SpriteHighlight( grid, grPos, te, c);
			dfx.progressive = true;									
			doorGlowFX = dfx;
			s().addFx( grid, grPos, doorGlowFX);
		}
		else
		{
			doorGlowFX.filt.color = c;
			doorGlowFX.tick();
		}
	}
	
	public function glow(c)
	{
		if ( dep == null)
			if ( npc == null)
				Player_glow(c);
			else
				NPC_glow(c);
		else
		{
			if ( isDoor )	DOOR_glow( c );					
			else			STD_glow( c );
		}
	}
	
	public static function hasSelection()
	{
		for ( sels in Main.ship.selectables)	
			if ( sels.selected ) 
				return true;
		return false;
	}
	
	public function select()
	{
		selected = true;
		glow( SELECTED_COL );
		
		for ( sels in s().selectables)
			if ( sels != this )
				sels.deselect();
	}
	
	public function deselect()
	{
		if ( selected ) 
		{
			selected = false;
			if ( isCloset )
				ServerProcess.hideCloset();
			unglow();
		}
	}
	
	public static function cancelAllSelection()
	{
		for ( sels in Main.ship.selectables)
			sels.deselect();
	}
	
	////////////////////////////////////////
	public function Door_onEnter()
	{
		Main.setInputSkip( true );
		Debug.ASSERT( dep.gameData != null, te.setup.index +" must haxe a valid <dep> tag in the xml to behave as a door" );

		var to = null;
		var from = null;
		switch(dep.gameData)
		{
			case Door( a, b ):
				to = (a == grid.getRid()) ? b : a;
				from = (a == grid.getRid()) ? a : b;
			default: throw "DOOR DATA ERROR";
		}
		
		var color = HOVER_COL;
		var txt = Protocol.itemList[ DOOR.index() ].name + " >> " + Protocol.roomDb( to ).assert("invalid room to go").name;
		
		var mi = Main.ship.getMoveInfos(from, to);
		if ( !mi.enabled )
		{
			color = BROKEN_COL;
			txt += " " + mi.txt;
		}
		
		var enableDoor = IsoConst.EDITOR || mi.enabled;
		Main.gui.showTip( txt, enableDoor );
		
		if ( selected ) return;
		
		glow( color );
		if( enableDoor )
			doorHovered = true;
	}
	
	public function s() return Main.ship;
	
	public function isUiSet( s )
	{
		return ( 	Main.actServerDataExt != null
				&&	Main.actServerDataExt.uiFlags.has( s ));
	}
	
	public function Door_onRelease()
	{
		if ( isUiSet( UI_FLAGS.UF_EXPECT_CLOSET_OPENED ) ) return;
		
		var to = null;
		var from = null;
		switch(dep.gameData)
		{
			case Door( a, b ):
				to = (a == grid.getRid()) ? b : a;
				from = (a == grid.getRid()) ? a : b;
			default: throw "DOOR DATA ERROR";
		}
		
		var mi = s().getMoveInfos(from, to);
		if ( mi.enabled )
		{
			unglow();
			deselect();
			ServerProcess.cancelSelection();
			Main.setInputSkip( false );
			
			var player = Main.ship.player;
			if (dep.pad.test( function(d) return d.isEq(player.getGridPos() )))
			{
				s().player.set = CS_UP;
				var vp = s().player.useDoor( tile );
				if ( vp ) 
					Main.doVp();
			}
			else
			{
				var gp = dep.pad.random();
				player.walkTo( gp.x,gp.y );
			}
		}
		else
		{
			if ( selected ) 
			{
				deselect();
				ServerProcess.cancelSelection();
				return;
			}
			
			select();
			ServerProcess.selectItem( dep );
		}
	}
	
	public function Door_onOut()
	{
		Main.setInputSkip( false );
		if ( !selected ) unglow();
		clearText();
		doorHovered = false;
	}
	
	////////////////////////////////////////
	public function Closet_onEnter()
	{
		Main.gui.showTip(Protocol.txtDb( "closet" ));
		Main.setInputSkip( true );
		
		if ( selected ) return;
		
		glow( HOVER_COL );
	}
	
	public function Closet_onRelease()
	{
		//Debug.MSG("closet on release");
		if ( selected ) 
		{
			if ( isUiSet( UI_FLAGS.UF_FORCE_CLOSET_OPENED ) )
			{
				//Debug.MSG("closet closuer is impeached");
				return;
			}
			
			deselect();
			ServerProcess.cancelSelection();
			return;
		}
		
		//Main.ship.player.circa( tile );
		var p = tile.getGridPos();
		Main.ship.player.walkTo( p.x, p.y );
		select();
		
		ServerProcess.showCloset(false);
	}
	
	public function Closet_onOut()
	{
		if ( !selected ) unglow();
		Main.setInputSkip( false );
		clearText();
	}
	
	////////////////////////////////////////
	public function Equipment_onEnter()
	{
		var d = dep;
		
		Main.setInputSkip( true );
		switch(d.gameData)
		{
			case Equipment( i ):
			{
				Debug.ASSERT( i != null);
				
				var t = Protocol.itemList[ i.index() ].name;
				
				switch(i)
				{
					case PATROL_INTERFACE: 
						var full = Main.serverDataGetItemByDep( grid.getRid(), dep);
						if( full!=null)
							t = Protocol.roomList[ 
								full.customInfos
								.locate(function(ci) return switch(ci) { default: null; case RoomLink(r): r; } ).index()]
								.assert("invalid room link").name;
						
					default: 
				}
				Main.gui.showTip( t );
			}
			default:Debug.BREAK("AHAH");
		}
		
		if ( selected ) return;
		
		glow( HOVER_COL );
	}
	
	public function Equipment_onRelease()
	{
		if ( isUiSet( UI_FLAGS.UF_EXPECT_CLOSET_OPENED ) ) 
		{
			Debug.MSG("cant select bcs UF_EXPECT_CLOSET_OPENED set");
			return;
		}
			
		if ( selected ) 
		{
			Debug.MSG("selecting selection");
			deselect();
			ServerProcess.cancelSelection();
			return;
		}
		
		select();
		
		var pad = dep.pad.random();
		var pl : Player= s().player;
		
		if ( pad != null )
		{
			pl.set = CS_UP;
			
			var p = tile.getGridPos();
			Main.ship.player.walkTo( pad.x, pad.y, dep );
		}
		
		
		Debug.MSG("selecting equipment");
		ServerProcess.selectItem( dep );
	}
	
	public function Equipment_onOut()
	{
		if ( !selected ) unglow();
		Main.setInputSkip( false );
		clearText();
	}
	
	////////////////////////////////////////
	public function Player_onEnter()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) return;
		
		Main.setInputSkip( true );
		
		if ( selected ) 
		{
			Debug.MSG("hovering selected");
			return;
		}
		
		//Main.gui.sideNoteHead.htmlText = Protocol.heroesList[ player.getChar().index() ].name;
		Main.gui.showTip( Protocol.heroesList[ player.getChar().index() ].assert("invalid hero tip").name );
		
		//do fx
		Player_glow( HOVER_COL );
	}
	
	public function Player_onRelease()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) 
		{
			Debug.MSG("simple ui:stalled");
			return;
		}
		
		if ( 	Main.actServerDataExt != null
			&&	Main.actServerDataExt.uiFlags.has( UF_EXPECT_CLOSET_OPENED )) 
			{
				Debug.MSG("expect closey:stalled");
				return;
			}
			
		if ( selected ) 
		{
			deselect();
			ServerProcess.cancelSelection();
			return;
		}
		
		select();
		ServerProcess.selectPlayer( player.data.serial );
	}
	
	public function Player_onOut()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) return;
		
		//Debug.MSG("Player_onOut");
		if ( !selected ) unglow();
		Main.setInputSkip( false );
		clearText();
	}
	
	public function Player_glow(c)
	{
		if ( charGlowFX != null)
		{
			charGlowFX.filt.color = c;
			charGlowFX.tick();
		}
		else
		{
			charGlowFX = new fx.SimpleHighlight( player.te.el, c);
			charGlowFX.progressive = true;
		}
	}
	
	
	
	public function Player_unglow()
	{
		charGlowFX.degressive = true;
		charGlowFX = null;
	}
	
	public function NPC_unglow()
	{
		charGlowFX.degressive = true;
		charGlowFX = null;
	}
	
	////////////////////////////////////////
	public function NPC_onEnter()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) return;
		Main.setInputSkip( true );
		if ( selected ) 
		{
			Debug.MSG("hovering selected");
			return;
		}
		
		Main.gui.showTip( npc.getName() );
		
		glow( HOVER_COL );
	}
	
	public function NPC_onRelease()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) 
		{
			Debug.MSG("simple ui:stalled");
			return;
		}
		
		if ( 	Main.actServerDataExt != null
			&&	Main.actServerDataExt.uiFlags.has( UF_EXPECT_CLOSET_OPENED )) 
			{
				Debug.MSG("expect closey:stalled");
				return;
			}
			
		if ( selected ) 
		{
			deselect();
			ServerProcess.cancelSelection();
			return;
		}
		
		select();
		ServerProcess.selectNPC( npc.data.uid );
	}
	
	public function NPC_glow(c)
	{
		if ( charGlowFX != null)
		{
			charGlowFX.filt.color = c;
			charGlowFX.tick();
		}
		else
		{
			charGlowFX = new fx.SimpleHighlight( npc.te.el, c);
			charGlowFX.progressive = true;
		}
	}
	
	public function NPC_onOut()
	{
		if ( isUiSet( UI_FLAGS.UF_SIMPLE_UI ) ) return;
		
		Debug.MSG("npc_onOut");
		if ( !selected ) unglow();
		Main.setInputSkip( false );
		clearText();
	}
}