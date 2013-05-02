package com.digitalaisle.frontend.managers {
	
	import com.digitalaisle.frontend.events.FontManagerEvent;
	
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.text.Font;

	public class FontManager extends EventDispatcher {
		
		private static var instance:FontManager;
		private static var allowInstantiation:Boolean;
		
		private var fontfile:String; 	// "app:/skins/MyriadPro.swf"
		private var fontnames:Array;
		private var fontldr:Loader;
		private var fontclass:Class;
		
		public function FontManager() {
			if (!allowInstantiation) {
				throw new Error("FontManager Error: Use FontManager.getInstance() instead of new keyword.");
			}
		}
		
		public static function getInstance():FontManager {
			if (instance == null) {
				allowInstantiation = true;
				instance = new FontManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		public function loadFontSWF(file:String, ...names):void {
			fontfile = file;
			fontnames = new Array();
			for(var i:int=0; i<names.length; i++){
				if(names[i] is String){
					fontnames.push(names[i]);
				}
			}			
			fontldr = new Loader();
			fontldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onFontIOError, false, 0, true);
			fontldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFontSecurityError, false, 0, true);
			fontldr.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontComplete, false, 0, true);
			fontldr.load(new URLRequest(fontfile));
		}
		
		protected function onFontIOError(e:IOErrorEvent):void {
			trace("FontManager: "+e);		
		}
		
		protected function onFontSecurityError(e:SecurityError):void {
			trace("FontManager: "+e);			
		}
		
		protected function onFontComplete(e:Event):void {
			trace("FontManager: "+e);
			for(var i:int=0; i<fontnames.length; i++){
				trace(fontfile+" has '"+fontnames[i]+"': "+fontldr.contentLoaderInfo.applicationDomain.hasDefinition(fontnames[i]));
			
				if(fontldr.contentLoaderInfo.applicationDomain.hasDefinition(fontnames[i])){
					fontclass = fontldr.contentLoaderInfo.applicationDomain.getDefinition(fontnames[i]) as Class;
					Font.registerFont(fontclass);				
				}
			}
			trace("Available Fonts: "+Font.enumerateFonts(false));
			dispatchEvent(new FontManagerEvent(FontManagerEvent.COMPLETE));
		}
		
		public function hasFont(name:String, checkDeviceFonts:Boolean = false):Boolean {
			var exists:Boolean;
			var fonts:Array = Font.enumerateFonts(false);
			for(var f:int=0; f<fonts.length; f++){				
				if(fonts[f].fontName == name){				
					exists = true;
				}
			}
			return exists;
		}
		
	}
}