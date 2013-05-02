package com.digitalaisle.frontend.valueObjects.entityObjects
{
	import org.casalib.util.ObjectUtil;

	public class ProjectProductItem extends ProjectContentItem
	{
		public var mainCategory:int;
		public var subCategory:int;
		public var price:String;
		public var currency:String;
		public var upc:String;
		public var manufacturerId:int;
		public var brand:String;
		public var subBrand:String;
		public var quantity:int;
		public var nutritionalInfo:String;
		public var uom:int;
		public var dimensions:String;
		public var inStoreLocation:String;
		
		public function ProjectProductItem()
		{
			super();
		}
		
		override public function create(projectProductItemNode:XML, uri:String, ownerId:int, projectURI:String):void
		{
			super.create(projectProductItemNode, uri, ownerId, projectURI);

			mainCategory = projectProductItemNode.hasOwnProperty("mainCategory") ? projectProductItemNode.mainCategory : 0;
			subCategory = projectProductItemNode.hasOwnProperty("subCategory") ? projectProductItemNode.subCategory : 0;
			price = projectProductItemNode.hasOwnProperty("price") ? projectProductItemNode.price : "";
			currency = projectProductItemNode.hasOwnProperty("currency") ? projectProductItemNode.currency: "";
			upc = projectProductItemNode.hasOwnProperty("upc") ? projectProductItemNode.upc : "";
			manufacturerId = projectProductItemNode.hasOwnProperty("manufacturerId") ? projectProductItemNode.manufacturerId : 0;
			brand = projectProductItemNode.hasOwnProperty("brand") ? projectProductItemNode.brand : "";
			subBrand = projectProductItemNode.hasOwnProperty("subBrand") ? projectProductItemNode.subBrand : "";
			nutritionalInfo = projectProductItemNode.hasOwnProperty("nutritionalInfo") ? projectProductItemNode.nutritionalInfo : "";
			quantity =  projectProductItemNode.hasOwnProperty("quantity") ? projectProductItemNode.quantity : 0;
			uom =  projectProductItemNode.hasOwnProperty("uoM") ? projectProductItemNode.uoM : 0;
			dimensions = projectProductItemNode.hasOwnProperty("dimensions") ? projectProductItemNode.dimensions : "";
			inStoreLocation = projectProductItemNode.hasOwnProperty("inStoreLocation") ? projectProductItemNode.inStoreLocation : "";
		}
	}
}
