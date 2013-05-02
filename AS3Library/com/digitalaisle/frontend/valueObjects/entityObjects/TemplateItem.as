package com.digitalaisle.frontend.valueObjects.entityObjects
{
	public class TemplateItem extends Object
	{
		public var id:int;
		public var name:String;
		public var itemType:int;
		public var itemCardinality:int;
		public var uri:String;
		public var viewSWF:String;
		public var controlType:int;
		public var dataItemId:int;
		public var dataItems:Array = new Array();
		public var lazyLoad:int = 0;
		
		public function TemplateItem()
		{
			super();
		}
		
		public function create(templateItemNode:XML):TemplateItem
		{
			var templateItem:TemplateItem = new TemplateItem();
			templateItem.id = templateItemNode.templateItemId;
			templateItem.name = templateItemNode.name;
			templateItem.itemType = templateItemNode.itemType;
			templateItem.itemCardinality = templateItemNode.itemCardinality;
			templateItem.uri = templateItemNode.uri;
			templateItem.viewSWF = templateItemNode.viewSWF;
			templateItem.controlType = templateItemNode.controlType;
			templateItem.lazyLoad = templateItemNode.lazyLoad;
			//templateItem.dataItemId = templateItemNode.dataItemId[0].nodeValue;
			
			if(templateItemNode.hasOwnProperty("dataItems")) {
				for(var i:int = 0; i < templateItemNode.dataItems.length(); i++) {
					templateItem.dataItems.push(templateItemNode.dataItems[i].templateItemId);
				}
			}
			
			return templateItem;
		}
	}
}