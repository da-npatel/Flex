package com.digitalaisle.uilibrary.supportClasses
{
	import com.demonsters.debugger.MonsterDebugger;
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.ControlType;
	import com.digitalaisle.frontend.events.DataManagerEvent;
	import com.digitalaisle.frontend.events.SessionEvent;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.managers.KioskServiceManager;
	import com.digitalaisle.frontend.managers.SessionManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.ProjectObject;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.DASequence;
	import com.digitalaisle.uilibrary.keypads.OffScreenKeyboard;
	import com.digitalaisle.uilibrary.popups.Confirm;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.StyleEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	
	import org.casalib.util.LocationUtil;
	import org.casalib.util.ObjectUtil;
	
	import spark.components.Application;
	
	public class TemplateBase extends ContainerBase
	{
		private static const DEFAULT_PRELOADER:String = "components/HPLoader.swf";
		/*protected var applicationUtil:ApplicationUtil = ApplicationUtil.getInstance();*/
		protected var dataManager:DataManager = DataManager.getInstance();
		protected var themeSchemaItem:ProjectContentItem;
		protected var confirmationPopup:Confirm;
		
		[Bindable]
		public var mainMenuCol:ArrayCollection = new ArrayCollection();
		[Bindable]
		public var projectAvatar:String;
		[Bindable]
		public var projectLogo:String;
		
		private var _projectObject:ProjectObject;
		private var _isStylesLoaded:Boolean = false;
		
		public function TemplateBase()
		{
			super();
		
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		override public function initialize():void
		{
			super.initialize();
		}
		
		public function fetchModuleSwfById(id:int):String
		{
			var moduleItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemById(id);
			var moduleSwf:String = DataManager.getInstance().fetchTemplateItemById(moduleItem.templateItemId).viewSWF;
			return moduleSwf;
		}
		
		
		
		protected function onCreationComplete(e:FlexEvent):void
		{
			FlexGlobals.topLevelApplication.frontend.preloadAnimation.load(DEFAULT_PRELOADER);
			MonsterDebugger.enabled = true;
			
			dataManager.addEventListener(DataManagerEvent.THEME_LOADED, onThemeLoaded);
			dataManager.addEventListener(DataManagerEvent.LOADING_COMPLETE, onDataLoaded);
			dataManager.addEventListener(DataManagerEvent.LAZY_LOADING_COMPLETE, onDataLazyLoaded);
			FlexGlobals.topLevelApplication.addEventListener(UserTouchEvent.TOUCH, onUserTouch, true);
			ApplicationUtil.topLevel = this;
			//TODO: Add to DesktopTemplateBase
			/*if(LocationUtil.isAirApplication()) {
				var offScreenKeyboard:OffScreenKeyboard = new OffScreenKeyboard();
				addElement(offScreenKeyboard);
				ApplicationUtil.appKeypad = offScreenKeyboard;
				var sequencer:DASequence = new DASequence();
				addElement(sequencer);
				//sequencer.addEventListener("showadmin", onSequenceShowAdmin, false, 0, true);
				dataManager.init();
			}else if(LocationUtil.isPlugin()) {
				var flashVars:Object = FlexGlobals.topLevelApplication.parameters;
				
				if(ObjectUtil.contains(flashVars, flashVars.dataSource)) {
					dataManager.initHostedModule(flashVars.dataSource);
				}
			}*/
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
		
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
		}
		
		override protected function getCurrentSkinState():String
		{
			return super.getCurrentSkinState();
		}
		
		protected function buildOn():void
		{
			FlexGlobals.topLevelApplication.frontend.buildOn();
		}
		
		
		override protected function onAdded(e:FlexEvent):void
		{
			super.onAdded(e);
			
			com.demonsters.debugger.MonsterDebugger.inspect(e.target);
		}
		
		protected function onThemeLoaded(e:DataManagerEvent):void
		{
			DataManager.getInstance().removeEventListener(DataManagerEvent.THEME_LOADED, onThemeLoaded);
			
			var themeSchemaItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.THEME_SCHEMA);
			if(themeSchemaItems.length > 0)
				themeSchemaItem = themeSchemaItems[0];
			
			if(themeSchemaItem) {
				var templateStyleSWF:String = themeSchemaItem.fetchBinaryContentByType(BinaryType.THEME_STYLE_SWF);
				var styleEventDispatcher:IEventDispatcher = FlexGlobals.topLevelApplication.styleManager.loadStyleDeclarations(templateStyleSWF);
				styleEventDispatcher.addEventListener(StyleEvent.COMPLETE, onStyleSwfComplete);
				styleEventDispatcher.addEventListener(StyleEvent.ERROR, onStyleSwfError);
			}
			
			// Load CUSTOM PRELOADER SWF (if any)
			var preloaderSWF:String = themeSchemaItem.fetchBinaryContentByType(BinaryType.PRELOADER_SWF);
			if(!preloaderSWF == "") {
				FlexGlobals.topLevelApplication.frontend.preloadAnimation.unloadAndStop(true);
				FlexGlobals.topLevelApplication.frontend.preloadAnimation.load(preloaderSWF);
			}
		}
		
		protected function onDataLoaded(e:DataManagerEvent):void
		{
			
			DataManager.getInstance().removeEventListener(DataManagerEvent.LOADING_COMPLETE, onDataLoaded);
			
			
			var projectAvatarItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.PROJECT_AVATAR);
			if(projectAvatarItems.length > 0) {
				var avatarItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemsByOwnerId(projectAvatarItems[0].id)[0];
				projectAvatar = avatarItem.fetchBinaryContentByType(BinaryType.AVATAR_VIDEO);
			}
			
			/*var themeSchemaItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.THEME_SCHEMA);
			if(themeSchemaItems.length > 0)
				themeSchemaItem = themeSchemaItems[0];
			
			if(themeSchemaItem){
				var templateStyleSWF:String = themeSchemaItem.fetchBinaryContentByType(BinaryType.THEME_STYLE_SWF);
				var styleEventDispatcher:IEventDispatcher = FlexGlobals.topLevelApplication.styleManager.loadStyleDeclarations(templateStyleSWF);
				styleEventDispatcher.addEventListener(StyleEvent.COMPLETE, onStyleSwfComplete);
				styleEventDispatcher.addEventListener(StyleEvent.ERROR, onStyleSwfError);
			}*/
			
			var backgroundItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.BACKGROUND);
			if(backgroundItems.length > 0) {
				var backgroundItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemsByOwnerId(backgroundItems[0].id)[0];
				backgroundSource = backgroundItem.fetchBinaryContentByType(BinaryType.IMAGE);
			}
			
			var logoItems:ArrayCollection = DataManager.getInstance().fetchWidgetContentItemsByControlType(ControlType.LOGO);
			if(logoItems.length > 0) {
				var logoItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemsByOwnerId(logoItems[0].id)[0];
				projectLogo = logoItem.fetchBinaryContentByType(BinaryType.IMAGE);
			}
			
			//_projectObject = DataManager.getInstance().projectObject;  // NOte: Replaced with a internal getter. //TODO: needs testing!!!
			
			SessionManager.getInstance().unitId = projectObject.unitId;
			
			/*if(LocationUtil.isAirApplication()) {
				SessionManager.getInstance().addEventListener(SessionEvent.TIMEOUT, onConfirmStart);
				SessionManager.getInstance().init(SessionManager.TRACKING_TIMEOUT, ApplicationUtil.timoutTime, ApplicationUtil.confirmationTime);
			}else {
				
			}*/
			
		}
		
		protected function onDataLazyLoaded(e:DataManagerEvent):void
		{
			DataManager.getInstance().removeEventListener(DataManagerEvent.LAZY_LOADING_COMPLETE, onDataLazyLoaded);
		}
		
		protected function onStyleSwfComplete(e:StyleEvent):void
		{
			e.target.removeEventListener(StyleEvent.COMPLETE, onStyleSwfComplete);
			_isStylesLoaded = true;
		}
		
		protected function onStyleSwfError(e:StyleEvent):void
		{
			MonsterDebugger.trace(this, "Error: Problem loading the template's style swf.  The application will attempt to load the template's default style");
		}
		
		private function onUserTouch(e:UserTouchEvent):void
		{
			ApplicationUtil.updateSession(e.uid, e.action, e.point, e.description);
		}
		
		private function doNothing(e:ResultEvent):void { }
		
		protected function returnHome():void
		{
			ApplicationUtil.returnHome();
		}

		public function get projectObject():ProjectObject
		{
			return DataManager.getInstance().projectObject;
		}

		public function get isStylesLoaded():Boolean
		{
			return _isStylesLoaded;
		}


	}
}