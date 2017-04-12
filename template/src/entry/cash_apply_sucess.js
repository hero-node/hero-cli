require('hero-js');

var API = window.API;

API.boot = function () {};
// eslint-disable-next-line
API.special_logic = function (data) {
    if (data.click === 'done') {
        window.location.href = 'dianrong://redirect?version=2&action=MainTab&pageName=mine&closeSelf=true';
    }
};
API.reloadData = function () {};

window.ui = {
    version: 0,
    backgroundColor: 'f5f5f5',
    nav: {
        title: '申请变现',
        navigationBarHiddenH5: true
    },
    views: [
        {
            class: 'UIView',
            frame: {
                w: '1x',
                h: '357'
            },
            backgroundColor: 'ffffff'
        }, {
            class: 'HeroImageView',
            frame: {
                x: '0',
                w: '60',
                y: '0',
                h: '60'
            },
            center: {
                x: '0.5x',
                y: '74'
            },
            image: 'icon_success'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '116',
                h: '19'
            },
            textColor: '00bc8d',
            alignment: 'center',
            size: 16,
            text: '变现申请已提交'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '141',
                h: '15'
            },
            textColor: 'aaaaaa',
            alignment: 'center',
            size: 14,
            text: '系统自动审核中'
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                y: '196',
                h: '1'
            },
            backgroundColor: 'eeeeee'
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                y: '256',
                h: '1'
            },
            backgroundColor: 'eeeeee'
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                y: '306',
                h: '1'
            },
            backgroundColor: 'eeeeee'
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                y: '356',
                h: '1'
            },
            backgroundColor: 'eeeeee'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                w: '200',
                y: '218',
                h: '17'
            },
            text: '变现金额',
            textColor: '666666',
            size: 16
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                w: '200',
                y: '273',
                h: '17'
            },
            text: '还款日',
            textColor: '666666',
            size: 16
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                w: '200',
                y: '320',
                h: '17'
            },
            text: '应还金额',
            textColor: '666666',
            size: 16
        }, {
            class: 'HeroLabel',
            frame: {
                r: '15',
                w: '200',
                y: '206',
                h: '23'
            },
            text: API.fmoney(localStorage.amount, 2),
            alignment: 'right',
            textColor: '333333',
            size: 16
        }, {
            class: 'HeroLabel',
            frame: {
                r: '15',
                w: '200',
                y: '230',
                h: '17'
            },
            text: '预计两小时内到账',
            alignment: 'right',
            textColor: '666666',
            size: 12
        }, {
            class: 'HeroLabel',
            frame: {
                r: '15',
                w: '200',
                y: '273',
                h: '17'
            },
            text: localStorage.payDate,
            alignment: 'right',
            textColor: '333333',
            size: 16
        }, {
            class: 'HeroLabel',
            frame: {
                r: '15',
                w: '200',
                y: '320',
                h: '17'
            },
            text: API.fmoney(localStorage.payAmount, 2),
            alignment: 'right',
            textColor: '333333',
            size: 16
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                b: '0',
                h: '75'
            },
            borderColor: 'e4e4e4',
            hidden: localStorage.fromIndex === 1,
            subViews: [
                {
                    class: 'DRButton',
                    DRStyle: 'B1',
                    title: '完成',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '15',
                        h: '45'
                    },
                    click: {
                        click: 'done'
                    }
                }
            ]
        }
    ]
};
