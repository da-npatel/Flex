package com.digitalaisle.frontend.utils {
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.*;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class LoadQueue extends EventDispatcher {
		
		private var _autoLoad:Boolean = true;
		private var _ldrs:Array;
		private var _failed:Array;
		private var loaded:Array;
		private var loadTimer:Timer;
		
		public function LoadQueue(){
			_ldrs = new Array();
			_failed = new Array();
		}
		
		// Public LoadQueue Methods =========================================================================================
		
		public function add(file:String, required:Boolean = false):void {
			if(file == null || file == ""){
				return;
			}
			if (isDuplicate(file)) {
				//trace(file+" is a duplicate asset and will not be reloaded.");
				return;
			}else{
				//trace(file+" is a new unique asset.");
			}
			
			var ldr:*;
			var req:URLRequest = new URLRequest(file);
			var obj:Object = new Object();
			var type:String = urlType(file);
			switch(type){
				case "file":
					ldr = new Loader();
				break;
								
				case "url":
					ldr = new URLLoader();
				break;
				
				default:
					//trace("Error: Could not determine queue asset type. "+file);
					return;
				break;
			}
						
			obj.file = file;
			obj.required = required; // TODO Implement optional tier for assets			
			obj.ldr = ldr;
			obj.req = req;
			_ldrs.push(obj);
			
			/*if(_autoLoad){
				obj.status = "loading";
				//startLoader(obj);
			} else {
				obj.status = "pending";
			}*/
		}
		
		public function load():void {
			if(_ldrs.length > 0){				
				for(var i:int = 0; i < _ldrs.length; i++){
					startLoader(_ldrs[i]);
				}				
				loadTimer = new Timer(100);
				loadTimer.addEventListener(TimerEvent.TIMER, loadListener, false, 0, true);
				loadTimer.start();
			} else {
				//trace("Warning: LoadQueue did not start because load list is empty."); 
				dispatchEvent(new Event("emptyqueue"));
			}
		} 
		
		public function getAssetByURL(url:String):DisplayObject {
			for(var i:int = 0; i < _ldrs.length; i++){	
				if(_ldrs[i].req.url == url){					
					return _ldrs[i].ldr.content;
				}
			}
			return null;
		}
		
		public function destroy():void {
			if(loadTimer.running){
				loadTimer.stop();
			}
			loadTimer.removeEventListener(TimerEvent.TIMER, loadListener);
			for(var i:int=0; i < _ldrs.length; i++){
				stopLoader(_ldrs[i]);
			}
		}
		
		// Internal Loader Methods ========================================================================================
		
		private function loadListener(e:Event):void { // Listen for all assets
			var loaded:int = 0;
			var total:int = _ldrs.length;
			
			for(var i:int = 0; i < _ldrs.length; i++){
				switch(_ldrs[i].status){
					case "loading":						
					break;
					case "loaded":
						loaded++;
					break;
					case "pending":
					break;
				}
			}			
			//trace(loaded+" of "+total+" assets loaded.");
			if (loaded == total) { // All required assets loaded
				//trace("All "+total+" assets loaded. "+_failed.length+" asset error.");				
				loadTimer.removeEventListener(TimerEvent.TIMER, loadListener);
				dispatchEvent(new Event("assetsloaded"));
			}
		}
		
		private function startLoader(obj:Object):void {
			if (obj.ldr is Loader) {
				obj.ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, assetLoaded, false, 0, true);
				obj.ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, assetIOError, false, 0, true);
				obj.ldr.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, assetSecurityError, false, 0, true);
				obj.ldr.load(obj.req);
			} else if (obj.ldr is URLLoader) {
				
			}
		}
		
		private function stopLoader(obj:Object):void {
			if (obj.ldr is Loader) {
				obj.ldr.contentLoaderInfo.removeEventListener(Event.COMPLETE, assetLoaded);
				obj.ldr.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, assetIOError);
				obj.ldr.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, assetSecurityError);			
			} else if (obj.ldr is URLLoader) {
				
			}
		}
		
		private function assetSecurityError(e:SecurityErrorEvent):void {
			//trace("Asset Security Error: "+e);	
			removeAsset(e.target);
		}
		
		private function assetIOError(e:IOErrorEvent):void{
			//trace("Asset IO Error: "+e);
			removeAsset(e.target);
		}
		
		private function assetLoaded(e:Event):void{
			//trace("Asset Loaded: "+getAsset(e.target).req.url);
			var obj:Object = getAsset(e.target);
			if(obj.ldr.content is Bitmap){
				obj.ldr.content.smoothing = true;
			}
			obj.status = "loaded";
			stopLoader(obj);
		}
		
		private function removeAsset(ldr:*):void {
			var num:int = getAssetNum(ldr);			
			//var sliced:Array = _ldrs.slice(num, num + 1);		
			_failed = _failed.concat(_ldrs.slice(num, num + 1));
			_ldrs.splice(num, 1);
			trace("Remove Asset: failed: "+_failed+" ldrs: "+_ldrs);
		}
		
		private function getAsset(ldr:*):Object {							
			for(var i:int = 0; i < _ldrs.length; i++){				
				if(_ldrs[i].ldr.contentLoaderInfo == ldr){
					return _ldrs[i];	
					break;
				}
			}			
			return null;
		}
		
		private function getAssetNum(ldr:*):int {
			var num:int = -1;
			for(var i:int = 0; i < _ldrs.length; i++){
				if(_ldrs[i].ldr.contentLoaderInfo == ldr){
					num = i;
					break;				
				}
			}
			return num;
		}
				
		private function isDuplicate(url:String):Boolean {
			var result:Boolean;			
			for(var i:int = 0; i < _ldrs.length; i++){						
				if(_ldrs[i].req.url == url){				
					result = true;
				}
			}		
			return result;
		}
		
		private function urlType(url:String):String {
			if(url == null){
				return null;
			}
			var type:String;
			if(url.indexOf(".html") >= 0 || url.indexOf(".aspx") >= 0 || url.indexOf(".asp") >= 0 || url.indexOf(".htm") >= 0  || url.indexOf(".php") >= 0  || url.indexOf(".htm") >= 0) {
				type = "url";
			} else {
				type = "file";
			}
			return type;
		}
		
		
		// Getters & Setters ========================================================================================================
		
		public function get ldrs():Array { return _ldrs; }		
		public function get failed():Array { return _failed; }
	}	
}