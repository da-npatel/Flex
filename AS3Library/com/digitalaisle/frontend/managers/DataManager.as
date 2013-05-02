package com.digitalaisle.frontend.managers
{
	import com.adobe.utils.ArrayUtil;
	import com.adobe.utils.DictionaryUtil;
	import com.demonsters.debugger.MonsterDebugger;
	import com.digitalaisle.frontend.enums.BinaryFormat;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.enums.ItemType;
	import com.digitalaisle.frontend.events.DataManagerEvent;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.ProjectObject;
	import com.digitalaisle.frontend.valueObjects.entityObjects.*;
	import com.digitalaisle.uilibrary.components.FrontendApplication;
	import com.digitalaisle.uilibrary.projectContent.ProjectRecipeItem;
	import com.digitalaisle.utils.MiscUtil;
	import com.digitalaisle.utils.XMLQueLoaderUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.DateUtil;
	import org.casalib.util.LocationUtil;
	import org.casalib.util.ObjectUtil;
	import org.casalib.util.StringUtil;
	
	import r1.deval.D;

	public class DataManager extends EventDispatcher
	{
		public static var themeFolderRef:String;
		public static var globalDictionary:Dictionary = new Dictionary(true);
		
		private var _isFlatMode:Boolean = false;
		private var _isRequired:Boolean = true;
		
		/** @private **/
		private static const ACTIVE:int = 1;
		private static const NOT_ACTIVE:int = 0;
		private static const WIDGETS_XML:String = "Widgets.xml";
		private static const PROJECT_XML:String = "Project.xml";
		
		/** @private Phases of the data loading process **/
		private static const INITIALIZE:String = "initialize";
		private static const PROJECT_CONFIG:String = "coreXMLLoadPhase";
		private static const PROCESS_PROJECT:String = "processProjectContentItems";
		
		private static const DESKTOP:String = "desktop";
		private static const HOSTED:String = "hosted";
		private static const WEB_PREVIEW:String = "webPreview";
		
		/** @private **/
		private static var instance:DataManager;
		/** @private **/
		private static var allowInstantiation:Boolean;
		
		/** @private Application instance of a Project Object **/
		private var _projectObject:ProjectObject = new ProjectObject();	
		
		/** @private **/
		//private var _unitLocation:Location = new Location();
		private var _xmlQueManager:XMLQueLoaderUtil = new XMLQueLoaderUtil();
		private var _allProjectContentItems:Vector.<int> = new Vector.<int>();
		private	var _unusedItemsByLocation:Vector.<int> = new Vector.<int>();
		private var _projectContentItemsDict:Dictionary = new Dictionary();
		private var _templateItemsDict:Dictionary = new Dictionary();
		private var _templateItems:Vector.<TemplateItem> = new Vector.<TemplateItem>();
		private var _moduleWidgetItems:Vector.<int> = new Vector.<int>();
		private var _isLazyLoading:Boolean = false;
		private var _loadingPhase:String;
		private var _projectURI:String;
		private var _mode:String;
		
		public static function getInstance():DataManager
		{
			if (instance == null) {
				allowInstantiation = true;
				instance = new DataManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		
		public function DataManager():void 
		{
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use DataManager.getInstance() instead of new.");
			}
		}
		
		
		/**
		 * Initializes the Data Manager processes
		 * 
		 */		
		public function init():void
		{
			_mode = DESKTOP;
			handleProcesses(INITIALIZE);
		}
		
		public function initHostedModule(dataSource:String):void
		{
			_mode = HOSTED;
			_templateItemsDict[HOSTED] = dataSource;
			handleProcesses(INITIALIZE);
		}
		
		public function initModulePreview(projectContentItems:ArrayCollection):void
		{
			
		}

		/**
		 * Fetches all module data items
		 * @param controlType: Type of supported control that the returned data is constructed for.
		 * @return: By default, a list of ProjectContentItems are returned.
		 * 
		 */		
		public function fetchModules():ArrayCollection
		{
			var moduleList:Array = new Array();
			for(var i:int = 0; i < _moduleWidgetItems.length; i++) {
				var moduleWidgetItem:ProjectContentItem = _projectContentItemsDict[_moduleWidgetItems[i]];
				var templateItem:TemplateItem = _templateItemsDict[moduleWidgetItem.templateItemId];
				if(templateItem.itemType == ItemType.MODULE || templateItem.itemType == ItemType.INITIAL_MODULE) {
					moduleList.push(_projectContentItemsDict[_moduleWidgetItems[i]]);
				}
			}
			return new ArrayCollection(moduleList);
		}
		
		public function fetchProjectContentItemById(id:int):ProjectContentItem
		{
			var projectContentItem:ProjectContentItem = _projectContentItemsDict[id];
			return projectContentItem;
		}
		
		public function fetchWidgetContentItemsByControlType(controlType:int):ArrayCollection
		{
			var widgets:Array = new Array();
			for(var i:int = 0; i < _moduleWidgetItems.length; i++) {
				var moduleWidget:ProjectContentItem = _projectContentItemsDict[_moduleWidgetItems[i]];
				var templateItem:TemplateItem = fetchTemplateItemById(moduleWidget.templateItemId);
				if(templateItem.controlType == controlType)
					widgets.push(_projectContentItemsDict[_moduleWidgetItems[i]]);
			}
			return new ArrayCollection(widgets);
		}
		
		public function fetchModuleItemByDataSource(dataSource:String):ProjectContentItem
		{
			var pciCollection:Array = DictionaryUtil.getValues(_projectContentItemsDict);
			var projectContentItem:ProjectContentItem
			for(var i:int = 0; i < _moduleWidgetItems.length; i++) {
				projectContentItem = _projectContentItemsDict[_moduleWidgetItems[i]];
				
				if(projectContentItem.dataSource == dataSource) {
					break;
				}
			}
			return projectContentItem;
		}
		
		public function fetchAllProducts():ArrayCollection
		{
			var products:ArrayCollection = new ArrayCollection();
			for(var i:int = 0; i < _allProjectContentItems.length; i++) {
				var item:ProjectContentItem = _projectContentItemsDict[_allProjectContentItems[i]]
				if(item is ProjectProductItem) {
					products.addItem(_projectContentItemsDict[_allProjectContentItems[i]]);
				}
			}
			return products;
		}
			
		/**
		 * Fetches all project content items based on it's owner id
		 * @param ownerId: Id of the project content items owner
		 * @param controlType: Type of supported control that the returned data is constructed for. 
		 * @return: By default, a list of ProjectContentItems are returned.
		 * 
		 */		
		public function fetchProjectContentItemsByOwnerId(ownerId:int):ArrayCollection
		{
			var projectContentItems:Array = new Array();
			for(var i:int = 0; i < _allProjectContentItems.length; i++) {
				if(_projectContentItemsDict[_allProjectContentItems[i]].ownerId == ownerId){
					projectContentItems.push(_projectContentItemsDict[_allProjectContentItems[i]]);
				}
			}
			return new ArrayCollection(projectContentItems);
		}
		
		
		public function fetchRelatedItemsByOwnerId(ownerId:int):ArrayCollection
		{
			var projectContentItems:Array = new Array();
			var ownerItem:ProjectContentItem = fetchProjectContentItemById(ownerId);
			for(var i:int = 0; i < ownerItem.relatedItems.length; i++) {
				var projectContentItem:ProjectContentItem = fetchProjectContentItemById(ownerItem.relatedItems[i].relatedItemId);
				if(projectContentItem) {
					projectContentItems.push(projectContentItem);
				}else {
					MonsterDebugger.trace(FlexGlobals.topLevelApplication, "Related item with the id of " + ownerItem.relatedItems[i].relatedItemId + " not found in project export. ", "Angel Romero", "Warning");
					continue;
				}
			}
			return new ArrayCollection(projectContentItems);
		}
		
		public function fetchModuleSwfByModuleId(id:int):String
		{
			var moduleSwf:String = "";
			for(var i:int = 0; i < _moduleWidgetItems.length; i++) {
				var moduleItem:ProjectContentItem = _projectContentItemsDict[_moduleWidgetItems[i]];
				if(moduleItem.id == id){
					moduleSwf = fetchTemplateItemById(moduleItem.templateItemId).viewSWF;
					if(FlexGlobals.topLevelApplication.releaseBuild)	
						moduleSwf = moduleItem.folderPath + moduleSwf;
					else
						moduleSwf = "ui/modules/" + moduleSwf;
					break;
				}
			}
			return moduleSwf;
		}

		
		public function fetchProjectContentItemsByTemplateItemId(id:int):ArrayCollection
		{
			var returnArr:Array = new Array();
			// needs update
			for(var i:int = 0; i < _allProjectContentItems.length; i++){
				var projectContentItem:ProjectContentItem = _projectContentItemsDict[_allProjectContentItems[i]];
				if(projectContentItem.templateItemId == id)
					returnArr.push(projectContentItem);
			}
			return new ArrayCollection(returnArr);
		}
		
		/*public function fetchProjectContentItemsByTemplateItemType(itemType:int):Array
		{
			var returnArr:Array = new Array();
			var projectContentItem:ProjectContentItem;
			for(var i:int = 0; i < _allProjectContentItems.length; i++)
			{
				projectContentItem = _allProjectContentItems[i] as ProjectContentItem;
				if(projectContentItem.templateItem.itemType == itemType)
				{
					returnArr.push(projectContentItem);
				}
			}
			return returnArr;
		}*/
		
		
		//TODO: WHo is using this call...is this even needed
		public function fetchDataItemByControlType(dataItems:Array, controlType:int):TemplateItem
		{
			var dataItem:TemplateItem;
			for(var i:int = 0; i < dataItems.length; i++) {
				if(dataItems[i].controlType == controlType) {
					dataItem = dataItems[i];
					break;
				}
			}
			return dataItem;
		}
		
		public function fetchUnitLocation():Location
		{
			return _projectObject.unitLocation;
		}
		
		public function fetchTemplateItemById(id:int):TemplateItem
		{
			return _templateItemsDict[id];
		}
		
		private function initialize():void
		{	
			_xmlQueManager.addEventListener(Event.COMPLETE, onXMLQueComplete);
			_xmlQueManager.addEventListener(IOErrorEvent.IO_ERROR, onXMLLoadError);

			if(LocationUtil.isAirApplication())
				trace("this is an Air Application");
			
			_projectObject.baseURL = LocationUtil.isAirApplication() ? "app:/projects/" : FrontendApplication.baseURL + "projects/";
		
			var configXMLObj:Object = FrontendApplication.topLevelDict["Config"];
			_projectObject.owner = configXMLObj.owner[0].name[0].nodeValue;
			_projectObject.name = configXMLObj.project[0].name[0].nodeValue;
			_projectObject.description = configXMLObj.project[0].description[0].nodeValue;
			_projectObject.serverURL = configXMLObj.serverURL[0].nodeValue;
			_projectObject.projectURI = configXMLObj.project[0].uri[0].nodeValue + "/";
			_projectObject.systemVolume = configXMLObj.systemVol[0].nodeValue;
			_projectObject.version = configXMLObj.projectVersion[0].nodeValue;
			_projectObject.unitId = configXMLObj.unitId[0].nodeValue;
			var locationDept:String = ObjectUtil.contains(configXMLObj, configXMLObj.locationDept) ? configXMLObj.locationDept[0].nodeValue : "";
			_projectObject.unitLocation = new Location().create(configXMLObj.location[0], locationDept);
			_projectObject.copyrightText = "© " + new Date().getFullYear() + " " + projectObject.owner;
			_projectURI = _projectObject.baseURL + _projectObject.projectURI;
			
			switch(mode) {
				case DESKTOP:
					
					break;
				case HOSTED:
					
					break;
			}
			
			_loadingPhase = PROJECT_CONFIG;
			_xmlQueManager.addToQue("Projects",_projectURI + PROJECT_XML);
			_xmlQueManager.addToQue("Widgets", _projectURI + WIDGETS_XML);
			_xmlQueManager.startQue();
		}
		
		private function processWidgetItems():void
		{
			var widgetsXML:XML = _xmlQueManager.getValueOf("Widgets") as XML; //POPULATE THIS LIST OF ACTIVE WIDGETS BASED ON WHAT THE MODULE IS CURRENTLY USING
			var ignoredControlTypes:Array = [ControlType.WEATHER_MODULE, ControlType.EXTERNAL_MODULE, ControlType.EXTERNAL_PORTAL, ControlType.CORE_MODULE, ControlType.THEME_SCHEMA, ControlType.SEARCH];
			
			// If in Hosted environment, strip out any unused widgets from the collection of parsed widgets
			if(_mode == HOSTED) {
				
				function fetchWidgetItemByDataSource(projectContentItems:XMLList, dataSource:String):XML
				{
					var projectContentItem:XML;
					for(var i:int = 0; i < projectContentItems.length(); i++) { 
						if(projectContentItems[i].dataSource == dataSource) {
							projectContentItem = projectContentItems[i];
							break;
						}
					}
					return projectContentItem;
				}
				
				var templateItemId:int = fetchWidgetItemByDataSource(widgetsXML.projectContentItem, _templateItemsDict[HOSTED]).templateItem.templateItemId;
				var moduleTemplateItem:TemplateItem = fetchTemplateItemById(templateItemId);
				var usedTemplateItems:Array = [moduleTemplateItem.id];
				org.casalib.util.ArrayUtil.addItemsAt(usedTemplateItems, moduleTemplateItem.dataItems, 1);
				
				/*for(var j:int = 0; j < widgetsXML.projectContentItem.length; j++) {
					if(!com.adobe.utils.ArrayUtil.arrayContainsValue(usedTemplateItems, widgetsXML.projectContentItem[j].templateItem[0].templateItemId[0].nodeValue)) {
						widgetsXML.projectContentItem.splice(j, 1);
						j--;
					}
				}*/
			}
			
			for(var i:int = 0; i < widgetsXML.projectContentItem.length(); i++) {
				if(widgetsXML.projectContentItem[i].contentItem.status == ACTIVE) {
					var templateItem:TemplateItem = fetchTemplateItemById( widgetsXML.projectContentItem[i].templateItem.templateItemId);
					var itemType:int = templateItem.itemType;
					var controlType:int = templateItem.controlType;
					
					/*if(_mode == HOSTED) {
						if(!com.adobe.utils.ArrayUtil.arrayContainsValue(usedTemplateItems, templateItem.id) || templateItem.controlType == ControlType.THEME_SCHEMA) {
							widgetsXML.projectContentItem.splice(i, 1);
							i--;
							continue;
						}
					}*/
					
					
					var projectItem:ProjectContentItem = new ProjectContentItem();
					projectItem.create(widgetsXML.projectContentItem[i], templateItem.uri, widgetsXML.ownerId, _projectURI);
					_projectContentItemsDict[projectItem.id] = projectItem;
					_moduleWidgetItems.push(projectItem.id);
					
					if(templateItem.controlType == ControlType.THEME_SCHEMA) {
						_projectObject.themeSchemaItem = projectItem;
						_projectObject.themeFolderRef = projectItem.folderPath;
						themeFolderRef = projectItem.folderPath;
						dispatchEvent(new DataManagerEvent(DataManagerEvent.THEME_LOADED));
					}
			
					if(!com.adobe.utils.ArrayUtil.arrayContainsValue(ignoredControlTypes, controlType))
						_xmlQueManager.addToQue("ProjectContentItemId" + projectItem.id + "_Data", projectItem.folderPath + "Items.xml");
				}
			}
			_loadingPhase = PROCESS_PROJECT;
			widgetsXML = null;
			_xmlQueManager.startQue();
		}
		
		
		private function handleProcesses(process:String):void
		{
			switch(process)
			{
				case INITIALIZE:
					initialize();
					break;
				case PROJECT_CONFIG:
					_isRequired = false;
					handleCoreLoad();
					break;
				case PROCESS_PROJECT:
					handleProcessingItems();
					break;
			}
		}
		
		
		
		private function handleCoreLoad():void
		{
			var projectXML:XML = _xmlQueManager.getValueOf("Projects") as XML;
			
			if(projectXML) {
				_projectObject.templateSWF = projectXML.contentTemplate.uri;
				_projectObject.projectId = projectXML.projectId;
				
				// Check to see if any template items exist
				//if(ObjectUtil.contains(projectXML.contentTemplate[0], projectXML.contentTemplate[0].templateItems)) {
				if(projectXML.contentTemplate.hasOwnProperty("templateItems")){
					for(var i:int = 0; i < projectXML.contentTemplate.templateItems.length(); i++){
						var templateItem:TemplateItem = new TemplateItem().create(projectXML.contentTemplate.templateItems[i]);
						_templateItems.push(templateItem);
						_templateItemsDict[templateItem.id] = templateItem;
					}
				}else{
					MonsterDebugger.trace(this, "Error: There are no template items for this project.  Exiting Frontend!", "Angel Romero", "Error");
					ApplicationUtil.exitApplication();
					return;
				}
				
				// Determine the Content Template Type
				if(projectXML.contentTemplate.type != "0"){
					_xmlQueManager.empty();	
					processWidgetItems();
				}else{
					_projectObject.themeFolderRef = _projectURI;
					_isFlatMode = true;
					dispatchEvent(new DataManagerEvent(DataManagerEvent.LOADING_COMPLETE));
				}
			}
		}
		
		
		private function handleProcessingItems():void
		{
			disableInvalidProjectContentItems();
			
			_xmlQueManager.xmlData.sort(sortModuleWidgetItems, Array.NUMERIC);
			
			for(var i:int = 0; i < _xmlQueManager.xmlData.length; i++) {
				
				var projectContentItem:ProjectContentItem = _projectContentItemsDict[int(_xmlQueManager.xmlData[i].data.ownerId)];
				var templateItem:TemplateItem = _templateItemsDict[projectContentItem.templateItemId];
				
				if(!isLazyLoading && templateItem.lazyLoad > 0) {
					_isLazyLoading = true;
					dispatchEvent(new DataManagerEvent(DataManagerEvent.LOADING_COMPLETE));
					trace("Loading Complete");
				}
				
				if(_xmlQueManager.xmlData[i].data.hasOwnProperty("projectContentItem")) {
					processProjectContentItems(_xmlQueManager.xmlData[i].data.projectContentItem, _xmlQueManager.xmlData[i].data.ownerId);	
				}else {
					for(var j:int = 0; j > _moduleWidgetItems.length; j++) {
						if(_moduleWidgetItems[j] == _xmlQueManager.xmlData[i].data.ownerId) {
							_moduleWidgetItems.splice(j, 1);
							break;
						}
					}
				}
			}
			
			disableInvalidRelatedItems();
			
			if(!isLazyLoading) {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LOADING_COMPLETE));
			}else {
				dispatchEvent(new DataManagerEvent(DataManagerEvent.LAZY_LOADING_COMPLETE));
				trace("Lazy Loading Complete");
			}
			
			_isLazyLoading = false;
			_xmlQueManager.empty();
			

			_xmlQueManager.removeEventListener(Event.COMPLETE, onXMLQueComplete);
			_xmlQueManager.removeEventListener(IOErrorEvent.IO_ERROR, onXMLLoadError);
			_xmlQueManager.destroy();
		}
		
		private function sortModuleWidgetItems(itemA:Object, itemB:Object):Number
		{
			var projectContentItemA:ProjectContentItem = _projectContentItemsDict[int(itemA.data.ownerId)];
			var templateItemA:TemplateItem = _templateItemsDict[projectContentItemA.templateItemId];
			
			var projectContentItemB:ProjectContentItem = _projectContentItemsDict[int(itemB.data.ownerId)];
			var templateItemB:TemplateItem = _templateItemsDict[projectContentItemB.templateItemId];
			
			if(templateItemA.lazyLoad > templateItemB.lazyLoad) {
				return 1;
			} else if(templateItemA.lazyLoad < templateItemB.lazyLoad) {
				return -1;
			} else  {
				return 0;
			}
		}
		
		
	
		/**
		 * Searches through an instance of a ProjectContentItem data object in search for XML files to add to the XML que
		 * @param projectContentItem: Refers to the ProjectContentItem data object
		 * 
		 */		
		private function processProjectContentItems(projectContentItem:XMLList, ownerId:int):void
		{
			var ignoredControlTypes:Array = [ControlType.WEATHER_MODULE, ControlType.EXTERNAL_MODULE, ControlType.EXTERNAL_PORTAL, ControlType.CORE_MODULE, ControlType.THEME_SCHEMA, ControlType.SEARCH];
			for(var i:int = 0; i < projectContentItem.length(); i++) {
				if(projectContentItem[i].contentItem.status == ACTIVE) {
					if(projectContentItem[i].hasOwnProperty("predicate")) {
						if(!determineItemAvailabity(projectContentItem[i].predicate)) {
							_unusedItemsByLocation.push(int(projectContentItem[i].id));
							continue;
						}
					}
					
					var projectItem:ProjectContentItem;
					var templateItem:TemplateItem = fetchTemplateItemById( projectContentItem[i].templateItem.templateItemId);
					var itemType:int = templateItem.itemType;
					var controlType:int = templateItem.controlType;
	
					switch(itemType)
					{
						case ItemType.DATA:
							//_dataContentItems.push(projectItem);
							switch(controlType)
							{
								case ControlType.PRODUCT_ITEM:
									projectItem = new ProjectProductItem();
									break;
								case ControlType.CALENDAR:
									projectItem = new ProjectEventItem();
									break;
								case ControlType.RECIPE_ITEM:
									projectItem = new ProjectRecipeItem();
									break;
								default:
									projectItem = new ProjectContentItem();
							}
							
							if(projectItem)
								projectItem.create(projectContentItem[i], templateItem.uri, ownerId, _projectURI);
							break;
					}
					
					_projectContentItemsDict[projectItem.id] = projectItem;
					_allProjectContentItems.push(projectItem.id);
				}
			}
		}
		
		private function determineItemAvailabity(predicate:String):Boolean
		{
			if(predicate == "") return true;
			
			var predicateObj:Object = MiscUtil.convertStringToKeyValueObject(predicate, true);
			var isDateValid:Boolean = true;
			if(predicateObj.hasOwnProperty("dateRange")) {
				var todayDate:Date = new Date();
				var dateRange:Object = D.eval(predicateObj.dateRange);
				var fromDate:Date = DateUtil.iso8601ToDate(dateRange.fromDate);
				var toDate:Date = DateUtil.iso8601ToDate(dateRange.toDate);
				if(fromDate.getTime() > todayDate.getTime()) {
					return false;
				}else if(toDate.getTime() >= todayDate.getTime()) {
					// return true
				}else {
					return false;
				}
			}
			
			if(predicateObj.hasOwnProperty("location")) {
				var location:Object = D.eval(predicateObj.location);
				if(location.hasOwnProperty("stateProvince")) {
					var states:Array = location.stateProvince as Array;
					return com.adobe.utils.ArrayUtil.arrayContainsValue(states, fetchUnitLocation().stateProvince) ? true : false;
				}
			}
			return true;
		}
		
		
		
		private function disableInvalidProjectContentItems():void
		{
			for(var i:int = 0; i < _xmlQueManager.invalidXMLSources.length; i++) {
				for(var j:int = 0; j < _moduleWidgetItems.length; j++) {
					var moduleWidgetItem:ProjectContentItem = _projectContentItemsDict[_moduleWidgetItems[j]];
					if(_xmlQueManager.invalidXMLSources[i].url == moduleWidgetItem.folderPath + "Items.xml") {
						//trace("invalid " + i);
						_moduleWidgetItems.splice(j, 1);
						j--;
						break;
					}
				}
			}
		}
		
		private function disableInvalidRelatedItems():void {
			/*if(_unusedItemsByLocation.length > 0) {
				var allProjectContentItems:Array = DictionaryUtil.getValues(_projectContentItemsDict);
				for (var i:int = 0; i < allProjectContentItems.length; i++) {
					allProjectContentItems[i].clean(_unusedItemsByLocation);
				}
			}*/
		}
		
		/**
		 * 
		 * @param binaryContentItems: 
		 * @param type: 
		 * @return 
		 * 
		 */
		// TODO: Depricated call that is now moving within the ProjectContentItem instance
		public function fetchBinaryContentByType(projectContentItem:ProjectContentItem, binaryType:int):String
		{	
			var value:String = "";
			
			for(var i:int = 0; i < projectContentItem.binaryContentItems.length; i++) {
				if(projectContentItem.binaryContentItems[i].type == binaryType) {
					var suffix:String = BinaryFormat.fetchBinaryExtensionById(binaryType);	
					value = projectContentItem.folderPath + projectContentItem.binaryContentItems[i].uri /*suffix*/;
					break;
				}
			}
			return value;
		}
		
		public function fetchBinaryContentItemsByType(projectContentItem:ProjectContentItem, binaryType:int):ArrayCollection
		{	
			var value:ArrayCollection = new ArrayCollection;
			
			for(var i:int = 0; i < projectContentItem.binaryContentItems.length; i++) {
				if(projectContentItem.binaryContentItems[i].type == binaryType) {
					var suffix:String = BinaryFormat.fetchBinaryExtensionById(binaryType);	
					value.addItem(projectContentItem.folderPath + projectContentItem.binaryContentItems[i].uri);
				}
			}
			return value;
		}
		
		//TODO: Depricated
		//NOTE: relatedItem needs to be an array since there can be multiple items with the same relation type
		public function fetchRelatedItemByType(relatedItems:Array, relationType:int):Object
		{
			var relatedItem:Object;
			for(var i:int = 0; i < relatedItems.length; i++) {
				if(relatedItems[i].relationType == relationType)
					relatedItem = fetchProjectContentItemById(relatedItems[i].relatedItemId);		// NOTE: RELATED ITEM WILL DEPEND ON RELATION TYPE(EVENT, PRODUCT, etc);
			}
			return relatedItem;
		}
		
		
		public function fetchRelatedItemsByType(relatedItems:Array, relationType:int):ArrayCollection
		{
			var relatedItemsList:Array = new Array();
			
			for(var i:int = 0; i < relatedItems.length; i++) {
				if(relatedItems[i].relationType == relationType) {
					var relatedItem:ProjectContentItem = fetchProjectContentItemById(relatedItems[i].relatedItemId) as ProjectContentItem;
					if(relatedItem) {
						relatedItemsList.push(relatedItem);
					}else {
						MonsterDebugger.trace(FlexGlobals.topLevelApplication, "Related item with the id of " + relatedItems[i].relatedId + " not found in project export. ", "Angel Romero", "Warning");
						continue;
					}
				}
			}
			return new ArrayCollection(relatedItemsList);
		}
		
		public function fetchRelatedItemsByTemplateItemName(relatedItems:Array, templateItemName:String):ArrayCollection
		{
			var relatedItemsList:Array = new Array();
			
			for(var i:int = 0; i < relatedItems.length; i++) {
				var relatedItem:ProjectContentItem = fetchProjectContentItemById(relatedItems[i].relatedItemId) as ProjectContentItem;
				var relTemplateItem:TemplateItem = fetchTemplateItemById(relatedItem.templateItemId);
				if(relTemplateItem.name == templateItemName) {					
					relatedItemsList.push(relatedItem);
				}				
			}
			return new ArrayCollection(relatedItemsList);
		}
		
		public function fetchRelatedItemsByTemplateItemType(relatedItems:Array, templateItemType:int):ArrayCollection
		{
			var relatedItemsList:Array = new Array();
			
			for(var i:int = 0; i < relatedItems.length; i++) {
				var relatedItem:ProjectContentItem = fetchProjectContentItemById(relatedItems[i].relatedItemId) as ProjectContentItem;
				var relTemplateItem:TemplateItem = fetchTemplateItemById(relatedItem.templateItemId);
				if(relTemplateItem.itemType == templateItemType) {					
					relatedItemsList.push(relatedItem);
				}				
			}
			return new ArrayCollection(relatedItemsList);
		}
		
		public function fetchRelatedItemsByTemplateItemNameAndRelationType(relatedItems:Array, templateItemName:String, relationType:int):ArrayCollection
		{
			var relatedItemsList:Array = new Array();
			
			for(var i:int = 0; i < relatedItems.length; i++) {
				var relatedItem:ProjectContentItem = fetchProjectContentItemById(relatedItems[i].relatedItemId) as ProjectContentItem;
				var relTemplateItem:TemplateItem = fetchTemplateItemById(relatedItem.templateItemId);
				if(relTemplateItem.name == templateItemName && relatedItems[i].relationType == relationType) {					
					relatedItemsList.push(relatedItem);
				}				
			}
			return new ArrayCollection(relatedItemsList);
		}
		
		public function fetchProjectContentItemsByTemplateItemName(templateItemName:String):ArrayCollection
		{
			var projectContentItems:Array = new Array();
			for (var i:int = 0; i < _allProjectContentItems.length; i++) 
			{
				var projectContentItem:ProjectContentItem = fetchProjectContentItemById(_allProjectContentItems[i]);
				var templateItem:TemplateItem = fetchTemplateItemById(projectContentItem.templateItemId);
				if(templateItem.name == templateItemName) {
					projectContentItems.push(projectContentItem);
				}
			}
			return new ArrayCollection(projectContentItems);
		}
		
		// TODO: Externalize into an separate into a separate UTIL
		private function cleanArrayOfValue(source:Array, value:*):Array
		{
			for (var i:int = 0; i < source.length; i++) {
				if (source[i] == value) {         
					source.splice(i, 1);
					i--;
				}
			}
			return source
		}
		
		private function onXMLQueComplete(e:Event):void
		{
			handleProcesses(_loadingPhase);
		}
		
		
		private function onXMLLoadError(e:IOErrorEvent):void
		{	
			var missingUrl:String = StringUtil.remove(e.text, "Error #2032: Stream Error. URL:");
			MonsterDebugger.trace(FlexGlobals.topLevelApplication, "Missing the following XML file: " + missingUrl, "Angel Romero", "Error");
			
			if(_isRequired)
			{
				Alert.show("Unable to launch the application due to invalid content.  Please contact technical support.", "Unable to Launch", Alert.OK, FlexGlobals.topLevelApplication.stage.parent, onContentError);
			}
		}
		
		
		private function onContentError(e:CloseEvent):void
		{
			ApplicationUtil.exitApplication();
		}
		
		public function get projectObject():ProjectObject
		{
			return _projectObject;
		}
		
		public function get isLazyLoading():Boolean
		{
			return _isLazyLoading;
		}

		public function get isFlatMode():Boolean
		{
			return _isFlatMode;
		}
		public function get allProjectContentItems():Array{
			return DictionaryUtil.getValues(_projectContentItemsDict);
		}

		public function get mode():String
		{
			return _mode;
		}

	}
}
