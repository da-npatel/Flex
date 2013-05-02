package com.digitalaisle.themeLibrary.base
{
	import com.adobe.utils.ArrayUtil;

	public class ModuleSkinBase extends Object
	{
		//private var _id:Sting;
		private var _type:String;
		private var _supportedAssets:Array = new Array();
		private var _assets:Array = new Array();
		
		public function ModuleSkinBase()
		{
			super();
		}
		
		public function fetchModuleAssetByType(assetType:String):String
		{
			var asset:String = "";
			var isAssetSupported:Boolean = ArrayUtil.arrayContainsValue(_supportedAssets, assetType);
			if(isAssetSupported)
			{
				for(var i:int = 0; i < _assets.length; i++)
				{
					if(assetType == _assets[i].type)
					{
						asset = _assets[i].source;
						break;
					}
				}
			}
			
			return asset;
				
		}

		/*public function get id():Sting
		{
			return _id;
		}

		public function set id(value:Sting):void
		{
			_id = value;
		}*/

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		public function get supportedAssets():Array
		{
			return _supportedAssets;
		}

		public function set supportedAssets(value:Array):void
		{
			_supportedAssets = value;
		}

		public function get assets():Array
		{
			return _assets;
		}

		public function set assets(value:Array):void
		{
			_assets = value;
		}

	}
}