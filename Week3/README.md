# FAQ - 常见问题答疑  

## Q1. 第三课常见错误

A:

```
Error: moonbeam-truffle-plugin listed as a plugin, but not found in global or local node modules!  

```
Q
处理方式： 

```
cd moonbeam-truffle-box
npm install @truffle/hdwallet-provider
```

再运行

```
npm install
```

最后在开启docker后运行

```
truffle run moonbeam install 
```

以上就可以安装成功了。


## Q2. truffle run moonbeam start 启动的时候用的端口是 9933， 如何修改 moonbeam start 的docker 占用的端口？

A:
 1. 先检查是否已经在运行一个Moonbeam Docker 容器了 ，如果已经有运行，就不要再开第二个了。
 2. 要修改hostconfig.json, 可参考：https://stackoverflow.com/questions/19335444/how-do-i-assign-a-port-mapping-to-an-existing-docker-container


## Q3. 直接在mac操作是不需要用到docker了吗？

A: 可以不用Docker，第四课也会介绍Moonbase Alpha测试网 所以不想在本地运行节点也可以直接部署到测试网。


## Q4. 安装报错如下

```
(base) ➜  moonbeam-truffle-box truffle run moonbeam install
Error:
Error: moonbeam-truffle-plugin listed as a plugin, but not found in global or local node modules!

    at new ExtendableError (/usr/local/lib/node_modules/truffle/build/webpack:/packages/plugins/node_modules/@truffle/error/index.js:10:1)
    at Object.normalizeConfigPlugins (/usr/local/lib/node_modules/truffle/build/webpack:/packages/plugins/dist/lib/utils.js:30:1)
    at Function.checkPluginModules (/usr/local/lib/node_modules/truffle/build/webpack:/packages/plugins/dist/lib/Plugins.js:50:1)
    at Function.listAll (/usr/local/lib/node_modules/truffle/build/webpack:/packages/plugins/dist/lib/Plugins.js:17:1)
    at Function.findPluginsForCommand (/usr/local/lib/node_modules/truffle/build/webpack:/packages/plugins/dist/lib/Plugins.js:25:1)
    at Object.run (/usr/local/lib/node_modules/truffle/build/webpack:/packages/core/lib/commands/run/run.js:7:1)
    at internal/util.js:297:30
    at new Promise (<anonymous>)
    at bound run (internal/util.js:296:12)
    at Object.run (/usr/local/lib/node_modules/truffle/build/webpack:/packages/core/lib/commands/run/index.js:32:1)
    at Command.run (/usr/local/lib/node_modules/truffle/build/webpack:/packages/core/lib/command.js:172:1)
    at Object.586806 (/usr/local/lib/node_modules/truffle/build/webpack:/packages/core/cli.js:57:1)
    at __webpack_require__ (/usr/local/lib/node_modules/truffle/build/webpack:/webpack/bootstrap:18:1)
    at __webpack_require__.x (/usr/local/lib/node_modules/truffle/build/webpack:/webpack/bootstrap:36:1)
    at Function.__webpack_require__.x (/usr/local/lib/node_modules/truffle/build/webpack:/webpack/runtime/startup chunk dependencies:36:1)
    at /usr/local/lib/node_modules/truffle/build/webpack:/webpack/startup:3:1
Truffle v5.4.10 (core: 5.4.10)
Node v14.15.3
```


A:


```
npm install -g @truffle/hdwallet-provider
我全局安装一直失败，后来就我直接安装在moonbeam-truffle-box下也是可以的

cd moonbeam-truffle-box
npm install @truffle/hdwallet-provider
```



