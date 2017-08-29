// You can access variables provided by `src/environments`
// HOME_PAGE is equal to publicPath
export const PATH = (window.location.origin + process.env.HOME_PAGE)
export const IS_PRODUCTION = process.env.NODE_ENV === 'production'
export const BACKEND_URL = process.env.backendURL
