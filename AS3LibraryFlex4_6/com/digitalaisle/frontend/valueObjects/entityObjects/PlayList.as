package com.digitalaisle.frontend.valueObjects.entityObjects
{
	public class PlayList extends Object
	{
		public var id:int = 0;
		public var canOverride:Boolean;
		public var name:String;
		public var description:String;
		public var isDefault:Boolean;
		public var status:int = 0;
		public var type:int;
		public var validFromDate:Date;
		public var validToDate:Date;
		public var playListItems:Array = new Array();
		
		public function PlayList()
		{
			super();
		}
	}
}