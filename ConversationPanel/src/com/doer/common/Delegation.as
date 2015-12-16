package com.doer.common
{
	import com.doer.common.interfaces.IDelegate;
	import com.doer.common.interfaces.IVDelegate;
	import com.doer.common.mouse.style.EraserMouseStyle;
	import com.doer.config.ComplexConf;
	import com.doer.meta.MetaCanvas;
	import com.doer.meta.paint.PaintStyle;
	import com.doer.meta.paint.ShapeStyle;
	import com.doer.meta.shape.TextRender;
	import com.doer.meta.utils.MetaPaintEvent;
	import com.doer.modes.nav.NavToolConf;
	import com.doer.utils.LocalCommand;
	import com.doer.utils.LocalCommandEvent;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.NebulaScreenType;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.core.Container;
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.core.IVisualElementContainer;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.BorderContainer;
	
	import view.common.text.TextCompent;
	import view.common.text.TextLayer;
	import view.modes.nav.tool.NavToolBox;

	/**
	 * 实现IDelegate接口的都能被代理
	 * **/
	public class Delegation
	{
		/**
		 * 当前绘图样式
		 * **/
		public var currentPaintStyle:PaintStyle = null;
		
		
		/***
		 * 当前正在显示的课件id
		 * **/
		public var curBookId:String = "";
		
		/**
		 * 当前正在显示的页数
		 * **/
		public var curPage:int = 0;
		
		
		/**
		 * 当前正在播放的动画帧
		 * **/
		public var curFrame:int = 0;
		
		/**
		 * 是否辅屏
		 * **/
		public var isSecondScreen:Boolean = false;
		
		/**
		 * 是否激活
		 * **/
		private var active:Boolean = false;
	
		/**
		 * 需要的代理View
		 * **/
		private var delegateView:IVDelegate = null;
		
		/**
		 * 需要被代理的行为提供者
		 * **/
		private var behaviour:IDelegate = null;
		
		/**
		 * 当前是否文字模式
		 * **/
		private var isTextMode:Boolean = false;
		
		private var navConf:NavToolConf = NavToolConf.getInstance();
		
		/**
		 * 添加绘图代理
		 * **/
		public function addDelegate(delegateView:IVDelegate,behaviour:IDelegate):void
		{
			this.delegateView = delegateView;
			this.behaviour = behaviour;
			
			this.isTextMode = navConf.mainTool == NavToolConf.TOOL_TEXT;
			
			if(!this.isTextMode)
			{
				this.active = isSecondScreen ? navConf.subTool != NavToolConf.TOOL_HAND : navConf.mainTool != NavToolConf.TOOL_HAND;	
			}else
			{
				this.active = false;
			}
			
			if(active)
			{
				var tool:String = isSecondScreen ? navConf.subTool : navConf.mainTool;
				
				currentPaintStyle = getPaintStyleByCommand(tool == NavToolConf.TOOL_PEN ? LocalCommandType.CMD_NAV_PEN : LocalCommandType.CMD_NAV_ERASER);
			}
			
			
			refresh();
			
			delegateView.getCanvas().drawShapeByDatas(behaviour.getInvalidatePaintdata(curBookId,curPage)); //添加初始化数据
			delegateView.getCanvas().addEventListener(MetaPaintEvent.PAINT_FINISH,onFinishPaint);
			
			navConf.addEventListener("sizeChange",onToolChange);
			navConf.addEventListener("colorChange",onToolChange);
			
		}
		
		/**
		 * nav子工具栏状态修改
		 * **/
		private function onToolChange(e:Event):void
		{
			
			var val:Boolean = isSecondScreen;
			
			if(ComplexConf.activeScreen == NebulaScreenType.BOARD && ComplexConf.subActiveScreen == NebulaScreenType.BOARD)
				val = false;
			
			
			var textColor:uint = val ? navConf.subTextColor : navConf.mainTextColor;
			var textSize:int = navConf.getTextSize(val);
			
			if(textCompent != null)
			{
				var size:Number = Math.round(textSize / 1000 * textLayer.height);
				size = size % 2 == 1 ? size ++ : size;
				
				textCompent.textColor = textColor;
				textCompent.textSize = size;
				
				textCompent.refresh();
			}
			
			if(currentPaintStyle != null && (currentPaintStyle.shapeStyle == ShapeStyle.ERASER || currentPaintStyle.shapeStyle == ShapeStyle.POINTS))
			{
				currentPaintStyle = getPaintStyleByCommand( currentPaintStyle.shapeStyle == ShapeStyle.ERASER ? LocalCommandType.CMD_NAV_ERASER : LocalCommandType.CMD_NAV_PEN);
				
				var canvas:MetaCanvas = delegateView.getCanvas();
				
				if(canvas != null)
					canvas.setPaintStyle(currentPaintStyle.thick,currentPaintStyle.color,
						currentPaintStyle.alpha,currentPaintStyle.shapeStyle,currentPaintStyle.dotted,currentPaintStyle.arrowMode);
				
			}
			
		}
		
		
		
		/**
		 * 移除代理
		 * **/
		public function removeDelegate():void
		{
			removeTextCompent();
			
			navConf.removeEventListener("sizeChange",onToolChange);
			navConf.removeEventListener("colorChange",onToolChange);
			
			if(delegateView != null)
			{
				delegateView.getCanvas().removeEventListener(MetaPaintEvent.PAINT_FINISH,onFinishPaint);
				delegateView.clearDrag();
				
			}
			
			this.delegateView = null;
			this.behaviour = null;
			
			
		}
		
		/**
		 * 添加绘图数据
		 * **/
		public function addPaintData(data:Object):void
		{
			if(delegateView != null)
			{
				var canvas:MetaCanvas = delegateView.getCanvas();
				
				if(canvas != null)
					canvas.drawShapeBySingle(data);
			}
			
		}
		
		/**
		 * 刷新当前
		 * **/
		public function onRefresh():void
		{
			if(delegateView != null)
			{
				var canvas:MetaCanvas = delegateView.getCanvas();
				canvas.clear();
				canvas.drawShapeByDatas(behaviour.getInvalidatePaintdata(curBookId,curPage)); //添加初始化数据
			}
			
		}
		
		/**
		 * 本地消息监听
		 * **/
		public function onCommand(cmd:LocalCommand):void
		{
			
			if(!ComplexConf.isClipScreen)
				parseCommand(cmd);
			else
			{
				if(ComplexConf.activeScreen == NebulaScreenType.BOARD && ComplexConf.subActiveScreen == NebulaScreenType.BOARD)
					parseCommand(cmd);
				else
				{
					if(cmd.data.isSub)
					{
						if(isSecondScreen)
							parseCommand(cmd);
					}else
					{
						if(!isSecondScreen)
							parseCommand(cmd);
					}
				}
			}
		
		}
		
		/**
		 * 处理command
		 * **/
		private function parseCommand(cmd:LocalCommand):void
		{
			if(cmd.command == LocalCommandType.CMD_NAV_ERASER || cmd.command == LocalCommandType.CMD_NAV_PEN)
			{
				active = cmd.data.selected;
				isTextMode = false;
				currentPaintStyle = getPaintStyleByCommand(cmd.command);
				
				if(delegateView != null)
					refresh();
			}
			else if(cmd.command == LocalCommandType.CMD_NAV_CLEAR)
			{
				if(delegateView != null)
				{
					if(textCompent != null)
					{
						textLayer.removeElement(textCompent);
						textCompent = null;
					}
					
					behaviour.clear();
					delegateView.getCanvas().clear();
				}
				
			}else if(cmd.command == LocalCommandType.CMD_NAV_TEXT)
			{
				active = false;
				isTextMode = cmd.data.selected;
				
				if(delegateView != null)
					refresh();
				
			}else if(cmd.command == LocalCommandType.CMD_NAV_HAND)
			{
				active = false;
				isTextMode = false;
				
				if(delegateView != null)
					refresh();
			}
		}
		
		private function onFinishPaint(e:MetaPaintEvent):void
		{
			this.behaviour.saveDelegatePaintdata(e.param);
		}
		

		/**
		 * 文字层
		 * **/
		private var textLayer:TextLayer = null;
		
		/**
		 * 文字控件
		 * **/
		private var textCompent:TextCompent = null;
		
		/**
		 * 添加文字组件
		 * **/
		private function appendTextCompent():void
		{
			if(textLayer == null)
			{
				textLayer = delegateView.getLayer();
				
				textLayer.tip.visible = true;
				textLayer.visible = true;
				
				textLayer.content.addEventListener(MouseEvent.CLICK,onTextHandler);
			}

		}
		
		/**
		 * 移除文字组件
		 * **/
		public function removeTextCompent():void
		{
			if(textCompent != null)
				paintText();
			if(textLayer != null)
			{
				textLayer.content.removeEventListener(MouseEvent.CLICK,onTextHandler);
				
				textLayer.visible = false;
				textLayer = null;
			}
		}
		
		private function onTextHandler(e:MouseEvent):void
		{
			var textColor:uint = isSecondScreen ? navConf.subTextColor : navConf.mainTextColor;
			var textSize:int = navConf.getTextSize(isSecondScreen);
			
			var size:Number = Math.round(textSize / 1000 * textLayer.height);
			size = size % 2 == 1 ? size ++ : size;
			
			textLayer.tip.visible = false;
			
			if(textCompent != null)
				paintText();
			
			var mx:Number = textLayer.mouseX;
			var my:Number = textLayer.mouseY;
			
			if(textLayer.height - my < 30)
			{
				Tools.alert("超出区域!");
				return;
			}
			
			textCompent = new TextCompent();

			
			textCompent.x = mx;
			textCompent.y = my;
			
			textCompent.maxWidth = textLayer.width - mx;
			
			textCompent.maxHeight = textLayer.height - my;
				
			
			textLayer.addElementAt(textCompent,textLayer.numElements - 2);
			
			textCompent.textColor = textColor;
			textCompent.textSize = size;
			
			textLayer.stage.focus = null;
		}
		
		private function paintText():void
		{		
			
			if(textCompent.textStr == null || textCompent.textStr.replace(new RegExp(" ","g")) == "")
			{
				textLayer.removeElement(textCompent);
				textCompent = null;
				return;
			}
			
			var canvas:MetaCanvas = delegateView.getCanvas();
			
			var data:Object = {
				
				s : ShapeStyle.TEXT,
				t : textCompent.textSize,
				c : textCompent.textColor,
				sw : textLayer.width,
				sh : textLayer.height,
				w : textCompent.width,
				h : textCompent.height,
				x : (textCompent.x + canvas.getShowArea().x) / textLayer.height,
				y : textCompent.y / textLayer.height,
				r : 0,
				a : textCompent.textStr,
				d : []
					
			}
				
			this.behaviour.saveDelegatePaintdata(data);
				
			delegateView.getCanvas().drawShapeBySingle(data);
				
			textLayer.removeElement(textCompent);
			textCompent = null;
			
		}
		
		/**
		 * 刷新canvas状态
		 * **/
		private function refresh():void
		{
			var canvas:MetaCanvas = delegateView.getCanvas();
			
			canvas.active = active;
			
			if(!active)
				delegateView.readyDrag();
			else
				delegateView.clearDrag();
			
			if(currentPaintStyle != null)
				canvas.setPaintStyle(currentPaintStyle.thick,currentPaintStyle.color,
					currentPaintStyle.alpha,currentPaintStyle.shapeStyle,currentPaintStyle.dotted,currentPaintStyle.arrowMode);
				
			if(isTextMode)
				appendTextCompent();
			else
				removeTextCompent();
		}
		
		/**
		 * 获取画笔样式
		 * **/
		private function getPaintStyleByCommand(command:String):PaintStyle
		{
			var eSize:int = navConf.getEraserSize(isSecondScreen);
			
			var pSize:int = navConf.getPenSize(isSecondScreen);
			
			var pColor:int = isSecondScreen ? navConf.subPenColor : navConf.mainPenColor;
			
			if(command == LocalCommandType.CMD_NAV_PEN)
			{
				return new  PaintStyle(pSize,pColor,1,ShapeStyle.POINTS);
			}else if(command == LocalCommandType.CMD_NAV_ERASER)
			{
				return new PaintStyle(eSize,0,1,ShapeStyle.ERASER,true);
			}
			
			throw new Error("画笔样式获取错误！");
		}
	}
}
