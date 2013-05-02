package com.digitalaisle.frontend.valueObjects
{
	import com.digitalaisle.frontend.valueObjects.entityObjects.Location;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;

	public class ProjectObject extends Object
	{
		public var projectId:int;
		public var name:String = "";
		public var description:String = "";
		public var projectURI:String;
		public var baseURL:String;
		public var serverURL:String;
		public var templateSWF:String;
		public var themeSchemaItem:ProjectContentItem;
		public var themeFolderRef:String;
		public var owner:String;
		public var version:Number;
		public var unitId:int;
		public var logoId:int;
		public var locale:String;
		public var systemVolume:Number;
		public var copyrightText:String;
		public var unitLocation:Location = new Location();
		
		public function ProjectObject()
		{
			super();
		}
	}
}