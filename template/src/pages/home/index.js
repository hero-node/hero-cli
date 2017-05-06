import { Component, Hero, Boot, Message } from 'hero-js';
import { Entry } from 'hero-cli/decorator';
import {fmoney , dateFormat } from '../../utils/index';
import request from '../../common/request';
import {PATH as path} from '../../constant/index';
import getDefaultUIViews from './view';

var defaultUIViews = getDefaultUIViews();
function realizationHanlder(data){

			if (!data.content.realizeAmount) {
					data.content.realizeAmount = 0;
			};
			if (data.content.realizeAmount) {
					localStorage.realizeAmount = data.content.realizeAmount;
					Hero.out({datas:[
							{name:'cash',text:fmoney(data.content.realizeAmount,0)},
							{name:'applyBtn',enable:true},
							{name:'cover',hidden:true},
					]});
			}else if(data.content.details){
					localStorage.amount = data.content.details[0].amount;
					localStorage.leftPayDays = data.content.details[0].leftPayDays;
					localStorage.payAmount = data.content.details[0].payAmount;
					localStorage.loanId = data.content.details[0].loanId;
					localStorage.canPrepayment = data.content.details[0].canPrepayment;
					var date = new Date();
					date.setTime(data.content.details[0].payDate);
					localStorage.payDate = dateFormat(date,'yyyy-MM-dd');
					localStorage.status = data.content.details[0].status;
					date.setTime(data.content.details[0].transferDate);
					localStorage.transferDate = dateFormat(date,'yyyy-MM-dd');
					if (localStorage.status === 2 || localStorage.status === '2') {
							Hero.out({command:'load:'+path+'/cash_apply_status.html'})
					}else{
							localStorage.fromIndex = 1;
							Hero.out({command:'load:'+path+'/cash_apply_sucess.html'})
					}
			}
}
@Entry()
@Component({
	view: defaultUIViews
})
export class DecoratePage {

    @Boot
    boot(){
      request('/feapi/errors').then(function(data){
				window.errors = data.content.list;
				request('/api/v2/user/realization').then(realizationHanlder, ()=>{});
	      request('/api/v2/user/realization/application').then(function(data){
					localStorage.cardName = data.content.cardName;
					localStorage.cardNo = data.content.cardNo;
					localStorage.feeRateList = JSON.stringify(data.content.feeRateList);
	      }, ()=>{});

      }, ()=>{
				console.log('Server Error...')
			});

			setTimeout(function(){
					Hero.out({datas:[
							{name:'cover',hidden:true},
					]});
			},2000);
    }
    @Message('__data.click === "apply"')
    apply(){
      if (localStorage.realizeAmount && localStorage.feeRateList) {
          // Hero.out({command:'load:'+path+'/cash_apply.html'})
      };
    }

    @Message('__data.click === "faq"')
    faq(){
      // Hero.out({command:'goto:'+path+'/webview.html'});
    }

    @Message('__data.click === "info"')
    info(){
			Hero.out({datas:[
					{name:'maskBtn',hidden:false},
					{name:'maskView',hidden:false},
			]});
    }

    @Message('__data.click === "mask"')
    mask(){
			Hero.out({datas:[
					{name:'maskBtn',hidden:true},
					{name:'maskView',hidden:true},
			]});
    }

}
