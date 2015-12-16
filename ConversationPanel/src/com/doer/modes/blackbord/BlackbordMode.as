package com.doer.modes.blackbord
{
	import com.doer.meta.paint.PaintStyle;
	import com.doer.meta.paint.ShapeStyle;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ClientComplexDraw;
	import com.metaedu.client.messages.nebula.complex.BoardContainer;
	import com.metaedu.client.messages.nebula.complex.draw.Dot;
	import com.metaedu.client.messages.nebula.complex.draw.DrawOperation;
	
	public class BlackbordMode 
	{
		private static var instance:BlackbordMode = null;
		
		private var shapeDatas:Array = null;
		
		/**
		 * 当前显示的黑板X
		 * **/
		public var showX:Number = 0;
		
		public static function getInstance():BlackbordMode
		{
			if(instance == null)
				instance = new BlackbordMode(new Inner());
			
			return instance;
		}
		
		public function BlackbordMode(inner:Inner)
		{
			shapeDatas = new Array();
		}
		
		/**
		 * 设置初始化登录数据
		 * **/
		public function onLoginInfo(loginData:BoardContainer):void
		{
			showX = loginData.x;
			
			var draws:Vector.<DrawOperation> = loginData.draws;
			
			for(var i:int = 0; i < draws.length; i ++)
			{
				
				var data:Object = {
					
					x : draws[i].x,
					y : draws[i].y,
					w : draws[i].width,
					h : draws[i].height,
					sw : draws[i].horizontalPixels,
					sh : draws[i].verticalPixels,
					r : draws[i].rotation,
					s : draws[i].method,
					t : draws[i].size,
					a : draws[i].url,
					c : draws[i].color,
					d : new Array()
						
				}
				
				for(var j:int = 0; j < draws[i].dots.length; j ++)
				{
					data.d.push({
						x : draws[i].dots[j].x,
						y : draws[i].dots[j].y,
						p : draws[i].dots[j].p
						
					});
				}
				
				shapeDatas.push(data);
			}
			
		}
		
		public function getInvalidateData():Array
		{
			return shapeDatas;
		}
		
		public function savePaintData(data:Object):void
		{
			shapeDatas.push(data);
		}
		
		public function clearData():void
		{
			shapeDatas = new Array();	
			
		}
		
		/**
		 * 转换本服务端数据未本地数据
		 * **/
		public static function changeServDataToLocal(servData:*):Object
		{
			var data:Object = {
				
					x : servData.draw.x,
					y : servData.draw.y,
					w : servData.draw.width,
					h : servData.draw.height,
					sw : servData.draw.horizontalPixels,
					sh : servData.draw.verticalPixels,
					r : servData.draw.rotation,
					s : servData.draw.method,
					t : servData.draw.size,
					a : servData.draw.url,
					c : servData.draw.color,
					d : new Array()
					
			}
			
			for(var i:int = 0; i < servData.draw.dots.length; i ++)
			{
				data.d.push({
					x : servData.draw.dots[i].x,
					y : servData.draw.dots[i].y,
					p : servData.draw.dots[i].p
					
				});
			}
			
			return data;
		}
		
		/**
		 * 转换本地数据到发送数据
		 * **/
		public static function changeLocalDataToSendData(data:Object,isSubScreen:Boolean):ClientComplexDraw
		{
			var sendData:ClientComplexDraw = new ClientComplexDraw();
			
			sendData.index = isSubScreen ? 2 : 1;
			sendData.draw.x = data.x;
			sendData.draw.y = data.y;
			sendData.draw.height = data.h;
			sendData.draw.width = data.w;
			sendData.draw.horizontalPixels = data.sw;
			sendData.draw.verticalPixels = data.sh;
			sendData.draw.rotation = data.r;
			sendData.draw.method = data.s;
			sendData.draw.size = data.t;
			sendData.draw.url = data.a;
			sendData.draw.color = data.c;
			
			var arr:Vector.<Dot> = new Vector.<Dot>();
			
			for(var i:int = 0; i < data.d.length; i ++)
			{
				var dot:Dot = new Dot();
				dot.x = data.d[i].x;
				dot.y = data.d[i].y;
				dot.p = data.d[i].p;
				
				arr.push(dot);
			}
			
			sendData.draw.dots = arr;
			
			return sendData;
		}
		
	}
}

class Inner{};