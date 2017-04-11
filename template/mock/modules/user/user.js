import Mock from 'mockjs';
// Usage:
// http://mockjs.com/examples.html

function subRouter(express) {

    /*eslint-disable*/
    var router = express.Router();

    // Get Method
    router.get('/user', function(req, res) {
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
