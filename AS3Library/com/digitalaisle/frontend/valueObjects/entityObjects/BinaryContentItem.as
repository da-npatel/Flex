package com.digitalaisle.frontend.valueObjects.entityObjects
{
	public class BinaryContentItem extends Object
	{
		public var id:int;
		public var duration:int;
		public var format:int;
		public var height:int;
		public var width:int;
		public var type:int;
		public var uri:String;
		public var fileSource:String;
		
		
		public function BinaryContentItem()
		{
			super();
		}
		
		public function create(binaryContentItemNode:XML):BinaryContentItem
		{
			var binaryItem:BinaryContentItem = new BinaryContentItem();
			binaryItem.id = binaryContentItemNode.binaryContentItemId;
			binaryItem.duration = binaryContentItemNode.duration;
			binaryItem.format = binaryContentItemNode.format;
			binaryItem.width = binaryContentItemNode.width;
			binaryItem.height = binaryContentItemNode.height;
			binaryItem.type = binaryContentItemNode.type;
			binaryItem.uri = binaryContentItemNode.uri;
			binaryItem.fileSource = "";		// Construct the file url
			return binaryItem;
		}
	}
}