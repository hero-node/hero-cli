import { PATH as path } from '../../constant/index';

export default {
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
            frame: { x: '15', r: '15', y: '115', h: '50' },
            placeHolder: 'Telephone',
            name: 'phone',
            textFieldDidEditing: { name: 'phone' }
        },
        {
            class: 'DRTextField',
            theme: 'green',
            frame: { x: '15', r: '15', y: '178', h: '50' },
            placeHolder: 'Password',
            secure: true,
            name: 'password',
            drSecure: { 'secure': true }, // 带小眼睛
            textFieldDidEditing: { name: 'password' }
        },
        {
            class: 'DRButton',
            name: 'loginBtn',
            DRStyle: 'B1',
            enable: false,
            frame: { x: '15', r: '15', y: '0', h: '44' },
            yOffset: 'password+50',
            title: 'Sign In',
            click: { click: 'login' }
        },
        {
            class: 'HeroLabel',
            size: 14,
            textColor: '00bc8d',
            text: 'Forget Password?',
            frame: { x: '15', w: '150', h: '40', y: '0' },
            yOffset: 'loginBtn+10'
        },
        {
            class: 'HeroButton',
            frame: { x: '15', w: '100', h: '40', y: '0' },
            yOffset: 'loginBtn+10',
            click: { command: 'goto:' + path + '/forget.html' }
        },
        {
            class: 'HeroToast',
            name: 'toast',
            corrnerRadius: 10,
            frame: { w: '300', h: '44' },
            center: { x: '0.5x', y: '0.5x' }
        }
    ]
};
