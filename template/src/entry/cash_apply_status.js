require('hero-js');

var API = window.API;

API.boot = function () {};
// eslint-disable-next-line
API.special_logic = function () {};
API.reloadData = function () {};
window.ui = {
    version: 0,
    backgroundColor: 'ffffff',
    nav: {
        title: '快速变现',
        navigationBarHiddenH5: true
    },
    views: [
        {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '20',
                h: '19'
            },
            textColor: '666666',
            alignment: 'center',
            size: 18,
            text: '待还金额(元)'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '49',
                h: '54'
            },
            textColor: '333333',
            alignment: 'center',
            size: 45,
            text: API.fmoney(localStorage.payAmount, 2)
        }, {
            class: 'UIView',
            frame: {
                w: '190',
                h: '23'
            },
            center: {
                x: '0.5x',
                y: '157'
            },
            subViews: [
                {
                    class: 'HeroImageView',
                    frame: {
                        x: '0',
                        y: '1',
                        w: '20',
                        h: '20'
                    },
                    image: 'icon_duedate'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '23',
                        w: '58',
                        h: '23'
                    },
                    textColor: '666666',
                    size: 16,
                    text: '还款日:'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '78',
                        w: '110',
                        h: '23'
                    },
                    textColor: '000000',
                    size: 16,
                    text: localStorage.payDate
                }
            ]
        }, {
            class: 'HeroImageView',
            name: 'statusIcon',
            frame: {
                w: '60',
                h: '54'
            },
            center: {
                x: '0.5x',
                y: '210'
            },
            image: 'icon_counting'
        }, {
            class: 'HeroLabel',
            name: 'weidaoqi',
            hidden: (parseInt(localStorage.leftPayDays, 10) === 0),
            frame: {
                x: '0',
                r: '0',
                y: '252',
                h: '22'
            },
            textColor: '333333',
            alignment: 'center',
            size: 16,
            attribute: {
                'color(8,2)': '00bc8d',
                'size(8,2)': 18
            },
            text: '距离还款日还有 ' + localStorage.leftPayDays + ' 天'
        }, {
            class: 'HeroImageView',
            frame: {
                x: '17',
                y: '319',
                w: '15',
                h: '15'
            },
            image: 'icon_info-36'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '40',
                r: '15',
                y: '316',
                h: '46'
            },
            textColor: '666666',
            numberOfLines: 2,
            size: 14,
            attribute: {
                'gap': 22
            },
            text: '请确保绑定银行卡余额充足，将从还款日起自动还款'
        }, {
            class: 'HeroImageView',
            name: 'daoqi1',
            hidden: (parseInt(localStorage.leftPayDays, 10) !== 0),
            frame: {
                x: '17',
                y: '375',
                w: '15',
                h: '15'
            },
            image: 'icon_info-36'
        }, {
            class: 'HeroLabel',
            name: 'daoqi2',
            hidden: (parseInt(localStorage.leftPayDays, 10) !== 0),
            frame: {
                x: '40',
                r: '16',
                y: '373',
                h: '68'
            },
            textColor: '666666',
            numberOfLines: 3,
            size: 14,
            attribute: {
                'gap': 22
            },
            text: '若到期未及时还款， 变现借款将继续按日产生利息。若 ' + localStorage.transferDate + ' 前未完成还款，当天系统将对您在团团赚的投资发起债权转让，以偿还借款'
        }, {
            class: 'HeroLabel',
            name: 'daoqi3',
            hidden: (parseInt(localStorage.leftPayDays, 10) !== 0),
            frame: {
                x: '0',
                r: '0',
                y: '255',
                h: '18'
            },
            textColor: '333333',
            size: 18,
            alignment: 'center',
            text: '已到期'
        }, {
            class: 'UIView',
            frame: {
                w: '1x',
                y: '300',
                h: '1'
            },
            backgroundColor: 'e4e4e4'
        }, {
            class: 'UIView',
            frame: {
                w: '60',
                h: '1'
            },
            center: {
                x: '0.5x',
                y: '114'
            },
            backgroundColor: 'e4e4e4'
        }
    ]
};
