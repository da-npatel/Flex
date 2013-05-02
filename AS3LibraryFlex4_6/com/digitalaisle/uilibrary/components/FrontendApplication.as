package com.digitalaisle.uilibrary.components
{
	import com.digitalaisle.uilibrary.skins.FrontendApplicationSkin;
	import com.digitalaisle.utils.MiscUtil;
	import com.greensock.TweenLite;
	import com.greensock.dataTransfer.XMLManager;
	import com.greensock.easing.Linear;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.events.StyleEvent;
	//Include Spark Module Loader replacing MX Module Loader
	//import mx.modules.ModuleLoader;
	import spark.modules.ModuleLoader;
	//End
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.casalib.util.LocationUtil;
	import org.casalib.util.ObjectUtil;
	import org.casalib.util.StageReference;
	
	import spark.components.SkinnableContainer;
	import spark.primitives.Rect;
	
	public class FrontendApplication extends SkinnableContainer
	{
		private static const GLOBAL_STYLE_SWF:String = "css/globalStyle.swf";
		
		/** Skin Parts **/
		[SkinPart(required="true")]		
		public var templateldr:ModuleLoader;		
		[SkinPart(required="false")]
		public var preloadAnimation:SWFLoader;
		[SkinPart(required="true")]
		public var curtain:Rect;	
		
		public static var baseURL:String = LocationUtil.isAirApplication() ? "" : MiscUtil.getFilePath(FlexGlobals.topLevelApplication.url);
		
		//Current Handle for release build for template swf's or any swf that loads a module
		//public var releaseBuild:Boolean = false;
		public static var topLevelDict:Dictionary = new Dictionary(true);		// NOT BEING USED???
		private var _templateSWF:String = "";
		
		public function FrontendApplication()
		{
			super();
			setStyle("skinClass", FrontendApplicationSkin);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			addEventListener(FlexEvent.PREINITIALIZE, onPreinitialize);
		}
		
		public function buildOn():void
		{
			preloadAnimation.unloadAndStop();
			TweenLite.to(curtain, 1.5, {delay:1, alpha:0, ease:Linear.easeNone, onComplete:onBuildOnComplete});
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
		
			switch(instance)
			{
				case preloadAnimation:
					preloadAnimation.addEventListener(IOErrorEvent.IO_ERROR, onPreloadAnimationError);
					preloadAnimation.addEventListener(Event.COMPLETE, onPreloadAnimationComplete);
					break;
				case templateldr:
					templateldr.addEventListener(ModuleEvent.ERROR, onTemplateError);
					templateldr.addEventListener(ModuleEvent.READY, onTemplateReady);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
		}
		
		private function onBuildOnComplete():void
		{
			removeElement(curtain);
		}
		
		private function onPreinitialize(e:FlexEvent):void
		{
			var styleEventDispatcher:IEventDispatcher = FlexGlobals.topLevelApplication.styleManager.loadStyleDeclarations(FrontendApplication.baseURL + GLOBAL_STYLE_SWF);
			styleEventDispatcher.addEventListener(StyleEvent.COMPLETE, onStyleSwfComplete);
			styleEventDispatcher.addEventListener(StyleEvent.ERROR, onStyleSwfError);
		}
		
		protected function onCreationComplete(e:FlexEvent):void
		{
			var configXMLManager:XMLManager = new XMLManager();
			configXMLManager.addEventListener(Event.COMPLETE, onConfigXMLLoaded, false, 0, true);
			var configURL:String = FrontendApplication.baseURL + "Config/Unit.xml";
			configXMLManager.load(configURL); 
			
			StageReference.setStage(FlexGlobals.topLevelApplication.stage); 
			removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function onTemplateError(e:ModuleEvent):void {	
			MonsterDebugger.trace(this, "Error: The following template swf, " + _templateSWF + ", failed to load. Please check the location of the file to make sure it is there.", MonsterDebugger.COLOR_ERROR);
			templateldr.removeEventListener(ModuleEvent.ERROR, onTemplateError);
			templateldr.removeEventListener(ModuleEvent.READY, onTemplateReady);
			//NativeApplication.nativeApplication.exit();
		}
		
		private function onTemplateReady(e:ModuleEvent):void {	
			templateldr.removeEventListener(ModuleEvent.ERROR, onTemplateError);
			templateldr.removeEventListener(ModuleEvent.READY, onTemplateReady);
		}
		
		private function onPreloadAnimationComplete(e:Event):void
		{
			preloadAnimation.removeEventListener(IOErrorEvent.IO_ERROR, onPreloadAnimationError);
			preloadAnimation.removeEventListener(Event.COMPLETE, onPreloadAnimationComplete);
		}
		
		private function onPreloadAnimationError(e:IOErrorEvent):void
		{
			MonsterDebugger.trace(this, "Error: The following swf, " + preloadAnimation.source + ", failed to load. Please check the location of the file to make sure it is there.", MonsterDebugger.COLOR_ERROR);
		}
		
		private function onStyleSwfComplete(e:StyleEvent):void
		{
			e.target.removeEventListener(StyleEvent.COMPLETE, onStyleSwfComplete);
		}
		
		private function onStyleSwfError(e:StyleEvent):void
		{
			MonsterDebugger.trace(this, "Error: Problem loading the global style swf.  Please double check to see if the global style swf is placed within css folder.  It can be found within the AssetLibrary project.", MonsterDebugger.COLOR_ERROR);
		}
		
		private function onConfigXMLLoaded(e:Event):void
		{
			FrontendApplication.topLevelDict["Config"] = ObjectUtil.clone(e.target.parsedObject);
			e.target.removeEventListener(Event.COMPLETE, onConfigXMLLoaded);
			e.target.destroy();
			
			// Load Template SWF
			_templateSWF = FrontendApplication.topLevelDict["Config"].project[0].contentTemplate[0].uri[0].nodeValue;
			if(!FlexGlobals.topLevelApplication.releaseBuild){
				_templateSWF = "ui/templates/" + _templateSWF;
			}else {
				_templateSWF = FrontendApplication.baseURL + "projects/" + FrontendApplication.topLevelDict["Config"].project[0].uri[0].nodeValue + "/" +_templateSWF;
			}
			
			templateldr.loadModule(_templateSWF);
		}

		
			

	}
}
