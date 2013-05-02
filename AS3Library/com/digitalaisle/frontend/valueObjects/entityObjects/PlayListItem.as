package com.digitalaisle.frontend.valueObjects.entityObjects
{
	public class PlayListItem extends Object
	{
		public var id:int = 0;
		public var seqNo:Number = 0;
		public var name:String;
		public var shortDescription:String;
		public var transitionIn:int = 0;
		public var transitionOut:int = 0;
		public var duration:int = 0; 
		public var status:int = 0;
		public var binaryContentItems:Array = new Array();
		public var folderPath:String;
		
		public function PlayListItem()
		{
			super();
		}
	}
}