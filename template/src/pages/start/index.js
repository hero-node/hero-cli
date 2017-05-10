import { Component,AfterMessage, BeforeMessage, ViewWillDisappear, ViewWillAppear, Message, Boot, Hero } from 'hero-js';
import { Entry } from 'hero-cli/decorator';
import ui from './view';
import {PATH as path} from '../../constant/index';

var ui2Data = Hero.getState();

@Entry({
  filename: 'pages/start.html'
})
// This is cause HTML login.html will generated in `pages` folder,
// So we can access /pages/start.html

// The default action is keep the same path structure as the current JavaScript like below:
// @Entry({
//    filename: 'entry/start/index.html'
// })
// This is use [html-webpack-plugin](https://www.npmjs.com/package/html-webpack-plugin) generate HTML.
// Valid options in @Entry as same as html-webpack-plugin.
@Component({
  view: ui
})
export class DecoratePage {

    @Boot
    boot(){
      console.log('Bootstrap successfully!');
    }

    @ViewWillAppear
    enter(){
      console.log('Enter this page...');
    }
    @ViewWillDisappear
    leave(){
      console.log('I\'m going to leave this page...');
    }
    @BeforeMessage
    before(data){
      console.log('Before Handling Message from NativeApp...', data);
      if (ui2Data.phone && ui2Data.password && ui2Data.phone.length > 0 && ui2Data.password.length > 0) {
          Hero.out({datas:{name:'loginBtn',enable:true}});
      }else{
          Hero.out({datas:{name:'loginBtn',enable:false}});
      }
    }

    @Message(function(data){ return data.click && data.click === "login";})
    login(data) {
      console.log('Sending request...');
      setTimeout(function(){
        Hero.out({command:'goto:'+path+'/pages/home/index.html'})
      },300)
    }

    @AfterMessage
    after(data){
      console.log('After Handling Message from NativeApp...', data);
    }
}
