import { Hero } from 'hero-js';
import axios from 'axios';
import qs from 'qs';
import { BACKEND_URL } from '../constant/index';

if (typeof Promise === 'undefined') {
    require('promise/lib/rejection-tracking').enable();
    window.Promise = require('promise/lib/es6-extensions.js');
}

function send(url, method, data) {

    var options = {
        method: method ? method.toUpperCase() : 'GET',
        baseURL: BACKEND_URL,
        withCredentials: true,
        url: url,
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
        },
        paramsSerializer: function (params) {
            return qs.stringify(params, { arrayFormat: 'brackets' });
        },
        transformRequest: [function (req) {
    // Do whatever you want to transform the data
            return qs.stringify(req);
        }]
    };

    data && options.method === 'GET' ? (options.params = data) : (options.data = data);

    return new Promise((resolve, reject) => {
        Hero.out({ command: 'showLoading' });

        axios(options).then((resp) => {
            if (!resp) {
                reject(null);
                return;
            }
            if (resp.data) {
                if (resp.data.result === 'success') {
                    resolve(resp.data);
                } else {
                    reject(resp.data);
                }
            } else {
                reject(resp);
            }
        }, (error) => {
            console.log(error);
            reject(error);
        }).catch(() => {
        }).then(() => {
            Hero.out({ command: 'stopLoading' });
        });
    });

}
export default send;
