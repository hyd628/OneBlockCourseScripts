# FAQ - 常见问题答疑  

## 1. 第三课常见错误

```
Error: moonbeam-truffle-plugin listed as a plugin, but not found in global or local node modules!  

```

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
