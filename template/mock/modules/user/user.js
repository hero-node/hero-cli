import Mock from 'mockjs';
// Usage: 
// http://mockjs.com/examples.html

function subRouter(express) {

    /*eslint-disable*/
    var router = express.Router();

    // 下载文件
    router.get('/user/download', function(req, res) {
        return res.download(path.join(__dirname, '../download/sample.pdf'), '补件-' + new Date().getTime() + '.pdf');
    });

    // Get Method
    router.get('/user', function(req, res) {
        console.log(req.query);
        // http://www.expressjs.com.cn/4x/api.html#res.json
        return res.json({
            result: 'success',
            content: {
                // http://www.expressjs.com.cn/4x/api.html#req.params
                planId: req.params.planId,
                desc: Mock.Random.paragraph()
            }
        });
    });

    return router;
}

export default {
    root: '/',
    router: subRouter
};
