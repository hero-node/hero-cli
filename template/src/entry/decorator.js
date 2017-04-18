import { Component, ViewWillAppear, ViewWillDisappear,BeforeMessage,AfterMessage, Boot, Message, API } from 'hero-js/decorator';

var path = window.location.origin + '/borrower-static/cash/v1.1';

var ui2Data = API.getState();

var defaultUIViews = {
    version: 0,
    backgroundColor: 'ffffff',
    nav: {
        navigationBarHidden: true
    },
    views: [
        {
            class: 'DRTextField',
            type: 'phone',
            theme: 'green',
            frame: {
                x : '15',
                r : '15',
                y : '115',
                h : '50'
            },
            placeHolder: '手机号码',
            name: 'phone',
            textFieldDidEditing: {
                name: 'phone'
            }
        }, {
            class: 'DRTextField',
            theme: 'green',
            frame: {
                x : '15',
                r : '15',
                y : '178',
                h : '50'
            },
            placeHolder: '密码',
            name: 'password',
            drSecure: {
                'secure': true
            }, // 带小眼睛
            textFieldDidEditing: {
                name: 'password'
            }
        }, {
            class: 'AppButton',
            frame: {
                x : '15',
                r : '15',
                y : '0',
                h : '44'
            },
            title: '自定义的继承自Hero按钮实例'
        }, {
            class: 'DRButton',
            name: 'loginBtn',
            DRStyle: 'B1',
            enable: false,
            frame: {
                x : '15',
                r : '15',
                y : '0',
                h : '44'
            },
            yOffset: 'password+50',
            title: '登录',
            click: {
                click: 'login'
            }
        }, {
            class: 'HeroLabel',
            size: 14,
            textColor: '00bc8d',
            text: '忘记密码?',
            frame: {
                x : '15',
                w : '100',
                h : '40',
                y : '0'
            },
            yOffset: 'loginBtn+10'
        }, {
            class: 'HeroButton',
            frame: {
                x : '15',
                w : '100',
                h : '40',
                y : '0'
            },
            yOffset: 'loginBtn+10',
            click: {
                command: 'goto:' + path + '/forget.html'
            }
        }, {
            class: 'HeroLabel',
            frame: {
                w : '1x',
                h : '50',
                b : '0'
            },
            text: 'Powered by Dianrong.com',
            alignment: 'center',
            attribute: {
                'color(0,10)': 'aaaaaa',
                'color(10,13)': '00bc8d',
                'size(0,23)': '14'
            }
        }, {
            class: 'HeroToast',
            name: 'toast'
        }
    ]
}
@Component({template: '../pageTemplate.html', title: '演示页面'})
export class DecoratePage {
    constructor() {
        API.resetUI(defaultUIViews);
        this.title = 'This is my title';
    }

    @Boot
    bootstrap() {
        console.log(this.title + ' Bootstrap Method')
    }
    @AfterMessage
    after(data){
      console.log('Handle Message Successfully');
    }
    @BeforeMessage
    before(data){
      if (ui2Data.phone && ui2Data.password && ui2Data.phone.length > 0 && ui2Data.password.length > 0) {
          API.out({ datas: { name: 'loginBtn', enable: true } });
      } else {
          API.out({ datas: { name: 'loginBtn', enable: false } });
      }
    }
    @ViewWillAppear
    viewWillAppear() {
        console.log('View will appear...')
    }

    @ViewWillDisappear
    viewWillDisappear() {
      console.log('View will disappear...')
    }
    // eslint-disable-next-line
    @Message('__data.click && __data.click=="login"')
    login(data) {
        console.log('login....');
        API.out({command: 'showLoading'});

        fetch(`${process.env.backendURL}/api/user?identity=${ui2Data.phone}&password=${ui2Data.password}`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json'
          }
        }).then(function(){
        }).catch(function(){
        }).then(function(){
          API.out({command:'stopLoading'});
        });
    }
}
