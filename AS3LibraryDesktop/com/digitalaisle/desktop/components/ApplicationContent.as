package com.digitalaisle.desktop.components
{
	import com.digitalaisle.desktop.components.HTMLBrowser;
	import com.digitalaisle.desktop.skins.ApplicationContentSkin;
	import com.digitalaisle.frontend.events.DASlideshowEvent;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectContentItem;
	import com.digitalaisle.uilibrary.components.DASlideshow;
	import com.digitalaisle.uilibrary.components.PromoView;
	import com.digitalaisle.uilibrary.containers.AssetContainer;
	import com.digitalaisle.uilibrary.containers.ProductPage;
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.modules.ModuleLoader;
	import mx.states.State;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	/**
	 *  Module state using the Module Loader
	 */
	[SkinState("module")]
	
	/**
	 *  Product page state using the ProductPage
	 */
	[SkinState("product")]
	
	/**
	 *  SWF/Image/Video state using the AssetContainer see#AssetContainer
	 */
	[SkinState("asset")]
	
	/**
	 *  Promo slideshow state using the DASlideshow
	 */
	[SkinState("promoSlides")]
	
	/**
	 *  HTML state using the HTMLBrowser
	 */
	[SkinState("html")]
	
	/**
	 *  Promo state
	 */
	[SkinState("promo")]
	
	[Style(name="itemPageSkinClass", type="Class", inherit="no")]
	
	[Style(name="promoViewSkinClass", type="Class", inherit="no")]
	
	public class ApplicationContent extends ContainerBase
	{
		public static const ASSET:String = "asset";
		public static const HTML:String = "html";
		public static const MODULE:String = "module";
		public static const PROMO:String = "promo";
		public static const PROMO_SLIDESHOW:String = "promoSlideshow";
		public static const PRODUCT:String = "product";
		
		[SkinPart(required="true")]
		public var assetContainer:AssetContainer;
		[SkinPart(required="true")]
		public var htmlBrowser:HTMLBrowser;
		[SkinPart(required="true")]
		public var moduleLoader:ModuleLoader;
		[SkinPart(required="true")]
		public var productPage:ProductPage;
		[SkinPart(required="false")]
		public var promoSlideshow:DASlideshow;
		[SkinPart(required="false")]
		public var promoView:PromoView;
		
		
		private var _source:Object;
		private var _contentType:String;
		private var _contentSkinClass:Class;
		private var _lockDomain:Boolean = false;		
		
		// Callback for handling a click on a promo item
		public var promoClickHandler:Function = null;
		
		// Callback for handling a change in the promo slider
		public var promoChangeHandler:Function = null;
		
		public function ApplicationContent()
		{
			super();

			// Setting default skinClass of ApplicationContent
			setStyle("skinClass", ApplicationContentSkin);
		}

		override public function initialize():void
		{
			super.initialize();
		
			states.push(new State({name:"module"}));
			states.push(new State({name:"product"}));
			states.push(new State({name:"asset"}));
			states.push(new State({name:"promoSlides"}));
			states.push(new State({name:"module"}));
			states.push(new State({name:"html"}));
			states.push(new State({name:"promo"}));
		}
		
		override protected function stateChanged(oldState:String, newState:String, recursive:Boolean):void
		{
			super.stateChanged(oldState, newState, recursive);
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			//super.getCurrentSkinState();
			return currentState;
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case promoSlideshow:
					promoSlideshow.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					promoSlideshow.addEventListener(FlexEvent.REMOVE, onComponentRemove, false, 0, true);
					promoSlideshow.addEventListener(DASlideshowEvent.CLICK, onPromoClick, false, 0, true);
					promoSlideshow.addEventListener(DASlideshowEvent.CHANGE, onPromoChange, false, 0, true);
					break;
				case htmlBrowser:
					htmlBrowser.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					htmlBrowser.lockDomain = _lockDomain;
					htmlBrowser.projectContentItem = _source as ProjectContentItem;
					break;
				case moduleLoader:
					moduleLoader.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					moduleLoader.addEventListener(FlexEvent.REMOVE, onComponentRemove, false, 0, true);
					break;
				case productPage:
					productPage.setStyle("skinClass", ApplicationUtil.appProductPageSkinClass);
					productPage.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					break;
				case promoView:
					promoView.addEventListener(FlexEvent.ADD, onComponentAdd, false, 0, true);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case promoSlideshow:
					promoSlideshow.removeEventListener(FlexEvent.ADD, onComponentAdd);
					promoSlideshow.removeEventListener(FlexEvent.REMOVE, onComponentRemove);
					promoSlideshow.removeEventListener(DASlideshowEvent.CLICK, onPromoClick);
					promoSlideshow.removeEventListener(DASlideshowEvent.CHANGE, onPromoChange);
					break;
				case htmlBrowser:
					
					break;
				case moduleLoader:
					moduleLoader.unloadModule();
					moduleLoader.removeEventListener(FlexEvent.ADD, onComponentAdd);
					moduleLoader.removeEventListener(FlexEvent.REMOVE, onComponentRemove);
					break;
				case productPage:
					productPage.removeEventListener(FlexEvent.ADD, onComponentAdd);
					break;
				case promoView:
					promoView.removeEventListener(FlexEvent.ADD, onComponentAdd);
					break;
			}
		}
		
		public function loadContent(source:Object, contentType:String, skinClass:Class = null):void
		{
			_contentSkinClass = skinClass;
				
			_contentType = contentType;
			this.source = source;
		}
		
		private function loadModule(source:String):void
		{
			moduleLoader.unloadModule();
			moduleLoader.addEventListener(ModuleEvent.READY, onModuleReady);
			moduleLoader.addEventListener(ModuleEvent.ERROR, onModuleError);
			moduleLoader.loadModule(source);
		}
		
		private function onModuleReady(e:ModuleEvent):void
		{ 
			moduleLoader.removeEventListener(ModuleEvent.ERROR, onModuleError);
			moduleLoader.removeEventListener(ModuleEvent.READY, onModuleReady);
			dispatchEvent(new ModuleEvent(ModuleEvent.READY));
		}
		
		private function onModuleError(e:ModuleEvent):void
		{
			MonsterDebugger.trace(this, "Error: The following module, " + source + ", failed to load. Please check the location of the file to make sure it is there.", MonsterDebugger.COLOR_ERROR);
		}
		
		public function get source():Object
		{
			return _source;
		}

		public function set source(value:Object):void
		{
			_source = value;
			switch(_contentType)
			{
				case ASSET:
					currentState = "asset";
					break;
				case MODULE:
					if(currentState == "module")
						loadModule(_source as String);
					else
						currentState = "module";
					break;
				case HTML:
					currentState = "html";
					if(htmlBrowser)
					{
						htmlBrowser.lockDomain = _lockDomain;
						htmlBrowser.projectContentItem = _source as ProjectContentItem;
					}
					break;
				case PROMO_SLIDESHOW:
					currentState = "promoSlides";
					break;
				case PRODUCT:
					if(currentState == "product")
						productPage.projectContentItem = _source as ProjectContentItem;
					else
						currentState = "product";
					break;
				case PROMO:
					currentState = "promo";
					if(promoView)
					{
						if(getStyle("promoViewSkinClass"))
							promoView.setStyle("skinClass", getStyle("promoViewSkinClass"));
						promoView.projectContentItem = _source as ProjectContentItem;
					}
					break;
			}
		}
		

		private function onComponentAdd(e:FlexEvent):void
		{
			switch(e.target)
			{
				case promoSlideshow:
					promoSlideshow.dataProvider = _source as ArrayCollection;
					break;
				case htmlBrowser:
					htmlBrowser.lockDomain = _lockDomain;
					htmlBrowser.projectContentItem = _source as ProjectContentItem;
					//htmlBrowser.location = _source as String;
					break;
				case moduleLoader:
					loadModule(_source as String);
					break;
				case productPage:
					productPage.projectContentItem = _source as ProjectContentItem;
					break;
				case promoView:
					if(getStyle("promoViewSkinClass"))
						promoView.setStyle("skinClass", getStyle("promoViewSkinClass"));
					promoView.projectContentItem = _source as ProjectContentItem;
					break;
			}
		}
		
		private function onComponentRemove(e:FlexEvent):void
		{
			switch(e.target)
			{
				case htmlBrowser:
					//htmlBrowser.location = "";
					break;
				case moduleLoader:
					moduleLoader.unloadModule();
					moduleLoader.removeEventListener(ModuleEvent.READY, onModuleReady);
					moduleLoader.removeEventListener(ModuleEvent.ERROR, onModuleError);
					break;
			}
		}
		
		private function onPromoClick(e:DASlideshowEvent):void
		{		
			/*
			// YSK 2011-10-16: Cannot dispatch the event further as otherwise the ProjectContentItem reference inside of 
			// the event gets garbage collected. Instead using a callback method
			// dispatchEvent(e);
			*/
			if (promoClickHandler != null) {
				promoClickHandler(e);
			}
			/*var promoProjectItem:ProjectContentItem = DataManager.getInstance().fetchProjectContentItemById(e.pci.id);
			if(promoProjectItem.relatedItems.length > 0)
				loadContent(promoProjectItem, PROMO);*/
		}
		
		private function onPromoChange(e:DASlideshowEvent):void
		{					
			if (promoChangeHandler != null) {
				promoChangeHandler(e);
			}			
		}
		
		public function get contentType():String
		{
			return _contentType;
		}

		public function set contentType(value:String):void
		{
			_contentType = value;
		}
		
		public function get lockDomain():Boolean
		{
			return _lockDomain;
		}
		
		public function set lockDomain(value:Boolean):void
		{
			_lockDomain = value;
		}
	}
}
