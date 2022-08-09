package com;

import com.Protocol;
import mt.MLib;

class SRoom {
	var hotel(default,null)	: SHotel;
	public var type			: RoomType;
	public var cx			: Int;
	public var cy			: Int;
	public var wid			: Int;
	public var level		: Int;
	public var constructing	: Bool;
	public var working		: Bool;
	//public var equipments	: Array<Item>;
	public var gifts		: Array<Item>;
	public var damages		: Int;
	public var custom		: RoomCustomization;
	public var data			: Int;

	public function new(h:SHotel, x,y, t:RoomType) {
		hotel = h;
		working = false;
		constructing = false;
		//equipments = [];
		gifts = [];
		cx = x;
		cy = y;
		wid = 1;
		level = 0;
		type = t;
		damages = 0;
		data = 0;
		custom = {
			color		: "raw",
			texture		: -1,
			bath		: -1,
			bed			: -1,
			ceil		: -1,
			furn		: -1,
			wall		: -1,
		}
	}

	public function toString() {
		return
			'$type@$cx,$cy' +
			(working?'[WORKING]':'') +
			(constructing?'[CONSTRUCT]':'') +
			(hasClient() && getClient().hasServiceRequest(#if neko Date.now().getTime() #else Game.ME.serverTime #end)?"[SERVICE]":"");
	}

	public function getSunlight() : Int {
		return cy<0 ? 0 :
			(!hotel.hasRoomExceptFiller(cx-1,cy) ? 1 : 0 ) +
			(!hotel.hasRoomExceptFiller(cx+1,cy) ? 1 : 0 );
	}

	public static function fromState(h:SHotel, s:RoomState) {
		var r = new com.SRoom(h, s.cx, s.cy, s.type);
		r.wid = s.wid;
		r.level = s.level;
		r.working = s.working;
		r.constructing = s.constructing;
		//r.equipments = s.equipments.copy();
		r.gifts = s.gifts.copy();
		r.damages = s.damages;
		r.data = s.data;
		r.custom = {
			color	: s.custom.color,
			texture	: s.custom.texture,
			bed		: s.custom.bed,
			bath	: s.custom.bath,
			ceil	: s.custom.ceil,
			furn	: s.custom.furn,
			wall	: s.custom.wall,
		}
		return r;
	}

	public function isFiller() {
		return type==R_FillerStructs;
	}


	public function canReceivedItem(i:Item) {
		switch( i ) {
			case I_Cold, I_Heat, I_Noise, I_Odor, I_Light :
				return type==R_Bedroom;

			case I_Bath(_), I_Bed(_), I_Ceil(_), I_Furn(_), I_Wall(_) :
				return type==R_Bedroom || type==R_CustoRecycler;

			case I_Color(_), I_Texture(_) :
				return type==R_Bedroom  || type==R_CustoRecycler;

			default :
				return false;
		}
	}

	public function canSkipWork() {
		return switch( type ) {
			case R_Trash, R_ClientRecycler : true;
			case R_Bedroom : true;
			case R_StockBeer, R_StockPaper, R_StockSoap : true;
			default : false;
		}
	}


	public function isDamaged() return damages>0;



	//public function hasEquipment(i:Item) {
		//for(i2 in equipments)
			//if( i2.equals(i) )
				//return true;
		//return false;
	//}


	public function countCustomizations() {
		var n = 0;
		if( custom.bath>=0 ) n++;
		if( custom.bed>=0 ) n++;
		if( custom.ceil>=0 ) n++;
		if( custom.furn>=0 ) n++;
		if( custom.wall>=0 ) n++;
		if( custom.color!="raw" ) n++;
		if( custom.texture>=0 ) n++;
		return n;
	}

	public function getCustomizationBonus() : Int {
		return MLib.ceil( countCustomizations()*GameData.CUSTOMIZATION_POWER );
	}

	public function getIsolation() : Int {
		var n = 0;
		if( !hotel.hasRoomExceptFiller(cx-1, cy) )	n++;
		if( !hotel.hasRoomExceptFiller(cx+1, cy) )	n++;
		if( !hotel.hasRoomExceptFiller(cx, cy-1) )	n++;
		if( !hotel.hasRoomExceptFiller(cx, cy+1) )	n++;
		return n;
	}

	public function countNeighbors() {
		var n = 0;
		var r = hotel.getRoom(cx-1,cy); if( r!=null && r.type==R_Bedroom && r.hasClient() ) n++;
		var r = hotel.getRoom(cx+1,cy); if( r!=null && r.type==R_Bedroom && r.hasClient() ) n++;
		var r = hotel.getRoom(cx,cy-1); if( r!=null && r.type==R_Bedroom && r.hasClient() ) n++;
		var r = hotel.getRoom(cx,cy+1); if( r!=null && r.type==R_Bedroom && r.hasClient() ) n++;
		return n;
	}

	public function canBeDestroyed() {
		return hotel.roomUnlocked(type);
	}

	public function canBeEdited() {
		return type!=R_Lobby && !working && !constructing && gifts.length==0;
	}

	public function canBeCustomized() {
		return type==R_Bedroom || type==R_Lobby;
	}

	public function getMissingStock() {
		return mt.MLib.max(0, GameData.getStockMax(type, level)-data);
	}

	public function hasBoost() {
		return hotel.hasFlag("boost_"+cx+"_"+cy);
	}

	public function getBoostEndTask() {
		return hotel.getTask( InternalSetFlag("boost_"+cx+"_"+cy, false) );
	}

	public function canBeBoosted() {
		return switch( type ) {
			case R_StockBeer, R_StockPaper, R_StockSoap : true;
			case R_Bank : true;
			case R_Laundry : true;
			default : false;
		}
	}

	//public function getRefillCost() {
		//return getMissingStock() * GameData.getStockCost(type);
	//}

	public function getState() : RoomState {
		// ATTENTION: ne pas oublier de casser les références (copy, serialize)
		return {
			type		: type,
			cx			: cx,
			cy			: cy,
			wid			: wid,
			level		: level,
			working		: working,
			constructing: constructing,
			//equipments	: equipments.copy(),
			data		: data,
			gifts		: gifts.copy(),
			damages		: damages,
			custom		: {
				color	: custom.color,
				texture	: custom.texture,
				bath	: custom.bath,
				bed		: custom.bed,
				ceil	: custom.ceil,
				furn	: custom.furn,
				wall	: custom.wall,
			},
		}
	}

	public function getClients() {
		return hotel.clients.filter( function(c) return c.room==this );
	}

	public function getClient() return getClients()[0];

	public function hasClient() {
		for( c in hotel.clients )
			if( c.room==this )
				return true;
		return false;
	}

	public function destroy() {
		hotel = null;
		type = null;
	}
}
