package com.digitalaisle.uilibrary.data
{
	public class PanelObject extends Object
	{
		public var uid:String = "0";
		public var labelText:String;
		public var descriptionText:String;
		public var upStateAsset:String;
		public var downStateAsset:String;
		public var disabledStateAsset:String;
		public var thumbnailAsset:String;
		public var buttonStyleName:String;
		public var itemSeqNo:int = 0;
		public var searchFrequency:int = 0;
		
		public function PanelObject()
		{
			super();
		}
		
		public static function create(uid:String, labelText:String, descriptionText:String, upStateAsset:String=null, downStateAsset:String=null, disabledStateAsset:String=null, buttonStyleName:String = null):PanelObject
		{
			var panelObj:PanelObject = new PanelObject();
			panelObj.uid = uid;
			panelObj.labelText = labelText;
			panelObj.descriptionText = descriptionText;
			if(upStateAsset)
				panelObj.upStateAsset = upStateAsset;
			if(downStateAsset)
				panelObj.downStateAsset = downStateAsset;
			if(disabledStateAsset)
				panelObj.disabledStateAsset = disabledStateAsset;
			return panelObj;
		}
	}
}