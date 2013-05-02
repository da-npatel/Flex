package com.digitalaisle.frontend.valueObjects.entityObjects
{	
	import com.digitalaisle.utils.MiscUtil;	
	
	import org.casalib.util.StringUtil;
	
	[Bindable]
	public class ProjectContentItem extends Object
	{
		public var id:int = 0;
		public var ownerId:int = 0;
		public var uri:String = "";
		public var itemSeqNo:int = 0;
		public var name:String;
		public var binaryContentItems:Array = new Array();
		public var folderPath:String;
		public var status:int;
		public var shortDescription:String = "";
		public var longDescription:String = "";
		public var enclongDescription:String = "";
		public var locale:String;
		public var dataSource:String;
		public var relatedItems:Array = new Array();
		public var templateItemId:int;
		public var externalLink:String = "";
		public var additionalProperties:Object = new Object();
		public var searchFrequency:int = 0;
		public var predicate:String;
		
		protected var searchFields:Array;
		
		public function ProjectContentItem()
		{
			super();
		}
		
		public function create(projectContentItemNode:XML, uri:String, ownerId:int, projectURI:String):void
		{
			id = projectContentItemNode.projectContentItemId;
			this.ownerId = ownerId;
			itemSeqNo = projectContentItemNode.hasOwnProperty("itemSeqNo") ? projectContentItemNode.itemSeqNo : 0;
			
			var contentItem:XMLList = projectContentItemNode.contentItem;
			name = contentItem.name;
			shortDescription = contentItem.hasOwnProperty("shortDesc") ? contentItem.shortDesc : "";

			if(contentItem.hasOwnProperty("longDesc") && contentItem.longDesc != "") {				
				var unescaped:String = StringUtil.htmlDecode(contentItem.longDesc);
				enclongDescription = contentItem.longDesc;
				longDescription = cleanHTML(contentItem.longDesc);
				longDescription = StringUtil.replace(longDescription, '<a href="', '<a href="event:');
				// Search string for any url's and attach handler					
			}
			
			locale = contentItem.locale;
			status = contentItem.status;
			dataSource = projectContentItemNode.dataSource;
			folderPath = projectURI + uri + "_" + dataSource + "/";
			externalLink = contentItem.hasOwnProperty("externalLink") ? contentItem.externalLink : "";
			templateItemId = projectContentItemNode.templateItem.hasOwnProperty("templateItemId") ? projectContentItemNode.templateItem.templateItemId : 0;
			predicate = projectContentItemNode.hasOwnProperty("predicate") ? projectContentItemNode.predicate : "";
			
			if(contentItem.hasOwnProperty("addnlAttributes")) {
					additionalProperties = MiscUtil.convertStringToKeyValueObject(contentItem.addnlAttributes);
			}
				
			var j:int = 0;
			if(contentItem.hasOwnProperty("binaryContentItems")) {
				for(j = 0; j < contentItem.binaryContentItems.length(); j++) {
					var binaryItem:BinaryContentItem = new BinaryContentItem().create(contentItem.binaryContentItems[j]);
					binaryContentItems.push(binaryItem);
				}
			}
			
			if(projectContentItemNode.hasOwnProperty("relatedItems")) {
				for(j = 0; j < projectContentItemNode.relatedItems.length(); j++) {
					var relatedItem:RelatedItem = new RelatedItem().create(projectContentItemNode.relatedItems[j]);
					relatedItems.push(relatedItem);
				}
			}
			
			searchFields = [name, shortDescription, longDescription];
		}
		
		
		public function qualifySearch(term:String):uint
		{
			var frequency:uint = 0;
			term = term.toLowerCase();
			for(var i:int = 0; i < searchFields.length; i++) {
				if(searchFields[i] is String) {
					frequency += StringUtil.contains(String(searchFields[i]).toLowerCase(), term);
				}else if(searchFields[i] is Array) {
					// Loop
				}
			}
			return frequency;
		}
		
		public function fetchBinaryContentByType(binaryType:int):String
		{	
			var value:String = "";
			for(var i:int = 0; i < binaryContentItems.length; i++) {
				if(binaryContentItems[i].type == binaryType) {
					//var suffix:String = BinaryFormat.fetchBinaryExtensionById(binaryType);	
					value = folderPath + binaryContentItems[i].uri /*suffix*/;
					break;
				}
			}
			return value;
		}
		
		public function clean(invalidItems:Vector):void
		{
			for (var i:int = 0; i < relatedItems.length; i++) {
				for (var j:int = 0; j < invalidItems.length; j++) {
					if(relatedItems[i].relatedItemId == invalidItems[j]) {
						relatedItems.splice(i, 1);
						i--;
					}
				}
			}
		}

		private function cleanHTML(str:String):String
		{
			var pattern:RegExp = /<TEXTFORMAT.*?>/g;
			var str:String = str.replace(pattern, "");
			pattern = /<FONT.*?>/g;
			str = str.replace(pattern, "");
			pattern = /<\/FONT.*?>/g;
			str = str.replace(pattern, "");
			pattern = /<A HREF/g;
			str = str.replace(pattern, "<a href");
			pattern = /<\/A>/g;
			str = str.replace(pattern, "</a>");
			pattern= /TARGET="_blank"/g;
			str = str.replace(pattern, "rel=\"external\" ");
			pattern = /<I>/g;
			str = str.replace(pattern, "<em>");
			pattern = /<\/I>/g;
			str = str.replace(pattern, "</em>");
			pattern = /<B>/g;
			str = str.replace(pattern, "<strong>");
			pattern = /<\/B>/g;
			str = str.replace(pattern, "</strong>");
			pattern = /<U>/g;
			str = str.replace(pattern, "<u>");
			pattern = /<\/U>/g;
			str = str.replace(pattern, "</u>");
			pattern= /<\/LI><LI>/g;
			str = str.replace(pattern, "</li><li>");
			pattern= /<\/LI>/g;
			str = str.replace(pattern, "</li></ul>");
			pattern= /<LI>/g;
			str = str.replace(pattern, "<ul><li>");
			pattern = /<P ALIGN="LEFT">/g;
			str = str.replace(pattern, "<p style=\"text-align:left\" >");
			pattern = /<P ALIGN="RIGHT">/g;
			str = str.replace(pattern, "<p style=\"text-align:right\" >");
			pattern = /<P ALIGN="JUSTIFY">/g;
			str = str.replace(pattern, "<p style=\"text-align:justify\" >");
			pattern = /<\/P>/g;
			str = str.replace(pattern, "</p>");
			pattern = /<\/TEXTFORMAT.*?>/g;
			str = str.replace(pattern, "");
			return str;
		}
	}
}
