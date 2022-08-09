import Protocol;
using Ex;

class IsoProtocol
{
	public static function trackbackRid( str : String ) : Protocol.RoomId
	{
		var i = 0;
		for(st in Protocol.roomIdList)
		{
			if( st.id == str )
				return Type.createEnumIndex( RoomId, i );
			i++;
		}
		return null;
	}
	
	public static function trackbackIid( str : String ) : Protocol.ItemId
	{
		var i = 0;
		for(st in Protocol.itemIdList)
		{
			if( st.id == str )
				return Type.createEnumIndex( ItemId, i );
			i++;
		}
		return null;
	}
	
	public static function trackbackProjectId( str : String ) : Protocol.ProjectId
	{
		var i = 0;
		for(st in Protocol.projectIdList)
		{
			if( st.id == str )
				return Type.createEnumIndex( ProjectId, i );
			i++;
		}
		return null;
	}
	
	public static function trackbackResearchId( str : String ) : Protocol.ResearchId
	{
		var i = 0;
		for(st in Protocol.researchIdList)
		{
			if( st.id == str )
				return Type.createEnumIndex( ResearchId, i );
			i++;
		}
		return null;
	}
}
