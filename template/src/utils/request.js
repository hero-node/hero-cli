import axios from 'axios'
import Qs from 'qs'
import { BACKEND_URL } from '../constant/index'

const instance = axios.create({
  baseURL: BACKEND_URL,
  withCredentials: true,
  transformRequest: req => Qs.stringify(req),
  validateStatus: status => status === 200
})

instance.interceptors.response.use(
  ({ data }) => {
    const result = data.result

    if (result === undefined || result === 'success') return data

    return window.Promise.reject(data)
  }
)

export default instance
