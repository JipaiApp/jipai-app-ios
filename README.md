# Jipai iOS App

这是基于 Pili Streaming Cloud 实现的一个轻量级直播 App，配合 [jipai-server-node](https://github.com/jipaiapp/jipai-server-node) 可以快速搭建一个可运行的直播 App。

![](./jipai.png)

## 配置

- 替换 `AppDelegate.m` 中的 `kWXAppID` 为你的微信 App ID
- 在 Jipai Target 的 URL Types 中添加微信 App ID
- 替换 `JPApiManager.m` 中的 `kBaseURL` 为你的 `jipai-server-node` 对应的 ip 或者 url

配置完成，编译运行开始直播吧。

## License

- 源码基于 [MIT License](https://opensource.org/licenses/MIT) 开源
- 所有文档及资源（图片）基于 [CC-BY-DN](https://creativecommons.org/licenses/by-nd/4.0/) 开放授权
