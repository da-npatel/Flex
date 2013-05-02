package com.digitalaisle.themeLibrary
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.base.TemplateSkinBase;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.AboutUsSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.AvatarMakerSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.CalendarSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.ConsultationSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.MultiItemFinderSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.PartyPlannerSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.base.SingleItemFinderSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.modules.custom.AgeGateSkin;
	import com.digitalaisle.themeLibrary.themeDefinitions.templates.base.AvatarFull;
	import com.digitalaisle.themeLibrary.themeDefinitions.templates.custom.LorealTemplate;
	import com.digitalaisle.themeLibrary.themeDefinitions.templates.custom.VirtualBartender;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	import com.digitalaisle.themeLibrary.types.TemplateSkinType;
	import com.greensock.dataTransfer.XMLManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	public class ThemeManager extends EventDispatcher
	{
		private static var instance:ThemeManager;
		private static var allowInstantiation:Boolean;
		
		private var _defaultModuleBkgd:String;
		
		//private var _themeXML:String;
		private var _managerDict:Dictionary = new Dictionary();
		private var _defaultThemeXML:String = "Default.xml";	// This needs to be based off theme definment 
		private var _themeData:Object;
		private var _templateSkinBase:TemplateSkinBase;
		private var _folderPath:String;
		
		
		public function ThemeManager()
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use ThemeManager.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():ThemeManager
		{
			if(instance == null)
			{
				allowInstantiation = true;
				instance = new ThemeManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		public function init(themeXML:String, folderPath:String):void
		{
			var themeXMLManager:XMLManager = new XMLManager();
			themeXMLManager.addEventListener(Event.COMPLETE, onThemeXMLLoaded);
			themeXMLManager.addEventListener(IOErrorEvent.IO_ERROR, onThemeXMLError);
			themeXMLManager.load(themeXML);
			_folderPath = folderPath;
		}
		
		
		public function fetchTemplateSkinBaseByType(templateType:String):TemplateSkinBase
		{
			return _templateSkinBase;
		}
		
		
		public function fetchModuleSkinBaseByType(moduleType:String):ModuleSkinBase
		{
			var moduleSkinBase:ModuleSkinBase;
			
			for(var i:int = 0; i < _templateSkinBase.modules.length;i++)
			{
				if(moduleType == _templateSkinBase.modules[i].type)
				{
					moduleSkinBase = _templateSkinBase.modules[i].skin;
					break;
				}
			}
			
			return moduleSkinBase;
		}
		
		
		private function instantiateTemplateSkinBase(themeSkinType:String):TemplateSkinBase
		{
			var templateSkinBase:TemplateSkinBase;
			
			switch(themeSkinType)
			{
				case TemplateSkinType.LOREAL:
					templateSkinBase = new LorealTemplate();
					break;
				case TemplateSkinType.AVATAR_PROMO:
					templateSkinBase = new AvatarFull();
					break;
				case TemplateSkinType.AVATAR_FULL:
					templateSkinBase = new AvatarFull();
					break;
				case TemplateSkinType.AVATAR_HALF:
					
					break;
				case TemplateSkinType.VERTICAL:
					
					break;
				case TemplateSkinType.VB_AVATAR_HALF:
					templateSkinBase = new VirtualBartender();
					break;
			}
			
			return templateSkinBase;
		}
		
		
		private function instantiateModuleBase(moduleSkinType:String):ModuleSkinBase
		{
			var moduleSkinBase:ModuleSkinBase;
			
			switch(moduleSkinType)
			{
				case ModuleSkinType.ABOUT_US_DEFAULT:
					moduleSkinBase = new AboutUsSkin();
					break;
				case ModuleSkinType.CALENDAR_DEFUALT:
					moduleSkinBase = new CalendarSkin();
					break;
				case ModuleSkinType.CONSULTATION_DEFUALT:
					moduleSkinBase = new ConsultationSkin();
					break;
				case ModuleSkinType.SINGLE_ITEM_FINDER:
					moduleSkinBase = new SingleItemFinderSkin();
					break;
				case ModuleSkinType.MULTI_ITEM_FINDER:
					moduleSkinBase = new MultiItemFinderSkin();
					break;
				case ModuleSkinType.PARTY_PLANNER_DEFAULT:
					moduleSkinBase = new PartyPlannerSkin();
					break;
				case ModuleSkinType.AGE_GATE_DEFAULT:
					moduleSkinBase = new AgeGateSkin();
					break;
				case ModuleSkinType.AVATAR_MAKER_DEFAULT:
					moduleSkinBase = new AvatarMakerSkin();
					break;
			}
			
			return moduleSkinBase;
		}
		
		
		private function populateModulesArray(modules:Array):Array
		{
			var templateModules:Array = new Array();
			
			for(var i:int = 0; i < modules.length; i++)
			{
				var moduleSkinType:String = modules[i].type;
				var moduleSkin:ModuleSkinBase = instantiateModuleBase(moduleSkinType);
				moduleSkin.assets = populateAssetsArray(modules[i].ModuleAssets[0].Asset);
				templateModules.push({type: moduleSkinType, skin: moduleSkin});
			}
			
			return templateModules;
		}
		
		private function populateAssetsArray(assets:Array):Array
		{
			var internalAssets:Array = new Array();
			
			for(var i:int = 0; i < assets.length; i++)
			{
				internalAssets.push({type: assets[i].type, source: _folderPath + assets[i].source})
			}
			
			return internalAssets;
		}
			
		
		/** Event Handlers **/
		
		private function onThemeXMLLoaded(e:Event):void
		{
			var themeData:Object = e.target.parsedObject;
	
			_templateSkinBase = instantiateTemplateSkinBase(themeData.Settings[0].Type[0].nodeValue);
			_templateSkinBase.modules = populateModulesArray(themeData.SupportedModules[0].Module);
			_templateSkinBase.assets = populateAssetsArray(themeData.TemplateAssets[0].Asset);
			
			e.target.destroy();
			
			_defaultModuleBkgd = _templateSkinBase.fetchTemplateAssetByType(AssetSkinType.DEFAULT_MODULE_BKGD);
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function onThemeXMLError(e:IOErrorEvent):void
		{
			// Handle this last
			// load default skin for the theme
			
		}

		public function get defaultModuleBkgd():String
		{
			return _defaultModuleBkgd;
		}

	}
}