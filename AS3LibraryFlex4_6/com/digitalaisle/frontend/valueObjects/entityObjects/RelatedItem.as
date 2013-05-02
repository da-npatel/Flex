package com.digitalaisle.frontend.valueObjects.entityObjects
{
	import com.digitalaisle.utils.MiscUtil;

	public class RelatedItem extends Object
	{
		public var id:int;
		public var relatedItemId:int;
		public var relationType:int;
		public var relatedProjectContentItemId:int;
		public var relationData:Object = {};
		
		public function RelatedItem()
		{
			super();
		}
		
		public function create(relatedItemNode:XML):RelatedItem
		{
			var relatedItem:RelatedItem = new RelatedItem();
			relatedItem.id = relatedItemNode.projectContentItemId;
			relatedItem.relatedItemId = relatedItemNode.relatedItemId;
			relatedItem.relationType = relatedItemNode.relationType;
			relatedItem.relatedProjectContentItemId = relatedItemNode.relatedProjectContentItemId;
			if(relatedItemNode.hasOwnProperty("relationData")) {
				relatedItem.relationData = MiscUtil.convertStringToKeyValueObject(relatedItemNode.relationData);
			}
			return relatedItem;
		}
	}
}