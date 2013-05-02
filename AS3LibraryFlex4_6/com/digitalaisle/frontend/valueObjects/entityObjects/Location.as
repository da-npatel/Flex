package com.digitalaisle.frontend.valueObjects.entityObjects
{
	import org.casalib.util.ObjectUtil;

	public class Location
	{
		public var city:String;
		public var country:String;
		public var latitude:String;
		public var longitude:String;
		public var name:String;
		public var postalCode:String;
		public var stateProvince:String;
		public var street1:String;
		public var street2:String = "";
		public var street3:String = "";
		public var type:String;
		public var locationDept:String;
		
		public function Location()
		{
			super();
		}
		
		public function create(locationNode:Object, locationDept:String):Location
		{
			var location:Location = new Location();
			location.city = locationNode.hasOwnProperty("city") ? locationNode.city[0].nodeValue : "";
			location.country = locationNode.hasOwnProperty("country") ? locationNode.country[0].nodeValue : "";
			location.name = locationNode.hasOwnProperty("name") ? locationNode.name[0].nodeValue : "";
			location.postalCode = locationNode.hasOwnProperty("postalCode") ? locationNode.postalCode[0].nodeValue : "";
			location.stateProvince = locationNode.hasOwnProperty("stateProvince") ? locationNode.stateProvince[0].nodeValue : "";
			location.street1 = locationNode.hasOwnProperty("street1") ? locationNode.street1[0].nodeValue : "";
			location.street2 = locationNode.hasOwnProperty("street2") ? locationNode.street2[0].nodeValue : "";
			location.street3 = locationNode.hasOwnProperty("street3") ? locationNode.street3[0].nodeValue : "";
			location.type = locationNode.hasOwnProperty("type") ? locationNode.type[0].nodeValue : "";
			location.locationDept = locationDept;
			return location;
		}
	}
}