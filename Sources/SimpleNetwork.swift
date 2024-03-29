//
//  SimpleNetwork.swift
//  SimpleNetwork
//
//  Created by 谢聪捷 on 3/3/15.
//  Copyright (c) 2015 谢聪捷. All rights reserved.
//

import Foundation

///  常用的网络访问方法 -> 枚举类型的定义
///
///  - GET:  GET 请求
///  - POST: POST 请求
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}


public class SimpleNetwork {

    
    ///  请求 JSON  方法一
    ///
    ///  :param: Method     HTTP 访问方法
    ///  :param: urlString  urlString
    ///  :param: params     可选参数字典
    ///  :param: completion 完成回调
    // 取别名：定义闭包类型，类型别名 -> 首字母一定要大写
    public typealias Completion = (result: AnyObject?, error: NSError?) -> ()
    public func requestJSON(method: HTTPMethod, _ urlString: String, _ params: [String: String]?,completion: Completion) {
        
        // 实例化网络请求
        if let request = request(method, urlString, params) {
            
            // 访问网络 - 本身的回调方法是异步的
            session!.dataTaskWithRequest(request, completionHandler: { (data, _, error) -> Void in
                
                // 如果有错误，直接回调，将网络访问的错误传回
                if error != nil {
                    completion(result: nil, error: error)
                    return
                }
                
                // 反序列化 -> 字典或者数组
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
                
                // 判断是否反序列化成功
                if json == nil {
                    let error = NSError(domain: SimpleNetwork.errorDomain, code: -1, userInfo: ["error": "反序列化失败"])
                    completion(result: json, error: error)
                } else {
                    // 反序列化成功，有结果
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        completion(result: json, error: nil)
                    })
                }
            }).resume()
            
            return
        }
        
        // 如果网络请求没有创建成功，应该生成一个错误，提供给其他的开发者
        /**
            domain: 错误所属领域字符串，com.itheima.error
            code:   如果是复杂的系统，可以自己定义错误编号
            userInfo:   错误信息字典
        */
        let error = NSError(domain: SimpleNetwork.errorDomain, code: -1, userInfo: ["error": "请求建立失败"])
        completion(result: nil, error: error)
        
    }
    
    // 类属性，跟对象无关，调用时需使用类名调用
    static let errorDomain = "com.itheima.error"
    
    ///  全局网络会话, 提示，可以利用构造函数，设置不同的网络会话配置
    lazy var session: NSURLSession? = {
        return NSURLSession.sharedSession()
        }()
    
    
    ///  返回网络访问的请求
    ///
    ///  :param: method    HTTP 访问方法
    ///  :param: urlString urlString
    ///  :param: params    可选参数字典
    ///
    ///  :returns: 可选网络请求
    func request(method: HTTPMethod, _ urlString: String, _ params: [String: String]?) -> NSURLRequest? {
        
        // isEmpty 是 "" & nil
        if urlString.isEmpty {
            return nil
        }
        
        // 记录 urlString,因为传入的参数是不可变的
        var urlStr = urlString
        var r: NSMutableURLRequest?
        
        if method == .GET {
            // URL 的参数是拼接在URL字符串中的
            // 1.生成查询字符串
            let query = queryString(params)
            
            // 2.如果有拼接参数
            if query != nil {
                urlStr += "?" + query!
            }
            
            // 3.实例化请求
            r = NSMutableURLRequest(URL: NSURL(string: urlStr)!)
        } else {
            
            // 设置请求体，提问：POST访问，能没有请求体码？ -> 必需要提交数据给服务器
            if let query = queryString(params) {
                
                r = NSMutableURLRequest(URL: NSURL(string: urlString)!)
                
                // 设置请求方法
                // swift 语言中，枚举类型，如果要取返回值，需要使用一个 rawValue
                r!.HTTPMethod = method.rawValue
                
                // 设置数据体
                r!.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        }
        
        return r
    }

    
    
    ///  生成查询字符串
    ///
    ///  :param: params 可选字典
    ///
    ///  :returns: 拼接完成的字符串
    func queryString(params: [String: String]?) -> String? {
        
        // 1. 判断参数
        if params == nil {
            return nil
        }
        
        // 2.涉及到数组的使用技巧
        // 2.1 定义一个数组
        var array = [String]()
        // 2.2 遍历字典
        for (k, v) in params! {
            // 字典中的值要进行百分号转义 以防止特殊符号的拼接
            let str = k + "=" + v.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            array.append(str)
        }
        
        return join("&", array)
    }
    
    // 公共的初始化函数，外部就能够调用了
    public init() {}
    
    
    
}




















































