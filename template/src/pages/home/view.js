import { PATH as path } from '../../constant/index';

export default {
    	version: 0,
    	backgroundColor: 'f5f5f5',
    	nav: {
        title: '钱速递',
        navigationBarHiddenH5: true
    	},
    	views:
    	[
        {
            class: 'UIView',
            frame: { w: '1x', h: '320' },
            borderColor: 'e4e4e4',
            backgroundColor: 'ffffff'
        },
        {
            class: 'UIView',
            frame: { w: '1x', y: '335', h: '249' },
            borderColor: 'e4e4e4',
            backgroundColor: 'ffffff'
        },
        {
            class: 'HeroLabel',
            name: 'cash',
            alignment: 'center',
            frame: { w: '1x', y: '23', h: '54' },
            textColor: '333333',
            size: 45,
            text: '0'
        },
        {
            class: 'UIView',
            frame: { w: '123', h: '18' },
            center: { x: '0.5x', y: '95' },
            subViews: [
                {
                    class: 'HeroLabel',
                    frame: { w: '1x', h: '19' },
                    textColor: '666666',
                    size: 18,
                    text: '可借额度(元)'
                },
                {
                    class: 'HeroButton',
                    frame: { r: '0', w: '18', h: '18' },
                    image: path + '/images/icon_info-40.png',
                    click: { click: 'info' }
                }
            ]
        },
        {
            class: 'UIView',
            frame: { w: '1x', y: '125', h: '1' },
            backgroundColor: 'e4e4e4'
        },
        {
            class: 'HeroImageView',
            frame: { x: '20', y: '148', w: '16', h: '16' },
            image: path + '/images/icon_done_1.png'
        },
        {
            class: 'HeroLabel',
            name: 'rateDetail1',
            frame: { x: '40', y: '145', w: '200', h: '23' },
            textColor: '666666',
            size: 16,
            attribute: { 'color(4,5)': '000000' },
            text: '日费率 0.03% 起'
        },
        {
            class: 'HeroImageView',
            frame: { x: '20', y: '176', w: '16', h: '16' },
            image: path + '/images/icon_done_1.png'
        },
        {
            class: 'HeroLabel',
            name: 'rateDetail2',
            frame: { x: '40', y: '173', w: '250', h: '23' },
            textColor: '666666',
            size: 16,
            attribute: { 'color(13,3)': '000000' },
            text: '1,000元借一天，费用 0.3 元起'
        },
        {
            class: 'UIView',
            frame: { w: '1x', y: '215', h: '1' },
            backgroundColor: 'e4e4e4'
        },
        {
            class: 'DRButton',
            name: 'applyBtn',
            enable: false,
            DRStyle: 'B1',
            title: '立即申请',
            frame: { x: '15', y: '245', h: '45', r: '15' },
            cornerRadius: 4,
            size: 18,
            ripple: false,
            click: { click: 'apply' }
        },
        {
            class: 'UIView',
            frame: { w: '1x', y: '320', h: '15' },
            backgroundColor: 'f5f5f5',
            borderColor: 'eeeeee'
        },
        {
            class: 'HeroLabel',
            frame: { x: '43', w: '200', y: '353', h: '15' },
            textColor: '00bc8d',
            size: 14,
            text: '钱速递是什么?'
        },
        {
            class: 'HeroLabel',
            frame: { x: '25', r: '25', y: '375', h: '34' },
            textColor: '666666',
            size: 12,
            numberOfLines: 2,
            text: '点融网为满足团团赚在投用户短期资金周转需求，而提供的快速借款居间服务。'
        },
        {
            class: 'HeroLabel',
            frame: { x: '43', w: '200', y: '433', h: '15' },
            textColor: '00bc8d',
            size: 14,
            text: '如何申请？'
        },
        {
            class: 'HeroLabel',
            frame: { x: '25', r: '25', y: '455', h: '34' },
            textColor: '666666',
            size: 12,
            numberOfLines: 2,
            text: '直接线上申请，系统自动审批，审批通过后预计可在2小时内将出借人资金划付至您绑定银行卡。'
        },
        {
            class: 'HeroLabel',
            frame: { x: '43', w: '200', y: '513', h: '15' },
            textColor: '00bc8d',
            size: 14,
            text: '如何还款？'
        },
        {
            class: 'HeroLabel',
            frame: { x: '25', r: '25', y: '535', h: '34' },
            textColor: '666666',
            size: 12,
            numberOfLines: 2,
            hAuto: true,
            text: '支持随借随还。借款开始日的次日起即可提前还款，提前还款可减免您借款剩余天数的利息。'
        },
        {
            class: 'UIView',
            frame: { x: '25', r: '25', y: '421', h: '1' },
            backgroundColor: 'e4e4e4'
        },
        {
            class: 'UIView',
            frame: { x: '25', r: '25', y: '501', h: '1' },
            backgroundColor: 'e4e4e4'
        },
        {
            class: 'HeroImageView',
            frame: { x: '20', w: '18', y: '351', h: '18' },
            image: path + '/images/icon_1.png'
        },
        {
            class: 'HeroImageView',
            frame: { x: '20', w: '18', y: '431', h: '18' },
            image: path + '/images/icon_2.png'
        },
        {
            class: 'HeroImageView',
            frame: { x: '20', w: '18', y: '511', h: '18' },
            image: path + '/images/icon_3.png'
        },
        {
            class: 'UIView',
            frame: { w: '95', y: '600', h: '40' },
            center: { x: '0.5x', y: '610' },
            subViews: [
                {
                    class: 'HeroButton',
                    frame: { w: '1x', h: '1x' },
                    ripple: false,
                    click: { click: 'faq' }
                },
                {
                    class: 'HeroImageView',
                    frame: { y: '8', w: '13', h: '13' },
                    image: path + '/images/q30.png'
                },
                {
                    class: 'HeroLabel',
                    frame: { y: '4', x: '17', r: '0', h: '22' },
                    textColor: '00bc8d',
                    size: '12',
                    text: '更多常见问题'
                }
            ]
        },
        {
            class: 'HeroButton',
            name: 'maskBtn',
            ripple: false,
            frame: { w: '1x', h: '1x' },
            click: { click: 'mask' },
            hidden: true
        },
        {
            class: 'UIView',
            name: 'maskView',
            enable: false,
            hidden: true,
            frame: { w: '297', h: '88' },
            center: { x: '0.5x', y: '130' },
            subViews: [
                {
                    class: 'HeroImageView',
                    frame: { w: '192', h: '69' },
                    center: { x: '200', y: '53' },
                    image: path + '/images/img_popover.png'
                },
                {
                    class: 'HeroLabel',
                    frame: { w: '166', h: '55' },
                    center: { x: '200', y: '68' },
                    textColor: 'ffffff',
                    size: 12,
                    numberOfLines: 2,
                    text: '依据您在点融网的投资数据综合评估得出的最高可借金额'
                }
            ]
        },
        {
            class: 'HeroToast',
            name: 'toast'
        },
        {
            class: 'HeroView',
            name: 'cover',
            frame: { w: '1x', h: '1x' },
            backgroundColor: 'ffffff'
        }
    	]
};
