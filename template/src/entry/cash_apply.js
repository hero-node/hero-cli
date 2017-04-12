require('hero-js');

var API = window.API;
var ui2Data = window.ui2Data;
var path = window.path;

API.boot = function () {
    ui2Data.agreeBox = true;
    ui2Data.money = 0;
    ui2Data.durationSlider = '7天';
};
// eslint-disable-next-line
API.special_logic = function (data) {
    if (data.click === 'apply') {
        API.out({
            datas: [
                {
                    name: 'passwordView',
                    hidden: false
                }, {
                    name: 'passwordTextField',
                    clear: true,
                    focus: true
                }, {
                    name: 'password1',
                    hidden: true
                }, {
                    name: 'password2',
                    hidden: true
                }, {
                    name: 'password3',
                    hidden: true
                }, {
                    name: 'password4',
                    hidden: true
                }, {
                    name: 'password5',
                    hidden: true
                }, {
                    name: 'password6',
                    hidden: true
                }
            ]
        });
    }
    if (data.click === 'close') {
        API.out({
            datas: [
                {
                    name: 'passwordView',
                    hidden: true
                }, {
                    name: 'passwordTextField',
                    blur: true
                }
            ]
        });
    }
    if (data.click === 'agree') {
        let moneyOK = (ui2Data.money > 100 && ui2Data.money < 200000);

        API.out({
            datas: [
                {
                    name: 'nextBtn',
                    enable: data.value && moneyOK
                }
            ]
        });
    }
    if (data.click === 'license') {
        location.href = path + '/license.html';
    }
    if (data.click === 'passwordClick') {
        API.out({
            datas: [
                {
                    name: 'passwordTextField',
                    focus: true
                }
            ]
        });
    }
    if (data.edit === 'end') {
        let val = data.value;

        if ((!val) || (val.length === 0)) {
            API.out({
                datas: [
                    {
                        name: 'errorInfo',
                        hidden: false,
                        text: '变现金额必须是100的整数倍'
                    }, {
                        name: 'moreView',
                        hidden: true
                    }, {
                        name: 'nextView',
                        frame: {
                            x: '0',
                            y: '240',
                            w: '1x',
                            h: '152'
                        }
                    }, {
                        name: 'money',
                        borderColor: 'ff0000'
                    }
                ]
            });
        } else if (val % 100 !== 0) {
            API.out({
                datas: [
                    {
                        name: 'errorInfo',
                        hidden: false,
                        text: '变现金额必须是100的整数倍'
                    }, {
                        name: 'moreView',
                        hidden: true
                    }, {
                        name: 'nextView',
                        frame: {
                            x: '0',
                            y: '240',
                            w: '1x',
                            h: '152'
                        }
                    }, {
                        name: 'money',
                        borderColor: 'ff0000'
                    }
                ]
            });
        } else if (parseInt(val, 10) < 1000) {
            API.out({
                datas: [
                    {
                        name: 'errorInfo',
                        hidden: false,
                        text: '变现金额必须大于1,000元'
                    }, {
                        name: 'moreView',
                        hidden: true
                    }, {
                        name: 'nextView',
                        frame: {
                            x: '0',
                            y: '240',
                            w: '1x',
                            h: '152'
                        }
                    }, {
                        name: 'money',
                        borderColor: 'ff0000'
                    }
                ]
            });
        } else if (parseInt(val, 10) > parseInt(localStorage.realizeAmount, 10)) {
            API.out({
                datas: [
                    {
                        name: 'errorInfo',
                        hidden: false,
                        text: '变现金额不能超过限额'
                    }, {
                        name: 'moreView',
                        hidden: true
                    }, {
                        name: 'nextView',
                        frame: {
                            x: '0',
                            y: '240',
                            w: '1x',
                            h: '152'
                        }
                    }, {
                        name: 'money',
                        borderColor: 'ff0000'
                    }
                ]
            });
        } else {
            API.out({
                datas: [
                    {
                        name: 'errorInfo',
                        hidden: true
                    }, {
                        name: 'moreView',
                        hidden: false
                    }, {
                        name: 'nextView',
                        frame: {
                            x: '0',
                            y: '495',
                            w: '1x',
                            h: '152'
                        }
                    }, {
                        name: 'nextBtn',
                        enable: ui2Data.agreeBox
                    }, {
                        name: 'pay',
                        text: API.fmoney(parseInt(ui2Data.money, 10) * localStorage.feeRate * parseInt(ui2Data.durationSlider, 10) + parseInt(ui2Data.money, 10))
                    }, {
                        name: 'cost',
                        text: API.fmoney(parseInt(ui2Data.money, 10) * localStorage.feeRate * parseInt(ui2Data.durationSlider, 10))
                    }
                ]
            });
        }
    }
    if (data.change === 'durationSlider') {
        API.out({
            datas: [
                {
                    name: 'pay',
                    text: API.fmoney(parseInt(ui2Data.money, 10) * localStorage.feeRate * parseInt(ui2Data.durationSlider, 10) + parseInt(ui2Data.money, 10))
                }, {
                    name: 'cost',
                    text: API.fmoney(parseInt(ui2Data.money, 10) * localStorage.feeRate * parseInt(ui2Data.durationSlider, 10))
                }
            ]
        });
    }
    if (data.edit === 'start') {
        API.out({
            datas: [
                {
                    name: 'errorInfo',
                    hidden: true
                }
            ]
        });
    }
    if (data.edit === 'passwordEditing') {
        API.out({
            datas: [
                {
                    name: 'password1',
                    hidden: 1 > ui2Data.passwordTextField.length
                }, {
                    name: 'password2',
                    hidden: 2 > ui2Data.passwordTextField.length
                }, {
                    name: 'password3',
                    hidden: 3 > ui2Data.passwordTextField.length
                }, {
                    name: 'password4',
                    hidden: 4 > ui2Data.passwordTextField.length
                }, {
                    name: 'password5',
                    hidden: 5 > ui2Data.passwordTextField.length
                }, {
                    name: 'password6',
                    hidden: 6 > ui2Data.passwordTextField.length
                }
            ]
        });
        // eslint-disable-next-line
        if (ui2Data.passwordTextField.length == 6) {
            API.out({
                datas: [
                    {
                        name: 'passwordView',
                        hidden: true
                    }, {
                        name: 'passwordTextField',
                        blur: true
                    }
                ]
            });
            API.out({ command: 'showLoading' });
            API.in({
                http: {
                    'url': '/api/v2/user/realization',
                    method: 'POST',
                    data: {
                        tradeKey: ui2Data.passwordTextField,
                        appAmount: ui2Data.money,
                        loanMaturity: parseInt(ui2Data.durationSlider, 10),
                        maturityType: 'DAILY'
                    }
                }
            });

        }
    }

};
API.reloadData = function (data) {
    if (data.api === '/api/v2/user/realization') {
        localStorage.amount = data.content.amount;
        localStorage.payAmount = data.content.payAmount;
        localStorage.payDate = data.content.payDate;
        API.out({
            command: 'goto:' + path + '/cash_apply_sucess.html'
        });
    }
};

window.ui = {
    version: 0,
    backgroundColor: 'f5f5f5',
    nav: {
        title: '快速变现',
        navigationBarHiddenH5: true
    },
    views: [
        {
            class: 'UIView',
            backgroundColor: 'ffffff',
            frame: {
                x: '0',
                y: '0',
                w: '1x',
                h: '240'
            }
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '20',
                h: '17'
            },
            textColor: '333333',
            size: 16,
            text: '变现金额(元)'
        }, {
            class: 'HeroLabel',
            alignment: 'right',
            frame: {
                x: '15',
                r: '15',
                y: '20',
                h: '20'
            },
            textColor: '999999',
            size: 14,
            text: '1000元起，且为100的倍数'
        }, {
            class: 'DRTextField',
            name: 'money',
            style: 'drlender',
            color: 'cccccc',
            tintColor: '00bc8d',
            type: 'pin',
            size: 16,
            placeHolder: '最高变现' + API.fmoney(isNaN(localStorage.realizeAmount)
                ? 0
                : localStorage.realizeAmount, 0) + '元',
            textFieldDidEndEditing: {
                edit: 'end'
            },
            textFieldDidBeginEditing: {
                edit: 'start'
            },
            frame: {
                x: '15',
                r: '15',
                y: '46',
                h: '45'
            }
        }, {
            class: 'HeroLabel',
            name: 'errorInfo',
            hidden: true,
            frame: {
                x: '27',
                r: '15',
                y: '96',
                h: '17'
            },
            textColor: 'd70c18',
            size: 12,
            text: '错误信息'
        }, {
            class: 'UIView',
            frame: {
                x: '0',
                r: '0',
                y: '124',
                h: '1'
            },
            backgroundColor: 'e4e4e4'
        }, {
            class: 'HeroLabel',
            frame: {
                x: '15',
                r: '15',
                y: '140',
                h: '17'
            },
            textColor: '333333',
            size: 16,
            text: '变现期限'
        }, {
            class: 'DRSliderView',
            name: 'durationSlider',
            frame: {
                x: '15',
                r: '15',
                y: '170',
                h: '50'
            },
            tintColor: '00bc8d',
            change: {
                change: 'durationSlider'
            },
            values: ['7天', '14天', '21天', '28天']
        }, {
            class: 'UIView',
            name: 'moreView',
            frame: {
                x: '0',
                r: '0',
                y: '240',
                h: '254'
            },
            backgroundColor: 'eeeeee',
            borderColor: 'dddddd',
            hidden: true,
            subViews: [
                {
                    class: 'HeroImageView',
                    frame: {
                        x: '15',
                        y: '10',
                        w: '15',
                        h: '15'
                    },
                    image: 'icon_info-36'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '37',
                        y: '7',
                        r: '15',
                        h: '36'
                    },
                    numberOfLines: 2,
                    size: 14,
                    textColor: '666666',
                    text: '还款日当天，将从您绑定银行卡中自动扣除还款金额，请确保银行卡余额充足'
                }, {
                    class: 'UIView',
                    frame: {
                        x: '0',
                        r: '0',
                        y: '53',
                        h: '200'
                    },
                    backgroundColor: 'ffffff',
                    borderColor: 'e4e4e4'
                }, {
                    class: 'UIView',
                    frame: {
                        x: '0',
                        r: '0',
                        y: '103',
                        h: '1'
                    },
                    backgroundColor: 'e4e4e4'
                }, {
                    class: 'UIView',
                    frame: {
                        x: '15',
                        r: '0',
                        y: '153',
                        h: '1'
                    },
                    backgroundColor: 'e4e4e4'
                }, {
                    class: 'UIView',
                    frame: {
                        x: '15',
                        r: '0',
                        y: '203',
                        h: '1'
                    },
                    backgroundColor: 'e4e4e4'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '55',
                        h: '50'
                    },
                    textColor: '666666',
                    size: 16,
                    text: '到账银行卡'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '105',
                        h: '50'
                    },
                    textColor: '666666',
                    size: 16,
                    text: '日费率'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '155',
                        h: '50'
                    },
                    textColor: '666666',
                    size: 16,
                    text: '变现费用(元)'
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '205',
                        h: '50'
                    },
                    textColor: '666666',
                    size: 16,
                    text: '应还金额(元)'
                }, {
                    class: 'HeroImageView',
                    name: 'bankIcon',
                    frame: {
                        r: '200',
                        w: '22',
                        y: '68',
                        h: '22'
                    },
                    image: localStorage.cardName.indexOf('招商') > -1
                        ? 'zsyh'
                        : localStorage.cardName.indexOf('北京银行') > -1
                            ? 'bjyh'
                            : localStorage.cardName.indexOf('广东发展') > -1
                                ? 'gdfzyh'
                                : localStorage.cardName.indexOf('深圳发展') > -1
                                    ? 'szfzyh'
                                    : localStorage.cardName.indexOf('光大') > -1
                                        ? 'zggdyh'
                                        : localStorage.cardName.indexOf('中国工商') > -1
                                            ? 'zggsyh'
                                            : localStorage.cardName.indexOf('中国建设') > -1
                                                ? 'zgjsyh'
                                                : localStorage.cardName.indexOf('民生银行') > -1
                                                    ? 'zgmsyh'
                                                    : localStorage.cardName.indexOf('中国农业') > -1
                                                        ? 'zgnyyh'
                                                        : localStorage.cardName.indexOf('中国银行') > -1
                                                            ? 'zgyh'
                                                            : localStorage.cardName.indexOf('邮政') > -1
                                                                ? 'zgyzcxyh'
                                                                : ''
                }, {
                    class: 'HeroLabel',
                    name: 'bankText',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '55',
                        h: '50'
                    },
                    textColor: '333333',
                    size: 16,
                    alignment: 'right',
                    text: localStorage.cardName + '(尾号' + localStorage.cardNo.substr(localStorage.cardNo.length - 4, 4) + ')'
                }, {
                    class: 'HeroLabel',
                    name: 'rate',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '105',
                        h: '50'
                    },
                    textColor: '333333',
                    size: 16,
                    alignment: 'right',
                    text: '0.03%'
                }, {
                    class: 'HeroLabel',
                    name: 'cost',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '155',
                        h: '50'
                    },
                    textColor: '333333',
                    size: 16,
                    alignment: 'right'
                }, {
                    class: 'HeroLabel',
                    name: 'pay',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '205',
                        h: '50'
                    },
                    textColor: '333333',
                    size: 16,
                    alignment: 'right'
                }
            ]
        }, {
            class: 'UIView',
            name: 'nextView',
            frame: {
                x: '0',
                y: '240',
                w: '1x',
                h: '152'
            },
            subViews: [
                {
                    class: 'HeroCheckBox',
                    name: 'agreeBox',
                    checked: true,
                    color: '00bc8d',
                    frame: {
                        x: '15',
                        w: '15',
                        y: '22',
                        h: '15'
                    },
                    tintColor: '00bc8d',
                    click: {
                        click: 'agree'
                    }
                }, {
                    class: 'HeroButton',
                    frame: {
                        x: '40',
                        r: '15',
                        y: '20',
                        h: '64'
                    },
                    click: {
                        click: 'license'
                    },
                    titleColor: '00bc8d'
                }, {
                    class: 'HeroLabel',
                    numberOfLines: 4,
                    size: 12,
                    frame: {
                        x: '40',
                        r: '15',
                        y: '18',
                        h: '66'
                    },
                    textColor: '999999',
                    attribute: {
                        'color(7, 61)': '00bc8d'
                    },
                    text: '我已阅读并同意《委托代扣授权书》《点融网借款人服务协议》《借款协议》《借款项目发布申请批准通知书》《承诺书》《系统实时匹配交易服务协议》'
                }, {
                    class: 'DRButton',
                    name: 'nextBtn',
                    enable: false,
                    DRStyle: 'B1',
                    title: '确认申请',
                    frame: {
                        x: '15',
                        r: '15',
                        y: '102',
                        h: '45'
                    },
                    click: {
                        click: 'apply'
                    }
                }
            ]
        }, {
            class: 'UIView',
            name: 'passwordView',
            hidden: true,
            frame: {
                w: '1x',
                h: '1.5x'
            },
            backgroundColor: '000000aa',
            subViews: [
                {
                    class: 'UIView',
                    frame: {
                        x: '35',
                        y: '110',
                        r: '35',
                        h: '180'
                    },
                    backgroundColor: 'ffffff',
                    cornerRadius: 2
                }, {
                    class: 'HeroImageView',
                    frame: {
                        r: '43',
                        w: '12',
                        y: '118',
                        h: '12'
                    },
                    image: 'icon_Close'
                }, {
                    class: 'HeroButton',
                    frame: {
                        r: '35',
                        w: '30',
                        y: '110',
                        h: '30'
                    },
                    click: {
                        click: 'close'
                    }
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '35',
                        y: '130',
                        r: '35',
                        h: '19'
                    },
                    textColor: '333333',
                    alignment: 'center',
                    text: '输入交易密码',
                    size: 18
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '35',
                        y: '155',
                        r: '35',
                        h: '19'
                    },
                    textColor: '333333',
                    alignment: 'center',
                    text: '请输入6位数字交易密码',
                    size: 14
                }, {
                    class: 'HeroLabel',
                    frame: {
                        x: '50',
                        y: '260',
                        r: '35',
                        h: '19'
                    },
                    textColor: '999999',
                    text: '若忘记密码，请至"我的设置-密码管理"修改',
                    size: 12
                }, {
                    class: 'HeroButton',
                    frame: {
                        w: '270',
                        h: '45'
                    },
                    center: {
                        x: '0.5x',
                        y: '215'
                    },
                    ripple: false,
                    click: {
                        click: 'passwordClick'
                    }
                }, {
                    class: 'UIView',
                    enable: false,
                    frame: {
                        w: '270',
                        h: '45'
                    },
                    borderColor: 'e4e4e4',
                    center: {
                        x: '0.5x',
                        y: '215'
                    },
                    cornerRadius: 2,
                    subViews: [
                        {
                            class: 'UIView',
                            frame: {
                                x: '45',
                                y: '0',
                                w: '1',
                                h: '45'
                            },
                            backgroundColor: 'e4e4e4'
                        }, {
                            class: 'UIView',
                            frame: {
                                x: '90',
                                y: '0',
                                w: '1',
                                h: '45'
                            },
                            backgroundColor: 'e4e4e4'
                        }, {
                            class: 'UIView',
                            frame: {
                                x: '135',
                                y: '0',
                                w: '1',
                                h: '45'
                            },
                            backgroundColor: 'e4e4e4'
                        }, {
                            class: 'UIView',
                            frame: {
                                x: '180',
                                y: '0',
                                w: '1',
                                h: '45'
                            },
                            backgroundColor: 'e4e4e4'
                        }, {
                            class: 'UIView',
                            frame: {
                                x: '225',
                                y: '0',
                                w: '1',
                                h: '45'
                            },
                            backgroundColor: 'e4e4e4'
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password1',
                            frame: {
                                x: '18',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password2',
                            frame: {
                                x: '63',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password3',
                            frame: {
                                x: '108',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password4',
                            frame: {
                                x: '153',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password5',
                            frame: {
                                x: '198',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }, {
                            class: 'UIView',
                            hidden: true,
                            name: 'password6',
                            frame: {
                                x: '243',
                                y: '18',
                                w: '10',
                                h: '10'
                            },
                            backgroundColor: '000000',
                            cornerRadius: 7
                        }
                    ]
                }, {
                    class: 'DRTextField',
                    name: 'passwordTextField',
                    type: 'pin',
                    frame: {
                        x: '0',
                        y: '-1110',
                        w: '100',
                        h: '10'
                    },
                    textFieldDidBeginEditing: {
                        edit: 'passwordStart'
                    },
                    textFieldDidEndEditing: {
                        edit: 'passwordEnd'
                    },
                    textFieldDidEditing: {
                        edit: 'passwordEditing'
                    }
                }
            ]
        }, {
            class: 'HeroToast',
            name: 'toast'
        }
    ]
};
