/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-05-26
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
package __src.ui{
	// import public package
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	// class
	public class ADialog extends Sprite{
	/**Public Const
	---------------------------*/
		public static const TYPE_WAIT:int = 1001;
		public static const TYPE_ALERT:int = 1002;
		public static const TYPE_PROMPT:int = 1003;

		public static const BN_OK:int = 2001;
		public static const BN_CANCEL:int = 2002;
		
	/**Private Const
	---------------------------*/
		private static const BG_ALPHA:Number = 0.5;
		private static const BG_COLOR:int = 0x336699;
		
		private static const DLG_PADDING:int = 12;
		private static const DLG_ROUND:int = 12;
		private static const DLG_COLOR:int = 0x003366;
				
		private static const LINE_HEIGHT:int = 30;

	/**Private Variable
	---------------------------*/
		private static var ins:ADialog;
		private static var target:DisplayObjectContainer;
		private static var nType:int;
		private static var fnCallback:Function;
		
		private static var bnOk:AButton;
		private static var bnCancel:AButton;
		private static var tfInput:TextField
	
	/**Public Function
	---------------------------*/
		public static function mount(t:DisplayObjectContainer):void{
			target = t;
		}
		public static function show(text:String,type:int = ADialog.TYPE_ALERT,callback:* = null):void{
			// close previous window
			close();
			// create instance
			ins = new ADialog;
			// save data
			nType = type;
			fnCallback = callback;
			// creat mask layout
			var bg:Sprite = new Sprite;
			bg.graphics.beginFill(BG_COLOR,BG_ALPHA);
			bg.graphics.drawRect(0,0,target.stage.stageWidth,target.stage.stageHeight);
			bg.graphics.endFill();
			ins.addChild(bg);
			// creat dialog background
			var dlg:Sprite = new Sprite;
			dlg.name = 'dialog';
			ins.addChild(dlg);
			// create prompt text field
			var tfPrompt:TextField = new TextField();
			tfPrompt.autoSize = TextFieldAutoSize.CENTER;
			tfPrompt.defaultTextFormat = new TextFormat(null,12,0xFFFFFF);
			tfPrompt.text = text;
			tfPrompt.x = 0;
			tfPrompt.y = 0;
			dlg.addChild(tfPrompt);
			var sh:Number = tfPrompt.textHeight + 8;
			// create component
			var dlg_w:int = 0;
			var dlg_h:int = 0;
			if(nType == ADialog.TYPE_WAIT){
				dlg_w = tfPrompt.width;
				dlg_h = sh;
			}
			else if(nType == ADialog.TYPE_ALERT){
				bnOk = new AButton;
				bnOk.label = '了解';
				bnOk.useHandCursor = true;
				bnOk.addEventListener(MouseEvent.CLICK,OnClick_Ok);

				dlg_w = (tfPrompt.width < bnOk.width ? bnOk.width : tfPrompt.width);
				dlg_h = sh + LINE_HEIGHT;
				
				bnOk.x = (dlg_w - bnOk.width) / 2;
				bnOk.y = sh + (LINE_HEIGHT - bnOk.height) / 2;
				dlg.addChild(bnOk);
			}
			else if(nType == ADialog.TYPE_PROMPT){
				bnOk = new AButton;
				bnOk.label = '确定';
				bnOk.useHandCursor = true;
				bnOk.addEventListener(MouseEvent.CLICK,OnClick_Ok);
				
				bnCancel = new AButton;
				bnCancel.label = '返回';
				bnCancel.useHandCursor = true;
				bnCancel.addEventListener(MouseEvent.CLICK,OnClick_Cancel);
				
				// create input text field
				tfInput = new TextField;
				tfInput.name = 'input';
				tfInput.type = TextFieldType.INPUT;
				tfInput.defaultTextFormat = new TextFormat(null,12,0x000000);
				tfInput.border = true;
				tfInput.borderColor = 0x999999;
				tfInput.background = true;
				tfInput.backgroundColor = 0xFFFFFF;
				tfInput.maxChars = 10;
				tfInput.height = tfInput.textHeight + 2;
				tfInput.width = 290;
				tfInput.addEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
				
				dlg_w += (tfPrompt.width > tfInput.width ? tfPrompt.width : tfInput.width);
				dlg_h = sh + LINE_HEIGHT * 2;
				
				var bnWidth:int = bnOk.width + 15 + bnCancel.width;
				tfInput.x = 0;
				tfInput.y = sh;
				bnOk.x = (dlg_w - bnWidth) / 2;
				bnOk.y = sh + LINE_HEIGHT + (LINE_HEIGHT - bnOk.height) / 2;
				bnCancel.x = bnOk.x + 15 + bnOk.width;
				bnCancel.y = bnOk.y;
				
				dlg.addChild(bnOk);
				dlg.addChild(bnCancel);
				dlg.addChild(tfInput);
				// focus
				target.stage.focus = tfInput;
			}
			dlg.graphics.beginFill(DLG_COLOR);
			dlg.graphics.drawRoundRect(-DLG_PADDING,-DLG_PADDING,dlg_w + DLG_PADDING * 2,dlg_h + DLG_PADDING * 2,DLG_ROUND);
			dlg.graphics.endFill();
			dlg.x = (ins.width - dlg.width) / 2;
			dlg.y = (ins.height - dlg.height) / 2;
			
			dlg.filters = new Array(new GlowFilter(0x000000),new DropShadowFilter(6));
			target.addChild(ins);
		}
		public static function close():void{
			bnOk && bnOk.removeEventListener(MouseEvent.CLICK,OnClick_Ok);
			bnCancel && bnCancel.removeEventListener(MouseEvent.CLICK,OnClick_Cancel);
			tfInput && tfInput.removeEventListener(KeyboardEvent.KEY_UP,OnKeyUp);
			ins && ins.parent.removeChild(ins);
			ins = null;
		}

	/**Private Function
	---------------------------*/
		private static function OnClick_Ok(e:MouseEvent):void{
			if(fnCallback != null){
				if(nType == ADialog.TYPE_ALERT){
					fnCallback();
				}
				if(nType == ADialog.TYPE_PROMPT){
					var t1:* = ins.getChildByName('dialog');
					var t2:* = t1.getChildByName('input');
					fnCallback(ADialog.BN_OK,t2.text);
				}
			}
			close();
		}
		private static function OnClick_Cancel(e:MouseEvent):void{
			if(fnCallback != null){
				if(nType == ADialog.TYPE_PROMPT){
					fnCallback(ADialog.BN_CANCEL,null);
				}
			}
			close();
		}
		private static function OnKeyUp(e:KeyboardEvent):void{
			if(e.keyCode == 13){
				OnClick_Ok(null);
			}
		}
	}
}