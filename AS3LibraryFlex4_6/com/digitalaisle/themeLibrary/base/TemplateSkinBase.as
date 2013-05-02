package com.digitalaisle.themeLibrary.base
{
	import com.adobe.utils.ArrayUtil;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	
	import flash.utils.Dictionary;

	public class TemplateSkinBase extends Object
	{
		//private var _id:Sting;
		private var _type:String;
		
		private var _supportedModules:Array = new Array();
		private var _supportedAssets:Array = new Array();
		private var _modules:Array = new Array();
		private var _assets:Array = new Array();
		
		private var _settings:Object = new Object();
		protected var templateSWFRef:String;
		
		public function TemplateSkinBase()
		{
			super();
		}
		
		public function fetchTemplateAssetByType(assetType:String):String
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

		public function get supportedModules():Array
		{
			return _supportedModules;
		}

		public function set supportedModules(value:Array):void
		{
			_supportedModules = value;
		}

		public function get supportedAssets():Array
		{
			return _supportedAssets;
		}

		public function set supportedAssets(value:Array):void
		{
			_supportedAssets = value;
		}

		public function get settings():Object
		{
			return _settings;
		}

		public function set settings(value:Object):void
		{
			_settings = value;
		}

		public function get modules():Array
		{
			return _modules;
		}

		public function set modules(value:Array):void
		{
			_modules = value;
		}
		
		
		public function get templateSWF():String
		{
			return templateSWFRef;
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