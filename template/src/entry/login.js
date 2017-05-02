import { Component, BeforeMessage, Message, Hero } from 'hero-js';
import { Entry } from 'hero-cli/decorator';
import request from '../common/request';
import {PATH as path} from '../constant/index';

var host = window.location.origin;

var ui2Data = Hero.getState();

var title;

var defaultUIViews = {
      version:0,
      backgroundColor:'ffffff',
      nav:{
          navigationBarHidden:true
      },
      views:[
          {
              class:'DRTextField',
              type:'phone',
              theme:'green',
              frame:{x:'15',r:'15',y:'115',h:'50'},
              placeHolder:'手机号码',
              name:'phone',
              textFieldDidEditing:{name:'phone'},
          },
          {
              class:'DRTextField',
              theme:'green',
              frame:{x:'15',r:'15',y:'178',h:'50'},
              placeHolder:'密码',
              name:'password',
              drSecure:{'secure':true}, // 带小眼睛
              textFieldDidEditing:{name:'password'},
          },
          {
              class:'DRButton',
              name:'loginBtn',
              DRStyle:'B1',
              enable:false,
              frame:{x:'15',r:'15',y:'0',h:'44'},
              yOffset:'password+50',
              title:'登录',
              click:{click:'login'}
          },
          {
              class:'HeroLabel',
              size:14,
              textColor:'00bc8d',
              text:'忘记密码?',
              frame:{x:'15',w:'100',h:'40',y:'0'},
              yOffset:'loginBtn+10',
          },
          {
              class:'HeroButton',
              frame:{x:'15',w:'100',h:'40',y:'0'},
              yOffset:'loginBtn+10',
              click:{command:'goto:'+path+'/forget.html'},
          },
          {
              class:'HeroLabel',
              frame:{w:'1x',h:'50',b:'0'},
              text:'Powered by Dianrong.com',
              alignment:'center',
              attribute:{
                  'color(0,10)':'aaaaaa',
                  'color(10,13)':'00bc8d',
                  'size(0,23)':'14',
              },
          },
          {
              class:'HeroToast',
              name:'toast',
              corrnerRadius:10,
              frame:{w:'300',h:'44'},
              center:{x:'0.5x',y:'0.5x'}
          }
      ]
}

@Entry()
@Component({
  view: defaultUIViews
})
export class DecoratePage {

    @BeforeMessage
    before(data){
      if (ui2Data.phone && ui2Data.password && ui2Data.phone.length > 0 && ui2Data.password.length > 0) {
          Hero.out({datas:{name:'loginBtn',enable:true}});
      }else{
          Hero.out({datas:{name:'loginBtn',enable:false}});
      }
    }

    @Message('__data.click && __data.click == "login"')
    login(data) {
      console.log('Send Login Request...');
      
      request('/api/v2/users/login','POST', {
        identity:ui2Data.phone,
        password:ui2Data.password
      }).then(function(){
        Hero.out({command:'goto:'+host+'/home.html'})
      }, function(){
        console.log('Server Error...')
      });
    }
}
